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

//TODO: Set New Task

///
abstract class Authorization extends _BaseService {
  ///
  Authorization({List<Confirmatory>? confirmatories})
      : _confirmatories = (confirmatories ?? [])
            .asMap()
            .map((key, value) => MapEntry(value.key.key, value));

  ///
  static Authorization of(BuildContext context) {
    return context.authorization;
  }

  ///
  FutureOr<bool> initService();

  ///
  FutureOr<dynamic> login(dynamic authData);

  ///
  FutureOr<void> logout(dynamic authData);

  ///
  FutureOr<AccessToken> register(dynamic authData, {dynamic credentials});

  ///
  FutureOr<AccessToken> decryptToken(String token);

  ///
  FutureOr<String> encryptToken(AccessToken token);

  /// throw if token not verified
  FutureOr<void> verifyToken(AccessToken token);

  ///
  Component build(BuildContext context);

  ///
  Crypto get crypto => _crypto ??= context.crypto;

  ///
  Crypto? _crypto;

  ///
  DataAccess get dataAccess => _dataAccess ??= context.dataAccess;

  ///
  DataAccess? _dataAccess;

  @override
  FutureOr<bool> init([bool inInterface = true]) {
    if (!context.hasService<Crypto>()) {
      throw UnsupportedError("Authorization service not"
          " supported without CryptoService");
    }

    if (!context.hasService<DataAccess>()) {
      throw UnsupportedError("Authorization service not"
          " supported without DataAccess");
    }

    _confirmatories.forEach((key, value) {
      value._attach(context);
    });

    return initService();
  }

  ///
  final Map<String, Confirmatory> _confirmatories;

  ///
  Confirmatory getConfirmatoryByKey(String key) {
    return _confirmatories[key]!;
  }

  ///
  Confirmatory<T> getConfirmatory<T extends MessageReceiver>(
      ConfirmationType type) {
    var available = _confirmatories.values
        .whereType<Confirmatory<T>>()
        .where((element) => element.type == type);

    if (available.isEmpty) {
      throw ServiceUnavailable("There isn't available confirmatory");
    }

    if (available.length > 1) {
      throw ServiceUnavailable("There multiple available confirmatory."
          " use [confirmatoryByKey].");
    }

    return available.first;
  }
}

///
class Confirmatory<T extends MessageReceiver> {
  /// Sessions not stored generally. If you want to store,
  /// define [customSessionDataAccess]
  Confirmatory({
    Key? key,
    required ConfirmatoryDelegate<T> confirmatoryDelegate,
    RandomGenerator? sessionIdGenerator,
    String? customSessionCollection,
    String? customConfirmationCollection,
    DataAccess? customSessionDataAccess,
    DataAccess? customConfirmationDataAccess,
  })  : _delegate = confirmatoryDelegate,
        key = key ?? Key.random(),
        _sessionStore = _defaultSessionStorage(
            customSessionDataAccess, customSessionCollection),
        _confirmationStore = _defaultConfirmationStorage(
          customConfirmationCollection,
          customConfirmationDataAccess,
        ),
        _sessionIDGenerator = sessionIdGenerator ?? RandomGenerator("[*#]/l(30)");

  ///
  final Key key;

  final RandomGenerator _sessionIDGenerator;

  ///
  ConfirmationType get type => _delegate.type;

  static StoreDelegate<ConfirmationSession> _defaultSessionStorage(
    DataAccess? customSessionDataAccess,
    String? sessionCollection,
  ) {
    return StoreDelegate<ConfirmationSession>(
        collection: sessionCollection ?? "confirmation_sessions",
        toMap: (session) {
          return session.toMap();
        },
        customAccess: customSessionDataAccess,
        fromMap: ConfirmationSession.fromMap);
  }

  static StoreDelegate<Confirmation> _defaultConfirmationStorage(
    String? confirmationCollection,
    DataAccess? customConfirmationDataAccess,
  ) {
    return StoreDelegate<Confirmation>(
        collection: confirmationCollection ?? "confirmations",
        toMap: (conf) {
          return conf.toMap();
        },
        fromMap: Confirmation.fromMap);
  }

  void _attach(BuildContext context) {
    _context = context;
    _delegate.init(context);
    _sessionStore.attach(context);
    _confirmationStore.attach(context);
  }

  BuildContext? _context;

  ///
  BuildContext get context => _context!;

  ///
  final ConfirmatoryDelegate _delegate;

  ///
  final StoreDelegate<ConfirmationSession> _sessionStore;

  ///
  final StoreDelegate<Confirmation> _confirmationStore;

  ///
  FutureOr<Confirmation> confirm(
      Request clientRequest, ConfirmationRequest request) async {
    //TODO: Improve logs and exceptions
    try {
      var session = await _sessionStore.read(request.sessionID);
      var valid = await _delegate.check(clientRequest, session, request);
      if (valid) {
        var confirmation = Confirmation.fromSession(session);
        await _confirmationStore.write(confirmation);
        await _delegate.onConfirm(clientRequest, confirmation);
        return confirmation;
      } else {
        throw BadRequests();
      }
    } on Exception {
      throw BadGateway();
    }
  }

  ///
  FutureOr<ConfirmationSession> createSession(
      {required Request request,
      required String userId,
      required ConfirmationType type,
      required MessageReceiver receiver,
      String? customCode,
      Map<String, dynamic>? customData}) async {
    var session = ConfirmationSession(
        userId: userId,
        confirmationType: type,
        client: receiver,
        requestDate: DateTime.now(),
        sessionID: _sessionIDGenerator.generateString(),
        customData: customData,
        code: type == ConfirmationType.code
            ? null
            : customCode ??
                (_delegate as CodeConfirmationDelegate).getRandomCode(),
        onTimeout: type == ConfirmationType.code ? null : _delegate.onTimeout,
        timeout: type == ConfirmationType.code ? null : _delegate._timeout);
    Logger.of(context).info(context, "confirmation_session_created",
        payload: {"user_id": userId, "session_id": session.sessionID});
    await _sessionStore.write(session);
    await _delegate.onSessionCreated(request, session);
    return session;
  }
}

