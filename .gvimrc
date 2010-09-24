
" Things to override for the GTK interface
" ----------------------------------------------------------------------------
colorscheme my_inkpot
map <F2> :colorscheme my_inkpot<CR>:set background=dark<CR>
set cmdheight=2                  " Keep a 2-line command-line
set mousehide                    " Hide the mouse pointer while typing
if has("win32")
   set guifont=Anonymous_Pro:h11:cANSI
elseif has("unix")
   set guifont=Anonymous\ Pro\ 16
endif
