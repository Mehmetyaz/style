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

/// Log everything
abstract class Logger extends ModuleDelegate {
  ///
  Logger({RandomGenerator? logIdGenerator})
      : loggerIdGenerator = logIdGenerator ?? RandomGenerator('[*#]/l(30)');

  ///
  static Logger of(BuildContext context) => context.logger;

  ///
  final RandomGenerator loggerIdGenerator;

  ///
  void log(LogMessage logMessage);

  void _log(LogLevel level, BuildContext context, String name,
          {Map<String, dynamic>? payload, String? title, String? customId}) =>
      log(LogMessage(
          loggerContext: context,
          customId: customId,
          payload: payload,
          typeName: name,
          title: title,
          level: level));

  ///
  void verbose(BuildContext context, String name,
          {Map<String, dynamic>? payload, String? customId, String? title}) =>
      _log(LogLevel.verbose, context, name,
          title: title, payload: payload, customId: customId);

  ///
  void info(BuildContext context, String name,
          {Map<String, dynamic>? payload, String? customId, String? title}) =>
      _log(LogLevel.info, context, name,
          payload: payload, customId: customId, title: title);

  ///
  void error(BuildContext context, String name,
          {Map<String, dynamic>? payload, String? customId, String? title}) =>
      _log(LogLevel.error, context, name,
          payload: payload, customId: customId, title: title);

  ///
  void warn(BuildContext context, String name,
          {Map<String, dynamic>? payload, String? customId, String? title}) =>
      _log(
        LogLevel.warn,
        context,
        name,
        title: title,
        payload: payload,
        customId: customId,
      );

  ///
  void important(BuildContext context, String name,
          {Map<String, dynamic>? payload, String? customId, String? title}) =>
      _log(LogLevel.important, context, name,
          title: title, payload: payload, customId: customId);
}

///
class DefaultLogger extends Logger {
  ///
  DefaultLogger({RandomGenerator? logIdGenerator})
      : super(logIdGenerator: logIdGenerator);

  @override
  FutureOr<bool> init([bool inInterface = true]) => true;

  @override
  void log(LogMessage logMessage) {
    print(JsonEncoder.withIndent('  ').convert({
      'id': logMessage.id,
      'time': logMessage.time.toIso8601String(),
      'level': logMessage.level.index,
      'type_name': logMessage.typeName,
      'title': logMessage.title,
      'payload': logMessage.payload,
      if (logMessage.level.index > 1)
        'where': (logMessage.loggerContext as Binding)
            .where((e) => e is! ExceptionWrapper),
      if (logMessage.level.index > 3)
        'stack_trace': StackTrace.current.toString(),
    }));
  }
}

/// eg log
///
/// level: important
/// type_name: server_start
/// title: Server Started : Server started with 192.168.1.1
/// time: 14.00.21 16:18
/// payload: {
///   agent: x,
///   cause: y,
///   token: a,
///   context: short_desc,
///   duration: 10 ms
/// }
///
class LogMessage {
  ///
  ///
  LogMessage(
      {String? customId,
      required this.loggerContext,
      required this.typeName,
      required this.level,
      this.payload,
      this.title})
      : id = customId ??
            Logger.of(loggerContext).loggerIdGenerator.generateString(),
        time = DateTime.now();

  ///
  BuildContext loggerContext;

  ///
  DateTime time;

  ///
  String id, typeName;

  ///
  String? title;

  ///
  LogLevel level;

  ///
  Map<String, dynamic>? payload;
}

///
enum LogLevel {
  ///
  verbose,

  ///
  info,

  ///
  warn,

  ///
  error,

  ///
  important
}
