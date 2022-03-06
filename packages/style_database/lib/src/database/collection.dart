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

import 'package:style_query/style_query.dart';
import 'package:style_random/style_random.dart';

import '../index/index.dart';

///
class Collection {
  ///
  Collection(this.name, this._randomGenerator);

  ///
  String name;

  ///
  Map<String, Indexer> indexes = {};

  ///
  final RandomGenerator _randomGenerator;

  ///
  void add(JsonMap data) {
    data["id"] ??= _randomGenerator.generateString();
    if (indexes.isNotEmpty) {
      for (var key in indexes.keys) {
        indexes[key]!.indexObject(data["id"], data[key]);
      }
    }
  }

  ///
  void createIndexes<T>(String field, {
    bool unique = false,
    bool ascending = true,
  }) {
    indexes[field] = SortedIndex<int>(field, ascending: ascending);
  }
}
