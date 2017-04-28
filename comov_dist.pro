FUNCTION comov_dist,z, H0=h, Omega_m=Om_m, Lambda0=Om_l
;+
;Compute the comoving distance of redshift z in a FRW cosmology in units of Mpc
; H0=h	 	Hubble constant in km/s/Mpc
; OM_m =	Omega_M
; Om_l = 	Omega_lambda
; z=z		redshift	
;-

 if N_params() LT 1 then begin 
      print,'Sytnax - ' + $
 'angdist = comov_dist( z, [H0 =, Omega_m =, Lambda0 = ])'
      return,-1
 endif
  
   DH=299792.458/h   ;c/H0 [Mpc]
   dzz=.0005d0
   tt=findgen(n_elements(z))
   
for i=0,n_elements(z)-1 do begin
   zz=makex(0,z[i],dzz)
   tt[i]=int_tabulated( zz,(1d0/(sqrt((1+Om_m*zz)*(1+zz)^2-zz*(2+zz)*Om_l))) )
endfor 

return, double(tt*DH) 

end
