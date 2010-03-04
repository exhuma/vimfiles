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

" Indentation settings
" ----------------------------------------------------------------------------
set autoindent                   " always set autoindenting on
set shiftwidth=3                 " Force indentation to be 3 spaces
set tabstop=3                    "          -- idem --
set list                         " EOL, trailing spaces, tabs: show them.
set lcs=tab:>\                   " Tabs are shown as >
set lcs+=trail:.                 " Trailing spaces are shownas periods
set expandtab                    " always expand tabs to spaces

" Development helpers
" ----------------------------------------------------------------------------
set showmatch                    " Show matching braces
   " for ctrl-P and ctrl-N completion, get things from syntax file
   autocmd BufEnter * exec('setlocal complete+=k$VIMRUNTIME/syntax/'.&ft.'.vim')
"Insert LGPL Header
imap <F1> <C-o>:r ~/.vim/licenses/LGPL.h<CR>
"Insert GPL Header
imap <F2> <C-o>:r ~/.vim/licenses/GPL2.h<CR>
"Insert standard html template
imap <F5> <C-o>:r ~/.vim/templates/html.tpl<CR>
"Insert indentation modeline
imap <F12> # vim: set shiftwidth=3 tabstop=3 expandtab ai:<CR>

" Display
" ----------------------------------------------------------------------------
set title                        " display title in X.
set foldcolumn=4                 " display folds
set nowrap                       " Prevent wrapping
colorscheme desert               " Select colorscheme
set background=dark
  " Quick switch for color schemes for bright/dark console settings
  nmap <F2> :colorscheme my_inkpot<CR>:set background=dark<CR>
  nmap <F3> :colorscheme chela_light<CR>:set background=light<CR>
set cursorline                   " Vim7 Only!


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
set backspace=indent,eol,start   " allow backspacing over everything in insert mode
set history=50                   " keep 50 lines of command line history
set ruler                        " show the cursor position all the time
set showcmd                      " display incomplete commands
nnoremap Q gq                    " Don't use Ex mode, use Q for formatting

" Abbreviations
" ----------------------------------------------------------------------------
iab miam Michel Albert <michel@albert.lu>

" EOF... sort of ;)
" good example at http://www.stack.nl/~wjmb/stuff/dotfiles/vimrc.htm
"
" vim: set shiftwidth=3 tabstop=3 expandtab:
" vim: set foldmethod=marker foldmarker={{{,}}} foldenable foldlevel=0:
