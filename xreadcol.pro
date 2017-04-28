function xreadcol_readline, unit, separator=separator, comments=comments, $
                            callback=callback, escape=escape, nulls=nulls, $
                            missing=missing, preserve_null=preserve_null, $
                            regex=regex, cols=cols, curline=curline, $
                            nlines=nlines, line=oline, skip=skip, $
                            ignore=ignore, left=left, right=right
;+
; NAME:
;   XREADCOL_READLINE
;
; PURPOSE:
;   Service procedure of XREADCOL that reads a single (valid) line from a
;   file.
;
; CATEGORY:
;   Catalogs
;
; CALLING SEQUENCE:
;   fields = xreadcol_readline(unit, [options])
;
; INPUTS:
;   unit:  A valid unit file open for reading
;
; KEYWORD PARAMETERS:
;   separator:  Either a string or regular expression indicating the
;               separators to use.  It is passed directly to strsplit
;   comments:   Either an array of strings or regular expressions used to
;               identify comments.  If /regex is not specified, then a comment
;               line must begin with one of the character sequences specified
;               by comments; otherwise, each element of comments must match a
;               comment in the line.
;   callback:   A string indicating a procedure that will receive the comments
;               for further processing.  The procedure will get a single
;               parameter with the comment, and the keywords line= (containing
;               the line number) and /comment.  Note that if the /skip flag is
;               provided, the callback procedure will also be called with the
;               skip=2 flag.
;   escape:     A character used to escape separators (passed directly to
;               strsplit).
;   nulls:      A list of strings (or regular expressions) that will be
;               interpreted as null entries, i.e. replaced with empty
;               strings.
;   ignore:     A list of strings that will be ignored (i.e. removed) from the
;               input.
;   missing:    If specified, indicates the value to assign to missing
;               columns, i.e. to columns that do not have any non-space
;               character; if not specified, assume the empty string
;   /regex:     If specified, separator and comments must be regular
;               expressions.
;   cols:       If provided, the line is splitted according to the requested
;               columns instead of using the separator; in this case,
;               separator, comments, and escape are all ignored.
;   curline:    An input/output variable used to count the current line in 
;               the file.
;   line:       An output variable used to obtain the true, original line 
;               read from the file.
;   nlines:     The maximum number of lines to read: when curline = nlines no
;               further lines will be read.  You can use nlines=-1 to continue
;               reading indefinitly.
;   /skip:      Indicates that the line will be skipped, and this will trigger
;               a call to callback (if defined) with the skip=2 flag.
;
; MODIFICATION HISTORY:
;       Mon Nov 21 18:24:19 2005, Marco Lombardi <mlombard@eso.org>
;		Created.
;-

  if n_elements(missing) eq 1 then mis = missing $
  else mis = ''
  if keyword_set(regex) then begin
    while not eof(unit) do begin
      if curline eq nlines then return, -1
      line = ' '
      readf, unit, line
      oline = line
      curline = curline + 1
      for c=0, n_elements(comments)-1 do begin 
        p = stregex(line, comments[c], length=l)
        if p ge 0 then begin
          if n_elements(callback) eq 1 then $
            call_procedure, callback, strmid(line, p, l), line=curline, $
                            /comment, level=-2
          line = strmid(line, 0, p) + strmid(line, p + l)
        endif
      endfor
      if n_elements(cols) gt 0 then begin
        line = strmid(line, cols[*, 0], cols[*, 1] - cols[*, 0] + 1)
        break
      endif
      ; @@@ line = strtrim(line, 2)
      if strlen(line) gt 0 then begin
        if keyword_set(skip) and n_elements(callback) eq 1 then $
          call_procedure, callback, line, line=curline, skip=2, level=-2
        line = strsplit(line, separator, /regex, /extract, /preserve_null)
        break
      endif
    endwhile
    k = indgen(n_elements(line)) 
    w = -1
    for i=0, n_elements(nulls)-1 do begin
      if i eq 0 then w = where(stregex(line, nulls[i], /boolean)) $
      else w = where(w eq k or stregex(line, nulls[i], /boolean))
    endfor
    if w[0] ge 0 then line[w] = mis
  endif else begin                                     ; not regexp
    while not eof(unit) do begin
      if curline eq nlines then return, -1
      line = ' '
      readf, unit, line
      oline = line
      curline = curline + 1
      if n_elements(cols) gt 0 then begin
        line = strmid(line, cols[*, 0], cols[*, 1] - cols[*, 0] + 1)
        break
      endif
      ; @@@ line = strtrim(line, 2)
      for c=0, n_elements(comments)-1 do begin 
        if strmid(line, 0, strlen(comments[c])) eq comments[c] then begin
          if n_elements(callback) eq 1 then $
            call_procedure, callback, line, line=curline, /comment, level=-2
          line = ''
        endif
      endfor
      
      if size(left, /type) eq 7 then begin
        nleft = strlen(left)
        if strmid(line, 0, nleft) eq left then $
           line = strmid(line, nleft)
      endif else if n_elements(left) eq 1 then line = strmid(line, left)
      if size(right, /type) eq 7 then begin
        nright = strlen(right)
        nline = strlen(line)
        if strmid(line, nline-nright) eq right then $
           line = strmid(line, 0, nline-nright)
      endif
      if strlen(line) gt 0 then begin
        if keyword_set(skip) and n_elements(callback) eq 1 then $
           call_procedure, callback, line, line=curline, skip=2, level=-2
        line = strsplit(line, separator, escape=escape, /extract, $
                        preserve_null=preserve_null)
        break
      endif
    endwhile
    if n_elements(line) eq 0 then $
       if eof(unit) then return, -4 $
       else return, -2
    if n_elements(line) eq 1 and line[0] eq '' then return, -3
    k = indgen(n_elements(line)) 
    w = -1
    for i=0, n_elements(nulls)-1 do begin
      if i eq 0 then w = where(strtrim(line, 2) eq nulls[i]) $
      else w = where(w eq k or strtrim(line, 2) eq nulls[i])
    endfor
    if w[0] ge 0 then line[w] = mis
  endelse
  
  for n=0, n_elements(ignore)-1 do begin
    l = strlen(ignore[n])
    repeat begin
      p = strpos(line, ignore[n])
      w = where(p ge 0, c)
      for i=0, c-1 do $
         line[w[i]] = strmid(line[w[i]], 0, p[w[i]]) + $
                      strmid(line[w[i]], p[w[i]] + l)
    endrep until c eq 0
  endfor    

  return, line
