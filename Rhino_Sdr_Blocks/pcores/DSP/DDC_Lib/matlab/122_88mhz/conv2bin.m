function bin=conv2bin(num,Nbits);

if(Nbits <= 8)
	bin = dec2bin(typecast(int8(num),'uint8'));
elseif(Nbits <= 16)
	bin = dec2bin(typecast(int16(num),'uint16'));
elseif(Nbits <= 32)
	bin = dec2bin(typecast(int32(num),'uint32'));
elseif(Nbits <= 64)
	bin = dec2bin(typecast(int64(num),'uint64'));
end
if(length(bin) < Nbits)
    zero_count = Nbits - length(bin);
	for i = 1:zero_count		
		bin = strcat('0',bin);
	end
elseif(length(bin) > Nbits)
	bin = substr(bin,length(bin)-Nbits + 1,Nbits);
end 
