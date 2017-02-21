div  = (2*pi)/1024;
x  = 0:div:(2*pi);

% cosine waveform
y = cos(x);
z  = y * (2^15);
bin_cos  = dec2bin(typecast(int16(z),'uint16'));
[rows,cols]=size(bin_cos);
fid=fopen('cos.dat','wt');
quarter = (rows/4) + 1;
for i=1:quarter
	fprintf(fid,'"%s",\n',bin_cos(i,:));
end
fclose(fid);

% sine waveform
y = sin(x);
z  = y * (2^15);
bin_sin  = dec2bin(typecast(int16(z),'uint16'));
[rows,cols]=size(bin_sin);
fid=fopen('sin.dat','wt');
quarter = (rows/4) + 1;
for i=1:quarter
	fprintf(fid,'"%s",\n',bin_sin(i,:));
end
fclose(fid);
