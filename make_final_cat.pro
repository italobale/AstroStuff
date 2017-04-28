; REMOVE DUPLICATES AND CREATE THE FINAL CATALOG OF UNIQUE ENTRIES
; WITH AVERAGE REDSHIFT IN CASE OF MULTIPLE MEASUREMENTS (ONLY IF CONSITENT)
; USES M1206_VIMOS_v1.5_FULLTABLE.cat ==> M1206_VIMOS_v1.5_FULLTABLE.tmp 
;(REMOVE flag 24,23,etc. AND CHANGE FLAGS TO 3(=3,4), 2.9(=9), 2.5(=5,6,7,8), 2, 1, 0 ONLY)

spawn," grep -v '#' M1206_VIMOS_v1.5_FULLTABLE.tmp | sort -k7 | awk '{print $7}' | uniq -u > unique_ID.dat"
readcol,'unique_ID.dat',idu,form='d'

spawn," grep -v '#' M1206_VIMOS_v1.5_FULLTABLE.tmp | sort -k7 | awk '{print $7}' | uniq -d > multipl_ID.dat"
;readcol,'multipl_ID.dat',idm,form='d'

readcol,'M1206_VIMOS_v1.5_FULLTABLE.tmp',obb,slit,numb,id1,ra1,dec1,id2,ra2,dec2,z,zflag,form='a,i,i,d,d,d,d,d,d,d,i'
spawn, 'grep -v ''#'' M1206_VIMOS_v1.5_FULLTABLE.tmp | cut -c126-230',comm

match_id,idu,id2,i1,i2
 
  gg=make_array(n_elements(id1),/STRING,value='1  0.000000')

; PRINT UNIQUE ENTRIES ON A NEW FILE
forprint,obb(i2),slit(i2),numb(i2),id1(i2),ra1(i2),dec1(i2),id2(i2),ra2(i2),dec2(i2),z(i2),zflag(i2),gg(i2),comm(i2), texto='UNIQUE.tmp', form='(a25,2x,i3,2x,i2,2x,i8,2x,2f12.6,2x,i8,2x,2f12.6,2x,f7.5,2x,i3,2x,a11,2x,a-)',/nocomment

  multi=make_array(n_elements(id1),/INTEGER,value=0)

for i=0,n_elements(z)-1 do begin
     for j=0,n_elements(z)-1 do begin
         if (id2[i] eq id2[j]) then  multi[i]=multi[i]+1 
     endfor
endfor

k=where(multi gt 1)

forprint,obb(k),slit(k),numb(k),id1(k),ra1(k),dec1(k),id2(k),ra2(k),dec2(k),z(k),zflag(k),multi(k), $
texto='all_multi.cat', form='(a25,2x,i3,2x,i2,2x,i8,2x,2f12.6,2x,i8,2x,2f12.6,2x,f7.5,2x,i3,2x,i1)',/nocomment
 
spawn,"cat all_multi.cat | awk '$12==7' | sort -k7 > m7.dat"
spawn,"cat all_multi.cat | awk '$12==6' | sort -k7 > m6.dat"
spawn,"cat all_multi.cat | awk '$12==5' | sort -k7 > m5.dat"
spawn,"cat all_multi.cat | awk '$12==4' | sort -k7 > m4.dat"
spawn,"cat all_multi.cat | awk '$12==3' | sort -k7 > m3.dat"
spawn,"cat all_multi.cat | awk '$12==2' | sort -k7 > m2.dat"

; MULTIPLICITY 7

readcol,'m7.dat',obb0,slit0,numb0,id10,ra10,dec10,id20,ra20,dec20,z0,zflag0,multi0,form='a,i,i,d,d,d,d,d,d,d,i,i' 
k1=0+findgen(n_elements(z0)/7)*7
k2=1+findgen(n_elements(z0)/7)*7
k3=2+findgen(n_elements(z0)/7)*7
k4=3+findgen(n_elements(z0)/7)*7
k5=4+findgen(n_elements(z0)/7)*7
k6=5+findgen(n_elements(z0)/7)*7
k7=6+findgen(n_elements(z0)/7)*7

  zbest0=(z0[k1]+z0[k2]+z0[k3]+z0[k4]+z0[k5]+z0[k6]+z0[k7])/7

