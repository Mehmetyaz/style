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

import 'style_query_base.dart';

///
abstract class FilterExpression {
  ///
  bool isMatch(JsonMap map);

  ///
  dynamic toMap();
}

///
class AndExpression extends FilterExpression {
  ///
  AndExpression(this.expressions);

  ///
  List<FilterExpression> expressions;

  @override
  bool isMatch(JsonMap map) {
    for (var expression in expressions) {
      if (!expression.isMatch(map)) {
        return false;
      }
    }
    return true;
  }

  @override
  JsonMap toMap() {
    return {
      "&&": [...expressions.map((e) => e.toMap()).toList()]
    };
  }
}

///
class OrExpression extends FilterExpression {
  ///
  OrExpression(this.expressions);

  ///
  List<FilterExpression> expressions;

  @override
  bool isMatch(JsonMap map) {
    for (var expression in expressions) {
      if (expression.isMatch(map)) {
        return true;
      }
    }
    return false;
  }

  @override
  JsonMap toMap() {
    return {
      "||": [...expressions.map((e) => e.toMap()).toList()]
    };
  }
}

///
abstract class MatchExpression<Q extends Object> extends FilterExpression {
  ///
  MatchExpression(this.key, this.queryValue);

  ///
  Q queryValue;

  ///
  String key;

  ///
  String get expression;

  ///
  bool compareTo(dynamic value);

  @override
  List toMap() {
    return [key, expression, queryValue];
  }

  @override
  bool isMatch(JsonMap map) {
    return compareTo(map[key]);
  }
}

///
class EqualExpression<Q extends Object> extends MatchExpression<Q> {
  ///
  EqualExpression(String key, Q queryValue) : super(key, queryValue);

  @override
  bool compareTo(dynamic value) => value == queryValue;

  @override
  String get expression => "==";
}

///
class NotEqualExpression<Q extends Object> extends MatchExpression<Q> {
  ///
  NotEqualExpression(String key, Q queryValue) : super(key, queryValue);

  @override
  bool compareTo(dynamic value) => value != queryValue;

  @override
  String get expression => "!=";
}

///
mixin ComparisonExpression<Q extends Comparable> on MatchExpression<Q> {
  ///
  bool get equal;

  ///
  bool get greater;
}

///
class GreaterExpression<Q extends Comparable> extends MatchExpression<Q>
    with ComparisonExpression {
  ///
  GreaterExpression(String key, Q queryValue) : super(key, queryValue);

  @override
  bool compareTo(dynamic value) =>
      value is Comparable && value.compareTo(queryValue) > 0;

  @override
  bool get equal => false;

  @override
  bool get greater => true;

  @override
  String get expression => ">";
}

///
class LessExpression<Q extends Comparable> extends MatchExpression<Q>
    with ComparisonExpression {
  ///
  LessExpression(String key, Q queryValue) : super(key, queryValue);

  @override
  bool compareTo(dynamic value) =>
      value is Comparable && value.compareTo(queryValue) < 0;

  @override
  bool get equal => false;

  @override
  bool get greater => false;

  @override
  String get expression => "<";
}

///
class GreaterOrEqualExpression<Q extends Comparable> extends MatchExpression<Q>
    with ComparisonExpression {
  ///
  GreaterOrEqualExpression(String key, Q queryValue) : super(key, queryValue);

  @override
  bool compareTo(dynamic value) =>
      value is Comparable && value.compareTo(queryValue) > -1;

  @override
  bool get equal => true;

  @override
  bool get greater => true;

  @override
  String get expression => ">=";
}

///
class LessOrEqualExpression<Q extends Comparable> extends MatchExpression<Q>
    with ComparisonExpression {
  ///
  LessOrEqualExpression(String key, Q queryValue) : super(key, queryValue);

  @override
  bool compareTo(dynamic value) =>
      value is Comparable && value.compareTo(queryValue) < 1;

  @override
  bool get equal => true;

  @override
  bool get greater => false;

  @override
  String get expression => "<=";
}
