/* 
 ============================================================
 Graphics.pde
 ============================================================
 
 Collection of meaningful visual elements and animations for 
 onscreen usage.
 
 
 ============================================================
 Part of: IAT 267 Final Project  
 
 */

color bgColor;


// ##########################################################

// KittyTheCat states
static final int HAPPY = 0;
static final int SAD = 1;  

class GKittyTheCat extends VisElem {  
  int state;
  ArrayList<PImage> imgs = new ArrayList<PImage>();

  GKittyTheCat(float x, float y, float scaleFactor, int state) {
    super(x, y, scaleFactor);
    this.state = state;
    imgs.add(loadImage("images/cat_happy.png"));
    imgs.add(loadImage("images/cat_sad.png"));
  }

  void drawElement() {
    tint(255, 255);

    switch (state) {

    case HAPPY:
      image(imgs.get(HAPPY), -255, -540);
      break;
    case SAD:
      image(imgs.get(SAD), -255, -540);
      break;
    }
  }
}


// ##########################################################

class GInfoBoard extends VisElem {

  GInfoBoard(float x, float y) {  // origin is window's origin
    super(x, y);
  }

  void drawElement() {
    stroke(0);
    strokeWeight(4);
    fill(60);
    rect(459, 69, 405, 255); // frame (back)
    fill(200);
    rect(469, 76, 386, 239);  // surface
  }
}


// ##########################################################

// GBarChart animations
static final int BLINK = 0;
static final int GROW = 1;  

class GBarChart extends VisElem { 
  float barHeight = 0.0;    
  boolean barVisible = true;  
  int barGrowDirection = 1;

  GBarChart(float x, float y) {  // origin is chart origin
    super(x, y);
    anims.add(new AnimationBlink());
    anims.add(new AnimationGrow());
  }  

  void drawElement() {
    strokeWeight(2);
    stroke(0);
    line(30, 0, 160, 0);
    line(30, 0, 30, -160);
    for (int i = 0; i<= 4; i++) 
      line(20, -35*i, 30, -35*i);

    if (barVisible) {
      noStroke();
      fill(224, 61, 72);
      rect(50, -1, 50, -barHeight-1);
    }

    fill(0);
    textFont(font_primary, 14);
    text("Glucose Level", 28, 16);

    textFont(font_primary, 12);
    text("mg/dl", 11, -170);
    textAlign(RIGHT);
    text("0", 12, 3);
    text("50", 12, -32);
    text("100", 12, -67);
    text("150", 12, -102);
    text("200", 12, -137);
    textAlign(LEFT);
  }

  void setLevel(float glucoseLevel) {
    barHeight = mapLevel(glucoseLevel);
  }

  float mapLevel(float glucoseLevel) {
    return map(glucoseLevel, 0, 230, 0, 158);
  }


  class AnimationBlink extends VisElemAnimation {
    void handler() {  
      float freq = (float)params[0];  // blinking frequency in Hz

      if ((frameCount / ceil(FRAMERATE/2/freq)) % 2 == 0)
        barVisible = true;
      else
        barVisible = false;
    }

    void clean() {
      barVisible = true;
    }
  }

  class AnimationGrow extends VisElemAnimation {   
    float from, to, limit;   
    float d;  // calculated increment
    int timer;

    void pre() {
      from = mapLevel((float)params[0]); 
      to = mapLevel((float)params[1]); 
      float time = (float)params[2];
      d = abs((from-to) / (time * FRAMERATE));
      limit = time * FRAMERATE;
      timer = 0;

      barGrowDirection = (from <= to) ? 1 : -1;
    }

    void handler() {  
      if (timer <= limit) {
        barHeight += d*barGrowDirection;
      } else
        playing = false;

      timer += 1;
    }
  }
}


// ##########################################################

// GHeart animations
static final int HEARTBEAT = 0;

class GHeart extends VisElem {
  int pulseRate;

  GHeart(float x, float y, int pulseRate) {
    super(x, y);
    this.pulseRate = pulseRate;
    anims.add(new AnimationHeartbeat());
  }

  void drawElement() {
    smooth();
    noStroke();
    fill(240, 30, 50);       
    beginShape();
    vertex(50, 15);
    bezierVertex(50, -5, 90, 5, 50, 40);
    vertex(50, 15);
    bezierVertex(50, -5, 10, 5, 50, 40);
    endShape();

    stroke(240, 30, 50);
    strokeWeight(2);
    line(50, 13, 50, 38);
  }


  class AnimationHeartbeat extends VisElemAnimation {   
    int timer;

    void pre() {
      timer = 0;
    }

    void handler() {  
      float x = timer / 10.0;
      scaleFactor = 1.0 + (cos(PI*x*0.333*(pulseRate/72.0)))/((20-abs(1*(pulseRate/200.0)))*1.19);
      scaleFactor *= 1.17;

      timer += 1;
    }
  }
}


// ##########################################################

class GKeysChart extends VisElem {

  GKeysChart(float x, float y) {
    super(x, y);
  }

  void drawElement() {  
    textFont(font_debug, 14);
    fill(30);
    text("KEYS CHART", -5, 1);

    for (int i = 0; i <= 5; i++) {
      noFill();
      stroke(120);
      strokeWeight(1);
      rect(100+i*25, -15, 20, 20, 4);

      fill(120);
      textFont(font_debug, 12);
      text(i+1, 106+i*25, 0);
    }

    pushMatrix();
    translate(-30, 0);

    noFill();
    stroke(120);
    strokeWeight(1);
    rect(300, -15, 20, 20, 4);
    rect(326, -15, 45, 20, 4);
    rect(395, -15, 20, 20, 4);

    fill(120);
    text("E", 306, 0);
    text("Enter", 333.5, 0);
    text("D", 401, 0);

    fill(30);  
    textFont(font_debug, 10.4);
    text("Steps", 190, -22);
    text("Context Action", 301, -22); 
    text("Debug", 390, -22);   

    popMatrix();
  }
}


