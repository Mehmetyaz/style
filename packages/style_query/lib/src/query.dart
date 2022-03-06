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
import 'access_object.dart';

///
abstract class Query<L extends AccessLanguage> with AccessObject {
  /// AccessEvent reach data that have this key-value pair with equal or not
  /// equal operations.
  ///
  /// E.g <br>
  /// query is: <br>
  /// `{"author" : "John"}` <br>
  /// Or with sentences, "document/entry that data's `author` is equal to `John` "
  ///
  /// In the example, this query want to reach key-value
  /// pair of "author" and "John".
  ///
  /// Even if a query is not made directly for this key-value pair,
  /// it returns true if there is a possibility that this key-value pair may
  /// exist in the files that affect the result. For example query is empty
  /// and want to reach all document in the collection. In this case reaching
  /// the pair is possible.
  bool isReached(String key, String value);

  /// AccessEvent is sort by key.<br>
  /// returns true if sorted ascending, <br>
  /// returns false if sorted descending, <br>
  /// returns null if not sorted by this key.
  bool? sortedByAsc(String key) {
    return sortExpression?.sortedByAsc(key) ?? false;
  }

  /// is this query specified response fields by the [key]
  /// returns true if [key] specified as exclude
  /// returns false if [key] specified as include
  /// returns null if [key] not specified
  bool? fieldIsExcluded(String key);

  /// is this query specified response fields by the [key]
  /// returns true if [key] specified as include
  /// returns false if [key] specified as exclude
  /// returns null if [key] not specified
  bool? fieldIsIncluded(String key);

  /// return null if not filtered
  FilterExpression? filteredBy(String key);

  ///
  FilterExpression? get filter;

  /// Response fields manipulates
  Fields<L>? get fields;

  ///
  SortExpression? get sortExpression;

  /// Response fields manipulates
  set fields(Fields<L>? value);

  /// Query known object
  String? get identifier;

  /// Document limit
  int? get limit;

  /// Set document limit
  set limit(int? value);

  /// Document offset
  int? get offset;

  /// Set document offset
  set offset(int? value);
}
