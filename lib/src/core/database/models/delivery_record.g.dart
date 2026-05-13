// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delivery_record.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetDeliveryRecordCollection on Isar {
  IsarCollection<DeliveryRecord> get deliveryRecords => this.collection();
}

const DeliveryRecordSchema = CollectionSchema(
  name: r'DeliveryRecord',
  id: -8233966962468054066,
  properties: {
    r'customerName': PropertySchema(
      id: 0,
      name: r'customerName',
      type: IsarType.string,
    ),
    r'deliverService': PropertySchema(
      id: 1,
      name: r'deliverService',
      type: IsarType.string,
    ),
    r'importedAt': PropertySchema(
      id: 2,
      name: r'importedAt',
      type: IsarType.dateTime,
    ),
    r'lastPrintedAt': PropertySchema(
      id: 3,
      name: r'lastPrintedAt',
      type: IsarType.dateTime,
    ),
    r'location': PropertySchema(
      id: 4,
      name: r'location',
      type: IsarType.string,
    ),
    r'phone': PropertySchema(id: 5, name: r'phone', type: IsarType.string),
    r'price': PropertySchema(id: 6, name: r'price', type: IsarType.string),
    r'printCount': PropertySchema(
      id: 7,
      name: r'printCount',
      type: IsarType.long,
    ),
    r'shop': PropertySchema(id: 8, name: r'shop', type: IsarType.string),
    r'sourceUrl': PropertySchema(
      id: 9,
      name: r'sourceUrl',
      type: IsarType.string,
    ),
  },

  estimateSize: _deliveryRecordEstimateSize,
  serialize: _deliveryRecordSerialize,
  deserialize: _deliveryRecordDeserialize,
  deserializeProp: _deliveryRecordDeserializeProp,
  idName: r'id',
  indexes: {
    r'importedAt': IndexSchema(
      id: 5552566418050361863,
      name: r'importedAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'importedAt',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _deliveryRecordGetId,
  getLinks: _deliveryRecordGetLinks,
  attach: _deliveryRecordAttach,
  version: '3.3.2',
);

int _deliveryRecordEstimateSize(
  DeliveryRecord object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.customerName.length * 3;
  bytesCount += 3 + object.deliverService.length * 3;
  bytesCount += 3 + object.location.length * 3;
  bytesCount += 3 + object.phone.length * 3;
  bytesCount += 3 + object.price.length * 3;
  bytesCount += 3 + object.shop.length * 3;
  bytesCount += 3 + object.sourceUrl.length * 3;
  return bytesCount;
}

void _deliveryRecordSerialize(
  DeliveryRecord object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.customerName);
  writer.writeString(offsets[1], object.deliverService);
  writer.writeDateTime(offsets[2], object.importedAt);
  writer.writeDateTime(offsets[3], object.lastPrintedAt);
  writer.writeString(offsets[4], object.location);
  writer.writeString(offsets[5], object.phone);
  writer.writeString(offsets[6], object.price);
  writer.writeLong(offsets[7], object.printCount);
  writer.writeString(offsets[8], object.shop);
  writer.writeString(offsets[9], object.sourceUrl);
}

DeliveryRecord _deliveryRecordDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = DeliveryRecord();
  object.customerName = reader.readString(offsets[0]);
  object.deliverService = reader.readString(offsets[1]);
  object.id = id;
  object.importedAt = reader.readDateTime(offsets[2]);
  object.lastPrintedAt = reader.readDateTimeOrNull(offsets[3]);
  object.location = reader.readString(offsets[4]);
  object.phone = reader.readString(offsets[5]);
  object.price = reader.readString(offsets[6]);
  object.printCount = reader.readLong(offsets[7]);
  object.shop = reader.readString(offsets[8]);
  object.sourceUrl = reader.readString(offsets[9]);
  return object;
}

