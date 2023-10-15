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

///Mongo Db Operation Type
enum DbOperationType {
  ///Create Document
  create,

  ///Read Document
  read,

  ///Update Document
  update,

  ///Delete Document
  delete,
}

// class AccessBuilder {
//   ///
//   AccessBuilder(
//       {this.request , required this.access, this.context});
//
//   ///
//   Request? request;
//
//   ///
//   BuildContext? context;
//
//   ///
//   Access access;
// }

///
class AccessEvent {
  ///
  AccessEvent(
      {required this.access, required this.request, this.errors, this.context})
      : createTime = DateTime.now(),
        type = _getDbOpType(access.type);

  ///
  static DbOperationType _getDbOpType(AccessType type) {
    switch (type) {
      case AccessType.read:
        return DbOperationType.read;
      case AccessType.readMultiple:
        return DbOperationType.read;
      case AccessType.create:
        return DbOperationType.create;
      case AccessType.update:
        return DbOperationType.update;
      case AccessType.exists:
        return DbOperationType.read;
      case AccessType.listen:
        return DbOperationType.read;
      case AccessType.delete:
        return DbOperationType.delete;
      case AccessType.count:
        return DbOperationType.read;
      // case AccessType.aggregation:
      //   return DbOperationType.read;
    }
  }

  ///
  Access access;

  ///
  AccessToken? get token => request?.token;

  ///
  DbOperationType type;

  ///
  Request? request;

  ///
  final DateTime createTime;

  ///
  Map<String, dynamic>? before, after;

  ///
  List<MapEntry<String, dynamic>>? errors;

  ///
  BuildContext? context;

  // ignore_for_file: avoid_positional_boolean_parameters
  ///
  Map<String, dynamic> toMap([bool includeBeforeAfter = true]) => {
        'data_access': context?.dataAccess.toMap() ?? 'unknown',
        'type': type.index,
        'create': createTime.millisecondsSinceEpoch,
        'request': request?.toMap(),
        if (includeBeforeAfter) 'before': before,
        if (includeBeforeAfter) 'after': after,
        'access': access.toMap(),
        'errors': errors
      };
}

///
class Read extends AccessEvent {
  ///
  Read(
      {Request? request,
      required String collection,
      required JsonMap query,
      AccessToken? customToken})
      : super(
            request: request?..token = customToken,
            access: Access(
                type: AccessType.read, collection: collection, query: query));
}

///
class ReadMultiple extends AccessEvent {
  ///
  ReadMultiple(
      {Request? request,
      required String collection,
      JsonMap? query,
      AccessToken? customToken})
      : super(
            request: request?..token = customToken,
            access: Access(
                type: AccessType.readMultiple,
                collection: collection,
                query: query));
}

///
class Create extends AccessEvent {
  ///
  Create(
      {Request? request,
      required String collection,
      required JsonMap data,
      AccessToken? customToken})
      : super(
            request: request?..token = customToken,
            access: Access(
                type: AccessType.create, collection: collection, create: data));
}

///
class Update extends AccessEvent {
  ///
  Update(
      {Request? request,
      required String collection,
      JsonMap? query,
      String? identifier,
      required JsonMap data,
      AccessToken? customToken})
      : assert(identifier != null || query != null),
        super(
            request: request?..token = customToken,
            access: Access(
                type: AccessType.update, collection: collection, update: data));
}

///
class Delete extends AccessEvent {
  ///
  Delete(
      {Request? request,
      required String collection,
      required JsonMap query,
      AccessToken? customToken})
      : super(
            request: request?..token = customToken,
            access: Access(
                type: AccessType.delete, collection: collection, query: query));
}

///
class Count extends AccessEvent {
  ///
  Count(
      {Request? request,
      required String collection,
      JsonMap? query,
      AccessToken? customToken})
      : super(
          request: request?..token = customToken,
          access: Access(
              type: AccessType.count, collection: collection, query: query),
        );
}

///
class Exists extends AccessEvent {
  ///
  Exists(
      {Request? request,
      required String collection,
      required JsonMap query,
      AccessToken? customToken})
      : super(
            request: request?..token = customToken,
            access: Access(
                type: AccessType.exists, collection: collection, query: query));
}
