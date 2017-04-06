#!/usr/bin/env python

"""
Script to plot the distribution of objects on the sky using an Aitoff projection
"""

from __future__ import division
import argparse
import numpy as np
from astropy.io import ascii
from astropy import units as u
from astropy.coordinates import SkyCoord
import matplotlib.pyplot as plt
from matplotlib import rc
#from matplotlib.ticker import MultipleLocator, FormatStrFormatter

parser = argparse.ArgumentParser(\
    description = "This script plots the position of objects \
    on the sky using an Aitoff projection", \
    formatter_class = argparse.ArgumentDefaultsHelpFormatter)

parser.add_argument("-gc", help = "Plot in Galactic coordinates", \
    default="", action="store_true")
parser.add_argument("-o", "-outfile", help = "Print output to a png file", \
    default="", action="store_true")
args = parser.parse_args()

def AddLabels(rr, dd, names):
    # Annotate object names
    for i, txt in enumerate(names):
        ax.annotate(txt, (rr[i]-0.02,dd[i]+0.05), color='r', fontsize=7)

# Set up fonts 
# for Helvetica and other sans-serif fonts use:
# rc('font',**{'family':'sans-serif','sans-serif':['Helvetica']})
rc('font',**{'family':'serif','serif':['Palatino'], 'size': 10})
rc('text', usetex=True)

# Read the coordinates from a file:
inp_table = 'CLASH-VLT_sample.txt'

# Read TABLE
table = ascii.read(inp_table)
ra = table["RA"]
dec = table["DEC"]
ids = table["ID"]
coord = SkyCoord(ra, dec, unit=(u.hour,u.deg), frame='icrs')
ra_rad = coord.ra.wrap_at(180 * u.deg).radian
dec_rad = coord.dec.radian
gcra_rad = coord.galactic.l.wrap_at(180 * u.deg).radian
gcdec_rad = coord.galactic.b.radian

# Plot the Galactic plane
l = np.arange(360) ; b = np.zeros(360)
c = SkyCoord(l=l, b=b, unit=(u.deg,u.deg), frame="galactic")
gpra_rad = c.icrs.ra.wrap_at(180 * u.deg).radian
gpdec_rad = c.icrs.dec.radian

# Set the plot size in inches (width, height) & resolution(DPI)
fig = plt.figure(figsize=(12,6), dpi=100)
ax = fig.add_subplot(111, projection='aitoff')

if args.gc:
    # PLOT THE OBJECT DISTRIBUTION IN GALACTIC COORDINATES
    ax.plot(gcra_rad, gcdec_rad, 'o', color='r', markersize=5, alpha=0.7)
    AddLabels(gcra_rad, gcdec_rad, ids)
else:
    # PLOT THE OBJECT DISTRIBUTION IN EQUATORIAL COORDINATES
    ax.plot(ra_rad, dec_rad, 'o', color='r', markersize=5, alpha=0.7)
    # Plot the Galactic plane
    # Filter out the lowest points to avoid edge-to-edge line 
    for i, j in enumerate(gpdec_rad):
        if j == min(gpdec_rad):
            gpmin = i
    # Cut out a slice of +-6
    tl = gpmin - 6; th = len(gpdec_rad) - gpmin + 6
    ax.plot(gpra_rad[tl:], gpdec_rad[tl:], '--', color='grey')
    ax.plot(gpra_rad[:-th], gpdec_rad[:-th], '--', color='grey')
    AddLabels(ra_rad, dec_rad, ids)

# plot grid
plt.grid(True)

if args.o:
    plt.savefig("allsky_plot.png", bbox_inches='tight')
else:
    # Show the plot in GUI
    plt.show()
