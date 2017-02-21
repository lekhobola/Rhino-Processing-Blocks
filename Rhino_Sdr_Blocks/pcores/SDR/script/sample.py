import textwrap
import csv
import os, sys
import math

import numpy as np 
import matplotlib.pyplot as plt
from scipy import fft, arange 

# hex string to signed integer
def htosi(s):
    i = int(s, 16)
    if i >= 2**15:
        i -= 2**16
    return i    

hex_data = []	
with open('Fmcomms_BIST_960khz_stream_dump.txt') as fp:
	with open('Fmcomms_BIST_960khz_stream_dump.dat', 'wb') as f:
		for frame in fp:
			hex_data = textwrap.wrap(frame[:2*256], 4)
			for i in range(len(hex_data)):
				f.write('%d\n' % htosi(hex_data[i]))
				
