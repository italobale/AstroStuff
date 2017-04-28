pro mm2xyvimos,xmm,ymm,ccd_x,ccd_y,seqfile=inpfile
;
; Convert x,y in mm on VIMOS focal plane (taken from the x_obj, y_obj columns of the seq. file) 
; to CCD pixels x,y (on the preimaging)
; We use the transformation matrix MASK to CCD taken from the header of the corresponding preimaging
;

spawn,"/home/bal/dfits "+inpfile+" | /home/bal/fitsort PRO.MASK.CCD.X0|tail -1 |awk '{print $2}'",a & x0=float(a[0])
spawn,"/home/bal/dfits "+inpfile+" | /home/bal/fitsort PRO.MASK.CCD.XX|tail -1 |awk '{print $2}'",a & xx=float(a[0])
spawn,"/home/bal/dfits "+inpfile+" | /home/bal/fitsort PRO.MASK.CCD.XY|tail -1 |awk '{print $2}'",a & xy=float(a[0])
spawn,"/home/bal/dfits "+inpfile+" | /home/bal/fitsort PRO.MASK.CCD.Y0|tail -1 |awk '{print $2}'",a & y0=float(a[0])
spawn,"/home/bal/dfits "+inpfile+" | /home/bal/fitsort PRO.MASK.CCD.YY|tail -1 |awk '{print $2}'",a & yy=float(a[0])
spawn,"/home/bal/dfits "+inpfile+" | /home/bal/fitsort PRO.MASK.CCD.YX|tail -1 |awk '{print $2}'",a & yx=float(a[0])

spawn,"/home/bal/dfits "+inpfile+" | /home/bal/fitsort PRO.MASK.CCD.X_0_0|tail -1 |awk '{print $2}'",a & x_0_0=float(a[0])
spawn,"/home/bal/dfits "+inpfile+" | /home/bal/fitsort PRO.MASK.CCD.X_0_1|tail -1 |awk '{print $2}'",a & x_0_1=float(a[0])
spawn,"/home/bal/dfits "+inpfile+" | /home/bal/fitsort PRO.MASK.CCD.X_0_2|tail -1 |awk '{print $2}'",a & x_0_2=float(a[0])
spawn,"/home/bal/dfits "+inpfile+" | /home/bal/fitsort PRO.MASK.CCD.X_0_3|tail -1 |awk '{print $2}'",a & x_0_3=float(a[0])
spawn,"/home/bal/dfits "+inpfile+" | /home/bal/fitsort PRO.MASK.CCD.X_1_0|tail -1 |awk '{print $2}'",a & x_1_0=float(a[0])
spawn,"/home/bal/dfits "+inpfile+" | /home/bal/fitsort PRO.MASK.CCD.X_1_1|tail -1 |awk '{print $2}'",a & x_1_1=float(a[0])
spawn,"/home/bal/dfits "+inpfile+" | /home/bal/fitsort PRO.MASK.CCD.X_1_2|tail -1 |awk '{print $2}'",a & x_1_2=float(a[0])
spawn,"/home/bal/dfits "+inpfile+" | /home/bal/fitsort PRO.MASK.CCD.X_1_3|tail -1 |awk '{print $2}'",a & x_1_3=float(a[0])
spawn,"/home/bal/dfits "+inpfile+" | /home/bal/fitsort PRO.MASK.CCD.X_2_0|tail -1 |awk '{print $2}'",a & x_2_0=float(a[0])
spawn,"/home/bal/dfits "+inpfile+" | /home/bal/fitsort PRO.MASK.CCD.X_2_1|tail -1 |awk '{print $2}'",a & x_2_1=float(a[0])
spawn,"/home/bal/dfits "+inpfile+" | /home/bal/fitsort PRO.MASK.CCD.X_2_2|tail -1 |awk '{print $2}'",a & x_2_2=float(a[0])
spawn,"/home/bal/dfits "+inpfile+" | /home/bal/fitsort PRO.MASK.CCD.X_2_3|tail -1 |awk '{print $2}'",a & x_2_3=float(a[0])
spawn,"/home/bal/dfits "+inpfile+" | /home/bal/fitsort PRO.MASK.CCD.X_3_0|tail -1 |awk '{print $2}'",a & x_3_0=float(a[0])
spawn,"/home/bal/dfits "+inpfile+" | /home/bal/fitsort PRO.MASK.CCD.X_3_1|tail -1 |awk '{print $2}'",a & x_3_1=float(a[0])
spawn,"/home/bal/dfits "+inpfile+" | /home/bal/fitsort PRO.MASK.CCD.X_3_2|tail -1 |awk '{print $2}'",a & x_3_2=float(a[0])
spawn,"/home/bal/dfits "+inpfile+" | /home/bal/fitsort PRO.MASK.CCD.X_3_3|tail -1 |awk '{print $2}'",a & x_3_3=float(a[0])