P _deliveryRecordDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _deliveryRecordGetId(DeliveryRecord object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _deliveryRecordGetLinks(DeliveryRecord object) {
  return [];
}

void _deliveryRecordAttach(
  IsarCollection<dynamic> col,
  Id id,
  DeliveryRecord object,
) {
  object.id = id;
}

extension DeliveryRecordQueryWhereSort
    on QueryBuilder<DeliveryRecord, DeliveryRecord, QWhere> {
  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterWhere> anyImportedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'importedAt'),
      );
    });
  }
}

extension DeliveryRecordQueryWhere
    on QueryBuilder<DeliveryRecord, DeliveryRecord, QWhereClause> {
  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterWhereClause> idBetween(
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

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterWhereClause>
  importedAtEqualTo(DateTime importedAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'importedAt', value: [importedAt]),
      );
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterWhereClause>
  importedAtNotEqualTo(DateTime importedAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'importedAt',
                lower: [],
                upper: [importedAt],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'importedAt',
                lower: [importedAt],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'importedAt',
                lower: [importedAt],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'importedAt',
                lower: [],
                upper: [importedAt],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterWhereClause>
  importedAtGreaterThan(DateTime importedAt, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'importedAt',
          lower: [importedAt],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterWhereClause>
  importedAtLessThan(DateTime importedAt, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'importedAt',
          lower: [],
          upper: [importedAt],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterWhereClause>
  importedAtBetween(
    DateTime lowerImportedAt,
    DateTime upperImportedAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'importedAt',
          lower: [lowerImportedAt],
          includeLower: includeLower,
          upper: [upperImportedAt],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension DeliveryRecordQueryFilter
    on QueryBuilder<DeliveryRecord, DeliveryRecord, QFilterCondition> {
  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterFilterCondition>
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

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterFilterCondition>
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

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterFilterCondition>
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

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterFilterCondition>
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

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterFilterCondition>
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

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterFilterCondition>
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

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterFilterCondition>
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

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterFilterCondition>
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

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterFilterCondition>
  customerNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'customerName', value: ''),
      );
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterFilterCondition>
  customerNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'customerName', value: ''),
      );
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterFilterCondition>
  deliverServiceEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'deliverService',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterFilterCondition>
  deliverServiceGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'deliverService',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterFilterCondition>
  deliverServiceLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'deliverService',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterFilterCondition>
  deliverServiceBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'deliverService',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterFilterCondition>
  deliverServiceStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'deliverService',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterFilterCondition>
  deliverServiceEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'deliverService',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterFilterCondition>
  deliverServiceContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'deliverService',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterFilterCondition>
  deliverServiceMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'deliverService',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterFilterCondition>
  deliverServiceIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'deliverService', value: ''),
      );
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterFilterCondition>
  deliverServiceIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'deliverService', value: ''),
      );
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterFilterCondition>
  idGreaterThan(Id value, {bool include = false}) {
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

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterFilterCondition>
  idLessThan(Id value, {bool include = false}) {
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

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterFilterCondition> idBetween(
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

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterFilterCondition>
  importedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'importedAt', value: value),
      );
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterFilterCondition>
  importedAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'importedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterFilterCondition>
  importedAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'importedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterFilterCondition>
  importedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'importedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterFilterCondition>
  lastPrintedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'lastPrintedAt'),
      );
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterFilterCondition>
  lastPrintedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'lastPrintedAt'),
      );
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterFilterCondition>
  lastPrintedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastPrintedAt', value: value),
      );
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterFilterCondition>
  lastPrintedAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lastPrintedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterFilterCondition>
  lastPrintedAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lastPrintedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterFilterCondition>
  lastPrintedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lastPrintedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterFilterCondition>
  locationEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'location',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterFilterCondition>
  locationGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'location',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterFilterCondition>
  locationLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'location',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterFilterCondition>
  locationBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'location',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterFilterCondition>
  locationStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'location',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterFilterCondition>
  locationEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'location',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterFilterCondition>
  locationContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'location',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterFilterCondition>
  locationMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'location',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterFilterCondition>
  locationIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'location', value: ''),
      );
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterFilterCondition>
  locationIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'location', value: ''),
      );
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterFilterCondition>
  phoneEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'phone',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterFilterCondition>
  phoneGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'phone',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterFilterCondition>
  phoneLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'phone',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterFilterCondition>
  phoneBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'phone',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterFilterCondition>
  phoneStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'phone',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterFilterCondition>
  phoneEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'phone',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterFilterCondition>
  phoneContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'phone',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterFilterCondition>
  phoneMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'phone',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterFilterCondition>
  phoneIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'phone', value: ''),
      );
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterFilterCondition>
  phoneIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'phone', value: ''),
      );
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterFilterCondition>
  priceEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'price',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterFilterCondition>
  priceGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'price',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterFilterCondition>
  priceLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'price',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterFilterCondition>
  priceBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'price',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterFilterCondition>
  priceStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'price',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterFilterCondition>
  priceEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'price',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterFilterCondition>
  priceContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'price',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterFilterCondition>
  priceMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'price',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterFilterCondition>
  priceIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'price', value: ''),
      );
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterFilterCondition>
  priceIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'price', value: ''),
      );
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterFilterCondition>
  printCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'printCount', value: value),
      );
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterFilterCondition>
  printCountGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'printCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterFilterCondition>
  printCountLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'printCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterFilterCondition>
  printCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'printCount',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterFilterCondition>
  shopEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'shop',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterFilterCondition>
  shopGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'shop',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterFilterCondition>
  shopLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'shop',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterFilterCondition>
  shopBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'shop',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterFilterCondition>
  shopStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'shop',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterFilterCondition>
  shopEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'shop',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterFilterCondition>
  shopContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'shop',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterFilterCondition>
  shopMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'shop',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterFilterCondition>
  shopIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'shop', value: ''),
      );
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterFilterCondition>
  shopIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'shop', value: ''),
      );
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterFilterCondition>
  sourceUrlEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'sourceUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterFilterCondition>
  sourceUrlGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'sourceUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterFilterCondition>
  sourceUrlLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'sourceUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterFilterCondition>
  sourceUrlBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'sourceUrl',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterFilterCondition>
  sourceUrlStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'sourceUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterFilterCondition>
  sourceUrlEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'sourceUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterFilterCondition>
  sourceUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'sourceUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterFilterCondition>
  sourceUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'sourceUrl',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterFilterCondition>
  sourceUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'sourceUrl', value: ''),
      );
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterFilterCondition>
  sourceUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'sourceUrl', value: ''),
      );
    });
  }
}

