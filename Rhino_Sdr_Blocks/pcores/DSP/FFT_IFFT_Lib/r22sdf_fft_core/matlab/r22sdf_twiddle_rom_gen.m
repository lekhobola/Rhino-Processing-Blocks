% -----------------------------------------------------------------------------------------
% Author:  Lekhobola Joachim Tsoeunyane
% Date:    22 June 2014
% Company: University Of Cape Town
% ----------------------------------------------------------------------------------------
function r22sdf_twiddle_rom_gen(N,tf_bit_width);
% ----------------------------------------------------------------------------------------
% This generates DIF R2^2-SDF FFT ROM of twiddle factors in 2's complement number format
% ----------------------------------------------------------------------------------------
% [hd]          = r22sdf_twiddle_rom_gen(N,tf_bit_width)
% N			    = Number of fft points, it must be in powers of two (i.e. 8,16,32...)
% tf_bit_width  = Bit width of twiddle factors
% ----------------------------------------------------------------------------------------
%
% at kth stage, k = 0,1,...ceil(log(N)/log(4))-2
% a[i] = e^(j*2*pi*p/N) = cos(2*pi*p/N) + jsin(2*pi*p/N)
% i = 0,1,2,...,(N/2^2k-1)
% m = N/2^(2+2k)
% p = 0 					    [ 0 ≤ i < m ],
%   = 2 * 2^((2*k)+1) * (i − m) [ m ≤ i < 2*m ]
%   = 2^(k*2) * (i − 2*m)       [ 2*m ≤ i < 3*m ]
%   = 3 * 2^(2*k) * (i − 3*m)   [ 3*m ≤ i < 4*m ]
%
% ----------------------------------------------------------------------------------------

% compute the number of stages
stages_count = ceil(log(N)/log(4))-1;
for k = 0:stages_count-1;	

	% calculate rom depth for kth stage
	rom_depth = N/(2^(2*k)); 
	% compute width of a rom height address
	addr = log2(rom_depth);
	
	% create vhdl file for kth fft stage
	file_name = sprintf("data/fft%d_tf_rom_s%d.vhd",N,k);
    fid=fopen(file_name,'wt');
	fprintf(fid,"--********************************************************************************\n");
	fprintf(fid,"--* Company:        University of Cape Town									   \n");												   
	fprintf(fid,"--* Engineer:       Lekhobola Joachim Tsoeunyane, lekhobola@gmail.com		       \n");
	fprintf(fid,"--********************************************************************************\n"); 
	fprintf(fid,"--* Create Date:    %s  				 										   \n",datestr(now));
	fprintf(fid,"--* Design Name:    Pipelined R2^2 DIF-SDF FFT								       \n");				   
	fprintf(fid,"--* Module Name:    fft%d_tf_rom_s%d.vhd										   \n",N,k); 											  
	fprintf(fid,"--* Project Name:   RHINO SDR Processing Blocks								   \n");
	fprintf(fid,"--* Target Devices: Xilinx - SPARTAN-6											   \n");
	fprintf(fid,"--********************************************************************************\n");
	fprintf(fid,"--* Dependencies: none															   \n");
	fprintf(fid,"--********************************************************************************\n");
	fprintf(fid,"LIBRARY IEEE;\n");
	fprintf(fid,"USE IEEE.STD_LOGIC_1164.ALL;\n");
	fprintf(fid,"USE IEEE.STD_LOGIC_UNSIGNED.ALL;\n");
	fprintf(fid,"--********************************************************************************\n");
	fprintf(fid,"--* This module implements the stage-%d of twiddle factor ROM for a %d-point      \n",k,N);
	fprintf(fid,"--* pipelined R2^2 DIF-SDF FFT. Each value is a complex number{imaginary,complex} \n");
	fprintf(fid,"--* ******************************************************************************\n");
	fprintf(fid,"--* params:																	   \n");
	fprintf(fid,"--*        addr_w - rom address bit width									       \n");				
	fprintf(fid,"--*        data_w - output data bit width										   \n");				
	fprintf(fid,"--* ports:																		   \n");							
	fprintf(fid,"--* 			[in]  addr	- Twidde factor ROM address to read					   \n");				
	fprintf(fid,"--* 			[out] doutr - Twiddle factor read from rom addr - real value	   \n");			
	fprintf(fid,"--* 			[out] douti - Twidder factor read from rom addr - imaginary value  \n");			
	fprintf(fid,"--********************************************************************************\n");	
	fprintf(fid,"--* Notes: Do not modify this file as it is auto-generated using matlab script    \n");	
	fprintf(fid,"--********************************************************************************\n");	
	fprintf(fid,"entity fft%d_tf_rom_s%d is\n",N,k);	
	fprintf(fid,"	generic(\n");	
	fprintf(fid,"		addr_w : natural := %d;\n",addr);	
	fprintf(fid,"		data_w : natural := %d\n",tf_bit_width);	
	fprintf(fid,"	);\n");	
	fprintf(fid,"    port (\n");	 
	fprintf(fid,"        addr  : in  std_logic_vector (addr_w - 1 downto 0);\n");	
	fprintf(fid,"        doutr : out std_logic_vector (data_w - 1 downto 0);\n");	
	fprintf(fid,"        douti : out  std_logic_vector(data_w - 1 downto 0)\n");	
	fprintf(fid," 	);\n");	
	fprintf(fid,"end fft%d_tf_rom_s%d;\n\n",N,k);	

	fprintf(fid,"architecture Behavioral of fft%d_tf_rom_s%d is\n",N,k);	
	fprintf(fid,"	type complex is array(0 to 1) of std_logic_vector(data_w - 1 downto 0);\n");	
	fprintf(fid,"	type rom_type is array(0 to (2 ** addr_w) - 1) of complex;\n\n");
		
	fprintf(fid,"	constant rom : rom_type := (\n");	

	
	% starting index for twiddle rom
	s = rom_depth / 4;
	
	printf("stage %d, factors = %d \n", k, rom_depth);
	for i = 0:rom_depth-1;
	    % compute twiddle factor index
		m = N/2^(2+(2*k)); 
		if (s < m)
			p = 0;
		elseif(s < (2*m))
			p = 2^(2*k+1)*(s-m);
		elseif(s < (3*m))
		    p = 2^(2*k)*(s-(2*m));
		elseif(s < (4*m))
			p = (3*2^(2*k))*(s-(3*m));
		end 
		
		s = s+1;
		if(s == rom_depth)
			s = 0;
		end
		
		% find a twiddle factor
		tf = exp(-1j*2*pi*(p/N))
		% real and imaginary of a twiddle factor
		realval = real(tf);
		imagval = imag(tf);
		% round twiddle factor
		rounded_real = realval*(2^(tf_bit_width-2));
		rounded_imag = imagval*(2^(tf_bit_width-2));
		% convert twiddle to binary
        real_bin = conv2bin(rounded_real,tf_bit_width);
	    imag_bin = conv2bin(rounded_imag,tf_bit_width);
		% write to file
		if(i < rom_depth - 1)
			fprintf(fid,"								 (\"%s\",\"%s\"),\n",real_bin,imag_bin);
		else
			fprintf(fid,"								 (\"%s\",\"%s\")\n",real_bin,imag_bin);
		end
			
	end
fprintf(fid,"							   );\n");	
fprintf(fid,"begin\n");	
fprintf(fid,"	doutr <= std_logic_vector(rom(conv_integer(addr))(0));\n");	
fprintf(fid,"	douti <= std_logic_vector(rom(conv_integer(addr))(1));\n");	
fprintf(fid,"end Behavioral;\n");	
fclose(fid);
end
