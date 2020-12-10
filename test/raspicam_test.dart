// @dart=2.9
import 'package:test/test.dart';
import 'package:raspicam/raspicam.dart';

void main() {
  test('raspicam', () async {
    var rpc = Raspicam();
    await rpc.start();
  });
}