extension DeliveryRecordQueryObject
    on QueryBuilder<DeliveryRecord, DeliveryRecord, QFilterCondition> {}

extension DeliveryRecordQueryLinks
    on QueryBuilder<DeliveryRecord, DeliveryRecord, QFilterCondition> {}

extension DeliveryRecordQuerySortBy
    on QueryBuilder<DeliveryRecord, DeliveryRecord, QSortBy> {
  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterSortBy>
  sortByCustomerName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customerName', Sort.asc);
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterSortBy>
  sortByCustomerNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customerName', Sort.desc);
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterSortBy>
  sortByDeliverService() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deliverService', Sort.asc);
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterSortBy>
  sortByDeliverServiceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deliverService', Sort.desc);
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterSortBy>
  sortByImportedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importedAt', Sort.asc);
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterSortBy>
  sortByImportedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importedAt', Sort.desc);
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterSortBy>
  sortByLastPrintedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPrintedAt', Sort.asc);
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterSortBy>
  sortByLastPrintedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPrintedAt', Sort.desc);
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterSortBy> sortByLocation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'location', Sort.asc);
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterSortBy>
  sortByLocationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'location', Sort.desc);
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterSortBy> sortByPhone() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'phone', Sort.asc);
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterSortBy> sortByPhoneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'phone', Sort.desc);
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterSortBy> sortByPrice() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'price', Sort.asc);
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterSortBy> sortByPriceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'price', Sort.desc);
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterSortBy>
  sortByPrintCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'printCount', Sort.asc);
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterSortBy>
  sortByPrintCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'printCount', Sort.desc);
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterSortBy> sortByShop() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shop', Sort.asc);
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterSortBy> sortByShopDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shop', Sort.desc);
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterSortBy> sortBySourceUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceUrl', Sort.asc);
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterSortBy>
  sortBySourceUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceUrl', Sort.desc);
    });
  }
}

