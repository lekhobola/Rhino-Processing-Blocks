function bin=conv2bin(num,Nbits);

bin = dec2bin(mod((num),2^Nbits),Nbits)

