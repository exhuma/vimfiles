" Pyhtonic stuff
"
if has("win32")
   map <F5> :!python.exe "%:p"<CR>
elseif has("unix")
   map <F5> :w<CR>:!urxvt -e python -i % &<CR><CR>
   nmap <F9> :Pylint<CR><C-W>p
endif

nmap <F6> yyP<home>widef get_<end>(self):<esc><down><esc>yyP>>I"Accessor: <end>"<esc><down>yyP>>Ireturn self.__<esc>o<esc><down>yyPIdef set_<end>(self, input):<esc><down>yyP>>I"Mutator: <end>"<esc><down>yyP>>Iself.__<end> = input<esc>o<esc><down><home>wveyA = property(get_<esc>pA, set_<esc>pA)<esc>o<esc>
set comments& comments+=sl:\"\"\"-,mb:#,e:-\"\"\" formatoptions& formatoptions+=or

set tabstop=4
set shiftwidth=4
set expandtab

let g:pylint_onwrite = 0
compiler pylint

