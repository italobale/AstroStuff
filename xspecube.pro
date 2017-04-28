PRO XSPECUBE, cube, hdr,ra=ra, dec=dec, aperad=rad, wl,flux,fvar, specfile=sfile, specproid=specproid, variance=var, lmin=lmin, lmax=lmax, mask_name=mskname, spec2d=spec2d,f2d=flux2d
;+
;Input: cube, hdr, ra=ra,dec=dec,rad=rad(") 
;       [,variance=var, lmin=lambda_min, lmax=lambda_max]
;Output: lambda,flux,var_flux
; If specproid is provided then a spectrum in SPECPRO name/format is
; created instead of sfile. 
; SPECPRO file -> spec1d.[mask_name].[id].[Ap_??].fits
;              -> info.[mask_name].[id].[Ap_??].dat

;Exa (MACS1149 MUSE cube, spensing spiral for Refsdal)
; Extract and create a std fits spectrum
;cube=mrdfits(cubefile, 1, hdr) & var=mrdfits(cubefile, 2, hdrv)
;xspecube, cube,
; hdr,ra='11:49:35.470',dec='+22:23:43.65',aperad=1,specproid=36,wl,flux,var=var
;Extract and create a std fits spectrum
;xspecube, cube, hdr, ra=177.397071, dec=22.396108,aperad=1,specfile='M1149_id033.fits'
;
;-
nax=sxpar(hdr,'NAXIS*')
nxy=long(nax[0])*long(nax[1])
getrot,hdr,rot,cdelt & scl=avg(abs(cdelt))*3600. & rpix=rad/scl
lambda0=sxpar(hdr,'CRVAL3')
pix0=sxpar(hdr,'CRPIX3')  
wdisp=sxpar(hdr,'CD3_3')  ;dispersion A/pix

if n_elements(mskname) eq 0 then mskname='MUSE'

if size(ra,/type) eq 7 then ra2=ten2(ra)*15 else ra2=ra
if size(dec,/type) eq 7 then dec2=ten2(dec) else dec2=dec

rd2xy,ra2,dec2,hdr,x,y
iw=where_circle(x,y,rpix,nax[0],nax[1])  ;extraction aperture
;iw=where_box(x,y,rpix[0],rpix[1],nax[0],nax[1])    ;rectangular aperture 
;iw=where_anulus(x,y,rpix[0],rpix[1],nax[0],nax[1])  ;extraction aperture
flux=fltarr(nax[2]) & w=flux*0.

for k=0,nax[2]-1 do flux[k]= mean( cube(iw+k*nxy) )
;Extract variance spectrum, if variance cube is provided, otherwise set it to 1
fvar=make_array(nax[2],/float,val=1.)
if n_elements(var) ne 0 then begin
   for k=0,nax[2]-1 do fvar[k]= mean( var(iw+k*nxy) )
endif

;Wavelength array
wl=lambda0+wdisp*(indgen(nax[2])+1-pix0)

;If /spec2d, make a pseudo-2D-spectrum, with lx=10*rad, ly=2*rad
if keyword_set(spec2d) then begin
   lenslit=10*rpix        ;length of pseudo-2D-spectrum in pixels
   x1=fix(x-0.5*lenslit) & x2=fix(x+0.5*lenslit)
   y1=fix(y-rpix) & y2=fix(y+rpix) 
   flux2d=make_array(nax[2],x2-x1+1,/float) & wl2d=flux2d
   fvar2d=make_array(nax[2],x2-x1+1,/float,val=1.)
   for k=0,nax[2]-1 do begin 
;      could use mean(..,dim=2) with new IDL
       flux2d[k,*]= avg( cube[x1:x2,y1:y2,k],1)  ; collapse the slit along y
       wl2d[k,*]= wl[k]
       if n_elements(var) ne 0 then fvar2d[k,*]= avg( cube[x1:x2,y1:y2,k],1)
   endfor
endif

mkhdr, hs, flux
sxaddpar, hs,'CRVAL1',lambda0
sxaddpar, hs,'CRPIX1',pix0
sxaddpar, hs,'CDELT1',wdisp
sxaddpar, hs,'OBJECT', 'MACSJ1149 (MUSE DATA)'
sxaddpar, hs,'BUNIT', '10**(-20)*erg/s/cm**2/Angstrom'
sxaddpar, hs,'CUNIT1', 'Angstrom'
sxaddpar, hs,'CTYPE1', 'AWAV'
sxaddpar, hs,'RA_TARG', ra2
sxaddpar, hs,'DEC_TARG', dec2
sxaddpar, hs,'APER_RAD', rad,'Extraction aperture radius (arcsec)'

if keyword_set(specproid) then begin 
   if specproid gt 999 then begin 
      print, 'specpro ID should be < 1000'
      goto, out
   end
   ids=strim(specproid,'i3')
   if strlen(ids) eq 1 then ids='00'+ids
   if strlen(ids) eq 2 then ids='0'+ids
   sfile='spec1d.'+mskname+'.'+ids+'.'+'Ap_'+strim(rad[0]*10,'i3')+'.fits'
;
;Create SPECPRO information file
;This contains all the info..
   infos=['ID','RA','DEC','extractpos','extractwidth','slitRA','slitDEC',$  
         'slitlen','slitwid','slitPA','zphot','zpdf','zpdf_low','zpdf_up']
;   infos=['ID','RA','DEC']
   ival=replicate('0',n_elements(infos))
   ival[0]=strim(specproid,'i4')
   ival[1]=strim(ra2,'f12.6') & ival[2]=strim(dec2,'f12.6')
   infofile='info.'+mskname+'.'+ids+'.'+'Ap_'+strim(rad[0]*10,'i3')+'.dat'
   print,' Output SPECPRO info file: '+infofile
   write_tab,file=infofile,infos,ival,form='(a12,1x,a12)'
;write 1D spec in SPECPRO format (structure array)
   if keyword_set(lmin) then wl1=lmin else wl1=min(wl)
   if keyword_set(lmax) then wl2=lmax else wl2=max(wl)
   kk=where(wl ge wl1 and wl le wl2)
   oned = {flux:flux[kk], lambda:wl[kk], ivar:fvar[kk]}
   mwrfits, oned, sfile, /create
   if keyword_set(spec2d) then begin
      sfile2d='spec2d.'+mskname+'.'+ids+'.'+'Ap_'+strim(rad[0]*10,'i3')+'.fits'
      twod = {flux:flux2d, lambda:wl2d, ivar:fvar2d}
      mwrfits, twod, sfile2d, /create
   endif
endif else begin
;Default output file name otherwise.. 
 if keyword_set(sfile) eq 0 then sfile='output_spec.fits'
 writefits,sfile,flux,hs
if n_elements(var) ne 0 then begin
 sxaddpar, hs,'OBJECT', 'MACSJ1149 (MUSE DATA VARIANCE)'
 writefits,file_basename(sfile,'.fits')+'_var.fits',fvar,hs
 print,' Output spec file: '+file_basename(sfile,'.fits')+'_var.fits'
endif

endelse

print,' Output spec file: '+sfile

out:

RETURN
END
