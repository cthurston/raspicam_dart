import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:raspicam/src/raspicam_options.dart';

class Raspicam {
  String executable = 'raspistill';
  bool isRunning = false;
  bool isStarted = false;
  bool takingPhoto = false;
  late Process childProcess;
  RaspicamOptions options;

  String _currentPhoto = '';
  late DateTime _endTime;
  late DateTime _startTime;
  Completer _readyCompleter = Completer();
  Completer _takePhotoCompleter = Completer();

  Raspicam(this.options);

  Future<dynamic> start() async {
    await destroyPreviousPiCameraProcesses();
    childProcess = await Process.start(executable, options());

    isStarted = true;
    attachListeners();
    _takePhotoCompleter.complete('');
    return _readyCompleter.future;
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

    // Does not kill the process, just signals to take photo.
    childProcess.kill(ProcessSignal.sigusr1);

    return _takePhotoCompleter.future;
  }

  Future<ProcessResult> destroyPreviousPiCameraProcesses() async {
    return Process.run('pkill', ['raspistill']);
  }

  void attachListeners() {
    childProcess.stderr
        .transform(utf8.decoder)
        .transform(LineSplitter())
        .listen((data) {
      print(data);
      isRunning = isRunning || checkReady(data);

      if (isRunning && !_readyCompleter.isCompleted) {
        _readyCompleter.complete(childProcess);
      }

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
      if (!_takePhotoCompleter.isCompleted) {
        _takePhotoCompleter
            .completeError(Exception('Camera was killed while taking photo.'));
      }
    });
  }

  bool checkReady(String data) {
    return data.contains('Waiting for SIGUSR');
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
