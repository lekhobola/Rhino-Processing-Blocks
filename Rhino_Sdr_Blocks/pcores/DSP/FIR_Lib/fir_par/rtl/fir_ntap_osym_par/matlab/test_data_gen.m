function test_data_gen(FilterN,DataN,bit_width);

A = 2^(bit_width - 1); % amplitute
Fs = 44000; % sampling frequency in KHz
t = 0:DataN-1;

x1T = round(A*(sin(2*pi*2000/Fs*t)+sin(2*pi*9500/Fs*t)));
%x1T = 100;
x1Bin = cell(DataN,1);
for i=1:DataN;
	x1Bin{i} = '';
end

fid=fopen('data/AllOrderFIRDataIn.dat','wt');
for i=1:DataN;
    x1Bin{i} = conv2bin(x1T(i),bit_width);
	fprintf(fid,"%s\n",x1Bin{i});
end 
fclose(fid);

Fpass = 4400;
Fstop = 6600;

nFpass = 2*Fpass/Fs;
nFstop = 2*Fstop/Fs;

f = [0 nFpass nFstop 1];
at = [1 1 0 0];
W = [1 1];

b = remez(FilterN-1,f,at,W);
a = 1;

for i=1:DataN;
	x1T(i) = conv2dec(x1Bin{i},bit_width);
end;

x2T = filter(b,a,x1T);

fid=fopen('data/matlabAllOrderFIR.dat','wt');
for i=1:length(x2T);
	fprintf(fid,"%d\n",x2T(i));
end 
fclose(fid);
