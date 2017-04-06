" ############################################################################
" Complete re-work of my .vimrc
" All my old baggage has been thrown over board, and the .vimrc cleaned up.
" Thise file no longer contains any comments what each section does. The vim
" onlline help is all you need. But, if you're new to vim, here are a couple
" of hints to get you started:
"
" Folding
" -------
"
"  This file uses folds to make it a bit more manageable. Type the following
"  to get started on folding:
"
"       :help folding
"
"  If you just want to open everything up and start reading, type "zR"
"
" Finding help
" ------------
"
"  You can open up the help by typing ":help" followed by a label. To read the
"  vimrc, the following will be helpful:
"
"    * If the line changes a setting (for example: 'set autoindent') you
"      should surround the help label with single quotes:
"
"          :help 'autodindent'
"
"    * for everything else, you can prefix the label with a colon to get to
"      the right page:
"
"          :help :filetype
" ############################################################################

set encoding=utf-8
scriptencoding utf-8  " The encoding of *this* file

" Vundle {{{
filetype off  " See https://github.com/gmarik/vundle/issues/176
set rtp+=~/.vim/bundle/Vundle.vim/
call vundle#begin("~/.vim/bundle")

Plugin 'gmarik/Vundle.vim'

Plugin 'Jinja'
Plugin 'MarcWeber/vim-addon-mw-utils'
Plugin 'NrrwRgn'
Plugin 'SirVer/ultisnips'
Plugin 'Yggdroot/indentLine'
Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'ervandew/supertab'
Plugin 'gitv'
Plugin 'itchyny/lightline.vim'
Plugin 'jelera/vim-javascript-syntax'
Plugin 'klen/python-mode'
Plugin 'mattn/emmet-vim'
Plugin 'molokai'
Plugin 'scrooloose/nerdtree'
Plugin 'tomtom/tlib_vim'
Plugin 'tpope/vim-fugitive'
Plugin 'tpope/vim-surround'
Plugin 'unimpaired.vim'

call vundle#end()
" }}}

