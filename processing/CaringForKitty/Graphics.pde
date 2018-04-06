/* 
 ============================================================
 Graphics.pde
 ============================================================
 
 List and implementations of all graphic elements that are 
 used onscreen.
 
 
 ============================================================
 Part of: IAT 267 Final Project  
 
 */

color bgColor;
int fr;  // shortcut to get the set framerate
float fraf; // framerate adjust factor


// Returns a framerate-adjusted time interval
int secsToFrames(float seconds) {
  return round(seconds * fr);
}


// #############################################################################

class GKittyTheCat extends GraphicElement {  

  GKittyTheCat(float x, float y, float scaleFactor, String state) {
    super(x, y, scaleFactor, state);
    this.images.put("happy", loadImage("images/cat_happy.png"));
    this.images.put("sad", loadImage("images/cat_sad.png"));
  }

  void drawElement() {
    image(images.get(state), -255, -540);
  }
}


// #############################################################################

class GInfoBoard extends GraphicElement {

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


// #############################################################################

class GBarChart extends GraphicElement {   
  float barHeight = 0.0;     
  int barGrowDirection = 1;
  boolean barVisible = true;  

  GBarChart(float x, float y) {  // origin is chart origin
    super(x, y);
    this.anims.put("blink", new AnimationBlink());
    this.anims.put("grow", new AnimationGrow());
  }  

  void drawElement() {
    // axes and scale
    strokeWeight(2);
    stroke(0);
    line(30, 0, 160, 0);
    line(30, 0, 30, -160);
    for (int i = 0; i <= 4; i++) 
      line(20, -35*i, 30, -35*i);

    // the red bar
    if (barVisible) {      
      fill(COL_STRAWBERRY);
      noStroke();
      rect(50, -1, 50, -barHeight-1);
    }

    // markings and labels
    fill(0);
    textFont(fonts.get("frutiger14"), 14);
    text("Glucose Level", 33.8, 16);
    textFont(fonts.get("frutiger12"), 12);   
    textAlign(RIGHT);
    text("0", 12, 4);
    text("50", 12, -31);
    text("100", 12, -66);
    text("150", 12, -101);
    text("200", 12, -136);
    textAlign(LEFT);
    text("mg/dl", 12, -170);
  }

  float mapLevel(float glucoseLevel) {
    return map(glucoseLevel, 0, 230, 0, 158);  // maps glucose value to bar's onscreen height
  }

  void setLevel(float glucoseLevel) {
    barHeight = mapLevel(glucoseLevel);
  }


  class AnimationBlink extends GraphicElementAnimation {
    void handler() {  
      float freq = (float)params[0];  // blinking frequency in Hz

      if ((frameCount / ceil(fr/2.0F/freq)) % 2 == 0)
        barVisible = true;
      else
        barVisible = false;
    }

    void clean() {
      barVisible = true;
    }
  }

  class AnimationGrow extends GraphicElementAnimation {    
    float from, to;   
    float d;  // computed increment
    int frames_num;

    void pre() {
      from = (float)params[0]; 
      to = (float)params[1]; 
      float time = (float)params[2];

      d = abs(mapLevel(from-to) / (time * fr));
      frames_num = round(time * fr);    
      barGrowDirection = (from <= to) ? 1 : -1;

      timer = 0;
    }

    void handler() {  
      if (timer < frames_num) 
        barHeight += d*barGrowDirection;
      else
        playing = false;

      timer += 1;
    }
  }
}


// #############################################################################

// Credits to Luciana from:
// https://www.processing.org/discourse/beta/num_1246205739.html

class GHeart extends GraphicElement {  
  int pulseRate;

  GHeart(float x, float y, int pulseRate) {
    super(x, y);
    this.pulseRate = pulseRate;
    this.anims.put("heartbeat", new AnimationHeartbeat());
  }

