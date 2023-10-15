/*
 * Copyright 2021 styledart.dev - Mehmet Yaz
 *
 * Licensed under the GNU AFFERO GENERAL PUBLIC LICENSE,
 *    Version 3 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *       https://www.gnu.org/licenses/agpl-3.0.en.html
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

part of style_dart;


///
typedef JsonMap = Map<String, dynamic>;

///
enum AccessType {
  ///
  read,

  ///
  readMultiple,

  ///
  create,

  ///
  update,

  ///
  exists,

  ///
  listen,

  ///
  delete,

  ///
  count,

  ///
  //aggregation
}

/// A request to access the database / a collection in the database.
/// Any CRUD operations, aggregations,
/// or other operations are defined as [Access].
///
class Access {
  ///
  const Access(
      {this.query,
        required this.type,
        this.create,
        this.update,
        required this.collection,
        this.pipeline,
        this.settings});

  ///
  final JsonMap? query;

  ///
  final JsonMap? pipeline;

  ///
  final JsonMap? settings;

  ///
  final AccessType type;

  ///
  final String collection;

  ///
  final JsonMap? create;

  ///
  final JsonMap? update;

  ///
  JsonMap toMap() => {
    'collection': collection,
    'type': type.index,
    if (create != null) 'create': create,
    if (update != null) 'update': update,
    if (pipeline != null) 'pipeline': pipeline!,
    if (query != null) 'query': query,
  };
}


///
typedef DbOperation<T extends DbResult> = FutureOr<T> Function(Access access);

///
abstract class DataAccess extends ModuleDelegate {
  ///
  factory DataAccess(
    DataAccessImplementation implementation, {
    List<DbCollection>? collections,
    Map<DbOperationType, bool>? defaultPermissionsByType,
    bool defaultPermission = true,
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
    Map<String, String>? identifierMapping;
    TriggerService? triggerService;
    PermissionHandlerService? permissionHandler;

    if (collections != null) {
      var hasIdentifier =
          collections.where((element) => element.identifier != null).isNotEmpty;

      if (hasIdentifier) {
        identifierMapping = {};
        for (var db in collections) {
          if (db.identifier != null) {
            identifierMapping[db.collectionName] = db.identifier!;
          }
        }
      }
    }

    if (hasPermission) {
      permissionHandler = PermissionHandlerService.create(
          defaultPermission: defaultPermission,
          collections: collections,
          defaultRules: defaultPermissionsByType);
    }

    if (hasTrigger) {
      triggerService = TriggerService.create(collections: collections);
    }

    DataAccess acc;

    if (collections?.isEmpty ?? true) {
      acc = _DataAccessEmpty(implementation, identifierMapping);
    } else if (triggerService != null && permissionHandler == null) {
      acc = _DataAccessWithOnlyTrigger(
          implementation, triggerService, identifierMapping);
    } else if (triggerService == null && permissionHandler != null) {
      acc = _DataAccessWithPermission(
          implementation, permissionHandler, identifierMapping);
    } else {
      acc = _DataAccessWithTriggerAndPermission(implementation, triggerService!,
          permissionHandler!, identifierMapping);
    }

    //QueryLanguageBinding().initDelegate(CommonLanguageDelegate());

    return acc;
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
  static DataAccess of(BuildContext context) => context.dataAccess;

  //final QueryLanguageBinding _queryLanguageBinding = QueryLanguageBinding();

  ///
  // AccessEvent buildAccess(AccessEvent builder) {
  //   var res = _queryLanguageBinding.convertTo(builder.access);
  //   return AccessEvent(access: res, request: builder.request);
  // }

  ///
  DataAccessImplementation implementation;

  ///
  PermissionHandlerService? permissionHandler;

  ///
  TriggerService? triggerService;

  FutureOr<T> _operation<T extends DbResult>(
      AccessEvent event, FutureOr<T> Function(Access access) interoperation);

  ///
  FutureOr<DbResult> any(AccessEvent access) {
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
      // case AccessType.aggregation:
      //   return _operation(access, _aggregation);
    }
  }

  ///
  FutureOr<ReadDbResult> read(AccessEvent access) =>
      _operation<ReadDbResult>(access, _read);

  ///
  FutureOr<ReadListResult> readList(AccessEvent access) =>
      _operation<ReadListResult>(access, _readList);

  ///
  FutureOr<ReadListResult> aggregation(AccessEvent access) =>
      _operation<ReadListResult>(access, _aggregation);

  ///
  FutureOr<DbResult<bool>> exists(AccessEvent access) =>
      _operation<DbResult<bool>>(access, _exists);

  ///
  FutureOr<DeleteDbResult> delete(AccessEvent access) =>
      _operation<DeleteDbResult>(access, _delete);

  ///
  FutureOr<UpdateDbResult> update(AccessEvent access) =>
      _operation<UpdateDbResult>(access, _update);

  ///
  FutureOr<CreateDbResult> create(AccessEvent access) =>
      _operation<CreateDbResult>(access, _create);

  ///
  FutureOr<DbResult<int>> count(AccessEvent access) =>
      _operation<DbResult<int>>(access, _count);

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
  FutureOr<bool> init([bool inInterface = true]) => _initDb();

  ///
  Map<String, dynamic> toMap() => {
        'implementation': implementation.runtimeType,
        'data_access': runtimeType,
        'wrapper': (context as Binding).key.key
      };
}

class _DataAccessWithTriggerAndPermission
    extends DataAccess {
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
  FutureOr<T> _operation<T extends DbResult>(AccessEvent event,
      FutureOr<T> Function(Access acc) interoperation) async {
    if (await permissionHandler!.check(event)) {
      return triggerService!.triggerAndReturn(event, interoperation);
    } else {
      throw ForbiddenUnauthorizedException();
    }
  }
}

class _DataAccessWithOnlyTrigger extends DataAccess {
  _DataAccessWithOnlyTrigger(DataAccessImplementation implementation,
      TriggerService triggerService, Map<String, String>? identifierMapping)
      : super._(implementation,
            triggerService: triggerService,
            identifierMapping: identifierMapping);

  @override
  FutureOr<T> _operation<T extends DbResult>(
      AccessEvent event, FutureOr<T> Function(Access access) interoperation) {
    try {
      return triggerService!.triggerAndReturn(event, interoperation);
    } on Exception {
      rethrow;
    }
  }
}

class _DataAccessEmpty extends DataAccess {
  _DataAccessEmpty(DataAccessImplementation implementation,
      Map<String, String>? identifierMapping)
      : super._(implementation, identifierMapping: identifierMapping);

  @override
  FutureOr<T> _operation<T extends DbResult>(
          AccessEvent event, FutureOr<T> Function(Access acc) interoperation) =>
      interoperation(event.access);
}

class _DataAccessWithPermission extends DataAccess {
  _DataAccessWithPermission(
      DataAccessImplementation implementation,
      PermissionHandlerService permissionHandler,
      Map<String, String>? identifierMapping)
      : super._(implementation,
            permissionHandler: permissionHandler,
            identifierMapping: identifierMapping);

  @override
  FutureOr<T> _operation<T extends DbResult>(AccessEvent event,
      FutureOr<T> Function(Access access) interoperation) async {
    try {
      if (await permissionHandler!.check(event)) {
        return interoperation(event.access);
      } else {
        throw ForbiddenUnauthorizedException()..payload = event.toMap(false);
      }
    } on Exception {
      rethrow;
    }
  }
}

///
abstract class DataAccessImplementation {
  ///
  FutureOr<bool> init();

  ///
  FutureOr<DbResult> any(AccessEvent event) {
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
      // case AccessType.aggregation:
      //   return aggregation(event.access);
      case AccessType.delete:
        return delete(event.access);
      case AccessType.count:
        return count(event.access);
    }
  }

  ///
  FutureOr<ReadDbResult> read(Access access);

  ///
  FutureOr<ReadListResult> readList(Access access);

  ///
  FutureOr<ReadListResult> aggregation(Access access);

  ///
  FutureOr<DeleteDbResult> delete(Access access);

  ///
  FutureOr<UpdateDbResult> update(Access access);

  ///
  FutureOr<CreateDbResult> create(Access access);

  ///
  FutureOr<BoolDbResult> exists(Access access);

  ///
  FutureOr<CountDbResult> count(Access access);

  ///
  BuildContext get context => dataAccess.context;

  ///
  late final DataAccess dataAccess;
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
