// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'print_invoice.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPrintInvoiceCollection on Isar {
  IsarCollection<PrintInvoice> get printInvoices => this.collection();
}

const PrintInvoiceSchema = CollectionSchema(
  name: r'PrintInvoice',
  id: 5246536357237002194,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'currency': PropertySchema(
      id: 1,
      name: r'currency',
      type: IsarType.string,
    ),
    r'customerName': PropertySchema(
      id: 2,
      name: r'customerName',
      type: IsarType.string,
    ),
    r'guestServiceChecked': PropertySchema(
      id: 3,
      name: r'guestServiceChecked',
      type: IsarType.bool,
    ),
    r'jtChecked': PropertySchema(
      id: 4,
      name: r'jtChecked',
      type: IsarType.bool,
    ),
    r'locationLines': PropertySchema(
      id: 5,
      name: r'locationLines',
      type: IsarType.stringList,
    ),
    r'otherChecked': PropertySchema(
      id: 6,
      name: r'otherChecked',
      type: IsarType.bool,
    ),
    r'pageName': PropertySchema(
      id: 7,
      name: r'pageName',
      type: IsarType.string,
    ),
    r'phoneLines': PropertySchema(
      id: 8,
      name: r'phoneLines',
      type: IsarType.stringList,
    ),
    r'printerName': PropertySchema(
      id: 9,
      name: r'printerName',
      type: IsarType.string,
    ),
    r'printerTransport': PropertySchema(
      id: 10,
      name: r'printerTransport',
      type: IsarType.string,
    ),
    r'selectedOption': PropertySchema(
      id: 11,
      name: r'selectedOption',
      type: IsarType.string,
    ),
    r'totalPrice': PropertySchema(
      id: 12,
      name: r'totalPrice',
      type: IsarType.string,
    ),
    r'virakChecked': PropertySchema(
      id: 13,
      name: r'virakChecked',
      type: IsarType.bool,
    ),
  },

  estimateSize: _printInvoiceEstimateSize,
  serialize: _printInvoiceSerialize,
  deserialize: _printInvoiceDeserialize,
  deserializeProp: _printInvoiceDeserializeProp,
  idName: r'id',
  indexes: {
    r'createdAt': IndexSchema(
      id: -3433535483987302584,
      name: r'createdAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'createdAt',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _printInvoiceGetId,
  getLinks: _printInvoiceGetLinks,
  attach: _printInvoiceAttach,
  version: '3.3.2',
);

int _printInvoiceEstimateSize(
  PrintInvoice object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.currency.length * 3;
  bytesCount += 3 + object.customerName.length * 3;
  bytesCount += 3 + object.locationLines.length * 3;
  {
    for (var i = 0; i < object.locationLines.length; i++) {
      final value = object.locationLines[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.pageName.length * 3;
  bytesCount += 3 + object.phoneLines.length * 3;
  {
    for (var i = 0; i < object.phoneLines.length; i++) {
      final value = object.phoneLines[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.printerName.length * 3;
  bytesCount += 3 + object.printerTransport.length * 3;
  bytesCount += 3 + object.selectedOption.length * 3;
  bytesCount += 3 + object.totalPrice.length * 3;
  return bytesCount;
}

void _printInvoiceSerialize(
  PrintInvoice object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeString(offsets[1], object.currency);
  writer.writeString(offsets[2], object.customerName);
  writer.writeBool(offsets[3], object.guestServiceChecked);
  writer.writeBool(offsets[4], object.jtChecked);
  writer.writeStringList(offsets[5], object.locationLines);
  writer.writeBool(offsets[6], object.otherChecked);
  writer.writeString(offsets[7], object.pageName);
  writer.writeStringList(offsets[8], object.phoneLines);
  writer.writeString(offsets[9], object.printerName);
  writer.writeString(offsets[10], object.printerTransport);
  writer.writeString(offsets[11], object.selectedOption);
  writer.writeString(offsets[12], object.totalPrice);
  writer.writeBool(offsets[13], object.virakChecked);
}

PrintInvoice _printInvoiceDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PrintInvoice();
  object.createdAt = reader.readDateTime(offsets[0]);
  object.currency = reader.readString(offsets[1]);
  object.customerName = reader.readString(offsets[2]);
  object.guestServiceChecked = reader.readBool(offsets[3]);
  object.id = id;
  object.jtChecked = reader.readBool(offsets[4]);
  object.locationLines = reader.readStringList(offsets[5]) ?? [];
  object.otherChecked = reader.readBool(offsets[6]);
  object.pageName = reader.readString(offsets[7]);
  object.phoneLines = reader.readStringList(offsets[8]) ?? [];
  object.printerName = reader.readString(offsets[9]);
  object.printerTransport = reader.readString(offsets[10]);
  object.selectedOption = reader.readString(offsets[11]);
  object.totalPrice = reader.readString(offsets[12]);
  object.virakChecked = reader.readBool(offsets[13]);
  return object;
}

P _printInvoiceDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readBool(offset)) as P;
    case 5:
      return (reader.readStringList(offset) ?? []) as P;
    case 6:
      return (reader.readBool(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readStringList(offset) ?? []) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readString(offset)) as P;
    case 13:
      return (reader.readBool(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _printInvoiceGetId(PrintInvoice object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _printInvoiceGetLinks(PrintInvoice object) {
  return [];
}

void _printInvoiceAttach(
  IsarCollection<dynamic> col,
  Id id,
  PrintInvoice object,
) {
  object.id = id;
}

extension PrintInvoiceQueryWhereSort
    on QueryBuilder<PrintInvoice, PrintInvoice, QWhere> {
  QueryBuilder<PrintInvoice, PrintInvoice, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterWhere> anyCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'createdAt'),
      );
    });
  }
}

extension PrintInvoiceQueryWhere
    on QueryBuilder<PrintInvoice, PrintInvoice, QWhereClause> {
  QueryBuilder<PrintInvoice, PrintInvoice, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterWhereClause> idNotEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterWhereClause> createdAtEqualTo(
    DateTime createdAt,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'createdAt', value: [createdAt]),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterWhereClause>
  createdAtNotEqualTo(DateTime createdAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'createdAt',
                lower: [],
                upper: [createdAt],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'createdAt',
                lower: [createdAt],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'createdAt',
                lower: [createdAt],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'createdAt',
                lower: [],
                upper: [createdAt],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterWhereClause>
  createdAtGreaterThan(DateTime createdAt, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'createdAt',
          lower: [createdAt],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterWhereClause> createdAtLessThan(
    DateTime createdAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'createdAt',
          lower: [],
          upper: [createdAt],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterWhereClause> createdAtBetween(
    DateTime lowerCreatedAt,
    DateTime upperCreatedAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'createdAt',
          lower: [lowerCreatedAt],
          includeLower: includeLower,
          upper: [upperCreatedAt],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension PrintInvoiceQueryFilter
    on QueryBuilder<PrintInvoice, PrintInvoice, QFilterCondition> {
  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdAt', value: value),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  createdAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  createdAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'createdAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  currencyEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'currency',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  currencyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'currency',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  currencyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'currency',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  currencyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'currency',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  currencyStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'currency',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  currencyEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'currency',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  currencyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'currency',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  currencyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'currency',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  currencyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'currency', value: ''),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  currencyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'currency', value: ''),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  customerNameEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'customerName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  customerNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'customerName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  customerNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'customerName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  customerNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'customerName',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  customerNameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'customerName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  customerNameEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'customerName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  customerNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'customerName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  customerNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'customerName',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  customerNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'customerName', value: ''),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  customerNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'customerName', value: ''),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  guestServiceCheckedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'guestServiceChecked', value: value),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  jtCheckedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'jtChecked', value: value),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  locationLinesElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'locationLines',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  locationLinesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'locationLines',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  locationLinesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'locationLines',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  locationLinesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'locationLines',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  locationLinesElementStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'locationLines',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  locationLinesElementEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'locationLines',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  locationLinesElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'locationLines',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  locationLinesElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'locationLines',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  locationLinesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'locationLines', value: ''),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  locationLinesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'locationLines', value: ''),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  locationLinesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'locationLines', length, true, length, true);
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  locationLinesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'locationLines', 0, true, 0, true);
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  locationLinesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'locationLines', 0, false, 999999, true);
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  locationLinesLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'locationLines', 0, true, length, include);
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  locationLinesLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'locationLines', length, include, 999999, true);
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  locationLinesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'locationLines',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  otherCheckedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'otherChecked', value: value),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  pageNameEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'pageName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  pageNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'pageName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  pageNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'pageName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  pageNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'pageName',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  pageNameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'pageName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  pageNameEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'pageName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  pageNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'pageName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  pageNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'pageName',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  pageNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'pageName', value: ''),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  pageNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'pageName', value: ''),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  phoneLinesElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'phoneLines',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  phoneLinesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'phoneLines',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  phoneLinesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'phoneLines',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  phoneLinesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'phoneLines',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  phoneLinesElementStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'phoneLines',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  phoneLinesElementEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'phoneLines',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  phoneLinesElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'phoneLines',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  phoneLinesElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'phoneLines',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  phoneLinesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'phoneLines', value: ''),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  phoneLinesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'phoneLines', value: ''),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  phoneLinesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'phoneLines', length, true, length, true);
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  phoneLinesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'phoneLines', 0, true, 0, true);
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  phoneLinesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'phoneLines', 0, false, 999999, true);
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  phoneLinesLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'phoneLines', 0, true, length, include);
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  phoneLinesLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'phoneLines', length, include, 999999, true);
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  phoneLinesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'phoneLines',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  printerNameEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'printerName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  printerNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'printerName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  printerNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'printerName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  printerNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'printerName',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  printerNameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'printerName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  printerNameEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'printerName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  printerNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'printerName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  printerNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'printerName',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  printerNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'printerName', value: ''),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  printerNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'printerName', value: ''),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  printerTransportEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'printerTransport',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  printerTransportGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'printerTransport',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  printerTransportLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'printerTransport',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  printerTransportBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'printerTransport',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  printerTransportStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'printerTransport',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  printerTransportEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'printerTransport',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  printerTransportContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'printerTransport',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  printerTransportMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'printerTransport',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  printerTransportIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'printerTransport', value: ''),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  printerTransportIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'printerTransport', value: ''),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  selectedOptionEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'selectedOption',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  selectedOptionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'selectedOption',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  selectedOptionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'selectedOption',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  selectedOptionBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'selectedOption',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  selectedOptionStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'selectedOption',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  selectedOptionEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'selectedOption',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  selectedOptionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'selectedOption',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  selectedOptionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'selectedOption',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  selectedOptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'selectedOption', value: ''),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  selectedOptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'selectedOption', value: ''),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  totalPriceEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'totalPrice',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  totalPriceGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'totalPrice',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  totalPriceLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'totalPrice',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  totalPriceBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'totalPrice',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  totalPriceStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'totalPrice',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  totalPriceEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'totalPrice',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  totalPriceContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'totalPrice',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  totalPriceMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'totalPrice',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  totalPriceIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'totalPrice', value: ''),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  totalPriceIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'totalPrice', value: ''),
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterFilterCondition>
  virakCheckedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'virakChecked', value: value),
      );
    });
  }
}

