"""
Converts negative fits images to positive (and vice versa). Works correctly with files which data in range from 0 to 65,536.
"""

from astropy.io import fits
import os

os.chdir("data")
list_dir = os.listdir()

for f in list_dir:
    if ".fits" in f:
        #print(f)
        hdul =  fits.open(f)
        hdul[0].data = 65536 - hdul[0].data
        hdul.writeto(f,overwrite=True)
	hdul.close()
