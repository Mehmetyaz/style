import 'package:style_query/style_query.dart';

///
abstract class Storage {
  ///
  Future<void> create(JsonMap object);

  ///
  JsonMap read(String id);
}
