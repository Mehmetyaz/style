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

import '../style_query.dart';

///
class CommonLanguage extends AccessLanguage {
  @override
  String get name => "common";
}

///
class CommonQuery extends Query<CommonLanguage> {
  ///
  CommonQuery({this.id, this.selector, this.limit, this.offset, this.sort});

  ///
  String? id;

  ///
  Map<String, dynamic>? selector, sort;

  ///
  @override
  int? limit, offset;

  ///
  factory CommonQuery.fromMap(Map<String, dynamic> map) {
    return CommonQuery(
      sort: map["sort"],
      offset: map["offset"],
      limit: map["limit"],
      selector: map["selector"],
    );
  }

  @override
  FilterExpression? filteredBy(String key) {
    throw UnimplementedError();
  }

  @override
  bool isReached(String key, String value) {
    throw UnimplementedError();
  }

  @override
  bool? fieldIsExcluded(String key) {
    throw UnimplementedError();
  }

  @override
  bool? fieldIsIncluded(String key) {
    throw UnimplementedError();
  }

  @override
  JsonMap toMap() => {
        if (sort != null) "sort": sort,
        if (offset != null) "offset": offset,
        if (limit != null) "limit": limit,
        if (selector != null) "selector": selector
      };

  @override
  String? get identifier => throw UnimplementedError();

  @override
  Fields<CommonLanguage>? fields;

  @override
  FilterExpression? get filter => throw UnimplementedError();

  @override
  // TODO: implement sortExpression
  SortExpression<AccessLanguage>? get sortExpression =>
      throw UnimplementedError();
}

///
class CommonUpdate extends UpdateData<CommonLanguage> {
  ///
  CommonUpdate(this._data);

  final JsonMap _data;

  @override
  UpdateDifference<T>? difference<T>(String key) {
    throw UnimplementedError();
  }

  @override
  JsonMap toMap() => _data;

  @override
  List<String> keysRenamed() => throw UnimplementedError();

  @override
  List<String> fieldsChanged() => throw UnimplementedError();

  @override
  List<String> fieldsRemoved() => throw UnimplementedError();

  @override
  Map<String, UpdateDifference<CommonLanguage>> differences() =>
      throw UnimplementedError();
}

///
class CommonCreate extends CreateData<CommonLanguage> {
  ///
  CommonCreate(this._data);

  final JsonMap _data;

  @override
  JsonMap toMap() => _data;

  @override
  String get id => throw UnimplementedError();
}

///
class CommonAccess extends Access<CommonLanguage> {
  ///
  CommonAccess(
      {required AccessType type,
      required String collection,
      CommonQuery? query,
      CommonCreate? create,
      UpdateData<CommonLanguage>? update,
      OperationSettings? settings})
      : super(
            type: type,
            collection: collection,
            settings: settings,
            query: query,
            create: create,
            update: update);
}