forprint,id10(k1),z0(k1),zflag0(k1),z0(k2),zflag0(k2),z0(k3),zflag0(k3),z0(k4),zflag0(k4),z0(k5),zflag0(k5),z0(k6),zflag0(k6),z0(k7),zflag0(k7),zbest0,multi0(k1), $
texto='z_qf_multi7.cat', form='(i8,2x,f6.4,1x,f3.1,1x,f6.4,1x,f3.1,1x,f6.4,1x,f3.1,1x,f6.4,1x,f3.1,1x,f6.4,1x,f3.1,1x,f6.4,1x,f3.1,1x,f6.4,1x,f3.1,2x,f7.5,2x,i1)',/nocomment
readcol,'z_qf_multi7.cat',id00,z1,zflag1,z2,zflag2,z3,zflag3,z4,zflag4,z5,zflag5,z6,zflag6,z7,zflag7,zbest,multi,form='d,d,i,d,i,d,i,d,i,d,i,d,i,d,i,d,i' 

std=fltarr(n_elements(id00))
zflbest=fltarr(n_elements(id00))
for i=0,n_elements(id00)-1 do begin
   x=[z1[i],z2[i],z3[i],z4[i],z5[i],z6[i],z7[i]]
   y=moment(x, SDEV=sstd)
   std[i]=sstd
   pp=[zflag1[i],zflag2[i],zflag3[i],zflag4[i],zflag5[i],zflag6[i],zflag7[i]]
   zflbest[i]=max(pp)
endfor
comm=make_array(n_elements(id00),/STRING,value='| -')
forprint,obb0(k1),slit0(k1),numb0(k1),id10(k1),ra10(k1),dec10(k1),id20(k1),ra20(k1),dec20(k1),zbest,zflbest,multi,std,comm, $
texto='MULTI7.tmp',form='(a25,2x,i3,2x,i2,2x,i8,2x,2f12.6,2x,i8,2x,2f12.6,2x,f7.5,2x,i3,2x,i1,2x,f7.5,2x,a-)',/nocomment


; MULTIPLICITY 6

readcol,'m6.dat',obb0,slit0,numb0,id10,ra10,dec10,id20,ra20,dec20,z0,zflag0,multi0,form='a,i,i,d,d,d,d,d,d,d,i,i' 
k1=0+findgen(n_elements(z0)/6)*6
k2=1+findgen(n_elements(z0)/6)*6
k3=2+findgen(n_elements(z0)/6)*6
k4=3+findgen(n_elements(z0)/6)*6
k5=4+findgen(n_elements(z0)/6)*6
k6=5+findgen(n_elements(z0)/6)*6

  zbest0=(z0[k1]+z0[k2]+z0[k3]+z0[k4]+z0[k5]+z0[k6])/6

forprint,id10(k1),z0(k1),zflag0(k1),z0(k2),zflag0(k2),z0(k3),zflag0(k3),z0(k4),zflag0(k4),z0(k5),zflag0(k5),z0(k6),zflag0(k6),zbest0,multi0(k1), $
texto='z_qf_multi6.cat', form='(i8,2x,f6.4,1x,f3.1,1x,f6.4,1x,f3.1,1x,f6.4,1x,f3.1,1x,f6.4,1x,f3.1,1x,f6.4,1x,f3.1,1x,f6.4,1x,f3.1,2x,f7.5,2x,i1)',/nocomment
readcol,'z_qf_multi6.cat',id00,z1,zflag1,z2,zflag2,z3,zflag3,z4,zflag4,z5,zflag5,z6,zflag6,zbest,multi,form='d,d,i,d,i,d,i,d,i,d,i,d,i,d,i' 

std=fltarr(n_elements(id00))
zflbest=fltarr(n_elements(id00))
for i=0,n_elements(id00)-1 do begin
   x=[z1[i],z2[i],z3[i],z4[i],z5[i],z6[i]]
   y=moment(x, SDEV=sstd)
   std[i]=sstd
   pp=[zflag1[i],zflag2[i],zflag3[i],zflag4[i],zflag5[i],zflag6[i]]
   zflbest[i]=max(pp)
endfor
comm=make_array(n_elements(id00),/STRING,value='| -')
forprint,obb0(k1),slit0(k1),numb0(k1),id10(k1),ra10(k1),dec10(k1),id20(k1),ra20(k1),dec20(k1),zbest,zflbest,multi,std,comm, $
texto='MULTI6.tmp',form='(a25,2x,i3,2x,i2,2x,i8,2x,2f12.6,2x,i8,2x,2f12.6,2x,f7.5,2x,i3,2x,i1,2x,f7.5,2x,a-)',/nocomment

