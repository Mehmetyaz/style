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

import 'package:style_database/src/index/index.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  group("num", () {
    var a = 10;
    var b = 20;
    var c = 10;
    var d = 40;
    var e = 5;

    test("eq", () {
      var exp = EqualExpression(a);
      expect(exp.compareTo(c), true);
      expect(exp.compareTo(b), false);
    });

    test("ne", () {
      var exp = NotEqualExpression(a);
      expect(exp.compareTo(c), false);
      expect(exp.compareTo(b), true);
    });

    test("gt", () {
      var exp = GreaterExpression(b);
      expect(exp.compareTo(a), false);
      expect(exp.compareTo(d), true);
    });

    test("gte", () {
      var exp = GreaterOrEqualExpression(c);
      expect(exp.compareTo(a), true);
      expect(exp.compareTo(e), false);
    });

    test("ls", () {
      var exp = LessExpression(c);
      expect(exp.compareTo(e), true);
      expect(exp.compareTo(b), false);
    });

    test("lse", () {
      var exp = LessOrEqualExpression(c);
      expect(exp.compareTo(e), true);
      expect(exp.compareTo(b), false);
      expect(exp.compareTo(a), true);
    });
  });
}
