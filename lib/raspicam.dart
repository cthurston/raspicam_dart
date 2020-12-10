import 'dart:convert';
import 'dart:io';

class Raspicam {
  String workingDir = '/tmp';
  bool isStarted = false;
  bool isRunning = false;
  bool takingPhoto = false;
  late Process childProcess;
  String executable = 'raspistill';
  List<String> arguments = [
    '--width',
    '480',
    '--height',
    '480',
    '--signal',
    '--output',
    'image_%04d.jpg',
    '--preview',
    '720,0,480,480',
    '--hflip',
    '--vflip',
    '--quality',
    '99',
    '--encoding',
    'jpg',
    '--verbose',
  ];

  Raspicam();
  void start() async {
    await destroyPreviousPiCameraProcesses();

    childProcess = await Process.start(executable, arguments);
    isStarted = true;
    attachListeners();
  }

  void stop() {}

  Future<ProcessResult> destroyPreviousPiCameraProcesses() async {
    return Process.run('pkill', ['raspistill']);
  }

  void attachListeners() {
    childProcess.stderr.transform(utf8.decoder).listen((data) {
      print(data);
      isRunning = isRunning || checkReady(data);

      if (isRunning && !takingPhoto) takeSomePictures();
    });
  }

  void takeSomePictures() {
    takingPhoto = true; // Will be set from stderr
    childProcess.kill(ProcessSignal.sigusr1);
    Future.delayed(Duration(seconds: 5), killChildProcess);
  }

  void killChildProcess() {
    childProcess.kill();
  }

  bool checkReady(String data) {
    return data.contains('SIGUSR');
  }
}

class RaspicamOptions {
  bool hflip = false;
  bool vflip = false;
  int quality = 99;
  bool verbose = true;
  String output = 'image_%04d.jpg';
  String encoding = 'jpg';
  bool signal = true;
  bool keypress = false;
  bool timelapse = false;
}
