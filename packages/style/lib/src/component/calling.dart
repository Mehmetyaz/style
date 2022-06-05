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

part of '../style_base.dart';

/// İşlem Çağrısı
///
/// Çağrı bindingler üzerinde gezinir.
///
/// Kimi zaman eş zamanlı olarak bindinge yüklenir
///
/// Kimi zaman kuyruk olarak
///
abstract class Calling {
  ///
  Calling(
    CallingBinding binding,
  ) : _binding = binding;
  final CallingBinding _binding;

  ///
  @internal
  @protected
  FutureOr<Message> onCall(Request request);

  ///
  FutureOr<Message> call(Request request) async {
    try {
      var r = await onCall(request);
      return r;
    } on Exception catch (e, s) {
      return _binding.exceptionHandler
          .getBinding(e)
          .calling
          .onCall(request, e, s);
    }
  }

  ///
  int callCount = 0;

  ///
  CallingBinding get binding => _binding;
}
