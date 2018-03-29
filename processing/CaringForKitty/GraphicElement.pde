/* 
 ============================================================
 GraphicElement.pde
 ============================================================
 
 Base class for graphic elements like heart, bar chart, etc.
 Enables easy animating, quick customization and more.
 
 
 ============================================================
 Part of: IAT 267 Final Project  
 
 */

abstract class GraphicElement { 

  // Stores element's position as coordinates
  PVector pos;

  // Stores scaling coefficient to control element's onscreen size
  float scaleFactor = 1.0; 

  // Allows element to be stateful
  String state;

  // Visibility switch to make element hidden if needed
  boolean visible = true;

  // Stores raster images that can be used by element
  Map<String, PImage> images = new HashMap();  

  // Stores supported animations, using animation ids as indexes
  Map<String, GraphicElementAnimation> anims = new HashMap();

  GraphicElement(float x, float y) {
    this.pos = new PVector(x, y);
  }     

  // Another constructor variant 
  GraphicElement(float x, float y, float scaleFactor) {
    this(x, y);
    this.scaleFactor = scaleFactor;
  }

  // Another constructor variant 
  GraphicElement(float x, float y, float scaleFactor, String state) {
    this(x, y, scaleFactor);
    this.state = state;
  }

  // Computes animations for a new frame
  void processAnimations() {
    for (GraphicElementAnimation anim : anims.values())   
      if (anim.playing)
        anim.handler();
  }

  void playAnim(String animId, Object... args) {
    GraphicElementAnimation anim = anims.get(animId);

    anim.params = args;
    anim.pre();
    anim.playing = true;
  }

  void stopAnim(String animId) {
    GraphicElementAnimation anim = anims.get(animId);

    anim.playing = false;
    anim.clean();
  }

  // If called without arguments, stops all animations
  void stopAnim() {
    for (String animId : anims.keySet())   
      if (anims.get(animId).playing)
        stopAnim(animId);
  }

  // Master rendering code
  void draw() {
    if (!visible)
      return;

    pushMatrix();
    translate(pos.x, pos.y);
    scale(scaleFactor);

    drawElement();
    processAnimations();

    popMatrix();
  }

  // Element-specific rendering code
  abstract void drawElement();
}


abstract class GraphicElementAnimation {

  // True if animation is active
  boolean playing = false;

  // Stores animation's parameters
  Object[] params;
  
  // Built-in timer
  long timer;

  // Actual animation code
  abstract void handler();

  // Code to execute once when animation is started (optional)
  void pre() {
  }

  // Code to execute once when animation is stopped (optional)
  void clean() {
  }
}
