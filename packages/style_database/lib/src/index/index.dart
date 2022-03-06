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

import 'package:binary_tree/binary_tree.dart';
import 'package:style_query/style_query.dart';

///
abstract class Indexer<V extends Object> {
  ///
  Indexer(this.key);

  ///
  String key;

  ///
  IndexMatch<V> getMatches(
      FilterExpression expression, SortExpression sort, int offset, int? limit);

  bool _isMatch(MatchExpression<V> expression);

  ///
  Map<V, dynamic> get getIndex;

  ///
  void indexObject(String id, V value);
}

///
class UniqueIndex<T extends Object> extends Indexer<T> {
  ///
  UniqueIndex(String key) : super(key);

  @override
  Map<T, dynamic> get getIndex => throw UnimplementedError();

  @override
  void indexObject(String id, T value) {}

  @override
  IndexMatch<T> getMatches(FilterExpression expression, SortExpression sort,
      int offset, int? limit) {
    // TODO: implement getMatches
    throw UnimplementedError();
  }

  @override
  bool _isMatch(MatchExpression<T> expression) {
    // TODO: implement _isMatch
    throw UnimplementedError();
  }
}

/// Multiple
class SortedIndex<T extends Comparable> extends Indexer<T> {
  ///
  SortedIndex(String key, {required this.ascending}) : super(key);

  ///
  final bool ascending;

  ///
  final Map<T, List<String>> index = {};

  ///
  final BinaryTree<T> values = BinaryTree<T>();

  @override
  Map<T, dynamic> get getIndex => index;

  @override
  void indexObject(String id, T value) {
    index[value] ??= <String>[];
    index[value]!.add(id);
  }

  @override
  IndexMatch<T> getMatches(FilterExpression expression, SortExpression sort,
      int offset, int? limit) {
    // TODO: implement getMatches
    throw UnimplementedError();
  }

  @override
  bool _isMatch(MatchExpression<T> expression) {
    // TODO: implement _isMatch
    throw UnimplementedError();
  }
}

///
class IndexMatch<V> {
  ///
  IndexMatch(this.query, this.indexer);

  ///
  Indexer indexer;

  ///
  Query query;

  ///
  List<V> getResult() {
    throw UnimplementedError();
  }

  ///
  List<V> getResultWith(IndexMatch other) {
    throw Exception();
  }
}
