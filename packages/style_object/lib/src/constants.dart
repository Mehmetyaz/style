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

const int kKeyLength = 2;
const int kObjectMetaLength = 4;
const int kDynamicListMetaKey = 4;
const int kByteLength = 1;

const int kLengthLength = 2;
const int k16BitLength = 2;
const int k32BitLength = 4;
const int k64BitLength = 8;

const int nullType = 0;
const int boolType = 1;
const int uInt8Type = 2;
const int int8Type = 3;
const int uInt16Type = 4;
const int int16Type = 5;
const int uInt32Type = 6;
const int int32Type = 7;
const int uInt64Type = 8;
const int int64Type = 9;
const int floatType = 10;
const int doubleType = 11;

const int uint8ListType = 12;
const int int8ListType = 13;
const int uint16ListType = 14;
const int int16ListType = 15;
const int uint32ListType = 16;
const int int32ListType = 17;
const int uint64ListType = 18;
const int int64ListType = 19;
const int floatListType = 20;
const int doubleListType = 21;

const int stringType = 22;
const int objectType = 23;

// dynamic length
const int listType = 24;

// static length arrays eg. string list
const int fixedLengthListType = 25;

// static length numeric arrays
const int matrix2DType = 26;
const int matrix3DType = 27;
const int matrix4DType = 28;
const int jsonType = 29;
