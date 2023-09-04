"""
Converts negative fits images to positive (and vice versa). Works correctly with files which data in range from 0 to 65,536.
"""

import numpy as np
from astropy.io import fits
import os

def convert_one(path):
    hdul = fits.open(path)
    hdul[0].data = 65535 - hdul[0].data
    os.remove(path)
    hdul.writeto(os.path.basename(path), overwrite=True)
    hdul.close()

os.chdir("converted")

total = len([f_name for f_name in os.listdir() if f_name.endswith(".fit")])
counter = 1

with open("converted.txt", "w") as file_object:
    for f_name in os.listdir():
        if f_name.endswith(".fit"):
            print(counter, "/", total, f" ({round(counter/total*100, 1)}%)")
            convert_one(f_name)
            file_object.write(f_name + "\n")
            
            counter += 1