extension PrintInvoiceQueryObject
    on QueryBuilder<PrintInvoice, PrintInvoice, QFilterCondition> {}

extension PrintInvoiceQueryLinks
    on QueryBuilder<PrintInvoice, PrintInvoice, QFilterCondition> {}

extension PrintInvoiceQuerySortBy
    on QueryBuilder<PrintInvoice, PrintInvoice, QSortBy> {
  QueryBuilder<PrintInvoice, PrintInvoice, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterSortBy> sortByCurrency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.asc);
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterSortBy> sortByCurrencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.desc);
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterSortBy> sortByCustomerName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customerName', Sort.asc);
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterSortBy>
  sortByCustomerNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customerName', Sort.desc);
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterSortBy>
  sortByGuestServiceChecked() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'guestServiceChecked', Sort.asc);
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterSortBy>
  sortByGuestServiceCheckedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'guestServiceChecked', Sort.desc);
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterSortBy> sortByJtChecked() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'jtChecked', Sort.asc);
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterSortBy> sortByJtCheckedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'jtChecked', Sort.desc);
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterSortBy> sortByOtherChecked() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'otherChecked', Sort.asc);
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterSortBy>
  sortByOtherCheckedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'otherChecked', Sort.desc);
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterSortBy> sortByPageName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pageName', Sort.asc);
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterSortBy> sortByPageNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pageName', Sort.desc);
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterSortBy> sortByPrinterName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'printerName', Sort.asc);
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterSortBy>
  sortByPrinterNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'printerName', Sort.desc);
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterSortBy>
  sortByPrinterTransport() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'printerTransport', Sort.asc);
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterSortBy>
  sortByPrinterTransportDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'printerTransport', Sort.desc);
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterSortBy>
  sortBySelectedOption() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'selectedOption', Sort.asc);
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterSortBy>
  sortBySelectedOptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'selectedOption', Sort.desc);
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterSortBy> sortByTotalPrice() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalPrice', Sort.asc);
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterSortBy>
  sortByTotalPriceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalPrice', Sort.desc);
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterSortBy> sortByVirakChecked() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'virakChecked', Sort.asc);
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterSortBy>
  sortByVirakCheckedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'virakChecked', Sort.desc);
    });
  }
}

