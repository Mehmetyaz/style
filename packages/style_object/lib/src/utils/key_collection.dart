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

mixin KeyCollection<T> on StyleKey<T> {
  final Map<int, StyleKey> _keys = {};
  final Map<String, StyleKey> _keyTags = {};

  operator [](dynamic key) => key is String ? _keyTags[key] : _keys[key as int];

  StyleKey getKey(int key) {
    if (!_keys.containsKey(key)) {
      throw KeyNotFoundException(key: key);
    }
    return _keys[key]!;
  }

  StyleKey getKeyWithTag(String tag) {
    if (!_keyTags.containsKey(tag)) {
      throw KeyNotFoundException(tag: tag);
    }
    return _keyTags[tag]!;
  }

  Map getKeyTree() {
    return _keys.map((key, value) =>
        MapEntry(key, value is KeyCollection ? value.getKeyTree() : value));
  }

  Map getKeyTreeWithTags() {
    return _keys.map((key, value) => MapEntry(value.tag,
        value is KeyCollection ? value.getKeyTreeWithTags() : value));
  }

  KeyInfo toKeyInfo() {
    if (this is ListKey) {
      return KeyInfo(
          key: this,
          children: (_keys[-objectType] as ObjectKey?)?.toKeyInfo().children);
    }

    return KeyInfo(
        key: this,
        children: _keys.isEmpty
            ? null
            : _keys.values
                .map<KeyInfo>((value) => value is KeyCollection
                    ? value.toKeyInfo()
                    : KeyInfo(key: value))
                .toList());
  }

  void addChildren(List<KeyInfo> children) {
    for (var child in children) {
      addInfo(child);
    }
  }

  void addInfo(KeyInfo info) {
    if (this is ListKey) {
      _keys[-objectType] ??= ObjectKey(-objectType, "#");
      _keyTags["#"] ??= _keys[-objectType]!;
      return (_keys[-objectType] as ObjectKey).addInfo(info);
    }

    _keys[info.key.key] = info.key;
    _keyTags[info.key.tag] = info.key;

    if (info.children != null) {
      for (var c in info.children!) {
        (_keys[info.key.key] as KeyCollection).addInfo(c);
      }
    }
  }

  void addKey(StyleKey key) {
    _keys[key.key] = key;
    _keyTags[key.tag] = key;
  }

  void addKeys(List<StyleKey> keys) {
    for (var key in keys) {
      addKey(key);
    }
  }

  StyleKey readKey(ByteDataReader data) {
    return _keys[data.getUint16()]!;
  }
}
