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

class KeyInfo {
  KeyInfo({required this.key, this.children});

  KeyInfo.root({this.children}) : key = ObjectKey(0, "#");

  factory KeyInfo.fromBytes(Uint8List list) {
    return KeyInfo.fromObject(_decoder.convert(list));
  }

  factory KeyInfo.fromObject(Map<String, dynamic> object) {
    return KeyInfo(
        children: (object[_listKey.tag] as List?)?.map((e) {
          return KeyInfo.fromBytes(e);
        }).toList(),
        key: _createStyleKey(
            object[_keyKey.tag]!,
            object[_tagKey.tag]!,
            object[_typeKey.tag],
            object[_fixedLengthKey.tag],
            object[_fixedTypeKey.tag]));
  }

  static StyleKey _createStyleKey(
      int key, String tag, int type, int? fixedLength, int? fixedType) {
    switch (type) {
      case boolType:
        return BoolKey(key, tag);
      case uInt8Type:
        return Uint8Key(key, tag);
      case int8Type:
        return Int8Key(key, tag);
      case uInt16Type:
        return Uint16Key(key, tag);
      case int16Type:
        return Int16Key(key, tag);
      case uInt32Type:
        return Uint32Key(key, tag);
      case int32Type:
        return Int32Key(key, tag);
      case int64Type:
        return Int64Key(key, tag);
      case uInt64Type:
        return Uint64Key(key, tag);
      case uint8ListType:
        return Uint8ListKey(key, tag, fixedLength);
      case int8ListType:
        return Int8ListKey(key, tag, fixedLength);
      case uint16ListType:
        return Uint16ListKey(key, tag, fixedLength);
      case int16ListType:
        return Int16ListKey(key, tag, fixedLength);
      case uint32ListType:
        return Uint32ListKey(key, tag, fixedLength);
      case int32ListType:
        return Int32ListKey(key, tag, fixedLength);
      case uint64ListType:
        return Uint64ListKey(key, tag, fixedLength);
      case int64ListType:
        return Int64ListKey(key, tag, fixedLength);
      case floatType:
        return Float32Key(key, tag);
      case doubleType:
        return DoubleKey(key, tag);
      case stringType:
        return StringKey(key, tag, fixedLength);
      case objectType:
        return ObjectKey(key, tag);
      case listType:
        return ListKey(key, tag, fixedType);
      case jsonType:
        return JsonKey(key, tag);
      default:
        throw Exception('Unknown type: $type');
    }
  }

  static final StyleObjectCodec _codec = StyleObjectCodec(
      keyCollection: ObjectKey.root(children: [
    KeyInfo(key: _keyKey),
    KeyInfo(key: _typeKey),
    KeyInfo(key: _fixedLengthKey),
    KeyInfo(key: _tagKey),
    KeyInfo(key: _listKey),
    KeyInfo(key: _fixedTypeKey),
  ]));
  static final StyleObjectEncoder _encoder = _codec.encoder;
  static final StyleObjectDecoder _decoder = _codec.decoder;

  static final Uint16Key _keyKey = Uint16Key(1, "key");
  static final Uint8Key _typeKey = Uint8Key(2, "type");
  static final ListKey _listKey = ListKey(3, "children", uint8ListType);
  static final Int64Key _fixedLengthKey = Int64Key(4, "fixedLength");
  static final Uint8Key _fixedTypeKey = Uint8Key(5, "fixedType");
  static final StringKey _tagKey = StringKey(6, "tag");

  StyleObjectAdvanced toObject() {
    return StyleObjectAdvanced({
      _keyKey: Uint16Data(key.key),
      _typeKey: Uint8Data(key.type),
      _tagKey: StringData(key.tag),
      if (children != null)
        _listKey: ListData(children!.map((c) => c.toBytes()).toList()),
      if (key.fixedLength != null)
        _fixedLengthKey: Uint64Data(key.fixedLength!),
      if (key is ListKey && (key as ListKey).fixedType != null)
        _fixedTypeKey: Uint8Data((key as ListKey).fixedType!),
    });
  }

  Uint8List toBytes() {
    return _encoder.convert(toObject());
  }

  final StyleKey key;
  final List<KeyInfo>? children;

//int? get fixedLength => key.fixedLength;
}
