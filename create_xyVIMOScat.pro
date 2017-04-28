readcol,'input_files.dat',OBs,qq,preimg,ff,summf,nt,form='(a,a,a,a,a,i)'

mm0_only=0        ;1=get only the objects with zero mm (no match is performed)
                  ;0=do everything
ans='a'


k=n_elements(ff)-1

offx=findgen(k+1)
offy=findgen(k+1)

spawn,'rm forprint.prt'
forprint,'',text=7,comm='#M1206 Slit# Obj# ID x(mm) y(mm) x(pix) y(pix) RA DEC z qflag'

for i=0,k do begin

    str=mrdfits(ff(i),nt(i),hh)

    ;help,str,/stru
    ;forprint,str.slit,str.obj_no,str.obj_x,str.obj_y
    slit=str.slit
    numb=str.obj_no
    xmm=str.obj_x
    ymm=str.obj_y

oobb=make_array(n_elements(xmm),/STRING,value=OBs[i]+'_'+qq[i]) 
   
xcol,summf[i],'3,10,12',id,z,fl,form='(a,d,a)'
spawn, 'grep -v ''#'' '+summf[i]+' | cut -c100-180',comm

mm2xyvimos,xmm,ymm,xv,yv,seq=preimg[i]

forprint,xv(0:15),yv(0:15)

xmm0=where(xmm eq 0,n0)
if n0 gt 0 then  forprint,text=7,/nocom,$
 oobb(xmm0),slit(xmm0),numb(xmm0),xmm(xmm0),ymm(xmm0),xv(xmm0),yv(xmm0),str.obj_ra(xmm0),str.obj_dec(xmm0),z(xmm0),fl(xmm0),$
 form='(a25,2x,2i6,2x,4f12.3,2x,2f13.6,2x,f10.4,2x,i3)'

if mm0_only eq 1 then goto,out

;spawn, '~/setse' ;setup sextractor
spawn, '/utils/sextractor-2.8.6-64bit/bin/sex -CATALOG_NAME tmp_xy.cat -DETECT_THRESH 5 '+preimg[i] 

;Read SEX x,y
readcol, 'tmp_xy.cat',xs,ys,f='f,f'
forprint,xs(0:15),ys(0:15)

xcats_xy,xv,yv,xs,ys,iv,is,dxmed,dymed,dist=10
;Finds outliers outside 20 pixels after registering the offsets..
xcats_xy,xv,yv,xs+dxmed,ys+dymed,dist=20,imiss=imis
;pause,pippo
if ans ne 'a' then pause,ans
if ans eq 'q' then begin
 print,'skipping: '+OBs[i]+'_'+qq[i] 
 goto, out
endif
forprint, xv[imis],yv[imis],id[imis],slit[imis],numb[imis],form='(2f10.2,2x,i7,i5,i5)',$
    text=OBs[i]+'_'+qq[i]+'_wrong.cat',comm='#Possibly wrong coords: x(pix) y(pix) id Slit# Obj#'

offx(i)=dxmed
offy(i)=dymed

forprint,TEXTOUT =OBs[i]+'_'+qq[i]+'_VIMOSxy.cat',comm='# Slit# Obj# ID x(pix) y(pix) z qflag Comments '+OBs[i]+'_'+qq[i]+': VIMOS COORDINATES AND REDSHIFTS',$
         slit,numb,id,xv,yv,z,fl,comm,form='(i3,1x,i1,2x,a9,2x,f9.3,2x,f9.3,2x,f6.4,1x,a3,2x,a-)'

forprint,TEXTOUT =OBs[i]+'_'+qq[i]+'_xyOK.cat',comm='# Slit# Obj# ID x(pix) y(pix) z qflag Comments '+OBs[i]+'_'+qq[i]+': VIMOS COORDINATES AND REDSHIFTS',$
         slit,numb,id,xv-offx(i),yv-offy(i),z,fl,comm,form='(i3,1x,i1,2x,a9,2x,f9.3,2x,f9.3,2x,f6.4,1x,a3,2x,a-)'

out:
endfor

spawn,'grep M1206 forprint.prt >xy2chk.dat'

if mm0_only eq 0 then forprint,TEXTOUT ='offset.tab',OBs,qq,offx,offy,form='(a,2x,a,2x,f9.3,2x,f9.3)',/nocomment

end
