/* 
 ============================================================
 Debug.pde
 ============================================================
 
 Some auxiliary stuff to ease the development process.
 
 
 ============================================================
 Part of: IAT 267 Final Project  
 
 */

class DebugTools {  
  boolean visible = false;

  void draw() {
    if (!visible) 
      return;

    textFont(font_debug, 12);
    fill(30);

    text("FPS: " + round(frameRate), 5, 15);
    text("mouseX: " + (mouseX) + ", mouseY: " + (mouseY), 5, 35);
    text("sensors: slider=" + sensors.slider + ", proximity=" + sensors.proximity + ", force=" + sensors.force, 5, 55);
  }
}