extension PrintInvoiceQuerySortThenBy
    on QueryBuilder<PrintInvoice, PrintInvoice, QSortThenBy> {
  QueryBuilder<PrintInvoice, PrintInvoice, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterSortBy> thenByCurrency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.asc);
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterSortBy> thenByCurrencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.desc);
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterSortBy> thenByCustomerName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customerName', Sort.asc);
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterSortBy>
  thenByCustomerNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customerName', Sort.desc);
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterSortBy>
  thenByGuestServiceChecked() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'guestServiceChecked', Sort.asc);
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterSortBy>
  thenByGuestServiceCheckedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'guestServiceChecked', Sort.desc);
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterSortBy> thenByJtChecked() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'jtChecked', Sort.asc);
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterSortBy> thenByJtCheckedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'jtChecked', Sort.desc);
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterSortBy> thenByOtherChecked() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'otherChecked', Sort.asc);
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterSortBy>
  thenByOtherCheckedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'otherChecked', Sort.desc);
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterSortBy> thenByPageName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pageName', Sort.asc);
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterSortBy> thenByPageNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pageName', Sort.desc);
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterSortBy> thenByPrinterName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'printerName', Sort.asc);
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterSortBy>
  thenByPrinterNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'printerName', Sort.desc);
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterSortBy>
  thenByPrinterTransport() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'printerTransport', Sort.asc);
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterSortBy>
  thenByPrinterTransportDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'printerTransport', Sort.desc);
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterSortBy>
  thenBySelectedOption() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'selectedOption', Sort.asc);
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterSortBy>
  thenBySelectedOptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'selectedOption', Sort.desc);
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterSortBy> thenByTotalPrice() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalPrice', Sort.asc);
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterSortBy>
  thenByTotalPriceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalPrice', Sort.desc);
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterSortBy> thenByVirakChecked() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'virakChecked', Sort.asc);
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QAfterSortBy>
  thenByVirakCheckedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'virakChecked', Sort.desc);
    });
  }
}

