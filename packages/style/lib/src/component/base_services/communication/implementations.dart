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

///
class Email extends NonDemandMessage {
  ///
  Email(
      {required String id,
      required NonDemandClient client,
      required this.subject,
      required this.body,
      this.cc,
      this.bcc})
      : super(
            messageId: id,
            client: client,
            payload: {'subject': subject, 'body': body, 'cc': cc, 'bcc': bcc});

  String subject, body;
  String? cc, bcc;
}

///
class WebSocketServerMessage extends NonDemandMessage {
  ///
  WebSocketServerMessage(
      {required super.messageId,
      required super.payload,
      required super.client});
}

///
class Notification extends NonDemandMessage {
  ///
  Notification(
      {required super.payload,
      required super.messageId,
      required super.client});
}

///
class SMS extends NonDemandMessage {
  ///
  SMS(
      {required super.payload,
      required super.messageId,
      required super.client});
}
