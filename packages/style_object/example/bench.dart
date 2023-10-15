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
import 'dart:io';
import 'dart:typed_data';

import 'package:style_object/style_object.dart';

ByteData withByteData(ByteData data, List<int> value) {
  var b = data.buffer.asUint8List()
    ..setRange(0, value.length, Uint8List.fromList(value).buffer.asUint8List());
  return b.buffer.asByteData();
}

void withLoop(ByteData data, List<int> value) {
  var o = 0;
  for (var v in value) {
    data.setInt64(o, v);
    o++;
  }
}

void main() {
  test(true);
  test();
  test();
  test();
  test();
  test();
  test();
  test();
}

var count = 1000000;

void test([bool init = false]) {
  var a = A(
      count64: 4093001811601238970,
      count32: 14665414764,
      count16: 146654,
      enumV: MyEnum.c,
      boolV: true,
      bytes: utf8.encode("Styles") as Uint8List,
      string: "Style Object Created by Mehmet Yaz");

  var ii = 0;
  while (ii < 10) {
    var b = a.toBytes();
    A.fromBytes(b);
    ii++;
  }
  var bytes = a.toBytes();
  var jsonEncoded = utf8.encode(json.encode(a.toJson()));
  if (init) {
    stdout
      ..writeln("\n\n\nHow To Stored?")
      ..writeln("STYLE: Not human readable!")
      ..writeln("JSON: ${json.encode(a.toJson())}")
      ..writeln("\nHow Much Space?")
      ..writeln("style length : ${bytes.lengthInBytes}")
      ..writeln("json length: ${jsonEncoded.length}");
  }

  stdout
    ..writeln("\nHow Long To Encode? (dart object instance to bytes)")
    ..writeln("STYLE: ${toMicro(testStyleEncode(a))}  μs/object")
    ..writeln("JSON: ${toMicro(testJsonEncode(a))}  μs/object")
    ..writeln("\nHow Long To Decode?  (bytes to dart object instance)")
    ..writeln("STYLE: ${toMicro(testStyleDecode(bytes))}  μs/object")
    ..writeln(
        "JSON: ${toMicro(testJsonDecode(jsonEncoded as Uint8List))}  μs/object");
}

int testJsonEncode(A a) {
  var st = Stopwatch()..start();
  var i = 0;
  while (i < count) {
    utf8.encode(json.encode(a.toJson()));
    i++;
  }
  return st.elapsedMicroseconds;
}

int testStyleEncode(A a) {
  var st = Stopwatch()..start();
  var i = 0;
  while (i < count) {
    a.toBytes();
    i++;
  }
  return st.elapsedMicroseconds;
}

int testJsonDecode(Uint8List bytes) {
  var st = Stopwatch()..start();
  var i = 0;
  while (i < count) {
    A.fromJson(json.decode(utf8.decode(bytes)));
    i++;
  }
  return st.elapsedMicroseconds;
}

int testStyleDecode(Uint8List bytes) {
  var st = Stopwatch()..start();
  var i = 0;
  while (i < count) {
    A.fromBytes(bytes);
    i++;
  }
  return st.elapsedMicroseconds;
}

double toMicro(int elapsedMicro) {
  return ((elapsedMicro / count) * 10).floor() / 10;
}

class A {
  A(
      {required this.count64,
      required this.count32,
      required this.enumV,
      required this.boolV,
      required this.bytes,
      required this.string,
      required this.count16});

  factory A.fromJson(Map<String, dynamic> map) {
    return A(
        count64: map["count_64"],
        count32: map["count_32"],
        enumV: MyEnum.values[map["enumV"]],
        boolV: map["boolV"],
        bytes: (map["bytes"] as List<dynamic>).cast<int>(),
        string: map["string"],
        count16: map['count_16']);
  }

  factory A.fromBytes(Uint8List bytes) {
    var obj = decoder.convertWithKeys(bytes);
    return A(
        count64: obj[_count64.key],
        count32: obj[_count32.key],
        enumV: MyEnum.values[obj[_enum.key]],
        boolV: obj[_bool.key],
        bytes: obj[_bytes.key],
        string: obj[_string.key],
        count16: obj[_count16.key]);
  }

  static StyleObjectCodec codec = StyleObjectCodec(
      keyCollection: ObjectKey(0, "#")
        ..addKey(_count64)
        ..addKey(_count32)
        ..addKey(_enum)
        ..addKey(_bool)
        ..addKey(_bytes)
        ..addKey(_string)
        ..addKey(_count16));

  static StyleObjectEncoder encoder = codec.encoder;
  static StyleObjectDecoder decoder = codec.decoder;

  static final _count64 = Int64Key(1, "count_64");
  static final _count32 = Uint32Key(2, "count_32");
  static final _count16 = Int16Key(7, "count_16");
  static final _enum = Int8Key(3, "enumV");
  static final _bool = BoolKey(4, "boolV");
  static final _bytes = Uint8ListKey(5, "bytes", 6);
  static final _string = StringKey(6, "string", 34);

  Uint8List toBytes() => encoder.convert(StyleObjectAdvanced({
        _count64: Uint64Data(count64),
        _count32: Uint32Data(count32),
        _enum: Int8Data(enumV.index),
        _bool: BoolData(boolV),
        _bytes: Uint8ListData(bytes as Uint8List),
        _string: StringData(string),
        _count16: Int16Data(count16)
      }));

  Map<String, dynamic> toJson() => {
        "count_64": count64,
        "count_32": count32,
        "count_16": count16,
        "enumV": enumV.index,
        "boolV": boolV,
        "bytes": bytes,
        "string": string
      };

  int count64;
  int count32;
  int count16;
  MyEnum enumV;
  bool boolV;
  List<int> bytes;
  String string;
}

enum MyEnum { a, b, c, d }