spawn,"/home/bal/dfits "+inpfile+" | /home/bal/fitsort PRO.MASK.CCD.Y_0_0|tail -1 |awk '{print $2}'",a & y_0_0=float(a[0])
spawn,"/home/bal/dfits "+inpfile+" | /home/bal/fitsort PRO.MASK.CCD.Y_0_1|tail -1 |awk '{print $2}'",a & y_0_1=float(a[0])
spawn,"/home/bal/dfits "+inpfile+" | /home/bal/fitsort PRO.MASK.CCD.Y_0_2|tail -1 |awk '{print $2}'",a & y_0_2=float(a[0])
spawn,"/home/bal/dfits "+inpfile+" | /home/bal/fitsort PRO.MASK.CCD.Y_0_3|tail -1 |awk '{print $2}'",a & y_0_3=float(a[0])
spawn,"/home/bal/dfits "+inpfile+" | /home/bal/fitsort PRO.MASK.CCD.Y_1_0|tail -1 |awk '{print $2}'",a & y_1_0=float(a[0])
spawn,"/home/bal/dfits "+inpfile+" | /home/bal/fitsort PRO.MASK.CCD.Y_1_1|tail -1 |awk '{print $2}'",a & y_1_1=float(a[0])
spawn,"/home/bal/dfits "+inpfile+" | /home/bal/fitsort PRO.MASK.CCD.Y_1_2|tail -1 |awk '{print $2}'",a & y_1_2=float(a[0])
spawn,"/home/bal/dfits "+inpfile+" | /home/bal/fitsort PRO.MASK.CCD.Y_1_3|tail -1 |awk '{print $2}'",a & y_1_3=float(a[0])
spawn,"/home/bal/dfits "+inpfile+" | /home/bal/fitsort PRO.MASK.CCD.Y_2_0|tail -1 |awk '{print $2}'",a & y_2_0=float(a[0])
spawn,"/home/bal/dfits "+inpfile+" | /home/bal/fitsort PRO.MASK.CCD.Y_2_1|tail -1 |awk '{print $2}'",a & y_2_1=float(a[0])
spawn,"/home/bal/dfits "+inpfile+" | /home/bal/fitsort PRO.MASK.CCD.Y_2_2|tail -1 |awk '{print $2}'",a & y_2_2=float(a[0])
spawn,"/home/bal/dfits "+inpfile+" | /home/bal/fitsort PRO.MASK.CCD.Y_2_3|tail -1 |awk '{print $2}'",a & y_2_3=float(a[0])
spawn,"/home/bal/dfits "+inpfile+" | /home/bal/fitsort PRO.MASK.CCD.Y_3_0|tail -1 |awk '{print $2}'",a & y_3_0=float(a[0])
spawn,"/home/bal/dfits "+inpfile+" | /home/bal/fitsort PRO.MASK.CCD.Y_3_1|tail -1 |awk '{print $2}'",a & y_3_1=float(a[0])
spawn,"/home/bal/dfits "+inpfile+" | /home/bal/fitsort PRO.MASK.CCD.Y_3_2|tail -1 |awk '{print $2}'",a & y_3_2=float(a[0])
spawn,"/home/bal/dfits "+inpfile+" | /home/bal/fitsort PRO.MASK.CCD.Y_3_3|tail -1 |awk '{print $2}'",a & y_3_3=float(a[0])

 xxx=xx*xmm+xy*ymm+x0
 yyy=yx*xmm+yy*ymm+y0

; Correction for Optical Distortions
      dx=x_0_0+x_0_1*ymm+x_0_2*ymm*ymm+x_0_3*ymm*ymm*ymm+$
         x_1_0*xmm+x_1_1*xmm*ymm+x_1_2*xmm*ymm*ymm+x_1_3*xmm*ymm*ymm*ymm+$
         x_2_0*xmm*xmm+x_2_1*xmm*xmm*ymm+x_2_2*xmm*xmm*ymm*ymm+x_2_3*xmm*xmm*ymm*ymm*ymm+$
         x_3_0*xmm*xmm*xmm+x_3_1*xmm*xmm*xmm*ymm+x_3_2*xmm*xmm*xmm*ymm*ymm+x_3_3*xmm*xmm*xmm*ymm*ymm*ymm
         
      dy=y_0_0+y_0_1*ymm+y_0_2*ymm*ymm+y_0_3*ymm*ymm*ymm+$
         y_1_0*xmm+y_1_1*xmm*ymm+y_1_2*xmm*ymm*ymm+y_1_3*xmm*ymm*ymm*ymm+$
         y_2_0*xmm*xmm+y_2_1*xmm*xmm*ymm+y_2_2*xmm*xmm*ymm*ymm+y_2_3*xmm*xmm*ymm*ymm*ymm+$
         y_3_0*xmm*xmm*xmm+y_3_1*xmm*xmm*xmm*ymm+y_3_2*xmm*xmm*xmm*ymm*ymm+y_3_3*xmm*xmm*xmm*ymm*ymm*ymm

ccd_x=xxx+dx
ccd_y=yyy+dy

return
end
