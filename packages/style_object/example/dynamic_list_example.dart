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

import 'dart:convert';

import 'package:style_object/style_object.dart';

void main() async {
  var codec = StyleObjectCodec(
      keyCollection: ObjectKey.root(children: [
    KeyInfo(key: ListKey(1, "map_val", objectType), children: [
      KeyInfo(
        key: StringKey(2, "name"),
      ),
    ]),
    KeyInfo(key: StringKey(4, "string_val")),
    KeyInfo(key: Uint16Key(5, "uint16_val")),
    KeyInfo(key: ObjectKey(6, "map_val2"), children: [
      KeyInfo(key: Int64Key(100, 'int_val')),
      KeyInfo(key: Int64Key(200, 'int_val2')),
    ]),
    KeyInfo(key: JsonKey(10, "json_val")),
    KeyInfo(key: Uint8ListKey(11, "uint8_list_val")),
    KeyInfo(key: Uint8ListKey(12, "uint8_list_val2")),
    KeyInfo(key: Uint8Key(13, "uint8_val")),
  ]));

  //print(codec.keyMapper.getKeyTreeWithTags());
  var info = (codec.keyMapper.toKeyInfo());

  var infoBytes = info.toBytes();
  var info2 = KeyInfo.fromBytes(infoBytes);

  var sCodec = StyleObjectCodec(keyCollection: ObjectKey.fromInfo(info2));

  //print(sCodec.keyMapper.getKeyTreeWithTags());

  var d = StyleObjectDynamic({
    "map_val": [
      {"name": "Ali"},
      {"name": "Veli"},
      {"name": "Can"},
    ],
    "string_val": "String 4",
    "uint16_val": 6,
    "map_val2": {
      "int_val": 1500,
      "int_val2": 1800,
    },
    // "json_val": {
    //   "name": "Mehmet",
    //   "surname": "Yaz",
    //   "age": 30,
    // },
    "uint8_list_val": [156, 56, 118, 4, 5, 85, 60, 8, 185, 10],
    "uint8_list_val2": [1, 2, 3, 4, 5, 6, 7, 84, 98, 100],
    "uint8_val": 115,
  });

  var bytes = sCodec.encoder.convert(d);

  print(bytes.buffer.asUint8List().length);
  print(utf8
      .encode(json.encode({
        "map_val": [
          {"name": "Ali"},
          {"name": "Veli"},
          {"name": "Can"},
        ],
        "string_val": "String 4",
        "uint16_val": 6,
        "map_val2": {
          "int_val": 1500,
          "int_val2": 1800,
        },
        // "json_val": {
        //   "name": "Mehmet",
        //   "surname": "Yaz",
        //   "age": 30,
        // },
        "uint8_list_val": [156, 56, 118, 4, 5, 85, 60, 8, 185, 10],
        "uint8_list_val2": [1, 2, 3, 4, 5, 6, 7, 84, 98, 100],
        "uint8_val": 115,
      }))
      .length);

  var res = sCodec.decoder.convert(bytes);
  print(res);
}
