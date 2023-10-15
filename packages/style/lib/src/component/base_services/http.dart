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
abstract class HttpService extends ModuleDelegate {
  ///
  HttpService({this.securityContext});

  ///
  static HttpService of(BuildContext context) => context.httpService;

  ///
  String get address;

  ///
  SecurityContext? securityContext;

  ///
  Map<String, dynamic>? get defaultResponseHeaders;

  ///
  Future<void> handleHttpRequest(HttpRequest request);

// @override
// Future<bool> init() async {
//   // await context.logger.ensureInitialize();
//   server = await serverBind;
//   if (defaultResponseHeaders != null) {
//     for (var h in defaultResponseHeaders!.entries) {
//       server.defaultResponseHeaders.add(h.key, h.value);
//     }
//   }
//   server.listen(handleHttpRequest);
//   return true;
// }
}

class JsonHttpService extends HttpService {
  ///
  JsonHttpService({String? host, int? port, super.securityContext})
      : _address =
            host ?? String.fromEnvironment('HOST', defaultValue: 'localhost'),
        port = port ?? int.fromEnvironment('PORT', defaultValue: 80);

  ///
  final String _address;

  ///
  int port;

  @override
  Future<void> handleHttpRequest(HttpRequest request) async {
    var log = LogMessage(
        loggerContext: context,
        typeName: 'request_handled',
        level: LogLevel.info);
    var stopwatch = Stopwatch()..start();
    var bodyBytes = await request.toList();
    var uInt8List = mergeList(bodyBytes);

    Body? body;

    if (uInt8List.isNotEmpty) {
      body = JsonBody(json.decode(utf8.decode(uInt8List)));
    }
    var req = HttpStyleRequest.fromRequest(req: request, body: body);

    try {
      var res = await context.owner.calling(req);
      stopwatch.stop();
      if (res is Response && res is! NoResponseRequired) {
        request.response.statusCode = res.statusCode;
        request.response.headers.contentType = res.contentType;
        for (var head in res.additionalHeaders?.entries.toList() ??
            <MapEntry<String, dynamic>>[]) {
          request.response.headers.add(head.key, head.value as Object);
        }

        if (res.body is! JsonBody) {
          request.response.statusCode = 500;
          request.response.headers.contentType = ContentType.json;
          await request.response.close();
          res.sent = true;
          log.payload = {
            'took_internal': stopwatch.elapsedMicroseconds,
            'status_code': 500,
            'method': req.method.name,
            'path': req.path.calledPath,
            'content_type': ContentType.json.toString(),
            'error': {
              'message': 'Response body is not a json body',
              'type': 'response_body_not_json',
              'response_body': res.body.toString()
            }
          };
        } else {
          if (res.body?.data != null) {
            request.response.write(res.body!.data);
          }
          await request.response.close();
          res.sent = true;
          log.payload = {
            'took_internal': stopwatch.elapsedMicroseconds,
            'status_code': res.statusCode,
            'method': req.method.name,
            'path': req.path.calledPath,
            'headers': res.additionalHeaders,
            'content_type': res.contentType.toString(),
          };
        }
      }
    } on Exception catch (e) {
      stopwatch.stop();
      request.response.statusCode = 400;
      request.response.headers.contentType = ContentType.json;
      request.response.write(json.encode({'error': e.toString()}));
      await request.response.close();
      log.payload = {
        'took_internal': stopwatch.elapsedMicroseconds,
        'status_code': 400,
        'method': req.method.name,
        'path': req.path.calledPath,
        'content_type': ContentType.json.toString(),
      };
    }

    Logger.of(context).log(log);

    return;
  }

  @override
  Map<String, dynamic>? get defaultResponseHeaders => {};

  @override
  String get address =>
      'http${securityContext != null ? "s" : ""}://$_address:$port';

  ///
  Future<HttpServer> get serverBind => securityContext != null
      ? HttpServer.bindSecure(_address, port, securityContext!, shared: true)
      : HttpServer.bind(_address, port, shared: true);

  ///
  late HttpServer server;

  @override
  FutureOr<bool> init() async {
    server = await serverBind;
    if (defaultResponseHeaders != null) {
      for (var h in defaultResponseHeaders!.entries) {
        server.defaultResponseHeaders.add(h.key, h.value as Object);
      }
    }
    Logger.of(context).log(LogMessage(
        loggerContext: context,
        title: 'Server started at: ${server.address.host}:${server.port}',
        typeName: 'server_started',
        payload: {
          'host': server.address.host,
          'port': server.port,
          'server_header': server.serverHeader,
          'default_headers': server.defaultResponseHeaders.toString(),
        },
        level: LogLevel.important));
    server.listen(handleHttpRequest);
    return true;
  }
}

