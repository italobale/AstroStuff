; CROSS-MATCH VIPGI OUTPUT COORDINATES 
; (RECONSTRUCTED FROM mm TO CCD AND THEN USING MARIO'S GEOTRAN TO OBTAIN RA,DEC)
; *_xyOK.rd_clean
; WITH THE INPUT CATALOG (CFHT) FROM MARIO 
; MACS1206_CFHT_VIPGI.cat

readcol,'input_filename.dat',ff,OBs,qq,form='a,a,a'

readcol,'MACS1206_CFHT_VIPGI.cat',id2,ra2,dec2,f='a,d,d'

k=n_elements(ff)-1

for i=0,k do begin

; READ RA,DEC OF MASK_i
readcol,ff[i],slit,numb,id1,ra1,dec1,z,zflag,f='i,i,d,d,d,d,i'
spawn, 'grep -v ''#'' '+ff[i]+' | cut -c64-170',comm
forprint,ra1(0:10),dec1(0:10)

xcats,ra1,dec1,ra2,dec2,i1,i2,imiss=imiss,dist=1.0

; PRINT THE MATCHED SOURCES ON A FILE WITH
; I1, IDX(I1), RAX(I1), DECX(I1), I2, ID_ACS(I1), RA(I2), DEC(I2)
obb=make_array(n_elements(id1), /STRING, VALUE = OBs[i]+'_'+qq[i] )       
forprint,obb(i1),slit(i1),numb(i1),id1(i1),ra1(i1),dec1(i1),id2(i2),ra2(i2),dec2(i2),z(i1),zflag(i1),comm(i1), $
texto=OBs[i]+'_'+qq[i]+'_match.cat', form='(a25,2x,i3,2x,i2,2x,i8,2x,2f12.6,2x,a12,2x,2f12.6,2x,f6.4,2x,i3,2x,a-)',/nocomment

; PRINT THE MISSMATCHED SOURCES ON A FILE WITH
; ID1(IMISS), RA1(IMISS), DEC1(IMISS), ID2(IMISS)

forprint,obb(imiss),slit(imiss),numb(imiss),id1(imiss),ra1(imiss),dec1(imiss),z(imiss),zflag(imiss),comm(imiss), $
texto=OBs[i]+'_'+qq[i]+'_miss.cat', form='(a25,2x,i3,2x,i2,2x,i8,2x,2f12.6,2x,f6.4,2x,i3,2x,a-)',/nocomment

endfor

end


; CREATE A DS9 REGION FILE OF VIPGI RECONSTRUCTED COORDINATES
; FOR SOURCES WITH A MATCH WITHIN 1" RADIUS   
; cat M1206_*_match.cat | awk '{print "point("$5","$6") # point=cross text={"$1,$2,$3,$7"}"}' > VIPGI_RADEC_MATCHED_ID.reg

; CREATE A DS9 REGION FILE OF VIPGI RECONSTRUCTED COORDINATES
; FOR SOURCES WITHOUT A MATCH WITHIN 1" RADIUS
; cat M1206_*_miss.cat | awk '{print "point("$5","$6") # point=cross text={"$1,$2,$3,$4"}"}' > VIPGI_RADEC_MISSED_ID.reg

;cat M1206_*_match.cat | sort -k7 > all_match.cat
;cat M1206_*_miss.cat | sort -k5 > all_miss.cat

; cat all_match.cat all_miss.cat > M1206_VIMOS_FULLTABLE.cat
