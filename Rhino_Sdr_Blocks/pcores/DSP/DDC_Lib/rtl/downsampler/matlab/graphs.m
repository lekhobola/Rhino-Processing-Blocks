clear all; 
close all; 

fpgaOut = importdata('../tb/fpga.out',' ');

N = length(fpgaOut);
Fs  = 163.84e6/32;%200.784e3;
Ts = 1/Fs; 
t  = [0:Ts:(N*Ts)- Ts];


%fid = fopen('../tb/fm.out');   
%fpga = textscan(fid,'%f','Delimiter','\n');
%fclose(fid);
%fpgaOut = fpga{1};

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
plot(f,F1);
title('FM signal spectrum');
xlabel('Frequency [hertz]');
ylabel('Magnitude [dB]');

subplot(2,2,2);
plot(t(1:50),fpgaOut(1:50));
title('FM signal');
xlabel('Time');
ylabel('Amplitude');