end


pro xreadcol_sex_callback, buffer, line=line, comment=comment, skip=skip, $
                           level=level
  common xreadcol_sex_cb, col, name
  
 if n_elements(col) eq 0 then begin
    col = 0
    name = 'ANONYMOUS'
  endif
  tab = string(9B)
  space = '[ ' + tab + ']'
  fields = stregex(buffer, '\#' + space + '*([0-9]+)' + space + '+([A-Za-z0-9_]+)' + space + '*([^[]*)(\[[^]]*\])?', /subexpr, /extract)
  if strlen(fields[0]) gt 0 then begin
    n = fix(fields[1])
    if n gt (col+1) then begin
      if n_elements(scope_varfetch("names", level=level)) eq 0 then begin
        (scope_varfetch("names", level=level)) = $
           name + strtrim(indgen(n - col - 1) + 1, 2)
      endif else begin
        (scope_varfetch("names", level=level)) = $
           [scope_varfetch("names", level=level), $
            name + strtrim(indgen(n - col - 1) + 1, 2)]
      endelse
    endif
    col = n
    name = strtrim(fields[2], 2)
    if n_elements(scope_varfetch("names", level=level)) eq 0 then begin
      (scope_varfetch("names", level=level)) = name
    endif else begin
      (scope_varfetch("names", level=level)) = $
         [scope_varfetch("names", level=level), name]
    endelse
  endif
  return
end


pro xreadcol_skycat_callback, buffer, line=line, comment=comment, skip=skip, $
                              level=level
  if keyword_set(skip) then begin
    tab = string(9B)
    if stregex(buffer, '^[- ' + string(9B) + ']+$', /boolean) then $
       (scope_varfetch('skiptlines', level=level)) = 0 $
    else (scope_varfetch('skiptlines', level=level))++
  endif
  return
end


pro xreadcol_vizier_callback, buffer, line=line, comment=comment, skip=skip, $
                              level=level, precall=precall
  if keyword_set(precall) then begin
    file = file_basename(scope_varfetch('file', level=level))
    vizier = scope_varfetch('vizier', level=level)
    if vizier eq 1 then $
       vizier = file_dirname(scope_varfetch('file', level=level)) + $
                '/ReadMe.txt'
    openr, u, vizier, /get_lun
    line = ''
    ;; Find the table with the data description for the correct file
    while not eof(u) do begin
      readf, format='(A)', u, line
      if strmid(line, 0, 33) eq "Byte-by-byte Description of file:" then begin
        files = strsplit(strmid(line, 33), /extract)
        w = where(files eq file)
        if w[0] ge 0 then break
      endif
    endwhile
    if eof(u) then message, "Byte-by-byte description not foind"
    ;; Skip the table header
    readf, format='(A)', u, line
    readf, format='(A)', u, line
    readf, format='(A)', u, line
    ;; Read the table
    mins = [1]
    maxs = [1]
    formats = ['']
    units = ['']
    labels = ['']
    while not eof(u) do begin
      readf, format='(A)', u, line
      if strmid(line, 0, 10) eq '          ' then continue
      if strmid(line, 0, 10) eq '----------' then break
      s = strsplit(line, /extract)
      if strmid(line, 0, 5) eq '     ' then s = [s[0], s]
      if strpos(s[0], '-') ge 1 then $
         s = [strsplit(s[0], '-', /extract), s[1:*]]
      mins = [mins, fix(s[0])]
      maxs = [maxs, fix(s[1])]
      formats = [formats, s[2]]
      units = [units, s[3]]
      labels = [labels, s[4]]
      if strmid(line, 0, 33) eq "Byte-by-byte Description of file:" then begin
        files = strsplit(strmid(line, 33), /extract)
        w = where(files eq file)
        if w[0] ge 0 then break
      endif
    endwhile
    if eof(u) then message, "Error parsin byte-by-byte description table"
    close, u
    free_lun, u

    ;; Fix RA & Dec sessagesimal notation
    mins = [mins, 1]
    maxs = [maxs, 1]
    labels = [labels, '']
    w = where(labels eq 'RAh')
    if w[0] ge 0 then begin
      w = w[0]
      if labels[w+1] eq 'RAm' then begin
        labels = [labels[0:w], labels[w+2:*]]
        mins = [mins[0:w], mins[w+2:*]]
        maxs = [maxs[0:w-1], maxs[w+1:*]]
        if labels[w+1] eq 'RAs' then begin
          labels = [labels[0:w], labels[w+2:*]]
          mins = [mins[0:w], mins[w+2:*]]
          maxs = [maxs[0:w-1], maxs[w+1:*]]
        endif
      endif
    endif
    w = where(labels eq 'DE-')
    if w[0] ge 0 then begin
      w = w[0]
      if labels[w+1] eq 'DEd' then begin
        labels = [labels[0:w-1], labels[w+1:*]]
        mins = [mins[0:w], mins[w+2:*]]
        maxs = [maxs[0:w-1], maxs[w+1:*]]
        if labels[w+1] eq 'DEm' then begin
          labels = [labels[0:w], labels[w+2:*]]
          mins = [mins[0:w], mins[w+2:*]]
          maxs = [maxs[0:w-1], maxs[w+1:*]]
          if labels[w+1] eq 'DEs' then begin
            labels = [labels[0:w], labels[w+2:*]]
            mins = [mins[0:w], mins[w+2:*]]
            maxs = [maxs[0:w-1], maxs[w+1:*]]
          endif
        endif
      endif
    endif
    mins = mins[1:n_elements(mins)-2] - 1
    maxs = maxs[1:n_elements(maxs)-2] - 1
    labels = labels[1:n_elements(labels)-2] 

    (scope_varfetch('cols', level=level)) = [[mins], [maxs]]
    (scope_varfetch('names', level=level)) = labels
  endif
