/* 
 ============================================================
 Sensors.pde
 ============================================================
 
 Interface for accessing hardware sensors (slider, proximity,
 force) and some signal processing code.
 
 Requires "Serial" library to be installed, in order to work.
 
 
 ============================================================
 Part of: IAT 267 Final Project  
 
 */

import processing.serial.*;


class Sensors {
  Serial port;  
  String portName;
  byte[] buffer;

  // Becomes true when sensors start receiving data
  boolean init;

  // Amount of reading cycles passed  
  long ticks;

  // Stores first-handed sensors data
  int slider;
  int proximity;
  int force;

  // Stores processed sensors data
  float proximityNormalized;
  float proximityNormalizedShift; 
  long ticksShift;
  boolean proximityEvent;
  int sliderPast, sliderDelta;
  float sliderDeltaNormalized;


  Sensors() {
    this(null, 9600);
  }

  Sensors(String portName) {
    this(portName, 9600);
  }

  Sensors(String portName, int baudRate) {
    if ((boolean)settings.get("sensors_enabled") == false)
      return;

    if (portName == null) {
      String portNameFound = findAvailablePort();

      if (portNameFound == null) 
        throw new java.lang.Error("No available COM ports were found");

      portName = portNameFound;
    }

    this.port = new Serial(applet, portName, baudRate);
    this.portName = portName;
    this.buffer = new byte[255];
  }

  // Tries to automatically find the proper serial port
  String findAvailablePort() {
    int i, n = Serial.list().length;

    if (n == 0) 
      return null;  // exit if no ports available

    for (i = 0; i < n; i++)  
    try {
      Serial testPort = new Serial(applet, Serial.list()[i]);
      testPort.stop();
    }
    catch (Exception e) {
    }

    // returns last port from the list of available ones
    return Serial.list()[i-1];
  }

  void read() {
    if ((boolean)settings.get("sensors_enabled") == false)
      return;

    if (port.available() > 0) { 
      port.readBytesUntil('&', buffer);  // read in all data until '&' is encountered

      if (buffer != null) {
        String myString = new String(buffer);

        // p is all sensor data (with delimiters) ('&' is eliminated) 
        String[] p = splitTokens(myString, "&");  

        if (p.length < 2) 
          return;  // exit if packet is broken


        // ## Proximity sensor reading #################################################

        String[] proximity_sensor = splitTokens(p[0], "c"); 

        if (proximity_sensor.length != 3) 
          return;  // exit if packet is broken
        this.proximity = int(proximity_sensor[1]);


        // ## Slider sensor reading ####################################################

        String[] slider_sensor = splitTokens(p[0], "b");  

        if (slider_sensor.length != 3) 
          return;  // exit if packet is broken
        this.slider = int(slider_sensor[1]);


        // ## Force sensor reading #####################################################

        String[] force_sensor = splitTokens(p[0], "a"); 

        if (force_sensor.length != 3) 
          return;  // exit if packet is broken
        this.force = int(force_sensor[1]);
      }


      // ## Signal processing ########################################################

      if (!init) {
        if (proximity == 0)
          return;  // exit if there is no data coming in yet

        this.init = true;
      }

      // If this cycle is the first
      if (ticks == 0) {
        proximityNormalized = proximity;  // "normalized" means "average over time"
        sliderPast = slider;         
        return;  // exit as there is nothing else to do in the first cycle
      }

      proximityNormalized = ((ticks-1)*proximityNormalized + proximity) / ticks;
      sliderDelta = slider - sliderPast; 

      // If this cycle is the second
      if (ticks == 1) {
        sliderDeltaNormalized = sliderDelta; 
        return;  // exit as there is nothing else to do in the second cycle
      }

      sliderDeltaNormalized = ((ticks-1)*sliderDeltaNormalized + sliderDelta) / ticks;

      if (sliderDelta == 0)
        sliderDeltaNormalized *= 0.95;  // damping when base value is zero (for smooth syringe animation)


      // ## -- Smooth proximity detection #############################################

      // when major shift in average proximity has occured 
      if (abs(proximity - proximityNormalized) > 30.0F) {      
        proximityNormalizedShift = proximityNormalized;  // memorize average at the moment of the shift
        proximityNormalized = proximity;  // reset average
        ticksShift = ticks;  // memorize the moment of shift       
      }

      // if this deviation is persistent enough...
      if ((ticks - ticksShift) >= 30) 
        // ...and it really looks like there were no objects but now there are
        if ((proximityNormalizedShift > 100.0) && (proximityNormalized < 35.0F))
          proximityEvent = true;  // ...fire the proximity event!

      // #############################################################################

      ticks += 1;
    }
  }

  void reset() {
    proximityEvent = false;
  }
}
