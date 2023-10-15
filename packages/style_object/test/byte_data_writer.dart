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

import 'dart:typed_data';

import 'package:style_object/src/style_object_base.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  var length = 1000;
  var controlBytes = List.generate(length, (index) => 0);
  ByteDataWriter writer = ByteDataWriter(length);
  int offset = 0;
  test("set byte", () {
    controlBytes[offset] = 10;
    writer.setUint8(10);
    testBytes(writer, controlBytes);
  });

  test("set bytes", () {
    offset = writer.offset;
    setBytes([10, 20, 30, 40], controlBytes, offset);
    writer.setBytes(Uint8List.fromList([10, 20, 30, 40]));
    testBytes(writer, controlBytes);
  });
}

void setBytes(List<int> data, List<int> controlBytes, int offset) {
  var e = offset + data.length;
  controlBytes.setRange(offset, e, data);
}

void testBytes(ByteDataWriter writer, List<int> controlBytes) {
  var byteList = writer.byteData.buffer.asUint8List().toList();
  expect(byteList, controlBytes);
}
