// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'main.dart';

// **************************************************************************
// _IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, invalid_use_of_protected_member, lines_longer_than_80_chars, constant_identifier_names, avoid_js_rounded_ints, no_leading_underscores_for_local_identifiers, require_trailing_commas, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_in_if_null_operators, library_private_types_in_public_api, prefer_const_constructors
// ignore_for_file: type=lint

extension GetDocumentCollection on Isar {
  IsarCollection<int, Document> get documents => this.collection();
}

const DocumentSchema = IsarGeneratedSchema(
  schema: IsarSchema(
    name: 'Document',
    idName: 'id',
    embedded: false,
    properties: [
      IsarPropertySchema(
        name: 'name',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'createdAt',
        type: IsarType.dateTime,
      ),
    ],
    indexes: [],
  ),
  converter: IsarObjectConverter<int, Document>(
    serialize: serializeDocument,
    deserialize: deserializeDocument,
    deserializeProperty: deserializeDocumentProp,
  ),
  embeddedSchemas: [],
);

@isarProtected
int serializeDocument(IsarWriter writer, Document object) {
  {
    final value = object.name;
    if (value == null) {
      IsarCore.writeNull(writer, 1);
    } else {
      IsarCore.writeString(writer, 1, value);
    }
  }
  IsarCore.writeLong(writer, 2,
      object.createdAt?.toUtc().microsecondsSinceEpoch ?? -9223372036854775808);
  return object.id;
}

@isarProtected
Document deserializeDocument(IsarReader reader) {
  final object = Document();
  object.id = IsarCore.readId(reader);
  object.name = IsarCore.readString(reader, 1);
  {
    final value = IsarCore.readLong(reader, 2);
    if (value == -9223372036854775808) {
      object.createdAt = null;
    } else {
      object.createdAt =
          DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true).toLocal();
    }
  }
  return object;
}

@isarProtected
dynamic deserializeDocumentProp(IsarReader reader, int property) {
  switch (property) {
    case 0:
      return IsarCore.readId(reader);
    case 1:
      return IsarCore.readString(reader, 1);
    case 2:
      {
        final value = IsarCore.readLong(reader, 2);
        if (value == -9223372036854775808) {
          return null;
        } else {
          return DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true)
              .toLocal();
        }
      }
    default:
      throw ArgumentError('Unknown property: $property');
  }
}

sealed class _DocumentUpdate {
  bool call({
    required int id,
    String? name,
    DateTime? createdAt,
  });
}

class _DocumentUpdateImpl implements _DocumentUpdate {
  const _DocumentUpdateImpl(this.collection);

  final IsarCollection<int, Document> collection;

  @override
  bool call({
    required int id,
    Object? name = ignore,
    Object? createdAt = ignore,
  }) {
    return collection.updateProperties([
          id
        ], {
          if (name != ignore) 1: name as String?,
          if (createdAt != ignore) 2: createdAt as DateTime?,
        }) >
        0;
  }
}

sealed class _DocumentUpdateAll {
  int call({
    required List<int> id,
    String? name,
    DateTime? createdAt,
  });
}

class _DocumentUpdateAllImpl implements _DocumentUpdateAll {
  const _DocumentUpdateAllImpl(this.collection);

  final IsarCollection<int, Document> collection;

  @override
  int call({
    required List<int> id,
    Object? name = ignore,
    Object? createdAt = ignore,
  }) {
    return collection.updateProperties(id, {
      if (name != ignore) 1: name as String?,
      if (createdAt != ignore) 2: createdAt as DateTime?,
    });
  }
}

extension DocumentUpdate on IsarCollection<int, Document> {
  _DocumentUpdate get update => _DocumentUpdateImpl(this);

  _DocumentUpdateAll get updateAll => _DocumentUpdateAllImpl(this);
}

sealed class _DocumentQueryUpdate {
  int call({
    String? name,
    DateTime? createdAt,
  });
}

class _DocumentQueryUpdateImpl implements _DocumentQueryUpdate {
  const _DocumentQueryUpdateImpl(this.query, {this.limit});

