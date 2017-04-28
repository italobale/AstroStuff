; Make sky plot from specz files

xs=17.   ;field size (arcmin)
ys=17.

;readcol,'Dan_cats/m1206_specz.cat',id, ra, dec, z, fl, f='l,d,d,f,i'
readcol,'~/Dropbox/CLASH-VLT/MACS1206/catalogs/MACS1206_v1.71_zcat.dat',id, ra, dec, z, fl, f='l,d,d,f,i'

i=where(fl gt 1) & id=id[i] & ra=ra[i] & dec=dec[i] & z=z[i] & fl=fl[i]

zcl=0.44     ; Cluster redshift here

c= 299792.458d0      
zcl=0.438 & sigcl=1500.  ; Ebeling et al. CL redshift
zcl1=zcl-3*sigcl/c*(1+zcl)
zcl2=zcl+3*sigcl/c*(1+zcl)
km=where(z ge zcl1 and z le zcl2)
;print, zcl1,zcl2
z1=0.51 & z2=0.55
k2=where(z ge z1 and z le z2)
z1_2=0.35-0.02 & z2_2=0.35+0.02
k1=where(z ge z1_2 and z le z2_2)

;BCG
r0=ten2('12:06:12.15')*15 & d0=ten2('-08:48:03.5')

xxc=cos(dec*!dtor)*(ra-r0)*60 & yyc=(dec-d0)*60

yps=17. & xps=24.
ps_start,'tmp.ps',xps,yps,/col,/enc

plot,[0],[0],psym=7,xtit='!7D!5_RA (arcmin)',ytit='!7D!5_Dec (arcmin)',xran=[xs,-xs],yran=[-ys,ys],/xsty,/ysty,/nodata,thick=4, pos=[.07,.1,.07+.7*yps/xps,.1+.7],tit='MACS1206'
plots,[0],[0],psym=7,col=0, thick=4
circle,0,0,zang(1000,1.,/sile)/60.,line=2,col=0,/dat
circle,0,0,zang(3000,1.,/sile)/60.,line=2,col=0,/dat
circle,0,0,zang(5000,1.,/sile)/60.,line=2,col=0,/dat

;xyouts,[0],[0],'BCG',align=-0.3,col=0
mysym,0,0.5,/fill
plots,xxc[km],yyc[km],psym=8, col=2
plots,xxc[k2],yyc[k2],psym=8, col=4
plots,xxc[k1],yyc[k1],psym=8, col=3
xyouts,-1*zang([1,3,5]*1000,1.,/sile)/60.,[0,0,0],/dat,['1','3','5'],alig=1,chars=1.3
xyouts,-15,0,/dat,['Mpc'],alig=1,chars=1.3
xyouts,0,13,/dat,strim(n_elements(ra),'i5')+' redshifts with QF>1',alig=0.5,chars=1.3

xs2=4
plot,[0],[0],psym=7, pos=[.65,.5,.65+.3*yps/xps,.5+.3],/noera,/nodata,xran=[xs2,-xs2],yran=[-xs2,xs2],/xsty,/ysty
oplot,xxc[km],yyc[km],psym=8, col=2
;plots,[0],[0],psym=7,col=0, thick=4
oplot,xxc[k2],yyc[k2],psym=8, col=4
oplot,xxc[k1],yyc[k1],psym=8, col=3
circle,0,0,zang(1000,1.,/sile)/60.,line=2,col=0,/dat
xyouts,-2,0,/dat,'1 Mpc',alig=.15

histo, z,0.1,0.9,.015,ysty=2,xtit='Redshift',chars=1.2, thick=3, pos=[.64,.1,.64+.33,.1+.33],/noera
vline,[zcl1,zcl2],thick=5,col=2,line=2
vline,[z1,z2],thick=5,col=4,line=2
vline,[z1_2,z2_2],thick=5,col=3,line=2
xyouts,orient=90,[z1,zcl1,z1_2]*.97,[1,1,1]*200,/dat,$
        strim([n_elements(k1),n_elements(km),n_elements(k2)],'i4')

ps_end,/nos

END
