clc;
clear all;
close all;

%-----------------------------------------------------------------------
%						FM Modulation
%-----------------------------------------------------------------------    
N  = 8192*4;%3734*2;                         % total # of samples     
Fs = 61.44e6;                                      % Sampling Frequency
Ts = 1/Fs;                                      % sampling interval  
fc = 1e6;                                    % carrier frequency  


t = [0:Ts:(N*Ts)-Ts];
% system impedance (ohms)
R = 50;

% FM modulate a test signal.                   
ModFreq = 15e3;                                % Modulating frequency  
signal = 128 * cos(2*pi*fc*t); 

% Write test data to a file
fid=fopen('../../tb/fpga.in','wt');
fprintf(fid,"%d\n",signal);
fclose(fid);

% PLOTS                                                                   
startplot = 1;
endplot   = 1000;

dF = Fs/N;                      % hertz
f = -Fs/2:dF:Fs/2-dF;           % hertz
f = Fs/2*[-1:2/N:1-2/N];

figure(1);
subplot(2,2,1);
plot(t(1:800), signal(1:800));
title('Message Signal');
xlabel('Time (seconds)');
ylabel('Amplitude');

% normalized FFT of signal
f1=(fftshift(fft(signal,N))/(N));

% power spectrum
F1=10*log10((abs(f1).^2)/R*1000);

subplot(2,2,2);
plot(f,F1);
title('spectrum of a Message Signal ( x[n] )');
xlabel('Frequency [hertz]');
ylabel('Magnitude [dB]');

%-----------------------------------------------------------------------
%						Digital Down Conversion (DDC)
%----------------------------------------------------------------------- 

%						Numerially-Controlled Oscillator
%----------------------------------------------------------------------- 

fLO = fc;
LO  = exp(1*1j*2*pi*fLO*t);

% normalized FFT of signal
f2=(fftshift(fft(LO,N))/(N));

% power spectrum
F2 = 10*log10((abs(f2).^2)/R*1000);

subplot(2,2,3);
plot(f,F2);
title('spectrum of a Local Oscillator ( LO[n] )');
xlabel('Frequency [hertz]');
ylabel('Magnitude [dB]');

%						Mixer Stage of DDC
%----------------------------------------------------------------------- 
mixer = signal .* LO;			   % mix FM signal with LO

% normalized FFT of signal
f3=(fftshift(fft(mixer,N))/(N));

% power spectrum
F3 = 10*log10((abs(f3).^2)/R*1000);

subplot(2,2,4);
plot(f,F3);
title('Spectrum of a mixer signal ( b[n] )');
xlabel('Frequency [hertz]');
ylabel('Magnitude [dB]');

%						CIC Stage 1
%-----------------------------------------------------------------------
Mcic = 1;   % Differential delays in the filter.
Ncic = 10;  % Filter sections
Rcic = 154; % Decimation factor

g = ones(1,Rcic*Mcic);
h = g;
for i=1:Ncic;
	h = conv(h,g);
end;

cic_filtered  = conv(mixer,g);
cic = cic_filtered([1:Rcic:length(cic_filtered)]);
cic = cic(1:round(length(mixer)/Rcic));

Fs = round(Fs/Rcic);                                   
Ts = 1/Fs;
N = round(N/Rcic);
t = [0:Ts:(N*Ts)- Ts];

dF = Fs/N;                      % hertz
f = -Fs/2:dF:Fs/2-dF;           % hertz

% normalized FFT of signal
f4=(fftshift(fft(cic,N))/(N));

% power spectrum
F4 = 10*log10((abs(f4).^2)/R*1000);
figure(2)
subplot(2,2,1)
plot(f,F4);
title('Spectrum of a CIC output ( c[n] )');
xlabel('Frequency [hertz]');
ylabel('Magnitude [dB]');

%						Compensation FIR Stage
%-----------------------------------------------------------------------

Hfir = cfir(Rcic,Mcic,Ncic);


% Write test data to a file
fid=fopen('../../tb/coeffs.in','wt');
fprintf(fid,"%d,",round(Hfir*2^15));
fclose(fid);

% filter the mixer spurs
pfir = filter(Hfir,1,cic);

% normalized FFT of signal
f5=(fftshift(fft(pfir,N))/(N));

% power spectrum
F5 = 10*log10((abs(f5).^2)/R*1000);

subplot(2,2,2);
plot(f,F5);
title('Spectrum of a filter output [I[n] and Q[n]');
xlabel('Frequency [hertz]');
ylabel('Magnitude [dB]');

% Write test data to a file
fid=fopen('../../tb/pfir.in','wt');
fprintf(fid,"%d %d\n",round(real(pfir)/42.811),round(imag(pfir)/42.811));
fclose(fid);

%						CIC Stage 2
%-----------------------------------------------------------------------
Mcic = 1;   % Differential delays in the filter.
Ncic = 1;  % Filter sections
Rcic = 2; % Decimation factor

g = ones(1,Rcic*Mcic);
h = g;
for i=1:Ncic;
	h = conv(h,g);
end;

cic1 = pfir;
cic_filtered  = conv(cic1,g);
cic = cic_filtered([1:Rcic:length(cic_filtered)]);
cic = cic(1:round(length(cic1)/Rcic));

Fs = round(Fs/Rcic);                                   
Ts = 1/Fs;
N = round(N/Rcic);
t = [0:Ts:(N*Ts)- Ts];

dF = Fs/N;                      % hertz
f = -Fs/2:dF:Fs/2-dF;           % hertz

% normalized FFT of signal
f5=(fftshift(fft(cic,N))/(N));

% power spectrum
F5 = 10*log10((abs(f5).^2)/R*1000);

figure(2)
subplot(2,2,3)
plot(f,F5);
title('Spectrum of a CIC-2 output ( c[n] )');
xlabel('Frequency [hertz]');
ylabel('Magnitude [dB]');
  
%-------------------------------------------------------------------------%



