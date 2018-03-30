/* 
 ============================================================
 Sound.pde
 ============================================================
 
 Simple monophonic sound player. 
 
 Table soundNames lists names of .mp3 files that should be 
 loaded.
 
 Requires "Sound" library to be installed, in order to work.
 
 
 ============================================================
 Part of: IAT 267 Final Project  
 
 */

import processing.sound.SoundFile; 


static final String[] soundNames = {
  "fanfares", 
  "keystroke", 
  "keystroke_error", 
  "meow_angry", 
  "meow_loud", 
  "meow_short", 
  "purring", 
  "squealing"
};


class SoundPlayer {

  Map<String, SoundFile> sounds = new HashMap();

  SoundPlayer() {
    for (String soundName : soundNames)
      sounds.put(soundName, new SoundFile(applet, "sounds/" + soundName + ".mp3"));
  }

  void play(String soundName, float volume) {
    if ((boolean)settings.get("sound_enabled") == false)
      return;

    for (SoundFile sound : sounds.values())  
      if (sound.isPlaying() != 0)
        sound.stop();

    soundPlayer.sounds.get(soundName).play();
    soundPlayer.sounds.get(soundName).amp(volume);
  }
}
