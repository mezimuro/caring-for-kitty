/* 
 ============================================================
 Sensors.pde
 ============================================================
 
 Interface for accessing hardware sensors (slider, proximity
 and force sensors) and some signal processing code.
 
 Requires "Serial" library to be installed, in order to work.
 
 
 ============================================================
 Part of: IAT 267 Final Project  
 
 */

import processing.serial.*;


class Sensors {

  Serial port;  
  byte[] buf;
  long ticks, proximityTicksPrev;

  int slider;
  int proximity;
  int force;

  boolean initialized;
  boolean proximityEvent;

  float proximityNormalized, proximityPrev;
  int sliderPrev;
  float sliderDelta, sliderDeltaNormalized;


  Sensors() {
    buf = new byte[255];
    ticks = 0;
  }

  void serialInit(String portId, int baudRate) {
    port = new Serial(applet, portId, baudRate);
    initialized = false;
    proximityNormalized = -1.0;
    sliderDeltaNormalized = -1.0;
    proximityEvent = false;
  }

  void serialInit(int baudRate) {
    Serial testPort = null;
    int i;

    // automatically finds the port
    for (i = 0; i < Serial.list().length; i++) {   
      try {
        testPort = new Serial(applet, Serial.list()[i], baudRate);        
        testPort.stop();
      } 
      catch (Exception e) {
      }
    }

    serialInit(Serial.list()[i-1], baudRate);
  }

  void read() {
    if (0 < port.available()) { 
      port.readBytesUntil('&', buf);  //read in all data until '&' is encountered

      if (buf != null) {
        String myString = new String(buf);
        //println(myString);   //for testing only

        //p is all sensor data (with a's and b's) ('&' is eliminated) 
        String[] p = splitTokens(myString, "&");  

        if (p.length < 2) 
          return;  //exit this function if packet is broken

        //println(p[0]);   //for testing only


        //get force sensor reading //////////////////////////////////////////////////

        String[] force_sensor = splitTokens(p[0], "a"); 
        if (force_sensor.length != 3) return;  //exit this function if packet is broken
        //println(force_sensor[1]);
        force = int(force_sensor[1]);


        //get slider sensor reading //////////////////////////////////////////////////

        String[] slider_sensor = splitTokens(p[0], "b");  
        if (slider_sensor.length != 3) return;  //exit this function if packet is broken
        //println(slider_sensor[1]);
        slider = int(slider_sensor[1]);


        //get proximity sensor reading ///////////////////////////////////////////////   

        String[] proximity_sensor = splitTokens(p[0], "c"); 
        if (proximity_sensor.length != 3) return;
        proximity = int(proximity_sensor[1]);
      }
    }


    // Values processing ///////////////////////////////////////////////

    if (initialized) {
      if (proximityNormalized < 0) {
        proximityNormalized = proximity;
      } else {
        proximityNormalized = ((ticks-1)*proximityNormalized + proximity) / ticks;
      }

      if (ticks > 1)
        sliderDelta = (slider - sliderPrev);
      sliderPrev = slider;

      if (sliderDeltaNormalized < 0) {
        sliderDeltaNormalized = sliderDelta;
      } else {
        sliderDeltaNormalized = ((ticks-1)*sliderDeltaNormalized + sliderDelta) / ticks;

        // damping when zero
        if (sliderDelta == 0.0)
          sliderDeltaNormalized *= 0.95;

        //println(sliderDeltaNormalized);
      }

      ticks += 1;
    }


    // Smooth proximity detection ///////////////////////////////////////////////  

    if (abs(proximity - proximityNormalized) > 30) {
      proximityPrev = proximityNormalized;
      proximityTicksPrev = ticks;

      proximityNormalized = -1.0;
    }

    if ((ticks - proximityTicksPrev) >= 30) {
      if ((proximityPrev > 100.0) && (proximityNormalized < 35))
        proximityEvent = true;
      //println(proximityNormalized);
    }


    if (proximity > 0.0) 
      initialized = true;
  }
}
