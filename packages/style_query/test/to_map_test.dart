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
  test("to_map_test", () {
    expect(
        AndExpression([
          EqualExpression("a", 10),
          EqualExpression("b", 20),
          EqualExpression("d", 40),
          NotEqualExpression("d", 30),
          OrExpression([
            GreaterExpression("c", 8),
            LessExpression("c", 10),
            GreaterOrEqualExpression("d", 80),
            LessOrEqualExpression("e", 5)
          ])
        ]).toMap(),
        {
          "&&": [
            ["a", "==", 10],
            ["b", "==", 20],
            ["d", "==", 40],
            ["d", "!=", 30],
            {
              "||": [
                ["c", ">", 8],
                ["c", "<", 10],
                ["d", ">=", 80],
                ["e", "<=", 5]
              ]
            }
          ]
        });
  });
}
