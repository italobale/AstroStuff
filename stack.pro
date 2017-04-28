; SCRIPT FOR THE STACKING OF SPECTRA. 
; ORIGNAL VERSION BY RAPHAEL GOBAT.
; EDITS AND COMMENTS BY ITALO BALESTRA 13/03/2013 

; USAGE:
; CREATE AN INPUT FILE WITH TWO COLUMNS:
; (1) redshift (2) filename of spectrum
; 
; stack, srej, z0, DIR = dir, HELP = help
; 
; srej = number of sigma used for data rejection
; z0 = redshift used for the stacked spectrum
; dir = path to the directory containing the spectra to be stacked
; 
; example: 
; stack, 3, 0 

;##############################################################################

pro readspec_fits, filename, xflux, flux, zz, res, expt

if n_params() lt 3 then stop, 'readspec_fits : n_params < 3'

ap = 1
bnd = 1
zz = -1
spec = readfits(filename,head,/silent)
flux = double(spec[*,ap-1,bnd-1])
sap = strtrim(string(ap,format='(i0)'),2)

headsize = size(head,/n_elements)
crval1 = 1.0
crpix1 = 1.0
cdelt1 = 1.0

for i = 0, headsize-1 do begin
    strnm = strtrim(strsplit((strsplit(head[i],'/',/extract))[0], $
    	'=',/extract),2)
    case strnm[0] of 
    	'CRVAL1' : crval1 = float(strnm[1])
    	'CRPIX1' : crpix1 = float(strnm[1])
	'CD1_1'  : cdelt1 = float(strnm[1])
    	'CDELT1' : cdelt1 = float(strnm[1])
	'CTYPE1' : ctype1 = strtrim(strmid(strnm[1],1,strlen(strnm[1])-2),2)	
	'APVEL1' : zz = float((strsplit(strmid(strnm[1],1, $
	    strlen(strnm[1])-2),' ',/extract))[0])/299792.458	    
	'SPEC_RES' : res = float(strnm[1])
	'EXPTIME' : expt = float(strnm[1])
	else :
    endcase
endfor

crval1 = double(crval1)
crpix1 = double(crpix1)
cdelt1 = double(cdelt1)

xflux = dindgen(n_elements(flux))
for i = 1L, long(n_elements(flux)) do xflux[i-1] = crval1 + (i - crpix1)*cdelt1
if (strmatch(ctype1,'*LOG*',/fold_case) eq 1) then xflux = 1d1^xflux

end


;##############################################################################

function stackspec, xs, fs, zs, wg, srej, z0

; INPUT : xs = structure containing the wavelength grid of each spectrum
;         fs = structure containing the fluxes
;         zs = array of redshifts
; OPTIONAL : wg = array of weights; by default, every spectrum is given the 
;                 same weight
;          srej = coefficient of the sigma clipping
;            z0 = redshift of the stack; if not specified, z0 = <zs>
; OUTPUT : structure containing the wavelength grid of the stack, the average 
;          flux and the redshift of the stack

ns = n_tags(xs)    ; NUMBER OF SPECTRA

if (n_elements(z0) eq 0 || z0 lt 0) then z0 = mean(zs)    
if (ns eq 1) then return, {x : xs.(0), y : fs.(0), z : z0}
if (n_elements(wg) lt ns) then wg = replicate(1.,ns)

xmn = min(xs.(0))*(1.+z0)/(1.+zs[0])   ; SET x LOWER BOUND AFTER SHIFTING TO z STACK 
xmx = max(xs.(0))*(1.+z0)/(1.+zs[0])   ; SET x UPPER BOUND AFTER SHIFTING TO z STACK
xmn2 = xmn & xmx2 = xmx
xf0 = xs.(0)*(1.+z0)/(1.+zs[0])   ; TAKE 1st SPECTRUM AS REFERENCE x ARRAY

; RESET BOUNDS OF x OF EACH SPECTRUM TO MATCH THAT OF STACKED SPECTRUM  
for i = 1, ns-1 do  begin
    xi = xs.(i)*(1.+z0)/(1.+zs[i])    
    if (min(xi) lt xmn) then xf0 = [xi[where(xi lt xmn)],xf0]
    if (max(xi) gt xmx) then xf0 = [xf0,xi[where(xi gt xmx)]]
    xmn = min(xi) < xmn & xmx = max(xi) > xmx
    xmn2 = min(xi) > xmn2 & xmx2 = max(xi) < xmx2
endfor

; INITIALIZE ARRAY OF STACKED FLUX
n0 = n_elements(xf0)   ; N.ELEMENTS OF x OF STACK
nn = fltarr(n0)        ; EMPTY ARRAY WITH LENGTH OF x OF 1st SPECTRUM  
ys = replicate(!values.f_nan,ns,n0)   ; EMPTY MATRIX WITH LENGTH OF x TIMES NUM.OF SPECTRA

