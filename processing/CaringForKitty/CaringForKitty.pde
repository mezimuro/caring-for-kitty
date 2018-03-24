/* 
 ============================================================
 SavingTheKitty.pde
 ============================================================
 
 Main Processing applet code.
 
 Applet Version: Milestone 2
 
 
 ============================================================
 Part of: IAT 267 Final Project  
 
 */

final PApplet applet = this;


// ##########################################################
// ## Constants #############################################

static final int FRAMERATE = 60; 
static final boolean SOUND_ENABLED = true;

// Applet states
static final int STEP_START_SCREEN = 1;
static final int STEP_ENTER_CAT_NAME = 2;
static final int STEP_FEEDING = 3;
static final int STEP_INSULIN = 4;
static final int STEP_EMERGENCY = 5;
static final int STEP_CONGRATULATIONS = 6;

// User actions
static final int ACTION_IDLE = -1;
static final int ACTION_FEED = 0;
static final int ACTION_ADMINISTER = 1;
static final int ACTION_NURSE_CALL = 2;

// Colors
static final color BG_WHITE = #FFFFFF;
static final color BG_SKYBLUE = #A8D6ED;
static final color BG_LIGHTGREEN = #A7F1C7;
static final color BG_APRICOT = #FBCEB1;
static final color BG_JASMINE = #F8DE7E;

// Misc
static final String DEFAULT_CAT_NAME = "Kitty The Cat";


// ##########################################################
// ## Code ##################################################

// Applet-related
PFont font_primary, font_debug;
ArrayList<VisElem> graphics;
SoundPlayer soundPlayer;
DebugTools debugTools;
Sensors sensors;
int timer;

boolean stepChanged;
boolean lockControls;

// Interaction-related
int step;
int action, actionTimer;
String catName;
float glucoseLevel;

// Shortcuts
GKittyTheCat kitty;
GInfoBoard infoBoard;
GBarChart barChart;
GHeart heart;
GFood food;
GSyringe syringe;
GNurse nurse;
GKeysChart keysChart;
GStartScreen startScreen;
GPressEnter pressEnter;
GText prompt;


void setup() {
  size(1024, 820);
  frameRate(FRAMERATE);
  background(255);

  sensors = new Sensors();
  sensors.serialInit(9600);

  font_primary = loadFont("fonts/Skia-Regular_Black-26.vlw");
  font_debug = loadFont("fonts/LucidaSans-12.vlw");

  // order of elements defines their z-index
  graphics = new ArrayList<VisElem>();
  graphics.add(new GKittyTheCat(282, 319, 0.5, SAD));
  graphics.add(new GInfoBoard(0, 0)); 
  graphics.add(new GBarChart(500, 282)); 
  graphics.add(new GHeart(695, 167, 98)); 
  graphics.add(new GFood(70, 182)); 
  graphics.add(new GSyringe(399, 540));  
  graphics.add(new GNurse(506, 475));
  graphics.add(new GText(120, 417, font_primary, 18, color(0))); 
  graphics.add(new GStartScreen()); 
  graphics.add(new GPressEnter());  
  graphics.add(new GKeysChart(27, 796)); 

  kitty = (GKittyTheCat)graphics.get(0);
  infoBoard = (GInfoBoard)graphics.get(1);
  barChart = (GBarChart)graphics.get(2);
  heart = (GHeart)graphics.get(3);
  food = (GFood)graphics.get(4);
  syringe = (GSyringe)graphics.get(5);
  nurse = (GNurse)graphics.get(6);
  prompt = (GText)graphics.get(7);
  startScreen = (GStartScreen)graphics.get(8);
  pressEnter = (GPressEnter)graphics.get(9);
  keysChart = (GKeysChart)graphics.get(10);

  soundPlayer = new SoundPlayer();
  soundPlayer.preload();

  debugTools = new DebugTools();
  debugTools.visible = true;

  catName = DEFAULT_CAT_NAME;
  step = STEP_START_SCREEN;
  stepChanged = false;
  action = ACTION_IDLE;
  actionTimer = 0;
  lockControls = false;
}