  final IsarQuery<Document> query;
  final int? limit;

  @override
  int call({
    Object? name = ignore,
    Object? createdAt = ignore,
  }) {
    return query.updateProperties(limit: limit, {
      if (name != ignore) 1: name as String?,
      if (createdAt != ignore) 2: createdAt as DateTime?,
    });
  }
}

extension DocumentQueryUpdate on IsarQuery<Document> {
  _DocumentQueryUpdate get updateFirst =>
      _DocumentQueryUpdateImpl(this, limit: 1);

  _DocumentQueryUpdate get updateAll => _DocumentQueryUpdateImpl(this);
}

class _DocumentQueryBuilderUpdateImpl implements _DocumentQueryUpdate {
  const _DocumentQueryBuilderUpdateImpl(this.query, {this.limit});

  final QueryBuilder<Document, Document, QOperations> query;
  final int? limit;

  @override
  int call({
    Object? name = ignore,
    Object? createdAt = ignore,
  }) {
    final q = query.build();
    try {
      return q.updateProperties(limit: limit, {
        if (name != ignore) 1: name as String?,
        if (createdAt != ignore) 2: createdAt as DateTime?,
      });
    } finally {
      q.close();
    }
  }
}

extension DocumentQueryBuilderUpdate
    on QueryBuilder<Document, Document, QOperations> {
  _DocumentQueryUpdate get updateFirst =>
      _DocumentQueryBuilderUpdateImpl(this, limit: 1);

  _DocumentQueryUpdate get updateAll => _DocumentQueryBuilderUpdateImpl(this);
}

extension DocumentQueryFilter
    on QueryBuilder<Document, Document, QFilterCondition> {
  QueryBuilder<Document, Document, QAfterFilterCondition> idEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 0,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Document, Document, QAfterFilterCondition> idGreaterThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 0,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Document, Document, QAfterFilterCondition>
      idGreaterThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 0,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Document, Document, QAfterFilterCondition> idLessThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 0,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Document, Document, QAfterFilterCondition> idLessThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 0,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Document, Document, QAfterFilterCondition> idBetween(
    int lower,
    int upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 0,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }

  QueryBuilder<Document, Document, QAfterFilterCondition> nameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 1));
    });
  }

  QueryBuilder<Document, Document, QAfterFilterCondition> nameIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 1));
    });
  }

  QueryBuilder<Document, Document, QAfterFilterCondition> nameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Document, Document, QAfterFilterCondition> nameGreaterThan(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Document, Document, QAfterFilterCondition>
      nameGreaterThanOrEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Document, Document, QAfterFilterCondition> nameLessThan(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Document, Document, QAfterFilterCondition> nameLessThanOrEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Document, Document, QAfterFilterCondition> nameBetween(
    String? lower,
    String? upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 1,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Document, Document, QAfterFilterCondition> nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Document, Document, QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Document, Document, QAfterFilterCondition> nameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Document, Document, QAfterFilterCondition> nameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 1,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Document, Document, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 1,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<Document, Document, QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 1,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<Document, Document, QAfterFilterCondition> createdAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 2));
    });
  }

  QueryBuilder<Document, Document, QAfterFilterCondition> createdAtIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 2));
    });
  }

  QueryBuilder<Document, Document, QAfterFilterCondition> createdAtEqualTo(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 2,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Document, Document, QAfterFilterCondition> createdAtGreaterThan(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 2,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Document, Document, QAfterFilterCondition>
      createdAtGreaterThanOrEqualTo(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 2,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Document, Document, QAfterFilterCondition> createdAtLessThan(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 2,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Document, Document, QAfterFilterCondition>
      createdAtLessThanOrEqualTo(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 2,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Document, Document, QAfterFilterCondition> createdAtBetween(
    DateTime? lower,
    DateTime? upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 2,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }
}

extension DocumentQueryObject
    on QueryBuilder<Document, Document, QFilterCondition> {}

extension DocumentQuerySortBy on QueryBuilder<Document, Document, QSortBy> {
  QueryBuilder<Document, Document, QAfterSortBy> sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<Document, Document, QAfterSortBy> sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<Document, Document, QAfterSortBy> sortByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        1,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<Document, Document, QAfterSortBy> sortByNameDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        1,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<Document, Document, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2);
    });
  }

  QueryBuilder<Document, Document, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc);
    });
  }
}

