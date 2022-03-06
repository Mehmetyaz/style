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

import 'collection.dart';

///
class Database {
  ///
  Database({RandomGenerator? idGenerator})
      : idGenerator = idGenerator ?? RandomGenerator("[#*]/l(30)");

  ///
  RandomGenerator idGenerator;

  ///
  bool opened = false;

  ///
  Map<String, Collection> collections = {};

  ///
  void read(CommonAccess access) {}

  ///
  void create(CommonAccess access) {
    collections[access.collection] ??
        Collection(access.collection, idGenerator);
    collections[access.collection]!.add(access.create!.toMap());
  }

  ///
  void createIndexes(
    String collection,
    String field, {
    bool unique = false,
    bool ascending = true,
  }) {
    collections[collection] ??= Collection(collection, idGenerator);
    collections[collection]!.createIndexes(field);
  }
}
