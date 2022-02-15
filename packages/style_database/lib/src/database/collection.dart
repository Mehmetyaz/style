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

import 'dart:collection';
import 'dart:convert';

import '../index/index.dart';

///
class Collection<T extends DbObject> {
  ///
  Collection(this.name);

  ///
  String name;

  ///
  Map<String, Indexer> indexes = {};

  ///
  HashMap<String, T> objects = HashMap();

  ///
  void add(T data) {
    objects[data.id] = data;
    if (indexes.isNotEmpty) {
      for (var key in indexes.keys) {
        var p = data.getProperty(key);
        if (p != null) {
          indexes[key]?.indexObject(data.id, p);
        }
      }
    }
  }

  ///
  void createIndexes<T>(
    String field, {
    bool unique = false,
    bool ascending = true,
  }) {
    indexes[field] = SortedIndex<int>(field, ascending: ascending);
  }
}

///
abstract class DbObject {
  ///
  DbObject();

  ///
  T? getProperty<T>(String key);

  ///
  String get id;
}

///
class MapDbObject extends DbObject {
  ///
  MapDbObject(this.data, this._id);

  ///
  final Map<String, dynamic> data;

  ///
  final String _id;

  @override
  T? getProperty<T>(String key) {
    return data[key] as T?;
  }

  @override
  String get id => _id;
}
