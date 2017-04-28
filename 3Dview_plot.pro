;Define custom plotting symbols:
;oOrb = OBJ_NEW('orb', COLOR=[0, 0, 255],radius=0.5)
;oSymbol = OBJ_NEW('IDLgrSymbol', oOrb)

view='redshift'
;view='dist'

readcol,'M1206_VIMOS_v2.2_TABLE.cat',obid,slit,objn,id0,ra0,dec0,id,x,y,z,zfl,$
form='(a,i,i,l,d,d,l,d,d,d,i)'

; SET PLOT PARAMETERS

; DEFINE THE CENTER OF THE BOX TO PLOT (e.g. COORDINATES AND z OF THE BCG)
  ra_cen=181.55
  dec_cen=-8.8
  z_cen=0.4407

; DEFINE THE DEPTH OF THE BOX 
  z1=0.4 & z2=0.5

; FILTER OUT HI- AND LOW-z OBJECTS
x=x(where(zfl gt 1 and z gt 0.3 and z lt 0.7))
y=y(where(zfl gt 1 and z gt 0.3 and z lt 0.7))
z=z(where(zfl gt 1 and z gt 0.3 and z lt 0.7))

; COMPUTE COMOVING DISTANCES in Mpc FROM THE CENTER OF THE BOX
  dlx=(x-ra_cen)*3600
  xx=zang2(dlx,z,h0=71,Omega_m=0.27,Lambda0=0.73)/1000
  dly=(y-dec_cen)*3600
  yy=zang2(dly,z,h0=71,Omega_m=0.27,Lambda0=0.73)/1000

 if view eq 'dist' then begin

  zz=comov_dist(z,H0=71,Omega_m=0.27,Lambda0=0.73)
  zz_cen=comov_dist(z_cen,H0=71,Omega_m=0.27,Lambda0=0.73)
  zz0=make_array(n_elements(zz),Value=zz_cen, /Double)
  dlz=zz-zz0

 zmin=comov_dist(z1,H0=71,Omega_m=0.27,Lambda0=0.73)
 zmax=comov_dist(z2,H0=71,Omega_m=0.27,Lambda0=0.73)
 
; THIS PLOTS THE ACTUAL COMOVING VOLUME
p=plot3d(xx,yy,dlz,XTITLE='RA [Mpc]',YTITLE='DEC [Mpc]',ZTITLE='Comoving Distance [Mpc]',ZRANGE=[zmin-zz0,zmax-zz0],AXIS_STYLE=2,XMINOR=0,YMINOR=0,ASPECT_Z=0.1,$
DEPTH_CUE=[0,2],/PERSPECTIVE,FONT_SIZE=6,sym_object=orb(color=[255,0,0],radius=0.5),linestyle='none')
 endif

 if view eq 'redshift' then begin

; THIS PLOTS JUST RA, DEC, AND z
p=plot3d(xx,yy,z,XTITLE='RA',YTITLE='DEC',ZTITLE='z',ZRANGE=[z1,z2],AXIS_STYLE=2,XMINOR=0,YMINOR=0,ASPECT_Z=300,$
DEPTH_CUE=[0,2],/PERSPECTIVE,FONT_SIZE=6,sym_object=orb(radius=0.5),linestyle='none')
 endif

end
