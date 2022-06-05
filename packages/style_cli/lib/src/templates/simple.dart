/*
 * Copyright 2021 styledart.dev - Mehmet Yaz
 *
 * Licensed under the GNU AFFERO GENERAL PUBLIC LICENSE,
 *    Version 3 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *       https://www.gnu.org/licenses/agpl-3.0.en.html
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

import '../template_generator.dart';

///
const simpleServer = TemplateGenerator([  "bin",
  "data",
  "assets",
  "lib"], {
  "bin/main.dart": """
import 'package:__projectName__/server.dart';
import 'package:style_dart/style_dart.dart';
 
void main(List<String> arguments) {
  runService(MyServer());
}
  """,
  "lib/server.dart": """
  import 'dart:async';

import 'package:style_dart/style_dart.dart';

///
class MyServer extends StatelessComponent {
  ///
  const MyServer({Key? key}) : super(key: key);

  @override
  Component build(BuildContext context) {
    return Server(

        // Project root name for using in redirect
        // or reach microservices
        rootName: "__projectName__",

        // Root Endpoint handle http(s)://<host> requests
        // You can use redirect for your default endpoint
        // eg. Redirect("../index.html")
        // for redirecting documentation (temporary)http..://google.com
        // call http://localhost
        rootEndpoint: SimpleEndpoint.static("Hello World!"),

        // you can change favicon.ico
        faviconDirectory: "__dataDir__/assets/",

        // Server routes
        children: [
          /// Route and sub-route http(s)://localhost/hi(/..)
          Route("hi",

              /// Say hello everyone http://localhost/hi
              root: SimpleEndpoint.static("Hello Everyone!"),

              /// Say hi http://localhost/hi/mehmet
              child: Route("{name}", root: SimpleEndpoint((req, _) {
                return "Hello \${req.arguments["name"]}!";
              }))),

          /// Sum 40 and 2 : http://localhost/sum/40/2
          MathOperationRoute("sum", (a, b) => a + b),

          /// Difference 44 and 2 : http://localhost/dif/44/2
          MathOperationRoute("dif", (a, b) => a - b),
        ]);
  }
}

///
class MathOperationRoute extends StatelessComponent {
  ///
  MathOperationRoute(this.name, this.operation);

  /// Operation route.
  /// eg when name is "sum".
  /// http(s)://host/sum/.. handled
  final String name;

  /// Math operation with 2 input
  final num Function(int a, int b) operation;

  @override
  Component build(BuildContext context) {
    return ExceptionWrapper(
        child: Route(name,

            /// on called http(s)://host/{name}
            /// so we cant calculate anything
            root: Throw(FormatException()),

            /// Handle "http(s)://host/" 's sub-routes with argument as "a"
            child: Route("{a}",

                /// on called http(s)://host/{name}/{a}
                /// also we cant calculate anything with only one input
                root: Throw(FormatException()),
                child: Route("{b}",

                    /// on called http(s)://host/{name}/{a}/{b}
                    /// now, we can calculate
                    root: SimpleEndpoint((request, _) {
                  var a = int.parse(request.arguments["a"]);
                  var b = int.parse(request.arguments["b"]);
                  return {"a": a, "b": b, name: operation(a, b)};
                })))),
        exceptionEndpoint: FormatExceptionEndpoint());
  }
}

///
class FormatExceptionEndpoint extends ExceptionEndpoint<FormatException> {
  @override
  FutureOr<Response> onError(
      Message message, FormatException exception, StackTrace stackTrace) {
    return (message as Request).response(
        "please ensure path like: \\\"host/{sum|div|dif|mul}/{number}/{number}\\\"");
  }
}  
  """,
  "pubspec.yaml": """
name: __projectName__
description: A simple style data access server.
version: 1.0.0
publish_to: none

environment:
  sdk: '>=2.14.0 <3.0.0'

dependencies:
  style_dart:
    path: ../../../style

dev_dependencies:
  effective_dart: ^1.3.2
""",
  "analysis_options.yaml": "include: package:effective_dart/analysis_options.yaml",
  ".gitignore": """
# Files and directories created by pub.
.dart_tool/
.packages

# Conventional directory for build output.
build/

# Local data created with DataAccess
data/
""",
  "assets/favicon.ico": [
    137,
    80,
    78,
    71,
    13,
    10,
    26,
    10,
    0,
    0,
    0,
    13,
    73,
    72,
    68,
    82,
    0,
    0,
    0,
    100,
    0,
    0,
    0,
    100,
    8,
    6,
    0,
    0,
    0,
    112,
    226,
    149,
    84,
    0,
    0,
    0,
    1,
    115,
    82,
    71,
    66,
    0,
    174,
    206,
    28,
    233,
    0,
    0,
    0,
    4,
    103,
    65,
    77,
    65,
    0,
    0,
    177,
    143,
    11,
    252,
    97,
    5,
    0,
    0,
    0,
    9,
    112,
    72,
    89,
    115,
    0,
    0,
    14,
    195,
    0,
    0,
    14,
    195,
    1,
    199,
    111,
    168,
    100,
    0,
    0,
    3,
    66,
    73,
    68,
    65,
    84,
    120,
    94,
    237,
    220,
    189,
    107,
    20,
    65,
    28,
    198,
    241,
    217,
    219,
    196,
    35,
    69,
    16,
    108,
    20,
    44,
    44,
    108,
    19,
    80,
    43,
    65,
    65,
    176,
    211,
    194,
    63,
    65,
    197,
    23,
    80,
    59,
    11,
    27,
    155,
    136,
    157,
    34,
    168,
    133,
    24,
    43,
    209,
    63,
    32,
    32,
    8,
    66,
    32,
    133,
    87,
    4,
    81,
    12,
    9,
    70,
    49,
    4,
    21,
    173,
    69,
    144,
    132,
    28,
    151,
    144,
    91,
    247,
    201,
    173,
    132,
    144,
    183,
    123,
    217,
    153,
    249,
    253,
    102,
    158,
    47,
    44,
    51,
    59,
    215,
    221,
    231,
    216,
    189,
    98,
    103,
    13,
    99,
    140,
    49,
    198,
    194,
    40,
    41,
    70,
    213,
    93,
    123,
    83,
    191,
    147,
    15,
    35,
    173,
    51,
    119,
    213,
    235,
    141,
    7,
    47,
    158,
    140,
    221,
    53,
    43,
    149,
    101,
    83,
    187,
    216,
    40,
    150,
    123,
    42,
    45,
    70,
    181,
    249,
    194,
    248,
    58,
    53,
    247,
    103,
    98,
    236,
    109,
    90,
    77,
    42,
    103,
    147,
    254,
    228,
    247,
    234,
    193,
    115,
    63,
    204,
    207,
    87,
    89,
    241,
    113,
    215,
    85,
    138,
    81,
    101,
    190,
    48,
    62,
    191,
    255,
    98,
    62,
    214,
    102,
    246,
    229,
    151,
    151,
    163,
    249,
    53,
    102,
    186,
    145,
    153,
    119,
    166,
    118,
    169,
    89,
    124,
    220,
    83,
    106,
    47,
    89,
    62,
    49,
    166,
    39,
    103,
    49,
    253,
    155,
    31,
    143,
    22,
    50,
    243,
    208,
    140,
    95,
    192,
    188,
    148,
    84,
    130,
    132,
    138,
    129,
    212,
    129,
    132,
    140,
    129,
    84,
    129,
    132,
    142,
    129,
    212,
    128,
    196,
    128,
    129,
    84,
    128,
    196,
    130,
    129,
    196,
    131,
    196,
    132,
    129,
    68,
    131,
    196,
    134,
    129,
    196,
    130,
    196,
    136,
    129,
    68,
    130,
    196,
    138,
    129,
    196,
    129,
    196,
    140,
    129,
    68,
    129,
    196,
    142,
    129,
    196,
    128,
    16,
    163,
    149,
    8,
    16,
    98,
    172,
    231,
    29,
    132,
    24,
    27,
    243,
    10,
    66,
    140,
    205,
    121,
    3,
    33,
    198,
    214,
    121,
    1,
    33,
    198,
    246,
    57,
    7,
    33,
    198,
    206,
    57,
    5,
    33,
    198,
    238,
    57,
    3,
    33,
    70,
    123,
    57,
    1,
    33,
    70,
    251,
    89,
    7,
    33,
    70,
    103,
    89,
    5,
    33,
    70,
    231,
    89,
    3,
    33,
    70,
    119,
    89,
    1,
    33,
    70,
    247,
    149,
    14,
    66,
    140,
    222,
    178,
    241,
    108,
    239,
    158,
    98,
    116,
    90,
    179,
    185,
    246,
    104,
    237,
    98,
    102,
    204,
    99,
    173,
    24,
    168,
    116,
    144,
    209,
    51,
    3,
    183,
    179,
    102,
    118,
    175,
    56,
    117,
    214,
    240,
    241,
    33,
    115,
    236,
    228,
    240,
    74,
    206,
    242,
    193,
    124,
    95,
    94,
    40,
    150,
    213,
    101,
    237,
    166,
    126,
    245,
    245,
    226,
    253,
    52,
    77,
    111,
    21,
    167,
    206,
    154,
    159,
    153,
    255,
    54,
    57,
    49,
    117,
    165,
    254,
    107,
    181,
    102,
    230,
    46,
    151,
    242,
    68,
    186,
    203,
    172,
    254,
    237,
    37,
    74,
    231,
    89,
    5,
    65,
    68,
    233,
    44,
    235,
    32,
    136,
    40,
    237,
    231,
    4,
    4,
    17,
    165,
    189,
    156,
    129,
    32,
    162,
    236,
    158,
    83,
    16,
    68,
    148,
    157,
    115,
    14,
    130,
    136,
    178,
    125,
    94,
    64,
    16,
    81,
    182,
    206,
    27,
    8,
    34,
    202,
    230,
    188,
    130,
    32,
    162,
    108,
    204,
    59,
    8,
    34,
    202,
    122,
    34,
    64,
    16,
    81,
    90,
    137,
    1,
    65,
    68,
    17,
    6,
    130,
    98,
    71,
    17,
    7,
    130,
    98,
    70,
    17,
    9,
    130,
    98,
    69,
    17,
    11,
    130,
    98,
    68,
    17,
    13,
    130,
    98,
    67,
    17,
    15,
    130,
    98,
    66,
    81,
    1,
    130,
    98,
    65,
    81,
    3,
    130,
    98,
    64,
    81,
    5,
    130,
    66,
    71,
    81,
    7,
    130,
    66,
    70,
    81,
    9,
    130,
    66,
    69,
    81,
    11,
    130,
    66,
    68,
    81,
    13,
    130,
    66,
    67,
    81,
    15,
    130,
    66,
    66,
    81,
    253,
    102,
    235,
    255,
    229,
    24,
    75,
    197,
    212,
    105,
    203,
    141,
    149,
    195,
    125,
    149,
    100,
    116,
    224,
    80,
    122,
    194,
    152,
    145,
    82,
    126,
    220,
    234,
    65,
    4,
    236,
    71,
    57,
    144,
    36,
    201,
    17,
    51,
    188,
    191,
    148,
    239,
    82,
    53,
    136,
    148,
    205,
    65,
    75,
    153,
    121,
    105,
    62,
    221,
    88,
    197,
    66,
    175,
    169,
    189,
    135,
    132,
    186,
    83,
    75,
    37,
    72,
    200,
    219,
    230,
    212,
    129,
    132,
    190,
    135,
    81,
    21,
    72,
    232,
    24,
    72,
    13,
    72,
    12,
    24,
    72,
    5,
    72,
    44,
    24,
    72,
    60,
    72,
    76,
    24,
    72,
    52,
    72,
    108,
    24,
    72,
    44,
    72,
    140,
    24,
    72,
    36,
    72,
    172,
    24,
    72,
    28,
    72,
    204,
    24,
    72,
    20,
    72,
    236,
    24,
    72,
    12,
    8,
    49,
    90,
    137,
    0,
    33,
    198,
    122,
    222,
    65,
    136,
    177,
    49,
    175,
    32,
    196,
    216,
    156,
    55,
    16,
    98,
    108,
    157,
    23,
    16,
    98,
    108,
    159,
    115,
    16,
    98,
    236,
    156,
    83,
    16,
    98,
    236,
    158,
    51,
    16,
    98,
    180,
    151,
    19,
    16,
    98,
    180,
    159,
    117,
    16,
    98,
    116,
    150,
    85,
    16,
    98,
    116,
    158,
    53,
    16,
    98,
    116,
    151,
    21,
    16,
    98,
    116,
    95,
    233,
    32,
    196,
    232,
    45,
    59,
    151,
    172,
    211,
    207,
    7,
    6,
    251,
    43,
    215,
    243,
    217,
    205,
    252,
    216,
    187,
    182,
    230,
    166,
    122,
    126,
    60,
    213,
    138,
    129,
    236,
    128,
    156,
    122,
    86,
    237,
    171,
    86,
    135,
    210,
    196,
    12,
    22,
    43,
    78,
    74,
    77,
    210,
    88,
    202,
    146,
    89,
    51,
    126,
    94,
    237,
    187,
    223,
    25,
    99,
    76,
    77,
    198,
    252,
    3,
    143,
    225,
    3,
    114,
    191,
    206,
    119,
    113,
    0,
    0,
    0,
    0,
    73,
    69,
    78,
    68,
    174,
    66,
    96,
    130
  ]

});
