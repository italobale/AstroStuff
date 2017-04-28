readcol,'input_file_pointings.dat',pid,pra,pdec,exp,form='(a,a,a,a)'

;SET IMAGE SIZE, SCALE, AND CENTER
imsize=30.
pixsc=5.0
nx=imsize*60/pixsc
rac=64.0345 & decc=-24.0729  

dummyhdr,hdr,rac,decc,imsize,imsize,/arcm,pxs=pixsc

nxy=sxpar(hdr,'NAXIS*')
im=fltarr(nxy[0],nxy[1])
master=im*0.

;SET FOOTPRINT (8x7.15 arcmin) AND OFFSETS OF THE 4 QUADRANTS
imq_x=8.0   ;arcmin
imq_y=7.15  ;arcmin
dra1=0.1666 & dra2=-0.019 & ddec1=-0.135 & ddec2=0.0144

FOR i=0,n_elements(pid)-1 do begin

footprint=fltarr(imq_x*60/pixsc,imq_y*60/pixsc)+exp[i]

;Q1
rd2xy,pra[i]+dra1,pdec[i]+ddec1,hdr,x1,y1
im[x1,y1]=footprint & master=master+im & im=fltarr(nxy[0],nxy[1])
;Q2
rd2xy,pra[i]+dra1,pdec[i]+ddec2,hdr,x2,y2
im[x2,y2]=footprint & master=master+im & im=fltarr(nxy[0],nxy[1])
;Q3
rd2xy,pra[i]+dra2,pdec[i]+ddec2,hdr,x3,y3
im[x3,y3]=footprint & master=master+im & im=fltarr(nxy[0],nxy[1])
;Q4
rd2xy,pra[i]+dra2,pdec[i]+ddec1,hdr,x4,y4
im[x4,y4]=footprint & master=master+im & im=fltarr(nxy[0],nxy[1])

ENDFOR

; MANUALLY SUBTRACT FAILED QUADRANTS (IF ANY)
; M3 p2 Q3 
ra0=63.965857 & dec0=-24.01170 & exp0=3600
rd2xy,ra0+dra2,dec0+ddec2,hdr,x3,y3
footprint=fltarr(imq_x*60/pixsc,imq_y*60/pixsc)+exp0
im[x3,y3]=footprint & master=master-im

writefits,'expmap_M0416.fits',master,hdr

END