extension DocumentQuerySortThenBy
    on QueryBuilder<Document, Document, QSortThenBy> {
  QueryBuilder<Document, Document, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<Document, Document, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<Document, Document, QAfterSortBy> thenByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Document, Document, QAfterSortBy> thenByNameDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Document, Document, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2);
    });
  }

  QueryBuilder<Document, Document, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc);
    });
  }
}

extension DocumentQueryWhereDistinct
    on QueryBuilder<Document, Document, QDistinct> {
  QueryBuilder<Document, Document, QAfterDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Document, Document, QAfterDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(2);
    });
  }
}

extension DocumentQueryProperty1
    on QueryBuilder<Document, Document, QProperty> {
  QueryBuilder<Document, int, QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<Document, String?, QAfterProperty> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<Document, DateTime?, QAfterProperty> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }
}

extension DocumentQueryProperty2<R>
    on QueryBuilder<Document, R, QAfterProperty> {
  QueryBuilder<Document, (R, int), QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<Document, (R, String?), QAfterProperty> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<Document, (R, DateTime?), QAfterProperty> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }
}

extension DocumentQueryProperty3<R1, R2>
    on QueryBuilder<Document, (R1, R2), QAfterProperty> {
  QueryBuilder<Document, (R1, R2, int), QOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<Document, (R1, R2, String?), QOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<Document, (R1, R2, DateTime?), QOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, invalid_use_of_protected_member, lines_longer_than_80_chars, constant_identifier_names, avoid_js_rounded_ints, no_leading_underscores_for_local_identifiers, require_trailing_commas, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_in_if_null_operators, library_private_types_in_public_api, prefer_const_constructors
// ignore_for_file: type=lint

extension GetDocumentDataCollection on Isar {
  IsarCollection<int, DocumentData> get documentDatas => this.collection();
}

const DocumentDataSchema = IsarGeneratedSchema(
  schema: IsarSchema(
    name: 'DocumentData',
    idName: 'id',
    embedded: false,
    properties: [
      IsarPropertySchema(
        name: 'data',
        type: IsarType.longList,
      ),
      IsarPropertySchema(
        name: 'documentId',
        type: IsarType.long,
      ),
    ],
    indexes: [],
  ),
  converter: IsarObjectConverter<int, DocumentData>(
    serialize: serializeDocumentData,
    deserialize: deserializeDocumentData,
    deserializeProperty: deserializeDocumentDataProp,
  ),
  embeddedSchemas: [],
);

@isarProtected
int serializeDocumentData(IsarWriter writer, DocumentData object) {
  {
    final list = object.data;
    if (list == null) {
      IsarCore.writeNull(writer, 1);
    } else {
      final listWriter = IsarCore.beginList(writer, 1, list.length);
      for (var i = 0; i < list.length; i++) {
        IsarCore.writeLong(listWriter, i, list[i]);
      }
      IsarCore.endList(writer, listWriter);
    }
  }
  IsarCore.writeLong(writer, 2, object.documentId ?? -9223372036854775808);
  return object.id;
}

@isarProtected
DocumentData deserializeDocumentData(IsarReader reader) {
  final object = DocumentData();
  object.id = IsarCore.readId(reader);
  {
    final length = IsarCore.readList(reader, 1, IsarCore.readerPtrPtr);
    {
      final reader = IsarCore.readerPtr;
      if (reader.isNull) {
        object.data = null;
      } else {
        final list =
            List<int>.filled(length, -9223372036854775808, growable: true);
        for (var i = 0; i < length; i++) {
          list[i] = IsarCore.readLong(reader, i);
        }
        IsarCore.freeReader(reader);
        object.data = list;
      }
    }
  }
  {
    final value = IsarCore.readLong(reader, 2);
    if (value == -9223372036854775808) {
      object.documentId = null;
    } else {
      object.documentId = value;
    }
  }
  return object;
}

@isarProtected
dynamic deserializeDocumentDataProp(IsarReader reader, int property) {
  switch (property) {
    case 0:
      return IsarCore.readId(reader);
    case 1:
      {
        final length = IsarCore.readList(reader, 1, IsarCore.readerPtrPtr);
        {
          final reader = IsarCore.readerPtr;
          if (reader.isNull) {
            return null;
          } else {
            final list =
                List<int>.filled(length, -9223372036854775808, growable: true);
            for (var i = 0; i < length; i++) {
              list[i] = IsarCore.readLong(reader, i);
            }
            IsarCore.freeReader(reader);
            return list;
          }
        }
      }
    case 2:
      {
        final value = IsarCore.readLong(reader, 2);
        if (value == -9223372036854775808) {
          return null;
        } else {
          return value;
        }
      }
    default:
      throw ArgumentError('Unknown property: $property');
  }
}

sealed class _DocumentDataUpdate {
  bool call({
    required int id,
    int? documentId,
  });
}

class _DocumentDataUpdateImpl implements _DocumentDataUpdate {
  const _DocumentDataUpdateImpl(this.collection);

  final IsarCollection<int, DocumentData> collection;

  @override
  bool call({
    required int id,
    Object? documentId = ignore,
  }) {
    return collection.updateProperties([
          id
        ], {
          if (documentId != ignore) 2: documentId as int?,
        }) >
        0;
  }
}

sealed class _DocumentDataUpdateAll {
  int call({
    required List<int> id,
    int? documentId,
  });
}

class _DocumentDataUpdateAllImpl implements _DocumentDataUpdateAll {
  const _DocumentDataUpdateAllImpl(this.collection);

  final IsarCollection<int, DocumentData> collection;

  @override
  int call({
    required List<int> id,
    Object? documentId = ignore,
  }) {
    return collection.updateProperties(id, {
      if (documentId != ignore) 2: documentId as int?,
    });
  }
}

extension DocumentDataUpdate on IsarCollection<int, DocumentData> {
  _DocumentDataUpdate get update => _DocumentDataUpdateImpl(this);

  _DocumentDataUpdateAll get updateAll => _DocumentDataUpdateAllImpl(this);
}

sealed class _DocumentDataQueryUpdate {
  int call({
    int? documentId,
  });
}

class _DocumentDataQueryUpdateImpl implements _DocumentDataQueryUpdate {
  const _DocumentDataQueryUpdateImpl(this.query, {this.limit});

  final IsarQuery<DocumentData> query;
  final int? limit;

  @override
  int call({
    Object? documentId = ignore,
  }) {
    return query.updateProperties(limit: limit, {
      if (documentId != ignore) 2: documentId as int?,
    });
  }
}

extension DocumentDataQueryUpdate on IsarQuery<DocumentData> {
  _DocumentDataQueryUpdate get updateFirst =>
      _DocumentDataQueryUpdateImpl(this, limit: 1);

  _DocumentDataQueryUpdate get updateAll => _DocumentDataQueryUpdateImpl(this);
}

class _DocumentDataQueryBuilderUpdateImpl implements _DocumentDataQueryUpdate {
  const _DocumentDataQueryBuilderUpdateImpl(this.query, {this.limit});

  final QueryBuilder<DocumentData, DocumentData, QOperations> query;
  final int? limit;

  @override
  int call({
    Object? documentId = ignore,
  }) {
    final q = query.build();
    try {
      return q.updateProperties(limit: limit, {
        if (documentId != ignore) 2: documentId as int?,
      });
    } finally {
      q.close();
    }
  }
}

extension DocumentDataQueryBuilderUpdate
    on QueryBuilder<DocumentData, DocumentData, QOperations> {
  _DocumentDataQueryUpdate get updateFirst =>
      _DocumentDataQueryBuilderUpdateImpl(this, limit: 1);

  _DocumentDataQueryUpdate get updateAll =>
      _DocumentDataQueryBuilderUpdateImpl(this);
}

extension DocumentDataQueryFilter
    on QueryBuilder<DocumentData, DocumentData, QFilterCondition> {
  QueryBuilder<DocumentData, DocumentData, QAfterFilterCondition> idEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 0,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DocumentData, DocumentData, QAfterFilterCondition> idGreaterThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 0,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DocumentData, DocumentData, QAfterFilterCondition>
      idGreaterThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 0,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DocumentData, DocumentData, QAfterFilterCondition> idLessThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 0,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DocumentData, DocumentData, QAfterFilterCondition>
      idLessThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 0,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DocumentData, DocumentData, QAfterFilterCondition> idBetween(
    int lower,
    int upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 0,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }

  QueryBuilder<DocumentData, DocumentData, QAfterFilterCondition> dataIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 1));
    });
  }

  QueryBuilder<DocumentData, DocumentData, QAfterFilterCondition>
      dataIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 1));
    });
  }

  QueryBuilder<DocumentData, DocumentData, QAfterFilterCondition>
      dataElementEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 1,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DocumentData, DocumentData, QAfterFilterCondition>
      dataElementGreaterThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 1,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DocumentData, DocumentData, QAfterFilterCondition>
      dataElementGreaterThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 1,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DocumentData, DocumentData, QAfterFilterCondition>
      dataElementLessThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 1,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DocumentData, DocumentData, QAfterFilterCondition>
      dataElementLessThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 1,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DocumentData, DocumentData, QAfterFilterCondition>
      dataElementBetween(
    int lower,
    int upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 1,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }

  QueryBuilder<DocumentData, DocumentData, QAfterFilterCondition>
      dataIsEmpty() {
    return not().group(
      (q) => q.dataIsNull().or().dataIsNotEmpty(),
    );
  }

  QueryBuilder<DocumentData, DocumentData, QAfterFilterCondition>
      dataIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterOrEqualCondition(property: 1, value: null),
      );
    });
  }

  QueryBuilder<DocumentData, DocumentData, QAfterFilterCondition>
      documentIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 2));
    });
  }

  QueryBuilder<DocumentData, DocumentData, QAfterFilterCondition>
      documentIdIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 2));
    });
  }

  QueryBuilder<DocumentData, DocumentData, QAfterFilterCondition>
      documentIdEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 2,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DocumentData, DocumentData, QAfterFilterCondition>
      documentIdGreaterThan(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 2,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DocumentData, DocumentData, QAfterFilterCondition>
      documentIdGreaterThanOrEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 2,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DocumentData, DocumentData, QAfterFilterCondition>
      documentIdLessThan(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 2,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DocumentData, DocumentData, QAfterFilterCondition>
      documentIdLessThanOrEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 2,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DocumentData, DocumentData, QAfterFilterCondition>
      documentIdBetween(
    int? lower,
    int? upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 2,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }
}

extension DocumentDataQueryObject
    on QueryBuilder<DocumentData, DocumentData, QFilterCondition> {}

extension DocumentDataQuerySortBy
    on QueryBuilder<DocumentData, DocumentData, QSortBy> {
  QueryBuilder<DocumentData, DocumentData, QAfterSortBy> sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<DocumentData, DocumentData, QAfterSortBy> sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<DocumentData, DocumentData, QAfterSortBy> sortByDocumentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2);
    });
  }

  QueryBuilder<DocumentData, DocumentData, QAfterSortBy>
      sortByDocumentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc);
    });
  }
}

