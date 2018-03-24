/* 
 ============================================================
 Sound.pde
 ============================================================
 
 Organizes audio-related code into simple and handy interface 
 to create audio events as necessary.
 
 Requires "Sound" library to be installed, in order to work.
 
 
 ============================================================
 Part of: IAT 267 Final Project  
 
 */

import processing.sound.*; 


// Kinds of cat sounds
static final int MEOW_SHORT = 0;
static final int MEOW_LOUD = 1;
static final int PURRING = 2;
static final int MEOW_ANGRY = 3;
static final int MEOW_CURIOUS = 4;
static final int KEYSTROKE = 5;
static final int KEYSTROKE_WRONG = 6;
static final int FANFARES = 7;

class SoundPlayer {

  ArrayList<SoundFile> sounds = new ArrayList<SoundFile>();

  void preload() {
    sounds.add(new SoundFile(applet, "sounds/Meow-sound-3.wav"));
    sounds.add(new SoundFile(applet, "sounds/Cat-meowing-loudly.mp3"));    
    sounds.add(new SoundFile(applet, "sounds/Cat-purring-sound.wav"));
    sounds.add(new SoundFile(applet, "sounds/Angry-cat-sounds.mp3"));
    sounds.add(new SoundFile(applet, "sounds/Cat-meows-and-purring-sound.mp3"));
    sounds.add(new SoundFile(applet, "sounds/Typing On Keyboard-SoundBible.com-1459197142.mp3"));
    sounds.add(new SoundFile(applet, "sounds/Computer Error-SoundBible.com-399240903.mp3"));
    sounds.add(new SoundFile(applet, "sounds/Ta Da-SoundBible.com-1884170640.mp3"));
  }

  void play(int soundId, float volume) {
    if (SOUND_ENABLED) {
      for (SoundFile sound : soundPlayer.sounds)  
        sound.stop();

      soundPlayer.sounds.get(soundId).play();
      soundPlayer.sounds.get(soundId).amp(volume);
    }
  }
}