void draw() {    
  sensors.read();

  switch (step) {
  case STEP_START_SCREEN:
    for (VisElem el : graphics)   
      el.visible = false;  // hiding everything, then bringing back what is needed

    bgColor = BG_WHITE;
    kitty.visible = true;
    kitty.state = SAD;
    infoBoard.visible = true;
    startScreen.visible = true;
    startScreen.state = WELCOME;
    pressEnter.pos.y = 619;
    pressEnter.visible = true;
    keysChart.visible = true;

    stepChanged = true;
    break;


  case STEP_ENTER_CAT_NAME:
    for (VisElem el : graphics)   
      el.visible = false;

    bgColor = BG_WHITE;
    kitty.visible = true;
    kitty.state = SAD;
    infoBoard.visible = true;
    startScreen.visible = true; 
    startScreen.state = ENTER_CAT_NAME;
    pressEnter.pos.y = 619;
    pressEnter.visible = true;
    keysChart.visible = true;

    stepChanged = true;
    break;


  case STEP_FEEDING:

    // Initial state
    if (!stepChanged) {
      for (VisElem el : graphics)   
        el.visible = false;

      sensors.proximityEvent = false;

      bgColor = BG_SKYBLUE;
      kitty.visible = true;
      infoBoard.visible = true;
      barChart.visible = true;
      heart.visible = true;
      keysChart.visible = true;
      prompt.visible = true;

      kitty.state = SAD;
      glucoseLevel = 70;  // mg/dl
      heart.pulseRate = 140;  // bpm
      heart.playAnim(HEARTBEAT);
      barChart.setLevel(glucoseLevel);  
      barChart.playAnim(BLINK, 2.0);

      prompt.text = "It has been 3 hours since " + catName + 
        " last ate and her blood sugar levels have\ndropped down to 70mg/dl.\n\n" +
        "Feed " + catName + " a healthy snack to raise her blood glucose levels.";

      if (!stepChanged) {
        soundPlayer.play(MEOW_SHORT, 0.15);
      }

      action = ACTION_IDLE;
      actionTimer = 0;
    }

    if (sensors.proximityEvent) 
      action = ACTION_FEED;

    // Feeding the cat
    if (action == ACTION_FEED) {
      if (actionTimer == 0) {
        food.visible = true;
        food.opacity = 0;
        barChart.stopAnim(BLINK);
        barChart.playAnim(GROW, 70.0, 90.0, 4.0);
        prompt.text = "Looks like there is some food!\nEating...";        
        lockControls = true;
      }

      if (actionTimer == 4*FRAMERATE) {
        prompt.text = "Great! " + catName + " just had a delicious cat snack and its blood glucose levels\n" + 
          "are good now at 90mg/dl.";

        kitty.state = HAPPY;
        glucoseLevel = 90;
        heart.pulseRate = 60;  // bpm
        pressEnter.pos.y = 498;
        pressEnter.visible = true;

        soundPlayer.play(PURRING, 0.5);

        lockControls = false;

        action = ACTION_IDLE;
        actionTimer = 0;
      }

      actionTimer += 1;
    }

    stepChanged = true;
    break;


  case STEP_INSULIN:

    // Initial state
    if (!stepChanged) {
      for (VisElem el : graphics)   
        el.visible = false;

      bgColor = BG_APRICOT;
      kitty.visible = true;
      infoBoard.visible = true;
      barChart.visible = true;
      heart.visible = true;
      keysChart.visible = true;
      prompt.visible = true;

      kitty.state = SAD;
      glucoseLevel = 230;  // mg/dl
      heart.pulseRate = 180;  // bpm
      heart.playAnim(HEARTBEAT);
      barChart.setLevel(glucoseLevel);  
      barChart.playAnim(BLINK, 2.0);

      prompt.text = catName + " has just eaten a hugh sugar meal.\n\n" + 
        "Administer " + catName + "'s insulin to help reduce blood glucose levels using\nthe slider.";

      if (!stepChanged) {
        soundPlayer.play(MEOW_ANGRY, 0.4);
      }

      action = ACTION_IDLE;
      actionTimer = 0;
    }

    if (kitty.state == SAD) {
      if (abs(sensors.sliderDelta) > 0)
        action = ACTION_ADMINISTER;
      else
        action = ACTION_IDLE;

      if (sensors.sliderDeltaNormalized > 0.0078)
        syringe.visible = true;
      else {
        syringe.visible = false;
        syringe.opacity = 255;
      }
    } else {
      syringe.visible = false;
      syringe.opacity = 255;
    }

    // When insulin is flowing in
    if (action == ACTION_ADMINISTER) {
      barChart.setLevel(glucoseLevel);
      if (sensors.sliderDelta > 0)
        glucoseLevel -= abs(sensors.sliderDelta*0.04);  // flow speed

      if (glucoseLevel <= 90.0) {
        prompt.text = "Awesome! " + catName + " relies on insulin to cope with glucose level peaks.\n" +
          "Her condition came back to normal.";

        kitty.state = HAPPY;
        heart.pulseRate = 55;  // bpm
        pressEnter.pos.y = 497;
        pressEnter.visible = true;
        barChart.stopAnim(BLINK);

        soundPlayer.play(PURRING, 0.5);

        action = ACTION_IDLE;
      }

      actionTimer += 1;
    } 

    stepChanged = true;
    break;


  case STEP_EMERGENCY:

    // Initial state
    if (!stepChanged) {
      for (VisElem el : graphics)   
        el.visible = false;

      bgColor = BG_LIGHTGREEN;
      kitty.visible = true;
      infoBoard.visible = true;
      barChart.visible = true;
      heart.visible = true;
      keysChart.visible = true;
      prompt.visible = true;

      kitty.state = SAD;
      glucoseLevel = 20;  // mg/dl
      heart.pulseRate = 240;  // bpm
      heart.playAnim(HEARTBEAT);
      barChart.setLevel(glucoseLevel);  
      barChart.playAnim(BLINK, 8.0);

      prompt.text = "Uh oh! " + catName + "is experiencing shakiness, chills and light headedness\n" + 
        "- symptoms of hypoglycemia (very low blood glucose levels).\n\n" + 
        "Press the nurse call buttom for emergency assistance!";

      if (!stepChanged) {
        soundPlayer.play(MEOW_LOUD, 0.4);
      }

      action = ACTION_IDLE;
      actionTimer = 0;
    }

    if (kitty.state == SAD) 
      if (sensors.force > 150) 
        action = ACTION_NURSE_CALL;

    if (action == ACTION_NURSE_CALL) {

      if (actionTimer == 0) {
        nurse.visible = true;     
        nurse.playAnim(APPEARING);

        prompt.text = "Hold on, poor " + catName + "! Help is coming!";
        lockControls = true;
      }      

      if (actionTimer == 258) {
        prompt.text = "Nurse is here, she will take care of our kitty.";
        barChart.stopAnim(BLINK);
      }

      if (actionTimer == 350) {
        barChart.playAnim(GROW, glucoseLevel, 70.0, 3.0);
      }

      if (actionTimer == 640) {
        prompt.text = "Good job! " + catName + " is grateful to you for rescuing her. She feels good\n" 
          + "now and going to jump outside to play.";
        barChart.stopAnim(GROW);

        kitty.state = HAPPY;
        heart.pulseRate = 55;  // bpm
        nurse.visible = false;
        pressEnter.pos.y = 497;
        pressEnter.visible = true;

        soundPlayer.play(PURRING, 0.5);

        lockControls = false;

        action = ACTION_IDLE;
      }

      actionTimer += 1;
    } else {
      syringe.visible = false;
      syringe.opacity = 255;
    }

    stepChanged = true;
    break;

  case STEP_CONGRATULATIONS:
    for (VisElem el : graphics)   
      el.visible = false;  

    bgColor = BG_JASMINE;
    kitty.visible = true;
    kitty.state = SAD;
    infoBoard.visible = true;
    startScreen.visible = true;
    startScreen.state = CONGRATULATIONS;
    keysChart.visible = true;

    if (!stepChanged) {
      soundPlayer.play(FANFARES, 0.5);
    }

    stepChanged = true;
    break;
  }

  // Main drawing code
  background(bgColor);
  for (VisElem el : graphics)   
    el.draw();

  debugTools.draw();
}

