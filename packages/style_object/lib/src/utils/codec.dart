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

part of style_object;

class StyleObjectCodec extends Codec<dynamic, Uint8List> {
  StyleObjectCodec({KeyCollection? keyCollection})
      : keyMapper = keyCollection ?? ObjectKey(0, "#");

  final KeyCollection keyMapper;

  @override
  StyleObjectDecoder get decoder => StyleObjectDecoder(keyMapper);

  @override
  StyleObjectEncoder get encoder => StyleObjectEncoder(keyMapper);
}

class StyleObjectEncoder extends Converter<StyleObject, Uint8List> {
  const StyleObjectEncoder(this.keyMapper);

  final KeyCollection keyMapper;

  ObjectKey get rootKey => keyMapper as ObjectKey;

  @override
  Uint8List convert(StyleObject input) {
    var bytes = ByteDataWriter(input.getLength(rootKey) + k16BitLength);
    input.write(bytes, rootKey, true);
    return bytes.byteData.buffer.asUint8List();
  }
}

class StyleObjectDecoder extends Converter<Uint8List, Map<String, dynamic>> {
  const StyleObjectDecoder(this.keyMapper);

  final KeyCollection keyMapper;

  ObjectKey get rootKey => keyMapper as ObjectKey;

  Map<int, dynamic> convertWithKeys(Uint8List input) {
    var reader = ByteDataReader(input);
    var read = rootKey.readWithKeys(reader);
    return read.cast<int, Object>();
  }

  @override
  Map<String, dynamic> convert(Uint8List input) {
    var reader = ByteDataReader(input);
    var read = rootKey.read(reader);
    return read.cast<String, Object>();
  }
}