extension DeliveryRecordQuerySortThenBy
    on QueryBuilder<DeliveryRecord, DeliveryRecord, QSortThenBy> {
  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterSortBy>
  thenByCustomerName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customerName', Sort.asc);
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterSortBy>
  thenByCustomerNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customerName', Sort.desc);
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterSortBy>
  thenByDeliverService() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deliverService', Sort.asc);
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterSortBy>
  thenByDeliverServiceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deliverService', Sort.desc);
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterSortBy>
  thenByImportedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importedAt', Sort.asc);
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterSortBy>
  thenByImportedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importedAt', Sort.desc);
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterSortBy>
  thenByLastPrintedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPrintedAt', Sort.asc);
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterSortBy>
  thenByLastPrintedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPrintedAt', Sort.desc);
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterSortBy> thenByLocation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'location', Sort.asc);
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterSortBy>
  thenByLocationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'location', Sort.desc);
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterSortBy> thenByPhone() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'phone', Sort.asc);
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterSortBy> thenByPhoneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'phone', Sort.desc);
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterSortBy> thenByPrice() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'price', Sort.asc);
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterSortBy> thenByPriceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'price', Sort.desc);
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterSortBy>
  thenByPrintCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'printCount', Sort.asc);
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterSortBy>
  thenByPrintCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'printCount', Sort.desc);
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterSortBy> thenByShop() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shop', Sort.asc);
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterSortBy> thenByShopDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shop', Sort.desc);
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterSortBy> thenBySourceUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceUrl', Sort.asc);
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QAfterSortBy>
  thenBySourceUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceUrl', Sort.desc);
    });
  }
}

extension DeliveryRecordQueryWhereDistinct
    on QueryBuilder<DeliveryRecord, DeliveryRecord, QDistinct> {
  QueryBuilder<DeliveryRecord, DeliveryRecord, QDistinct>
  distinctByCustomerName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'customerName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QDistinct>
  distinctByDeliverService({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'deliverService',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QDistinct>
  distinctByImportedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'importedAt');
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QDistinct>
  distinctByLastPrintedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastPrintedAt');
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QDistinct> distinctByLocation({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'location', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QDistinct> distinctByPhone({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'phone', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QDistinct> distinctByPrice({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'price', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QDistinct>
  distinctByPrintCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'printCount');
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QDistinct> distinctByShop({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'shop', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DeliveryRecord, DeliveryRecord, QDistinct> distinctBySourceUrl({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sourceUrl', caseSensitive: caseSensitive);
    });
  }
}

extension DeliveryRecordQueryProperty
    on QueryBuilder<DeliveryRecord, DeliveryRecord, QQueryProperty> {
  QueryBuilder<DeliveryRecord, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<DeliveryRecord, String, QQueryOperations>
  customerNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'customerName');
    });
  }

  QueryBuilder<DeliveryRecord, String, QQueryOperations>
  deliverServiceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deliverService');
    });
  }

  QueryBuilder<DeliveryRecord, DateTime, QQueryOperations>
  importedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'importedAt');
    });
  }

  QueryBuilder<DeliveryRecord, DateTime?, QQueryOperations>
  lastPrintedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastPrintedAt');
    });
  }

  QueryBuilder<DeliveryRecord, String, QQueryOperations> locationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'location');
    });
  }

  QueryBuilder<DeliveryRecord, String, QQueryOperations> phoneProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'phone');
    });
  }

  QueryBuilder<DeliveryRecord, String, QQueryOperations> priceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'price');
    });
  }

  QueryBuilder<DeliveryRecord, int, QQueryOperations> printCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'printCount');
    });
  }

  QueryBuilder<DeliveryRecord, String, QQueryOperations> shopProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'shop');
    });
  }

  QueryBuilder<DeliveryRecord, String, QQueryOperations> sourceUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sourceUrl');
    });
  }
}
