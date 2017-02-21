clear all; 
close all; 

Fs   = 50e6;
N    = 1024;
NFFT = N;
Ts   = 1/Fs;                                     % sampling interval  
t    = [0:Ts:(N*Ts)-Ts];
f    = Fs*(-NFFT/2:NFFT/2-1)/NFFT;

matlabInRaw = dlmread('../tb/matlab.in',' ');
matlabOutRaw = dlmread('../tb/matlab.out',' ');
fpgaOutRaw = dlmread('../tb/fpga.out',' ');

matlabin = complex(matlabInRaw(:,1),matlabInRaw(:,2));
matlabout = complex(matlabOutRaw(:,1),matlabOutRaw(:,2));
fpgaout = complex(fpgaOutRaw(:,1),fpgaOutRaw(:,2));

% normalized FFT of signal
f1 = fftshift(matlabout);
F1 = abs(f1)/(N);
f2 = fftshift(fpgaout);
F2 = abs(f2)/(N);

subplot(2,2,1);
plot(t,matlabin);
title('Input Signal');
xlabel('Time');
ylabel('Amplitude');

subplot(2,2,2);
plot(f,F1);
title('FFT result using MATLAB');
xlabel('Frequency [hertz]');
ylabel('Magnitude');

subplot(2,2,3);
plot(f,F2);
title('FFT result using FPGA');
xlabel('Frequency [hertz]');
ylabel('Magnitude');
