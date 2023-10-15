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
part of style_dart;

/// Non-demand communication
abstract class CommunicationCenter extends ModuleDelegate {
  ///
  NonDemandCommunicator<Email>? mailer;

  ///
  NonDemandCommunicator<WebSocketServerMessage>? webSocketSender;

  ///
  NonDemandCommunicator<Notification>? notificationSender;

  ///
  NonDemandCommunicator<SMS>? smsSender;

  NonDemandCommunicator<T> getCommunicator<T extends NonDemandMessage>(
      String type) {
    throw UnimplementedError();
  }
}

/// WebSocket Server, EmailSender , NotificationSender, SMSSender
mixin NonDemandCommunicator<T extends NonDemandMessage> {
  /// Send message
  FutureOr<NonDemandResponse<T>> send(T message);
}
