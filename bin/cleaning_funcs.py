"""
There are functions which were written earlier (https://github.com/ill-i/Glass_Lib.git) and which are neccessary for cleaning table data to make it standart and readable. 
"""

import 


"""
EXPOSITION

We should write expositions in seconds only! So let's convert it
if it is necessary.
"""

def exposure_time(exp):
	"""
	The function recalculate exptime in seconds and return an array
	with one or more values (it depends on how much exp we have) and number of exposures.
	"""
	if exp == exp and exp!="":
		exp = exp.replace(",",";")
		if '*' not in str(exp):
			exp = str(exp).split(';')
			for g in range(0,len(exp)):
				if 's' in str(exp[g]) and 'm' not in str(exp[g]) and 'h' not in str(exp[g]):
					exp[g] = str(exp[g]).replace('s','')
					exp[g] = float(exp[g]) * 1
				elif 's' not in str(exp[g]) and 'm' in str(exp[g]) and 'h' not in str(exp[g]):
					exp[g] = str(exp[g]).replace('m','')
					exp[g] = float(exp[g])*60
				elif 's' not in str(exp[g]) and 'm' not in str(exp[g]) and 'h' in str(exp[g]):
					exp[g] = str(exp[g]).replace('h','')
					exp[g] = float(exp[g])*3600
				elif 's' in str(exp[g]) and 'm' in str(exp[g]) and 'h' not in str(exp[g]):
					exp[g] = str(exp[g]).replace('s','').split('m')
					exp[g] = float(exp[g][0])*60 +float(exp[g][1])
				elif 's' not in str(exp[g]) and 'm' in str(exp[g]) and 'h' in str(exp[g]):
					exp[g] = str(exp[g]).replace('m','').split('h')
					exp[g] = float(exp[g][0])*3600 +float(exp[g][1])*60
			exptime = exp
		else: # "*" in exp
			exptime = [99999] #polarisation
	else: # exp != exp or exp==""
			exptime = [99999] #unknown
	
	exp_num = len(exptime)
	
	return exptime, exp_num




