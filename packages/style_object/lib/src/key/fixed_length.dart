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

abstract class FixedLengthKey<T> extends StyleKey<T> {
  const FixedLengthKey(super.key, super.tag);

  @override
  KeyMetaRead readMeta(ByteDataReader data) {
    throw ArgumentError("There is no meta for fixed length key");
  }

  @override
  T read(ByteDataReader byteData) {
    return readFixed(byteData);
  }

  T readFixed(ByteDataReader byteData);
}

class BoolKey extends FixedLengthKey<bool> {
  const BoolKey(super.key, super.tag);

  @override
  bool readFixed(ByteDataReader byteData) {
    return byteData.getBool();
  }

  @override
  int? get fixedLength => kByteLength;

  @override
  int get type => boolType;
}

class Int8Key extends FixedLengthKey<int> {
  const Int8Key(super.key,super.tag);

  @override
  int readFixed(ByteDataReader byteData) {
    return byteData.getInt8();
  }

  @override
  int? get fixedLength => kByteLength;

  @override
  int get type => int8Type;
}

class Uint8Key extends FixedLengthKey<int> {
  const Uint8Key(super.key,super.tag);

  @override
  int readFixed(ByteDataReader byteData) {
    return byteData.getUint8();
  }

  @override
  int? get fixedLength => kByteLength;

  @override
  int get type => uInt8Type;
}

class Int16Key extends FixedLengthKey<int> {
  const Int16Key(super.key,super.tag  );

  @override
  int readFixed(ByteDataReader byteData) {
    return byteData.getInt16();
  }

  @override
  int? get fixedLength => k16BitLength;

  @override
  int get type => int16Type;
}

class Uint16Key extends FixedLengthKey<int> {
  const Uint16Key(super.key,super.tag);

  @override
  int readFixed(ByteDataReader byteData) {
    return byteData.getUint16();
  }

  @override
  int? get fixedLength => k16BitLength;

  @override
  int get type => uInt16Type;
}

class Int32Key extends FixedLengthKey<int> {
  const Int32Key(super.key,super.tag);

  @override
  int readFixed(ByteDataReader byteData) {
    return byteData.getInt32();
  }

  @override
  int? get fixedLength => k32BitLength;

  @override
  int get type => int32Type;
}

class Uint32Key extends FixedLengthKey<int> {
  const Uint32Key(super.key,super.tag);

  @override
  int readFixed(ByteDataReader byteData) {
    return byteData.getUint32();
  }

  @override
  int? get fixedLength => k32BitLength;

  @override
  int get type => uInt32Type;
}

class Int64Key extends FixedLengthKey<int> {
  const Int64Key(super.key,super.tag);

  @override
  int readFixed(ByteDataReader byteData) {
    return byteData.getInt64();
  }

  @override
  int? get fixedLength => k64BitLength;

  @override
  int get type => int64Type;
}

class Uint64Key extends FixedLengthKey<int> {
  const Uint64Key(super.key,super.tag);

  @override
  int readFixed(ByteDataReader byteData) {
    return byteData.getUint64();
  }

  @override
  int? get fixedLength => k64BitLength;

  @override
  int get type => uInt64Type;
}

class DoubleKey extends FixedLengthKey<double> {
  DoubleKey(super.key,super.tag);

  @override
  double readFixed(ByteDataReader byteData) {
    return byteData.getFloat64();
  }

  @override
  int? get fixedLength => k64BitLength;

  @override
  int get type => doubleType;
}

class Float32Key extends FixedLengthKey<double> {
  Float32Key(super.key,super.tag);

  @override
  double readFixed(ByteDataReader byteData) {
    return byteData.getFloat32();
  }

  @override
  int? get fixedLength => k32BitLength;

  @override
  int get type => floatType;
}
