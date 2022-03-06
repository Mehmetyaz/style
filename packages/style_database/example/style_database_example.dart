
import 'dart:math';

import 'package:style_database/src/database/database.dart';
import 'package:style_query/style_query.dart';

void main() {
  // var st = Stopwatch()..start();
  // var file = File(
  //     "/home/mehmet/projects/style/packages/style_database/example/js3.tss");
  // print(file.readAsStringSync());
  // // if (file.existsSync()) {
  // //   file.deleteSync();
  // // }
  // //
  // // file.createSync();
  //
  // var rand = file.openSync(mode: FileMode.append);
  //
  // rand.setPositionSync(28);
  // rand.writeFromSync(utf8.encode("0123" * 1));
  // //rand.setPositionSync(40);
  // //
  // //rand.setPositionSync(60);
  // // rand.truncateSync(1);
  // //
  // // rand.setPositionSync(4);
  // //
  // //rand.writeFromSync(utf8.encode("abcd" * 1));
  //
  // print(st.elapsedMilliseconds);
  //
  // // rand.flushSync();
  // rand.close();
  //
  // print(file.readAsStringSync());
  //
  // return;
  //
  var db = Database();

  db.createIndexes("collection1", "value");
  var st = Stopwatch()..start();
  var i = 0;
  while (i < 3) {
    db.create(CommonAccess(
        type: AccessType.create,
        collection: "collection1",
        create:
            CommonCreate({"Hello": "World!", "value": Random().nextInt(300)})));
    i++;
  }


  print(db.collections["collection1"]!.indexes["value"]!.getIndex);

  print(st.elapsedMilliseconds);



  // var a = 10;
  // var b = 2;
  //
  // var ex = GreaterExpression(b);
  //
  //
  // print(ex.compareTo(a));

  // var s = <int>{};
  //
  // var rand = Random();
  //
  // var i = 0;
  // while (i < 10) {
  //   s.add(rand.nextInt(100));
  //   i++;
  // }
  //
  // var list = [1, 7, 9, 12, 17, 22, 30, 35, 50, 69]; //s.toList()..sort();
  //
  // print(list);
  //
  // // print("L: ${list.length} : H: ${(list.length / 2).ceil()}");
  //
  // print(check(list, 0, -30));

  // int? res;
  // var lastIndex = (list.length / 2).ceil();
  // var g = 0;
  // while (g < list.length && res == null) {
  //   g++;
  // }
}

abstract class IndexMatch<T, K> {
  IndexMatch(this.all, this.start, this.end);

  Map<T, List<K>> all;

  ///
  int? start;

  ///
  int? end;
}

