;goto, addkeys

cat='catalogs/M1206_VIMOS_v1.5_FULLTABLE.cat'
assocfile='catalogs/OBID-Spec_filename.tab'

readcol,assocfile,f='a,a',obid0,root0
spawn,'grep -v ''#'' '+cat+ ' |awk ''{print $1,$2,$3,$4}'' >tmp1'
readcol,'tmp1',obids,slit,obj,id,f='a,i,i,l'
;obid0=obid0[0:15]
;root0=root0[0:15]
obid0=obid0[27]
root0=root0[27]
match_id,obids,obid0,i0,i

; obids[i0] <---> root0[i]
suffix='_cal_clean.fits'
suffixn='_noise.fits'
nchar=9-strlen(strim(id[i0],'i10'))
ss=strarr(n_elements(i0))
for j=0,n_elements(i0)-1 do ss[j]=strcat(replicate('0',nchar[j]))
nn=ss+strim(id[i0],'i10')

specfil='sc_'+nn+'_'+root0[i]+'_'+strim(slit[i0],'i5')+'_'+strim(obj[i0],'i8')+suffix
specfiln='sc_'+nn+'_'+root0[i]+'_'+strim(slit[i0],'i5')+'_'+strim(obj[i0],'i8')+suffixn

newspecfil=obid0[i]+'_'+strim(slit[i0],'i5')+'_'+strim(obj[i0],'i8')+'_1d.fits'  
newspecfiln=obid0[i]+'_'+strim(slit[i0],'i5')+'_'+strim(obj[i0],'i8')+'_noise.fits'  

;for j=0,n_elements(specfil)-1 do spawn,'cp Archival/LRr/mos/1D_Spectra/'+specfil[j]+' 1D_Spectra/'+newspecfil[j]
for j=0,n_elements(specfiln)-1 do spawn,'cp M2/mos/1D_Spectra/'+specfiln[j]+' 1D_Spectra/'+newspecfiln[j]

;;addkeys:
;for j=0,n_elements(newspecfil)-1 do begin
;  ff='1D_Spectra/'+newspecfil[j]               
;  spec=readfits(ff,hdr) 
;  sxaddpar,hdr,'ORIGNAME',specfil[j],'Original file name'
;  sxaddpar,hdr,'NEWNAME',newspecfil[j],'New file name'
;;  sxaddpar,hdr,'REDSHIFT',z[j],'Measured redshift',form='(f10.4)'
;;  sxaddpar,hdr,'RA_OBJ',ra[j],'RA Target',form='(f12.6)'
;;  sxaddpar,hdr,'DEC_OBJ',dec[j],'DEC Target',form='(f12.6)'
;  writefits,ff,spec,hdr  
;endfor

for j=0,n_elements(newspecfiln)-1 do begin
  ff='1D_Spectra/'+newspecfiln[j]	       
  spec=readfits(ff,hdr) 
  sxaddpar,hdr,'ORIGNAME',specfiln[j],'Original file name'
  sxaddpar,hdr,'NEWNAME',newspecfiln[j],'New file name'
;  sxaddpar,hdr,'REDSHIFT',z[j],'Measured redshift',form='(f10.4)'
;  sxaddpar,hdr,'RA_OBJ',ra[j],'RA Target',form='(f12.6)'
;  sxaddpar,hdr,'DEC_OBJ',dec[j],'DEC Target',form='(f12.6)'
  writefits,ff,spec,hdr
endfor

END
