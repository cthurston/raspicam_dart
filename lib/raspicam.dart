import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:raspicam/raspicam_options.dart';

class Raspicam {
  bool isStarted = false;
  bool isRunning = false;
  bool takingPhoto = false;
  late Process childProcess;
  String executable = 'raspistill';
  RaspicamOptions options;

  String _currentPhoto = '';
  late DateTime _startTime;
  late DateTime _endTime;
  Completer _takePhotoCompleter = Completer();

  Raspicam(this.options);

  void start() async {
    await destroyPreviousPiCameraProcesses();
    childProcess = await Process.start(executable, options());
    isStarted = true;
    attachListeners();
    _takePhotoCompleter.complete('');
  }

  void stop() {
    childProcess.kill();
  }

  Future<dynamic> takePhoto() {
    if (!isRunning) {
      throw Exception('Camera is not running.');
    }

    if (!_takePhotoCompleter.isCompleted) {
      throw Exception('Still processing last photo.');
    }

    _takePhotoCompleter = Completer();

    childProcess.kill(ProcessSignal.sigusr1);

    return _takePhotoCompleter.future;
  }

  Future<ProcessResult> destroyPreviousPiCameraProcesses() async {
    return Process.run('pkill', ['raspistill']);
  }

  void attachListeners() {
    childProcess.stderr.transform(utf8.decoder).listen((data) {
      print(data);
      isRunning = isRunning || checkReady(data);

      if (openingFile(data)) {
        _currentPhoto = parseOpeningFile(data);
      }
      if (checkStartingCapture(data)) {
        _startTime = DateTime.now();
      }
      if (checkFinishedCapture(data)) {
        _endTime = DateTime.now();
        print(_endTime.difference(_startTime));
        _takePhotoCompleter.complete(_currentPhoto);
      }
    });

    childProcess.exitCode.then((code) {
      print('Got an exit code $code');
      isRunning = false;
      isStarted = false;
    });
  }

  void killChildProcess() {
    childProcess.kill();
  }

  bool checkReady(String data) {
    return data.contains('SIGUSR');
  }

  bool checkStartingCapture(String data) {
    return data.contains('Starting capture');
  }

  bool checkFinishedCapture(String data) {
    return data.contains('Finished capture');
  }

  bool openingFile(String data) {
    return data.contains('Opening output file');
  }

  String parseOpeningFile(String data) {
    return data.replaceAll('Opening output file', '').trim();
  }
}
