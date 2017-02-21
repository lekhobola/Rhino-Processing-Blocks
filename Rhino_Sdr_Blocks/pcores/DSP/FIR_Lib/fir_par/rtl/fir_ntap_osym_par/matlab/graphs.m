function graphs(N);

fs = 100;

matlabRawData = dlmread('data/matlabAllOrderFIR.dat',' ');
fpgaRawData = dlmread('data/fpgaAllOrderFIR.dat',' ');
x1T = complex(matlabRawData(:,1),matlabRawData(:,2));
x2T = complex(fpgaRawData(:,1),fpgaRawData(:,2));

x1F = fftshift(abs(fft(x1T)));
x2F = fftshift(abs(x2T));

t = [-N/2:N/2-1]*fs;
plot(t,x1F,'-',t,x2F,'-');
legend('Matlab FFT','Fpga FFT');
