\# Sound Frequency Monitoring



A real-time sound frequency monitoring and alert system using Arduino and MATLAB to monitor machine operating frequencies and provide early indications of abnormal conditions.



\## Overview



This project presents a sound-based monitoring system that captures audio signals using a sound detector sensor and analyzes their frequency to identify deviations from a defined operating range.



The Arduino collects audio samples from the sensor and communicates the data to MATLAB. MATLAB performs real-time signal analysis using Fast Fourier Transform (FFT) to determine the dominant frequency and visualize both the time-domain signal and frequency spectrum.



Based on the detected frequency, the system classifies the current condition and provides visual and audible alerts using three LEDs and a buzzer.



\## Importance \& Applications



Monitoring changes in machine operating sounds can provide an early indication of abnormal behavior, helping identify potential problems before they develop into major failures.



The system can be adapted for applications such as:



\- Industrial machines and manufacturing environments

\- Motors and mechanical systems

\- Smart home applications



\## Features



\- Real-time sound frequency monitoring

\- Audio signal sampling using Arduino

\- Real-time FFT analysis using MATLAB

\- Dominant frequency detection

\- Time-domain signal visualization

\- Frequency spectrum visualization

\- Frequency-based condition classification

\- Green, yellow, and red LED indicators

\- Buzzer alert for high-frequency conditions

\- Serial communication between Arduino and MATLAB

\- Support for audio files with different frequencies for testing



\## Hardware \& Software Requirements



\### Hardware



\- Arduino UNO

\- Sound Detector Sensor

\- Green, Yellow, and Red LEDs

\- Buzzer



\### Software



\- Arduino IDE

\- MATLAB



\## How It Works



The system follows this process:



\*\*Microphone / Audio Source → Arduino → MATLAB → FFT Analysis → Frequency Classification → LED / Buzzer Alert\*\*



\### 1. Audio Sampling



The sound detector captures the incoming audio signal. The Arduino samples the signal at a defined sampling frequency and collects a block of 256 samples.



\### 2. Data Transfer



The collected samples are transmitted from the Arduino to MATLAB through Serial communication.



\### 3. FFT Analysis



MATLAB receives the samples and applies FFT analysis to determine the dominant frequency.



The MATLAB interface displays:



\- The time-domain signal

\- The frequency spectrum

\- The detected dominant frequency

\- The current frequency classification



\### 4. Condition Classification



The detected frequency is compared with predefined frequency ranges:



\- Low frequency: below 1200 Hz → Yellow LED

\- Normal range: 1200–2300 Hz → Green LED

\- High frequency: above 2300 Hz → Red LED + Buzzer



The detected frequency is then sent back to the Arduino, which updates the LEDs and buzzer accordingly.



\## Testing



The system was tested using audio files with different frequencies to verify the frequency analysis and condition classification.



The audio files are test signals with different frequencies and are not recordings of actual machine faults.



\## Demo



The demo demonstrates running the MATLAB real-time FFT analysis and testing the system using an audio file.



\## Future Improvements



\- Long-term frequency data storage and analysis

\- Email or mobile notifications for abnormal conditions

\- More advanced signal processing techniques



\## Team Project



\*\*Team Project — 6 Members\*\*



The project was developed as a team, with members contributing to different aspects of the system.



\### Contributors



\- Fatma Nagah Abdelazim

\- Hoda Mahmoud Shalaby

\- Nesreen Ashraf El-Emairy

\- Sama Mohamed Rashad

\- Fatma Mohsen El-Saber

\- Zamzam Ali Sarhan



\## License



This project is licensed under the MIT License. See the `LICENSE` file for details.

