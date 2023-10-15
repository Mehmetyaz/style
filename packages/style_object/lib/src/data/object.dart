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

abstract class StyleObject extends StyleData<Map> {
  StyleObject._();

  factory StyleObject(Map value) => StyleObjectDynamic(value);

  factory StyleObject.withKeys(Map<int, StyleData> value) =>
      StyleObjectWithKeys(value);

  factory StyleObject.withTags(Map<String, StyleData> value) =>
      StyleObjectWithTags(value);

  factory StyleObject.advanced(Map<StyleKey, StyleData> value) =>
      StyleObjectAdvanced(value);

  final Map<StyleKey, StyleData> _data = {};

  void setData(ObjectKey keyMapper);

  @override
  void write(ByteDataWriter builder, covariant ObjectKey key, bool withKey) {
    if (withKey) {
      builder.setUint16(key.key);
    }

    builder.setUint16(_data.length);

    for (var d in _data.entries) {
      d.value.write(builder, d.key, true);
    }
  }

  @override
  ObjectKey createKey(int key, String tag) {
    return ObjectKey(key, tag);
  }

  @override
  int getLength(covariant ObjectKey key) {
    setData(key);

    var len = kLengthLength;

    for (var d in _data.entries) {
      len += kKeyLength + (d.key.fixedLength ?? d.value.getLength(d.key));
    }
    return len;
  }
}

class StyleObjectAdvanced extends StyleObject {
  StyleObjectAdvanced(this.map) : super._();

  final Map<StyleKey, StyleData> map;

  @override
  Map<StyleKey, StyleData<dynamic>> get _data => map;

  @override
  void setData(ObjectKey keyMapper) {
    return;
  }
}

class StyleObjectDynamic extends StyleObject {
  StyleObjectDynamic(this.map) : super._();

  final Map map;

  @override
  void setData(ObjectKey keyMapper) {
    map.forEach((key, value) {
      StyleKey k;
      if (key is int) {
        k = keyMapper.getKey(key);
      } else if (key is String) {
        k = keyMapper.getKeyWithTag(key);
      } else {
        k = key as StyleKey;
      }
      StyleData v = StyleData.withType(data: value, type: k.type);

      _data[k] = v;
    });
  }
}

class StyleObjectWithData extends StyleObject {
  StyleObjectWithData(this.map) : super._();

  final Map<int, StyleData> map;

  @override
  void setData(ObjectKey keyMapper) {
    map.forEach((key, value) {
      _data[keyMapper.getKey(key)] = value;
    });
    return;
  }
}

class StyleObjectWithTags extends StyleObject {
  StyleObjectWithTags(this.map) : super._();

  final Map<String, StyleData> map;

  @override
  void setData(ObjectKey keyMapper) {
    for (var kv in map.entries) {
      _data[keyMapper.getKeyWithTag(kv.key)] = kv.value;
    }
    return;
  }
}

class StyleObjectWithKeys extends StyleObject {
  StyleObjectWithKeys(this.map) : super._();

  final Map<int, StyleData> map;

  @override
  void setData(ObjectKey keyMapper) {
    for (var kv in map.entries) {
      _data[keyMapper.getKey(kv.key)] = kv.value;
    }
    return;
  }
}
