clear all; 
close all; 

Fs  = 122.88e6/128;%200.784e3;
N  = floor(8192*4/128);
Ts  = 1/Fs; 
t   = [0:Ts:(N*Ts)- Ts];

fpgaOutRaw = dlmread('../../tb/fpga.out',' ');
fpgaOut = complex(fpgaOutRaw(:,1),fpgaOutRaw(:,2));

%fpgaOut = importdata('../../tb/fpga.out');   
%fpgaOut = fpgaOut(9:length(fpgaOut));
%N=9-5;

R = 50;
dF = Fs/N;                      % hertz
f = Fs/2*[-1:2/N:1-2/N];

% normalized FFT of signal
f1=(fftshift(fft(fpgaOut,N))/(N));

% power spectrum
F1 = 10*log10((abs(f1).^2)/R*1000);
 
%
figure(1);
subplot(2,2,1);
plot(f,F1/N);
title('FM signal spectrum');
xlabel('Frequency [hertz]');
ylabel('Magnitude [dB]');

subplot(2,2,2);
plot(t,fpgaOut);
title('FM signal');
xlabel('Time');
ylabel('Amplitude');
