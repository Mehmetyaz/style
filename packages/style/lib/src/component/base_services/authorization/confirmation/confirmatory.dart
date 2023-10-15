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
class SecondaryConfirmatory<T extends NonDemandMessage> {
  /// Sessions not stored generally. If you want to store,
  /// define [customSessionDataAccess]
  SecondaryConfirmatory({
    Key? key,
    required this.type,
    required SecondaryConfirmatoryDelegate<T> confirmatoryDelegate,
    this.defaultTimeout = const Duration(minutes: 5),
    this.sessionCollection = 'confirmation_sessions',
    this.confirmationCollection = 'confirmations',
    this.usageCollection = 'confirmation_usages',
  })  : _delegate = confirmatoryDelegate,
        key = key ?? Key.random();

  ///
  final Key key;

  ///
  ///final RandomGenerator _sessionIDGenerator;

  Authorization? _authorization;

  Authorization get authorization => _authorization!;

  void _attach(BuildContext context, Authorization authorization) {
    _context = context;
    _delegate.init(this);
    _authorization = authorization;
  }

  BuildContext? _context;

  ///
  BuildContext get context => _context!;

  ///
  final SecondaryConfirmatoryDelegate<T> _delegate;

  ///
  FutureOr<void> useConfirm(String id) {
    //TODO:
  }

  ///
  FutureOr<Confirmation> confirm(
      Request clientRequest, ConfirmRequest request) async {
    try {
      var confirm = await _delegate.confirm(clientRequest, request);

      await confirmationDataAccess.create(
          Create(collection: confirmationCollection, data: confirm.toMap()));

      _delegate.onConfirm(confirm);

      // TODO: Update
      await sessionDataAccess
          .update(Update(collection: sessionCollection, query: {
        'session_id': confirm.sessionID,
      }, data: {
        'confirmed': true,
        'confirmedAt': DateTime.now(),
        'confirm_id': confirm.confirmID,
      }));

      return confirm;
    } on Exception {
      rethrow;
    }
  }

  /// Create confirmation session.
  ///
  /// A session mean a confirmation request like password, email code, sms code.
  ///
  Future<ConfirmationSession> createSession(NonDemandClient client,
      {JsonMap? customData, Duration? customTimeout}) async {
    var session = ConfirmationSession(
        client: client,
        sessionID: sessionIDGenerator.generateString(),
        confirmationType: type,
        customData: customData,
        requestDate: DateTime.now(),
        timeout: customTimeout ?? defaultTimeout,
        userId: client.userID,
        code: _delegate is CodeConfirmationDelegate
            ? (_delegate as CodeConfirmationDelegate)
                .codeGenerator
                .generateString()
            : (_delegate as TokenConfirmationDelegate)
                .tokenGenerator
                .generateString());

    _delegate.onSessionCreated(session);
    var message = await _delegate.createMessageFromSession(session);

    //TODO: Log
    //TODO: catch
    await sessionDataAccess
        .create(Create(collection: sessionCollection, data: session.toMap()));

    var communication = context.findAncestorDelegateOf<CommunicationCenter>();

    if (communication == null) {
      throw Exception('CommunicationCenter not found');
    }

    var communicator = communication.getCommunicator(message.client.type);

    communicator.send(message);

    return session;
  }

  String sessionCollection;
  String confirmationCollection;
  String usageCollection;

  DataAccess get sessionDataAccess =>
      _sessionDataAccess ?? DataAccess.of(context);

  DataAccess get confirmationDataAccess =>
      _confirmationDataAccess ?? DataAccess.of(context);

  DataAccess? _sessionDataAccess;
  DataAccess? _confirmationDataAccess;

  ///
  final ConfirmationType type;

  final Duration defaultTimeout;

  RandomGenerator get _defaultSessionIdGenerator =>
      RandomGenerator('[*#]/l(30)');

  RandomGenerator? _sessionIDGenerator;

  RandomGenerator get sessionIDGenerator =>
      _sessionIDGenerator ?? _defaultSessionIdGenerator;
}

abstract class CodeConfirmationDelegate<T extends NonDemandMessage>
    extends SecondaryConfirmatoryDelegate<T> {
  RandomGenerator get codeGenerator;
}

