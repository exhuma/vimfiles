" Pyhtonic stuff
"

" ## Function Keys ##{{{##
if has("win32")
   map <F5> :!python.exe "%:p"<CR>
elseif has("unix")
   map <F5> :w<CR>:!urxvt -e python -i % &<CR><CR>
   map <F6> :w<CR>:!urxvt -e python -m winpdb %<CR><CR>
   nmap <F9> :Pylint<CR><C-W>p
   au! BufWritePost **/*.py "silent! !ctags *.py"
endif
"nmap <F6> yyP<home>widef get_<end>(self):<esc><down><esc>yyP>>I"Accessor: <end>"<esc><down>yyP>>Ireturn self.__<esc>o<esc><down>yyPIdef set_<end>(self, input):<esc><down>yyP>>I"Mutator: <end>"<esc><down>yyP>>Iself.__<end> = input<esc>o<esc><down><home>wveyA = property(get_<esc>pA, set_<esc>pA)<esc>o<esc>
" ## }}} ##

" ## Formatting ##{{{##
set comments& comments+=sl:\"\"\"-,mb:#,e:-\"\"\" formatoptions& formatoptions+=or

set tabstop=4
set shiftwidth=4
set expandtab
" ## }}} ##

let g:pylint_onwrite = 0
compiler pylint

" ## python environment ##{{{##
python << EOF
import os
import sys
import vim
for p in sys.path:
    if os.path.isdir(p):
        vim.command(r"set path+=%s" % (p.replace(" ", r"\ ")))

import vim
def EvaluateCurrentRange():
   eval(compile('\n'.join(vim.current.range),'','exec'),globals())

EOF
" ## }}} ##

set tags+=$HOME/.vim/tags/python.ctags

map <C-h> :py EvaluateCurrentRange()

" ## SuperTab ##{{{##
"let g:SuperTabDefaultCompletionType = "<c-x><c-o>"
" ## }}} ##

" vim: set foldmethod=marker foldmarker={{{,}}} foldenable foldlevel=0:
