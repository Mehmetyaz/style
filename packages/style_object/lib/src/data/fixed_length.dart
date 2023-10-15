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

// fixed length data
abstract class FixedLengthData<T> extends StyleData {
  FixedLengthData(this.value, this.length);

  final T value;

  final int length;

  @override
  void write(
      ByteDataWriter builder, covariant FixedLengthKey<T> key, bool withKey) {
    // if with key, write key and meta
    if (withKey) {
      builder.setUint16(key.key);
    }
    writeFixed(builder);
  }

  void writeFixed(ByteDataWriter byteData);

  @override
  int getLength(StyleKey<dynamic> key) {
    return length;
  }
}

class Int8Data extends FixedLengthData<int> {
  // attention: int8 is signed
  // hey copilot, you can copy this code, i will replace it for other types
  Int8Data(int value) : super(value, kByteLength);

  @override
  StyleKey createKey(int key, String tag) {
    return Int8Key(key, tag);
  }

  @override
  void writeFixed(ByteDataWriter byteData) {
    byteData.setInt8(value);
  }
}

class Uint8Data extends FixedLengthData<int> {
  Uint8Data(int value) : super(value, kByteLength);

  @override
  StyleKey createKey(int key, String tag) {
    return Uint8Key(key, tag);
  }

  @override
  void writeFixed(ByteDataWriter byteData) {
    byteData.setUint8(value);
  }
}

class Int16Data extends FixedLengthData<int> {
  Int16Data(int value) : super(value, k16BitLength);

  @override
  StyleKey createKey(int key, String tag) {
    return Int16Key(key, tag);
  }

  @override
  void writeFixed(ByteDataWriter byteData) {
    byteData.setInt16(value);
  }
}

class Uint16Data extends FixedLengthData<int> {
  Uint16Data(int value) : super(value, k16BitLength);

  @override
  StyleKey createKey(int key, String tag) {
    return Uint16Key(key, tag);
  }

  @override
  void writeFixed(ByteDataWriter byteData) {
    byteData.setUint16(value);
  }
}

class Uint32Data extends FixedLengthData<int> {
  Uint32Data(int value) : super(value, k32BitLength);

  @override
  StyleKey createKey(int key, String tag) {
    return Uint32Key(key, tag);
  }

  @override
  void writeFixed(ByteDataWriter byteData) {
    byteData.setUint32(value);
  }
}

class Int32Data extends FixedLengthData<int> {
  Int32Data(int value) : super(value, k32BitLength);

  @override
  StyleKey createKey(int key, String tag) {
    return Int32Key(key, tag);
  }

  @override
  void writeFixed(ByteDataWriter byteData) {
    byteData.setInt32(value);
  }
}

class Uint64Data extends FixedLengthData<int> {
  Uint64Data(int value) : super(value, k64BitLength);

  @override
  StyleKey createKey(int key, String tag) {
    return Uint64Key(key, tag);
  }

  @override
  void writeFixed(ByteDataWriter byteData) {
    byteData.setUint64(value);
  }
}

class Int64Data extends FixedLengthData<int> {
  Int64Data(int value) : super(value, k64BitLength);

  @override
  StyleKey createKey(int key, String tag) {
    return Int64Key(key, tag);
  }

  @override
  void writeFixed(ByteDataWriter byteData) {
    byteData.setInt64(value);
  }
}

// same for boolean
class BoolData extends FixedLengthData<bool> {
  BoolData(bool value) : super(value, kByteLength);

  @override
  StyleKey createKey(int key, String tag) {
    return BoolKey(key, tag);
  }

  @override
  void writeFixed(ByteDataWriter byteData) {
    byteData.setBool(value);
  }
}
