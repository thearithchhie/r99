import 'dart:convert';
import 'dart:io';

import 'package:r99/export.dart';

class DeliveryImportResult {
  const DeliveryImportResult({
    required this.records,
    required this.skippedRows,
    required this.messages,
    required this.exportUrl,
  });

  final List<DeliveryRecord> records;
  final int skippedRows;
  final List<String> messages;
  final String exportUrl;
}

class GoogleSheetDeliveryImportService {
  const GoogleSheetDeliveryImportService._();

  static const String _shopPhoneNumber = '0977156486';

  static Future<DeliveryImportResult> importFromShareUrl(String shareUrl) async {
    final resolvedShareUrl = resolveShareUrl(shareUrl);
    final exportUri = buildCsvExportUri(resolvedShareUrl);
    final csvText = await downloadCsv(exportUri);
    final rows = _parseCsv(csvText);

    if (rows.isEmpty) {
      throw const FormatException('The Google Sheet has no rows.');
    }

    final headers = rows.first.map((value) => sanitizeCell(value).toLowerCase()).toList();

    // Only columns in the ColumMapHeader enum are mapped. Any column not in the enum
    // (e.g. telegram_link, map, or any future addition) is completely ignored.
    final columnMap = <ColumMapHeader, int>{};
    for (final header in ColumMapHeader.values) {
      final index = headers.indexOf(header.key);
      if (index >= 0) columnMap[header] = index;
    }

    const mustHaveHeaders = [
      ColumMapHeader.shop,
      ColumMapHeader.customername,
      ColumMapHeader.phone,
      ColumMapHeader.location,
      ColumMapHeader.totalprice,
      ColumMapHeader.deliverService,
      ColumMapHeader.status,
      ColumMapHeader.chatRespondentName,
      ColumMapHeader.link,
      ColumMapHeader.outlet,
      ColumMapHeader.createdBy,
    ];
    final missingColumns = mustHaveHeaders
        .where((h) => !columnMap.containsKey(h))
        .map((h) => h.key)
        .toList();
    if (missingColumns.isNotEmpty) {
      throw FormatException('Missing required columns: ${missingColumns.join(', ')}');
    }

    // Required fields in Excel column order — add/remove entries here to maintain validation.
    const requiredFields = [
      (ColumMapHeader.shop, 'shop'),
      (ColumMapHeader.phone, 'phone number'),
      (ColumMapHeader.location, 'location'),
      (ColumMapHeader.status, 'status'),
      (ColumMapHeader.chatRespondentName, 'chat respondent name'),
      (ColumMapHeader.link, 'link'),
      (ColumMapHeader.outlet, 'outlet'),
      (ColumMapHeader.createdBy, 'created by'),
    ];

    final missingRows = <ColumMapHeader, List<String>>{for (final (header, _) in requiredFields) header: []};
    final shopPhoneRows = <String>[];

    final importedAt = DateTime.now();
    final records = <DeliveryRecord>[];
    final messages = <String>[];
    var skippedRows = 0;

    for (var index = 1; index < rows.length; index++) {
      final row = rows[index];

      String valueOf(ColumMapHeader header) {
        final columnIndex = columnMap[header];
        if (columnIndex == null || columnIndex >= row.length) return '';
        return sanitizeCell(row[columnIndex]);
      }

      final customerName = valueOf(ColumMapHeader.customername);
      final phone = valueOf(ColumMapHeader.phone).replaceAll(' ', '');
      final location = valueOf(ColumMapHeader.location);
      final rawPrice = valueOf(ColumMapHeader.totalprice);
      final deliverService = valueOf(ColumMapHeader.deliverService);
      final shop = valueOf(ColumMapHeader.shop);
      final status = valueOf(ColumMapHeader.status);
      final chatRespondentName = valueOf(ColumMapHeader.chatRespondentName);
      final link = valueOf(ColumMapHeader.link);
      final outlet = valueOf(ColumMapHeader.outlet);
      final createdBy = valueOf(ColumMapHeader.createdBy);

      if (customerName.isEmpty &&
          phone.isEmpty &&
          location.isEmpty &&
          rawPrice.isEmpty &&
          deliverService.isEmpty &&
          shop.isEmpty &&
          status.isEmpty &&
          chatRespondentName.isEmpty &&
          link.isEmpty &&
          outlet.isEmpty &&
          createdBy.isEmpty) {
        skippedRows++;
        continue;
      }

      String rowLabel() => customerName.isNotEmpty ? '"$customerName" (row ${index + 1})' : 'Row ${index + 1}';

      final fieldValues = {
        ColumMapHeader.shop: shop,
        ColumMapHeader.phone: phone,
        ColumMapHeader.location: location,
        ColumMapHeader.status: status,
        ColumMapHeader.chatRespondentName: chatRespondentName,
        ColumMapHeader.link: link,
        ColumMapHeader.outlet: outlet,
        ColumMapHeader.createdBy: createdBy,
      };

      bool rowHasError = false;
      for (final (header, label) in requiredFields) {
        if (fieldValues[header]!.isEmpty) {
          missingRows[header]!.add(rowLabel());
          messages.add('${rowLabel()}: skipped — missing $label');
          rowHasError = true;
          break;
        }
      }
      if (rowHasError) continue;

      if (phone == _shopPhoneNumber) {
        shopPhoneRows.add(rowLabel());
        continue;
      }

      final price = (status == OrderStatus.alradyPaid || status == OrderStatus.paidByShop) ? r'$0' : rawPrice;

      final stickerIndex = columnMap[ColumMapHeader.sticker];
      if (stickerIndex != null) {
        final rawSticker = stickerIndex < row.length ? row[stickerIndex] : '';
        final sticker = sanitizeCell(rawSticker);
        if (sticker != StickerValue.ok) {
          final stickerDisplay = sticker.isEmpty ? '(empty)' : sticker;
          messages.add('${rowLabel()}: skipped — sticker "$stickerDisplay"');
          skippedRows++;
          continue;
        }
      }

      records.add(
        DeliveryRecord()
          ..importedAt = importedAt
          ..sourceUrl = resolvedShareUrl
          ..customerName = customerName
          ..phone = phone
          ..location = location
          ..price = price
          ..deliverService = deliverService
          ..shop = shop,
      );
    }

    if (shopPhoneRows.isNotEmpty) {
      throw FormatException('This is phone number of shop in: ${shopPhoneRows.join(', ')}');
    }

    for (final (header, label) in requiredFields) {
      final rows = missingRows[header]!;
      if (rows.isNotEmpty) {
        throw FormatException('Missing $label in: ${rows.join(', ')}');
      }
    }

    return DeliveryImportResult(
      records: records,
      skippedRows: skippedRows,
      messages: messages,
      exportUrl: exportUri.toString(),
    );
  }

