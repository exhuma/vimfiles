set nocompatible           " Behave like vim and not like vi!

" vundle settings
filetype off
set rtp+=~/.vim/vundle.git/
call vundle#rc()
Bundle 'scrooloose/nerdtree'
Bundle 'csv.vim'

if has("vms")     "{{{ Stuff from stack.nl (see bottom of file)
  set nobackup    " do not keep a backup file, use versions instead
else
  set backup      " keep a backup file
  if has("win16") || has("win32") || has("win64")|| has("win95")
     set backupdir=.\\_vimfiles,.
  elseif has("unix")
     set backupdir=./_vimfiles,.
  endif
endif

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
  set incsearch
  set showmatch
endif

" Only do this part when compiled with support for autocommands.
if has("autocmd")

  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  filetype plugin indent on

  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
  au!

  " For all text files set 'textwidth' to 78 characters.
  autocmd FileType text setlocal textwidth=78

  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  autocmd BufReadPost *
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal g`\"" |
    \ endif

  augroup END

else

endif " has("autocmd") }}}

"
" Specific version settings
" ----------------------------------------------------------------------------

if v:version >= 703
   set colorcolumn=80
   set relativenumber
   set undofile
   if has("win16") || has("win32") || has("win64")|| has("win95")
      set undodir=.\\_vimfiles,.
   elseif has("unix")
      set undodir=./_vimfiles,.
   endif
endif

" Other Settings
" ----------------------------------------------------------------------------
set encoding=utf-8
set smartcase

" Indentation settings
" ----------------------------------------------------------------------------
set autoindent                   " always set autoindenting on
set shiftwidth=3                 " Force indentation to be 3 spaces
set tabstop=3                    "          -- idem --
set list                         " EOL, trailing spaces, tabs: show them.
set lcs=tab:├─                   " Tabs are shown as ├──├──
set lcs+=trail:␣                 " Show trailing spaces
set expandtab                    " always expand tabs to spaces

" Development helpers
" ----------------------------------------------------------------------------
set showmatch                    " Show matching braces
" for ctrl-P and ctrl-N completion, get things from syntax file
autocmd BufEnter * exec('setlocal complete+=k$VIMRUNTIME/syntax/'.&ft.'.vim')
"autocmd FileType *  execute "setlocal complete+="."k/usr/share/vim/vim62/syntax/".getbufvar("%","current_syntax").".vim"
"Insert indentation modeline
imap <F12> # vim: set shiftwidth=3 tabstop=3 expandtab ai:<CR>
au! BufWritePost *.py "silent! !ctags *.py"

" replace all @n@ in a selection with an auto-number (based on the line,
" starting at 0)
vmap <F11> :s/@n@/\=printf("%d;", line(".")-line("'<"))/<CR>

" Display
" ----------------------------------------------------------------------------
set title                        " display title in X.
set foldcolumn=5                 " display up to 4 folds
set nowrap                       " Prevent wrapping
colorscheme molokai
set background=dark


" UI Tweaks
" ----------------------------------------------------------------------------
" make search results appear in the middle of the screen
nmap n nzz
nmap N Nzz
nmap * *zz
nmap # #zz
nmap g* g*zz
nmap g# g#zz

" Switch to previous/next buffer
nmap <kMinus>  :bprevious<CR>
nmap <kPlus>   :bnext<CR>

" CTRL+S saves the buffer
nmap <C-s>     :w<CR>

" Jump to the previous/next entry in the quickfix list
nmap <C-Up>    :cNext<CR>
nmap <C-Down>  :cnext<CR>

" When moving up/down in wrapped lines, move 'screen' lines instead of
" physical lines
nnoremap j gj
nnoremap k gk

set backspace=indent,eol,start   " allow backspacing over everything in insert mode
set history=50                   " keep 50 lines of command line history
set ruler                        " show the cursor position all the time
set showcmd                      " display incomplete commands
set so=7                         " Keep a 7-lines lookahead when scrolling
set wildmenu                     " Show auto-complete matches
set statusline=%<%f%h%m%r%=\|\ Dec:\ %-3b\ Hex:\ 0x%2B\ \|\ %20(%4l,%4c%V\ \|\ %3P%)
set laststatus=2                 " Always show the status bar
"
" Don't use Ex mode, use Q for formatting
nnoremap Q gq

" Print Settings
" ----------------------------------------------------------------------------
set printoptions=header:3,number:y,left:10mm,right:10mm,top:10mm,bottom:10mm

" Abbreviations
" ----------------------------------------------------------------------------
iab miam Michel Albert <michel.albert@statec.etat.lu>

" SVNCommand Settings 
" ----------------------------------------------------------------------------
let SVNCommandEdit='split'
let SVNCommandNameResultBuffers=1
let mapleader=','

"
" NERDTree Settings
" ----------------------------------------------------------------------------
let NERDTreeIgnore=['\.bjk$', '\.b[xm]i$', '\.ms[ux]$' , '\.bd[bm]$' ,
         \ '\.bfi$' , '\.bpk$' , '\.bsk$' , '\.bwm$' , '\.exe$' , '\.tmp$' ,
         \ '\.exe$' , '\.ico$' , '\.lnk$' , '\.sfv$', '\~$' ]
let NERDTreeWinSize=40
map <C-S-e> :NERDTree<CR>

"
" Store viminfo on exit
set viminfo=%,'50,<100,n~/.viminfo

"let g:SaveUndoLevels = &undolevels
"let g:BufSizeThreshold = 1000000
"if has("autocmd")
"  " Store preferred undo levels
"  au VimEnter * let g:SaveUndoLevels = &undolevels
"  " Don't use a swap file for big files
"  au BufReadPre * if getfsize(expand("<afile>")) >= g:BufSizeThreshold | setlocal noswapfile | endif
"  " Upon entering a buffer, set or restore the number of undo levels
"  au BufEnter * if getfsize(expand("<afile>")) < g:BufSizeThreshold | let &undolevels=g:SaveUndoLevels | hi Cursor term=reverse ctermbg=black guibg=black | else | set undolevels=-1 | hi Cursor term=underline ctermbg=red guibg=red | endif
"endif

"
" Other Keyboard mappings
" ----------------------------------------------------------------------------
map <F4> :silent !/usr/bin/konsole --workdir :pwd<CR>
nnoremap <silent> <F8> :TlistToggle<CR>
nnoremap <leader><space> :noh<CR>

"
" Settings for specific file types (shouldn't this go to ftplugin?)
" ----------------------------------------------------------------------------
let g:xml_syntax_folding=1
au FileType xml setlocal foldmethod=syntax


" EOF... sort of ;)
" good example at http://www.stack.nl/~wjmb/stuff/dotfiles/vimrc.htm
"
" vim: set shiftwidth=3 tabstop=3 expandtab:
" vim: set foldmethod=marker foldmarker={{{,}}} foldenable foldlevel=0:
