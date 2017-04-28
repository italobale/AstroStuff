pro convert_vimos_to_specpro, reduction_file, maskname=maskname, outdir=outdir, objectnames=objectnames

;Inputs:
;
; reduction_file - The output file produced by the VIPGI reduction
;                  pipeline, containing 1D/2D data for all spectra.
; maskname - Optional input specifying the mask name to be used in
;            naming 1d/2d specpro files.
; outdir - Optional input string specifying to directory in which to
;          save the specpro formatted data. 
; objectnames - Optional string array specifying target names for each
;               object, to be used in naming 1d/2d files. If omitted
;               then the default name is 'slit_*_obj_*', with the
;               numbers from the WIN array.
;
;Outputs:
;
;spec1d files - Specpro formatted 1d spectra, with the object numbers
;               as assigned in the Window table.
;spec2d files - same as for 1d, but for the 2d spectra.
;info files - Information files in specpro format. Object slit
;             position is saved. 

;First load the data using the different extensions

if keyword_set(maskname) ne 1 then begin
   maskname = 'vimos'
endif
if keyword_set(outdir) ne 1 then begin
   outdir = '.'
endif

exr1d = mrdfits(reduction_file,'EXR1D')
exr2d = mrdfits(reduction_file,'EXR2D')
sky2d = mrdfits(reduction_file,'SKY2D')
obj = mrdfits(reduction_file,'OBJ')
win = mrdfits(reduction_file,'WIN')
exr1dresl = mrdfits(reduction_file,'EXR1DRESL')
exr1dresr = mrdfits(reduction_file,'EXR1DRESR')
noise = mrdfits(reduction_file,'NOISE')
exr1dedit = mrdfits(reduction_file,'EXR1DEDIT',head)
cdelt1 = sxpar(head, 'CDELT1')
crpix1 = sxpar(head, 'CRPIX1')
crval1 = sxpar(head, 'CRVAL1')

;Begin loop to extract, format, and save 1D/2D spectra in specpro
;format.
sz = size(exr1d)
pixels = indgen(sz[1])+1

;get the wavelength solution for the chip
wv = cdelt1 * (pixels-crpix1)+crval1

for i = 0, sz(2)-1 do begin
  thisspec1d = exr1dedit(*,i) ;use clipped 1d spec
  spec_start = win[i].spec_start
  spec_end = win[i].spec_end
  obj_start = win[i].obj_start
  obj_end = win[i].obj_end
  slit_num = win[i].slit
  obj_num = win[i].obj_no
  thisspec2d = exr2d[*,spec_start:spec_end]
  thisnoise = noise(*,i)
  thisnoise2d = rebin(thisnoise,float(sz[1]),spec_end-spec_start+1)
  ;make the 2d wave solution
  wv2d = rebin(wv,float(sz[1]),spec_end-spec_start+1)
  
  ;save 1d/2d specpro files
  spec1d = {flux:thisspec1d, lambda:wv, ivar:1/thisnoise^2}
  spec2d = {flux:thisspec2d, lambda:wv2d, ivar:1/thisnoise2d^2}

  ;little info for information file
  extractpos = round((obj_start+obj_end)/2.)
  extractwidth = obj_end-obj_start

  if keyword_set(objectnames) eq 1 then begin
     spec1dname = outdir+'/spec1d.'+maskname+'.'+string(i+1,f='(I03)')+'.'+objectnames[i]+'.fits'
     spec2dname = outdir+'/spec2d.'+maskname+'.'+string(i+1,f='(I03)')+'.'+objectnames[i]+'.fits'
     infoname =  outdir+'/info.'+maskname+'.'+string(i+1,f='(I03)')+'.'+objectnames[i]+'.dat'
  endif else begin
     thisname = 'slit_'+strcompress(string(slit_num),/remove_all)+'_obj_'+strcompress(string(obj_num),/remove_all)
     spec1dname = outdir+'/spec1d.'+maskname+'.'+string(i+1,f='(I03)')+'.'+thisname+'.fits'
     spec2dname = outdir+'/spec2d.'+maskname+'.'+string(i+1,f='(I03)')+'.'+thisname+'.fits'    
     infoname =  outdir+'/info.'+maskname+'.'+string(i+1,f='(I03)')+'.'+thisname+'.dat'
  endelse

  ;write these out
  mwrfits, spec1d, spec1dname, /create
  mwrfits, spec2d, spec2dname, /create
  openw, lun, infoname, /get_lun, /append
  printf, lun, 'extractpos', extractpos, f='(a, i)'
  printf, lun, 'extractwidth', extractwidth, f='(a, i)'
  close, lun
  free_lun, lun

endfor

end ;convert_vimos_to_specpro