; FILL UP THE MATRIX WITH FLUXES
for i = 0, ns-1 do begin
    xi = xs.(i)*(1.+z0)/(1.+zs[i])
    m = where(xf0 ge min(xi) and xf0 le max(xi))
    n = where(xi ge xmn2 and xi le xmx2)
; IF FLUXES NEED TO BE CONVERTED FROM lambda*F_lambda TO F_lambda    
;    ys[i,m] = interpol(fs.(i)/int_tabulated(xi[n],(fs.(i))[n]),xi,xf0[m])
; IF FLUXES ARE ALREADY IN F_lambda
    ys[i,m] = interpol(fs.(i),xi,xf0[m])     
    nn[m] = nn[m] + wg[i]
endfor

; APPLY SIGMA-CLIPPING
if (n_elements(srej) gt 0 && srej gt 0) then begin 
    for i = 0, n0-1 do begin
    	if (nn[i] ge 2) then begin
    	    u = where(finite(ys[*,i]))
	    v = where(abs(ys[u,i] - mean(ys[u,i])) gt srej*stddev(ys[u,i]),ni)
    	    if (ni gt 0) then begin
    	    	ys[u[v],i] = 0.
		nn[i] = nn[i] - total(wg[u[v]])
    	    endif
	endif
    endfor
endif

; COMPUTE THE MEAN
return, {x : xf0, y : total(ys*(wg # replicate(1.,n0)),1,/nan)/nn, z : z0}

end

;##############################################################################

pro stack, srej, z0, DIR = dir, HELP = help


if keyword_set(HELP) then begin
    print, '  stack [, rejection coeff. (default = 1), z stack, ' + $
    	'DIR = fits directory]'
    return
endif

erase 
;loadct, 39, /silent & !p.background = 255 & !p.color = 0
window,0,xsize=800,ysize=400, retain=2

if (n_elements(srej) eq 0) then srej = 1
if (n_elements(z0) eq 0) then z0 = -1
if keyword_set(DIR) then cdir = dir else cdir = '.'
!x.range = 0 & !y.range = 0 & count = 0


;while (1) do begin

;file1 = '' & read, ["  FITS file(s) ('q' to quit) : "], file1
;if (file1 eq 'q' || file1 eq 'quit') then break
;if (file1 eq 'e' || file1 eq 'exit') then return
;file1 = cdir + '/' + strsplit(file1,',',/extract)

infile = '' & read, [" Select input file ('q' to quit) : "], infile
readcol,infile,zz,file1,f='d,a'

if (min(strlen(file_search(file1))) gt 0) then begin
    n1 = n_elements(file1)
    for i = 0, n1-1 do begin
    	readspec_fits, file1[i], xi, fi, zi	
	b = where(fi ne 0.,nb)
	xi = xi[b[0]:b[nb-1]] & fi = fi[b[0]:b[nb-1]]		
    	if (zi lt 0) then zi = zz                   ;read, ['  Redshift of '+file1[i]+' : '], zi
    	tag = 'sp' + strtrim(string(count),2) & count++
    	if (n_elements(xs) eq 0) then begin
    	    xs = create_struct([tag],xi)
    	    fs = create_struct([tag],fi)	    
    	    zs = zi
	    xmn = min(xi*(1.+z0)/(1.+zi))
	    xmx = max(xi*(1.+z0)/(1.+zi))
    	endif else begin
    	    xs = create_struct(xs,[tag],xi)
    	    fs = create_struct(fs,[tag],fi)
    	    zs = [zs,zi]
    	    xmn = min(xi*(1.+z0)/(1.+zi)) > xmn
	    xmx = max(xi*(1.+z0)/(1.+zi)) < xmx
    	endelse
    endfor    
    stck = stackspec(xs, fs, zs, srej, z0)
    print, '  Redshift : ', stck.z    
    plot, stck.x, stck.y, xstyle = 1
        
;    clrs = 50.+200.*findgen(n1)/(n1-1)
;    b = where(stck.x ge xmn and stck.x le xmx)
;    nrm = int_tabulated((stck.x)[b],(stck.y)[b])
;    for i = 0, n1-1 do begin
;    	xi = xs.(i)*(1.+z0)/(1.+zs[i])
;	b = where(xi ge xmn and xi le xmx)
;	fi = fs.(i)*nrm/int_tabulated(xi[b],(fs.(i))[b])
;    	oplot, xi, fi, col = clrs[i]
;    endfor   
endif

;endwhile


fileo = ''
read, ["  Filename/quit : "], fileo
if (fileo ne 'q' && fileo ne 'quit' && fileo ne 'n') then begin
    close, 1 & openw, 1, fileo
    for i = 0, n_elements(stck.x)-1 do printf, 1, (stck.x)[i], (stck.y)[i]
    close, 1
endif


end
