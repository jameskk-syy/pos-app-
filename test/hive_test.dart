import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> main() async {
  debugPrint('--- STARTING HIVE TEST ---');
  await Hive.initFlutter();

  const boxName = 'test_box';
  await Hive.openBox(boxName);
  var box = Hive.box(boxName);

  await box.put('key', 'Hello World');
  debugPrint('Saved value: Hello World');

  var value = box.get('key');
  debugPrint('Retrieved value: $value');

  if (value == 'Hello World') {
    debugPrint('SUCCESS: Basic Read/Write working');
  } else {
    debugPrint('FAILURE: Read/Write mismatch');
  }
}
