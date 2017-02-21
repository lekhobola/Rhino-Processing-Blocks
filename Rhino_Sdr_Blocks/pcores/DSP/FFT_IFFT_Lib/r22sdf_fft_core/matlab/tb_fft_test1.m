bit_width = 8;
N = 512;
A = 2^(bit_width - 1); % amplitute
Fs = 380e6; % sampling frequency in KHz
f = 98e6;  % cut-off frequency in KHz
t = 0:N-1;

x1T = round(A * exp(j*2*pi*f*t/Fs));

fid=fopen('../tb/fpga.in','wt');
for i=1:N;
	fprintf(fid,"%s %s\n",conv2bin(real(x1T(i)),bit_width),conv2bin(imag(x1T(i)),bit_width));
end 
fclose(fid);

fid=fopen('../tb/matlab.in','wt');
for i=1:N;
	fprintf(fid,"%d %d\n",real(x1T(i)),imag(x1T(i)));
end 
fclose(fid);

x1F = fft(x1T);

fid=fopen('../tb/matlab.out','wt');
for i=1:N;
	fprintf(fid,"%d %d\n",real(x1F(i)),imag(x1F(i)));
end 
fclose(fid);

%% Frequency specifications:
N = length(t);
dF = Fs/N;                      % hertz
f = -Fs/2:dF:Fs/2-dF;           % hertz

%subplot(1,1,1);
plot(f,fftshift(abs(x1F))/N);
title('Signal Frequency Spectrum');
xlabel('Frequency [hertz]');
ylabel('Magnitude [dB]');
