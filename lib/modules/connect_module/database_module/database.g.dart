// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class Categories extends Table with TableInfo<Categories, Category> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Categories(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: 'NOT NULL PRIMARY KEY AUTOINCREMENT');
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  @override
  List<GeneratedColumn> get $columns => [id, description];
  @override
  String get aliasedName => _alias ?? 'categories';
  @override
  String get actualTableName => 'categories';
  @override
  VerificationContext validateIntegrity(Insertable<Category> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Category map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Category(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
    );
  }

  @override
  Categories createAlias(String alias) {
    return Categories(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class Category extends DataClass implements Insertable<Category> {
  final int id;
  final String? description;
  const Category({required this.id, this.description});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
    );
  }

  factory Category.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Category(
      id: serializer.fromJson<int>(json['id']),
      description: serializer.fromJson<String?>(json['description']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'description': serializer.toJson<String?>(description),
    };
  }

  Category copyWith(
          {int? id, Value<String?> description = const Value.absent()}) =>
      Category(
        id: id ?? this.id,
        description: description.present ? description.value : this.description,
      );
  @override
  String toString() {
    return (StringBuffer('Category(')
          ..write('id: $id, ')
          ..write('description: $description')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, description);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Category &&
          other.id == this.id &&
          other.description == this.description);
}

class CategoriesCompanion extends UpdateCompanion<Category> {
  final Value<int> id;
  final Value<String?> description;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.description = const Value.absent(),
  });
  CategoriesCompanion.insert({
    this.id = const Value.absent(),
    this.description = const Value.absent(),
  });
  static Insertable<Category> custom({
    Expression<int>? id,
    Expression<String>? description,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (description != null) 'description': description,
    });
  }

  CategoriesCompanion copyWith({Value<int>? id, Value<String?>? description}) {
    return CategoriesCompanion(
      id: id ?? this.id,
      description: description ?? this.description,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('description: $description')
          ..write(')'))
        .toString();
  }
}

class Todos extends Table with TableInfo<Todos, Todo> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Todos(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: 'NOT NULL PRIMARY KEY AUTOINCREMENT');
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
      'body', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  late final GeneratedColumn<int> category = GeneratedColumn<int>(
      'category', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: 'REFERENCES categories(id)');
  @override
  List<GeneratedColumn> get $columns => [id, title, body, category];
  @override
  String get aliasedName => _alias ?? 'todos';
  @override
  String get actualTableName => 'todos';
  @override
  VerificationContext validateIntegrity(Insertable<Todo> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    }
    if (data.containsKey('body')) {
      context.handle(
          _bodyMeta, body.isAcceptableOrUnknown(data['body']!, _bodyMeta));
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Todo map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Todo(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title']),
      body: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}body']),
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}category']),
    );
  }

  @override
  Todos createAlias(String alias) {
    return Todos(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class Todo extends DataClass implements Insertable<Todo> {
  final int id;
  final String? title;
  final String? body;
  final int? category;
  const Todo({required this.id, this.title, this.body, this.category});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || body != null) {
      map['body'] = Variable<String>(body);
    }
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<int>(category);
    }
    return map;
  }

  TodosCompanion toCompanion(bool nullToAbsent) {
    return TodosCompanion(
      id: Value(id),
      title:
          title == null && nullToAbsent ? const Value.absent() : Value(title),
      body: body == null && nullToAbsent ? const Value.absent() : Value(body),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
    );
  }

  factory Todo.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Todo(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String?>(json['title']),
      body: serializer.fromJson<String?>(json['body']),
      category: serializer.fromJson<int?>(json['category']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String?>(title),
      'body': serializer.toJson<String?>(body),
      'category': serializer.toJson<int?>(category),
    };
  }

  Todo copyWith(
          {int? id,
          Value<String?> title = const Value.absent(),
          Value<String?> body = const Value.absent(),
          Value<int?> category = const Value.absent()}) =>
      Todo(
        id: id ?? this.id,
        title: title.present ? title.value : this.title,
        body: body.present ? body.value : this.body,
        category: category.present ? category.value : this.category,
      );
  @override
  String toString() {
    return (StringBuffer('Todo(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('category: $category')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, body, category);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Todo &&
          other.id == this.id &&
          other.title == this.title &&
          other.body == this.body &&
          other.category == this.category);
}

class TodosCompanion extends UpdateCompanion<Todo> {
  final Value<int> id;
  final Value<String?> title;
  final Value<String?> body;
  final Value<int?> category;
  const TodosCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.body = const Value.absent(),
    this.category = const Value.absent(),
  });
  TodosCompanion.insert({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.body = const Value.absent(),
    this.category = const Value.absent(),
  });
  static Insertable<Todo> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? body,
    Expression<int>? category,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (body != null) 'body': body,
      if (category != null) 'category': category,
    });
  }

  TodosCompanion copyWith(
      {Value<int>? id,
      Value<String?>? title,
      Value<String?>? body,
      Value<int?>? category}) {
    return TodosCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      category: category ?? this.category,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (category.present) {
      map['category'] = Variable<int>(category.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TodosCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('category: $category')
          ..write(')'))
        .toString();
  }
}

