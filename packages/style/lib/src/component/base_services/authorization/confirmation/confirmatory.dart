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

part of '../../../../style_base.dart';

///
class Confirmatory {
  /// Sessions not stored generally. If you want to store,
  /// define [customSessionDataAccess]
  Confirmatory({
    Key? key,
    required ConfirmatoryDelegate confirmatoryDelegate,
    this.customConfirmationDataAccess,
    this.customSessionDataAccess,
    this.sessionCollection,
    this.confirmationCollection,
    RandomGenerator? sessionIdGenerator,
  })  : _delegate = confirmatoryDelegate,
        key = key ?? Key.random(),
        /*   _sessionStore = _defaultSessionStorage(
            customSessionDataAccess, customSessionCollection),
        _confirmationStore = _defaultConfirmationStorage(
          customConfirmationCollection,
          customConfirmationDataAccess,
        ),*/
        _sessionIDGenerator =
            sessionIdGenerator ?? RandomGenerator("[*#]/l(30)");

  ///
  final Key key;

  final RandomGenerator _sessionIDGenerator;

  ///
  ConfirmationType get type => _delegate.type;

  ///
  String? sessionCollection;

  ///
  String? confirmationCollection;

  ///
  DataAccess? customSessionDataAccess;

  ///
  DataAccess? customConfirmationDataAccess;

  void _attach(BuildContext context) {
    _context = context;
    _delegate.init(this);
  }

  BuildContext? _context;

  ///
  BuildContext get context => _context!;

  ///
  final ConfirmatoryDelegate _delegate;

  ///
  FutureOr<void> useConfirm(String id) {
    //TODO:
  }

  ///
  FutureOr<Confirmation> confirm(
      Request clientRequest, ConfirmRequest request) {
    try {
      //TODO: Log
      return _delegate.confirm(clientRequest, request);
    } on Exception {
      rethrow;
    }
  }

  ///
  FutureOr<ConfirmationSession> createSession(
      ConfirmationSession session) async {
    Logger.of(context).info(context, "confirmation_session_created",
        payload: session.toMap());
    await _delegate.onSessionCreated(session);
    return session;
  }
}

/// Do not extends or implement directly.
/// Use [CodeConfirmatoryDelegate] or [LinkConfirmatoryDelegate]
abstract class ConfirmatoryDelegate<S extends ConfirmationSession,
    C extends Confirmation, R extends ConfirmRequest> {
  ///
  ConfirmatoryDelegate({
    required this.type,
  });

  ///
  BuildContext get context => _confirmatory.context;

  ///
  final ConfirmationType type;

  ///
  late Confirmatory _confirmatory;

  ///
  @mustCallSuper
  FutureOr<void> init(Confirmatory confirmatory) {
    _confirmatory = confirmatory;
  }

  ///
  FutureOr<S> getSession(String sessionID);

  ///
  FutureOr<C> getConfirmation(String confirmationID);

  ///
  FutureOr<void> saveSession(S session);

  ///
  FutureOr<void> useSession(
      {required String confirmationID,
      required Request request,
      required String userId,
      required String useCase});

  ///
  FutureOr<void> saveConfirmation(S session);

  ///
  FutureOr<C> confirm(Request clientRequest, R confirmRequest);

  ///
  FutureOr<void> onSessionCreated(S session);
}

///
abstract class CodeConfirmationDelegate extends ConfirmatoryDelegate {
  ///
  CodeConfirmationDelegate() : super(type: ConfirmationType.code);

  ///
  String getRandomCode() {
    throw UnimplementedError();
  }
}

///
abstract class ConfirmationTypeAbstract {}

///
abstract class ConfirmRequest {
  ///
  ConfirmRequest({required this.sessionID});

  ///
  String sessionID;
}

///
class ConfirmationSession {
  ///
  ConfirmationSession(
      {required this.userId,
      required this.confirmationType,
      required this.client,
      required this.requestDate,
      required this.sessionID,
      this.customData,
      this.timeout,
      this.code,
      this.onTimeout})
      : assert((timeout == null) == (onTimeout == null));

  ///
  factory ConfirmationSession.fromMap(Map<String, dynamic> map) {
    return ConfirmationSession(
        userId: map["user_id"],
        confirmationType: ConfirmationType.values[map["type"]],
        customData: map["custom_data"],
        sessionID: map["session_id"],
        requestDate: DateTime.fromMillisecondsSinceEpoch(map["request_date"]),
        client:
            MessageReceiver.fromMap(map["client"])); //TODO: Message receiver
  }

  ///
  Map<String, dynamic> toMap() {
    return {
      "user_id": userId,
      "type": confirmationType.index,
      if (customData != null) "custom_data": customData,
      "client": client.toMap(),
      "session_id": sessionID,
      "request_date": requestDate.millisecondsSinceEpoch
    };
  }

  ///
  Duration? timeout;

  ///
  FutureOr<void> Function(ConfirmationSession session)? onTimeout;

  ///
  final String? code;

  ///
  String sessionID;

  ///
  String? userId;

  /// Verification request date
  DateTime requestDate;

  ///
  ConfirmationType confirmationType;

  /// Validation client.
  MessageReceiver client;

  ///
  Map<String, dynamic>? customData;
}

///
class Confirmation {
  ///
  Confirmation(
      {required this.userId,
      required this.confirmDate,
      required this.confirmID,
      required this.confirmationType,
      required this.requestDate,
      this.customData,
      required this.client});

  ///
  factory Confirmation.fromSession(ConfirmationSession session) {
    return Confirmation(
        userId: session.userId!,
        requestDate: session.requestDate,
        client: session.client,
        confirmationType: session.confirmationType,
        confirmDate: DateTime.now(),
        confirmID: session.sessionID,
        customData: session.customData);
  }

  ///
  factory Confirmation.fromMap(Map<String, dynamic> map) {
    return Confirmation(
        userId: map["user_id"],
        confirmDate: DateTime.fromMillisecondsSinceEpoch(map["confirm_date"]),
        confirmID: map["confirm_id"],
        confirmationType: ConfirmationType.values[map["type"]],
        requestDate: DateTime.fromMillisecondsSinceEpoch(map["request_date"]),
        client: MessageReceiver.fromMap(map["client"]),
        customData: map["custom_data"]);
  }

  ///
  Map<String, dynamic> toMap() {
    return {
      "user_id": userId,
      "confirm_date": confirmDate.millisecondsSinceEpoch,
      "confirm_id": confirmID,
      "type": confirmationType.index,
      "request_date": requestDate.millisecondsSinceEpoch,
      "client": client.toMap(),
      if (customData != null) "custom_data": customData
    };
  }

  ///
  String confirmID;

  ///
  String userId;

  /// Verification request date
  DateTime requestDate;

  ///
  DateTime confirmDate;

  ///
  ConfirmationType confirmationType;

  ///
  MessageReceiver client;

  ///
  Map<String, dynamic>? customData;

}

///
enum ConfirmationType {
  ///
  code,

  ///
  link,

  /// Oauth provider
  provider
}
