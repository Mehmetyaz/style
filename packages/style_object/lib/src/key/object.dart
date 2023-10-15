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

class ObjectKey extends StyleKey<Map> with KeyCollection {
  ObjectKey(super.key, super.tag);

  ObjectKey.root({List<KeyInfo>? children}) : super(0, "#") {
    if (children != null) {
      addChildren(children);
    }
  }

  ObjectKey.fromInfo(KeyInfo info) : super(info.key.key, info.key.tag) {
    if (info.children != null) {
      for (var child in info.children!) {
        addInfo(child);
      }
    }
  }

  @override
  int? get fixedLength => null;

  @override
  Map<String, dynamic> read(ByteDataReader byteData) {
    var readCount = 0;
    var map = <String, dynamic>{};
    var meta = readMeta(byteData) as ObjectKeyMeta;
    while (readCount < meta.entryCount) {
      var entryKey = readKey(byteData);
      var dataRead = entryKey.read(byteData);
      map[entryKey.tag] = dataRead;
      readCount++;
    }
    return map;
  }

  Map<int, dynamic> readWithKeys(ByteDataReader byteData) {
    var readCount = 0;
    var map = <int, dynamic>{};
    var meta = readMeta(byteData) as ObjectKeyMeta;
    while (readCount < meta.entryCount) {
      var entryKey = readKey(byteData);
      var dataRead = entryKey.read(byteData);
      map[entryKey.key] = dataRead;
      readCount++;
    }
    return map;
  }

  @override
  KeyMetaRead readMeta(ByteDataReader data) {
    return ObjectKeyMeta(data.getUint16());
  }

  void writeKeyAndMeta(ByteDataWriter builder, int count, bool withKey) {
    if (withKey) {
      builder.setUint16(key);
    }

    builder.setUint16(count);
  }

  @override
  int get type => objectType;
}
