/*
 * Copyright 2021 styledart.dev - Mehmet Yaz
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

part of '../../../style_base.dart';

///
typedef DbOperation<T extends DbResult> = FutureOr<T> Function(Access access);

///
abstract class DataAccess<L extends AccessLanguage> extends _BaseService {
  ///
  factory DataAccess(
    DataAccessImplementation implementation, {
    List<DbCollection>? collections,
    Map<DbOperationType, bool>? defaultPermissionsByType,
    bool defaultPermission = true,
    bool streamSupport = false,
  }) {
    /// set permission handler if
    /// or
    /// -- any collection have custom permission
    /// -- defaultPermissionsByType is not null
    /// -- defaultPermission is false
    var hasPermission = (collections
                ?.where((element) =>
                    element.permissionHandler != null || element.hasSchema)
                .isNotEmpty ??
            false) ||
        defaultPermissionsByType != null ||
        !defaultPermission;

    var hasTrigger = collections
            ?.where((element) =>
                element.triggers != null && element.triggers!.isNotEmpty)
            .isNotEmpty ??
        false;
    Map<String, String>? _identifierMapping;
    TriggerService? _triggerService;
    PermissionHandlerService? _permissionHandler;

    if (collections != null) {
      var hasIdentifier =
          collections.where((element) => element.identifier != null).isNotEmpty;

      if (hasIdentifier) {
        _identifierMapping = {};
        for (var db in collections) {
          if (db.identifier != null) {
            _identifierMapping[db.collectionName] = db.identifier!;
          }
        }
      }
    }

    if (hasPermission) {
      _permissionHandler = PermissionHandlerService.create(
          defaultPermission: defaultPermission,
          collections: collections,
          defaultRules: defaultPermissionsByType);
    }

    if (hasTrigger || streamSupport) {
      _triggerService = TriggerService.create(
          streamSupport: streamSupport, collections: collections);
    }

    DataAccess<L> _acc;

    if (collections?.isEmpty ?? true) {
      _acc = _DataAccessEmpty<L>(implementation, _identifierMapping);
    } else if (_triggerService != null && _permissionHandler == null) {
      _acc = _DataAccessWithOnlyTrigger<L>(
          implementation, _triggerService, _identifierMapping);
    } else if (_triggerService == null && _permissionHandler != null) {
      _acc = _DataAccessWithPermission<L>(
          implementation, _permissionHandler, _identifierMapping);
    } else {
      _acc = _DataAccessWithTriggerAndPermission<L>(implementation,
          _triggerService!, _permissionHandler!, _identifierMapping);
    }
    return _acc;
  }

  ///
  final Map<String, String>? identifierMapping;

  ///
  DataAccess._(this.implementation,
      {this.permissionHandler, this.triggerService, this.identifierMapping})
      : _read = implementation.read,
        _readList = implementation.readList,
        _delete = implementation.delete,
        _update = implementation.update,
        _create = implementation.create,
        _exists = implementation.exists,
        _count = implementation.count,
        _initDb = implementation.init,
        _aggregation = implementation.aggregation {
    implementation.dataAccess = this;
    permissionHandler?.dataAccess = this;
    triggerService?.dataAccess = this;
  }

  ///
  static DataAccess of(BuildContext context) {
    return context.dataAccess;
  }

  ///
  AccessEvent<L> buildAccess(AccessEvent<L> builder) {
    throw UnimplementedError();
  }

  ///
  DataAccessImplementation implementation;

  ///
  PermissionHandlerService? permissionHandler;

  ///
  TriggerService? triggerService;

  BuildContext get context => super.context;

  FutureOr<T> _operation<T extends DbResult>(
      AccessEvent<L> event, FutureOr<T> Function(Access access) interoperation);

  ///
  FutureOr<DbResult> any(AccessEvent<L> access) {
    switch (access.access.type) {
      case AccessType.read:
        return _operation(access, _read);
      case AccessType.readMultiple:
        return _operation(access, _readList);
      case AccessType.create:
        return _operation(access, _create);
      case AccessType.update:
        return _operation(access, _update);
      case AccessType.exists:
        return _operation(access, _exists);
      case AccessType.listen:
        throw UnimplementedError();
      case AccessType.delete:
        return _operation(access, _delete);
      case AccessType.count:
        return _operation(access, _count);
      case AccessType.aggregation:
        return _operation(access, _aggregation);
    }
  }

  ///
  FutureOr<ReadDbResult> read(AccessEvent<L> access) {
    return _operation<ReadDbResult>(access, _read);
  }

  ///
  FutureOr<ReadListResult> readList(AccessEvent<L> access) {
    return _operation<ReadListResult>(access, _readList);
  }

  ///
  FutureOr<ReadListResult> aggregation(AccessEvent<L> access) {
    return _operation<ReadListResult>(access, _aggregation);
  }

  ///
  FutureOr<DbResult<bool>> exists(AccessEvent<L> access) {
    return _operation<DbResult<bool>>(access, _exists);
  }

  ///
  FutureOr<DeleteDbResult> delete(AccessEvent<L> access) {
    return _operation<DeleteDbResult>(access, _delete);
  }

  ///
  FutureOr<UpdateDbResult> update(AccessEvent<L> access) {
    return _operation<UpdateDbResult>(access, _update);
  }

  ///
  FutureOr<CreateDbResult> create(AccessEvent<L> access) {
    return _operation<CreateDbResult>(access, _create);
  }

  ///
  FutureOr<DbResult<int>> count(AccessEvent<L> access) {
    return _operation<DbResult<int>>(access, _count);
  }

  // ///
  // FutureOr<ListenResult<Map<String, dynamic>>> listen(Query query) {
  //   throw UnimplementedError("implement override"
  //       " DataAccess.listen for use listen");
  // }

  ///
  final DbOperation<ReadDbResult> _read;

  ///
  final DbOperation<ReadListResult> _readList;

  ///
  final DbOperation<ReadListResult> _aggregation;

  ///
  final DbOperation<DeleteDbResult> _delete;

  ///
  final DbOperation<UpdateDbResult> _update;

  ///
  final DbOperation<CreateDbResult> _create;

  final FutureOr<DbResult<bool>> Function(Access access) _exists;

  ///
  final FutureOr<DbResult<int>> Function(Access access) _count;

  final FutureOr<bool> Function() _initDb;

  @override
  FutureOr<bool> init([bool inInterface = true]) {
    return _initDb();
  }

  ///
  Map<String, dynamic> toMap() => {
        "implementation": implementation.runtimeType,
        "data_access": runtimeType,
        "wrapper": (context as Binding).key.key
      };
}

class _DataAccessWithTriggerAndPermission<L extends AccessLanguage>
    extends DataAccess<L> {
  _DataAccessWithTriggerAndPermission(
      DataAccessImplementation implementation,
      TriggerService triggerService,
      PermissionHandlerService permissionHandler,
      Map<String, String>? identifierMapping)
      : super._(implementation,
            triggerService: triggerService,
            permissionHandler: permissionHandler,
            identifierMapping: identifierMapping);

  @override
  FutureOr<T> _operation<T extends DbResult>(AccessEvent<L> builder,
      FutureOr<T> Function(Access<L> acc) interoperation) async {
    var e = buildAccess(builder);
    if (await permissionHandler!.check(e)) {
      return triggerService!.triggerAndReturn(e, interoperation);
    } else {
      throw ForbiddenUnauthorizedException();
    }
  }
}

class _DataAccessWithOnlyTrigger<L extends AccessLanguage>
    extends DataAccess<L> {
  _DataAccessWithOnlyTrigger(DataAccessImplementation implementation,
      TriggerService triggerService, Map<String, String>? identifierMapping)
      : super._(implementation,
            triggerService: triggerService,
            identifierMapping: identifierMapping);

  @override
  FutureOr<T> _operation<T extends DbResult>(AccessEvent<L> builder,
      FutureOr<T> Function(Access<L> access) interoperation) {
    try {
      return triggerService!
          .triggerAndReturn(buildAccess(builder), interoperation);
    } on Exception {
      rethrow;
    }
  }
}

class _DataAccessEmpty<L extends AccessLanguage> extends DataAccess<L> {
  _DataAccessEmpty(DataAccessImplementation implementation,
      Map<String, String>? identifierMapping)
      : super._(implementation, identifierMapping: identifierMapping);

  @override
  FutureOr<T> _operation<T extends DbResult>(AccessEvent<L> access,
      FutureOr<T> Function(Access<L> acc) interoperation) {
    return interoperation(buildAccess(access).access);
  }
}

class _DataAccessWithPermission<L extends AccessLanguage>
    extends DataAccess<L> {
  _DataAccessWithPermission(
      DataAccessImplementation implementation,
      PermissionHandlerService permissionHandler,
      Map<String, String>? identifierMapping)
      : super._(implementation,
            permissionHandler: permissionHandler,
            identifierMapping: identifierMapping);

  @override
  FutureOr<T> _operation<T extends DbResult>(AccessEvent<L> builder,
      FutureOr<T> Function(Access<L> access) interoperation) async {
    try {
      var e = buildAccess(builder);
      if (await permissionHandler!.check(e)) {
        return interoperation(e.access);
      } else {
        throw ForbiddenUnauthorizedException()..payload = e.toMap(false);
      }
    } on Exception {
      rethrow;
    }
  }
}

///
abstract class DataAccessImplementation<L extends AccessLanguage> {
  ///
  FutureOr<bool> init();

  ///
  FutureOr<DbResult> any(AccessEvent<L> event) {
    switch (event.access.type) {
      case AccessType.read:
        return read(event.access);
      case AccessType.readMultiple:
        return readList(event.access);
      case AccessType.create:
        return create(event.access);
      case AccessType.update:
        return update(event.access);
      case AccessType.exists:
        return exists(event.access);
      case AccessType.listen:
        throw UnimplementedError();
      case AccessType.aggregation:
        return aggregation(event.access);
      case AccessType.delete:
        return delete(event.access);
      case AccessType.count:
        return count(event.access);
    }
  }

  ///
  FutureOr<ReadDbResult> read(Access<L> access);

  ///
  FutureOr<ReadListResult> readList(Access<L> access);

  ///
  FutureOr<ReadListResult> aggregation(Access<L> access);

  ///
  FutureOr<DeleteDbResult> delete(Access<L> access);

  ///
  FutureOr<UpdateDbResult> update(Access<L> access);

  ///
  FutureOr<CreateDbResult> create(Access<L> access);

  ///
  FutureOr<DbResult<bool>> exists(Access<L> access);

  ///
  FutureOr<DbResult<int>> count(Access<L> access);

  // ///
  // FutureOr<ListenResult<Map<String, dynamic>>> listen(
  //     Query query, Map<String, dynamic> document) {
  //   throw UnimplementedError("implement override"
  //       " DataAccess.listen for use listen");
  // }

  ///
  BuildContext get context => dataAccess.context;

  ///
  late final DataAccess<L> dataAccess;
}

///
typedef BoolDbResult = DbResult<bool>;

///
typedef CountDbResult = DbResult<int>;

///
typedef ReadDbResult = DbResult<Map<String, dynamic>>;

///
typedef ArrayDbResult<T> = DbResult<List<T>?>;

///
typedef ReadListResult = ArrayDbResult<Map<String, dynamic>>;

///
typedef AggregationResult = ArrayDbResult<Map<String, dynamic>>;

/// Database Operation Result
class DbResult<T> {
  ///
  DbResult({required this.data, this.statusCode, this.headers});

  ///
  T data;

  ///
  int? statusCode;

  ///
  Map<String, dynamic>? headers;
}

///
class UpdateDbResult extends DbResult<Map<String, dynamic>?> {
  ///
  UpdateDbResult({Map<String, dynamic>? data, this.newData})
      : super(data: data);

  ///
  Map<String, dynamic>? newData;
}

///
class CreateDbResult extends DbResult<Map<String, dynamic>?> {
  ///
  CreateDbResult({required this.identifier})
      : super(
            data: null,
            statusCode: 201,
            headers: {HttpHeaders.locationHeader: identifier});

  ///
  dynamic identifier;
}

///
class DeleteDbResult extends DbResult<Map<String, dynamic>?> {
  ///
  DeleteDbResult({required bool exists})
      : super(data: null, statusCode: exists ? 200 : 404);
}

///
class SimpleCacheDataAccess extends DataAccessImplementation<CommonLanguage> {
  ///
  SimpleCacheDataAccess({RandomGenerator? idGenerator});

  //: //_idGenerator = idGenerator ?? RandomGenerator("[*#]/l(30)");

  ///
  final Map<String, Map<String, Map<String, dynamic>>> data = {};

  @override
  Future<bool> init([bool inInterface = true]) async {
    return true;
  }

  //final RandomGenerator _idGenerator;

  @override
  FutureOr<CreateDbResult> create(Access<CommonLanguage> access) {
    throw UnimplementedError();
    // if (access.create == null) {
    //   throw BadRequests();
    // }
    // String id;
    //
    // var data = access.create!.toMap();
    //
    // var idKey = dataAccess.identifierMapping?[access.collection];
    // idKey ??= data["id"] != null ? "id" : "_id";
    //
    // id = access.identifier ?? data[idKey] ?? _idGenerator.generateString();
    // data[idKey] ??= id;
    // data[access.collection] ??= {};
    // data[access.collection]![id] = data;
    // return CreateDbResult(identifier: id);
  }

  @override
  FutureOr<DeleteDbResult> delete(Access<CommonLanguage> access) {
    throw UnimplementedError();
    // if (access.identifier == null) {
    //   throw BadRequests();
    // }
    // if (data[access.collection]?[access.identifier!] == null) {
    //   return DeleteDbResult(exists: false);
    // } else {
    //   data[access.collection]!.remove(access.identifier);
    //   return DeleteDbResult(exists: true);
    // }
  }

  @override
  Future<ReadDbResult> read(Access<CommonLanguage> access) async {
    throw UnimplementedError();
    // if (access.identifier == null) {
    //   throw BadRequests();
    // }
    // var d = data[access.collection]?[access.identifier];
    //
    // if (d == null) throw NotFoundException();
    // return ReadDbResult(data: Map<String, dynamic>.from(d));
  }

  @override
  FutureOr<ReadListResult> readList(covariant CommonAccess access) {
    var q = access.query as CommonQuery?;

    if (q?.selector != null) {
      Logger.of(context).warn(context, "query_not_supported",
          title: "Query selector "
              "not supported with SimpleCacheDataAccess , so its skipped");
    }

    if (q?.sort != null) {
      Logger.of(context).warn(context, "sort_not_supported",
          title: "Query sort "
              "not supported with SimpleCacheDataAccess , so its skipped");
    }
    if (access.query?.fields != null) {
      Logger.of(context).warn(context, "fields_not_supported",
          title: "Query fields "
              "not supported with SimpleCacheDataAccess , so its skipped");
    }
    var l = q?.limit ?? 200;
    var s = q?.offset ?? 0;

    var len = data[access.collection]?.length ?? 0;

    var nLen = len - s;

    if (nLen <= 0) {
      return ReadListResult(data: []);
    }

    if (l >= nLen) {
      l = nLen;
    }

    return ReadListResult(
        data: _copy(
            data[access.collection]?.values.toList().sublist(s).sublist(0, l)));
  }

  List<T>? _copy<T>(List<T>? l) {
    if (l == null) return null;
    return List<T>.from(l);
  }

  @override
  FutureOr<UpdateDbResult> update(Access<CommonLanguage> access) {
    throw UnimplementedError();
    // if (access.update == null) {
    //   throw BadRequests();
    // }
    // if (access.identifier == null) {
    //   throw BadRequests();
    // }
    // data[access.collection]?[access.identifier]
    // ?.addAll(access.update!.toMap());
    // return UpdateDbResult(data: null);
  }

  @override
  FutureOr<DbResult<int>> count(Access<CommonLanguage> access) {
    if (access.query != null) {
      Logger.of(context).warn(context, "query_not_supported",
          title: "Query "
              "not supported with SimpleCacheDataAccess , so its skipped");
    }
    return DbResult<int>(data: data[access.collection]?.length ?? 0);
  }

  @override
  FutureOr<DbResult<bool>> exists(Access<CommonLanguage> access) {
    throw UnimplementedError();
    // // TODO: implement exists
    // if (access.query != null) {
    //   Logger.of(context).warn(context, "query_not_supported",
    //       title: "Query "
    //           "not supported with SimpleCacheDataAccess , so its skipped");
    // }
    //
    // if (access.identifier == null) {
    //   throw BadRequests();
    // }
    //
    // return DbResult<bool>(
    //     data: data[access.collection]?[access.identifier!] != null);
  }

  @override
  FutureOr<ReadListResult> aggregation(Access<CommonLanguage> access) {
    throw UnimplementedError(
        "Aggregation not supported with Simple(Cache)DataAccess");
  }
}

///
// class StoreDelegate<T extends Identifier> {
//   ///
//   StoreDelegate(
//       {required this.collection,
//       DataAccess? customAccess,
//       required this.toMap,
//       required this.fromMap})
//       : _access = customAccess;
//
//   ///
//   DataAccess get access => _access!;
//
//   ///
//   void attach(BuildContext context) {
//     _access ??= DataAccess.of(context);
//   }
//
//   ///
//   Future<T> read(String id) async {
//     return fromMap(
//         (await access.read(Read(collection:
//         collection, identifier: id))).data);
//   }
//
//   ///
//   Future<void> write(T instance) async {
//     await access.create(Create(collection:
//     collection, data: toMap(instance)));
//   }
//
//   ///
//   Future<void> delete(String identifier) async {
//     await access.delete(Delete(collection:
//     collection, identifier: identifier));
//   }
//
//   DataAccess? _access;
//
//   ///
//   String collection;
//
//   ///
//   Map<String, dynamic> Function(T instance) toMap;
//
//   ///
//   T Function(Map<String, dynamic> map) fromMap;
// }

///
class SimpleDataAccess extends SimpleCacheDataAccess {
  ///
  SimpleDataAccess(this.directory)
      : assert(directory.endsWith(Platform.pathSeparator) ||
            directory.endsWith("/"));

  ///
  String directory;

  Future<bool> init([bool inInterface = true]) async {
    var docs = await Directory(directory)
        .list()
        .where((event) => event.path.endsWith(".json"))
        .toList();

    var colsFtrs =
        docs.map((e) async => json.decode(await File(e.path).readAsString()));
    var cols = await Future.wait(colsFtrs);
    var i = 0;
    while (i < cols.length) {
      data[docs[i].path.split("/").last.replaceAll(".json", "")] =
          (cols[i] as Map).cast<String, Map<String, dynamic>>();
      i++;
    }
    return true;
  }

  ///
  Future<void> saveCollection(String collection) async {
    var f = File("$directory$collection.json");
    if (!(await f.exists())) {
      await f.create();
    }
    f.writeAsString(json.encode(data[collection]));
  }

  @override
  FutureOr<CreateDbResult> create(Access<CommonLanguage> access) async {
    var res = await super.create(access);

    saveCollection(access.collection);

    return res;
  }

  @override
  FutureOr<UpdateDbResult> update(Access<CommonLanguage> access) async {
    var res = await super.update(access);

    saveCollection(access.collection);

    return res;
  }

  @override
  FutureOr<DeleteDbResult> delete(Access<CommonLanguage> access) async {
    var res = await super.delete(access);

    saveCollection(access.collection);

    return res;
  }
}
