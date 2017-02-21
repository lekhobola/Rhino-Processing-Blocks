clear all; 
close all; 

% Sampling Frequency
Fs = 380e6;
% Number of samples
Nsamples = 1000;
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


% Sampling frequency
Fs = 380e6;
% Bandpass Filter Design parameters
Nfilter = 64;
Fp1 = 88e6;
Fp2 = 108e6;
Fs1 = 78e6;
Fs2 = 118e6;

% normalize passband and stopband frequencies
nFp1 = 2*Fp1/Fs;
nFp2 = 2*Fp2/Fs;
nFs1 = 2*Fs1/Fs;
nFs2 = 2*Fs2/Fs;

F = [0 nFs1 nFp1 nFp2 nFs2 1];
A = [0 0 1 1 0 0];

% Filter Coeffients
b = remez(Nfilter-1,F,A,type='bandpass');

[H,w] = freqz(b);
subplot(2,2,2);
plot(Fs*w/(2*pi),20*log10(abs(H)));
title('FIR Filter Frequency Response');
xlabel('Frequency [hertz]');
ylabel('Magnitude [dB]');
