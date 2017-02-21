clc;
clear all;
close all;

%-----------------------------------------------------------------------
%						FM Modulation
%-----------------------------------------------------------------------    
N  = 3734*6;                                      % total # of samples     
Fs = 56e6;                                      % perform undersampling of FM signal
Ts = 1/Fs;                                      % sampling interval  
fc = 94.5e6;                                    % carrier frequency  
fc1 = 93.9e6;
fc2 = 88.9e6;
fc3 = 90.9e6;
fc4 = 92.4e6;
fc5 = 94.2e6;
fc6 = 94.8e6;
fc7 = 94.1e6;
fc8 = 100.5e6;
fc9 = 107.1e6;
t  = [0:Ts:(N*Ts)- Ts];                         % time index for samples 

% system impedance (ohms)
R = 50;

% FM modulate a test signal.                   
ModFreq = 15e3;                                % Modulating frequency  
carrier = 100 * cos(2*pi*fc*t); 
carrier1 = 100 * cos(2*pi*fc1*t);
carrier2 = 100 * cos(2*pi*fc2*t);
carrier3 = 100 * cos(2*pi*fc3*t);
carrier4 = 100 * cos(2*pi*fc4*t);
carrier5 = 100 * cos(2*pi*fc5*t);
carrier6 = 100 * cos(2*pi*fc6*t);
carrier7 = 100 * cos(2*pi*fc7*t);
carrier8 = 100 * cos(2*pi*fc8*t);
carrier9 = 100 * cos(2*pi*fc9*t);
carrier = carrier + carrier1 + carrier2 + carrier3 + carrier4 + carrier5 + carrier6 + carrier7 + carrier8 + carrier9;

msg = sin(2*pi*ModFreq*t);                     % compute vector  
       
mi = 2;     								   % Modulation Index
fmmsg = 100 * cos(2*pi*fc*t + mi*msg);
fmmsg1 = 100 * cos(2*pi*fc1*t + mi*msg);
fmmsg2 = 100 * cos(2*pi*fc2*t + mi*msg);
fmmsg3 = 100 * cos(2*pi*fc3*t + mi*msg);
fmmsg4 = 100 * cos(2*pi*fc4*t + mi*msg);
fmmsg5 = 100 * cos(2*pi*fc5*t + mi*msg);
fmmsg6 = 100 * cos(2*pi*fc6*t + mi*msg);
fmmsg7 = 100 * cos(2*pi*fc7*t + mi*msg);
fmmsg8 = 100 * cos(2*pi*fc8*t + mi*msg);
fmmsg9 = 100 * cos(2*pi*fc9*t + mi*msg);
fmmsg = fmmsg + fmmsg1 + fmmsg2 + fmmsg3 + fmmsg4 + fmmsg5 + fmmsg6 + fmmsg7 + fmmsg8 + fmmsg9;

% PLOTS                                                                   
startplot = 1;
endplot   = 1000;

dF = Fs/N;                      % hertz
f = -Fs/2:dF:Fs/2-dF;           % hertz
f = Fs/2*[-1:2/N:1-2/N];

figure(1);
subplot(2,2,1);
plot(t, msg);
title('Message Signal');
xlabel('Time (seconds)');
ylabel('Amplitude');

% normalized FFT of signal
f1=(fftshift(fft(msg,N))/(N));

% power spectrum
F1=10*log10((abs(f1).^2)/R*1000);

subplot(2,2,2);
plot(f,F1);
title('spectrum of a Message Signal ( x[n] )');
xlabel('Frequency [hertz]');
ylabel('Magnitude [dB]');
xlim([-20e3,20e3]);

% normalized FFT of signal
f2=(fftshift(fft(carrier,N))/(N));

% power spectrum
F2=10*log10((abs(f2).^2)/R*1000);

subplot(2,2,3);
plot(f,F2);
title('spectrum of a carrier');
xlabel('Frequency [hertz]');
ylabel('Magnitude [dB]');
xlim([0,20e6]);

% normalized FFT of signal
f3=(fftshift(fft(fmmsg,N))/(N));

% power spectrum
F3 = 10*log10((abs(f3).^2)/R*1000);

