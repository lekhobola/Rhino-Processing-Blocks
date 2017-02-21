clc;
clear all;
close all;

%-----------------------------------------------------------------------
%						Down-sampler
%-----------------------------------------------------------------------    
N  = 8192*4;%3734*2;                         % total # of samples    
NFFT = 8192; 
Fs = 122.88e6;                                   % Sampling Frequency
Ts = 1/Fs;                                     % sampling interval  
fc = 200e3;                                    % carrier frequency  

t = [0:Ts:(N*Ts)-Ts];

% test signal.                   
signal =  round(2^13 * cos(2*pi*fc*t)); 

% Write test data to a file
fid=fopen('../tb/fpga.in','wt');
fprintf(fid,"%d\n",signal);
fclose(fid);

% PLOTS                                                                   
startplot = 1;
endplot   = 1000;

f = Fs*(-NFFT/2:NFFT/2-1)/NFFT;

figure(1);
subplot(2,2,1);
plot(t(1:800), signal(1:800));
title('test signal');
xlabel('Time (seconds)');
ylabel('Amplitude');

% normalized FFT of signal
f1=fftshift(fft(signal,NFFT));
F1 = abs(f1)/(N);

subplot(2,2,2);
plot(f,F1);
title('FFT of test signal');
xlabel('Frequency [hertz]');
ylabel('Magnitude [dB]');
xlim([-500e3,500e3]);

%						CIC Stage 1
%-----------------------------------------------------------------------
Mcic = 1;   % Differential delays in the filter.
Ncic = 4;  % Filter sections
Rcic = 32; % Decimation factor

g = ones(1,Rcic*Mcic);
h = g;
for i=1:Ncic;
	h = conv(h,g);
end;

cic_filtered  = conv(signal,g);
cic = cic_filtered([1:Rcic:length(cic_filtered)]);
cic = cic(1:round(length(signal)/Rcic));

c = cic;

Fs = round(Fs/Rcic);                                   
Ts = 1/Fs;
N = round(N/Rcic);
t = [0:Ts:(N*Ts)- Ts];

f = Fs*(-NFFT/2:NFFT/2-1)/NFFT;

% normalized FFT of signal
f2=fftshift(fft(cic,NFFT));
F2 = abs(f2)/(N);

subplot(2,2,3)
plot(f,F2);
title('FFT CIC output');
xlabel('Frequency [hertz]');
ylabel('Magnitude [dB]');

% Computing power
P2=f2.*conj(f2)/(NFFT*NFFT);

subplot(2,2,4)
plot(f,10*log10(P2),'r');
title('PSD of CIC output');
xlabel('Frequency (Hz)')
ylabel('PSD (dB/Hz)');

%						Compensation FIR Stage
%-----------------------------------------------------------------------

Hfir = cfir(Rcic,Mcic,Ncic);

% Write test data to a file
fid=fopen('../tb/coeffs.in','wt');
fprintf(fid,"%d,",round(Hfir*2^15));
fclose(fid);

% filter the mixer spurs
pfir = filter(Hfir,1,cic);

% normalized FFT of signal
f3 = fftshift(fft(pfir,NFFT));
F3 = abs(f3)/(N);

figure(2);
subplot(2,2,1);
plot(f,F3);
title('FFT of C-Filter');
xlabel('Frequency [hertz]');
ylabel('Magnitude [dB]');

% Computing power
P3 = f3.*conj(f3)/(NFFT*NFFT);

subplot(2,2,2)
plot(f,10*log10(P3),'r');
title('PSD of CIC-filter');
xlabel('Frequency (Hz)')
ylabel('PSD (dB/Hz)');

% Write test data to a file
fid=fopen('../tb/pfir.in','wt');
fprintf(fid,"%d %d\n",round(real(pfir)/42.811),round(imag(pfir)/42.811));
fclose(fid);

subplot(2,2,3)
plot(t(1:100), pfir(1:100));
title('Filter Signal');
xlabel('Time (seconds)');
ylabel('Amplitude');
  
%-------------------------------------------------------------------------%



