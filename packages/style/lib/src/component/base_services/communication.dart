/*
 * Copyright 2021 styledart.dev - Mehmet Yaz
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */
part of '../../style_base.dart';

/// Non-demand communication
abstract class CommunicationCenter extends _BaseService {
  ///
  NonDemandCommunicator<Email>? mailer;

  ///
  NonDemandCommunicator<WebSocketServerMessage>? webSocketSender;

  ///
  NonDemandCommunicator<Notification>? notificationSender;

  ///
  NonDemandCommunicator<SMS>? smsSender;
}

///
mixin NonDemandCommunicator<T extends NonDemandMessage> {
  ///
  FutureOr<NonDemandResponse<T>> send(T message);
}

///
abstract class NonDemandMessage<T extends MessageReceiver> {
  ///
  NonDemandMessage({required this.id, required this.receiver});

  ///
  String id;

  ///
  T receiver;
}

///
abstract class NonDemandResponse<T extends NonDemandMessage> {
  ///
  NonDemandResponse(
      {required this.message, required this.forwarded, this.responsePayload});

  ///
  T message;

  ///
  bool forwarded;

  ///
  Map<String, dynamic>? responsePayload;
}

///
class Email extends NonDemandMessage<MessageReceiver> {
  ///
  Email({required MessageReceiver receiver, required String id})
      : super(id: id, receiver: receiver);
}

///
class WebSocketServerMessage extends NonDemandMessage<MessageReceiver> {
  ///
  WebSocketServerMessage(
      {required MessageReceiver receiver, required String id})
      : super(id: id, receiver: receiver);
}

///
class Notification extends NonDemandMessage<MessageReceiver> {
  ///
  Notification({required MessageReceiver receiver, required String id})
      : super(id: id, receiver: receiver);
}

///
class SMS extends NonDemandMessage<MessageReceiver> {
  ///
  SMS({required MessageReceiver receiver, required String id})
      : super(id: id, receiver: receiver);
}

///
@immutable
class MessageReceiver {
  ///
  MessageReceiver({required this.type, required this.identifier});

  ///
  factory MessageReceiver.fromMap(Map<String, dynamic> map) {
    return MessageReceiver(type: map["type"], identifier: map["identifier"]);
  }

  ///
  final String type;

  ///
  final String identifier;

  ///
  Map<String, dynamic> toMap() {
    return {"type": type, "identifier": identifier};
  }
}