; MULTIPLICITY 5

readcol,'m5.dat',obb0,slit0,numb0,id10,ra10,dec10,id20,ra20,dec20,z0,zflag0,multi0,form='a,i,i,d,d,d,d,d,d,d,i,i' 
k1=0+findgen(n_elements(z0)/5)*5
k2=1+findgen(n_elements(z0)/5)*5
k3=2+findgen(n_elements(z0)/5)*5
k4=3+findgen(n_elements(z0)/5)*5
k5=4+findgen(n_elements(z0)/5)*5

  zbest0=(z0[k1]+z0[k2]+z0[k3]+z0[k4]+z0[k5])/5

forprint,id10(k1),z0(k1),zflag0(k1),z0(k2),zflag0(k2),z0(k3),zflag0(k3),z0(k4),zflag0(k4),z0(k5),zflag0(k5),zbest0,multi0(k1), $
texto='z_qf_multi5.cat', form='(i8,2x,f6.4,1x,f3.1,1x,f6.4,1x,f3.1,1x,f6.4,1x,f3.1,1x,f6.4,1x,f3.1,1x,f6.4,1x,f3.1,2x,f7.5,2x,i1)',/nocomment
readcol,'z_qf_multi5.cat',id00,z1,zflag1,z2,zflag2,z3,zflag3,z4,zflag4,z5,zflag5,zbest,multi,form='d,d,d,d,d,d,d,d,d,d,d,d,i' 

std=fltarr(n_elements(id00))
zflbest=fltarr(n_elements(id00))
for i=0,n_elements(id00)-1 do begin
   x=[z1[i],z2[i],z3[i],z4[i],z5[i]]
   y=moment(x, SDEV=sstd)
   std[i]=sstd
   pp=[zflag1[i],zflag2[i],zflag3[i],zflag4[i],zflag5[i]]
   zflbest[i]=max(pp)
endfor
comm=make_array(n_elements(id00),/STRING,value='| -')
forprint,obb0(k1),slit0(k1),numb0(k1),id10(k1),ra10(k1),dec10(k1),id20(k1),ra20(k1),dec20(k1),zbest,zflbest,multi,std,comm, $
texto='MULTI5.tmp',form='(a25,2x,i3,2x,i2,2x,i8,2x,2f12.6,2x,i8,2x,2f12.6,2x,f7.5,2x,i3,2x,i1,2x,f7.5,2x,a-)',/nocomment

; MULTIPLICITY 4

readcol,'m4.dat',obb0,slit0,numb0,id10,ra10,dec10,id20,ra20,dec20,z0,zflag0,multi0,form='a,i,i,d,d,d,d,d,d,d,i,i' 
k1=0+findgen(n_elements(z0)/4)*4
k2=1+findgen(n_elements(z0)/4)*4
k3=2+findgen(n_elements(z0)/4)*4
k4=3+findgen(n_elements(z0)/4)*4

  zbest0=(z0[k1]+z0[k2]+z0[k3]+z0[k4])/4

forprint,id10(k1),z0(k1),zflag0(k1),z0(k2),zflag0(k2),z0(k3),zflag0(k3),z0(k4),zflag0(k4),zbest0,multi0(k1), $
texto='z_qf_multi4.cat', form='(i8,2x,f6.4,1x,f3.1,1x,f6.4,1x,f3.1,1x,f6.4,1x,f3.1,1x,f6.4,1x,f3.1,2x,f7.5,2x,i1)',/nocomment
readcol,'z_qf_multi4.cat',id00,z1,zflag1,z2,zflag2,z3,zflag3,z4,zflag4,zbest,multi,form='d,d,d,d,d,d,d,d,d,d,i' 

std=fltarr(n_elements(id00))
zflbest=fltarr(n_elements(id00))
for i=0,n_elements(id00)-1 do begin
   x=[z1[i],z2[i],z3[i],z4[i]]
   y=moment(x, SDEV=sstd)
   std[i]=sstd
   pp=[zflag1[i],zflag2[i],zflag3[i],zflag4[i]]
   zflbest[i]=max(pp)
