set shiftwidth=3
set tabstop=3
set foldmethod=indent

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

nmap <F11> :call BLAISENextTag( "E", "<font color=\"#0000ff\">", "</font>" )<CR>
nmap <F12> :call BLAISENextTag( "W", "<font color=\"#0000ff\">", "</font>" )<CR>

if has("win16") || has("win32") || has("win64")|| has("win95")
   map <F5> :w<CR>:!"C:\Program Files\StatNeth\Blaise 4.8 Enterprise\Bin\b4cpars.exe" /A- %<CR>
   map <F6> :!"C:\Program Files\StatNeth\Blaise 4.8 Enterprise\Bin\dep.exe" %<CR>
elseif has("unix")
   " nothing to do...
endif
