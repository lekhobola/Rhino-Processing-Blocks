clc;
clear all;
close all;
%-----------------------------------------------------------------------
% Author : Lekhobola Tsoeunyane			
% Date   : 11 March 2015
%-----------------------------------------------------------------------
%						Digital Down Converter
%-----------------------------------------------------------------------    
N  = 4800;                   % total # of samples     
Fs = 56e6;                  % perform undersampling of FM signal
Ts = 1/Fs;                      % sampling interval  
fc = 94.5e6;                    % carrier frequency  
t  = [0:Ts:(N*Ts)- Ts];         % time index for samples 
R = 50;							% system impedance (ohms)

ModFreq = 15e3;                                % Modulating frequency  
carrier = 100 * cos(2*pi*fc*t); 

msg = sin(2*pi*ModFreq*t);                     % compute vector  
       
mi = 1;     								   % Modulation Index
fmmsg = cos(2*pi*fc*t + mi*msg); 


% Write test data to a file
fid=fopen('../tb/fpga.in','wt');
fprintf(fid,"%d\n",round(2^7*fmmsg));
fclose(fid);

% PLOTS                                                                   
startplot = 1;
endplot   = 1000;

dF = Fs/N;                      % hertz
f = Fs/2*[-1:2/N:1-2/N];

% normalized FFT of signal
f1=(fftshift(fft(128*fmmsg,N))/(N));
% power spectrum
F1=10*log10((abs(f1).^2)/R*1000);

figure(1);
subplot(2,2,1);
plot(f,F1);
title('spectrum of a Message Signal ( x[n] )');
xlabel('Frequency [hertz]');
ylabel('Magnitude [dB]');

%						Numerially-Controlled Oscillator
%----------------------------------------------------------------------- 
% digital local oscillator
%fLO = Fs - fc;
fLO = 2*Fs - fc;
LO  = exp(-1*1j*2*pi*fLO*t);
% normalized FFT of signal
f4=(fftshift(fft(LO,N))/(N));
% power spectrum
F4 = 10*log10((abs(f4).^2)/R*1000);

subplot(2,2,2);
plot(f,F4);
title('spectrum of a Local Oscillator ( LO[n] )');
xlabel('Frequency [hertz]');
ylabel('Magnitude [dB]');

%						Mixer Stage of DDC
%----------------------------------------------------------------------- 
mixer = fmmsg .* LO;			   % mix FM signal with LO

% normalized FFT of signal
f5=(fftshift(fft(mixer,N))/(N));
% power spectrum
F5 = 10*log10((abs(f5).^2)/R*1000);

subplot(2,2,3);
plot(f,F5);
title('Spectrum of a mixer signal ( b[n] )');
xlabel('Frequency [hertz]');
ylabel('Magnitude [dB]');

%						CIC Stage 
%-----------------------------------------------------------------------
Mcic = 1;   % Differential delays in the filter.
Ncic = 5;  % Filter sections
Rcic = 614; % Decimation factor

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

subplot(2,2,4);
plot(f,F6);
title('Spectrum of a CIC output ( c[n] )');
xlabel('Frequency [hertz]');
ylabel('Magnitude [dB]');

%						Compensation FIR Stage
%-----------------------------------------------------------------------

Hfir= cfir(Rcic,Mcic,Ncic);

% Write test data to a file
fid=fopen('../tb/coeffs.in','wt');
fprintf(fid,"%d,",round(Hfir*2^15));
fclose(fid);

% filter the mixer spurs
compensator = filter(Hfir,1,cic);

% normalized FFT of signal
f7=(fftshift(fft(compensator,N))/(N));
% power spectrum
F7 = 10*log10((abs(f7).^2)/R*1000);

figure(2);
subplot(2,2,1);
plot(f,F7);
title('Spectrum of a filter output [I[n] and Q[n]');
xlabel('Frequency [hertz]');
ylabel('Magnitude [dB]');
%----------------------------------------------------------------------%



