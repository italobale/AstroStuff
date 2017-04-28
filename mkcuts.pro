ftable='M1206_VIMOS_v1.5_FULLTABLE.cat'

xcol,ftable,'1,2,5,6,8,9,10,11',nam,slit,rav,decv,rai,deci,z,qf,form='a,i,d,d,d,d,f,i',skip="#"

ra=rai & dec=deci
k=where(ra lt -99 or dec lt -99)
ra[k]=rav[k] & dec[k]=decv[k]

dregfile='~/Dropbox/CLASH/MACS1206/slits_coord/'

for i=0,0
;i=1438-48
;for i=0,n_elements(ra)-1

 ff=findfile(dregfile+nam[i]+'_slits.reg')
 if ff eq '' then goto, skip else ff=ff[0]
 spawn,'cut -d"(" -f2 '+ff+' |cut -d")" -f1 |tr "," " " |tr "\"" " " >tmp1'

 readcol,'tmp1',rs,ds,ls,ws,rot,f='d,d,f,f,f'
 
 spawn,'cut -d"{" -f2 '+ff+' |cut -d"_" -f1',slitno
 k=where(fix(slitno) eq slit[i],nn)
 if nn eq 0 then begin
   print, 'Slit '+strim(slit[i],'i4')+ not found in '+ff 
   goto, skip
 endif
 forprint, nam[i],rs[k],ds[k],ls[k],ws[k],slit[i]
 
 ;exjpg,ra[i],dec[i],'~/CLASH/MACS1206/RGB_FITS/m1206_acsir_RGB.fits.gz',10,'test.png',head=hcut
 ;rd2xy,rs[k[0]],ds[k[0]],hcut,xsl,ysl
 exjpg,rr,dd,'~/CLASH/MACS1206/RGB_FITS/m1206_acsir_RGB.fits.gz',10,'test.png',head=hcut
 rd2xy,rr,dd,hcut,xsl,ysl
 getrot,hcut,rot,cdelt
 scl=avg(abs(cdelt))*3600. 
 ls2=ls[k[0]]/scl/2.            ;length in pixel /2
 ws2=ws[k[0]]/scl/2.            ;width in pixel /2
 img=read_image('test.png')
 tv, img, 0, 0,/true,xs=5,/centim
 plots,[xsl-ws2,xsl+ws2,xsl+ws2,xsl-ws2,xsl-ws2],[ysl-ls2,ysl-ls2,ysl+ls2,ysl+ls2,ysl-ls2],col=255

;-

 skip:
endfor




END