end


pro xreadcol_twomass_callback, buffer, line=line, comment=comment, skip=skip, $
                               level=level
  common xreadcol_sex_cb, col, name
  
  if keyword_set(skip) then begin
    tab = string(9B)
    if stregex(buffer, '^\', /boolean) then $
       (scope_varfetch('skiptlines', level=level)) = 0 $
    else (scope_varfetch('skiptlines', level=level))++
  endif
  return

 if n_elements(col) eq 0 then begin
    col = 0
    name = 'ANONYMOUS'
  endif
  tab = string(9B)
  space = '[ ' + tab + ']'
  fields = stregex(buffer, '\#' + space + '*([0-9]+)' + space + '+([A-Za-z0-9_]+)' + space + '*([^[]*)(\[[^]]*\])?', /subexpr, /extract)
  if strlen(fields[0]) gt 0 then begin
    n = fix(fields[1])
    if n gt (col+1) then begin
      if n_elements(scope_varfetch("names", level=level)) eq 0 then begin
        (scope_varfetch("names", level=level)) = $
           name + strtrim(indgen(n - col - 1) + 1, 2)
      endif else begin
        (scope_varfetch("names", level=level)) = $
           [scope_varfetch("names", level=level), $
            name + strtrim(indgen(n - col - 1) + 1, 2)]
      endelse
    endif
    col = n
    name = strtrim(fields[2], 2)
    if n_elements(scope_varfetch("names", level=level)) eq 0 then begin
      (scope_varfetch("names", level=level)) = name
    endif else begin
      (scope_varfetch("names", level=level)) = $
         [scope_varfetch("names", level=level), name]
    endelse
  endif
  return
end


pro xreadcol, file, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, $
              v14, v15, v16, v17, v18, v19, v20, v21, v22, v23, v24, v25, $
              separator=separator, tab=tab, space=space, comma=comma, $
              comments=comments, callback=callback, escape=esc, regex=regex, $
              ignore=ignore, nulls=nulls, missing=missing, format=format, $
              stopempty=stopempty, upgradeformat=upgradeformat, $
              names=names, linenames=linenames, tlinenames=tlinenames, $
              cols=cols, ncols=ncols, autocols=autocols, $
              nlines=nlines, ntlines=ntlines, $
              skiplines=skiplines, skiptlines=skiptlines, $
              skiprecs=skiprecs, nrecs=nrecs, append=append, $
              lineno=lineno, silent=silent, checklines=checklines, $
              sex=sex, skycat=skycat, gnuplot=gnuplot, twomass=twomass, $
              vizier=vizier, tex=tex, info=info, verbose=verbose
;+
; NAME:
;   XREADCOL
;
; PURPOSE:
;   To read almost any format of text table
;
; CATEGORY:
;   Catalogs
;
; CALLING SEQUENCE:
;   xreadcol, file, v1, [v2, ...], [options]
;
; INPUTS:
;   file:  A string, representing the path of a file to read, or an integer,
;          indicating the (already opened) unit to use; if a string ending
;          with .gz is used, the file is taken to be gzipped.
;   v1:    A named variable that will receive part or all of the read table.
;          If only v1 is used, then v1 will be an array of structures with all
;          data saved there in different tags (the tag names are 'v1',
;          'v2'... or as indicated by names).  If more variables are given,
;          then they will receive all requested columns in order.
;
; OPTIONAL INPUTS:
;   vn:    Named variables that will receive the i-th column.
;
; KEYWORD PARAMETERS:
;   separator:     A string representing the separator(s) to use.  If /regex
;                  is not specified, each character of separator is taken as a
;                  valid column delimiter; otherwise, separator is taken as a
;                  regular expression to be used to match column delimiters.
;                  separator can also be an integer array, in which case it is
;                  taken as the fixed column indexes that separates different
;                  fields (see cols).
;   /tab:          The TAB character is a valid separator.
;   /space:        The SPACE character is a valid separator.
;   /comma:        The comma is a valid separator.
;   comments:      An array of strings indicating how comments are specified.
;                  If /regex is not specified, then a comment must begin at
;                  the beginning of a line (spaces are ignored) and ends at
;                  the end of the line; otherwise, each string of comments is
;                  taken as a regular expression that matches the whole
;                  comment.
;   callback:      A string with the name of a procedure to call for each
;                  comment or line skipped.  The procedure will get as
;                  parameter the comment (including the comment marker), and
;                  as keywords the line number (line=), /comment (if the line
;                  is a comment), or /skip (if the line was skipped).  Note
;                  that callback can access and modify local XREADCOL
;                  variables using the SCOPE_VARFETCH function; this technique
;                  is useful, for example, to set XREADCOL variables as a
;                  consequence of header processing.  To this purpose, the
;                  callback function is called with the keyword level that can
;                  be used directly with SCOPE_VARFETCH to access variables in
;                  XREADCOL.
;   escape:        An escape sequence to be used to prevent a character to be
;                  taken as a separator; cannot be used together with /regex
;   /regex:        Indicates that both the separator and comments are regular
;                  expressions.
;   format:        The format of the table line.  Should be a comma-separated
;                  list of format specifiers taken from the table reported
;                  below (parentheses are ignored).  If unspecified, all
;                  columns are taken to be integers 'B', but /upgradeformat is
;                  assumed
;   /upgradeformat Makes all lines of the table succeed by upgrading the
;                  format as requested.  This is done by trying in sequence
;                  integers values, then reals, sessagesimal reals, and
;                  finally strings.  Checks are also performed on overflow and
;                  precision (for example, 65537 will force a long, and
;                  3.1415926535 will force a double because a float would not
;                  have enough precision for that number).
;   ignore:        A list of strings that have to be ignored (i.e., removed)
;                  from each field.  The field type identification is
;                  performed after these strings are removed.
;   nulls:         A list of strings (or regular expressions if /regex is used)
;                  that will interpreted as a null value (i.e., replaced with
;                  an empty string).  If the missing keyword is specified
;                  these strings will be then assigned the indicated value.
;   missing:       If specified, indicates the value to assign to missing
;                  columns, i.e. to columns that do not have any non-space
;                  character; if not specified, lines containing such columns
;                  are discarded.
;   names:         A list of tag names for the resulting structure array.
;   linenames:     The tag names of the structure array are taken from the
;                  specified line number; the same separator as the data is
;                  used
;   tlinenames:    The tag names of the structure array are taken from the
;                  specified _true_ line number (i.e., number of non-comment
;                  lines in the file); the same separator as the data is 
;                  used
;   cols:          If specified, must be an array in the format Int[n, 2].
;                  Each couple cols[n, *] is taken as the starting and ending
;                  column of a field in the table (columns start at 0).  If
;                  cols is used, then separator, comments, escape, and /regex
;                  are ignored.
;   /autocols      If set, the array cols is automatically calculated from
;                  the linenames or tlinenames line, using the specified
;                  separator as an indication of how to split the line there
;   ncols:         The number of columns to read.
;   skiplines:     The number of lines to skip at the beginning of the file
;                  [0] 
;   skiptlines:    The number of _true_ lines to skip at the beginning of the
;                  file (not counting comment lines) [0]
;   nlines:        The total number of lines to read (including the skipped 
;                  ones) [infinity].
;   ntlines:       The total number of true lines to read (not including the
;                  the skipped ones) [infinity].
;   checklines:    The maximum number of (true) lines to check for format
;                  purposes; following lines will be read but their format
;                  will not be checked [999]
;   skiprecs:      The number of records to skip at the beginning of the 
;                  file [0]
;   nrecs:         The total number of valid lines to read (i.e., the number
;                  of valid records to return) [infinity].
;   lineno:        A named variable that will return the line numbers of valid
;                  lines (i.e., lines that have been used for the returned
;                  records).
;   /silent:       Do not print any non-fatal message.
;
; OUTPUTS:
;   The output is stored in the vn variables.  If only v1 is used, then the
;   output will be an array of structures (unless the table has a single
;   column); otherwise, the output will be stored in the individual variables
;   as equally long arrays.
;
; FORMATS:
;   The following table summarizes the codes to used with the format keyword:
; 
;       Byte(1)  Int(2)  Long(3)  UInt(12)  ULong(13)  Long64(14)  ULong64(15)
; Dec.     B       I       L         U         V           W           E
; Bin.     C       .       .         J         K           .           N
; Oct.     .       .       .         O         P           .           Q
; Hex.     .       .       .         H         M           .           Z
;
;       Float(4)  Double(5)                 String         A
; Dec.     F         D                      Skip column    X
; Ses.     S         T                      Skip all       Y
;
; MODIFICATION HISTORY:
;       Sun Nov 20 20:08:37 2005, Marco Lombardi <mlombard@eso.org>
;		Created.
;-

  ;; on_error, 2                                          ; return to caller

  if n_params() lt 2 then begin
    print, 'xreadcol, file, v1, [v2...], [options]'
    print, ' '
    print, '      Byte(1)  Int(2)  Long(3)  UInt(12)  ULong(13)  Long64(14)  ULong64(15)'
    print, 'Dec.     B       I       L         U         V           W           E'
    print, 'Bin.     C       .       .         J         K           .           N'
    print, 'Oct.     .       .       .         O         P           .           Q'
    print, 'Hex.     .       .       .         H         M           .           Z'
    print, ' '
    print, '      Float(4)  Double(5)                 String         A'
    print, 'Dec.     F         D                      Skip column    X'
    print, 'Ses.     S         T                      Skip all       Y'
    return
  endif

  ;; Types, and other flags for each format letter
  ;;        A   B   C   D   E   F   G   H   I   J   K   L   M  
  ;;        N   O   P   Q   R   S   T   U   V   W   X   Y   Z
  types = [ 7,  1,  1,  5, 15,  4,  0, 12,  2, 12, 13,  3, 13, $
           15, 12, 13, 15,  0,  4,  5, 12, 13, 14, -1, -2, 15]
  bases = [10, 10,  2, 10, 10, 10, 10, 16, 10,  2,  2, 10, 16, $
            2,  8,  8,  8, 10, 10, 10, 10, 10, 10, 10, 10, 16]
  sess  = [ 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, $
            0,  0,  0,  0,  0,  1,  1,  0,  0,  0,  0,  0,  0]
  ;; Saves these tables for future use
  _types = types
  _bases = bases
  _sess = sess

  ;; Upgrades: global type or subtype
  ;;           0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15]
  upgrades1 = [0, 2, 4, 5, 7, 7, 0, 7, 0, 0, 0, 0, 2, 3, 5,14]
  upgrades2 = [0,12, 3,14, 5, 5, 0, 7, 0, 0, 0, 0,13,15,14,15]

  ;; Check complex parameters
  if keyword_set(sex) then begin
    if n_elements(separator) eq 0 then separator = ''
    if n_elements(comments) eq 0 then comments = ['#']
    if n_elements(callback) eq 0 then callback = 'xreadcol_sex_callback'
  endif
  if keyword_set(skycat) then begin
    if n_elements(separator) eq 0 then separator = string(9B)
    if n_elements(names) eq 0 then tlinenames = 1
    if n_elements(skiptlines) eq 0 then skiptlines = 2
    if n_elements(callback) eq 0 then callback = 'xreadcol_skycat_callback'
  endif
  if keyword_set(gnuplot) then begin
    if n_elements(separator) eq 0 then separator = ''
    if n_elements(comments) eq 0 then comments = ['#']
  endif
  if keyword_set(twomass) then begin
    if n_elements(left) eq 0 then left = '|'
    if n_elements(right) eq 0 then right = '|'
    if n_elements(separator) eq 0 then separator = '| '
    if n_elements(names) eq 0 then tlinenames = 1
    if n_elements(skiptlines) eq 0 then skiptlines = 4
    if n_elements(nulls) eq 0 then nulls = ['null']
    if n_elements(missing) eq 0 then missing = '0'
    if n_elements(comments) eq 0 then comments = ['\']
  endif
  if keyword_set(vizier) then begin
    if n_elements(callback) eq 0 then callback = 'xreadcol_vizier_callback'
    if n_elements(missing) eq 0 then missing = ''
    xreadcol_vizier_callback, "", level=-1, /precall
  endif
  if keyword_set(tex) then begin
    if n_elements(separator) eq 0 then separator = '&'
    if n_elements(ignore) eq 0 then ignore = ['$', '\\']
  endif
    
  ;; Check the parameters
  if size(file, /type) eq 7 then begin
    if strmid(file, 0, 1) eq '<' then begin
      spawn, strmid(file, 1), unit=unit
    endif else begin
      if strmid(file, strlen(file)-3) eq ".gz" then $
         openr, unit, file, /get_lun, /compress $
      else $
         openr, unit, file, /get_lun 
    endelse
  endif else unit = file
  if n_elements(separator) eq 0 then separator = ''
  if keyword_set(tab) then separator = separator + string(9B)
  if keyword_set(space) then separator = separator + ' '
  if keyword_set(comma) then separator = separator + ','
  if keyword_set(regex) then begin
    if n_elements(nulls) eq 0 then nulls = '^ *$' else nulls = ['^ *$', nulls]
  endif else begin
    if n_elements(nulls) eq 0 then nulls = '' else nulls = ['', nulls]
  endelse
  if size(cols, /n_dimensions) eq 1 then begin
    message, "COLS should be an array Int[n,2]; use SEPARATOR instead"
  endif

  if size(separator, /type) ne 7 then begin
    cols = intarr(n_elements(separator) + 1, 2)
    cols[0, 0] = 0
    curcol = 0
    for n=0, n_elements(separator)-1 do begin
      if cols[curcol, 0] le separator[n]-1 then begin
        cols[curcol, 1] = separator[n]-1
        curcol += 1
        cols[curcol, 0] = separator[n]+1
      endif
    endfor
    cols[curcol, 1] = 9999
  endif else begin
    if separator eq '' then separator = ' ,' + string(9B) ; default separator
    if strpos(separator, ' ') ge 0 then $              ; if space a separator
      preserve_null = 0 $                              ; then multiple spaces
    else preserve_null = 1                             ; count as one
  endelse
  if n_elements(comments) eq 0 then $                  ; default begin comment
    if keyword_set(regex) then comments = ['#.*$'] $
    else comments = ['#']
  if n_elements(skiplines) ne 1 then begin
     if n_elements(linenames) eq 1 then skiplines = linenames $
     else skiplines = 0L
  end                                                   ; default no skip
  if n_elements(skiptlines) ne 1 then begin
     if n_elements(tlinenames) eq 1 then skiptlines = tlinenames $
     else skiptlines = 0L                               ; default no skip
  end
  if n_elements(nlines) ne 1 then nlines = -1L          ; default infinity
  if n_elements(ntlines) ne 1 then ntlines = -1L        ; default infinity
  if n_elements(checklines) ne 1 then checklines = 999L ; default 1000 lines
  if n_elements(skiprecs) ne 1 then skiprecs = 0L       ; default no skip
  if n_elements(nrecs) ne 1 then nrecs = -1L            ; default infinity
  if n_elements(linenames) ne 1 then linenames = -1L    ; default no header
  if n_elements(tlinenames) ne 1 then tlinenames = -1L  ; default no header
  if n_elements(v1) eq 0 and keyword_set(append) then $ ; if no previous data
     append = 0                                         ; disable append

  ;; Skip the first lines
  temp = ' '
  curline = 0L
  curtline = 0L
  while (curline lt skiplines) or (curtline lt skiptlines) do begin
    if curline eq linenames-1 then begin
       line = xreadcol_readline(unit, separator=separator, $
                                escape=esc, nulls=nulls, missing=missing, $
                                regex=regex, preserve_null=preserve_null, $
                                callback=callback, cols=cols, curline=curline, $
                                nlines=curline+1, line=oline, ignore=ignore, $
                                left=left, right=right, /skip)
       for c=0, n_elements(comments)-1 do begin
          if line[0] eq comments[c] then begin
             line = line[1:*]
             break
          end else if strmid(line[0], 0, strlen(comments[c])) eq comments[c] then begin
             line[0] = strmid(line[0], strlen(comments[c]))
             break
          end
       end
    end else begin
       line = xreadcol_readline(unit, separator=separator, comments=comments, $
                                escape=esc, nulls=nulls, missing=missing, $
                                regex=regex, preserve_null=preserve_null, $
                                callback=callback, cols=cols, curline=curline, $
                                nlines=curline+1, line=oline, ignore=ignore, $
                                left=left, right=right, /skip)
    end
    if size(line, /type) eq 2 then begin
      if line eq -2 and keyword_set(stopempty) then break
      if line eq -4 then goto, stop
      continue
    endif
    curtline = curtline + 1
    if (curline eq linenames) or (curtline eq tlinenames) then begin
      names = strtrim(line, 2)
      if names[0] eq '' then names = names[1:*]
      if names[n_elements(names)-1] eq '' then $
         names = names[0:n_elements(names)-2] 
      for j=0, n_elements(names)-1 do begin
        names[j] = repchr(names[j], ' ', '_')
        names[j] = repchr(names[j], ':', '_')
        names[j] = repchr(names[j], '-', '_')
      endfor
      if keyword_set(autocols) then begin 
        pseparator = strsplit(oline, separator, length=length, escape=escape, regex=regexp)
        cols = intarr(n_elements(pseparator), 2)
        cols[*, 0] = pseparator
        cols[*, 1] = pseparator + length
      endif
    endif
  endwhile
  ;; Check if we encounter EOF
  if size(line, /type) eq 2 then begin
    if size(file, /type) eq 7 then begin
      close, unit
      free_lun, unit
    endif
    if line eq -2 then message, "File is empty"
  endif

  ;; Skip the first records 
  curline = long(skiplines)
  for i=0L, skiprecs do $
    line = xreadcol_readline(unit, separator=separator, comments=comments, $
                             escape=esc, nulls=nulls, missing=missing, $
                             regex=regex, preserve_null=preserve_null, $
                             callback=callback, cols=cols, curline=curline, $
                             nlines=nlines, skip=(i lt skiprecs), $
                             ignore=ignore, left=left, right=right)
  
  ;; Check the format
  if n_elements(format) eq 1 then begin
    fmt = strsplit(strupcase(format), ',() ', /extract)
    fmt = byte(fmt) - 65
  endif

  ;; Find out the number of columns, if not provided
  if n_elements(ncols) ne 1 then begin
    if keyword_set(sex) and n_elements(names) gt 0 then begin 
      nnames = n_elements(names)
      ncols = n_elements(line) 
      if ncols gt nnames then $
         names = [names, names[nnames-1] + $
                  strtrim(indgen(ncols - nnames) + 1, 2)]
    endif
    if n_elements(cols) gt 1 then ncols = n_elements(cols)/2 $
    else if n_elements(fmt) gt 0 then ncols = n_elements(fmt) $
    else if n_elements(names) gt 0 then ncols = n_elements(names) $ 
    else if n_params() gt 2 then ncols = n_params() - 1 $
    else ncols = n_elements(line) 
  endif

  ;; Set the types
  if n_elements(fmt) eq 0 then begin
    fmt = replicate(1, ncols)                          ; 'B': Byte
    upgradeformat = 1                                  ; no format specified
  endif
  if keyword_set(append) then begin
    types = [0]
    if n_params() eq 2 then begin
      if n_tags(v1) eq 0 then types = [types, size(v1, /type)] $
      else begin
        for j=0, n_tags(v1)-1 do $
           types = [types, size(v1.(j), /type)]
      endelse
    endif else begin
      for j=1, n_params()-1 do $
         res = execute('types = [types, size(v' + $
                       strtrim(j + 1, 2) + ', /type)]')
    endelse
    types = types[1:*]
  endif else types = types[fmt]
  bases = bases[fmt]
  sess = sess[fmt]

  ;; Check the real number of columns, i.e. the number of tags in the result
  wtcol = where(types gt 0, ntcols)
  if n_elements(names) ne ntcols then $
    names = 'v' + strtrim(indgen(ntcols) + 1, 2)
  
  ;; Creates the record format
  for col=0, ntcols-1 do begin
    pos = stregex(names[col], '[^_a-zA-Z0-9]+', length=len)
    while pos ge 0 do begin
      names[col] = strmid(names[col], 0, pos) + $
                   strjoin(replicate('_', len)) + $
                   strmid(names[col], pos + len)
      pos = stregex(names[col], '[^_a-zA-Z0-9]+', length=len)
    endwhile
    first = strmid(names[col], 0, 1)
    if first ge '0' and first le '9' then names[col] = '_' + names[col]
    if col gt 0 then begin
      nvar = 1
      postfix = ''
      repeat begin
        w = where(names[col] + postfix eq names[0:col-1], cnt)
        if cnt gt 0 then begin
          nvar += 1
          postfix = '_' + strtrim(nvar, 2)
        endif
      endrep until cnt eq 0
    endif
  endfor
  s = 'rec=create_struct(names'
  for j=0, ntcols-1 do $
     s = s + ',fix(0,type=' + strtrim(types[wtcol[j]], 2) + ')'
  s = s + ')'
  res = execute(s)

  ;; Initializes the cycle variables
  if keyword_set(append) then begin
    catlen = 2*n_elements(v1) + 1
    cat = replicate(rec, catlen/2)
    if n_params() gt 2 then begin
      for j=1, n_params()-1 do begin
        res = execute('cat.(' + strtrim(j-1, 2) + ') = v' + $
                      strtrim(j, 2))
      endfor
    endif else begin
      if n_tags(v1) eq 0 then cat.(0) = v1 $
      else cat[*] = v1
    endelse
    cat = [cat[0], cat, cat]
    if n_elements(lineno) ne catlen/2 then $  
       lineno = replicate(-1L, catlen) $
    else $
       lineno = [lineno, replicate(-1L, catlen/2)]
    if n_elements(lines) ne catlen/2 then begin
      lines = line[*, intarr(catlen)]
      for j=0, n_tags(cat)-1 do lines[j, *] = strtrim(cat.(j), 2)
    endif else lines = [line, [lines], [line[*, catlen/2]]]
    currec = catlen/2
    curtline = 0L
  endif else begin
    catlen = 100L                                      ; Initial catalog size
    cat = replicate(rec, catlen)
    lineno = replicate(-1L, catlen)
    lines = line[*, intarr(catlen)]
    currec = 0L
    curtline = 0L
  endelse

  info = replicate({xreadcol_info, column: 0, name: '', type: 'B', $
                    lineno: 1L, value: ''}, ntcols)
  info.column = indgen(ncols) + 1
  info.name = names

  while 1 do begin
    ntags = n_elements(line) 
    if ntags lt ncols then line = [line, replicate('', ncols-ntags)] $
    else if ntags gt ncols then line = line[0:ncols-1]
    k = -1L
    for i = 0L, ncols-1 do begin
      if types[i] eq -1 then continue
      if types[i] eq -2 then break
      k = k + 1
      chknum:
      test = chknum(line[i], val, type=types[i], $
                    overflow=upgradeformat, precision=upgradeformat, $
                    base=bases[i], ses=sess[i], fast=(currec gt checklines))
      if test eq 0 then rec.(k) = val $
      else if test eq 5 then begin                     ; null string
        if n_elements(missing) eq 1 then begin
          line[i] = missing
          if strlen(strtrim(missing, 2)) eq 0 and $
             keyword_set(upgradeformat) then begin
            types[i] = 7
            goto, upgrade
          endif else goto, chknum
        endif else goto, readline
      endif else if keyword_set(upgradeformat) then begin
        info[i].lineno = curline
        info[i].value = line[i]
        if test eq 1 then begin                        ; type upgrade
          if types[i] ne 4 and types[i] ne 5 then begin
            types[i] = upgrades1[types[i]] 
          endif else if sess[i] eq 0 then begin
            sess[i] = 1 
            goto, chknum
          endif else begin
            sess[i] = 0
            types[i] = 7
          endelse
        endif else begin                               ; precision upgrade
          types[i] = upgrades2[types[i]]
        endelse
        upgrade:
        tmp = rec
        s = 'rec=create_struct(tag_names(rec)'
        for j=0, ntcols-1 do $
          s = s + ',fix(0,type=' + strtrim(types[wtcol[j]], 2) + ')'
        s = s + ')'
        res = execute(s)
        for j=0, k-1 do rec.(j) = tmp.(j)
        tmp = replicate(rec, n_elements(cat))
        for j=0, ntcols-1 do $
          if types[wtcol[j]] ne 7 then tmp.(j) = cat.(j) $
          else tmp.(j) = (lines[wtcol[j], *])[*]
        cat = tmp
        tmp = 0
        goto, chknum
      endif else begin                                 ; discard line
        if not keyword_set(silent) then $
          message, /informational, 'Skipping line ' + strtrim(curline, 2)
        goto, readline                               
      endelse
    endfor
    currec = currec + 1
    if currec ge catlen then begin
      if not keyword_set(silent) then $
         print, format='(A,$)', !error_state.msg_prefix + 'XREADCOL: ' + $
                'increasing buffer length...' + string(13B)
      cat = [cat, cat]
      lineno = [lineno, lineno]
      lines = [[lines], [lines]]
      catlen = catlen * 2L
      if not keyword_set(silent) then $
         print, format='(A,$)', !error_state.msg_prefix + 'XREADCOL: ' + $
                '                           ' + string(13B)
    endif
    cat[currec] = rec
    lineno[currec] = curline
    lines[*, currec] = line
    if currec mod 100 eq 0 then begin
      if not keyword_set(silent) then $
      print, format='(A,$)', !error_state.msg_prefix + 'XREADCOL: ' + $
             strtrim(currec, 2) + ' lines read' + string(13B)
    endif
    if currec eq nrecs then break
    readline:
    if (curline eq nlines) or (currec eq ntlines) then break
    if eof(unit) then break
    line = xreadcol_readline(unit, separator=separator, comments=comments, $
                             escape=esc, nulls=nulls, missing=missing, $
                             regex=regex, preserve_null=preserve_null, $
                             callback=callback, cols=cols, curline=curline, $
                             ignore=ignore, nlines=nlines, $
                             left=left, right=right)
    if size(line, /type) eq 2 then begin
      if line lt -1 and keyword_set(stopempty) then break
    endif
  endwhile

  stop:
  if size(file, /type) eq 7 then begin
    close, unit
    free_lun, unit
  endif

  ;; Shows informational results
  if currec eq 0 then $
    message, 'No valid lines found for specified format.' $
  else if not keyword_set(silent) then $ 
    message, /informational, strtrim(currec, 2) + ' valid lines read'

  ;; Evaluates the final format
  newformat = ''
  for i=0, ncols-1 do begin
    w = where(_types eq types[i] and _bases eq bases[i] and $
              _sess eq sess[i], cnt)
    if cnt eq 0 then ctype = '?' $
    else ctype = string(byte(65 + w[0]))
    newformat = newformat + ',' + ctype
    info[i].type = ctype
  endfor
  format = '(' + strmid(newformat, 1) + ')'
  if not keyword_set(silent) then $
     message, /informational, 'Format used: ' + format
  
  if keyword_set(verbose) then begin
    l1 = floor(alog10(ncols)) + 1
    l3 = max(strlen(info.name))
    l4 = floor(alog10(max(info.lineno))) + 1
    l5 = 67 - l1 - (l3 > 4) - l4
    format = '(A-' + strtrim(l1, 2) + ', "  ", A-4, "  ", A-' + $
             strtrim(l3 > 4, 2) + ', "  ", A-5)'
    print, format=format, '#', 'TYPE', 'NAME', 'LINE'
    format = '(I0' + strtrim(l1, 2) + ', "  ", A-4, "  ", A-' + $
             strtrim(l3, 2) + ', "  ", I0' + strtrim(l4, 2) + $
             ', " ", A-' + strtrim(l5, 2) + ')'
    for i=0, ncols-1 do $
       print, format=format, info[i].column, info[i].type, $
              info[i].name, info[i].lineno, info[i].value
  endif


  ;; Saves the final data
  cat = cat[1:currec]
  lineno = lineno[1:currec]
  if n_params() eq 2 then begin
    if n_tags(cat) eq 1 then v1 = cat.(0) $
    else v1 = cat
  endif else begin
    for j=0, ntcols-1 do $
       res = execute('v' + strtrim(j + 1, 2) + '=cat.(' + strtrim(j, 2) + ')')
  endelse

end


;;; Local Variables:
;;; comment-column: 55
;;; fill-column: 78
;;; End:
