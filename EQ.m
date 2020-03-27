clearvars;
close all;
global Fs gLow gLowMid gMid gHighMid gHigh enableEQ gainEQ additiveEQ;

% LE314 Digital Signal Processing Project
% Submitted by Peerawat Kongrawd (TEPE): 13 May, 2018.
% Contains two testing files : prayer0.wav, bohemian.wav

% Users Settings
filename = 'prayer0.wav';
duration = 10;              % Playback Duration (sec)
enableEQ = 1;               % Enable Equalizer
gainEQ = [0 1 1 1 1];       % Gain = [Low LowMid Mid HighMid High]  
                            % Gain = 1 for 'No Gain'

% Analysis Tools
analyzeFilter = 0;
compareInOut = 1;

% Load Filters from Objects
load('ChebyLP1.mat');
load('ChebyBP2.mat');
load('ChebyBP3.mat');
load('ChebyBP4.mat');
load('ChebyHP5.mat');

% Load Audio
[x,Fs] = audioread(filename);
samples = [1,duration*Fs];
clear x Fs
[x,Fs] = audioread(filename,samples);

% Shortcut
gLow = gainEQ(1);           % Gain of Lows
gLowMid = gainEQ(2);        % Gain of Low-Mids
gMid = gainEQ(3);           % Gain of Mids
gHighMid = gainEQ(4);       % Gain of High-Mids   
gHigh = gainEQ(5);          % Gain of Highs

% Additive EQ (Keep Original Input to Output)
additiveEQ = 1;
if(gLow >= 1 && gLowMid >= 1 && gMid >= 1 && gHighMid >= 1 && gHigh >= 1)
    gLow = 1-gLow;
    gLowMid = 1-gLowMid;
    gMid = 1-gMid;
    gHighMid = 1-gHighMid;
    gHigh = 1-gHigh;
    additiveEQ = 1;
else
additiveEQ = 0;
end

% Apply Filter Chebychev Type I
y1 = filter(ChebyLP1,x);
y2 = filter(ChebyBP2,x);
y3 = filter(ChebyBP3,x);
y4 = filter(ChebyBP4,x);
y5 = filter(ChebyHP5,x);

% Adder and Gain Multipliers
if (enableEQ == 1 && additiveEQ == 1)
y = x + gLow*y1 + gLowMid*y2 + gMid*y3 + gHighMid*y4 + gHigh*y5;
elseif (enableEQ == 1 && additiveEQ == 0)
y = gLow*y1 +gLowMid*y2 + gMid*y3 + gHighMid*y4 + gHigh*y5;
else
y = x;
end

% Output Sound
sound(y,Fs);


% Filter Analysis
if (analyzeFilter == 1)
fvtool(ChebyLP1, ChebyBP2, ChebyBP3, ChebyBP4, ChebyHP5)  % freqz(ChebyLP1)
minPhase_1 = isminphase(ChebyLP1);
minPhase_2 = isminphase(ChebyBP2);
minPhase_3 = isminphase(ChebyBP3);
minPhase_4 = isminphase(ChebyBP4);
minPhase_5 = isminphase(ChebyHP5);
end

% Plot FFT of Input and Output
if (compareInOut == 1)
audio_in = x;
audio_freq_sampl = Fs;
Length_audio=length(audio_in);
df=audio_freq_sampl/Length_audio;
frequency_audio=-audio_freq_sampl/2:df:audio_freq_sampl/2-df;
figure
FFT_audio_in=fftshift(fft(audio_in))/length(fft(audio_in));
plot(frequency_audio,abs(FFT_audio_in));
title('FFT of Input Audio');
xlabel('Frequency(Hz)');
ylabel('Amplitude');

audio_out = y;
figure
FFT_audio_out=fftshift(fft(audio_out))/length(fft(audio_out));
plot(frequency_audio,abs(FFT_audio_out));
title('FFT of Output Audio');
xlabel('Frequency(Hz)');
ylabel('Amplitude');
end