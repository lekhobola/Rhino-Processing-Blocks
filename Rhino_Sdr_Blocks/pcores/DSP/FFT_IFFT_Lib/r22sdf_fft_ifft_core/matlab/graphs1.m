clear all; 
close all; 

% Sampling Frequency
Fs = 380e6;
% Number of samples
N = 512;
% time 
t = 0:N-1;


matlabInRaw = dlmread('../tb/matlab.in',' ');
matlabOutRaw = dlmread('../tb/matlab.out',' ');
fpgaOutRaw = dlmread('../tb/fpga.out',' ');


matlabin = complex(matlabInRaw(:,1),matlabInRaw(:,2));
matlabout = complex(matlabOutRaw(:,1),matlabOutRaw(:,2));
fpgaout = complex(fpgaOutRaw(:,1),fpgaOutRaw(:,2));

%% Frequency specifications:
N = length(t);
dF = Fs/N;                      % hertz
f = -Fs/2:dF:Fs/2-dF;           % hertz

subplot(2,2,1);
plot(t,matlabin);
title('Input Signal');
xlabel('Time');
ylabel('Amplitude');

subplot(2,2,2);
plot(f,fftshift(abs(matlabout))/N);
title('FFT result using MATLAB');
xlabel('Frequency [hertz]');
ylabel('Magnitude [dB]');

subplot(2,2,3);
plot(f,fftshift(abs(fpgaout))/N);
title('FFT result using FPGA');
xlabel('Frequency [hertz]');
ylabel('Magnitude [dB]');
