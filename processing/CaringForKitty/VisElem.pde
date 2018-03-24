/* 
 ============================================================
 VisElem.pde
 ============================================================

 Base class for visual elements like heart, bar chart, etc.
 Easy animations making, tools for quick customization.
 
 
 ============================================================
 Part of: IAT 267 Final Project  
 
 */

abstract class VisElem { 

  // Stores element's position as window coordinates
  PVector pos;

  // Stores scaling coefficient to control element's size
  float scaleFactor = 1.0; 

  // Visibility switch to make element hidden if needed
  boolean visible = true;

  // Stores supported animations, using animation codes as indexes
  ArrayList<VisElemAnimation> anims = new ArrayList<VisElemAnimation>();


  VisElem(float x, float y) {
    this.pos = new PVector(x, y);
  }     

  // Another constructor variant 
  VisElem(float x, float y, float scaleFactor) {
    this(x, y);
    this.scaleFactor = scaleFactor;
  }

  void processAnimations() {
    for (VisElemAnimation anim : anims)   
      if (anim.playing)
        anim.handler();
  }

  void playAnim(int animCode, Object... args) {
    VisElemAnimation anim = anims.get(animCode);

    anim.params = args;
    anim.pre();
    anim.playing = true;
  }

  void stopAnim(int animCode) {
    VisElemAnimation anim = anims.get(animCode);

    anim.playing = false;
    anim.clean();
  }

  // Master rendering code
  void draw() {
    pushMatrix();

    translate(pos.x, pos.y);
    scale(scaleFactor);

    if (visible)
      drawElement();
    processAnimations();

    popMatrix();
  }

  // Element-specific rendering code
  abstract void drawElement();
}


abstract class VisElemAnimation {

  // True if animation is active
  boolean playing = false;

  // Stores animation's parameters
  Object[] params;

  // Actual animation code
  abstract void handler();
  
  // Code to execute when animation is started (optional)
  void pre() {
  }
  
  // Code to execute when animation is stopped (optional)
  void clean() {
  }
}