extension DocumentDataQuerySortThenBy
    on QueryBuilder<DocumentData, DocumentData, QSortThenBy> {
  QueryBuilder<DocumentData, DocumentData, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<DocumentData, DocumentData, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<DocumentData, DocumentData, QAfterSortBy> thenByDocumentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2);
    });
  }

  QueryBuilder<DocumentData, DocumentData, QAfterSortBy>
      thenByDocumentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc);
    });
  }
}

extension DocumentDataQueryWhereDistinct
    on QueryBuilder<DocumentData, DocumentData, QDistinct> {
  QueryBuilder<DocumentData, DocumentData, QAfterDistinct> distinctByData() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(1);
    });
  }

  QueryBuilder<DocumentData, DocumentData, QAfterDistinct>
      distinctByDocumentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(2);
    });
  }
}

extension DocumentDataQueryProperty1
    on QueryBuilder<DocumentData, DocumentData, QProperty> {
  QueryBuilder<DocumentData, int, QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<DocumentData, List<int>?, QAfterProperty> dataProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<DocumentData, int?, QAfterProperty> documentIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }
}

extension DocumentDataQueryProperty2<R>
    on QueryBuilder<DocumentData, R, QAfterProperty> {
  QueryBuilder<DocumentData, (R, int), QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<DocumentData, (R, List<int>?), QAfterProperty> dataProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<DocumentData, (R, int?), QAfterProperty> documentIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }
}

