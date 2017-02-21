
% ----------------------------------------------------------------------------------------
% Author: Lekhobola Tsouenyane
%
% This generates Parks-McClellan optimal FIR coefficients in 2's complement and 
% data for FPGA Test (ntap_fir_par.vhd core)
% ----------------------------------------------------------------------------------------

% Sampling Frequency
Fs = 380e6;
% Number of samples
Nsamples = 1000;
% time 
t = 0:(1/Fs):(1/Fs*Nsamples);

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

% Create Initial Signals
f1 = 10e6;
f2 = 250e6;
f3 = 108e6;

t  = 0:(1/Fs):(1/Fs)*Nsamples;
s1 = cos(2*pi*f1*t + pi/4);
s2 = cos(2*pi*f2*t + pi/2);
s3 = cos(2*pi*f3*t);
x  = s1 + s2 + s3;

x = x/max(abs(x));

xfiltered = filter(b,1,x);

% Bit Width
BW = 8;
CW = 8;

% Write FIR coefficients to a file
fid=fopen('../tb/taps.in','wt');
fprintf(fid,"(");
for i=1:length(b);
	fprintf(fid,"%d,",round(2^(CW-1) * b(i)));
end 
fprintf(fid,")");
fclose(fid);

% Write test data to a file
fid=fopen('../tb/fpga.in','wt');
for i=1:length(x);
	fprintf(fid,"%d\n",round(2^(BW-1) * x(i)));
end 
fclose(fid);

% Write test data to a file
fid=fopen('../tb/matlab.out','wt');
for i=1:length(x);
	fprintf(fid,"%d\n",round(2^(CW-1) * xfiltered(i)));
end 
fclose(fid);

%% Frequency specifications:
N = length(t);
dF = Fs/N;                      % hertz
f = -Fs/2:dF:Fs/2-dF;           % hertz

%plot(f,fftshift(abs(fft(x)))/N);

[H,w] = freqz(b);
subplot(1,1,1);
plot(Fs*w/(2*pi),20*log10(abs(H)));
title('FIR Filter Frequency Response');
xlabel('Frequency [hertz]');
ylabel('Magnitude [db]');