abstract class TokenConfirmationDelegate<T extends NonDemandMessage> {
  RandomGenerator get tokenGenerator;
}

/// Do not extends or implement directly.
/// Use [CodeConfirmatoryDelegate] or [LinkConfirmatoryDelegate]
abstract class SecondaryConfirmatoryDelegate<T extends NonDemandMessage> {
  ///
  SecondaryConfirmatoryDelegate();

  ///
  BuildContext get context => _confirmatory.context;

  ///
  late SecondaryConfirmatory _confirmatory;

  ///
  @mustCallSuper
  FutureOr<void> init(SecondaryConfirmatory confirmatory) {
    _confirmatory = confirmatory;
  }

  ///
  FutureOr<T> createMessageFromSession(ConfirmationSession session);

  ///
  FutureOr<void> useSession(
      {required String confirmationID,
      required Request request,
      required String userId,
      required String useCase});

  ///
  FutureOr<Confirmation> confirm(
      Request clientRequest, ConfirmRequest confirmRequest);

  FutureOr<void> onConfirm(Confirmation confirmation) {}

  ///
  FutureOr<void> onSessionCreated(ConfirmationSession session);
}

/// Confirmation Request
abstract class ConfirmRequest {
  ///
  ConfirmRequest({required this.sessionID, required this.type});

  /// Session ID of confirmation
  String sessionID;

  /// Type of confirmation
  String type;
}

///
class ConfirmationSession<T extends NonDemandMessage> {
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
  factory ConfirmationSession.fromMap(Map<String, dynamic> map) =>
      ConfirmationSession(
          userId: map['user_id'] as String?,
          confirmationType: ConfirmationType.values[map['type'] as int],
          customData: map['custom_data'] as Map<String, dynamic>?,
          sessionID: map['session_id'] as String,
          code: map['code'] as String?,
          timeout: map['timeout'] == null
              ? null
              : Duration(milliseconds: map['timeout'] as int),
          requestDate:
              DateTime.fromMillisecondsSinceEpoch(map['request_date'] as int),
          client: () {
            throw 0;
          }()); //TODO: Message receiver

  ///
  Map<String, dynamic> toMap() => {
        'user_id': userId,
        'type': confirmationType.index,
        if (customData != null) 'custom_data': customData,
        'client': client.toMap(),
        'session_id': sessionID,
        'request_date': requestDate.millisecondsSinceEpoch,
        if (timeout != null) 'timeout': timeout!.inMilliseconds,
        if (code != null) 'code': code,
      };

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
  NonDemandClient client;

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
      required this.client,
      this.sessionID = 'TODO'});

  ///
  factory Confirmation.fromSession(ConfirmationSession session) => Confirmation(
      userId: session.userId!,
      requestDate: session.requestDate,
      client: session.client,
      confirmationType: session.confirmationType,
      confirmDate: DateTime.now(),
      confirmID: session.sessionID,
      customData: session.customData);

  ///
  factory Confirmation.fromMap(Map<String, dynamic> map) => Confirmation(
        userId: map['user_id'] as String,
        confirmDate:
            DateTime.fromMillisecondsSinceEpoch(map['confirm_date'] as int),
        confirmID: map['confirm_id'] as String,
        confirmationType: ConfirmationType.values[map['type'] as int],
        requestDate:
            DateTime.fromMillisecondsSinceEpoch(map['request_date'] as int),
        customData: map['custom_data'] as Map<String, dynamic>?,
        client: () {
          throw 0;
        }() /*MessageReceiver.fromMap(map['client'] as Map<String, dynamic>)*/,
      );

  ///
  Map<String, dynamic> toMap() => {
        'user_id': userId,
        'confirm_date': confirmDate.millisecondsSinceEpoch,
        'confirm_id': confirmID,
        'type': confirmationType.index,
        'request_date': requestDate.millisecondsSinceEpoch,
        'client': client.toMap(),
        'session_id': sessionID,
        if (customData != null) 'custom_data': customData,
      };

  ///
  String confirmID;

  ///
  String userId;

  String sessionID;

  /// Verification request date
  DateTime requestDate;

  ///
  DateTime confirmDate;

  ///
  ConfirmationType confirmationType;

  ///
  NonDemandClient client;

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
