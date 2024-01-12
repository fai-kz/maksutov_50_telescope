This is a DaCHS RD for FAI's collection of images obtained on 50cm Maksutov telescope.

Data is collected in different repository and is not shared on GitHub. To collect data please visit https://vo.fai.kz.

The files in the perository:
q.rd    -- resource descriptor, DACHS file
neg2pos -- python script to convert images from negative to positive. (use it carefully, because it does not distinguish positive or negative the image is, but convert anyway)
/bin/annotate_fits.py -- python script to standardize data from logs to write them in headers. It is adopt to our journal style, so you should fix it in your way.
/bin/default.params   -- params for source extractor to do astrometry 

