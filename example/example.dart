import 'dart:convert';
import 'dart:io';

import 'package:raspicam/src/raspicam.dart';
import 'package:raspicam/src/raspicam_options.dart';

void main() {
  runner();
}

Stream<String> readLine() =>
    stdin.transform(utf8.decoder).transform(const LineSplitter());

void processLine(String line) {
  print(line);
}

void runner() async {
  var opts = RaspicamOptions();
  opts.width = 360;
  opts.height = 360;
  opts.previewHeight = 640;
  opts.previewX = 1200;
  opts.awb = 'off';
  opts.datetime = true;
  opts.folder = './test';

  print(opts());

  var rpc = Raspicam(opts);
  await rpc.start();
  var p1 = await rpc.takePhoto();
  print('Took a photo ${p1}');

  print('Press p to take more photos, anything else to exit.');
  readLine().listen((line) async {
    if (line.contains('p')) {
      var myPhoto = await rpc.takePhoto();
      print(myPhoto);
    } else {
      rpc.stop();
    }
  });
}
