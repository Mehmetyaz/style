

import 'package:meta/meta.dart';

///
abstract class AccessLanguage {
  ///
  String get name;
}


///
abstract class Query<T extends AccessLanguage> {
  ///
  Map<String, dynamic> toMap();

  /// AccessEvent reach data that have this key-value pair with equal or not
  /// equal operations.
  ///
  /// E.g <br>
  /// query is: <br>
  /// `{"author" : "John"}` <br>
  /// Or with sentences, "document/entry that data's `author` is equal to `John` "
  ///
  /// In the example, this query want to reach key-value
  /// pair of "author" and "John".
  ///
  /// Even if a query is not made directly for this key-value pair,
  /// it returns true if there is a possibility that this key-value pair may
  /// exist in the files that affect the result. For example query is empty
  /// and want to reach all document in the collection. In this case reaching
  /// the pair is possible.
  bool isReached(String key, String value);

  /// return null if not filtered
  FilterExpression? filteredBy(String key);

  /// AccessEvent is sort by key.<br>
  /// returns true if sorted ascending, <br>
  /// returns false if sorted descending, <br>
  /// returns null if not sorted by this key.
  bool? sortedByAsc(String key);

  ///
  bool? fieldIsExcluded(String key);

  ///
  bool? fieldIsIncluded(String key);


  /// Document limit
  int? get limit;

  /// Set document limit
  set limit(int? value);

  /// Document offset
  int? get offset;

  /// Set document offset
  set offset(int? value);
}

///
class FilterExpression {
  ///
  FilterExpression(
      {required this.filterType, required this.value, required this.key});

  ///
  final String key;

  ///
  final Object value;

  ///
  final FilterType filterType;
}

///
enum FilterType {
  ///
  gt,

  ///
  gte,

  ///
  lt,

  ///
  lte
}


///
mixin Pipeline<L extends AccessLanguage> {
  ///
  Map<String,dynamic> toMap();
}
/// Db Operation settings
abstract class OperationSettings {}


///
enum AccessType {
  ///
  read,

  ///
  readMultiple,

  ///
  create,

  ///
  update,

  ///
  exists,

  ///
  listen,

  ///
  delete,

  ///
  count,

  ///
  aggregation
}

///
@immutable
class Access<L extends AccessLanguage> {
  ///
  const Access(
      {this.query,
        this.identifier,
        required this.type,
        this.create,
        this.update,
        required this.collection,
        this.pipeline,
        this.settings});

  // ///
  // factory Access.fromMap(Map<String, dynamic> map) {
  //   return Access(
  //       identifier: map["identifier"],
  //       data: map["data"],
  //       query: map["query"] == null ? null : Query.fromMap(map["query"]),
  //       type: AccessType.values[map["type"]],
  //       collection: map["collection"],
  //
  //       /// May map contains "pipeline" key with null value
  //       /// This situation create empty pipeline
  //       pipeline: map["pipeline"]);
  // }

  ///
  final Query<L>? query;

  ///
  final Pipeline<L>? pipeline;

  ///
  final OperationSettings? settings;

  ///
  final String? identifier;

  ///
  final AccessType type;

  ///
  final String collection;

  ///
  final CreateData<L>? create;

  ///
  final UpdateData<L>? update;

  ///
  Map<String, dynamic> toMap() => {
    "collection": collection,
    "type": type.index,
    if (pipeline != null) "pipeline": pipeline,
    if (query != null) "query": query?.toMap(),
    if (identifier != null) "identifier": identifier,
  };
}



///
abstract class CreateData<L extends AccessLanguage> {
  /// Data for schema validate
  Map<String, dynamic> get data;
}


///
abstract class UpdateData<L extends AccessLanguage> {
  /// Data for schema
  Map<String, dynamic> get data;

  ///
  bool isChangedField(String key);

  ///
  UpdateDifference<T>? difference<T>(String key);

  ///
  bool keyIsRenamed(String key);

  ///
  bool keyRemoved(String key);

}

///
abstract class UpdateDifference<T> {}
