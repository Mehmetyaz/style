import 'dart:convert';

import 'package:style_query/style_query.dart';

void main() {

  var exp = AndExpression([
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
  ]);

  print(json.encode(exp.toMap()));
}

///
Map<String, dynamic> res = {
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
};
