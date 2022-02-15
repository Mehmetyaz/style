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

///
abstract class Indexer<V extends Comparable> {
  ///
  Indexer(this.key);

  ///
  String key;

  ///
  IndexMatch<V> getMatch(MatchExpression<V> expression);

  ///
  IndexMatch<V> getMatchesWith();

  ///
  Map<V, dynamic> get getIndex;

  ///
  void indexObject(String id, V value);
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
  final List<T> values = <T>[];

  @override
  Map<T, dynamic> get getIndex => index;

  @override
  void indexObject(String id, T value) {
    index[value] ??= <String>[];
    index[value]!.add(id);

    var where = values.indexOf(value);
    if (where == -1) {
      values.add(value);
      values.sort((a, b) => a.compareTo(b));
    }
  }

  ///
  int getObjectIndex(ComparisonExpression<T> expression) {



    var full = values.length;
    var half = (full / 2).ceil();

    int? res;


    half_loop:
    while (res == null){
        var _i = _check(half);
        if (_i.last) {

          if (half < 2 ) {
            if (ascending) {
              if (expression.greater) {
                res = 0;
              } else {
                res = -2;
              }
            } else {
              if (expression.greater) {

              } else {

              }
            }
          }




          res = half < 2 ? 0 : values.length;
          continue half_loop;
        }
        if (_i.index != null) {
          res = _i.index;
          continue half_loop;
        }



    }


    throw Exception();
  }

  _IndexFindResult _check(int index) {







    throw Exception();
  }

  /// Check index - 1 , index and index + 1 satisfy
  /// list val > value
  /// örnekte 60 tan büyüğü arıyorum
  _IndexFindResult _checkMiddle(List<int> l, int index, int value) {
    if (l[index] < value) {
      /// ortadaki 60 dan küçükse
      /// sağa bak
      if (l.length - 1 > index) {
        /// sağda var

        if (l[index + 1] >= value) {
          /// sağdaki 60'tan büyük veya eşit
          return _IndexFindResult(
              index: index + 1,
              //left: false,
              last: false,
              equal: l[index + 1] == value);
        } else {
          return _IndexFindResult(
              index: null,/* left: false,*/ last: false, equal: false);
        }
      } else {
        /// sağda yok
        return _IndexFindResult(
            index: null,/* left: null,*/ last: true, equal: false);
      }
    } else if (l[index] == value) {
      return _IndexFindResult(
          index: index,/* left: false,*/ last: false, equal: true);
    } else {
      /// ortadaki büyük sola bak
      if (index > 0) {
        /// solda var
        if (l[index - 1] > value) {
          /// soldaki büyük
          return _IndexFindResult(
              index: null,/* left: true,*/ last: false, equal: false);
        } else if (l[index - 1] == value) {
          /// soldaki eşit
          return _IndexFindResult(
              index: index - 1, /*left: false,*/ last: false, equal: true);
        } else {
          /// soldaki küçük
          return _IndexFindResult(
              index: null,/* left: false,*/ last: false, equal: false);
        }
      } else {
        /// solda yok
        return _IndexFindResult(
            index: null, /*left: true,*/ last: true, equal: false);
      }
    }
  }

  @override
  IndexMatch<T> getMatch(MatchExpression<T> expression) {
    throw UnimplementedError();
  }

  @override
  IndexMatch<T> getMatchesWith() {
    throw UnimplementedError();
  }
}







class _IndexFindResult {
  _IndexFindResult({this.index, required this.last,required this.equal});

  int? index;
  bool last;
  bool equal;


  @override
  String toString() {
    return "i: $index \nis_last: $last \nis_eq: $equal";
  }
}

///
abstract class IndexMatch<V> {
  ///
  IndexMatch(this.indexer);

  ///
  Indexer indexer;

  ///
  List<V> getResult();

  ///
  List<V> getResultWith(Indexer other);
}

///
abstract class MatchExpression<Q extends Object> {
  ///
  MatchExpression(this.queryValue);

  ///
  Q queryValue;

  ///
  bool compareTo(Q value);
}

///
class EqualExpression<Q extends Object> extends MatchExpression<Q> {
  ///
  EqualExpression(Q queryValue) : super(queryValue);

  @override
  bool compareTo(Q value) => value == queryValue;
}

///
class NotEqualExpression<Q extends Object> extends MatchExpression<Q> {
  ///
  NotEqualExpression(Q queryValue) : super(queryValue);

  @override
  bool compareTo(Q value) => value != queryValue;
}

///
mixin ComparisonExpression<Q extends Comparable> on MatchExpression<Q> {
  bool get equal;
  bool get greater;
}

///
class GreaterExpression<Q extends Comparable> extends MatchExpression<Q>
    with ComparisonExpression {
  ///
  GreaterExpression(Q queryValue) : super(queryValue);

  @override
  bool compareTo(Q value) => value.compareTo(queryValue) > 0;

  @override
  bool get equal => false;

  @override
  bool get greater => true;
}

///
class LessExpression<Q extends Comparable> extends MatchExpression<Q>
    with ComparisonExpression {
  ///
  LessExpression(Q queryValue) : super(queryValue);

  @override
  bool compareTo(Q value) => value.compareTo(queryValue) < 0;

  @override
  bool get equal => false;

  @override
  bool get greater => false;


}

///
class GreaterOrEqualExpression<Q extends Comparable> extends MatchExpression<Q>
    with ComparisonExpression {
  ///
  GreaterOrEqualExpression(Q queryValue) : super(queryValue);

  @override
  bool compareTo(Q value) => value.compareTo(queryValue) > -1;

  @override
  bool get equal => true;

  @override
  bool get greater => true;

}

///
class LessOrEqualExpression<Q extends Comparable> extends MatchExpression<Q>
    with ComparisonExpression {
  ///
  LessOrEqualExpression(Q queryValue) : super(queryValue);

  @override
  bool compareTo(Q value) => value.compareTo(queryValue) < 1;

  @override
  bool get equal => true;

  @override
  bool get greater => false;
}