// ##########################################################

// GStartScreen states
static final int WELCOME = 0;
static final int ENTER_CAT_NAME = 1;  
static final int CONGRATULATIONS = 2;  


class GStartScreen extends VisElem {
  int state;

  GStartScreen() {
    super(0, 0);
    this.state = WELCOME;
  }

  void drawElement() {  
    noStroke();
    if (state != CONGRATULATIONS)
      fill(255, 241);
    else
      fill(BG_JASMINE, 245);

    rect(0, 0, width, height);
    fill(0, 94);
    rect(width/2 - 300, 150, 600, 80, 5); 
    textAlign(CENTER);

    fill(0, 94);
    rect(width/2 - 300, 235, 600, 350, 5);

    switch (state) {
    case WELCOME:
      fill(255);
      textFont(font_primary, 40);
      text("WELCOME", width/2, 203);

      fill(255);
      textFont(font_primary, 18); 
      text("[Text that introduces type one diabetes\nand the basics of the game]", width/2, 269);

      break;


    case ENTER_CAT_NAME:
      fill(255);
      textFont(font_primary, 40);
      text("ENTER CAT'S NAME", width/2, 200);

      pushMatrix();
      translate(0, -69);

      textFont(font_primary, 35);
      text(catName + " ", width/2, 410.5);

      if (((frameCount/15) % 2) == 0)
        fill(255); 
      else
        fill(0, 0); 
      rect(width/2 + textWidth(catName) - textWidth(catName)*0.5, 411.2, 30, -6); 

      popMatrix(); 
      break; 


    case CONGRATULATIONS : 
      fill(255); 
      textFont(font_primary, 30); 
      text("* CERTIFICATE OF COMPLETION *", width/2, 200); 

      textFont(font_primary, 36); 
      text("Game Passed!", width/2, 340); 

      textFont(font_primary, 18); 
      text(catName + " is happy and healthy and you are\nwell informed on type one diabetes!", width/2, 394); 

      break;
    }

    textAlign(LEFT);
  }
}


// ##########################################################

class GText extends VisElem {
  String text; 
  PFont font; 
  int fontSize; 
  color fontColor; 

  GText(float x, float y) {
    super(x, y);
  }

  GText(float x, float y, PFont font, int fontSize, color fontColor) {
    super(x, y); 
    this.font = font; 
    this.fontSize = fontSize; 
    this.fontColor = fontColor;
  }

  GText(float x, float y, PFont font, int fontSize, color fontColor, String text) {
    this(x, y, font, fontSize, fontColor); 
    this.text = text;
  }


  void drawElement() {
    fill(fontColor); 
    textFont(font, fontSize); 
    text(text, 0, 0);
  }
}


// ##########################################################

class GPressEnter extends VisElem {

  GPressEnter() {
    super(0, 0);
  } 

  GPressEnter(float y) {
    super(y, 0);
  } 

  void drawElement() {
    if (((frameCount/45) % 2) == 0)
      fill(0); 
    else
      fill(0, 0); 

    textAlign(CENTER); 
    textFont(font_primary, 24); 
    text("Press Enter to continue", width/2, 0); 
    textAlign(LEFT);
  }
}


// ##########################################################

class GSyringe extends VisElem {
  float opacity; 
  int fadeDirection; 
  PImage img; 

  GSyringe(float x, float y) {
    super(x, y); 
    this.opacity = 255; 
    this.img = loadImage("images/syringe.png"); 
    this.scaleFactor = 0.4; 
    this.fadeDirection = 1;
  } 

  void drawElement() {
    tint(255, opacity); 
    image(img, 0, 0); 

    if (frameCount % 2 == 0)
      opacity += 1*fadeDirection*14; 

    if (opacity >= 255)
      fadeDirection = -1; 
    else if (opacity <= 0)
      fadeDirection = 1; 

    fill(0, opacity); 
    textFont(font_primary, 40); 
    text("Injecting insulin...", 72, 216);
  }
}


// ##########################################################

// GNurse animations
static final int APPEARING = 0; 

class GNurse extends VisElem {
  float opacity; 
  PImage img; 
  float defaultX; 

  GNurse(float x, float y) {
    super(x, y); 
    this.opacity = 0; 
    this.img = loadImage("images/nurse.png"); 
    this.scaleFactor = 0.8; 
    this.defaultX = pos.x; 
    anims.add(new AnimationAppearing());
  }

  void drawElement() {
    tint(255, opacity); 
    image(img, 0, 0);
  }

  class AnimationAppearing extends VisElemAnimation {   
    int timer; 
    float targetX; 

    void pre() {
      timer = 0; 
      opacity = 0;
    }

    void handler() {  
      float x = timer / 150.0; 

      if (timer == 0)
        targetX = defaultX; 

      pos.x = targetX - (exp(10/(x+0.8))); 
      opacity += 1.2; 
      timer += 1; 

      if (abs(pos.x - targetX) < 60) {
        pos.x = targetX - 61; 
        playing = false;
      }
    }
  }
}


// ##########################################################

class GFood extends VisElem {
  float opacity; 
  PImage img; 

  GFood(float x, float y) {
    super(x, y); 
    this.opacity = 0; 
    this.img = loadImage("images/food.png"); 
    this.scaleFactor = 0.15;
  }

  void drawElement() {
    tint(255, opacity); 
    image(img, 0, 0); 

    if (opacity < 255.0) {
      if (frameCount % 2 == 0)
        opacity += 4.6;
    }
  }
}

// ##########################################################
