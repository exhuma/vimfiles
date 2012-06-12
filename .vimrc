set nocompatible           " Behave like vim and not like vi!

"
" vundle (https://github.com/gmarik/vundle) settings
" ----------------------------------------------------------------------------
filetype off
if has("win16") || has("win32") || has("win64")|| has("win95")
    set rtp+=~/vimfiles/vundle.git/
else
    set rtp+=~/.vim/vundle.git/
endif

call vundle#rc()
Bundle 'scrooloose/nerdtree'
Bundle 'tpope/vim-fugitive'
Bundle 'nvie/vim-flake8'
Bundle 'ervandew/supertab'
Bundle 'taglist.vim'
Bundle 'TaskList.vim'
Bundle 'pythoncomplete'
Bundle 'python.vim'
Bundle 'gitv'
Bundle 'ZenCoding.vim'
Bundle 'vim-coffee-script'
Bundle 'ctrlp.vim'
Bundle 'surround.vim'

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

  autocmd FileType python set formatoptions=qorac textwidth=78

  augroup END

else

endif " has("autocmd") }}}

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

" replace all @n@ in a selection with an auto-number (based on the line,
" starting at 0)
vnoremap <F11> :s/@n@/\=printf("%d;", line(".")-line("'<"))/<CR>

" highlight columns of the current visual selection
vnoremap <F5> <ESC>:let &l:cc = join(range(getpos("'<")[2], getpos("'>")[2]),',')<CR>

" Display
" ----------------------------------------------------------------------------
set title                        " display title in X.
set foldcolumn=5                 " display up to 4 folds
set nowrap                       " Prevent wrapping
colorscheme molokai
set background=dark
set winheight=40
set winwidth=80

" Use a less intrusive color for the color column (It's not linked in
" the 'molokai' colorscheme as of this writing)
hi clear ColorColumn
hi link ColorColumn LineNr

" UI Tweaks
" ----------------------------------------------------------------------------
" make search results appear in the middle of the screen
nnoremap n nzz
nnoremap N Nzz
nnoremap * *zz
nnoremap # #zz
nnoremap g* g*zz
nnoremap g# g#zz

" Switch to previous/next buffer
nnoremap <kMinus>  :bprevious<CR>
nnoremap <kPlus>   :bnext<CR>

" CTRL+S saves the buffer
nnoremap <C-s>     :w<CR>

" Jump to the previous/next entry in the quickfix list
nnoremap <C-Up>    :cNext<CR>
nnoremap <C-Down>  :cnext<CR>

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
" TODO: enable the git statusline *only* if fugitive is properly installed
" set statusline=%<%f%m%r\ %{fugitive#statusline()}%=\|\ Dec:\ %-3b\ Hex:\ 0x%2B\ \|\ %20(%4l,%4c%V\ \|\ %3P%)

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
noremap <C-S-e> :NERDTreeToggle<CR>

"
" Zen Coding Settings
" ----------------------------------------------------------------------------
let g:user_zen_settings = {
\  'indentation' : '    '
\}

"
" Store viminfo on exit
set viminfo=%,'50,<100,n~/.viminfo

"
" Other Keyboard mappings
" ----------------------------------------------------------------------------
noremap <F4> :silent !/usr/bin/konsole --workdir :pwd<CR>
nnoremap <silent> <F8> :TlistToggle<CR>
" quickly clear the search string (to clear highlights)
nnoremap <leader><space> :noh<CR>
" Bubble visual selection
vnoremap <C-Up> xkP`[V`]
vnoremap <C-Down> xp`[V`]

"
" Settings for specific file types (shouldn't this go to ftplugin?)
" ----------------------------------------------------------------------------
let g:xml_syntax_folding=1
au FileType xml setlocal foldmethod=syntax

"
" Plugin settings
" ----------------------------------------------------------------------------
" ## SuperTab ##{{{##
"let g:SuperTabDefaultCompletionType = "<c-x><c-o>"
"let g:SuperTabMappingForward = '<c-nul>'
"let g:SuperTabMappingBackward = '<s-c-nul>'
" ## }}} ##
" ## ZenCoding ## {{{ ##
let g:user_zen_leader_key = '<c-z>'
let g:user_zen_settings = {
\  'indentation' : '    '
\}
" ## }}} ##
" ## CtrlP ## {{{ ##
let g:path_to_matcher = "/path/to/matcher"

let g:ctrlp_user_command = ['.git/', 'cd %s && git ls-files']
"let g:ctrlp_user_command = {
"  \ 'types': {
"    \ 1: ['.git/', 'cd %s && git ls-files'],
"    \ },
"  \ 'fallback': 'find %s -type f'
"  \ }
let g:ctrlp_working_path_mode = 2
" ## }}} ##
" ## SQL ## {{{ ##
let g:sql_type_default = 'pgsql'
let g:omni_sql_no_default_maps = 1
" ## }}} ##
" ## PHP ## {{{ ##
let php_folding = 1
" ## }}} ##

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

" Display the highlight group under the cursor
map <F10> :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
    \ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
    \ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>

" EOF... sort of ;)
" this file is based on http://www.stack.nl/~wjmb/stuff/dotfiles/vimrc.htm
" ... but it's been badly modified since then...
"
" vim: set shiftwidth=4 tabstop=4 expandtab:
" vim: set foldmethod=marker foldmarker={{{,}}} foldenable foldlevel=0:
