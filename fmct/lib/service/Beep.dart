// ignore_for_file: file_names
import 'package:just_audio/just_audio.dart';

bool busy = false;

class Beep {
  AudioPlayer audioPlayer = AudioPlayer();

  Future<Beep> init() async {
    await audioPlayer.setAsset('assets/sound/y2181.mp3');
    return this;
  }

  void play() async {
    if (busy) {
      return;
    }
    busy = true;
    audioPlayer.play().then((value) {
      busy = false;
    });
  }
}
