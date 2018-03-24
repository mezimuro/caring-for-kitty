//PROTOTYPE ARDUINO WORK 1
//MArch 16th



// Code to read values from two sensors and write them to the serial port
int val_force;
int val_slider;

#define val_trigPin 13
#define val_echoPin 12

int inputPin0 = 0; // Analog pin 0 - for force sensor
int inputPin1 = 1;  // Analog pin 1 - for slider sensor


void setup() {
  Serial.begin(9600); // Start serial communication at 9600 bps
  pinMode(val_trigPin, OUTPUT);
  pinMode(val_echoPin, INPUT);
}


void loop() {
  val_force = analogRead(inputPin0)/4; // Read analog input pin0 (force sensor), put in range 0 to 255
  val_slider= analogRead(inputPin1)/4; // Read analog input pin1 (slider sensor), put in range 0 to 255

  //Proximity Sensor
  long duration, distance;

  digitalWrite(val_trigPin, LOW);  
  delayMicroseconds(2); // delay
  digitalWrite(val_trigPin, HIGH);
  delayMicroseconds(10); // delay
  digitalWrite(val_trigPin, LOW);
  
  duration = pulseIn(val_echoPin, HIGH); //echo pulse
  distance = (duration/2) / 29.1;
  //Proximity Sensor End

  //'a' packet starts
  Serial.print("a"); //character 'a' will delimit the reading from the force sensor
  Serial.print(val_force);
  Serial.print("a");
  Serial.println();
  //'a' packet ends
  

  //'b' packet starts
  Serial.print("b"); //character 'b' will delimit the reading from the slider sensor
  Serial.print(val_slider);
  Serial.print("b");
  Serial.println();
  //'b' packet ends
  
  //add packets here if you use 3 or more sensors 
  //'c' packet starts
  Serial.print("c"); //character 'c' will delimit the reading from the proximity sensor
  Serial.print(distance);
  Serial.print("c");
  Serial.println();
  //'c' packet ends

  
  Serial.print("&"); //denotes end of readings from both sensors

  //print carriage return and newline
  Serial.println();

  delay(100); // Wait 100ms for next reading



}
