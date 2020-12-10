import 'package:raspicam/raspicam.dart';

void main() {
  runner();
}

void runner() async {
  var rpc = Raspicam();
  rpc.start();
}
