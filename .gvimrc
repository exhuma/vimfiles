" Things to override for the GTK interface
" ----------------------------------------------------------------------------
set mousehide                    " Hide the mouse pointer while typing
if has("win32")
   set guifont=Anonymous_Pro:h11:cANSI
elseif has("unix")
   "set guifont=Anonymous\ Pro\ 13
   set guifont=Liberation\ Mono\ 10
endif

" Remove toolbar
set guioptions-=T

"colorscheme wombat256mod
colorscheme jellybeans
