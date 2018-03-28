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

  // Visibility switch to make element hidden if needed
  boolean visible = true;

  // Stores supported animations, using animation codes as indexes
  ArrayList<GraphicElementAnimation> anims = new ArrayList<GraphicElementAnimation>();


  GraphicElement(float x, float y) {
    this.pos = new PVector(x, y);
  }     

  // Another constructor variant 
  GraphicElement(float x, float y, float scaleFactor) {
    this(x, y);
    this.scaleFactor = scaleFactor;
  }

  void processAnimations() {
    for (GraphicElementAnimation anim : anims)   
      if (anim.playing)
        anim.handler();
  }

  void playAnim(int animCode, Object... args) {
    GraphicElementAnimation anim = anims.get(animCode);

    anim.params = args;
    anim.pre();
    anim.playing = true;
  }

  void stopAnim(int animCode) {
    GraphicElementAnimation anim = anims.get(animCode);

    anim.playing = false;
    anim.clean();
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

  // Actual animation code
  abstract void handler();

  // Code to execute once when animation is started (optional)
  void pre() {
  }

  // Code to execute once when animation is stopped (optional)
  void clean() {
  }
}
