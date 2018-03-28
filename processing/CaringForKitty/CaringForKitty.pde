/* 
 ============================================================
 SavingTheKitty.pde
 ============================================================
 
 Main Processing applet code.
 
 
 ============================================================
 Part of: IAT 267 Final Project  
 
 */

import java.util.Map;
import java.util.LinkedHashMap;

final PApplet applet = this;


// #############################################################################
// ## Constants ################################################################

static enum Step {
  START_SCREEN, ENTER_CAT_NAME, FEEDING, INSULIN, EMERGENCY, CONGRATULATIONS
}

static enum State {
  IDLE, ACTION_EXECUTING, ACTION_DONE
}

static final color WHITE = #FFFFFF;
static final color SKYBLUE = #A8D6ED;
static final color LIGHTGREEN = #A7F1C7;
static final color APRICOT = #FBCEB1;
static final color JASMINE = #F8DE7E;


// #############################################################################
// ## Code #####################################################################

// Applet-related
Map<String, Object> settings;  
Map<String, PFont> fonts;
Map<String, GraphicElement> graphics;
Map<String, String[]> visibleSets;
SoundPlayer soundPlayer;
Sensors sensors;

// Interaction-related
Step step;
boolean stepSet;
State state;
long timer;

// Variables
float glucoseLevel;


void setup() { 
  size(1024, 820);  
  background(255);

  settings = new HashMap();     
  settings.put("framerate", 60);  // fps
  settings.put("sound_enabled", true);
  settings.put("sensors_enabled", false);
  settings.put("show_debug", false);  
  settings.put("lock_controls", false);  
  settings.put("cat_name", "Kitty The Cat");  // Default

  frameRate((int)settings.get("framerate"));

  fonts = new HashMap();    
  fonts.put("primary", loadFont("fonts/Skia-Regular_Black-26.vlw"));
  fonts.put("debug", loadFont("fonts/LucidaSans-12.vlw"));

  // Insertion order defines elements' z-index (order of draw)
  graphics = new LinkedHashMap();
  graphics.put("kitty", new GKittyTheCat(282, 319, 0.5, SAD));
  graphics.put("infoboard", new GInfoBoard(0, 0));
  graphics.put("barchart", new GBarChart(500, 282));
  graphics.put("heart", new GHeart(695, 167, 98));
  graphics.put("snack", new GCatFood(70, 182));
  graphics.put("syringe", new GSyringe(399, 540));
  graphics.put("nurse", new GNurse(506, 475));
  graphics.put("prompt", new GText(120, 417, fonts.get("primary"), 18, color(0)));
  graphics.put("overlay", new GOverlay());  
  graphics.put("pressenter", new GPressEnter());  
  graphics.put("keyschart", new GKeysChart(27, 796)); 
  graphics.put("debug", new GDebug()); 

  // Describes visible elements for kinds of screens
  visibleSets = new HashMap();
  visibleSets.put("normal", new String[]{
    "kitty", "infoboard", "barchart", "heart", "prompt", "keyschart"
    });
  visibleSets.put("with_overlay", new String[]{
    "kitty", "infoboard", "overlay", "pressenter", "keyschart"
    });

  soundPlayer = new SoundPlayer();
  sensors = new Sensors();

  step = Step.START_SCREEN;
  state = State.IDLE;
}

