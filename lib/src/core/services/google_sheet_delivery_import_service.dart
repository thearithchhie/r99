import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
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

  static Future<DeliveryImportResult> importFromShareUrl(String shareUrl) async {
    final resolvedShareUrl = resolveShareUrl(shareUrl);
    final exportUri = buildCsvExportUri(resolvedShareUrl);
    final csvText = await downloadCsv(exportUri);
    final rows = const CsvToListConverter(shouldParseNumbers: false, eol: '\n').convert(csvText);

    if (rows.isEmpty) {
      throw const FormatException('The Google Sheet has no rows.');
    }

    final headers = rows.first.map((value) => sanitizeCell(value).toLowerCase()).toList();
    final columnMap = <String, int>{
      ColumMapHeader.shop.key: headers.indexOf(ColumMapHeader.shop.key),
      ColumMapHeader.customername.key: headers.indexOf(ColumMapHeader.customername.key),
      ColumMapHeader.phone.key: headers.indexOf(ColumMapHeader.phone.key),
      ColumMapHeader.location.key: headers.indexOf(ColumMapHeader.location.key),
      ColumMapHeader.totalprice.key: headers.indexOf(ColumMapHeader.totalprice.key),
      ColumMapHeader.deliverService.key: headers.indexOf(ColumMapHeader.deliverService.key),
    };

    final missingColumns = columnMap.entries.where((entry) => entry.value < 0).map((entry) => entry.key).toList();
    if (missingColumns.isNotEmpty) {
      throw FormatException('Missing required columns: ${missingColumns.join(', ')}');
    }

    final importedAt = DateTime.now();
    final records = <DeliveryRecord>[];
    final messages = <String>[];
    var skippedRows = 0;

    for (var index = 1; index < rows.length; index++) {
      final row = rows[index];

      String valueOf(String key) {
        final columnIndex = columnMap[key]!;
        if (columnIndex >= row.length) return '';
        return sanitizeCell(row[columnIndex]);
      }

      final customerName = valueOf(ColumMapHeader.customername.key);
      final phone = valueOf(ColumMapHeader.phone.key);
      final location = valueOf(ColumMapHeader.location.key);
      final price = valueOf(ColumMapHeader.totalprice.key);
      final deliverService = valueOf(ColumMapHeader.deliverService.key);
      final shop = valueOf(ColumMapHeader.shop.key);

      if (customerName.isEmpty &&
          phone.isEmpty &&
          location.isEmpty &&
          price.isEmpty &&
          deliverService.isEmpty &&
          shop.isEmpty) {
        skippedRows++;
        continue;
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
          ..shop = shop.isEmpty ? ColumMapHeader.shop.key : shop,
      );
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
    return (value?.toString() ?? '').replaceAll('\uFEFF', '').replaceAll('\u00A0', ' ').trim();
  }
}