extension DocumentDataQueryProperty3<R1, R2>
    on QueryBuilder<DocumentData, (R1, R2), QAfterProperty> {
  QueryBuilder<DocumentData, (R1, R2, int), QOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<DocumentData, (R1, R2, List<int>?), QOperations> dataProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<DocumentData, (R1, R2, int?), QOperations> documentIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }
}

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$isarHash() => r'779194c58de9c5d5886e91d68df2d130d21a3722';

/// See also [isar].
@ProviderFor(isar)
final isarProvider = Provider<Isar>.internal(
  isar,
  name: r'isarProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$isarHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsarRef = ProviderRef<Isar>;
String _$docDataHash() => r'f8b362345ab465d2be53884f94a25c82face6426';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [docData].
@ProviderFor(docData)
const docDataProvider = DocDataFamily();

/// See also [docData].
class DocDataFamily extends Family<List<DocumentData>> {
  /// See also [docData].
  const DocDataFamily();

  /// See also [docData].
  DocDataProvider call({
    required int docId,
  }) {
    return DocDataProvider(
      docId: docId,
    );
  }

  @override
  DocDataProvider getProviderOverride(
    covariant DocDataProvider provider,
  ) {
    return call(
      docId: provider.docId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'docDataProvider';
}

/// See also [docData].
class DocDataProvider extends AutoDisposeProvider<List<DocumentData>> {
  /// See also [docData].
  DocDataProvider({
    required int docId,
  }) : this._internal(
          (ref) => docData(
            ref as DocDataRef,
            docId: docId,
          ),
          from: docDataProvider,
          name: r'docDataProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$docDataHash,
          dependencies: DocDataFamily._dependencies,
          allTransitiveDependencies: DocDataFamily._allTransitiveDependencies,
          docId: docId,
        );

  DocDataProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.docId,
  }) : super.internal();

  final int docId;

  @override
  Override overrideWith(
    List<DocumentData> Function(DocDataRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DocDataProvider._internal(
        (ref) => create(ref as DocDataRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        docId: docId,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<List<DocumentData>> createElement() {
    return _DocDataProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DocDataProvider && other.docId == docId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, docId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DocDataRef on AutoDisposeProviderRef<List<DocumentData>> {
  /// The parameter `docId` of this provider.
  int get docId;
}

class _DocDataProviderElement
    extends AutoDisposeProviderElement<List<DocumentData>> with DocDataRef {
  _DocDataProviderElement(super.provider);

  @override
  int get docId => (origin as DocDataProvider).docId;
}

String _$docHash() => r'7b379bee9d5a47d3af9cd5aaedf5b07b46f69975';

/// See also [doc].
@ProviderFor(doc)
const docProvider = DocFamily();

/// See also [doc].
class DocFamily extends Family<Document> {
  /// See also [doc].
  const DocFamily();

  /// See also [doc].
  DocProvider call({
    required int docId,
  }) {
    return DocProvider(
      docId: docId,
    );
  }

  @override
  DocProvider getProviderOverride(
    covariant DocProvider provider,
  ) {
    return call(
      docId: provider.docId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'docProvider';
}

/// See also [doc].
class DocProvider extends AutoDisposeProvider<Document> {
  /// See also [doc].
  DocProvider({
    required int docId,
  }) : this._internal(
          (ref) => doc(
            ref as DocRef,
            docId: docId,
          ),
          from: docProvider,
          name: r'docProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product') ? null : _$docHash,
          dependencies: DocFamily._dependencies,
          allTransitiveDependencies: DocFamily._allTransitiveDependencies,
          docId: docId,
        );

  DocProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.docId,
  }) : super.internal();

  final int docId;

  @override
  Override overrideWith(
    Document Function(DocRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DocProvider._internal(
        (ref) => create(ref as DocRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        docId: docId,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<Document> createElement() {
    return _DocProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DocProvider && other.docId == docId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, docId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DocRef on AutoDisposeProviderRef<Document> {
  /// The parameter `docId` of this provider.
  int get docId;
}

class _DocProviderElement extends AutoDisposeProviderElement<Document>
    with DocRef {
  _DocProviderElement(super.provider);

  @override
  int get docId => (origin as DocProvider).docId;
}

String _$documentsHash() => r'05d88a15b37ae5e44c6ceb008031c48ffdc988a0';

/// See also [Documents].
@ProviderFor(Documents)
final documentsProvider = NotifierProvider<Documents, List<Document>>.internal(
  Documents.new,
  name: r'documentsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$documentsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Documents = Notifier<List<Document>>;
String _$editorStateWrapperHash() =>
    r'1e4dfcdac596cbac921dec4336e0ffdc2b1e4e07';

abstract class _$EditorStateWrapper
    extends BuildlessAsyncNotifier<EditorState> {
  late final String docId;

  FutureOr<EditorState> build(
    String docId,
  );
}

/// See also [EditorStateWrapper].
@ProviderFor(EditorStateWrapper)
const editorStateWrapperProvider = EditorStateWrapperFamily();

/// See also [EditorStateWrapper].
class EditorStateWrapperFamily extends Family<AsyncValue<EditorState>> {
  /// See also [EditorStateWrapper].
  const EditorStateWrapperFamily();

  /// See also [EditorStateWrapper].
  EditorStateWrapperProvider call(
    String docId,
  ) {
    return EditorStateWrapperProvider(
      docId,
    );
  }

  @override
  EditorStateWrapperProvider getProviderOverride(
    covariant EditorStateWrapperProvider provider,
  ) {
    return call(
      provider.docId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'editorStateWrapperProvider';
}

/// See also [EditorStateWrapper].
class EditorStateWrapperProvider
    extends AsyncNotifierProviderImpl<EditorStateWrapper, EditorState> {
  /// See also [EditorStateWrapper].
  EditorStateWrapperProvider(
    String docId,
  ) : this._internal(
          () => EditorStateWrapper()..docId = docId,
          from: editorStateWrapperProvider,
          name: r'editorStateWrapperProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$editorStateWrapperHash,
          dependencies: EditorStateWrapperFamily._dependencies,
          allTransitiveDependencies:
              EditorStateWrapperFamily._allTransitiveDependencies,
          docId: docId,
        );

  EditorStateWrapperProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.docId,
  }) : super.internal();

  final String docId;

  @override
  FutureOr<EditorState> runNotifierBuild(
    covariant EditorStateWrapper notifier,
  ) {
    return notifier.build(
      docId,
    );
  }

  @override
  Override overrideWith(EditorStateWrapper Function() create) {
    return ProviderOverride(
      origin: this,
      override: EditorStateWrapperProvider._internal(
        () => create()..docId = docId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        docId: docId,
      ),
    );
  }

  @override
  AsyncNotifierProviderElement<EditorStateWrapper, EditorState>
      createElement() {
    return _EditorStateWrapperProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is EditorStateWrapperProvider && other.docId == docId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, docId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin EditorStateWrapperRef on AsyncNotifierProviderRef<EditorState> {
  /// The parameter `docId` of this provider.
  String get docId;
}

class _EditorStateWrapperProviderElement
    extends AsyncNotifierProviderElement<EditorStateWrapper, EditorState>
    with EditorStateWrapperRef {
  _EditorStateWrapperProviderElement(super.provider);

  @override
  String get docId => (origin as EditorStateWrapperProvider).docId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
