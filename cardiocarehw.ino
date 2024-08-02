#include <Adafruit_MCP9808.h>
#include <SoftwareSerial.h>
#include <Wire.h>

#define RX_PIN 10
#define TX_PIN 11
#define THRESHOLD 125      // To identify R peak
#define TIMER_VALUE 10000  // 10 seconds timer to calculate heart rate
const int ledpin = 13;

long instance1 = 0, timer;
double HRV = 0, HR = 72, interval = 0;
int value = 0, count = 0;
bool flag = false;
const int heartPin = A0;  // AD8232 OUTPUT pin connected to A0
const int LOPlus = 8;     // AD8232 LO+ pin connected to pin 9
const int LOMinus = 7;    // AD8232 LO- pin connected to pin 8
int currentMode = 0;     // Variable to keep track of the current mode
bool isStreaming = false; // Flag to control streaming

// Define the type of sensor used
SoftwareSerial BTSerial(RX_PIN, TX_PIN);
Adafruit_MCP9808 tempSensor = Adafruit_MCP9808();

void setup() {
  Serial.begin(9600);
  BTSerial.begin(9600);

  pinMode(LOPlus, INPUT);
  pinMode(LOMinus, INPUT);
  pinMode(ledpin, OUTPUT);

  if (!tempSensor.begin()) {
    Serial.println("Could not find MCP9808 temperature sensor");
    // while (1);
  } else {
    Serial.println("Sensor available for sensing");
  }
}

void loop() {
  // Handle Bluetooth commands
    // Serial.println("blue is avalable");
  if (BTSerial.available()) {
    int mode = BTSerial.read();

    // Update mode and start or stop streaming based on the mode
    if (mode >= 0 && mode <= 3) {
      currentMode = mode;
      isStreaming = (mode != 0); // Start streaming if mode is not 0 (IDLE)
    }
      Serial.print("Mode set to: ");
      Serial.println(mode);
  } 
  // else {
  //   Serial.println("blue is unavailable");
  // }

  // Continuously stream data based on the current mode
  if (isStreaming) {
    switch (currentMode) {
      case 0:
        BTSerial.println("IDLE MODE");
        break;
      case 1:
        streamECG();
        break;
      case 2:
        streamBP();
        break;
      case 3:
        streamTemperature();
        break;
      default:
        BTSerial.println("Invalid mode");
        break;
    }
  }
   digitalWrite(13, HIGH);
  
  delay(8); // Adjust delay as needed for streaming speed
}

// Function to stream ECG data
void streamECG() {
  // Serial.println("STREAMING ECG");
  if ((digitalRead(LOPlus) == 1) || (digitalRead(LOMinus) == 1)) {
    Serial.println("Leads off!");
    BTSerial.println(0);
    // Optionally handle leads-off condition
  } else {
    int value = analogRead(heartPin);
    Serial.print("before normalization: ");
    Serial.println(value);
    value = map(value, 250, 400, 0, 100);  // Normalize ECG values to 0-255

    if ((value > THRESHOLD) && (!flag)) {
      count++;
      flag = true;
      interval = micros() - instance1;  // RR interval
      instance1 = micros();
    } else if (value < THRESHOLD) {
      flag = false;
    }
    
    if ((millis() - timer) > TIMER_VALUE) {
      HR = count * 6;
      timer = millis();
      count = 0;
    }
    
    HRV = HR / 60 - interval / 1000000;
    
    // BTSerial.print("ECG Value: ");
    BTSerial.println(value);
    // BTSerial.print("Heart Rate: ");
    // BTSerial.println(HR);
    // BTSerial.print("Heart Rate Variability: ");
    // BTSerial.println(HRV);
    Serial.println(value);
  }
}

// Function to stream BP data
void streamBP() {
  // Example BP values (replace with actual readings)
  BTSerial.print("BP Value: ");
  BTSerial.println(180); // Replace with actual BP reading
  BTSerial.print("Another BP Value: ");
  BTSerial.println(80);  // Replace with actual BP reading
  Serial.println("streaming bp...");
}

// Function to stream temperature data
void streamTemperature() {
  float temperature = tempSensor.readTempC();
  // BTSerial.println("Temperature: ");
  BTSerial.println(temperature);
  Serial.println(temperature);
  // Serial.println("Streaming body temperature");
}
