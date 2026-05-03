// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_preference.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAppPreferenceCollection on Isar {
  IsarCollection<AppPreference> get appPreferences => this.collection();
}

const AppPreferenceSchema = CollectionSchema(
  name: r'AppPreference',
  id: -632636125728214278,
  properties: {
    r'showPreview': PropertySchema(
      id: 0,
      name: r'showPreview',
      type: IsarType.bool,
    ),
  },

  estimateSize: _appPreferenceEstimateSize,
  serialize: _appPreferenceSerialize,
  deserialize: _appPreferenceDeserialize,
  deserializeProp: _appPreferenceDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},

  getId: _appPreferenceGetId,
  getLinks: _appPreferenceGetLinks,
  attach: _appPreferenceAttach,
  version: '3.3.2',
);

int _appPreferenceEstimateSize(
  AppPreference object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _appPreferenceSerialize(
  AppPreference object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.showPreview);
}

AppPreference _appPreferenceDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AppPreference(
    id: id,
    showPreview: reader.readBoolOrNull(offsets[0]) ?? true,
  );
  return object;
}

P _appPreferenceDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBoolOrNull(offset) ?? true) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _appPreferenceGetId(AppPreference object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _appPreferenceGetLinks(AppPreference object) {
  return [];
}

void _appPreferenceAttach(
  IsarCollection<dynamic> col,
  Id id,
  AppPreference object,
) {
  object.id = id;
}

extension AppPreferenceQueryWhereSort
    on QueryBuilder<AppPreference, AppPreference, QWhere> {
  QueryBuilder<AppPreference, AppPreference, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension AppPreferenceQueryWhere
    on QueryBuilder<AppPreference, AppPreference, QWhereClause> {
  QueryBuilder<AppPreference, AppPreference, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<AppPreference, AppPreference, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterWhereClause> idBetween(
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
}

extension AppPreferenceQueryFilter
    on QueryBuilder<AppPreference, AppPreference, QFilterCondition> {
  QueryBuilder<AppPreference, AppPreference, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterFilterCondition>
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

  QueryBuilder<AppPreference, AppPreference, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<AppPreference, AppPreference, QAfterFilterCondition> idBetween(
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

  QueryBuilder<AppPreference, AppPreference, QAfterFilterCondition>
  showPreviewEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'showPreview', value: value),
      );
    });
  }
}

extension AppPreferenceQueryObject
    on QueryBuilder<AppPreference, AppPreference, QFilterCondition> {}

extension AppPreferenceQueryLinks
    on QueryBuilder<AppPreference, AppPreference, QFilterCondition> {}

extension AppPreferenceQuerySortBy
    on QueryBuilder<AppPreference, AppPreference, QSortBy> {
  QueryBuilder<AppPreference, AppPreference, QAfterSortBy> sortByShowPreview() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showPreview', Sort.asc);
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterSortBy>
  sortByShowPreviewDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showPreview', Sort.desc);
    });
  }
}

extension AppPreferenceQuerySortThenBy
    on QueryBuilder<AppPreference, AppPreference, QSortThenBy> {
  QueryBuilder<AppPreference, AppPreference, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterSortBy> thenByShowPreview() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showPreview', Sort.asc);
    });
  }

  QueryBuilder<AppPreference, AppPreference, QAfterSortBy>
  thenByShowPreviewDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showPreview', Sort.desc);
    });
  }
}

extension AppPreferenceQueryWhereDistinct
    on QueryBuilder<AppPreference, AppPreference, QDistinct> {
  QueryBuilder<AppPreference, AppPreference, QDistinct>
  distinctByShowPreview() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'showPreview');
    });
  }
}

extension AppPreferenceQueryProperty
    on QueryBuilder<AppPreference, AppPreference, QQueryProperty> {
  QueryBuilder<AppPreference, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AppPreference, bool, QQueryOperations> showPreviewProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'showPreview');
    });
  }
}
