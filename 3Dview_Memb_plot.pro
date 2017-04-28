view='redshift'
;view='dist'

readcol,'M0416_v3.0_nonmembers.cat',id,x,y,z,zfl,$
form='(l,d,d,d,i)'
readcol,'M0416_v3.0_members.cat',idm,xm,ym,zm,zflm,$
form='(l,d,d,d,i)'

; SET PLOT PARAMETERS

; DEFINE THE CENTER OF THE BOX TO PLOT (e.g. COORDINATES AND z OF THE BCG)
  ra_cen=64.038094
  dec_cen=-24.067507
  z_cen=0.3961

; DEFINE THE DEPTH OF THE BOX 
  z1=0.2 & z2=0.6

; FILTER OUT HI- AND LOW-z OBJECTS
x=x(where(zfl gt 1 and z gt z1 and z lt z2))
y=y(where(zfl gt 1 and z gt z1 and z lt z2))
z=z(where(zfl gt 1 and z gt z1 and z lt z2))

xm=xm(where(zflm gt 1 and zm gt 0.3 and zm lt 0.7))
ym=ym(where(zflm gt 1 and zm gt 0.3 and zm lt 0.7))
zm=zm(where(zflm gt 1 and zm gt 0.3 and zm lt 0.7))

; COMPUTE COMOVING DISTANCES in Mpc FROM THE CENTER OF THE BOX
  dlx=(x-ra_cen)*3600
  xx=zang2(dlx,z,h0=71,Omega_m=0.27,Lambda0=0.73)/1000
  dly=(y-dec_cen)*3600
  yy=zang2(dly,z,h0=71,Omega_m=0.27,Lambda0=0.73)/1000

  dlxm=(xm-ra_cen)*3600
  xxm=zang2(dlxm,zm,h0=71,Omega_m=0.27,Lambda0=0.73)/1000
  dlym=(ym-dec_cen)*3600
  yym=zang2(dlym,zm,h0=71,Omega_m=0.27,Lambda0=0.73)/1000

 if view eq 'dist' then begin

  zz=comov_dist(z,H0=71,Omega_m=0.27,Lambda0=0.73)
  zz_cen=comov_dist(z_cen,H0=71,Omega_m=0.27,Lambda0=0.73)
  zz0=make_array(n_elements(zz),Value=zz_cen, /Double)
  dlz=zz-zz0

  zzm=comov_dist(zm,H0=71,Omega_m=0.27,Lambda0=0.73)
  zzm_cen=comov_dist(z_cen,H0=71,Omega_m=0.27,Lambda0=0.73)
  zz0m=make_array(n_elements(zzm),Value=zzm_cen, /Double)
  dlzm=zzm-zz0m

 zmin=comov_dist(z1,H0=71,Omega_m=0.27,Lambda0=0.73)
 zmax=comov_dist(z2,H0=71,Omega_m=0.27,Lambda0=0.73)


; THIS PLOTS THE ACTUAL COMOVING VOLUME
p=plot3d(xx,yy,dlz,XTITLE='RA [Mpc]',YTITLE='DEC [Mpc]',ZRANGE=[zmin-zz0,zmax-zz0],AXIS_STYLE=2,XMINOR=0,YMINOR=0,ASPECT_Z=0.08,$
DEPTH_CUE=[0,2],/PERSPECTIVE,FONT_SIZE=6,sym_object=orb(color=[255,0,0],radius=0.5),linestyle='none')
 endif

 if view eq 'redshift' then begin

; THIS PLOTS JUST RA, DEC, AND z
;p=plot3d(xx,yy,z,XTICKNAME=['','','','','','',''],YTICKNAME=['','','','','','',''],ZRANGE=[z1,z2],AXIS_STYLE=2,XMINOR=0,YMINOR=0,ASPECT_Z=300,$
;DEPTH_CUE=[0,2],/PERSPECTIVE,FONT_SIZE=14,sym_object=orb(color=[0,0,255],radius=0.5),linestyle='none')
;p=plot3d(xxm,yym,zm,XTICKNAME=['','','','','','',''],YTICKNAME=['','','','','','',''],ZRANGE=[z1,z2],AXIS_STYLE=2,XMINOR=0,YMINOR=0,ASPECT_Z=300,$
;DEPTH_CUE=[0,2],/PERSPECTIVE,FONT_SIZE=14,sym_object=orb(color=[255,0,0],radius=0.5),linestyle='none',/overplot)

p=plot3d(xx,yy,z,XTICKNAME=['','','','','','',''],YTICKNAME=['','','','','','',''],ZTICKNAME=['','','','',''],ZRANGE=[z1,z2],AXIS_STYLE=2,XMINOR=0,YMINOR=0,ASPECT_Z=300,$
DEPTH_CUE=[0,2],/PERSPECTIVE,FONT_SIZE=14,sym_object=orb(color=[0,0,255],radius=0.2),linestyle='none')
p=plot3d(xxm,yym,zm,XTICKNAME=['','','','','','',''],YTICKNAME=['','','','','','',''],ZTICKNAME=['','','','',''],ZRANGE=[z1,z2],AXIS_STYLE=2,XMINOR=0,YMINOR=0,ASPECT_Z=300,$
DEPTH_CUE=[0,2],/PERSPECTIVE,FONT_SIZE=14,sym_object=orb(color=[255,0,0],radius=0.2),linestyle='none',/overplot)
 endif

;SET VIEWING ANGLE
p.Rotate,/reset       
p.Rotate, -180, /YAXIS
p.Rotate, -180, /ZAXIS
p.Rotate, -90, /YAXIS
;SAVE IMAGES FOR TIMELAPSE VIDEO 
i=findgen(100)
ii=string(format='(i03)',i)
for i=0,n_elements(i)-1 do begin & p.Rotate, 3.6, /XAXIS & p.Save, "test"+ii(i)+".jpg",RESOLUTION=200 & endfor


end
