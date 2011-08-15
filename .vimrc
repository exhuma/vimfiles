set nocompatible           " Behave like vim and not like vi!

"
" vundle (https://github.com/gmarik/vundle) settings
" ----------------------------------------------------------------------------
filetype off
set rtp+=~/.vim/vundle.git/
call vundle#rc()
Bundle 'scrooloose/nerdtree'
Bundle 'jinja.vim'
Bundle 'tpope/vim-fugitive'
Bundle 'gitv'
Bundle 'ZenCoding.vim'
Bundle 'vim-coffee-script'

if has("vms")     "{{{ Stuff from stack.nl (see bottom of file)
  set nobackup    " do not keep a backup file, use versions instead
else
  set backup      " keep a backup file
  " If the directory '_vimfiles' exist, put all vim related files (swap,
  " backup, ...) into it instead of the the directory of the file. This keeps
  " the folder clean
  if has("win16") || has("win32") || has("win64")|| has("win95")
     set backupdir=.\\_vimfiles,.
  elseif has("unix")
     set backupdir=./_vimfiles,.
  endif
endif

" Switch syntax highlighting on, highlight the current search and the matching
" parentheses/brackets,...
syntax on
set hlsearch
set incsearch
set showmatch

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

" Set a decent text width. This makes printouts cleaner, and makes it easier
" to read the files on an 80-column screen (f. ex. a server monitor)
set textwidth=78

" Enable 256 color support on all terminals. This makes it actually feasible
" to enable 'cursorline' and also allows me to use less obtrusive colors for
" othe elements (like 'colorcolumn')
set t_Co=256

if v:version >= 700
    " Highlight the line containing the cursor
    set cursorline
endif

if v:version >= 703
   " Highlight the column where the text should wrap
   exec printf("set colorcolumn=%d", &textwidth+1)

   " keep a file containing undo info. So you can undo even after closing the
   " file
   set undofile

   " keep special undofiles inside the '_vimfiles' subfolder if it exists
   if has("win16") || has("win32") || has("win64")|| has("win95")
      set undodir=.\\_vimfiles,.
   elseif has("unix")
      set undodir=./_vimfiles,.
   endif
endif

" Default editor encoding 
set encoding=utf-8

" Ignore case for search operations ...
set ignorecase

" ... but be case sensitive if the search pattern contains uppercase chars
set smartcase

" Indentation settings
" ----------------------------------------------------------------------------
set autoindent                   " always set autoindenting on
set shiftwidth=4                 " Force indentation to be 4 spaces
set tabstop=4                    "          -- idem --
set list                         " EOL, trailing spaces, tabs: show them.
set lcs=tab:├─                   " Tabs are shown as ├──├──
set lcs+=trail:␣                 " Show trailing spaces as ␣
set expandtab                    " always expand tabs to spaces

" Development helpers
" ----------------------------------------------------------------------------

" for ctrl-P and ctrl-N completion, get things from syntax file
autocmd BufEnter * exec('setlocal complete+=k$VIMRUNTIME/syntax/'.&filetype.'.vim')

"Insert indentation modeline
au! BufWritePost *.py "silent! !ctags *.py"

" replace all @n@ in a selection with an auto-number (based on the line,
" starting at 0)
vmap <F11> :s/@n@/\=printf("%d;", line(".")-line("'<"))/<CR>

" highlight columns of the current visual selection
vmap <F5> <ESC>:let &l:cc = join(range(getpos("'<")[2], getpos("'>")[2]),',')<CR>

" Display
" ----------------------------------------------------------------------------
set title                        " display title in X.
set foldcolumn=5                 " display up to 4 folds
set nowrap                       " Prevent wrapping
colorscheme molokai
set background=dark

" Use a less intrusive color for the color column (It's not linked in
" the 'molokai' colorscheme as of this writing)
hi clear ColorColumn
hi link ColorColumn LineNr

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
set scrolloff=7                  " Keep a 7-lines 'lookahead' when scrolling
set wildmenu                     " Show auto-complete matches
set wildignore=*.bdb,*.msu,*.bfi,*.bjk,*.bpk,*.bdm,*.bfm,*.bxi,*.bmi,*.msx,*.lnk,*~,*.bak
set statusline=%<%f%m%r\ %{fugitive#statusline()}%=\|\ Dec:\ %-3b\ Hex:\ 0x%2B\ \|\ %20(%4l,%4c%V\ \|\ %3P%)
set laststatus=2                 " Always show the status bar

" Don't use Ex mode, use Q for formatting
nnoremap Q gq

" Print Settings
" ----------------------------------------------------------------------------
set printoptions=header:3,number:y,left:10mm,right:10mm,top:10mm,bottom:10mm
if has("win32")
   set printfont=Anonymous_Pro:h10
elseif has("unix")
   set printfont=Anonymous\ Pro\ 10
endif

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
map <C-S-e> :NERDTreeToggle<CR>

"
" Zen Coding Settings
" ----------------------------------------------------------------------------
let g:user_zen_settings = {
\  'indentation' : '   '
\}

"
" Store viminfo on exit
set viminfo=%,'50,<100,n~/.viminfo

"
" Other Keyboard mappings
" ----------------------------------------------------------------------------
map <F4> :silent !/usr/bin/konsole --workdir :pwd<CR>
nnoremap <silent> <F8> :TlistToggle<CR>
" quickly clear the search string (to clear highlights)
nnoremap <leader><space> :noh<CR>

"
" Settings for specific file types (shouldn't this go to ftplugin?)
" ----------------------------------------------------------------------------
let g:xml_syntax_folding=1
au FileType xml setlocal foldmethod=syntax

"
" Disable some features on large files
" ----------------------------------------------------------------------------
" Protect large files from sourcing and other overhead.
" Files become read only
" ----------------------------------------------------------------------------
if !exists("my_auto_commands_loaded")
   let my_auto_commands_loaded = 1
   " Large files are > 10M
   " Set options:
   " eventignore+=FileType (no syntax highlighting etc
   " assumes FileType always on)
   " noswapfile (save copy of file)
   " bufhidden=unload (save memory when other file is viewed)
   " buftype=nowritefile (is read-only)
   " undolevels=-1 (no undo possible)
   let g:LargeFile = 1024 * 1024 * 10
   augroup LargeFile
      autocmd BufReadPre * let f=expand("<afile>") | if getfsize(f) > g:LargeFile | set eventignore+=FileType | setlocal noswapfile bufhidden=unload buftype=nowrite undolevels=-1 | else | set eventignore-=FileType | endif
   augroup END
endif

" EOF... sort of ;)
" this file is based on http://www.stack.nl/~wjmb/stuff/dotfiles/vimrc.htm
" ... but it's been badly modified since then...
"
" vim: set shiftwidth=4 tabstop=4 expandtab:
" vim: set foldmethod=marker foldmarker={{{,}}} foldenable foldlevel=0:
