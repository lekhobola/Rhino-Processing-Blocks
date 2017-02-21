clc;
clear all;
close all;

%-----------------------------------------------------------------------
%						FM Modulation
%-----------------------------------------------------------------------    
N  = 8192*4;                                    % total # of samples     
Fs = 122.88e6;                                  % perform undersampling of FM signal
Ts = 1/Fs;                                      % sampling interval  
fc = 94.5e6;                                    % carrier frequency  

t  = [0:Ts:(N*Ts)- Ts];                         % time index for samples 

% system impedance (ohms)
R = 50;

% FM modulate a test signal.                   
ModFreq = 15e3;                                % Modulating frequency  
carrier = cos(2*pi*fc*t); 

msg = sin(2*pi*ModFreq*t);
%msg = awgn(msg, 20, 'measured');                     % compute vector  
       
mi = 1;    								   % Modulation Index
fmmsg = 2^15 * cos(2*pi*fc*t + mi*msg);
%fmmsg = awgn(fmmsg, 20, 'measured');  

% Write test data to a file
fid=fopen('../../tb/fpga.in','wt');
fprintf(fid,"%d\n",fmmsg);
fclose(fid);

real_bin = zeros(1,8192);
real_bin = round(fmmsg(1:8192));
fid=fopen('../../tb/rhino.in','wt');
% write to file
for i=1:8192;
	if(i < 8192)
		fprintf(fid,"\"%s\",",conv2bin(real_bin(i),16));
	else
		fprintf(fid,"\"%s\"",conv2bin(real_bin(i),16));
	end
end;
fclose(fid);

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
xlim([0,35e6]);

% normalized FFT of signal
f3=(fftshift(fft(fmmsg,N))/(N));

% power spectrum
F3 = 10*log10((abs(f3).^2)/R*1000);

subplot(2,2,4);
plot(f,F3);
title('FM Modulated signal ( x[n] )');
xlabel('Frequency [hertz]');
ylabel('Magnitude [dB]');
xlim([26e6,30e6]);

%-----------------------------------------------------------------------
%						Digital Down Conversion (DDC)
%----------------------------------------------------------------------- 

%						Numerially-Controlled Oscillator
%----------------------------------------------------------------------- 
%nco = ideal_dds(Fs,17.5e6,N); % digital local oscillator
%fLO = 2*Fs - fc;
fLO = Fs - fc;
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
xlim([-30e6,0]);

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

%						CIC Stage 1
%-----------------------------------------------------------------------
Mcic = 1;   % Differential delays in the filter.
Ncic = 10;   % Filter sections
Rcic = 128; % Decimation factor

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


%						Compensation FIR Stage 1
%-----------------------------------------------------------------------

Hfir= cfir(Rcic,Mcic,Ncic,95e3,122.88e6);

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

% Write test data to a file
fid=fopen('../../tb/coeffs.in','wt');
fprintf(fid,"%d,",round(Hfir*2^15));
fclose(fid);

%						CIC Stage 2
%-----------------------------------------------------------------------
Mcic = 1;   % Differential delays in the filter.
Ncic = 1;   % Filter sections
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

%-----------------------------------------------------------------------
%						FM Demodulation
%-----------------------------------------------------------------------   

% Initialize the variables.                                            %

phase = zeros(1,length(cic));
freq = zeros(1,length(cic)-1);

% compute inverse tangent

%for i=1:length(pfir)
%	phase(i) = atan2(imag(pfir(i)),real(pfir(i)));
%end;

%dt = 1/(Fs/Rcic);

% Compute derivative

%freq = phase(1);   
%for k=2:length(phase);
%  freq(k) = (phase(k)-phase(k-1))/dt;
%end

phase = atan2(imag(cic),real(cic));
freq = phase(1)
freq = diff(phase)./diff(t);

freq = -1 .* freq;

% amplify the output
%freq = (1/max(freq(50:length(freq)))) * freq;
  
%-------------------------------------------------------------------------%
figure(3)
subplot(2,2,1)
plot(t(1:length(t)-1),freq);
title('FM Demodulated Signal');
xlabel('Time (seconds)');
ylabel('Amplitude');
%ylim([-1,1]);

% normalized FFT of signal
f8=(fftshift(fft(freq,N))/(N));

% power spectrum
F8 = 10*log10((abs(f8).^2)/R*1000);

subplot(2,2,2)
plot(f,F8);
title('Spectrum of a Demodulated Signals');
xlabel('Frequency [hertz]');
ylabel('Magnitude [dB]');
xlim([-20e3,20e3]);
