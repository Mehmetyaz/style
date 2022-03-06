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
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  group("num", () {
    var a = 10;
    var b = 20;
    var c = 10;
    var d = 40;
    var e = 5;

    var map = {"a": 10, "b": 20, "c": 10, "d": 40, "e": 5};




    test("gt", () {
      var exp = GreaterExpression("b", b);
      expect(exp.compareTo(a), false);
      expect(exp.compareTo(d), true);
    });

    test("gt_isMatch", () {
      expect(GreaterExpression("a", b).isMatch(map), false);
      expect(GreaterExpression("d", b).isMatch(map), true);
    });


    test("gte", () {
      var exp = GreaterOrEqualExpression("c", c);
      expect(exp.compareTo(a), true);
      expect(exp.compareTo(e), false);
    });

    test("gte_isMatch", () {
      expect(GreaterOrEqualExpression("a", c).isMatch(map), true);
      expect(GreaterOrEqualExpression("e", c).isMatch(map), false);
    });

    test("ls", () {
      var exp = LessExpression("c", c);
      expect(exp.compareTo(e), true);
      expect(exp.compareTo(b), false);
    });

    test("ls_isMatch", () {
      expect(LessExpression("e", c).isMatch(map), true);
      expect(LessExpression("b", c).isMatch(map), false);
    });

    test("lse", () {
      var exp = LessOrEqualExpression("c", c);
      expect(exp.compareTo(e), true);
      expect(exp.compareTo(b), false);
      expect(exp.compareTo(a), true);
    });

    test("lse_isMatch", () {
      expect(LessOrEqualExpression("e", c).isMatch(map), true);
      expect(LessOrEqualExpression("b", c).isMatch(map), false);
      expect(LessOrEqualExpression("a", c).isMatch(map), true);
    });

  });
}