void keyPressed() {
  if ((key != CODED) && !lockControls) {
    char pressed = java.lang.Character.toLowerCase(key);

    switch (pressed) {
    case '1':
      step = STEP_START_SCREEN;
      stepChanged = false;
      break;

    case '2':
      step = STEP_ENTER_CAT_NAME;
      stepChanged = false;
      break;

    case '3':
      step = STEP_FEEDING;
      stepChanged = false;
      break;

    case '4':
      step = STEP_INSULIN;
      stepChanged = false;
      break;

    case '5':
      step = STEP_EMERGENCY;
      stepChanged = false;
      break;

    case '6':
      step = STEP_CONGRATULATIONS;
      stepChanged = false;
      break;

    case 'd':
      if (step != STEP_ENTER_CAT_NAME)
        debugTools.visible = !debugTools.visible;
      break;

    case 'e':
      switch (step) {
      case STEP_FEEDING:
        if (kitty.state == SAD) {
          action = ACTION_FEED;
          actionTimer = 0;
        }             
        break;

      case STEP_INSULIN:
        if (kitty.state == SAD) {
          action = ACTION_ADMINISTER;
          actionTimer = 0;
        }         
        break;

      case STEP_EMERGENCY:
        if (kitty.state == SAD) {
          action = ACTION_NURSE_CALL;
          actionTimer = 0;
        }         
        break;
      }

      break;

    case ENTER:
      if (pressEnter.visible) {
        step = (step % 6) + 1;
        stepChanged = false;
      }      
      break;
    }

    if (step == STEP_ENTER_CAT_NAME) {
      if ((((key >= 'A') && (key <= 'Z')) || ((key >= 'a') && (key <= 'z'))) && (textWidth(catName) < 120)) {
        catName += key;
        soundPlayer.play(KEYSTROKE, 0.5);
      } else if (key != '2')
      soundPlayer.play(KEYSTROKE_WRONG, 0.5);

      if (key == BACKSPACE) {
        if (catName.length() > 0) {
          catName = catName.substring(0, catName.length()-1);
          soundPlayer.play(KEYSTROKE, 0.5);
        } else 
        soundPlayer.play(KEYSTROKE_WRONG, 0.5);
      }
    }
  }
}

void keyReleased() {
  if ((key != CODED) && !lockControls) {
    char pressed = java.lang.Character.toLowerCase(key);

    switch (pressed) {
    case 'e':
      action = ACTION_IDLE;
      break;
    }
  }
}
