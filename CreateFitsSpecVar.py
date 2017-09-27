#!/usr/bin/env python

"""
Script to create a Multi-extension fits file with MUSE Spectrum and Variance.
"""

import datetime
import pyfits

# INPUT FILE NAMES (SPECTRUM VARIANCE)
filename = "MACS212901165"
spec_file = "spec_"+filename+".fits"
var_file = "vari_"+filename+".fits"

# READ THE INPUT FILES 
header_spec = pyfits.getheader(spec_file)
data_spec = pyfits.getdata(spec_file)
header_var = pyfits.getheader(var_file)
data_var = pyfits.getdata(var_file)

today = str(datetime.date.today())

# CREATE THE NEW FITS FILE 
hdu0 = pyfits.PrimaryHDU()
hdu1 = pyfits.ImageHDU(data_spec)
hdu2 = pyfits.ImageHDU(data_var)
hdulist = pyfits.HDUList([hdu0,hdu1,hdu2])

hdr0 = hdulist[0].header
hdr0['SIMPLE'] = (True, "conforms to FITS standard")
hdr0['BITPIX'] = (8, "array data type")
hdr0['NAXIS'] = (0, "number of array dimensions")
hdr0['DATE'] = (today, 'Creation date (CCYY-MM-DD) of FITS file')
hdr0['EXTEND'] = True

hdr1 = hdulist[1].header
hdr1['XTENSION'] = ("IMAGE", "Image extension")                               
hdr1['BITPIX'] = (-32, "array data type")                                
hdr1['NAXIS'] = (1 , "number of array dimensions")                     
hdr1['NAXIS1'] = (3681, "axis lenght")                                                                         
hdr1['PCOUNT'] = (0, "number of parameters")                           
hdr1['GCOUNT'] = (1, "number of groups")                              
hdr1['EXTNAME'] = ("DATA", "extension name")                                 
hdr1['CUNIT1'] = "Angstrom"                                                            
hdr1['RA_TARG'] =  header_spec['RAC']                                              
hdr1['DEC_TARG'] = header_spec['DECC']                                              
hdr1['BUNIT'] = '1e-20 erg/s/cm^2/Angstrom'                                      
hdr1['CTYPE1'] = "AWAV"                                                            
hdr1['OBJECT'] = filename                                                        
hdr1['CRPIX1'] = 1.0                                                  
hdr1['CRVAL1'] = 4750.0                                                  
hdr1['CDELT1'] = 1.25                                                  
hdr1['DATE'] = (today, 'Creation date (CCYY-MM-DD) of FITS file')

hdr2 = hdulist[2].header
hdr2['XTENSION'] = ("IMAGE", "Image extension")                               
hdr2['BITPIX'] = (-32, "array data type")                                
hdr2['NAXIS'] = (1 , "number of array dimensions")                     
hdr2['NAXIS1'] = (3681, "axis lenght")                                                                         
hdr2['PCOUNT'] = (0, "number of parameters")                           
hdr2['GCOUNT'] = (1, "number of groups")                              
hdr2['EXTNAME'] = ("VARIANCE", "extension name")                                 
hdr2['CUNIT1'] = "Angstrom"                                                            
hdr2['RA_TARG'] =  header_spec['RAC']                                              
hdr2['DEC_TARG'] = header_spec['DECC']                                              
hdr2['BUNIT'] = '1e-20 erg/s/cm^2/Angstrom'                                      
hdr2['CTYPE1'] = "AWAV"                                                            
hdr2['OBJECT'] = filename                                                        
hdr2['CRPIX1'] = 1.0                                                  
hdr2['CRVAL1'] = 4750.0                                                  
hdr2['CDELT1'] = 1.25                                                  
hdr2['DATE'] = (today, 'Creation date (CCYY-MM-DD) of FITS file')

hdulist.writeto('MUSE_spec_'+filename+'.fits', clobber=True)
print("Fits file written on MUSE_spec_"+filename+".fits")
