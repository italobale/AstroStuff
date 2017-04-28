;Read 3D MUSE cube (DATA and VARIANCE)
cubefile='~/projects/MACS1149/MACS1149_MUSE_DATACUBE_allobs.fits'
cube=mrdfits(cubefile, 1, hdr)
;var=mrdfits(cubefile, 2, vhdr)

;Elliptical Refsdal lens (extract spectrum with rad=1.2")
rc='11:49:35.470' & dc='+22:23:43.65'
xspecube, cube, hdr, ra=rc,dec=dc,aperad=1.2,specfile='M1149_spec_152.fits'

END
