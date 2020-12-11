// @dart=2.9
import 'package:raspicam/raspicam_options.dart';
import 'package:test/test.dart';
import 'package:raspicam/raspicam.dart';

void main() {
  test('raspicam', () async {
    var opts = RaspicamOptions();
    var rpc = Raspicam(opts);
    await rpc.start();
    var myImage = await rpc.takePhoto();
    rpc.killChildProcess();
    expect(myImage.contains('image'), true);
  });
}