/// Do not extends or implement directly.
/// Use [CodeConfirmatoryDelegate] or [LinkConfirmatoryDelegate]
abstract class ConfirmatoryDelegate<T extends MessageReceiver> {
  ///
  ConfirmatoryDelegate({
    required this.longTerm,
    required this.type,
    Duration? timeout,
  })  : _timeout = timeout,
        assert(longTerm || timeout != null);

  ///
  late final BuildContext context;

  ///
  final bool longTerm;

  ///
  final Duration? _timeout;

  ///
  final ConfirmationType type;

  ///
  @mustCallSuper
  FutureOr<void> init(BuildContext context) {
    this.context = context;
  }

  ///
  FutureOr<void> onTimeout(ConfirmationSession<T> session) {}

  ///
  FutureOr<bool> check(Request clientRequest, ConfirmationSession session,
      ConfirmationRequest request);

  ///
  FutureOr<void> onConfirm(Request clientRequest, Confirmation confirmation);

  ///
  FutureOr<void> onSessionCreated(Request request, ConfirmationSession session);
}

///
abstract class CodeConfirmationDelegate<T extends MessageReceiver>
    extends ConfirmatoryDelegate<T> {
  ///
  CodeConfirmationDelegate()
      : super(longTerm: true, type: ConfirmationType.code);

  ///
  String getRandomCode() {
    throw UnimplementedError();
  }
}

///
class ConfirmationRequest {
  ///
  ConfirmationRequest({required this.sessionID});

  ///
  String sessionID;

  ///
  String? code;

  ///
  Map<String, dynamic>? data;
}

///
class ConfirmationSession<T extends MessageReceiver> {
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
        client: MessageReceiver.fromMap(map["client"])
            as T); //TODO: Message receiver
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
  FutureOr<void> Function(ConfirmationSession<T> session)? onTimeout;

  ///
  final String? code;

  ///
  String sessionID;

  ///
  String userId;

  /// Verification request date
  DateTime requestDate;

  ///
  ConfirmationType confirmationType;

  /// Validation client.
  T client;

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
        userId: session.userId,
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
  link
}

///
class EmailCodeConfirmatoryDelegate extends CodeConfirmationDelegate {
  ///
  EmailCodeConfirmatoryDelegate() : super();

  @override
  FutureOr<bool> check(Request clientRequest, ConfirmationSession session,
      ConfirmationRequest request) {
    // TODO: implement check
    throw UnimplementedError();
  }

  @override
  FutureOr<void> onConfirm(Request clientRequest, Confirmation confirmation) {
    // TODO: implement onConfirm
    throw UnimplementedError();
  }

  @override
  FutureOr<void> onSessionCreated(
      Request request, ConfirmationSession session) {
    // TODO: implement onSessionCreated
    throw UnimplementedError();
  }

  @override
  FutureOr<void> onTimeout(ConfirmationSession<MessageReceiver> session) {
    // TODO: implement onTimeout
    throw UnimplementedError();
  }
}

///
// class SimpleAuthorization extends Authorization {
//   @override
//   FutureOr<bool> initService() {
//     return true;
//   }
//
//   @override
//   FutureOr<UserCredential> login(dynamic authData) {
//     // TODO: implement login
//     throw UnimplementedError();
//   }
//
//   @override
//   FutureOr<bool> logout(dynamic authData) {
//     // TODO: implement logout
//     throw UnimplementedError();
//   }
//
//   @override
//   FutureOr<AccessToken> register
//   (dynamic authData, UserCredential credentials) {
//     // TODO: implement register
//     throw UnimplementedError();
//   }
//
//   @override
//   FutureOr<String> encryptToken(AccessToken token) async {
//     var header = <String, dynamic>{"alg": "HS256", "typ": "JWT"};
//     var payload = token.toMap();
//
//     var base64Payload = base64Url.encode(utf8.encode(json.encode(payload)));
//
//     var base64Header = base64Url.encode(utf8.encode(json.encode(header)));
//
//     ///
//     var cT = "$base64Header.$base64Payload";
//
//     ///
//     var hash = await crypto.calculateSha256Mac(utf8.encode(cT));
//
//     return "$cT.${base64Url.encode(hash)}";
//   }
//
//   @override
//   FutureOr<AccessToken> decryptToken(String token) async {
//     var parts = token.split(".");
//     if (parts.length != 3) {
//       throw UnauthorizedException();
//     }
//
//     var headerText = parts[0];
//     var payloadText = parts[1];
//     var hashBase64 = parts[2];
//
//     var calcHash = await crypto
//         .calculateSha256Mac(utf8.encode("$headerText.$payloadText"));
//
//     var calcHashBase64 = base64Url.encode(calcHash);
//
//     if (calcHashBase64 != hashBase64) {
//       throw UnauthorizedException();
//     }
//
//     return AccessToken.fromMap(
//         json.decode(utf8.decode(base64Url.decode(payloadText))));
//   }
//
//   @override
//   FutureOr<void> verifyToken(AccessToken token) {
//     // TODO: implement verifyToken
//     throw UnimplementedError();
//   }
//
//   @override
//   Component build() {
//     // TODO: implement build
//     throw UnimplementedError();
//   }
// }

// ///
// abstract class RegisterData {
//   ///
//   RegisterData({required this.method, required this.password});
//
//   ///
//   SingInMethod method;
//
//   ///
//   String password;
//
//   ///
//   String? userLoginInput;
// }
