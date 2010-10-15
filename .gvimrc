
" Things to override for the GTK interface
" ----------------------------------------------------------------------------
colorscheme molokai
map <F2> :colorscheme my_inkpot<CR>:set background=dark<CR>
set cmdheight=2                  " Keep a 2-line command-line
set mousehide                    " Hide the mouse pointer while typing
if has("win32")
   set guifont=Anonymous_Pro:h11:cANSI
elseif has("unix")
   set guifont=Anonymous\ Pro\ 16
endif

"
" Specific version settings
" ----------------------------------------------------------------------------
if v:version >= 700
   set cursorline
endif

if v:version >= 703
   hi clear ColorColumn
   hi link ColorColumn LineNr
endif
