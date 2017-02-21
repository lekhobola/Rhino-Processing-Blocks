clear all; 
close all; 

% Sampling Frequency
Fs = 10000;
% Number of samples
Nsamples = 1023;
% time 
t = 0:(1/Fs):(1/Fs*Nsamples);

%plot(baxis,abs(F(1:length(F)/2)));

fid = fopen('../tb/fpga.in');   
fpgain = textscan(fid,'%f','Delimiter','\n');
fclose(fid);

fid = fopen('../tb/fpga.out');   
fpgaout = textscan(fid,'%f','Delimiter','\n');
fclose(fid);

fid = fopen('../tb/matlab.out');   
matlabout = textscan(fid,'%f','Delimiter','\n');
fclose(fid);

%% Frequency specifications:
N = length(t);
dF = Fs/N;                      % hertz
f = -Fs/2:dF:Fs/2-dF;           % hertz

subplot(2,2,1);
plot(f,fftshift(abs(fft(fpgain{1})))/Nsamples);
title('Unfiltered Signal Frequency Spectrum');
xlabel('Frequency [hertz]');
ylabel('Magnitude [dB]');

subplot(2,2,3);
plot(f,fftshift(abs(fft(matlabout{1})))/Nsamples);
title('Matlab FIR-Filtered Signal Frequency Spectrum');
xlabel('Frequency [hertz]');
ylabel('Magnitude [dB]');

subplot(2,2,4);
plot(f,fftshift(abs(fft(fpgaout{1})))/Nsamples);
title('FPGA FIR-Filtered Signal Frequency Spectrum');
xlabel('Frequency [hertz]');
ylabel('Magnitude [dB]');