extension PrintInvoiceQueryWhereDistinct
    on QueryBuilder<PrintInvoice, PrintInvoice, QDistinct> {
  QueryBuilder<PrintInvoice, PrintInvoice, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QDistinct> distinctByCurrency({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currency', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QDistinct> distinctByCustomerName({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'customerName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QDistinct>
  distinctByGuestServiceChecked() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'guestServiceChecked');
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QDistinct> distinctByJtChecked() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'jtChecked');
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QDistinct>
  distinctByLocationLines() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'locationLines');
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QDistinct> distinctByOtherChecked() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'otherChecked');
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QDistinct> distinctByPageName({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pageName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QDistinct> distinctByPhoneLines() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'phoneLines');
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QDistinct> distinctByPrinterName({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'printerName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QDistinct>
  distinctByPrinterTransport({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'printerTransport',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QDistinct> distinctBySelectedOption({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'selectedOption',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QDistinct> distinctByTotalPrice({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalPrice', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PrintInvoice, PrintInvoice, QDistinct> distinctByVirakChecked() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'virakChecked');
    });
  }
}

extension PrintInvoiceQueryProperty
    on QueryBuilder<PrintInvoice, PrintInvoice, QQueryProperty> {
  QueryBuilder<PrintInvoice, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PrintInvoice, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<PrintInvoice, String, QQueryOperations> currencyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currency');
    });
  }

  QueryBuilder<PrintInvoice, String, QQueryOperations> customerNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'customerName');
    });
  }

  QueryBuilder<PrintInvoice, bool, QQueryOperations>
  guestServiceCheckedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'guestServiceChecked');
    });
  }

  QueryBuilder<PrintInvoice, bool, QQueryOperations> jtCheckedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'jtChecked');
    });
  }

  QueryBuilder<PrintInvoice, List<String>, QQueryOperations>
  locationLinesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'locationLines');
    });
  }

  QueryBuilder<PrintInvoice, bool, QQueryOperations> otherCheckedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'otherChecked');
    });
  }

  QueryBuilder<PrintInvoice, String, QQueryOperations> pageNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pageName');
    });
  }

  QueryBuilder<PrintInvoice, List<String>, QQueryOperations>
  phoneLinesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'phoneLines');
    });
  }

  QueryBuilder<PrintInvoice, String, QQueryOperations> printerNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'printerName');
    });
  }

  QueryBuilder<PrintInvoice, String, QQueryOperations>
  printerTransportProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'printerTransport');
    });
  }

  QueryBuilder<PrintInvoice, String, QQueryOperations>
  selectedOptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'selectedOption');
    });
  }

  QueryBuilder<PrintInvoice, String, QQueryOperations> totalPriceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalPrice');
    });
  }

  QueryBuilder<PrintInvoice, bool, QQueryOperations> virakCheckedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'virakChecked');
    });
  }
}
