// ignore_for_file: file_names
import 'package:flutter/services.dart';
import 'package:flutter_sound/flutter_sound.dart';

FlutterSoundPlayer mPlayer = FlutterSoundPlayer();
bool hasInited = false;
bool busy = false;

class Beep {
  static Future<Uint8List> getAssetData(String path) async {
    var asset = await rootBundle.load(path);
    return asset.buffer.asUint8List();
  }

  static void init() async {
    await mPlayer.openPlayer();
    hasInited = true;
  }

  static void play() async {
    if (!hasInited || busy) {
      return;
    }
    busy = true;
    Uint8List sounder = await getAssetData('assets/sound/y2181.mp3');
    mPlayer.startPlayer(
      fromDataBuffer: sounder,
      codec: Codec.mp3,
      whenFinished: () {
        busy = false;
      },
    );
  }
}