endfor
comm=make_array(n_elements(id00),/STRING,value='| -')
forprint,obb0(k1),slit0(k1),numb0(k1),id10(k1),ra10(k1),dec10(k1),id20(k1),ra20(k1),dec20(k1),zbest,zflbest,multi,std,comm, $
texto='MULTI4.tmp',form='(a25,2x,i3,2x,i2,2x,i8,2x,2f12.6,2x,i8,2x,2f12.6,2x,f7.5,2x,i3,2x,i1,2x,f7.5,2x,a-)',/nocomment

; MULTIPLICITY 3

readcol,'m3.dat',obb0,slit0,numb0,id10,ra10,dec10,id20,ra20,dec20,z0,zflag0,multi0,form='a,i,i,d,d,d,d,d,d,d,i,i' 
k1=0+findgen(n_elements(z0)/3)*3
k2=1+findgen(n_elements(z0)/3)*3
k3=2+findgen(n_elements(z0)/3)*3

  zbest0=(z0[k1]+z0[k2]+z0[k3])/3

forprint,id10(k1),z0(k1),zflag0(k1),z0(k2),zflag0(k2),z0(k3),zflag0(k3),zbest0,multi0(k1), $
texto='z_qf_multi3.cat', form='(i8,2x,f6.4,1x,f3.1,1x,f6.4,1x,f3.1,1x,f6.4,1x,f3.1,2x,f7.5,2x,i1)',/nocomment
readcol,'z_qf_multi3.cat',id00,z1,zflag1,z2,zflag2,z3,zflag3,zbest,multi,form='d,d,d,d,d,d,d,d,i' 

std=fltarr(n_elements(id00))
zflbest=fltarr(n_elements(id00))
for i=0,n_elements(id00)-1 do begin
   x=[z1[i],z2[i],z3[i]]
   y=moment(x, SDEV=sstd)
   std[i]=sstd
   pp=[zflag1[i],zflag2[i],zflag3[i]]
   zflbest[i]=max(pp)
endfor
comm=make_array(n_elements(id00),/STRING,value='| -')
forprint,obb0(k1),slit0(k1),numb0(k1),id10(k1),ra10(k1),dec10(k1),id20(k1),ra20(k1),dec20(k1),zbest,zflbest,multi,std,comm, $
texto='MULTI3.tmp',form='(a25,2x,i3,2x,i2,2x,i8,2x,2f12.6,2x,i8,2x,2f12.6,2x,f7.5,2x,i3,2x,i1,2x,f7.5,2x,a-)',/nocomment

; MULTIPLICITY 2

readcol,'m2.dat',obb0,slit0,numb0,id10,ra10,dec10,id20,ra20,dec20,z0,zflag0,multi0,form='a,i,i,d,d,d,d,d,d,d,i,i' 
k1=0+findgen(n_elements(z0)/2)*2
k2=1+findgen(n_elements(z0)/2)*2

  zbest0=(z0[k1]+z0[k2])/2

forprint,id10(k1),z0(k1),zflag0(k1),z0(k2),zflag0(k2),zbest0,multi0(k1), $
texto='z_qf_multi2.cat', form='(i8,2x,f6.4,1x,f3.1,1x,f6.4,1x,f3.1,2x,f7.5,2x,i1)',/nocomment
readcol,'z_qf_multi2.cat',id00,z1,zflag1,z2,zflag2,zbest,multi,form='d,d,d,d,d,d,i' 

std=fltarr(n_elements(id00))
zflbest=fltarr(n_elements(id00))
for i=0,n_elements(id00)-1 do begin
   x=[z1[i],z2[i]]
   y=moment(x, SDEV=sstd)
   std[i]=sstd
   pp=[zflag1[i],zflag2[i]]
   zflbest[i]=max(pp)
endfor
comm=make_array(n_elements(id00),/STRING,value='| -')
forprint,obb0(k1),slit0(k1),numb0(k1),id10(k1),ra10(k1),dec10(k1),id20(k1),ra20(k1),dec20(k1),zbest,zflbest,multi,std,comm, $
texto='MULTI2.tmp',form='(a25,2x,i3,2x,i2,2x,i8,2x,2f12.6,2x,i8,2x,2f12.6,2x,f7.5,2x,i3,2x,i1,2x,f7.5,2x,a-)',/nocomment


end

