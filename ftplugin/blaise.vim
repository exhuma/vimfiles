set shiftwidth=3
set tabstop=3
set foldmethod=indent
set commentstring={%s}

"-----------------------------------------------------------------------------
" Insert a new unique error-code at the cursor-position
"
" This function inserts an error/warning code at the cursor position. To
" ensure uniqueness, it searches the currently open buffer for existing codes
" and keeps track of the highest ID. It then increments the code by one and
" inserts it at the cursor position.
"
" The codes have a one-letter 'tag' and a 4-digit ID (ex. 'E0042')
"
" CAVEATS:
"  - Multiple error codes on one line will confuse this algorithm
"  - The function only searches the currently active file for existing codes.
"    If other files are referenced using 'include' statements, uniqueness is
"    not guaranteed anymore.
"  - This method will overwrite register "z" to store the cursor location.
"
" PARAMETERS:
"  tag:    The one-letter prefix
"  prefix: A text which is prepended to the output
"  suffix: A text which is appended to the output
"-----------------------------------------------------------------------------
fun! BLAISENextTag(tag, prefix, suffix)
   let errors = []
   let pattern = a:tag."\\d\\{4}"
   normal mz
   normal gg

   let match_line = search( pattern, "W" )
   while match_line != 0
      let errStr = matchstr( getline(match_line), pattern )
      let errStr = strpart( errStr, 1 )
      let errStr = substitute( errStr, "0", "", "g" )
      call add( errors, errStr )
      let match_line = search( pattern, "W" )
   endwhile
   let maxError = max(errors)+1

   normal `z
   execute "normal i".printf("%s%s%04d%s", a:prefix, a:tag, maxError, a:suffix)."\<ESC>"
endfun

setlocal makeprg=\"C:\\Program\ Files\\StatNeth\\Blaise\ 4.8\ Enterprise\\bin\\b4cpars.exe\"\ %
setlocal errorformat=%-Gb4cpars%.exe%.%#,%-GParsing:%.%#,%EError:\ \ \ \ %m,%CFile:\ \ \ \ \ %f,%CLine:\ \ \ \ \ %l,%ZPosition:\ %c

nmap <F11> :call BLAISENextTag( "E", "<font color='#0000ff'><b>", ":</b></font>" )<CR>
nmap <F12> :call BLAISENextTag( "W", "<font color='#ff0000'><b>", ":</b></font>" )<CR>
nmap <Leader>cam :!start "C:\Program Files\StatNeth\Blaise 4.8 Enterprise\Bin\cameleon.exe"<CR>
nmap <Leader>boi :!start "C:\Program Files\StatNeth\Blaise 4.8 Enterprise\Bin\BoWrkShp.exe"<CR>
nmap <Leader>diw :!start "C:\Program Files\StatNeth\Blaise 4.8 Enterprise\Bin\DepCfg.exe"<CR>
nmap <Leader>bml :!start "C:\Program Files\StatNeth\Blaise 4.8 Enterprise\Bin\Emily.exe"<CR>
nmap <Leader>bmf :!start "C:\Program Files\StatNeth\Blaise 4.8 Enterprise\Bin\MenuEdit.exe"<CR>
nmap <Leader>vmap :!start "\\STATEC_1\\COMMUN\Development\statent\combinedyears\utility\varmapper\tkmap.py"<CR>
nmap <Leader>cc :!start "C:\Program Files\StatNeth\Blaise 4.8 Enterprise\Bin\Blaise.exe" "%:p"<CR>

if has("win16") || has("win32") || has("win64")|| has("win95")
   map <F9> :make<CR>
   map <C-F9> :!"C:\Program Files\StatNeth\Blaise 4.8 Enterprise\Bin\dep.exe" %<CR>
elseif has("unix")
   " nothing to do...
endif


