" Pyhtonic stuff
"
map <F5> :w<CR>:!xterm -geometry 120x50+0+0 -bg black -fg white -e python -i % &<CR><CR>
set comments& comments+=sl:\"\"\"-,mb:#,e:-\"\"\" formatoptions& formatoptions+=or

" (un)comment out marked lines
vmap <C-c> :s/^/##/<CR>/asidfjwehfuhasdfkjgheuky<CR>
vmap <C-v> :s/^##//<CR>/afjwheifugawdifuggfu<CR>

"set foldtext='+'.v:folddashes.'\ '.(v:foldend-v:foldstart+1).'\ lines:\ '.substitute(getline(v:foldstart+1),'^.*\"\"\"-\\(.\\)\\*','\\1','').'\ \('.substitute(getline(v:foldstart),'^.\*def\ .\*\(self\,\\?\\(.*\\)\):','\\1','').'\)'
"set foldmethod=marker foldmarker=def\ ,}}} foldenable foldlevel=0