void draw() {    
  sensors.read();

  // Hiding everything, then bringing back what is needed
  if (!stepSet)
    for (GraphicElement element : graphics.values())   
      element.visible = false;  

  // Shortcuts for convenience
  int fr = (int)settings.get("framerate");
  boolean sensors_enabled = (boolean)settings.get("sensors_enabled");
  String catName = ((String)settings.get("cat_name"));
  GKittyTheCat kitty = ((GKittyTheCat)graphics.get("kitty"));
  GBarChart barChart = ((GBarChart)graphics.get("barchart"));
  GHeart heart = ((GHeart)graphics.get("heart"));
  GCatFood snack = ((GCatFood)graphics.get("snack"));
  GSyringe syringe = ((GSyringe)graphics.get("syringe"));
  GNurse nurse = ((GNurse)graphics.get("nurse"));
  GText prompt = ((GText)graphics.get("prompt"));
  GOverlay overlay = ((GOverlay)graphics.get("overlay"));
  GPressEnter pressEnter = ((GPressEnter)graphics.get("pressenter"));  

  switch (step) { 
  case START_SCREEN:  
    if (!stepSet) {
      bgColor = WHITE;

      for (String elementKey : visibleSets.get("with_overlay"))
        graphics.get(elementKey).visible = true; 

      kitty.state = SAD; 
      overlay.state = WELCOME; 
      pressEnter.pos.y = 619; 

      stepSet = true;
    }

    break;

    // #############################################################################

  case ENTER_CAT_NAME: 
    if (!stepSet) {
      bgColor = WHITE; 

      for (String elementKey : visibleSets.get("with_overlay"))
        graphics.get(elementKey).visible = true;     

      kitty.state = SAD; 
      overlay.state = ENTER_CAT_NAME; 
      pressEnter.pos.y = 619; 

      stepSet = true;
    }

    break; 

    // #############################################################################

  case FEEDING: 
    // Initial screen
    if (!stepSet) {
      bgColor = SKYBLUE; 

      for (String elementKey : visibleSets.get("normal"))
        graphics.get(elementKey).visible = true;     

      glucoseLevel = 70;  // mg/dl

      kitty.state = SAD; 
      barChart.setLevel(glucoseLevel); 
      barChart.playAnim(BLINK, 2.0); 
      heart.pulseRate = 140; // bpm
      heart.playAnim(HEARTBEAT); 
      prompt.text = "It has been 3 hours since " + catName +  " last ate and her" + 
        " blood sugar levels have\ndropped down to 70mg/dl.\n\nFeed " + catName + 
        " a healthy snack to raise her blood glucose levels."; 
      soundPlayer.play("meow_short", 0.15);

      sensors.reset();

      state = State.IDLE; 
      timer = 0;

      stepSet = true;
    }

    // Run code only if feeding sequence is not completed by user yet
    if (state != State.ACTION_DONE) {
      if (sensors_enabled && state == State.IDLE && sensors.proximityEvent)
        state = State.ACTION_EXECUTING; 

      // Feeding process
      if (state == State.ACTION_EXECUTING) {
        if (timer == 0) {
          snack.opacity = 0;
          snack.visible = true;            
          barChart.stopAnim(BLINK); 
          barChart.playAnim(GROW, 70.0, 90.0, 4.0); 
          prompt.text = "Looks like there is some food!\nEating..."; 

          settings.put("lock_controls", true);
        }

        // Cat is successfully fed
        if (timer == 4*fr) { // 4 seconds later
          glucoseLevel = 90; 

          kitty.state = HAPPY; 
          heart.pulseRate = 60; // bpm
          prompt.text = "Great! " + catName + " just had a delicious cat snack and her"
            + "blood glucose levels\nare good now at 90mg/dl.";             
          pressEnter.pos.y = 498; 
          pressEnter.visible = true; 
          soundPlayer.play("purring", 0.5);  

          settings.put("lock_controls", false);

          state = State.ACTION_DONE;
          timer = 0;
        }

        timer += 1;
      }
    }

    break; 

    // #############################################################################

  case INSULIN: 
    // Initial screen
    if (!stepSet) {
      bgColor = APRICOT; 

      for (String elementKey : visibleSets.get("normal"))
        graphics.get(elementKey).visible = true;     

      glucoseLevel = 230;  // mg/dl

      kitty.state = SAD; 
      barChart.setLevel(glucoseLevel); 
      barChart.playAnim(BLINK, 2.0); 
      heart.pulseRate = 180; // bpm
      heart.playAnim(HEARTBEAT); 
      syringe.opacity = 255;
      prompt.text = catName + " has just eaten a high sugar meal.\n\n" + 
        "Administer " + catName + "'s insulin to help reduce blood glucose " + 
        "levels using\nthe slider.";        
      soundPlayer.play("meow_angry", 0.4);

      state = State.IDLE; 
      timer = 0;

      stepSet = true;
    }

    // Run code only if insulin sequence is not completed by user yet
    if (state != State.ACTION_DONE) {     
      if (sensors_enabled) 
        state = (sensors.sliderDelta > 0.0F) ? State.ACTION_EXECUTING : State.IDLE;

      syringe.visible = (state == State.ACTION_EXECUTING) | (sensors.sliderDeltaNormalized > 0.0078F);

      // Insulin flowing process
      if (state == State.ACTION_EXECUTING) {
        float d = abs(sensors_enabled ? sensors.sliderDelta : 10) * 0.05;  // set flow speeds here
        glucoseLevel -= abs(d); 

        barChart.setLevel(glucoseLevel);

        // Insulin is successfully administered
        if (glucoseLevel <= 90.0F) {
          kitty.state = HAPPY; 
          barChart.stopAnim(BLINK); 
          heart.pulseRate = 55; // bpm
          syringe.visible = false; 
          prompt.text = "Awesome! " + catName + " relies on insulin to cope with glucose"
            + " level peaks.\nHer condition came back to normal."; 
          pressEnter.pos.y = 497; 
          pressEnter.visible = true;       
          soundPlayer.play("purring", 0.5); 

          state = State.ACTION_DONE;
        }

        timer += 1;
      }
    }

    break; 

    // #############################################################################

  case EMERGENCY : 
    // Initial screen
    if (!stepSet) {
      bgColor = LIGHTGREEN; 

      for (String elementKey : visibleSets.get("normal"))
        graphics.get(elementKey).visible = true;     

      glucoseLevel = 20;  // mg/dl

      kitty.state = SAD; 
      barChart.setLevel(glucoseLevel); 
      barChart.playAnim(BLINK, 8.0); 
      heart.pulseRate = 240; // bpm
      heart.playAnim(HEARTBEAT); 
      prompt.text = "Uh oh! " + catName + "is experiencing shakiness, chills and" + 
        " light headedness\n- symptoms of hypoglycemia (very low blood glucose" +  
        " levels).\n\nPress the nurse call buttom for emergency assistance!";
      soundPlayer.play("meow_loud", 0.4);

      state = State.IDLE; 
      timer = 0;

      stepSet = true;
    }

    // Run code only if nurse sequence is not completed by user yet
    if (state != State.ACTION_DONE) {  
      if (sensors_enabled && sensors.force > 150)
        state = State.ACTION_EXECUTING;

      // Nurse's caring process
      if (state == State.ACTION_EXECUTING) {
        if (timer == 0) {
          settings.put("lock_controls", true);

          nurse.visible = true; 
          nurse.playAnim(APPEARING); 
          prompt.text = "Hold on, poor " + catName + "! Help is coming!";
        } //

        else if (timer == 258) {
          prompt.text = "It's alright, nurse is here. She will take care of our kitty."; 
          barChart.stopAnim(BLINK);
        } //

        else if (timer == 350) 
          barChart.playAnim(GROW, glucoseLevel, 70.0, 3.0);

        else if (timer == 640) {
          kitty.state = HAPPY; 
          barChart.stopAnim(GROW); 
          heart.pulseRate = 55; // bpm
          nurse.visible = false; 
          prompt.text = "Good job! " + catName + " is grateful to you for rescuing " +  
            "her. She feels good\nnow and going to jump outside to play."; 
          pressEnter.pos.y = 497; 
          pressEnter.visible = true; 
          soundPlayer.play("purring", 0.5);        

          settings.put("lock_controls", false);

          state = State.ACTION_DONE;
        }

        timer += 1;
      }
    }

    break; 

    // #############################################################################

  case CONGRATULATIONS: 
    if (!stepSet) {
      bgColor = JASMINE; 

      for (String elementKey : visibleSets.get("with_overlay"))
        graphics.get(elementKey).visible = true;     

      kitty.state = HAPPY; 
      overlay.state = CONGRATULATIONS; 
      pressEnter.visible = false;
      soundPlayer.play("fanfares", 0.5);

      stepSet = true;
    }  

    break;
  }

  // Master rendering code
  background(bgColor); 
  for (GraphicElement element : graphics.values())   
    element.draw();

  graphics.get("debug").visible = (boolean)settings.get("show_debug");
}


