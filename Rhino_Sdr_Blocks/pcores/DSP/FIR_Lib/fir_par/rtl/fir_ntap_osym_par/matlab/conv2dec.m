function value = conv2dec(bin,N)

val = bin2dec(bin);
y = sign(2^(N-1)-val)*(2^(N-1)-abs(2^(N-1)-val));
if ((y == 0) && (val ~= 0))
	value = -val;
else
	value = y;
end

