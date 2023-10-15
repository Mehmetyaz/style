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
abstract class NonDemandMessage {
  /// Message
  NonDemandMessage(
      {required this.messageId, required this.payload, required this.client});

  /// Message id
  String messageId;

  /// Non demand message receiver client.
  NonDemandClient client;

  /// Message data
  JsonMap payload;
}

///
abstract class NonDemandResponse<T extends NonDemandMessage> {
  ///
  NonDemandResponse(
      {required this.message, required this.forwarded, this.responsePayload});

  /// Message
  T message;

  /// Forwarded
  bool forwarded;

  /// Response payload
  JsonMap? responsePayload;
}

///
@immutable
class NonDemandClient {
  ///
  NonDemandClient(
      {required this.type,
      required this.identifier,
      required this.userID,
      this.data});

  ///
  factory NonDemandClient.fromMap(Map<String, dynamic> map) => NonDemandClient(
      type: map['type'] as String,
      identifier: map['identifier'] as String,
      userID: map['user_id'] as String?,
      data: map['data'] as Map<String, dynamic>?);

  /// Client type like email, sms, web_socket
  final String type;

  /// User identifier
  final String? userID;

  /// Identifier for ident client from communicator.
  /// Like email address, phone number, socket id.
  final String identifier;

  /// Additional data
  final JsonMap? data;

  ///
  Map<String, dynamic> toMap() => {
        'type': type,
        'identifier': identifier,
        'user_id': userID,
        if (data != null) 'data': data
      };
}
