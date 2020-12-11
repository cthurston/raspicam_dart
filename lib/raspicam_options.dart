import 'package:path/path.dart' as path;

/// Not all options are implemented. Please PR any options you need added.
class RaspicamOptions {
  int quality = 98;
  String encoding = 'jpg';
  bool datetime = false;
  bool timestamp = false;

  int width = 640;
  int height = 480;
  String output = '';
  String folder = '';
  String prefix = 'image';
  int leadingZeros = 4;

  int previewX = 0;
  int previewY = 0;
  int previewWidth = 640;
  int previewHeight = 480;
  bool noPreview = false;

  int ISO = 0;
  String exposure = 'auto';
  String awb = 'auto';
  bool hflip = true;
  bool vflip = true;
  double framesPerSecond = 30;
  double shutter = 0; //1 / 30 * 1e6;

  // Gains are ignored if exposure mode and/or ISO is set
  List<double> awbGains = [744 / 256, 489 / 256];
  double analogGain = 640 / 256;
  double digitalGain = 320 / 256;
  bool settings = false;

  List<String> call() {
    return optionsToList();
  }

  List<String> optionsToList() {
    if (shutter == 0 && framesPerSecond == 0) framesPerSecond = 30;

    return [
      '--verbose',
      '--signal',
      '--quality',
      quality.toString(),
      '--encoding',
      encoding,
      if (datetime) '--datetime',
      if (!datetime && timestamp) '--timestamp',
      '--width',
      width.toString(),
      '--height',
      height.toString(),
      '--output',
      output.isNotEmpty
          ? path.join(folder, output)
          : path.join(folder, '${prefix}_%0${leadingZeros}d.${encoding}'),
      if (noPreview) '--nopreview',
      if (!noPreview) '--preview',
      if (!noPreview)
        '${previewX},${previewY},${previewWidth},${previewHeight}',
      if (ISO > 0) '--ISO',
      if (ISO > 0) ISO.toString(),
      if (exposure != 'auto') '--exposure',
      if (exposure != 'auto') exposure,
      '--awb',
      awb,
      if (hflip) '--hflip',
      if (vflip) '--vflip',
      '--shutter',
      shutter > 0 ? shutter.toString() : (1 / framesPerSecond * 1e6).toString(),
      if (awb == 'off') '--awbgains',
      if (awb == 'off') awbGains.join(','),
      if (analogGain != 0) '--analoggain',
      if (analogGain != 0) analogGain.toString(),
      if (digitalGain != 0) '--digitalgain',
      if (digitalGain != 0) digitalGain.toString(),
    ];
  }
}