// #############################################################################
// ## Keyboard control code ####################################################

void keyPressed() {
  if ((key != CODED) && !((boolean)settings.get("lock_controls"))) {
    switch (key) {
    case '1': 
      step = Step.START_SCREEN; 
      stepSet = false;      
      break; 

    case '2': 
      step = Step.ENTER_CAT_NAME; 
      stepSet = false; 
      break; 

    case '3': 
      step = Step.FEEDING; 
      stepSet = false; 
      break; 

    case '4': 
      step = Step.INSULIN; 
      stepSet = false; 
      break; 

    case '5': 
      step = Step.EMERGENCY; 
      stepSet = false; 
      break; 

    case '6': 
      step = Step.CONGRATULATIONS; 
      stepSet = false; 
      break; 

    case 'e': 
    case 'E':
      // When sensors are unavailable, this allows testing stuff by pressing "E"
      if (state != State.ACTION_DONE) 
        switch (step) {
        case FEEDING: 
        case INSULIN: 
        case EMERGENCY: 
          state = State.ACTION_EXECUTING;
          timer = 0;
          break;
        default:
          break;
        }
      break;  

    case 'd': 
    case 'D':
      if (step != Step.ENTER_CAT_NAME)
        settings.put("show_debug", !(boolean)settings.get("show_debug"));
      break;

    case ENTER: 
      if (graphics.get("pressenter").visible) {
        step = Step.values()[(step.ordinal() + 1) % 6];
        stepSet = false;
      }
      break;
    }

    // Typing processing (for entering user cat name)
    if (step == Step.ENTER_CAT_NAME) {
      String catName = (String)settings.get("cat_name");

      if (Character.toString(key).matches("[A-Za-z]")) {
        if (textWidth(catName) >= 120) {
          soundPlayer.play("keystroke_error", 0.5);
          return;
        }        
        settings.put("cat_name", catName + key);   
        soundPlayer.play("keystroke", 0.5);
      } //

      else if (key == BACKSPACE) {
        if (catName.length() == 0) {
          soundPlayer.play("keystroke_error", 0.5);
          return;
        }
        settings.put("cat_name", catName.substring(0, catName.length()-1)); 
        soundPlayer.play("keystroke", 0.5);
      }
    }
  }
}

void keyReleased() {
  if ((key != CODED) && !((boolean)settings.get("lock_controls"))) {
    switch (key) {
    case 'e': 
    case 'E':
      if (state != State.ACTION_DONE) 
        state = State.IDLE; // Cancel ongoing action if "E" is released
      break;
    }
  }
}