  static String resolveShareUrl(String shareUrl) {
    final trimmedInput = shareUrl.trim();
    if (trimmedInput.isNotEmpty) {
      try {
        buildCsvExportUri(trimmedInput);
        return trimmedInput;
      } catch (_) {}
    }

    final fallback = AppLoadEnv.googleSheetLink;
    if (fallback.isEmpty) {
      if (trimmedInput.isEmpty) {
        throw const FormatException('Missing Google Sheet URL.');
      }
      throw const FormatException('Invalid Google Sheet share URL.');
    }

    buildCsvExportUri(fallback);
    return fallback;
  }

  static Uri buildCsvExportUri(String shareUrl) {
    final source = Uri.parse(shareUrl.trim());
    final segments = source.pathSegments;
    final idIndex = segments.indexOf('d');
    if (idIndex < 0 || idIndex + 1 >= segments.length) {
      throw const FormatException('Invalid Google Sheet share URL.');
    }

    final sheetId = segments[idIndex + 1];
    final gid = source.queryParameters['gid'] ?? '0';

    return Uri.https('docs.google.com', '/spreadsheets/d/$sheetId/export', {'format': 'csv', 'gid': gid});
  }

  static Future<String> downloadCsv(Uri exportUri) async {
    final client = HttpClient();
    try {
      final request = await client.getUrl(exportUri);
      request.headers.set(HttpHeaders.userAgentHeader, 'Mozilla/5.0 Flutter GoogleSheet Import');
      final response = await request.close();
      if (response.statusCode != HttpStatus.ok) {
        throw HttpException(
          'Google Sheet download failed with status ${response.statusCode}. Make sure the sheet is shared publicly.',
          uri: exportUri,
        );
      }

      final body = await response.transform(utf8.decoder).join();
      if (body.trim().isEmpty) {
        throw const FormatException('The downloaded sheet is empty.');
      }
      return body;
    } finally {
      client.close();
    }
  }

