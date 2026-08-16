
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%ARDUINO CODE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all;


port = 'COM4'; 
baudRate = 115200; 

try
    arduino = serialport(port, baudRate);
    arduino.Timeout = 5; 
    flush(arduino); 
    disp([' Connection established on ', port]);
catch ME
    disp([' Error connecting to Arduino: ', ME.message]);
    return;
end

%% ======  FFT SETTING ======
N_SAMPLES = 256; 
SAMPLING_FREQ = 8000; 
T = 1/SAMPLING_FREQ;

window = 0.54 - 0.46*cos(2*pi*(0:N_SAMPLES-1)/(N_SAMPLES-1));
freqAxis = (0:N_SAMPLES/2-1)*(SAMPLING_FREQ/N_SAMPLES);

F_LOW = 1200;
F_HIGH = 2300;

%% ======  GUI  ======
fig = figure('Name',' Real-Time FFT Dashboard','NumberTitle','off', ...
    'Position',[100 100 1000 500],...
    'Color',[0.1 0.1 0.1]); 

% Dominant Frequency
dominantText = uicontrol('Style','text','Parent',fig,...
    'String','Dominant Frequency: 0 Hz','FontSize',14, ...
    'FontWeight','bold','ForegroundColor','w','BackgroundColor' ...
    ,[0.1 0.1 0.1],'Units','normalized','Position',[0.05 0.93 0.9 0.05]);

% Time Domain Plot
axTime = axes('Parent',fig,'Position',[0.05 0.55 0.55 0.35], ...
    'Color',[0 0 0]);
timePlot = plot(axTime, zeros(1, N_SAMPLES),'LineWidth',1.5, ...
    'Color',[0 0.7 1]);
xlabel(axTime,'Sample #','Color','w'); ylabel(axTime,'Amplitude', ...
    'Color','w');
title(axTime,'Time Domain Signal','Color','w');
axTime.XColor = 'w'; axTime.YColor = 'w';
grid(axTime,'on'); axTime.GridColor = [0.5 0.5 0.5]; axTime.GridAlpha = 0.3;

% FFT PloT
axFFT = axes('Parent',fig,'Position',[0.05 0.1 0.55 0.35],'Color' ...
    ,[0 0 0]);
fftPlot = plot(axFFT, freqAxis, zeros(1,N_SAMPLES/2),'LineWidth',1.5, ...
    'Color',[1 0.4 0.7]); 
xlabel(axFFT,'Frequency (Hz)','Color','w'); ylabel(axFFT,'Magnitude', ...
    'Color','w');
title(axFFT,'Frequency Spectrum','Color','w');
axFFT.XColor = 'w'; axFFT.YColor = 'w';
grid(axFFT,'on'); axFFT.GridColor = [0.5 0.5 0.5]; axFFT.GridAlpha = 0.3;
xlim(axFFT,[0 SAMPLING_FREQ/2]);

% LED Blocks
ledColor = [0.3 0.3 0.3]; 
ax1 = axes('Parent',fig,'Position',[0.7 0.65 0.25 0.08]);
rec1 = rectangle('Position',[0 0 1 1],'FaceColor',ledColor,'EdgeColor','w', ...
    'LineWidth',1.5);
text(0.5,1.2,sprintf('Low (< %d Hz) - YELLOW', F_LOW),'HorizontalAlignment', ...
    'center','FontWeight','bold','FontSize',12,'Color','w');
ax2 = axes('Parent',fig,'Position',[0.7 0.5 0.25 0.08]);
rec2 = rectangle('Position',[0 0 1 1],'FaceColor',ledColor, ...
    'EdgeColor','w','LineWidth',1.5);
text(0.5,1.2,sprintf('Normal (%d - %d Hz) - GREEN', F_LOW, F_HIGH), ...
    'HorizontalAlignment','center','FontWeight','bold','FontSize',12, ...
    'Color','w');
ax3 = axes('Parent',fig,'Position',[0.7 0.35 0.25 0.08]);
rec3 = rectangle('Position',[0 0 1 1],'FaceColor',ledColor, ...
    'EdgeColor','w','LineWidth',1.5);
text(0.5,1.2,sprintf('High (> %d Hz) - RED/BUZZER', F_HIGH), ...
    'HorizontalAlignment','center','FontWeight','bold','FontSize', ...
    12,'Color','w');

drawnow;
disp(' Starting Real-Time FFT analysis...');


circularBuffer = zeros(1,N_SAMPLES);
bufferIndex = 1;

%% ====== ANALYSIS LOOP  ======
try
    while ishandle(fig)
        while arduino.NumBytesAvailable > 0
            lineRead = readline(arduino);
            lineRead = strtrim(lineRead);

            if strcmp(lineRead,'<')
                continue;
            elseif strcmp(lineRead,'>')
                segFFT = circularBuffer - mean(circularBuffer);
                segFFT = segFFT .* window;
                Y = fft(segFFT);
                P2 = abs(Y/N_SAMPLES);
                P1 = P2(1:N_SAMPLES/2);
                [~, idx] = max(P1(2:end));
                dominantFreq = freqAxis(idx+1);

                writeline(arduino, num2str(dominantFreq));
                fftPlot.YData = P1;
                set(dominantText,'String',sprintf('Dominant Frequency: %.1f Hz', dominantFreq));

                if dominantFreq < F_LOW
                    set(dominantText,'ForegroundColor',[1 1 0]);
                elseif dominantFreq <= F_HIGH
                    set(dominantText,'ForegroundColor',[0 1 0]);
                else
                    set(dominantText,'ForegroundColor',[1 0 0]);
                end

                set(rec1,'FaceColor',ledColor); set(rec2,'FaceColor', ...
                        ledColor); set(rec3,'FaceColor',ledColor);
                if dominantFreq < F_LOW
                    set(rec1,'FaceColor','y');
                elseif dominantFreq <= F_HIGH
                    set(rec2,'FaceColor','g');
                else
                    set(rec3,'FaceColor','r');
                end

                drawnow;
                continue;
            end

            val = str2double(lineRead);
            if ~isnan(val)
                circularBuffer(bufferIndex) = val;
                bufferIndex = bufferIndex + 1;
                if bufferIndex > N_SAMPLES
                    bufferIndex = 1;
                end

                maxVal = max(circularBuffer);
                minVal = min(circularBuffer);
                ylim(axTime,[minVal-50 maxVal+50]);
                timePlot.YData = circularBuffer;
                drawnow limitrate;
            end
        end
        pause(0.001);
    end
catch
    disp('Program stopped by user or error occurred.');
end

delete(arduino);
disp('Connection closed. Program finished.');
