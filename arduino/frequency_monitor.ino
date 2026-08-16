
#define LED_GREEN  3      
#define LED_YELLOW 4      
#define LED_RED    5      
#define BUZZER     6
#define AUDIO_IN   A0     


const int N_SAMPLES = 256;   
const float SAMPLING_FREQ = 8000.0; 
const int SAMPLING_TIME = (1000000 / SAMPLING_FREQ); 


int audioSamples[N_SAMPLES]; 
volatile int sampleIndex = 0; 
volatile bool blockReadyToSend = false; 
volatile bool waitingForFreq = false; 

float freq = 0;
float prevFreq = 0;
float stableFreq = 0;
const float alpha = 0.7; 


void updateLEDs() {
  digitalWrite(LED_GREEN, LOW);
  digitalWrite(LED_YELLOW, LOW);
  digitalWrite(LED_RED, LOW);
  digitalWrite(BUZZER, LOW);

  if (stableFreq < 1200) {
    digitalWrite(LED_YELLOW, HIGH);
  } else if (stableFreq >= 1200 && stableFreq <= 2300) {
    digitalWrite(LED_GREEN, HIGH);
  } else if (stableFreq > 2300) {
    digitalWrite(LED_RED, HIGH);
    digitalWrite(BUZZER, HIGH);
  }
}

void setup() {
  Serial.begin(115200); 
  pinMode(LED_GREEN, OUTPUT);
  pinMode(LED_YELLOW, OUTPUT);
  pinMode(LED_RED, OUTPUT);
  pinMode(BUZZER, OUTPUT);
  pinMode(AUDIO_IN, INPUT); 
  digitalWrite(LED_GREEN, LOW);
  digitalWrite(LED_YELLOW, LOW);
  digitalWrite(LED_RED, LOW);
  digitalWrite(BUZZER, LOW);
}

void loop() {
  static unsigned long lastSampleTime = 0;
  
  //(Sampling)
  if (!blockReadyToSend && !waitingForFreq) {
    if (micros() - lastSampleTime >= SAMPLING_TIME) {
      if (sampleIndex < N_SAMPLES) {
        audioSamples[sampleIndex] = analogRead(AUDIO_IN);
        sampleIndex++;
      }
      lastSampleTime += SAMPLING_TIME;

      if (sampleIndex >= N_SAMPLES) {
        blockReadyToSend = true;
      }
    }
  }

  // MATLAB (Sending)
  if (blockReadyToSend) {
    Serial.println('<'); 
    for (int i = 0; i < N_SAMPLES; i++) {
      Serial.println(audioSamples[i]);
    }
    Serial.println('>'); 
    
    blockReadyToSend = false;
    waitingForFreq = true; 
  }

  //MATLAB (Receiving)
  if (waitingForFreq && Serial.available() > 0) {
    freq = Serial.parseFloat();   
    stableFreq = alpha * freq + (1 - alpha) * prevFreq;
    prevFreq = stableFreq;

    Serial.print("Received: ");
    Serial.println(stableFreq);
    
    updateLEDs(); 

    sampleIndex = 0; 
    waitingForFreq = false; 
  }
}
