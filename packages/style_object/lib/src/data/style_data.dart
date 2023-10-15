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

// class DataRead<T> {
//   DataRead({required this.data});
//
//   T data;
//
// }

abstract class StyleData<T> {
  StyleData();

  factory StyleData.withType({required Object? data, required int type}) {
    switch (type) {
      case boolType:
        return BoolData(data as bool) as StyleData<T>;
      case uInt8Type:
        return Uint8Data(data as int) as StyleData<T>;
      case int8Type:
        return Int8Data(data as int) as StyleData<T>;
      case uInt16Type:
        return Uint16Data(data as int) as StyleData<T>;
      case int16Type:
        return Int16Data(data as int) as StyleData<T>;
      case uInt32Type:
        return Uint32Data(data as int) as StyleData<T>;
      case int32Type:
        return Int32Data(data as int) as StyleData<T>;
      case uInt64Type:
        return Uint64Data(data as int) as StyleData<T>;
      case int64Type:
        return Int64Data(data as int) as StyleData<T>;
      case uint8ListType:
        return Uint8ListData(Uint8List.fromList(data as List<int>))
            as StyleData<T>;
      case int8ListType:
        return Int8ListData(data as Int8List) as StyleData<T>;
      case uint16ListType:
        return Uint16ListData(data as Uint16List) as StyleData<T>;
      case int16ListType:
        return Int16ListData(data as Int16List) as StyleData<T>;
      case uint32ListType:
        return Uint32ListData(data as Uint32List) as StyleData<T>;
      case int32ListType:
        return Int32ListData(data as Int32List) as StyleData<T>;
      case uint64ListType:
        return Uint64ListData(data as Uint64List) as StyleData<T>;
      case int64ListType:
        return Int64ListData(data as Int64List) as StyleData<T>;
      case stringType:
        return StringData(data as String) as StyleData<T>;
      case objectType:
        return StyleObjectDynamic(data as Map<Object, dynamic>) as StyleData<T>;
      case listType:
        return ListData(data as List) as StyleData<T>;
      case jsonType:
        return JsonData(data) as StyleData<T>;
      default:
        throw Exception('Unknown type: $type');
    }
  }

  factory StyleData.create(Object? value) {
    if (value is StyleData) {
      return value as StyleData<T>;
    } else if (value is int) {
      return Uint64Data(value) as StyleData<T>;
    } else if (value is bool) {
      return BoolData(value) as StyleData<T>;
    } else if (value is String) {
      return StringData(value) as StyleData<T>;
    } else if (value is Map) {
      if (value is Map<int, StyleData>) {
        return StyleObjectWithKeys(value) as StyleData<T>;
      } else if (value is Map<String, StyleData>) {
        return StyleObjectDynamic(value) as StyleData<T>;
      } else if (value is Map<Object, StyleData>) {
        return StyleObjectDynamic(value) as StyleData<T>;
      } else if (value is Map<Object, dynamic>) {
        return StyleObjectDynamic(value) as StyleData<T>;
      } else {
        throw UnimplementedError();
      }
    } else if (value is List) {
      if (value is List<int>) {
        return Int64ListData(value) as StyleData<T>;
      } else if (value is List<double>) {
        throw UnimplementedError();
      } else {
        return ListData(value) as StyleData<T>;
      }
    }

    throw 0;
  }

  int getLength(StyleKey<T> key);

  void write(ByteDataWriter builder, StyleKey<T> key, bool withKey);

  StyleKey createKey(int key, String tag);
}