" UI style and 'core' behaviour {{{
filetype plugin indent on
syntax on
colorscheme molokai
set list
set listchars=tab:├─
set listchars+=trail:␣
set listchars+=extends:→
set listchars+=precedes:←
set listchars+=nbsp:◊
set title
set foldcolumn=5
set background=dark
set t_Co=256
set cmdheight=2
set scrolloff=7
set wildmenu
set wildignore=*.lnk,*~,*.bak,*.pyc
set wildignore+=*/.hg/*,*/.svn/*
set wildignore+=env/*,*.egg-info/*,*/__pycache__/*,doc/_build/*
set wildmode=longest:full,full
set viminfo=%,'50,<100,n~/.viminfo
set pastetoggle=<F3>
set modeline
set ignorecase
set smartcase
set hlsearch
set incsearch
set showmatch
set ruler
set showcmd
set timeout timeoutlen=1000 ttimeoutlen=100
set backspace=indent,eol,start
set visualbell t_vb=

if has("patch-7.4.338")
    set wrap
    set breakindent
    set breakindentopt=sbr
    set showbreak=>
else
    set nowrap
endif

if has('autocmd')
    autocmd BufReadPost *
        \ if line("'\"") > 0 && line("'\"") <= line("$") |
        \   exe "normal g`\"" |
        \ endif
endif

if v:version >= 700
    " Highlight the line containing the cursor
    set cursorline
endif

if v:version >= 703
   " Highlight the column where the text should wrap
   set colorcolumn=+1
   hi clear ColorColumn
   hi link ColorColumn CursorLine
endif

" Custom colour for matching parentheses.
hi MatchParen term=reverse cterm=bold ctermbg=238 ctermfg=220

" Status line {{{

"Add the variable with the name a:varName to the statusline. Highlight it as {{{
"'error' unless its value is in a:goodValues (a comma separated string)
function! AddStatuslineFlag(varName, goodValues)
  set statusline+=[
  set statusline+=%#error#
  exec "set statusline+=%{RenderStlFlag(".a:varName.",'".a:goodValues."',1)}"
  set statusline+=%*
  exec "set statusline+=%{RenderStlFlag(".a:varName.",'".a:goodValues."',0)}"
  set statusline+=]
endfunction " }}}

"returns a:value or '' {{{
"
"a:goodValues is a comma separated string of values that shouldn't be
"highlighted with the error group
"
"a:error indicates whether the string that is returned will be highlighted as
"'error'
"
function! RenderStlFlag(value, goodValues, error)
  let goodValues = split(a:goodValues, ',')
  let good = index(goodValues, a:value) != -1
  if (a:error && !good) || (!a:error && good)
    return a:value
  else
    return ''
  endif
endfunction " }}}

set statusline=
set statusline+=%2.3n   " Buffer number
set statusline+=\ %< " Truncate here
set statusline+=%#Todo#\|%f\|%*   " The filename
set statusline+=\ %y " filetype
call AddStatuslineFlag('&ff', 'unix')    "fileformat
call AddStatuslineFlag('&fenc', 'utf-8') "file encoding
set statusline+=\ %m " modified flag
set statusline+=%r   "
set statusline+=%=   " Separator
set statusline+=\|\ Dec:\ %-3b\ Hex:\ 0x%2B " Character byte details
set statusline+=\ \|\ %20(%4l,%4c%V\ \|\ %3P%) " Cursor position

set laststatus=2                 " Always show the status bar

" }}} End status line

" }}}

" Code quality {{{
set autoindent
set shiftround
set shiftwidth=4
set tabstop=4
set expandtab
" }}}

" Modified behaviour {{{
" Modifies a couple of default shortcuts.
nnoremap n nzz
nnoremap N Nzz
nnoremap * *zz
nnoremap # #zz
nnoremap g* g*zz
nnoremap g# g#zz
nnoremap j gj
nnoremap k gk
" }}}

" Print Settings {{{
" ----------------------------------------------------------------------------
set printoptions=header:3,number:y,left:10mm,right:10mm,top:10mm,bottom:10mm
if has("win32")
   set printfont=Anonymous_Pro:h10
elseif has("unix")
   set printfont=Anonymous\ Pro\ 10
endif " }}}

" Mappings {{{
let mapleader=','
inoremap jj <Esc>
nnoremap <leader><space> :noh<CR>
nnoremap <leader>n :NERDTreeToggle<CR>
nnoremap <leader>t :silent !ctags -R .<CR>:redraw!<CR>
nnoremap <leader>l :PymodeLint<CR>
nnoremap <leader>d ddp/=======$<CR>jdd<C-o>P
nmap <space> <leader>

nmap <F4> a<C-R>=strftime("%Y-%m-%d %H:%M:%S")<CR><ESC>
imap <F4> <C-R>=strftime("%Y-%m-%d %H:%M:%S")<CR>

" Fix to make <C-PageUp/Down> work in tmux
nnoremap [5^ :tabprev<CR>
nnoremap [6^ :tabnext<CR>

" Abbreviation to instert a timestamp
iab <expr> dts strftime("%Y-%m-%d %H:%M:%S")

" Look up selected phrase in google
vnoremap ?? <Esc>:exec
 \ ':!sensible-browser http://www.google.com/search?q="'
 \ . substitute(@*,'\W\+\\|\<\w\>'," ","g")
 \ . '"'<CR><CR>
" }}}

" Plugins {{{

" NERDTree {{{
let NERDTreeIgnore=['\.exe$', '\.tmp$', '\.pyc',
    \ '\.sfv$', '\~$' ]
let NERDTreeWinSize=40
" }}}

" CtrlP {{{
let g:ctrlp_user_command = ['.git/', 'cd %s && git ls-files']
" }}}

" SQL {{{
let g:sql_type_default = 'pgsql'
let g:omni_sql_no_default_maps = 1
" }}}

" JavaScriptSyntax {{{
au FileType javascript call JavaScriptFold()
au FileType closure.javascript call JavaScriptFold()
" }}}

" UltiSnips {{{
let g:UltiSnipsEditSplit = 'vertical'
let g:UltiSnipsNoPythonWarning = 'true'
" }}}

" LightLine {{{
let g:lightline = {
    \ 'colorscheme': 'jellybeans',
    \ 'active': {
    \   'left': [ [ 'mode', 'paste' ],
    \             [ 'fugitive', 'readonly', 'filename', 'modified' ] ]
    \ },
    \ 'component': {
    \   'readonly': '%{&readonly?"⭤":""}',
    \   'fugitive': '%{exists("*fugitive#head")?fugitive#head():""}'
    \ },
    \ 'component_visible_condition': {
    \   'readonly': '(&filetype!="help"&& &readonly)',
    \   'modified': '(&filetype!="help"&&(&modified||!&modifiable))',
    \   'fugitive': '(exists("*fugitive#head") && ""!=fugitive#head())'
    \ },
    \ 'separator': { 'left': '', 'right': '' },
    \ 'subseparator': { 'left': '', 'right': '' }
    \ }
" }}}

" SuperTab {{{
let g:SuperTabLongestEnhanced=1
" }}}

" Syntastic {{{
let g:syntastic_id_checkers = 1
let g:syntastic_error_symbol = '✗'
let g:syntastic_warning_symbol = '⚠'
let g:syntastic_auto_loc_list = 1
let g:syntastic_python_python_exe = 'python3'
" }}}

" python-syntax {{{
let python_highlight_all = 1
" }}}

" python-mode {{{
let g:pymode_doc = 0
let g:pymode_folding = 1
let g:pymode_rope = 0
let g:pymode_rope_complete_on_dot = 0
let g:pymode_rope_extended_complete = 1
let g:pymode_syntax_print_as_function = 1
let g:pymode_virtualenv = 1
let g:pymode_virtualenv_path = 'env'
let pymode_lint_checker="pylint,pyflakes,pep8,mccabe"
" }}}

" {{{ emmet
let g:user_emmet_leader_key = '<c-y>'

" }}}

" vim: set shiftwidth=4 tabstop=4 expandtab:
" vim: set foldmethod=marker foldmarker={{{,}}} foldenable foldlevel=0:
