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
  // TODO: implement name
  String get name => throw UnimplementedError();
}

///
class CommonQuery extends Query<CommonLanguage> {
  ///
  CommonQuery({this.selector, this.fields, this.limit, this.offset, this.sort});

  ///
  Map<String, dynamic>? selector, sort, fields;

  ///
  @override
  int? limit, offset;

  ///
  factory CommonQuery.fromMap(Map<String, dynamic> map) {
    return CommonQuery(
      fields: map["fields"],
      sort: map["sort"],
      offset: map["offset"],
      limit: map["limit"],
      selector: map["selector"],
    );
  }

  ///
  @override
  Map<String, dynamic> toMap() => {
        if (fields != null) "fields": fields,
        if (sort != null) "sort": sort,
        if (offset != null) "offset": offset,
        if (limit != null) "limit": limit,
        if (selector != null) "selector": selector
      };

  @override
  FilterExpression? filteredBy(String key) {
    // TODO: implement filteredBy
    throw UnimplementedError();
  }

  @override
  bool isReached(String key, String value) {
    // TODO: implement isReached
    throw UnimplementedError();
  }

  @override
  bool? sortedByAsc(String key) {
    // TODO: implement sortedBy
    throw UnimplementedError();
  }

  @override
  bool? fieldIsExcluded(String key) {
    // TODO: implement fieldIsExcluded
    throw UnimplementedError();
  }

  @override
  bool? fieldIsIncluded(String key) {
    // TODO: implement fieldIsIncluded
    throw UnimplementedError();
  }
}

///
class CommonUpdate extends UpdateData<CommonLanguage> {
  ///
  CommonUpdate(this._data);

  final Map<String, dynamic> _data;

  @override
  Map<String, dynamic> get data => _data;

  @override
  UpdateDifference<T>? difference<T>(String key) {
    // TODO: implement difference
    throw UnimplementedError();
  }

  @override
  bool isChangedField(String key) {
    // TODO: implement isChangedField
    throw UnimplementedError();
  }

  @override
  bool keyIsRenamed(String key) {
    // TODO: implement keyIsRenamed
    throw UnimplementedError();
  }

  @override
  bool keyRemoved(String key) {
    // TODO: implement keyRemoved
    throw UnimplementedError();
  }
}


///
class CommonCreate extends CreateData<CommonLanguage> {
  ///
  CommonCreate(this._data);

  final Map<String, dynamic> _data;

  @override
  Map<String, dynamic> get data => _data;
}

///
class CommonAccess extends Access<CommonLanguage> {
  ///
  CommonAccess(
      {required AccessType type,
      required String collection,
      String? identifier,
      CommonQuery? query,
      CommonCreate? create,
      UpdateData<CommonLanguage>? update,
      OperationSettings? settings})
      : super(
            type: type,
            collection: collection,
            identifier: identifier,
            settings: settings,
            query: query,
            create: create,
            update: update);
}