  static String sanitizeCell(Object? value) {
    return (value?.toString() ?? '')
        .replaceAll('\uFEFF', '')   // BOM
        .replaceAll('\u00A0', ' ')  // non-breaking space
        .replaceAll('\uFE0F', '')   // emoji variation selector-16 (e.g. \uD83D\uDC4C vs \uD83D\uDC4C\uFE0E)
        .trim();
  }

  // Lenient CSV parser: splits on newlines first, then rejoins lines that
  // belong to a quoted multiline cell (e.g. a location field with an embedded
  // \n). Rejoining is capped at 10 lines per row so a malformed last-column
  // quoted field (e.g. an unclosed maps URL) cannot consume all subsequent rows.
  static List<List<Object>> _parseCsv(String csvText) {
    final rows = <List<Object>>[];
    final lines = csvText.split(RegExp(r'\r?\n'));
    var i = 0;
    while (i < lines.length) {
      var line = lines[i];
      i++;
      // Rejoin continuation lines for RFC4180 multiline cells (quoted fields
      // that span multiple physical lines). Cap at 10 to bound damage from a
      // malformed last-column quote that never closes.
      var joins = 0;
      while (joins < 10 && i < lines.length && _hasOpenQuote(line)) {
        line = '$line\n${lines[i]}';
        i++;
        joins++;
      }
      if (line.isNotEmpty) rows.add(_parseCsvRow(line));
    }
    return rows;
  }

  // Returns true if [line] has an odd number of unescaped double-quote
  // characters, meaning we are still inside a quoted field at end-of-line.
  static bool _hasOpenQuote(String line) {
    var inQuote = false;
    for (var j = 0; j < line.length; j++) {
      if (line[j] == '"') {
        if (inQuote && j + 1 < line.length && line[j + 1] == '"') {
          j++; // skip escaped ""
        } else {
          inQuote = !inQuote;
        }
      }
    }
    return inQuote;
  }

  static List<Object> _parseCsvRow(String rowText) {
    final fields = <Object>[];
    var i = 0;
    final len = rowText.length;

    do {
      if (i < len && rowText[i] == '"') {
        // Quoted field \u2014 consume until unescaped closing quote.
        i++;
        final sb = StringBuffer();
        while (i < len) {
          final c = rowText[i];
          if (c == '"') {
            i++;
            if (i < len && rowText[i] == '"') {
              sb.write('"'); // doubled quote = literal "
              i++;
            } else {
              break; // closing quote
            }
          } else {
            sb.write(c);
            i++;
          }
        }
        // Skip any stray characters between the closing quote and the next comma
        // (handles malformed CSV where text follows the closing quote).
        while (i < len && rowText[i] != ',') i++;
        fields.add(sb.toString());
      } else {
        // Unquoted field.
        final start = i;
        while (i < len && rowText[i] != ',') i++;
        fields.add(rowText.substring(start, i));
      }

      if (i < len && rowText[i] == ',') {
        i++; // consume delimiter and continue
      } else {
        break;
      }
    } while (true);

    return fields;
  }
}
