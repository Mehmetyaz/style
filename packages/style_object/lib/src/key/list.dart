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

class ListKey extends StyleKey<List> with KeyCollection {
  ListKey(super.key, super.tag, [this.fixedType]);

  @override
  int? get fixedLength => null;

  int? fixedType;

  @override
  List read(ByteDataReader byteData) {
    var listMeta = readMeta(byteData);
    if (fixedType != null) {
      return _readFixedType(byteData, listMeta.count);
    }
    var list = [];
    while (list.length < listMeta.count) {
      var k = byteData.getUint8();
      var key = _keys[-k] ??= _createFakeKeyForType(k, null, fixedType);
      var o = key.read(byteData);
      list.add(o);
    }
    return list;
  }

  List _readFixedType(ByteDataReader byteData, int count) {
    var list = [];
    var key = _keys[-fixedType!] ??=
        _createFakeKeyForType(fixedType!, null, fixedType);
    while (list.length < count) {
      var o = key.read(byteData);
      list.add(o);
    }
    return list;
  }

  @override
  ListMeta readMeta(ByteDataReader data) {
    var count = data.getUint16();
    return ListMeta(count);
  }

  void writeKeyAndMeta(ByteDataWriter builder, int count, bool withKey) {
    if (withKey) {
      builder.setUint16(key);
    }
    builder.setUint16(count);
  }

  static StyleKey _createFakeKeyForType(int type,
      [int? fixedCount, int? fixedType]) {
    return _typeKeys[type]!.call(fixedCount, fixedType);
  }

  static final Map<int, StyleKey Function(int? fixedLength, int? fixedType)>
      _typeKeys = {
    boolType: (f, t) => BoolKey(-boolType, ""),
    uInt8Type: (f, t) => Uint8Key(-uInt8Type, ""),
    int8Type: (f, t) => Int8Key(-int8Type, ""),
    uInt16Type: (f, t) => Uint16Key(-uInt16Type, ""),
    int16Type: (f, t) => Int16Key(-int16Type, ""),
    uInt32Type: (f, t) => Uint32Key(-uInt32Type, ""),
    int32Type: (f, t) => Int32Key(-int32Type, ""),
    int64Type: (f, t) => Int64Key(-int64Type, ""),
    uInt64Type: (f, t) => Uint64Key(-uInt64Type, ""),

    // typed data
    uint8ListType: (f, t) => Uint8ListKey(-uint8ListType, "", f),
    int8ListType: (f, t) => Int8ListKey(-int8ListType, "", f),
    uint16ListType: (f, t) => Uint16ListKey(-uint16ListType, "", f),
    int16ListType: (f, t) => Int16ListKey(-int16ListType, "", f),
    uint32ListType: (f, t) => Uint32ListKey(-uint32ListType, "", f),
    int32ListType: (f, t) => Int32ListKey(-int32ListType, "", f),
    uint64ListType: (f, t) => Uint64ListKey(-uint64ListType, "", f),
    int64ListType: (f, t) => Int64ListKey(-int64ListType, "", f),

    floatListType: (f, t) => Float32ListKey(-floatListType, "", fixedCount: f),
    doubleListType: (f, t) => Float64ListKey(-doubleListType, "", f),

    floatType: (f, t) => Float32Key(-floatType, ""),
    doubleType: (f, t) => DoubleKey(-doubleType, ""),

    // generated
    stringType: (f, t) => StringKey(-stringType, "", f),

    // structures
    objectType: (f, t) => ObjectKey(-objectType, ""),
    listType: (f, t) => ListKey(-listType, "", t),
    jsonType: (f, t) => JsonKey(-jsonType, ""),
  };

  @override
  int get type => listType;
}
