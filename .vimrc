set nocompatible           " Behave like vim and not like vi!

if has("vms")     "{{{ Stuff from stack.nl (see bottom of file)
  set nobackup    " do not keep a backup file, use versions instead
else
  set backup      " keep a backup file
endif

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
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
" VIM 7 Settings
" ----------------------------------------------------------------------------
if v:version >= 700
   set cursorline
endif

" Other Settings
" ----------------------------------------------------------------------------
set encoding=utf-8

" Indentation settings
" ----------------------------------------------------------------------------
set autoindent                   " always set autoindenting on
set shiftwidth=3                 " Force indentation to be 3 spaces
set tabstop=3                    "          -- idem --
set list                         " EOL, trailing spaces, tabs: show them.
set lcs=tab:├─                   " Tabs are shown as ├──├──
set lcs+=trail:▒                 " Trailing spaces are shown as shrouded blocks
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

" Display
" ----------------------------------------------------------------------------
set title                        " display title in X.
set foldcolumn=3                 " display folds
set nowrap                       " Prevent wrapping
colorscheme adaryn
set background=dark


" UI Tweaks
" ----------------------------------------------------------------------------
" make search results appear in the middle of the screen:
nmap n nzz
nmap N Nzz
nmap * *zz
nmap # #zz
nmap g* g*zz
nmap g# g#zz
nmap <kMinus>  :bprevious<CR>    " Switch to previous buffer
nmap <kPlus>   :bnext<CR>        " Switch to next buffer
nmap <C-s>     :w<CR>
set backspace=indent,eol,start   " allow backspacing over everything in insert mode
set history=50                   " keep 50 lines of command line history
set ruler                        " show the cursor position all the time
set showcmd                      " display incomplete commands
set so=7                         " Keep a 7-lines lookahead when scrolling
set wildmenu                     " Show auto-complete matches
nnoremap Q gq                    " Don't use Ex mode, use Q for formatting

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
         \ '\.bfi$' , '\.bpk$' , '\.bsk$' , '\.bwm$' , '\.exe$' ,
         \ '\.exe$' , '\.ico$' , '\.lnk$' , '\.sfv$', '\~$' ]
let NERDTreeWinSize=40

"
" Store viminfo on exit
set viminfo=%,'50,<100,n~/.viminfo

" EOF... sort of ;)
" good example at http://www.stack.nl/~wjmb/stuff/dotfiles/vimrc.htm
"
" vim: set shiftwidth=3 tabstop=3 expandtab:
" vim: set foldmethod=marker foldmarker={{{,}}} foldenable foldlevel=0:
