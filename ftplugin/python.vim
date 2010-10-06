" Pyhtonic stuff
"
map <F5> :w<CR>:!urxvt -e python -i % &<CR><CR>
nmap <F6> yyP<home>widef get_<end>(self):<esc><down><esc>yyP>>I"Accessor: <end>"<esc><down>yyP>>Ireturn self.__<esc>o<esc><down>yyPIdef set_<end>(self, input):<esc><down>yyP>>I"Mutator: <end>"<esc><down>yyP>>Iself.__<end> = input<esc>o<esc><down><home>wveyA = property(get_<esc>pA, set_<esc>pA)<esc>o<esc>
nmap <F9> :Pylint<CR><C-W>p
set comments& comments+=sl:\"\"\"-,mb:#,e:-\"\"\" formatoptions& formatoptions+=or

let g:pylint_onwrite = 0
compiler pylint