  void drawElement() {
    smooth();
    fill(COL_IMPERIALRED);  
    noStroke();

    // heart's shape
    beginShape();
    vertex(50, 15);
    bezierVertex(50, -5, 90, 5, 50, 40);
    vertex(50, 15);
    bezierVertex(50, -5, 10, 5, 50, 40);
    endShape();

    // correction
    stroke(COL_IMPERIALRED);
    strokeWeight(2);
    line(50, 13, 50, 38);
  }


  class AnimationHeartbeat extends GraphicElementAnimation {       
    void pre() {
      timer = 0;
    }

    void handler() {  
      float x = timer * (6.0/fr);
      scaleFactor = 1.0 + (cos(PI*x*0.333*(pulseRate/72.0)))/((20-abs(1*(pulseRate/200.0)))*1.19);  // pulsating
      scaleFactor *= 1.17;

      timer += 1;
    }
  }
}


// #############################################################################

class GKeysChart extends GraphicElement {

  GKeysChart(float x, float y) {
    super(x, y);
  }

  void drawElement() {  
    fill(30);
    textFont(fonts.get("debug"), 14);    
    text("KEYS CHART", -5, 1);

    for (int i = 0; i <= 5; i++) {
      noFill();
      stroke(120);
      strokeWeight(1);
      rect(100+i*25, -15, 20, 20, 4);

      fill(120);
      textFont(fonts.get("debug"), 12);
      text(i+1, 106+i*25, 0);
    }

    pushMatrix();
    translate(-30, 0);  // adjustable horizontal alignment

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
    textFont(fonts.get("debug"), 10.4);
    text("Steps", 190, -22);
    text("Context Action", 301, -22); 
    text("Debug", 390, -22);   

    popMatrix();
  }
}


// #############################################################################

class GOverlay extends GraphicElement {

  GOverlay() {
    super(0, 0, 1.0, "welcome");
  }

  void drawElement() {  
    String catName = ((String)settings.get("cat_name"));

    noStroke(); 
    textAlign(CENTER);

    // background
    if (state != "congratulations")
      fill(255, 241);
    else
      fill(COL_JASMINE, 245);
    rect(0, 0, width, height);    

    // content
    fill(0, 94);
    rect(width/2 - 300, 150, 600, 80, 5); 
    rect(width/2 - 300, 235, 600, 350, 5);

    // text
    fill(255);
    switch (state) {
    case "welcome":
      textFont(fonts.get("header"), 40);
      text("WELCOME", width/2, 204);

      textFont(fonts.get("frutiger18"), 18);  
      textLeading(30);
      text("Caring for Kitty is an interactive program that allows\nthe user to" +
        " assist an animated character with\ntype 1 diabetes as they experience" + 
        " different symptoms.", width/2, 269);

      break;

    case "enter_cat_name":
      textFont(fonts.get("header"), 40);
      text("ENTER CAT'S NAME", width/2, 204);

      pushMatrix();
      translate(0, -69); // adjustable horizontal alignment

      textFont(fonts.get("frutiger35"), 35);
      text(catName + " ", width/2, 400.5);

      if ((frameCount/round(fr/4)) % 2 == 0)
        fill(255); 
      else
        fill(0, 0); 
      rect(width/2 + textWidth(catName) - textWidth(catName)*0.5 + 2, 400.7, 20, -5); 

      popMatrix();     
      break; 

    case "congratulations": 
      textFont(fonts.get("header_smaller"), 36);
      text("* CERTIFICATE OF COMPLETION *", width/2, 203); 

      textFont(fonts.get("frutiger35"), 36); 
      text("Game Passed!", width/2, 340); 

      textFont(fonts.get("frutiger18"), 18); 
      text(catName + " is happy and healthy and you are\nwell informed now on type one diabetes!", width/2, 394); 

      break;
    }

    textAlign(LEFT);
  }
}


// #############################################################################

class GText extends GraphicElement {
  String text; 
  PFont font; 
  int fontSize; 
  color fontColor; 


  GText(float x, float y) {
    super(x, y);
  }

  GText(float x, float y, PFont font, int fontSize, color fontColor, String text) {
    super(x, y); 
    this.font = font; 
    this.fontSize = fontSize; 
    this.fontColor = fontColor;
    this.text = text;
  }

  GText(float x, float y, PFont font, int fontSize, color fontColor) {
    this(x, y, font, fontSize, fontColor, "");
  }

  void drawElement() {
    fill(fontColor); 
    textFont(font, fontSize); 
    text(text, 0, 0);
  }
}


// #############################################################################

class GPressEnter extends GraphicElement {

  GPressEnter() {
    super(0, 0);
  } 

  GPressEnter(float y) {
    super(y, 0);
  } 

  void drawElement() {
    if ((frameCount/round(fr*0.75)) % 2 == 0)
      fill(0); 
    else
      fill(0, 0); 

    textAlign(CENTER); 
    textFont(fonts.get("frutiger24"), 24); 
    text("Press Enter to continue", width/2, 0); 
    textAlign(LEFT);
  }
}


// #############################################################################

class GSyringe extends GraphicElement {
  int fadeDirection; 

  GSyringe(float x, float y) {
    super(x, y, 0.4); 
    this.images.put("main", loadImage("images/syringe.png")); 
    this.fadeDirection = 1;
  } 

  void drawElement() {
    image(images.get("main"), 0, 0); 

    // animated (fade in/out) syringe image
    opacity += 1*fadeDirection*7*fraf; 
    if (opacity >= 255)
      fadeDirection = -1; 
    else if (opacity <= 0)
      fadeDirection = 1; 

    // image subtitle
    fill(0, opacity); 
    textFont(fonts.get("frutiger48"), 48); 
    text("Injecting insulin...", 72, 216);
  }
}


// #############################################################################

class GNurse extends GraphicElement {
  PImage img; 
  float defaultX; 

  GNurse(float x, float y) {
    super(x, y, 0.8); 
    this.images.put("main", loadImage("images/nurse.png"));   
    this.anims.put("come_in", new AnimationComeIn());
    this.defaultX = pos.x;
  }

  void drawElement() {
    image(images.get("main"), 0, 0);
  }


  class AnimationComeIn extends GraphicElementAnimation {    
    float targetX; 

    void pre() {
      timer = 0; 
      opacity = 0;
    }

    void handler() {  
      float x =(timer/150.0) * fraf; 

      if (timer == 0)
        targetX = defaultX; 

      pos.x = targetX - exp(10/(x+0.8)); 
      opacity += 1.2 * fraf; 

      if (abs(pos.x - targetX) < 60) {
        pos.x = targetX - 61; 
        playing = false;
      }

      timer += 1;
    }
  }
}


// #############################################################################

class GCatFood extends GraphicElement {

  GCatFood(float x, float y) {
    super(x, y, 0.5); 
    this.images.put("main", loadImage("images/mouse.png"));
    this.anims.put("fade_in", new AnimationFadeIn());
  }

  void drawElement() {
    image(images.get("main"), 0, 0);
  }


  class AnimationFadeIn extends GraphicElementAnimation {   
    void pre() {
      timer = 0; 
      opacity = 0;
    }

    void handler() {  
      if (opacity < 255.0) 
        opacity += 2.9 * fraf;
    }
  }
}


// #############################################################################

class GDebug extends GraphicElement {

  GDebug() {
    super(0, 0);
  }

  void drawElement() {
    fill(30);
    textFont(fonts.get("debug"), 12);
    textLeading(15);

    text("FPS: " + round(frameRate) + "\nmouseX: " + (mouseX) + ", mouseY: " +
      (mouseY) + "\n\nport: " + sensors.portName + "\nslider: " + sensors.slider 
      + "\nproximity: " + sensors.proximity + "\nforce: " + sensors.force, 5, 15);
  }
}
