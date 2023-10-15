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

abstract class TypedDataKey<T> extends StyleKey<T> {
  const TypedDataKey(this.itemLength, super.key, super.tag, {this.fixedCount});

  final int itemLength;

  final int? fixedCount;

  @override
  int? get fixedLength => fixedCount != null ? fixedCount! * itemLength : null;

  T readItems(ByteDataReader byteData);

  @override
  T read(ByteDataReader byteData) {
    return readItems(byteData);
  }

  @override
  TypedDataMeta readMeta(ByteDataReader data) {
    if (fixedCount != null) {
      return TypedDataMeta(fixedCount!);
    } else {
      return TypedDataMeta(data.getUint16());
    }
  }
}

// create float32list key
class Float32ListKey extends TypedDataKey<Float32List> {
  const Float32ListKey(int key, String tag, {int? fixedCount})
      : super(k32BitLength, key, tag, fixedCount: fixedCount);

  @override
  Float32List readItems(ByteDataReader byteData) {
    var listMeta = readMeta(byteData);
    var list = Float32List(listMeta.count);

    var i = 0;
    while (i < listMeta.count) {
      list[i] = byteData.getFloat32();
      i++;
    }
    return list;
  }

  @override
  int get type => floatListType;
}

// create float64list key
class Float64ListKey extends TypedDataKey<Float64List> {
  const Float64ListKey(int key, String tag, [int? fixedCount])
      : super(k64BitLength, key, tag, fixedCount: fixedCount);

  @override
  Float64List readItems(ByteDataReader byteData) {
    var listMeta = readMeta(byteData);
    var list = Float64List(listMeta.count);

    var i = 0;
    while (i < listMeta.count) {
      list[i] = byteData.getFloat64();
      i++;
    }
    return list;
  }

  @override
  int get type => doubleListType;
}

class Uint8ListKey extends TypedDataKey<Uint8List> {
  const Uint8ListKey(int key, String tag, [int? fixedCount])
      : super(kByteLength, key, tag, fixedCount: fixedCount);

  @override
  Uint8List readItems(ByteDataReader byteData) {
    var listMeta = readMeta(byteData);
    var list =
        byteData.byteData.buffer.asUint8List(byteData.offset, listMeta.count);
    byteData.offset = byteData.offset + listMeta.count;
    return list;
  }

  @override
  int get type => uint8ListType;
}

class Int8ListKey extends TypedDataKey<Int8List> {
  const Int8ListKey(int key, String tag, [int? fixedCount])
      : super(kByteLength, key, tag, fixedCount: fixedCount);

  @override
  Int8List readItems(ByteDataReader byteData) {
    var listMeta = readMeta(byteData);
    var list =
        byteData.byteData.buffer.asInt8List(byteData.offset, listMeta.count);
    byteData.offset = byteData.offset + listMeta.count;
    return list;
  }

  @override
  int get type => int8ListType;
}

class Uint16ListKey extends TypedDataKey<Uint16List> {
  const Uint16ListKey(int key, String tag, [int? fixedCount])
      : super(k16BitLength, key, tag, fixedCount: fixedCount);

  @override
  Uint16List readItems(ByteDataReader byteData) {
    var listMeta = readMeta(byteData);
    var list = Uint16List(listMeta.count);

    var i = 0;
    while (i < listMeta.count) {
      list[i] = (byteData.getUint16());
      i++;
    }
    return list;
  }

  @override
  int get type => uint16ListType;
}

class Int16ListKey extends TypedDataKey<Int16List> {
  const Int16ListKey(int key, String tag, [int? fixedCount])
      : super(k16BitLength, key, tag, fixedCount: fixedCount);

  @override
  Int16List readItems(ByteDataReader byteData) {
    var listMeta = readMeta(byteData);
    var list = Int16List(listMeta.count);
    var i = 0;
    while (i < listMeta.count) {
      list[i] = (byteData.getInt16());
      i++;
    }
    return list;
  }

  @override
  int get type => int16ListType;
}

class Int32ListKey extends TypedDataKey<Int32List> {
  const Int32ListKey(int key, String tag, [int? fixedCount])
      : super(k32BitLength, key, tag, fixedCount: fixedCount);

  @override
  Int32List readItems(ByteDataReader byteData) {
    var listMeta = readMeta(byteData);
    var list = Int32List(listMeta.count);

    var i = 0;
    while (i < listMeta.count) {
      list[i] = (byteData.getInt32());
      i++;
    }
    return list;
  }

  @override
  int get type => int32ListType;
}

class Uint32ListKey extends TypedDataKey<Uint32List> {
  const Uint32ListKey(int key, String tag, [int? fixedCount])
      : super(k32BitLength, key, tag, fixedCount: fixedCount);

  @override
  Uint32List readItems(ByteDataReader byteData) {
    var listMeta = readMeta(byteData);
    var list = Uint32List(listMeta.count);

    var i = 0;
    while (i < listMeta.count) {
      list[i] = (byteData.getUint32());
      i++;
    }
    return list;
  }

  @override
  int get type => uint32ListType;
}

class Int64ListKey extends TypedDataKey<Int64List> {
  const Int64ListKey(int key, String tag, [int? fixedCount])
      : super(k64BitLength, key, tag, fixedCount: fixedCount);

  @override
  Int64List readItems(ByteDataReader byteData) {
    var listMeta = readMeta(byteData);
    var list = Int64List(listMeta.count);

    var i = 0;
    while (i < listMeta.count) {
      list[i] = (byteData.getInt64());
      i++;
    }
    return list;
  }

  @override
  int get type => int64ListType;
}

class Uint64ListKey extends TypedDataKey<Uint64List> {
  const Uint64ListKey(int key, String tag, [int? fixedCount])
      : super(k64BitLength, key, tag, fixedCount: fixedCount);

  @override
  Uint64List readItems(ByteDataReader byteData) {
    var listMeta = readMeta(byteData);
    var list = Uint64List(listMeta.count);

    var i = 0;
    while (i < listMeta.count) {
      list[i] = (byteData.getUint64());
      i++;
    }
    return list;
  }

  @override
  int get type => uint64ListType;
}
