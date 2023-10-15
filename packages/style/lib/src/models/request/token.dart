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
class AccessToken {
  ///
  AccessToken._(
      {required this.userId,
      required this.additional,
      required this.issuedAtDate,
      required this.issuer,
      required this.tokenID,
      required this.subject,
      this.audience,
      this.expireDate});

  ///
  factory AccessToken.fromMap(Map<String, dynamic> map) => AccessToken._(
        userId: map['uid'] as String,
        additional: map['add'] as Map<String,dynamic>,
        issuedAtDate: DateTime.fromMillisecondsSinceEpoch(map['iat'] as int),
        issuer: map['iss'] as String,
        tokenID: map['jti'] as String,
        subject: map['sub'] as String,
        audience: map['aud'] as String,
        expireDate: map['exp'] != null
            ? DateTime.fromMillisecondsSinceEpoch(map['exp'] as int)
            : null);

  ///
  static AccessToken create({
    required BuildContext context,
    required String userId,
    Map<String, dynamic>? additional,
    required String subject,
    required String deviceID,
    required String tokenID,
    DateTime? expire,
  }) => AccessToken._(
      userId: userId,
      additional: additional,
      issuedAtDate: DateTime.now(),
      issuer: context.owner.serviceRootName,
      tokenID: tokenID,
      subject: subject,
      expireDate: expire,
    );




  ///
  Map<String, dynamic> toMap() => {
      'uid': userId,
      'iss': issuer,
      'jti': tokenID,
      'sub': subject,
      'iat': issuedAtDate.millisecondsSinceEpoch,
      if (expireDate != null) 'exp': expireDate!.millisecondsSinceEpoch,
      if (audience != null) 'aud': audience,
      if (additional != null) 'add': additional,
      ...?additional
    };

  ///
  Future<String> encrypt(BuildContext context) async {
    var header = <String, dynamic>{'alg': 'HS256', 'typ': 'JWT'};

    var payload = toMap();

    var base64Payload = base64Url.encode(utf8.encode(json.encode(payload)));

    var base64Header = base64Url.encode(utf8.encode(json.encode(header)));

    var payloadFirstMacBytes = await context.crypto
        .calculateSha256Mac(base64Url.decode(base64Payload));

    var payloadFirstMacBase64 = base64Url.encode(payloadFirstMacBytes);

    var secondPlain = '$base64Header.$payloadFirstMacBase64';

    var secondMacBytes =
        await context.crypto.calculateSha256Mac(utf8.encode(secondPlain));

    var lastMacBase64 = base64Url.encode(secondMacBytes);

    var pHMerged = '$base64Header.$base64Payload';

    var phMergedBase64 = base64Url.encode(utf8.encode(pHMerged));

    return '$phMergedBase64.$lastMacBase64';
  }

  Future<void> confirm(BuildContext context) async {

  }


  /// "jti" Json Web Token Id
  String tokenID;

  /// "uid" User id
  String userId;

  /// "aud"
  String? audience;

  /// "iat" create date
  DateTime issuedAtDate;

  /// "exp" ExpireDate
  DateTime? expireDate;

  /// "iss" issuer
  String issuer;

  /// "sub" Subject
  String subject;

  /// "add"
  Map<String, dynamic>? additional;
}

///
class Nonce {
  ///
  Nonce(this.bytes);

  ///
  factory Nonce.random(int length) {
    var l = <int>[];
    var i = 0;

    while (i < length) {
      l.add(Random().nextInt(255));
      i++;
    }
    return Nonce(Uint8List.fromList(l));
  }

  ///
  Uint8List bytes;
}
