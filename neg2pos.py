"""
Converts negative fits images to positive (and vice versa). Works correctly with files which data in range from 0 to 65,536.
"""

from astropy.io import fits
import os

os.chdir("data")

def convert_one(path):
    hdul =  fits.open(path)
    hdul[0].data = 65535 - hdul[0].data
    #2**16=65536 digits we can use, but we start from 0,
    #so max value is 65535
    hdul[0].data = 65535 - hdul[0].data
    hdul.close()

total = len(os.listdir())
counter = 1
for f_name in os.listdir():
    if f_name.endswith(".fit"):
        print(f_name,counter,"/",total,f" ({round(counter/total*100,1)}%)")
        counter = counter + 1
        convert_one(f_name)
        # Open the file in append & read mode ('a+')
        with open("converted.txt", "a+") as file_object:
          # Move read cursor to the start of file.
          file_object.seek(0)
          # If file is not empty then append '\n'
          data = file_object.read(100)
          if len(data) > 0 :
            file_object.write("\n")
          # Append text at the end of file
          file_object.write(f_name)