///
class DefaultHttpServiceHandler extends HttpService {
  ///
  DefaultHttpServiceHandler({String? host, int? port, super.securityContext})
      : _address =
            host ?? String.fromEnvironment('HOST', defaultValue: 'localhost'),
        port = port ?? int.fromEnvironment('PORT', defaultValue: 80);

  ///
  final String _address;

  ///
  int port;

  ///
  @override
  Future<void> handleHttpRequest(HttpRequest request) async {
    var log = LogMessage(
        loggerContext: context,
        typeName: 'request_handled',
        level: LogLevel.info);
    var stopwatch = Stopwatch()..start();
    var bodyBytes = await request.toList();
    var uInt8List = mergeList(bodyBytes);

    Object? body;
    if (uInt8List.isEmpty) {
      body = null;
    } else if (request.headers.contentType?.mimeType ==
        ContentType.json.mimeType) {
      try {
        body = json.decode(utf8.decode(uInt8List));
      } on Exception {
        body = null;
      }
    } else if (request.headers.contentType?.mimeType ==
            ContentType.html.mimeType ||
        request.headers.contentType == ContentType.text) {
      try {
        body = utf8.decode(uInt8List);
      } on Exception {
        body = null;
      }
    } else if (request.headers.contentType?.mimeType ==
        ContentType.binary.mimeType) {
      try {
        body = (uInt8List);
      } on Exception {
        body = null;
      }
    } else {
      try {
        body = json.decode(utf8.decode(uInt8List));
      } on Exception {
        try {
          body = utf8.decode(uInt8List);
        } on Exception {
          try {
            body = (uInt8List);
          } on Exception {
            body = null;
          }
        }
      }
    }

    var req = HttpStyleRequest.fromRequest(req: request, body: Body(body));

    try {
      var res = await context.owner.calling(req);
      if (res is Response && res is! NoResponseRequired) {
        request.response.statusCode = res.statusCode;

        request.response.headers.contentType = res.contentType;
        for (var head in res.additionalHeaders?.entries.toList() ??
            <MapEntry<String, dynamic>>[]) {
          request.response.headers.add(head.key, head.value as Object);
        }

        if (res.body != null && res.body is StreamBody) {
          await request.response
              .addStream((res.body as StreamBody).streamBytes);
        } else if (res.body != null && res.body is BinaryBody) {
          request.response.add((res.body as BinaryBody).data);
        } else {
          if (res.body?.data != null) {
            request.response.write(res.body);
          }
        }

        await request.response.close();
        res.sent = true;
        log.payload = {
          'took': stopwatch.elapsedMilliseconds,
          'status_code': res.statusCode,
          'method': req.method.name,
          'path': req.path.calledPath,
          'headers': res.additionalHeaders,
          'content_type': res.contentType.toString(),
        };
      }
    } on Exception catch (e) {
      request.response.statusCode = 400;
      request.response.headers.contentType = ContentType.json;
      request.response.write(json.encode({'error': e.toString()}));
      log.payload = {
        'took': stopwatch.elapsedMilliseconds,
        'status_code': 400,
        'method': req.method.name,
        'path': req.path.calledPath,
        'content_type': ContentType.json.toString(),
      };
      await request.response.close();
    }

    Logger.of(context).log(log);

    return;
  }

  @override
  Map<String, dynamic>? get defaultResponseHeaders => {};

  @override
  String get address =>
      'http${securityContext != null ? "s" : ""}://$_address:$port';

  ///
  Future<HttpServer> get serverBind => securityContext != null
      ? HttpServer.bindSecure(_address, port, securityContext!, shared: true)
      : HttpServer.bind(_address, port, shared: true);

  ///
  late HttpServer server;

  @override
  FutureOr<bool> init() async {
    server = await serverBind;
    if (defaultResponseHeaders != null) {
      for (var h in defaultResponseHeaders!.entries) {
        server.defaultResponseHeaders.add(h.key, h.value as Object);
      }
    }
    Logger.of(context).log(LogMessage(
        loggerContext: context,
        title: 'Server started at: ${server.address.host}:${server.port}',
        typeName: 'server_started',
        payload: {
          'host': server.address.host,
          'port': server.port,
          'server_header': server.serverHeader,
          'default_headers': server.defaultResponseHeaders.toString(),
        },
        level: LogLevel.important));
    server.listen(handleHttpRequest);
    return true;
  }
}