class $PathTable extends Path with TableInfo<$PathTable, PathData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PathTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, true,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name =
      GeneratedColumn<String>('name', aliasedName, false,
          additionalChecks: GeneratedColumn.checkTextLength(
            minTextLength: 1,
          ),
          type: DriftSqlType.string,
          requiredDuringInsert: true,
          defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _pidMeta = const VerificationMeta('pid');
  @override
  late final GeneratedColumn<int> pid = GeneratedColumn<int>(
      'pid', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lastSyncUidMeta =
      const VerificationMeta('lastSyncUid');
  @override
  late final GeneratedColumn<int> lastSyncUid = GeneratedColumn<int>(
      'last_sync_uid', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [id, name, pid, lastSyncUid];
  @override
  String get aliasedName => _alias ?? 'path';
  @override
  String get actualTableName => 'path';
  @override
  VerificationContext validateIntegrity(Insertable<PathData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('pid')) {
      context.handle(
          _pidMeta, pid.isAcceptableOrUnknown(data['pid']!, _pidMeta));
    }
    if (data.containsKey('last_sync_uid')) {
      context.handle(
          _lastSyncUidMeta,
          lastSyncUid.isAcceptableOrUnknown(
              data['last_sync_uid']!, _lastSyncUidMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PathData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PathData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id']),
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      pid: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}pid']),
      lastSyncUid: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}last_sync_uid']),
    );
  }

  @override
  $PathTable createAlias(String alias) {
    return $PathTable(attachedDatabase, alias);
  }
}

class PathData extends DataClass implements Insertable<PathData> {
  final int? id;
  final String name;
  final int? pid;
  final int? lastSyncUid;
  const PathData({this.id, required this.name, this.pid, this.lastSyncUid});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || id != null) {
      map['id'] = Variable<int>(id);
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || pid != null) {
      map['pid'] = Variable<int>(pid);
    }
    if (!nullToAbsent || lastSyncUid != null) {
      map['last_sync_uid'] = Variable<int>(lastSyncUid);
    }
    return map;
  }

  PathCompanion toCompanion(bool nullToAbsent) {
    return PathCompanion(
      id: id == null && nullToAbsent ? const Value.absent() : Value(id),
      name: Value(name),
      pid: pid == null && nullToAbsent ? const Value.absent() : Value(pid),
      lastSyncUid: lastSyncUid == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncUid),
    );
  }

  factory PathData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PathData(
      id: serializer.fromJson<int?>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      pid: serializer.fromJson<int?>(json['pid']),
      lastSyncUid: serializer.fromJson<int?>(json['lastSyncUid']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int?>(id),
      'name': serializer.toJson<String>(name),
      'pid': serializer.toJson<int?>(pid),
      'lastSyncUid': serializer.toJson<int?>(lastSyncUid),
    };
  }

  PathData copyWith(
          {Value<int?> id = const Value.absent(),
          String? name,
          Value<int?> pid = const Value.absent(),
          Value<int?> lastSyncUid = const Value.absent()}) =>
      PathData(
        id: id.present ? id.value : this.id,
        name: name ?? this.name,
        pid: pid.present ? pid.value : this.pid,
        lastSyncUid: lastSyncUid.present ? lastSyncUid.value : this.lastSyncUid,
      );
  @override
  String toString() {
    return (StringBuffer('PathData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('pid: $pid, ')
          ..write('lastSyncUid: $lastSyncUid')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, pid, lastSyncUid);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PathData &&
          other.id == this.id &&
          other.name == this.name &&
          other.pid == this.pid &&
          other.lastSyncUid == this.lastSyncUid);
}

class PathCompanion extends UpdateCompanion<PathData> {
  final Value<int?> id;
  final Value<String> name;
  final Value<int?> pid;
  final Value<int?> lastSyncUid;
  const PathCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.pid = const Value.absent(),
    this.lastSyncUid = const Value.absent(),
  });
  PathCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.pid = const Value.absent(),
    this.lastSyncUid = const Value.absent(),
  }) : name = Value(name);
  static Insertable<PathData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? pid,
    Expression<int>? lastSyncUid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (pid != null) 'pid': pid,
      if (lastSyncUid != null) 'last_sync_uid': lastSyncUid,
    });
  }

  PathCompanion copyWith(
      {Value<int?>? id,
      Value<String>? name,
      Value<int?>? pid,
      Value<int?>? lastSyncUid}) {
    return PathCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      pid: pid ?? this.pid,
      lastSyncUid: lastSyncUid ?? this.lastSyncUid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (pid.present) {
      map['pid'] = Variable<int>(pid.value);
    }
    if (lastSyncUid.present) {
      map['last_sync_uid'] = Variable<int>(lastSyncUid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PathCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('pid: $pid, ')
          ..write('lastSyncUid: $lastSyncUid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDb extends GeneratedDatabase {
  _$AppDb(QueryExecutor e) : super(e);
  late final Categories categories = Categories(this);
  late final Todos todos = Todos(this);
  late final $PathTable path = $PathTable(this);
  Selectable<Todo> todosInCategory(int? var1) {
    return customSelect('SELECT * FROM todos WHERE category = ?1', variables: [
      Variable<int>(var1)
    ], readsFrom: {
      todos,
    }).asyncMap(todos.mapFromRow);
  }

  Selectable<CountEntriesResult> countEntries() {
    return customSelect(
        'SELECT c.description, (SELECT COUNT(*) FROM todos WHERE category = c.id) AS amount FROM categories AS c UNION ALL SELECT NULL, (SELECT COUNT(*) FROM todos WHERE category IS NULL)',
        variables: [],
        readsFrom: {
          categories,
          todos,
        }).map((QueryRow row) {
      return CountEntriesResult(
        description: row.readNullable<String>('description'),
        amount: row.read<int>('amount'),
      );
    });
  }

  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [categories, todos, path];
}

class CountEntriesResult {
  final String? description;
  final int amount;
  CountEntriesResult({
    this.description,
    required this.amount,
  });
}