subplot(2,2,4);
plot(f,F3);
title('FM Modulated signal ( x[n] )');
xlabel('Frequency [hertz]');
ylabel('Magnitude [dB]');
xlim([15e6,20e6]);

%-----------------------------------------------------------------------
%						Digital Down Conversion (DDC)
%----------------------------------------------------------------------- 

%						Numerially-Controlled Oscillator
%----------------------------------------------------------------------- 
%nco = ideal_dds(Fs,17.5e6,N); % digital local oscillator
fLO = 2*Fs - fc;
%fLO = fc;

LO  = exp(-1*1j*2*pi*fLO*t);

% normalized FFT of signal
f4=(fftshift(fft(LO,N))/(N));

% power spectrum
F4 = 10*log10((abs(f4).^2)/R*1000);

figure(2);
subplot(2,2,1);
plot(f,F4);
title('spectrum of a Local Oscillator ( LO[n] )');
xlabel('Frequency [hertz]');
ylabel('Magnitude [dB]');
xlim([-20e6,0]);

%						Mixer Stage of DDC
%----------------------------------------------------------------------- 
mixer = fmmsg .* LO;			   % mix FM signal with LO

% normalized FFT of signal
f5=(fftshift(fft(mixer,N))/(N));

% power spectrum
F5 = 10*log10((abs(f5).^2)/R*1000);

subplot(2,2,2);
plot(f,F5);
title('Spectrum of a mixer signal ( b[n] )');
xlabel('Frequency [hertz]');
ylabel('Magnitude [dB]');
xlim([-10e6,30e6]);

%						CIC Stage 
%-----------------------------------------------------------------------
Mcic = 1;   % Differential delays in the filter.
Ncic = 20;  % Filter sections
Rcic = 140; % Decimation factor

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
f6=(fftshift(fft(cic,N))/(N));

% power spectrum
F6 = 10*log10((abs(f6).^2)/R*1000);

subplot(2,2,3);
plot(f,F6);
title('Spectrum of a CIC output ( c[n] )');
xlabel('Frequency [hertz]');
ylabel('Magnitude [dB]');
xlim([-1.5e6,1.5e6]);

%						Compensation FIR Stage
%-----------------------------------------------------------------------

Hfir= cfir(Rcic,Mcic,Ncic);

% filter the mixer spurs
pfir = filter(Hfir,1,cic);

% normalized FFT of signal
f7=(fftshift(fft(pfir,N))/(N));

% power spectrum
F7 = 10*log10((abs(f7).^2)/R*1000);

subplot(2,2,4);
plot(f,F7);
title('Spectrum of a filter output [I[n] and Q[n]');
xlabel('Frequency [hertz]');
ylabel('Magnitude [dB]');
xlim([-1.5e6,1.5e6]);


%-----------------------------------------------------------------------
%						FM Demodulation
%-----------------------------------------------------------------------   

% Initialize the variables.                                            %

phase = zeros(1,length(pfir));
freq = zeros(1,length(pfir));

% compute inverse tangent

for i=1:length(pfir)
	phase(i) = atan2(imag(pfir(i)),real(pfir(i)));
end;

dt = 1/(Fs/Rcic);

% Compute derivative

freq = phase(1);   
for k=2:length(phase);
  freq(k) = (phase(k)-phase(k-1))/dt;
end

freq = -1 .* freq;

% amplify the output
freq = (1/max(freq(50:length(freq)))) * freq;
  
%-------------------------------------------------------------------------%
figure(3)
subplot(2,2,1)
plot(t,freq);
title('FM Demodulated Signal ( /\O[n] )');
xlabel('Time (seconds)');
ylabel('Amplitude');
%ylim([-1,1]);

% normalized FFT of signal
f8=(fftshift(fft(freq,N))/(N));

% power spectrum
F8 = 10*log10((abs(f8).^2)/R*1000);

subplot(2,2,2)
plot(f,F8);
title('Spectrum of a Demodulated Signal ( /\O[n] )');
xlabel('Frequency [hertz]');
ylabel('Magnitude [dB]');
xlim([-20e3,20e3]);
