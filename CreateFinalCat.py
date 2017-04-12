#!/usr/bin/env python

"""
Script to create the final CLASH-VLT spectroscopic catalog to be published
"""

from __future__ import division
import argparse
import numpy as np
from astropy.io import ascii
from astropy import units as u
from astropy.coordinates import SkyCoord
import collections

parser = argparse.ArgumentParser(\
    description = "This script creates the final CLASH-VLT spectroscopic \
    catalogs to be published. You need to edit the input files.", \
    formatter_class = argparse.ArgumentDefaultsHelpFormatter)

args = parser.parse_args()

# +++++++++++++++++++++++++++++
# Edit hard-coded INPUT files:
# +++++++++++++++++++++++++++++
# Name of the input FULLTABLE file
FullTable = 'M0416_VIMOS_v3.3_FULLTABLE.cat'
# Name of the input zcat file
inp_table = 'M0416_v3.4_zcat.dat'
# Name of the input catalog
in_cat = 'macsj0416_BRcz_v2.2_kron.cat'

# Read the FULLTABLE
print 'Reading FULLTABLE...'
ftable = ascii.read(FullTable, guess=False, format='no_header', \
    names=('ID0', 'slit', 'objn', 'ID1', 'RA1', 'DEC1', 'ID2', 'RA2', 'DEC2', \
        'z2', 'zFlag2', 'Comm'))
ID = ftable["ID0"]
slit = ftable["slit"]
objn = ftable["objn"]
ID2 = ftable["ID2"]
ra2 = np.array(ftable["RA2"])
dec2 = np.array(ftable["DEC2"])
z2 = np.array(ftable["z2"])
zFlag2 = np.array(ftable["zFlag2"])
Comm = ftable["Comm"]

# Filter out Literature data
ID0 = []
slit0 = []
objn0 = []
ID02 = []
ra0 = np.array([])
dec0 = np.array([])
z0 = np.array([])
zFlag0 = np.array([])
Comm0 = []

for m, n in enumerate(objn):
    if 0 < n < 90:
        ID0.append(ID[m])
        slit0.append(slit[m])
        objn0.append(n)
        ID02.append(ID2[m])
        ra0 = np.append(ra0, ra2[m])
        dec0 = np.append(dec0, dec2[m])
        z0 = np.append(z0, z2[m])
        zFlag0 = np.append(zFlag0, zFlag2[m])
        Comm0.append(Comm[m])

specname = []
for j in range(len(ID0)):
    specname.append(str(ID0[j])+'_'+str(slit0[j])+'_'+str(objn0[j]))

coo = SkyCoord(ra0, dec0, unit=(u.deg,u.deg), frame='fk5')
coo1 = coo.to_string('hmsdms', precision=2)
coo2 = coo.to_string('hmsdms', precision=1)

ttname = []
for k in range(len(coo)):
    cc1 = str(coo1[k])
    cc2 = str(coo2[k])
    ttname.append('CLASHVLTJ'+cc1[:2]+cc1[3:5]+cc1[6:11]+cc2[12:15]+cc2[16:18]+cc2[19:23])


# Read the zcat
print 'Reading zcat...'
table = ascii.read(inp_table, guess=False, format='no_header', \
    names=('ID_INPUT', 'RA', 'DEC', 'z', 'zFlag', 'Multi', 'Sigma', 'Mag', \
        'RootName'))
IDi = table["ID_INPUT"]
ra = np.array(table["RA"])
dec = np.array(table["DEC"])
z = np.array(table["z"])
zFlag = np.array(table["zFlag"])
Mag = np.array(table["Mag"])
RootName = np.array(table["RootName"])

coord = SkyCoord(ra, dec, unit=(u.deg,u.deg), frame='fk5')
crd1 = coord.to_string('hmsdms', precision=2)
crd2 = coord.to_string('hmsdms', precision=1)

targetname = []
for i in range(len(coord)):
    c1 = str(crd1[i])
    c2 = str(crd2[i])
    targetname.append('CLASHVLTJ'+c1[:2]+c1[3:5]+c1[6:11]+c2[12:15]+c2[16:18]+c2[19:23])


# Read the INPUT catalog with magnitudes
print 'Reading INPUT file with magnitudes...'
ftable = ascii.read(in_cat, guess=False, format='no_header', \
    names=('IDs', 'RAs', 'DECs', 'mag_auto_R', 'err_mag_auto', 'radius_50',\
        'B_kron', 'err_B_kron',  'Rmag', 'err_R_kron',  'z_kron', 'err_z_kron',\
            'B_ap', 'err_B_ap', 'R_ap', 'err_R_ap', 'z_ap', 'err_z_ap', 'B_iso',\
                'err_B_iso', 'R_iso', 'err_R_iso', 'z_iso', 'err_z_iso',\
                    'starflag'))
IDs = ftable["IDs"]
ras = np.array(ftable["RAs"])
decs = np.array(ftable["DECs"])
Rmag = np.array(ftable["Rmag"])


# Match the IDs of FULLTABLE and INPUT catalog
print 'Matching FULLTABLE with INPUT catalog...'
id2 = dict((value2, idy) for idy, value2 in enumerate(IDs))
pp = [id2[x] if x in IDs else -1 for x in ID02]
RmagCorr = []
for i in range(len(pp)):
    if pp[i] >= 0:
        RmagCorr.append(Rmag[pp[i]])
    else:
        RmagCorr.append(-99.99)

# Write the specname-ID correspondance to a file
dd = [('TargName', ttname), ('SpecName', specname), ('ID', ID02) , ('RA', ra0),\
    ('DEC', dec0), ('z', z0), ('QF', zFlag0), ('Mag', RmagCorr), ('Comments', Comm0)]
otable = collections.OrderedDict(dd)
ascii.write(otable, 'IDs_spec.txt', formats={'TargName': '{:27}', 'SpecName': \
    '{:26}', 'ID': '{:10}', 'RA': '%.6f', 'DEC': '%.6f', 'z': '%.4f', 'QF': '%i', \
        'Mag': '%.2f'})
print 'Output written on IDs_spec.txt'


# Match the IDs of zcat and INPUT catalog
print 'Matching zcat with INPUT catalog...'
px = [id2[x] if x in IDs else -1 for x in IDi]
Rmag_Corr = []
for i in range(len(px)):
    if px[i] >= 0:
        Rmag_Corr.append(Rmag[px[i]])
    else:
        Rmag_Corr.append(-99.99)

# Write the final spec catalog to a file
d = [('TargetName', targetname), ('RA', ra), ('DEC', dec), ('z', z), ('QF', zFlag),\
    ('MAG', Rmag_Corr)]
outtable = collections.OrderedDict(d)
ascii.write(outtable, 'out.txt', formats={'RA': '%.6f', 'DEC': '%.6f', 'z': '%.4f', \
    'QF': '%i', 'MAG': '%.2f'})
print 'Output written on out.txt'

print 'All done!'
