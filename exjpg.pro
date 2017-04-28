PRO EXJPG,ra,dec,rgbfil,siz,outfile,xmin,xmax,ymin,ymax, pos=pos, header=hcut,status=stat, $
    raslit=raslit,decslit=decslit,length=len,width=wid, title=tit, siztitle=stit
;+
;ra,dec in DEGREE (can also be array)
;rgbfil:  RGB FITS imsge
;siz: [sx,sy] in ARCSEC (or [sx,sx] if only one element is passed)
;outfil: output PNG file(s) (also array if RA and DEC are arrays)
;title: target name(s) (also array if RA and DEC are arrays)
;xmin,xmax,ymin,ymax: image boundaries
;slitinfo: ra(deg), dec(deg),len(arcsec), wid(arcsec)
;Exa: exjpg,ten(12,06,13.3)*15.,ten(-8,47,37),'~/CLASH/MACS1206/RGB_FITS/m1206_acsir_RGB.fits.gz',15.,'test.png',1802,4743,1513,4566
;-

stat=0
if n_elements(stit) eq 0 then stit=0.8
r=readfits(rgbfil,h,ex=1) 
g=readfits(rgbfil,ex=2) 
b=readfits(rgbfil,ex=3) 

getrot,h,rot,cdelt
scl=avg(abs(cdelt))*3600.
if n_elements(siz) eq 2 then begin
 shx=siz(0)/scl/2.
 shy=siz(1)/scl/2.
endif else begin
 shx=siz/scl/2.
 shy=shx
endelse

nn=n_elements(ra)
nxy=size(r,/dim)

for i=0,nn-1 do begin
 rd2xy,ra[i],dec[i],h,xc,yc
 if (xc le 0 or yc le 0 or xc ge nxy[0] or yc ge nxy[1]) then begin
   print, 'Cutout out of bounds !'
   stat=1
   goto, out
 endif
; pos=[x0,x1,y0,y1]
;   print, '[x0,x1,y0,y1] =',pos
 pos=[fix(xc-shx)>0,ceil(xc+shx)<nxy[0],fix(yc-shy)>0,ceil(yc+shy)<nxy[1]]
 sx=pos[1]-pos[0]+1
 sy=pos[3]-pos[2]+1


 hextract,r,h,rcut,hcut,pos[0],pos[1],pos[2],pos[3],status=status
 hextract,g,h,gcut,hcut,pos[0],pos[1],pos[2],pos[3],status=status
 hextract,b,h,bcut,hcut,pos[0],pos[1],pos[2],pos[3],status=status

 cube=bytarr(3,sx,sy) 
 cube(0,*,*)=byte(rcut)
 cube(1,*,*)=byte(gcut)
 cube(2,*,*)=byte(bcut)

 if n_elements(raslit) eq 0 then $
  write_image,outfile[i],'PNG',cube $
  else begin                        ; create a PS file (color img + slit) is the slit info are passed
   ps_start,outfile[i],5,5,/enc,/col 
    loadct,0
    tv, cube, 0, 0,/true,xs=5,/centim
    loadct,39  
    rd2xy,raslit[i],decslit[i],hcut,xsl,ysl
    getrot,hcut,rot,cdelt & scl=avg(abs(cdelt))*3600. 
    ls2=len[i]/scl/2.            ;length in pixel /2
    ws2=wid[i]/scl/2.            ;width in pixel /2

    plots,[xsl-ws2,xsl+ws2,xsl+ws2,xsl-ws2,xsl-ws2]/sx,$
          [ysl-ls2,ysl-ls2,ysl+ls2,ysl+ls2,ysl-ls2]/sy,col=250,/NORMAL
    if n_elements(tit) ne 0 then xyouts,.01,.93,tit[i],/norm,col=255,chars=stit
   ps_end,/nos 

  endelse
  
 print,outfile[i]+'  created...'

 out:
endfor

END

