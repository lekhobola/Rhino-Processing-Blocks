clear all; 
close all; 

Fs  = 25E6;

%fpgaOutRaw = dlmread('Fmcomms_BIST_960khz_stream_dump.dat',' ');
%fpgaOut = complex(fpgaOutRaw(:,1),fpgaOutRaw(:,2));
fid = fopen('SynthSine_Gbe.dat','r');
fpgaOut = fscanf(fid,'%d\n');
fclose(fid);

N =  length(fpgaOut); %length(fpgaOut);
Ts = 1/Fs; 
t  = [0:Ts:(N*Ts)- Ts];


R = 50;
dF = Fs/N;                      % hertz
f = Fs/2*[-1:2/N:1-2/N];

% normalized FFT of signal
f1=(fftshift(fft(fpgaOut(1:N),N))/(N));

% power spectrum
F1 = 10*log10((abs(f1).^2)/R*1000);
 
%
figure(1);
subplot(2,2,1);
plot(f,F1);
title('NCO Sine Waveform Spectrum - 200kHz');
xlabel('Frequency [hertz]');
ylabel('Magnitude [dB]');
%xlim([-500e3,500e3]);

subplot(2,2,2);
plot(t,fpgaOut);
title('200kHz Tone');
xlabel('Time');
ylabel('Amplitude');
