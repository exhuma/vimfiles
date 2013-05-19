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


" Vundle {{{
set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

Bundle 'tpope/vim-fugitive'
Bundle 'gitv'
Bundle 'ctrlp.vim'
Bundle 'surround.vim'
Bundle 'scrooloose/nerdtree'
Bundle 'unimpaired.vim'
Bundle 'molokai'
" }}}

" Code quality {{{
set encoding=utf-8
set autoindent
set shiftwidth=4
set tabstop=4
set expandtab
" }}}

" UI style and 'core' behaviour {{{
filetype plugin indent on
colorscheme molokai
set list
set lcs=tab:├─
set lcs+=trail:␣
set title
set foldcolumn=5
set nowrap
set background=dark
set t_Co=256
set cmdheight=2
set scrolloff=7
set wildmenu
set wildignore=*.lnk,*~,*.bak,*.pyc
set wildignore+=*/.hg/*,*/.svn/*
set viminfo=%,'50,<100,n~/.viminfo
set pastetoggle=<F3>
set modeline
set ignorecase
set smartcase


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
endif
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

" Mappings {{{
inoremap jj <Esc>
nnoremap <leader><space> :noh<CR>
" }}}

" Plugins {{{

" NERDTree {{{
let NERDTreeIgnore=['\.exe$', '\.tmp$', '\.pyc',
         \ '\.sfv$', '\~$' ]
let NERDTreeWinSize=40
" }}}

" }}}

" vim: set shiftwidth=4 tabstop=4 expandtab:
" vim: set foldmethod=marker foldmarker={{{,}}} foldenable foldlevel=0:
