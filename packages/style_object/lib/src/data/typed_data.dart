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

abstract class StyleTypedData<N extends num, T extends List<N>>
    extends StyleData<T> {
  StyleTypedData(this.itemLength, this.value);

  int itemLength;

  final List<N> value;

  @override
  int getLength(covariant TypedDataKey<T> key) =>
      (value.length * itemLength) +
      (key.fixedCount == null ? kLengthLength : 0);

  void writeItem(ByteDataWriter data, N value);

  @override
  void write(
      ByteDataWriter builder, covariant TypedDataKey<T> key, bool withKey) {
    if (withKey) {
      builder.setUint16(key.key);
    }

    if (key.fixedCount == null) {
      builder.setUint16(value.length);
    }
    for (var v in value) {
      writeItem(builder, v);
    }
  }
}

class Uint8ListData extends StyleTypedData<int, Uint8List> {
  Uint8ListData(Uint8List value) : super(kByteLength, value);

  @override
  StyleKey createKey(int key, String tag) {
    return Uint8ListKey(key,tag);
  }

  @override
  void writeItem(ByteDataWriter data, int value) {
    data.setUint8(value);
  }
}

class Int8ListData extends StyleTypedData<int, Int8List> {
  Int8ListData(List<int> value) : super(kByteLength, value);

  @override
  TypedDataKey<Int8List> createKey(int key, String tag) {
    return Int8ListKey(key,tag);
  }

  @override
  void writeItem(ByteDataWriter data, int value) {
    data.setInt8(value);
  }
}

class Uint16ListData extends StyleTypedData<int, Uint16List> {
  Uint16ListData(List<int> value) : super(k16BitLength, value);

  @override
  TypedDataKey<Uint16List> createKey(int key, String tag) {
    return Uint16ListKey(key,tag);
  }

  @override
  void writeItem(ByteDataWriter data, int value) {
    data.setUint16(value);
  }
}

class Int16ListData extends StyleTypedData<int, Int16List> {
  Int16ListData(Int16List value) : super(k16BitLength, value);

  @override
  TypedDataKey<Int16List> createKey(int key, String tag) {
    return Int16ListKey(key,tag);
  }

  @override
  void writeItem(ByteDataWriter data, int value) {
    data.setInt16(value);
  }
}

class Uint32ListData extends StyleTypedData<int, Uint32List> {
  Uint32ListData(List<int> value) : super(k32BitLength, value);

  @override
  TypedDataKey<Uint32List> createKey(int key, String tag) {
    return Uint32ListKey(key,tag);
  }

  @override
  void writeItem(ByteDataWriter data, int value) {
    data.setUint32(value);
  }
}

class Int32ListData extends StyleTypedData<int, Int32List> {
  Int32ListData(List<int> value) : super(k32BitLength, value);

  @override
  TypedDataKey<Int32List> createKey(int key, String tag) {
    return Int32ListKey(key,tag);
  }

  @override
  void writeItem(ByteDataWriter data, int value) {
    data.setInt32(value);
  }
}

class Int64ListData extends StyleTypedData<int, Int64List> {
  Int64ListData(List<int> value) : super(k64BitLength, value);

  @override
  TypedDataKey<Int64List> createKey(int key, String tag) {
    return Int64ListKey(key,tag);
  }

  @override
  void writeItem(ByteDataWriter data, int value) {
    data.setInt64(value);
  }
}

class Uint64ListData extends StyleTypedData<int, Uint64List> {
  Uint64ListData(List<int> value) : super(k64BitLength, value);

  @override
  TypedDataKey<Uint64List> createKey(int key, String tag) {
    return Uint64ListKey(key,tag);
  }

  @override
  void writeItem(ByteDataWriter data, int value) {
    data.setUint64(value);
  }
}
