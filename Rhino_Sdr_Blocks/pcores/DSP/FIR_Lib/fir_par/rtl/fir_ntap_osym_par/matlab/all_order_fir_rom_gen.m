% -----------------------------------------------------------------------------------------
% Author:  Lekhobola Joachim Tsoeunyane
% Date:    06 July 2014
% Company: University Of Cape Town
% ----------------------------------------------------------------------------------------
function all_order_fir_rom_gen(BW,N,Fs,Fpass,Fstop);
% ----------------------------------------------------------------------------------------
% This generates Parks-McClellan optimal FIR ROM for coefficients in 2's complement 
% number format
% ----------------------------------------------------------------------------------------
% []     =  equiripple_rom_gen(N,tf_bit_width)
% BW     =  Coefficient bit width
% N	     =  Number of coeffiecints or FIR taps
% Fs     =  Sampling frequency
% Fpass  =  Passband frequency
% Fstop  =  Stopband frequecy
% ----------------------------------------------------------------------------------------
% 

% rom address is log2(n) wide
addrw = ceil(log2(N));

file_name = sprintf("../../all_order_fir/all_order_fir_rom_pkg.vhd");
fid=fopen(file_name,'wt');
fprintf(fid,"--********************************************************************************\n");
fprintf(fid,"--* Company:        University of Cape Town									   \n");												   
fprintf(fid,"--* Engineer:       Lekhobola Joachim Tsoeunyane, lekhobola@gmail.com		       \n");
fprintf(fid,"--********************************************************************************\n"); 
fprintf(fid,"--* Create Date:    %s  				 										   \n",datestr(now));
fprintf(fid,"--* Design Name:    All Order FIR filter	  			                           \n");				   
fprintf(fid,"--* Module Name:    all_order_fir_rom_pkg.vhd										   \n"); 											  
fprintf(fid,"--* Project Name:   RHINO SDR Processing Blocks								   \n");
fprintf(fid,"--* Target Devices: Xilinx - SPARTAN-6											   \n");
fprintf(fid,"--********************************************************************************\n");
fprintf(fid,"--* Dependencies: none															   \n");
fprintf(fid,"--********************************************************************************\n");
fprintf(fid,"LIBRARY IEEE;\n");
fprintf(fid,"USE IEEE.STD_LOGIC_1164.ALL;\n");
fprintf(fid,"--********************************************************************************\n");
fprintf(fid,"--* This package defines  %d-coefficient FIR Filter ROM                         \n",N);
fprintf(fid,"--* ******************************************************************************\n");	
fprintf(fid,"--* Notes: Do not modify this file as it is auto-generated using matlab script    \n");	
fprintf(fid,"--********************************************************************************\n");
fprintf(fid,"package all_order_fir_rom_pkg is\n");	
fprintf(fid,"	type coeff_type is array (0 to %d) of std_logic_vector (%d downto 0);\n",N-1,BW-1);
fprintf(fid,"	constant coeffs : coeff_type  :=  (\n");	

% normalize passband and stopband frequencies
nFpass = 2*Fpass/Fs;
nFstop = 2*Fstop/Fs;

f = [0 nFpass nFstop 1];
a = [1 1 0 0];
W = [1 1];

h = remez(N-1,f,a,W);

%stem(0:N-1,h);
%freqz(h);

for i = 1:N;
	% round coeffiecient
	hr = round(h(i)*(2^(BW-1)));
	% convert coeffincient to binary
	hr_bin = conv2bin(hr,BW);
	% write to file
	if(i < N)
		fprintf(fid,"									 \"%s\",\n",hr_bin);
	else
		fprintf(fid,"								 	 \"%s\"\n",hr_bin);
	end
end

fprintf(fid,"	                                );\n");	
fprintf(fid,"end all_order_fir_rom_pkg;\n");
fprintf(fid,"package body all_order_fir_rom_pkg is\n");	
fprintf(fid,"end all_order_fir_rom_pkg;\n");	
fclose(fid);
end
