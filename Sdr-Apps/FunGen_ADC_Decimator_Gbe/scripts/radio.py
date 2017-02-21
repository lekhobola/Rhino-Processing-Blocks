import textwrap
import csv
import os, sys
import math

import numpy as np 
import matplotlib.pyplot as plt
from scipy import fft, arange 

# By     	  : Lekhobola Tsoeunyane
# Date   	  : 19 January 2016
# Project	  : Domain-specic High-level FPGA synthesis for SDR
# Description : GbE data acquisition and plot of the 49.152MHz ADC ramp
 
# hex string to signed integer
def htosi(s):
    i = int(s, 16)
    if i >= 2**15:
        i -= 2**16
    return i     

def plotSpectrum(y,Fs,sp):
 """
 Plots a Single-Sided Amplitude Spectrum of y(t)
 """
 n = len(y) # length of the signal
 k = arange(n)
 T = n/Fs
 frq = k/T # two sides frequency range
 frq = frq[range(n/2)] # one side frequency range

 Y = fft(y)/n # fft computing and normalization
 Y = Y[range(n/2)]
 
 plt.subplot(sp) 
 plt.plot(frq,abs(Y),'r') # plotting the spectrum
 plt.xlabel('Freq (Hz)')
 plt.ylabel('|Y(freq)|') 
#plt.annotate('960kHz', xy=(960000,0), xytext=(1500000, 100),
#			  arrowprops=dict(facecolor='black', shrink=0.00) 
#			 ) 
     
# set project path env 
os.environ['PRJ_PATH'] = '/home/lekhobola/Documents/dev/research/xilinx/sdrg/FunGen_ADC_Decimator_Gbe/Rhino_Sdr_Blocks/pcores/SDR/script'

# capture a fixed number of udp packets [total passed a argument in the program command], the output file is "AdcRamp_Gbe.pcap"
os.system('sudo tcpdump -i eno1 udp -c %s -w $PRJ_PATH/FunGen_ADC_Decimator_Gbe.pcap' % (sys.argv[1]))

# extract udp payload in every udp packet, the output file is "Fmcomms_BIST_960khz_stream_dump.txt"
os.system('tshark -r $PRJ_PATH/FunGen_ADC_Decimator_Gbe.pcap -T fields -e data > $PRJ_PATH/FunGen_ADC_Decimator_Gbe.txt')

os.system('capinfos ./FunGen_ADC_Decimator_Gbe.pcap')


hex_data = []	
with open('FunGen_ADC_Decimator_Gbe.txt') as fp:
	with open('FunGen_ADC_Decimator_Gbe.dat', 'wb') as f:
		for frame in fp:
			hex_data = textwrap.wrap(frame[:2*128], 4)
			for i in range(len(hex_data)):
				f.write('%d\n' % htosi(hex_data[i]))
