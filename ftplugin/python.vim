" Pyhtonic stuff
"
map <F5> :w<CR>:!xterm -geometry 120x50+0+0 -bg black -fg white -e python -i % &<CR><CR>
nmap <F6> yyP<home>widef get_<end>(self):<esc><down><esc>yyP>>I"Accessor: <end>"<esc><down>yyP>>Ireturn self.__<esc>o<esc><down>yyPIdef set_<end>(self, input):<esc><down>yyP>>I"Mutator: <end>"<esc><down>yyP>>Iself.__<end> = input<esc>o<esc><down><home>wveyA = property(get_<esc>pA, set_<esc>pA)<esc>o<esc>
set comments& comments+=sl:\"\"\"-,mb:#,e:-\"\"\" formatoptions& formatoptions+=or

"set foldtext='+'.v:folddashes.'\ '.(v:foldend-v:foldstart+1).'\ lines:\ '.substitute(getline(v:foldstart+1),'^.*\"\"\"-\\(.\\)\\*','\\1','').'\ \('.substitute(getline(v:foldstart),'^.\*def\ .\*\(self\,\\?\\(.*\\)\):','\\1','').'\)'
"set foldmethod=marker foldmarker=def\ ,}}} foldenable foldlevel=0

