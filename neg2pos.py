"""
Converts negative fits images to positive (and vice versa). Works correctly with files which data in range from 0 to 65,536.
"""

from astropy.io import fits
import os

os.chdir("data")

def convert_one(path):
    hdul =  fits.open(path)
    hdul[0].data = 65535 - hdul[0].data
    hdul.writeto(path, overwrite=True)
	hdul.close()


for f_name in os.listdir():
    if f_name.endswith(".fits"):
        convert_one(f_name)
