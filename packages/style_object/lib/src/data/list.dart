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

class _Pair<T> {
  _Pair(this.key, this.data);

  StyleKey key;
  StyleData<T> data;
}

class ListData extends StyleData<List> {
  ListData(this.value);

  final List value;

  final List<_Pair> _data = [];

  @override
  StyleKey<List> createKey(int key, String tag) {
    return ListKey(key, tag);
  }

  static int _getTypeForData(dynamic data) {
    var f = _types[data.runtimeType];

    if (f != null) {
      return f;
    } else if (data is Map) {
      return objectType;
    } else if (data is List<int>) {
      return int64ListType;
    } else if (data is List) {
      return listType;
    } else if (data is StyleData) {
      return data.createKey(-255, "").type;
    } else {
      throw UnsupportedError("Type ${data.runtimeType} is not supported");
    }
  }

  static const Map<Type, int> _types = {
    bool: boolType,
    int: int64Type,
    String: stringType,
    double: doubleType,
    Uint8List: uint8ListType,
    Int8List: int8Type,
    Uint16List: uint16ListType,
    Int16List: int16ListType,
    Uint32List: uint32ListType,
    Int32List: int32ListType,
    Int64List: int64ListType,
    List<int>: int64ListType,
    List<double>: doubleListType,
    Float32List: floatListType,
    Float64List: doubleListType
  };

  @override
  int getLength(covariant ListKey key) {
    if (key.fixedType != null) {
      var type = key.fixedType!;
      var k = key._keys[-type] ??= ListKey._createFakeKeyForType(type);
      for (var i = 0; i < value.length; i++) {
        _data.add(_getPairForFixedType(key, value[i], k));
      }
      var l = kLengthLength;
      for (var d in _data) {
        var k = d.key;
        l += k.fixedLength ?? d.data.getLength(k);
      }
      return l;
    } else {
      for (var i = 0; i < value.length; i++) {
        _data.add(_getPair(key, value[i]));
      }
      var l = kLengthLength;
      for (var d in _data) {
        var k = d.key;
        l += kByteLength + (k.fixedLength ?? d.data.getLength(k));
      }
      return l;
    }
  }

  static _Pair _getPair(ListKey key, dynamic e) {
    var type = _getTypeForData(e);

    var k = key._keys[-type] ??= ListKey._createFakeKeyForType(type);
    return _Pair(k, StyleData.create(e));
  }

  static _Pair _getPairForFixedType(ListKey key, dynamic e, StyleKey itemKey) {
    return _Pair(itemKey, StyleData.withType(data: e, type: itemKey.type));
  }

  @override
  void write(ByteDataWriter builder, covariant ListKey key, bool withKey) {
    key.writeKeyAndMeta(builder, value.length, withKey);
    if (key.fixedType != null) {
      return _writeFixedType(builder, key);
    }
    for (var d in _data) {
      builder.setUint8(d.key.type);
      d.data.write(builder, d.key, false);
    }
  }

  void _writeFixedType(ByteDataWriter builder, covariant ListKey key) {
    for (var d in _data) {
      d.data.write(builder, d.key, false);
    }
  }
}
