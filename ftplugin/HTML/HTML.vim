" ---- Author & Copyright: ---------------------------------------------- {{{1
"
" Author:      Christian J. Robinson <infynity@onewest.net>
" URL:         http://www.infynity.spodzone.com/vim/HTML/
" Last Change: March 12, 2007
" Version:     0.25.2
"
" Original Author: Doug Renze  (See below.)
"
" I am going to assume I can put this entirely under the GPL, as the original
" author used the phrase "freely-distributable and freely-modifiable".
"
" Original Copyright should probably go to Doug Renze, my changes and
" additions are Copyrighted by me, on the dates marked in the ChangeLog.
"
" ----------------------------------------------------------------------------
"
" This program is free software; you can redistribute it and/or modify it
" under the terms of the GNU General Public License as published by the Free
" Software Foundation; either version 2 of the License, or (at your option)
" any later version.
"
" This program is distributed in the hope that it will be useful, but WITHOUT
" ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
" FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
" more details.
"
" Comments, questions or bug reports can be sent to infynity@onewest.net
" Make sure to say that your message is regarding the HTML.vim macros.  Also,
" I wouldn't mind knowing how you got a copy.
"
" ---- Original Author's Notes: ----------------------------------------------
"
" HTML Macros
"        I wrote these HTML macros for my personal use.  They're
"        freely-distributable and freely-modifiable.
"
"        If you do make any major additions or changes, or even just
"        have a suggestion for improvement, feel free to let me
"        know.  I'd appreciate any suggestions.
"
"        Credit must go to Eric Tilton, Carl Steadman and Tyler
"        Jones for their excellent book "Web Weaving" which was
"        my primary source.
"
"        The home-page for this set of macros is currently
"        located at: http://www.avalon.net/~drenze/vi/HTML-macros.html
"
"        Doug Renze
"        http://www.avalon.net/~drenze/
"        mailto:drenze@avalon.net
"
" ---- TODO: ------------------------------------------------------------ {{{1
" - Under Win32, make a mapping call the user's default browser instead of
"   just ;ie? (:silent!!start rundll32 url.dll,FileProtocolHandler <URL/File>)
" - ;ns mapping for Win32 with "start netscape ..." ?
" ----------------------------------------------------------------------- }}}1
" RCS Information: 
" $Id: HTML.vim,v 1.132 2007/03/12 07:27:09 infynity Exp $

" ---- Initialization: -------------------------------------------------- {{{1

if version < 600
  echoerr "HTML.vim no longer supports Vim versions prior to 6."
  finish
endif

" Save cpoptions and remove some junk that will throw us off (reset at the end
" of the script):
let s:savecpo = &cpoptions
set cpoptions&vim

if ! exists("b:did_html_mappings")
let b:did_html_mappings = 1

setlocal matchpairs+=<:>

" SetIfUnset()  {{{2
"
" Set a global variable if it's not already set.
" Arguments:
"  1 - String:  The variable name.
"  2 - String:  The default value to use, "-" for the null string. 
" Return value:
"  0 - The variable already existed.
"  1 - The variable didn't exist and was set.
function! SetIfUnset(var,val)
  let var=a:var
  if var !~? '^\w:'
    let var = 'g:' . var
  endif
  execute "let varisset = exists(\"" . var . "\")"
  if (varisset == 0)
    if (a:val == "-")
      execute "let " . var . "= \"\""
    else
      execute "let " . var . "= a:val"
    endif
    return 1
  endif
  return 0
endfunction  "}}}2

command! -nargs=+ SetIfUnset call SetIfUnset(<f-args>)

SetIfUnset g:html_bgcolor         #FFFFFF
SetIfUnset g:html_textcolor       #000000
SetIfUnset g:html_linkcolor       #0000EE
SetIfUnset g:html_alinkcolor      #FF0000
SetIfUnset g:html_vlinkcolor      #990066
SetIfUnset g:html_tag_case        uppercase
SetIfUnset g:html_map_leader      ;
SetIfUnset g:html_default_charset iso-8859-1
" No way to know sensible defaults here so just make sure the
" variables are set:
SetIfUnset g:html_authorname  -
SetIfUnset g:html_authoremail -

"call input(&filetype)
if &filetype ==? "xhtml" 
      \ || (exists('g:do_xhtml_mappings') && g:do_xhtml_mappings != 0) 
      \ || (exists('b:do_xhtml_mappings') && b:do_xhtml_mappings != 0)
  let b:do_xhtml_mappings = 1
else
  let b:do_xhtml_mappings = 0
endif

if b:do_xhtml_mappings != 0
  let b:html_tag_case = 'lowercase'
endif

call SetIfUnset('b:html_tag_case', g:html_tag_case)
" ----------------------------------------------------------------------------


" ---- Functions: ------------------------------------------------------- {{{1

" HTMLencodeString()  {{{2
"
" Encode the characters in a string into their HTML &#...; representations.
" Arguments:
"  1 - String:  The string to encode.
" Return value:
"  String:  The encoded string.
function! HTMLencodeString(string)
  let out = ''
  let c   = 0
  let len = strlen(a:string)

  while c < len
    let out = out . '&#' . char2nr(a:string[c]) . ';'
    let c = c + 1
  endwhile

  return out
endfunction

" HTMLmap()  {{{2
"
" Define the HTML mappings with the appropriate case, plus some extra stuff:
" Arguments:
"  1 - String:  Which map command to run.
"  2 - String:  LHS of the map.
"  3 - String:  RHS of the map.
"  4 - Integer: Optional, applies only to visual maps:
"                -1: Don't add any extra special code to the mapping.
"                 0: Mapping enters insert mode.
"               Applies only when filetype indenting is on:
"                 1: re-selects the region, moves down a line, and re-indents.
"                 2: re-selects the region and re-indents.
"                 (Don't use these two arguments for maps that enter insert
"                 mode!)
function! HTMLmap(cmd, map, arg, ...)

  let arg = s:HTMLconvertCase(a:arg)
  if b:do_xhtml_mappings == 0
    let arg = substitute(arg, ' />', '>', 'g')
  endif

  let map = substitute(a:map, "^<lead>\\c", g:html_map_leader, '')

  if a:cmd =~ '^v'
    if a:0 >= 1 && a:1 < 0
      execute a:cmd . " <buffer> <silent> " . map . " " . arg
    elseif a:0 >= 1 && a:1 >= 1
      execute a:cmd . " <buffer> <silent> " . map . " <C-C>:call <SID>TO(0)<CR>gv" . arg
        \ . ":call <SID>TO(1)<CR>m':call <SID>HTMLreIndent(line(\"'<\"), line(\"'>\"), " . a:1 . ")<CR>``"
    elseif a:0 >= 1
      execute a:cmd . " <buffer> <silent> " . map . " <C-C>:call <SID>TO(0)<CR>gv" . arg
        \ . "<C-O>:call <SID>TO(1)<CR>"
    else
      execute a:cmd . " <buffer> <silent> " . map . " <C-C>:call <SID>TO(0)<CR>gv" . arg
        \ . ":call <SID>TO(1)<CR>"
    endif
  else
    execute a:cmd . " <buffer> <silent> " . map . " " . arg
  endif

endfunction

" HTMLmapo()  {{{2
"
" Define a map that takes an operator to its corresponding visual mode
" mapping:
" Arguments:
" 1 - String:  The mapping.
" 2 - Boolean: Whether to enter insert mode after the mapping has executed.
function! HTMLmapo(map, insert)
  if v:version < 700
    return
  endif

  let map = substitute(a:map, "^<lead>", g:html_map_leader, '')

  execute 'nnoremap <buffer> <silent> ' . map
    \ . " :let b:htmltagaction='" . map . "'<CR>"
    \ . ":let b:htmltaginsert=" . a:insert . "<CR>"
    \ . ':set operatorfunc=<SID>HTMLwrapRange<CR>g@'
endfunction

" s:HTMLwrapRange()  {{{2
" Function set in 'operatorfunc' for mappings that take an operator:
function! s:HTMLwrapRange(type)
  let sel_save = &selection
  let &selection = "inclusive"

  if a:type == 'line'
    exe "normal `[V`]" . b:htmltagaction
  elseif a:type == 'block'
    exe "normal `[\<C-V>`]" . b:htmltagaction
  else
    exe "normal `[v`]" . b:htmltagaction
  endif

  let &selection = sel_save

  if b:htmltaginsert == 1
    exe "normal \<Right>"
    startinsert
  endif

  " Leave these set so .-repeating of operator mappings works:
  "unlet b:htmltagaction b:htmltaginsert
endfunction

" s:TO()  {{{2
" Used to make sure the 'showmatch' and 'indentexpr' options are off
" temporarily to prevent the visual mappings from causing a (visual)bell or
" inserting improperly:
" Arguments:
"  1 - Integer: 0 - Turn options off.
"               1 - Turn options back on, if they were on before.
function! s:TO(s)
  if a:s == 0
    let s:savesm=&sm | let &l:sm=0
    let s:saveinde=&inde | let &l:inde=''
  else
    let &l:sm=s:savesm | unlet s:savesm
    let &l:inde=s:saveinde | unlet s:saveinde
  endif
endfunction

" s:HTMLconvertCase()  {{{2
"
" Convert special regions in a string to the appropriate case determined by
" b:html_tag_case
" Arguments:
"  1 - String: The string with the regions to convert surrounded by [{...}].
" Return Value:
"  The converted string.
function! s:HTMLconvertCase(str)
  if (! exists('b:html_tag_case')) || b:html_tag_case =~? 'u\(pper\(case\)\?\)\?' || b:html_tag_case == ''
    let str = substitute(a:str, '\[{\(.\{-}\)}\]', '\U\1', 'g')
  elseif b:html_tag_case =~? 'l\(ower\(case\)\?\)\?'
    let str = substitute(a:str, '\[{\(.\{-}\)}\]', '\L\1', 'g')
  else
    echohl WarningMsg
    echomsg "b:html_tag_case = '" . b:html_tag_case . "' invalid, overriding to 'upppercase'."
    echohl None
    let b:html_tag_case = 'uppercase'
    let str = s:HTMLconvertCase(a:str)
  endif
  return str
endfunction

" s:HTMLreIndent()  {{{2
"
" Re-indent a region.  (Usually called by HTMLmap.)
"  Nothing happens if filetype indenting isn't enabled.
" Arguments:
"  1 - Integer: Start of region.
"  2 - Integer: End of region.
"  3 - Integer: 1: Add an extra line below the region to re-indent.
"               *: Don't add an extra line.
function! s:HTMLreIndent(first, last, extraline)
  " To find out if filetype indenting is enabled:
  let save_register = @x
  redir @x | silent! filetype | redir END
  let filetype_output = @x
  let @x = save_register

  if filetype_output !~ "indent:ON"
    return
  endif

  " Make sure the range is in the proper order:
  if a:last >= a:first
    let firstline = a:first
    let lastline = a:last
  else
    let lastline = a:first
    let firstline = a:last
  endif

  " Make sure the full region to be re-indendted is included:
  if a:extraline == 1
    if firstline == lastline
      let lastline = lastline + 2
    else
      let lastline = lastline + 1
    endif
  endif

  exe firstline . ',' . lastline . 'norm =='
endfunction

" HTMLnextInsertPoint()  {{{2
"
" Position the cursor at the next point in the file that needs data.
" Arguments:
"  1 - Character: Optional, the mode the function is being called from. 'n'
"                 for normal, 'i' for insert.  If 'i' is used the function
"                 enables an extra feature where if the cursor is on the start
"                 of a closing tag it places the cursor after the tag.
"                 Default is 'n'.
" Return value:
"  None.
" Known problems:
"  Due to the necessity of running the search twice (why doesn't Vim support
"  cursor offset positioning in search()?) this function
"    a) won't ever position the cursor on an "empty" tag that starts on the
"       first character of the first line of the buffer
"    b) won't let the cursor "escape" from an "empty" tag that it can match on
"       the first line of the buffer when the cursor is on the first line and
"       tab is successively pressed
function! HTMLnextInsertPoint(...)
  let saveerrmsg = v:errmsg
  let v:errmsg = ""
  let byteoffset = line2byte(line('.')) + col('.') - 1

  " Tab in insert mode on the beginning of a closing tag jumps us to
  " after the tag:
  if a:0 >= 1 && a:1 == 'i' 
    if strpart(getline(line('.')), col('.') - 1, 2) == '</'
      normal %
      let done = 1
    elseif strpart(getline(line('.')), col('.') - 1, 4) =~ ' *-->'
      normal f>
      let done = 1
    else
      let done = 0
    endif

    if done == 1
      if col('.') == col('$') - 1
        startinsert!
      else
        normal l
      endif

      return
    endif
  endif


  normal 0

  " Running the search twice is inefficient, but it squelches error
  " messages and the second search puts my cursor where it's needed...
  if search('<\([^ <>]\+\)\_[^<>]*>\( \|\n *\)\{0,2}<\/\1>\|<\_[^<>]*""\_[^<>]*>\|<!--\( \|\n *\)\{0,2}-->', 'w') == 0
    if byteoffset == -1
      go 1
    else
      execute ':go ' . byteoffset
    endif
  else
    normal 0
    silent! execute ':go ' . line2byte(line('.')) + col('.') - 2
    exe 'silent normal! /<\([^ <>]\+\)\_[^<>]*>\(\n *\)\{0,2}<\/\1>\|<\_[^<>]*""\_[^<>]*>\|<!--\( \|\n *\)\{0,2}-->/;/>\(\n *\)\{0,2}<\|""\|<!--\( \|\n *\)\{0,2}-->/e' . "\<CR>"

    " Handle cursor positioning for comments and/or open+close tags spanning
    " multiple lines:
    if getline('.') =~ '<!-- \+-->'
      exe "normal F\<space>"
    elseif getline('.') =~ '^ *-->' && getline(line('.')-1) =~ '<!-- *$'
      normal 0
      normal t-
    elseif getline('.') =~ '^ *-->' && getline(line('.')-1) =~ '^ *$'
      normal k$
    elseif getline('.') =~ '^ *<\/[^<>]\+>' && getline(line('.')-1) =~ '^ *$'
      normal k$
    endif

    call histdel('search', -1)
    let @/ = histget('search', -1)
  endif

  let v:errmsg = saveerrmsg

endfunction

" s:tag()  {{{2
" 
" Causes certain tags (such as bold, italic, underline) to be closed then
" opened rather than opened then closed where appropriate, if syntax
" highlighting is on.
"
" Arguments:
"  1 - String: The tag name.
"  2 - Character: The mode: 
"                  'i' - Insert mode
"                  'v' - Visual mode
" Return value:
"  The string to be executed to insert the tag.
let s:HTMLtags{'i'}{'i'}{'o'} = "<[{I></I}]>\<ESC>hhhi"
let s:HTMLtags{'i'}{'i'}{'c'} = "<[{/I><I}]>\<ESC>hhi"
let s:HTMLtags{'i'}{'v'}{'o'} = "`>a</[{I}]>\<C-O>`<<[{I}]>"
let s:HTMLtags{'i'}{'v'}{'c'} = "`>a<[{I}]>\<C-O>`<</[{I}]>"
let s:HTMLtags{'b'}{'i'}{'o'} = "<[{B></B}]>\<ESC>hhhi"
let s:HTMLtags{'b'}{'i'}{'c'} = "<[{/B><B}]>\<ESC>hhi"
let s:HTMLtags{'b'}{'v'}{'o'} = "`>a</[{B}]>\<C-O>`<<[{B}]>"
let s:HTMLtags{'b'}{'v'}{'c'} = "`>a<[{B}]>\<C-O>`<</[{B}]>"
let s:HTMLtags{'u'}{'i'}{'o'} = "<[{U></U}]>\<ESC>hhhi"
let s:HTMLtags{'u'}{'i'}{'c'} = "<[{/U><U}]>\<ESC>hhi"
let s:HTMLtags{'u'}{'v'}{'o'} = "`>a</[{U}]>\<C-O>`<<[{U}]>"
let s:HTMLtags{'u'}{'v'}{'c'} = "`>a<[{U}]>\<C-O>`<</[{U}]>"
let s:HTMLtags{'comment'}{'i'}{'o'} = "<!--  -->\<ESC>Bhi"
let s:HTMLtags{'comment'}{'i'}{'c'} = " --><!-- \<ESC>Bhi"
let s:HTMLtags{'comment'}{'v'}{'o'} = "`>a -->\<C-O>`<<!-- "
let s:HTMLtags{'comment'}{'v'}{'c'} = "`>a<!-- \<C-O>`< -->"
let s:HTMLtags{'strong'}{'i'}{'o'} = "<[{STRONG></STRONG}]>\<ESC>bhhi"
let s:HTMLtags{'strong'}{'i'}{'c'} = "<[{/STRONG><STRONG}]>\<ESC>bhi"
let s:HTMLtags{'strong'}{'v'}{'o'} = "`>a</[{STRONG}]>\<C-O>`<<[{STRONG}]>"
let s:HTMLtags{'strong'}{'v'}{'c'} = "`>a<[{STRONG}]>\<C-O>`<</[{STRONG}]>"
function! s:tag(tag, mode)
  let attr=synIDattr(synID(line('.'), col('.') - 1, 1), "name")
  if ( a:tag == 'i' && attr =~? 'italic' )
        \ || ( a:tag == 'b' && attr =~? 'bold' )
        \ || ( a:tag == 'strong' && attr =~? 'bold' )
        \ || ( a:tag == 'u' && attr =~? 'underline' )
        \ || ( a:tag == 'comment' && attr =~? 'comment' )
    let ret=s:HTMLconvertCase(s:HTMLtags{a:tag}{a:mode}{'c'})
  else
    let ret=s:HTMLconvertCase(s:HTMLtags{a:tag}{a:mode}{'o'})
  endif
  return ret
endfunction

" s:HTMLdetectCharset()  {{{2
" 
" Detects the HTTP-EQUIV Content-Type charset based on Vim's current
" encoding/fileencoding.
"
" Arguments:
"  None
" Return value:
"  The value for the Content-Type charset based on 'fileencoding' or
"  'encoding'.
function! s:HTMLdetectCharset()

  if exists("g:html_charset")
    return g:html_charset
  endif

  " TODO: This table needs to be expanded:
  let charsets{'latin1'}    = 'iso-8859-1'
  let charsets{'utf_8'}     = 'UTF-8'
  let charsets{'utf_16'}    = 'UTF-16'
  let charsets{'shift_jis'} = 'Shift_JIS'
  let charsets{'euc_jp'}    = 'EUC-JP'
  let charsets{'cp950'}     = 'Big5'
  let charsets{'big5'}      = 'Big5'

  if &fileencoding != ''
    let enc=tolower(&fileencoding)
  else
    let enc=tolower(&encoding)
  endif

  " The iso-8859-* encodings are valid for the Content-Type charset header:
  if enc =~? '^iso-8859-'
    return enc
  endif

  let enc=substitute(enc, '\W', '_', 'g')

  if charsets{enc} != ''
    return charsets{enc}
  endif

  return g:html_default_charset 
endfunction

" }}}2

" ----------------------------------------------------------------------------


" ---- Misc. Mappings: -------------------------------------------------- {{{1

" Make it convenient to use ; as "normal":
if g:html_map_leader == ';'
  call HTMLmap("inoremap", ";;", ";")
  call HTMLmap("vnoremap", ";;", ";", -1)
  call HTMLmap("nnoremap", ";;", ";")
endif

if ! exists('g:no_html_tab_mapping')
  " Allow hard tabs to be inserted:
  call HTMLmap("inoremap", "<lead><tab>", "<tab>")
  call HTMLmap("nnoremap", "<lead><tab>", "<tab>")

  " Tab takes us to a (hopefully) reasonable next insert point:
  call HTMLmap("inoremap", "<tab>", "<C-O>:call HTMLnextInsertPoint('i')<CR>")
  call HTMLmap("nnoremap", "<tab>", ":call HTMLnextInsertPoint('n')<CR>")
  call HTMLmap("vnoremap", "<tab>", "<C-C>:call HTMLnextInsertPoint('n')<CR>", -1)
else
  call HTMLmap("inoremap", "<lead><tab>", "<C-O>:call HTMLnextInsertPoint('i')<CR>")
  call HTMLmap("nnoremap", "<lead><tab>", ":call HTMLnextInsertPoint('n')<CR>")
  call HTMLmap("vnoremap", "<lead><tab>", "<C-C>:call HTMLnextInsertPoint('n')<CR>", -1)
endif

" Update an image tag's WIDTH & HEIGHT attributes (experimental!):
runtime! MangleImageTag.vim 
if exists("*MangleImageTag")
  call HTMLmap("nnoremap", "<lead>mi", ":call MangleImageTag()<CR>")
  call HTMLmap("inoremap", "<lead>mi", "<C-O>:call MangleImageTag()<CR>")
endif

" ----------------------------------------------------------------------------


" ---- Template Creation Stuff: ----------------------------------------- {{{1

call HTMLmap("nnoremap", "<lead>html", ":if (HTMLtemplate()) \\| startinsert \\| endif<CR>")

let s:internal_html_template=
  \"<[{HTML}]>\n" .
  \" <[{HEAD}]>\n\n" .
  \"  <[{TITLE></TITLE}]>\n\n" .
  \"  <[{META NAME}]=\"Generator\" [{CONTENT}]=\"vim (Vi IMproved editor; http://www.vim.org/)\" />\n" .
  \"  <[{META NAME}]=\"Author\" [{CONTENT}]=\"%authorname%\" />\n" .
  \"  <[{META NAME}]=\"Copyright\" [{CONTENT}]=\"Copyright (C) %date% %authorname%\" />\n" .
  \"  <[{LINK REV}]=\"made\" [{HREF}]=\"mailto:%authoremail%\" />\n\n" .
  \" </[{HEAD}]>\n" .
  \" <[{BODY BGCOLOR}]=\"%bgcolor%\"" .
    \" [{TEXT}]=\"%textcolor%\"" .
    \" [{LINK}]=\"%linkcolor%\"" .
    \" [{ALINK}]=\"%alinkcolor%\"" .
    \" [{VLINK}]=\"%vlinkcolor%\">\n\n" .
  \"  <[{H1 ALIGN=\"CENTER\"></H1}]>\n\n" .
  \"  <[{P}]>\n" .
  \"  </[{P}]>\n\n" .
  \"  <[{HR WIDTH}]=\"75%\" />\n\n" .
  \"  <[{P}]>\n" .
  \"  Last Modified: <[{I}]>%date%</[{I}]>\n" .
  \"  </[{P}]>\n\n" .
  \"  <[{ADDRESS}]>\n" .
  \"   <[{A HREF}]=\"mailto:%authoremail%\">%authorname% &lt;%authoremail%&gt;</[{A}]>\n" .
  \"  </[{ADDRESS}]>\n" .
  \" </[{BODY}]>\n" .
  \"</[{HTML}]>"

let b:internal_html_template = s:HTMLconvertCase(s:internal_html_template)

if b:do_xhtml_mappings != 0
  let b:internal_html_template = "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\"\n" .
        \ " \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">\n" .
        \ b:internal_html_template
else
  let b:internal_html_template = substitute(b:internal_html_template, ' />', '>', 'g')
endif

" HTMLtemplate()  {{{2
"
" Determine whether to insert the HTML template:
" Arguments:
"  None
" Return Value:
"  0 - The cursor is not on an insert point.
"  1 - The cursor is on an insert point.
function! HTMLtemplate()
  if (line('$') == 1 && getline(1) == "")
    return s:HTMLtemplate2()
  else
    let YesNoOverwrite = confirm("Non-empty file.\nInsert template anyway?", "&Yes\n&No\n&Overwrite", 2, "W")
    if (YesNoOverwrite == 1)
      return s:HTMLtemplate2()
    elseif (YesNoOverwrite == 3)
      execute "1,$delete"
      return s:HTMLtemplate2()
    endif
  endif
  return 0
endfunction  " }}}2

" s:HTMLtemplate2()  {{{2
"
" Actually insert the HTML template:
" Arguments:
"  None
" Return Value:
"  0 - The cursor is not on an insert point.
"  1 - The cursor is on an insert point.
function! s:HTMLtemplate2()

  if g:html_authoremail != ''
    let g:html_authoremail_encoded = HTMLencodeString(g:html_authoremail)
  else
    let g:html_authoremail_encoded = ''
  endif

  let template = ''

  if (exists('b:html_template') && b:html_template != '')
    let template = b:html_template
  elseif (exists('g:html_template') && g:html_template != '')
    let template = g:html_template
  endif

  if template != ''
    if filereadable(expand(template))
      silent execute "0read " . template
    else
      echohl ErrorMsg
      echomsg "Unable to insert template file: " . template
      echomsg "Either it doesn't exist or it isn't readable."
      echohl None
      return 0
    endif
  else
    0put =b:internal_html_template
  endif

  if getline('$') =~ '^\s*$'
    $delete
  endif

  " Replace the various tokens with appropriate values:
  silent! %s/\C%authorname%/\=g:html_authorname/g
  silent! %s/\C%authoremail%/\=g:html_authoremail_encoded/g
  silent! %s/\C%bgcolor%/\=g:html_bgcolor/g
  silent! %s/\C%textcolor%/\=g:html_textcolor/g
  silent! %s/\C%linkcolor%/\=g:html_linkcolor/g
  silent! %s/\C%alinkcolor%/\=g:html_alinkcolor/g
  silent! %s/\C%vlinkcolor%/\=g:html_vlinkcolor/g
  silent! %s/\C%date%/\=strftime('%B %d, %Y')/g
  "silent! %s/\C%date\s*\([^%]\{-}\)\s*%/\=strftime(substitute(submatch(1),'\\\@<!!','%','g'))/g
  silent! %s/\C%date\s*\(\%(\\%\|[^%]\)\{-}\)\s*%/\=strftime(substitute(substitute(submatch(1),'\\%','%%','g'),'\\\@<!!','%','g'))/g
  silent! %s/\C%time%/\=strftime('%r %Z')/g
  silent! %s/\C%time12%/\=strftime('%r %Z')/g
  silent! %s/\C%time24%/\=strftime('%T')/g
  silent! %s/\C%charset%/\=<SID>HTMLdetectCharset()/g

  go 1

  call HTMLnextInsertPoint('n')
  if getline('.')[col('.') - 2] . getline('.')[col('.') - 1] == '><'
        \ || (getline('.') =~ '^\s*$' && line('.') != 1)
    return 1
  else
    return 0
  endif

endfunction  " }}}2

" ----------------------------------------------------------------------------

" ---- General Markup Tag Mappings: ------------------------------------- {{{1

"       SGML Doctype Command
"call HTMLmap("nnoremap", "<lead>4", "1GO<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0//EN\"><ESC>``")

"       SGML Doctype Command
if b:do_xhtml_mappings == 0
  " Transitional HTML (Looser):
  call HTMLmap("nnoremap", "<lead>4", ":call append(0, '<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\"') \\\| call append(1, ' \"http://www.w3.org/TR/html4/loose.dtd\">')<CR>")
  " Strict HTML:
  call HTMLmap("nnoremap", "<lead>s4", ":call append(0, '<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01//EN\"') \\\| call append(1, ' \"http://www.w3.org/TR/html4/strict.dtd\">')<CR>")
else
  " Transitional XHTML (Looser):
  call HTMLmap("nnoremap", "<lead>4", ":call append(0, '<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\"') \\\| call append(1, ' \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">')<CR>")
  " Strict XHTML:
  call HTMLmap("nnoremap", "<lead>s4", ":call append(0, '<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\"') \\\| call append(1, ' \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">')<CR>")
endif
call HTMLmap("imap", "<lead>4", "<C-O>" . g:html_map_leader . "4")
call HTMLmap("imap", "<lead>s4", "<C-O>" . g:html_map_leader . "s4")

"       Content-Type META tag
call HTMLmap("inoremap", "<lead>ct", "<[{META HTTP-EQUIV}]=\"Content-Type\" [{CONTENT}]=\"text/html; charset=<C-R>=<SID>HTMLdetectCharset()<CR>\" />")

"       Comment Tag
call HTMLmap("inoremap", "<lead>cm", "<C-R>=<SID>tag('comment','i')<CR>")
" Visual mapping:
call HTMLmap("vnoremap", "<lead>cm", "<C-C>:execute \"normal \" . <SID>tag('comment','v')<CR>", 2)
" Motion mapping:
call HTMLmapo('<lead>cm', 0)

"       A HREF  Anchor Hyperlink        HTML 2.0
call HTMLmap("inoremap", "<lead>ah", "<[{A HREF=\"\"></A}]><ESC>F\"i")
" Visual mappings:
call HTMLmap("vnoremap", "<lead>ah", "<ESC>`>a</[{A}]><C-O>`<<[{A HREF}]=\"\"><C-O>F\"", 0)
call HTMLmap("vnoremap", "<lead>aH", "<ESC>`>a\"></[{A}]><C-O>`<<[{A HREF}]=\"<C-O>f<", 0)
" Motion mappings:
call HTMLmapo('<lead>ah', 1)
call HTMLmapo('<lead>aH', 1)

"       A HREF  Anchor Hyperlink, with TARGET=""
call HTMLmap("inoremap", "<lead>at", "<[{A HREF=\"\" TARGET=\"\"></A}]><ESC>3F\"i")
" Visual mappings:
call HTMLmap("vnoremap", "<lead>at", "<ESC>`>a</[{A}]><C-O>`<<[{A HREF=\"\" TARGET}]=\"\"><C-O>3F\"", 0)
call HTMLmap("vnoremap", "<lead>aT", "<ESC>`>a\" [{TARGET=\"\"></A}]><C-O>`<<[{A HREF}]=\"<C-O>3f\"", 0)
" Motion mappings:
call HTMLmapo('<lead>at', 1)
call HTMLmapo('<lead>aT', 1)

"       A NAME  Named Anchor            HTML 2.0
call HTMLmap("inoremap", "<lead>an", "<[{A NAME=\"\"></A}]><ESC>F\"i")
" Visual mappings:
call HTMLmap("vnoremap", "<lead>an", "<ESC>`>a</[{A}]><C-O>`<<[{A NAME}]=\"\"><C-O>F\"", 0)
call HTMLmap("vnoremap", "<lead>aN", "<ESC>`>a\"></[{A}]><C-O>`<<[{A NAME}]=\"<C-O>f<", 0)
" Motion mappings:
call HTMLmapo('<lead>an', 1)
call HTMLmapo('<lead>aN', 1)

"       ABBR  Abbreviation              HTML 4.0
call HTMLmap("inoremap", "<lead>ab", "<[{ABBR TITLE=\"\"></ABBR}]><ESC>F\"i")
" Visual mappings:
call HTMLmap("vnoremap", "<lead>ab", "<ESC>`>a</[{ABBR}]><C-O>`<<[{ABBR TITLE}]=\"\"><C-O>F\"", 0)
call HTMLmap("vnoremap", "<lead>aB", "<ESC>`>a\"></[{ABBR}]><C-O>`<<[{ABBR TITLE}]=\"<C-O>f<", 0)
" Motion mappings:
call HTMLmapo('<lead>ab', 1)
call HTMLmapo('<lead>aB', 1)

"       ACRONYM                         HTML 4.0
call HTMLmap("inoremap", "<lead>ac", "<[{ACRONYM TITLE=\"\"></ACRONYM}]><ESC>F\"i")
" Visual mappings:
call HTMLmap("vnoremap", "<lead>ac", "<ESC>`>a</[{ACRONYM}]><C-O>`<<[{ACRONYM TITLE}]=\"\"><C-O>F\"", 0)
call HTMLmap("vnoremap", "<lead>aC", "<ESC>`>a\"></[{ACRONYM}]><C-O>`<<[{ACRONYM TITLE}]=\"<C-O>f<", 0)
" Motion mappings:
call HTMLmapo('<lead>ac', 1)
call HTMLmapo('<lead>aC', 1)

"       ADDRESS                         HTML 2.0
call HTMLmap("inoremap", "<lead>ad", "<[{ADDRESS></ADDRESS}]><ESC>bhhi")
" Visual mapping:
call HTMLmap("vnoremap", "<lead>ad", "<ESC>`>a</[{ADDRESS}]><C-O>`<<[{ADDRESS}]><ESC>", 2)
" Motion mapping:
call HTMLmapo('<lead>ad', 0)

"       B       Boldfaced Text          HTML 2.0
call HTMLmap("inoremap", "<lead>bo", "<C-R>=<SID>tag('b','i')<CR>")
" Visual mapping:
call HTMLmap("vnoremap", "<lead>bo", "<C-C>:execute \"normal \" . <SID>tag('b','v')<CR>", 2)
" Motion mapping:
call HTMLmapo('<lead>bo', 0)

"       BASE                            HTML 2.0        HEADER
call HTMLmap("inoremap", "<lead>bh", "<[{BASE HREF}]=\"\" /><ESC>F\"i")
" Visual mapping:
call HTMLmap("vnoremap", "<lead>bh", "<ESC>`>a\" /><C-O>`<<[{BASE HREF}]=\"<ESC>", 2)
" Motion mapping:
call HTMLmapo('<lead>bh', 0)

"       BIG                             HTML 3.0
call HTMLmap("inoremap", "<lead>bi", "<[{BIG></BIG}]><ESC>bhhi")
" Visual mapping:
call HTMLmap("vnoremap", "<lead>bi", "<ESC>`>a</[{BIG}]><C-O>`<<[{BIG}]><ESC>")
" Motion mapping:
call HTMLmapo('<lead>bi', 0)

"       BLOCKQUOTE                      HTML 2.0
call HTMLmap("inoremap", "<lead>bl", "<[{BLOCKQUOTE}]><CR></[{BLOCKQUOTE}]><ESC>O")
" Visual mapping:
call HTMLmap("vnoremap", "<lead>bl", "<ESC>`>a<CR></[{BLOCKQUOTE}]><C-O>`<<[{BLOCKQUOTE}]><CR><ESC>", 1)
" Motion mapping:
call HTMLmapo('<lead>bl', 0)

"       BODY                            HTML 2.0
call HTMLmap("inoremap", "<lead>bd", "<[{BODY}]><CR></[{BODY}]><ESC>O")
" Visual mapping:
call HTMLmap("vnoremap", "<lead>bd", "<ESC>`>a<CR></[{BODY}]><C-O>`<<[{BODY}]><CR><ESC>", 1)
" Motion mapping:
call HTMLmapo('<lead>bd', 0)

"       BR      Line break              HTML 2.0
call HTMLmap("inoremap", "<lead>br", "<[{BR}] />")

"       CENTER                          NETSCAPE
call HTMLmap("inoremap", "<lead>ce", "<[{CENTER></CENTER}]><ESC>bhhi")
" Visual mapping:
call HTMLmap("vnoremap", "<lead>ce", "<ESC>`>a</[{CENTER}]><C-O>`<<[{CENTER}]><ESC>", 2)
" Motion mapping:
call HTMLmapo('<lead>ce', 0)

"       CITE                            HTML 2.0
call HTMLmap("inoremap", "<lead>ci", "<[{CITE></CITE}]><ESC>bhhi")
" Visual mapping:
call HTMLmap("vnoremap", "<lead>ci", "<ESC>`>a</[{CITE}]><C-O>`<<[{CITE}]><ESC>", 2)
" Motion mapping:
call HTMLmapo('<lead>ci', 0)

"       CODE                            HTML 2.0
call HTMLmap("inoremap", "<lead>co", "<[{CODE></CODE}]><ESC>bhhi")
" Visual mapping:
call HTMLmap("vnoremap", "<lead>co", "<ESC>`>a</[{CODE}]><C-O>`<<[{CODE}]><ESC>", 2)
" Motion mapping:
call HTMLmapo('<lead>co', 0)

"       DEFINITION LIST COMPONENTS      HTML 2.0
"               DL      Definition List
"               DT      Definition Term
"               DD      Definition Body
call HTMLmap("inoremap", "<lead>dl", "<[{DL}]><CR></[{DL}]><ESC>O")
" Visual mappings:
call HTMLmap("vnoremap", "<lead>dl", "<ESC>`>a<CR></[{DL}]><C-O>`<<[{DL}]><CR><ESC>", 1)
call HTMLmap("inoremap", "<lead>dt", "<[{DT}] />")
call HTMLmap("inoremap", "<lead>dd", "<[{DD}] />")
" Motion mapping:
call HTMLmapo('<lead>dl', 0)

"       DEL     Deleted Text            HTML 3.0
call HTMLmap("inoremap", "<lead>de", "<lt>[{DEL></DEL}]><ESC>bhhi")
" Visual mapping:
call HTMLmap("vnoremap", "<lead>de", "<ESC>`>a</[{DEL}]><C-O>`<<lt>[{DEL}]><ESC>")
" Motion mapping:
call HTMLmapo('<lead>de', 0)

"       DFN     Defining Instance       HTML 3.0
call HTMLmap("inoremap", "<lead>df", "<[{DFN></DFN}]><ESC>bhhi")
" Visual mapping:
call HTMLmap("vnoremap", "<lead>df", "<ESC>`>a</[{DFN}]><C-O>`<<[{DFN}]><ESC>", 2)
" Motion mapping:
call HTMLmapo('<lead>df', 0)

"       DIR     Directory List          HTML 3.0
"imap ;di <DIR><CR></DIR><ESC>O

"       DIV     Document Division       HTML 3.0
call HTMLmap("inoremap", "<lead>dv", "<[{DIV}]><CR></[{DIV}]><ESC>O")
" Visual mapping:
call HTMLmap("vnoremap", "<lead>dv", "<ESC>`>a<CR></[{DIV}]><C-O>`<<[{DIV}]><CR><ESC>", 1)
" Motion mapping:
call HTMLmapo('<lead>dv', 0)

"       SPAN    Delimit Arbitrary Text  HTML 4.0
call HTMLmap("inoremap", "<lead>sn", "<[{SPAN></SPAN}]><ESC>bhhi")
" Visual mapping:
call HTMLmap("vnoremap", "<lead>sn", "<ESC>`>a</[{SPAN}]><C-O>`<<[{SPAN}]><ESC>", 2)
" Motion mapping:
call HTMLmapo('<lead>sn', 0)

"       EM      Emphasize               HTML 2.0
call HTMLmap("inoremap", "<lead>em", "<[{EM></EM}]><ESC>bhhi")
" Visual mapping:
call HTMLmap("vnoremap", "<lead>em", "<ESC>`>a</[{EM}]><C-O>`<<[{EM}]><ESC>", 2)
" Motion mapping:
call HTMLmapo('<lead>em', 0)

"       FONT                            NETSCAPE
call HTMLmap("inoremap", "<lead>fo", "<[{FONT SIZE=\"\"></FONT}]><ESC>F\"i")
call HTMLmap("inoremap", "<lead>fc", "<[{FONT COLOR=\"\"></FONT}]><ESC>F\"i")
" Visual mappings:
call HTMLmap("vnoremap", "<lead>fo", "<ESC>`>a</[{FONT}]><C-O>`<<[{FONT SIZE}]=\"\"><C-O>F\"", 0)
call HTMLmap("vnoremap", "<lead>fc", "<ESC>`>a</[{FONT}]><C-O>`<<[{FONT COLOR}]=\"\"><C-O>F\"", 0)
" Motion mappings:
call HTMLmapo('<lead>fo', 1)
call HTMLmapo('<lead>fc', 1)

"       HEADERS, LEVELS 1-6             HTML 2.0
call HTMLmap("inoremap", "<lead>h1", "<[{H1}]></[{H1}]><ESC>bhhi")
call HTMLmap("inoremap", "<lead>h2", "<[{H2}]></[{H2}]><ESC>bhhi")
call HTMLmap("inoremap", "<lead>h3", "<[{H3}]></[{H3}]><ESC>bhhi")
call HTMLmap("inoremap", "<lead>h4", "<[{H4}]></[{H4}]><ESC>bhhi")
call HTMLmap("inoremap", "<lead>h5", "<[{H5}]></[{H5}]><ESC>bhhi")
call HTMLmap("inoremap", "<lead>h6", "<[{H6}]></[{H6}]><ESC>bhhi")
call HTMLmap("inoremap", "<lead>H1", "<[{H1 ALIGN=\"CENTER}]\"></[{H1}]><ESC>bhhi")
call HTMLmap("inoremap", "<lead>H2", "<[{H2 ALIGN=\"CENTER}]\"></[{H2}]><ESC>bhhi")
call HTMLmap("inoremap", "<lead>H3", "<[{H3 ALIGN=\"CENTER}]\"></[{H3}]><ESC>bhhi")
call HTMLmap("inoremap", "<lead>H4", "<[{H4 ALIGN=\"CENTER}]\"></[{H4}]><ESC>bhhi")
call HTMLmap("inoremap", "<lead>H5", "<[{H5 ALIGN=\"CENTER}]\"></[{H5}]><ESC>bhhi")
call HTMLmap("inoremap", "<lead>H6", "<[{H6 ALIGN=\"CENTER}]\"></[{H6}]><ESC>bhhi")
" Visual mappings:
call HTMLmap("vnoremap", "<lead>h1", "<ESC>`>a</[{H1}]><C-O>`<<[{H1}]><ESC>", 2)
call HTMLmap("vnoremap", "<lead>h2", "<ESC>`>a</[{H2}]><C-O>`<<[{H2}]><ESC>", 2)
call HTMLmap("vnoremap", "<lead>h3", "<ESC>`>a</[{H3}]><C-O>`<<[{H3}]><ESC>", 2)
call HTMLmap("vnoremap", "<lead>h4", "<ESC>`>a</[{H4}]><C-O>`<<[{H4}]><ESC>", 2)
call HTMLmap("vnoremap", "<lead>h5", "<ESC>`>a</[{H5}]><C-O>`<<[{H5}]><ESC>", 2)
call HTMLmap("vnoremap", "<lead>h6", "<ESC>`>a</[{H6}]><C-O>`<<[{H6}]><ESC>", 2)
call HTMLmap("vnoremap", "<lead>H1", "<ESC>`>a</[{H1}]><C-O>`<<[{H1 ALIGN=\"CENTER}]\"><ESC>", 2)
call HTMLmap("vnoremap", "<lead>H2", "<ESC>`>a</[{H2}]><C-O>`<<[{H2 ALIGN=\"CENTER}]\"><ESC>", 2)
call HTMLmap("vnoremap", "<lead>H3", "<ESC>`>a</[{H3}]><C-O>`<<[{H3 ALIGN=\"CENTER}]\"><ESC>", 2)
call HTMLmap("vnoremap", "<lead>H4", "<ESC>`>a</[{H4}]><C-O>`<<[{H4 ALIGN=\"CENTER}]\"><ESC>", 2)
call HTMLmap("vnoremap", "<lead>H5", "<ESC>`>a</[{H5}]><C-O>`<<[{H5 ALIGN=\"CENTER}]\"><ESC>", 2)
call HTMLmap("vnoremap", "<lead>H6", "<ESC>`>a</[{H6}]><C-O>`<<[{H6 ALIGN=\"CENTER}]\"><ESC>", 2)
" Motion mappings:
call HTMLmapo("<lead>h1", 0)
call HTMLmapo("<lead>h2", 0)
call HTMLmapo("<lead>h3", 0)
call HTMLmapo("<lead>h4", 0)
call HTMLmapo("<lead>h5", 0)
call HTMLmapo("<lead>h6", 0)
call HTMLmapo("<lead>H1", 0)
call HTMLmapo("<lead>H2", 0)
call HTMLmapo("<lead>H3", 0)
call HTMLmapo("<lead>H4", 0)
call HTMLmapo("<lead>H5", 0)
call HTMLmapo("<lead>H6", 0)

"       HEAD                            HTML 2.0
call HTMLmap("inoremap", "<lead>he", "<[{HEAD}]><CR></[{HEAD}]><ESC>O")
" Visual mapping:
call HTMLmap("vnoremap", "<lead>he", "<ESC>`>a<CR></[{HEAD}]><C-O>`<<[{HEAD}]><CR><ESC>", 1)
" Motion mapping:
call HTMLmapo('<lead>he', 0)

"       HR      Horizontal Rule         HTML 2.0 W/NETSCAPISM
call HTMLmap("inoremap", "<lead>hr", "<[{HR}] />")
"       HR      Horizontal Rule         HTML 2.0 W/NETSCAPISM
call HTMLmap("inoremap", "<lead>Hr", "<[{HR WIDTH}]=\"75%\" />")

"       HTML                            HTML 3.0
call HTMLmap("inoremap", "<lead>ht", "<[{HTML}]><CR></[{HTML}]><ESC>O")
" Visual mapping:
call HTMLmap("vnoremap", "<lead>ht", "<ESC>`>a<CR></[{HTML}]><C-O>`<<[{HTML}]><CR><ESC>", 1)
" Motion mapping:
call HTMLmapo('<lead>ht', 0)

"       I       Italicized Text         HTML 2.0
call HTMLmap("inoremap", "<lead>it", "<C-R>=<SID>tag('i','i')<CR>")
" Visual mapping:
call HTMLmap("vnoremap", "<lead>it", "<C-C>:execute \"normal \" . <SID>tag('i','v')<CR>", 2)
" Motion mapping:
call HTMLmapo('<lead>it', 0)

"       IMG     Image                   HTML 2.0
call HTMLmap("inoremap", "<lead>im", "<[{IMG SRC=\"\" ALT}]=\"\" /><ESC>3F\"i")
" Visual mapping:
call HTMLmap("vnoremap", "<lead>im", "<ESC>`>a\" /><C-O>`<<[{IMG SRC=\"\" ALT}]=\"<C-O>2F\"", 0)
call HTMLmap("vnoremap", "<lead>iM", "<ESC>`>a\" [{ALT}]=\"\" /><C-O>`<<[{IMG SRC}]=\"<C-O>3f\"", 0)
" Motion mapping:
call HTMLmapo('<lead>im', 1)
call HTMLmapo('<lead>iM', 1)

"       INS     Inserted Text           HTML 3.0
call HTMLmap("inoremap", "<lead>in", "<lt>[{INS></INS}]><ESC>bhhi")
" Visual mapping:
call HTMLmap("vnoremap", "<lead>in", "<ESC>`>a</[{INS}]><C-O>`<<lt>[{INS}]><ESC>")
" Motion mapping:
call HTMLmapo('<lead>in', 0)

"       ISINDEX Identifies Index        HTML 2.0
call HTMLmap("inoremap", "<lead>ii", "<[{ISINDEX}] />")

"       KBD     Keyboard Text           HTML 2.0
call HTMLmap("inoremap", "<lead>kb", "<[{KBD></KBD}]><ESC>bhhi")
" Visual mapping:
call HTMLmap("vnoremap", "<lead>kb", "<ESC>`>a</[{KBD}]><C-O>`<<[{KBD}]><ESC>", 2)
" Motion mapping:
call HTMLmapo('<lead>kb', 0)

"       LI      List Item               HTML 2.0
call HTMLmap("inoremap", "<lead>li", "<[{LI}]></[{LI}]><ESC>bhhi")
" Visual mapping:
call HTMLmap("vnoremap", "<lead>li", "<ESC>`>a</[{LI}]><C-O>`<<[{LI}]><ESC>", 2)
" Motion mapping:
call HTMLmapo('<lead>li', 0)

"       LINK                            HTML 2.0        HEADER
call HTMLmap("inoremap", "<lead>lk", "<[{LINK HREF}]=\"\" /><ESC>F\"i")
" Visual mapping:
call HTMLmap("vnoremap", "<lead>lk", "<ESC>`>a\" /><C-O>`<<[{LINK HREF}]=\"<ESC>")
" Motion mapping:
call HTMLmapo('<lead>lk', 0)

"       LH      List Header             HTML 2.0
call HTMLmap("inoremap", "<lead>lh", "<[{LH></LH}]><ESC>bhhi")
" Visual mapping:
call HTMLmap("vnoremap", "<lead>lh", "<ESC>`>a</[{LH}]><C-O>`<<[{LH}]><ESC>", 2)
" Motion mapping:
call HTMLmapo('<lead>lh', 0)

"       MENU                            HTML 2.0
"imap ;mu <MENU><CR></MENU><ESC>O

"       META    Meta Information        HTML 2.0        HEADER
call HTMLmap("inoremap", "<lead>me", "<[{META NAME=\"\" CONTENT}]=\"\" /><ESC>3F\"i")
" Visual mappings:
call HTMLmap("vnoremap", "<lead>me", "<ESC>`>a\" [{CONTENT}]=\"\" /><C-O>`<<[{META NAME}]=\"<C-O>3f\"", 0)
call HTMLmap("vnoremap", "<lead>mE", "<ESC>`>a\" /><C-O>`<<[{META NAME=\"\" CONTENT}]=\"<C-O>2F\"", 0)
" Motion mappings:
call HTMLmapo('<lead>me', 1)
call HTMLmapo('<lead>mE', 1)

"       OL      Ordered List            HTML 3.0
call HTMLmap("inoremap", "<lead>ol", "<[{OL}]><CR></[{OL}]><ESC>O")
" Visual mapping:
call HTMLmap("vnoremap", "<lead>ol", "<ESC>`>a<CR></[{OL}]><C-O>`<<[{OL}]><CR><ESC>", 1)
" Motion mapping:
call HTMLmapo('<lead>ol', 0)

"       P       Paragraph               HTML 3.0
call HTMLmap("inoremap", "<lead>pp", "<[{P}]><CR></[{P}]><ESC>O")
" Visual mapping:
call HTMLmap("vnoremap", "<lead>pp", "<ESC>`>a<CR></[{P}]><C-O>`<<[{P}]><CR><ESC>", 1)
" Motion mapping:
call HTMLmapo('<lead>pp', 0)
" A special mapping... If you're between <P> and </P> this will insert the
" close tag and then the open tag in insert mode:
call HTMLmap("inoremap", "<lead>/p", "</[{P}]><CR><CR><[{P}]><CR>")

"       PRE     Preformatted Text       HTML 2.0
call HTMLmap("inoremap", "<lead>pr", "<[{PRE}]><CR></[{PRE}]><ESC>O")
" Visual mapping:
call HTMLmap("vnoremap", "<lead>pr", "<ESC>`>a<CR></[{PRE}]><C-O>`<<[{PRE}]><CR><ESC>", 1)
" Motion mapping:
call HTMLmapo('<lead>pr', 0)

"       Q       Quote                   HTML 3.0
call HTMLmap("inoremap", "<lead>qu", "<[{Q></Q}]><ESC>hhhi")
" Visual mapping:
call HTMLmap("vnoremap", "<lead>qu", "<ESC>`>a</[{Q}]><C-O>`<<[{Q}]><ESC>")
" Motion mapping:
call HTMLmapo('<lead>qu', 0)

"       S       Strikethrough           HTML 3.0
call HTMLmap("inoremap", "<lead>sk", "<[{STRIKE></STRIKE}]><ESC>bhhi")
" Visual mapping:
call HTMLmap("vnoremap", "<lead>sk", "<ESC>`>a</[{STRIKE}]><C-O>`<<[{STRIKE}]><ESC>", 2)
" Motion mapping:
call HTMLmapo('<lead>sk', 0)

"       SAMP    Sample Text             HTML 2.0
call HTMLmap("inoremap", "<lead>sa", "<[{SAMP></SAMP}]><ESC>bhhi")
" Visual mapping:
call HTMLmap("vnoremap", "<lead>sa", "<ESC>`>a</[{SAMP}]><C-O>`<<[{SAMP}]><ESC>", 2)
" Motion mapping:
call HTMLmapo('<lead>sa', 0)

"       SMALL   Small Text              HTML 3.0
call HTMLmap("inoremap", "<lead>sm", "<[{SMALL></SMALL}]><ESC>bhhi")
" Visual mapping:
call HTMLmap("vnoremap", "<lead>sm", "<ESC>`>a</[{SMALL}]><C-O>`<<[{SMALL}]><ESC>")
" Motion mapping:
call HTMLmapo('<lead>sm', 0)

"       STRONG                          HTML 2.0
call HTMLmap("inoremap", "<lead>st", "<C-R>=<SID>tag('strong','i')<CR>")
" Visual mapping:
call HTMLmap("vnoremap", "<lead>st", "<C-C>:execute \"normal \" . <SID>tag('strong','v')<CR>", 2)
" Motion mapping:
call HTMLmapo('<lead>st', 0)

"       STYLE                           HTML 4.0        HEADER
call HTMLmap("inoremap", "<lead>cs", "<[{STYLE TYPE}]=\"text/css\"><CR><!--<CR>--><CR></[{STYLE}]><ESC>kO")
" Visual mapping:
call HTMLmap("vnoremap", "<lead>cs", "<ESC>`>a<CR> --><CR></[{STYLE}]><C-O>`<<[{STYLE TYPE}]=\"text/css\"><CR><!--<CR><ESC>", 1)
" Motion mapping:
call HTMLmapo('<lead>cs', 0)

"       Linked CSS stylesheet
call HTMLmap("inoremap", "<lead>ls", "<[{LINK REL}]=\"stylesheet\" [{TYPE}]=\"text/css\" [{HREF}]=\"\"><ESC>F\"i")
" Visual mapping:
call HTMLmap("vnoremap", "<lead>ls", "<ESC>`>a\"><C-O>`<<[{LINK REL}]=\"stylesheet\" [{TYPE}]=\"text/css\" [{HREF}]=\"<ESC>", 2)
" Motion mapping:
call HTMLmapo('<lead>ls', 0)

"       SUB     Subscript               HTML 3.0
call HTMLmap("inoremap", "<lead>sb", "<[{SUB></SUB}]><ESC>bhhi")
" Visual mapping:
call HTMLmap("vnoremap", "<lead>sb", "<ESC>`>a</[{SUB}]><C-O>`<<[{SUB}]><ESC>", 2)
" Motion mapping:
call HTMLmapo('<lead>sb', 0)

"       SUP     Superscript             HTML 3.0
call HTMLmap("inoremap", "<lead>sp", "<[{SUP></SUP}]><ESC>bhhi")
" Visual mapping:
call HTMLmap("vnoremap", "<lead>sp", "<ESC>`>a</[{SUP}]><C-O>`<<[{SUP}]><ESC>", 2)
" Motion mapping:
call HTMLmapo('<lead>sp', 0)

"       TITLE                           HTML 2.0        HEADER
call HTMLmap("inoremap", "<lead>ti", "<[{TITLE></TITLE}]><ESC>bhhi")
" Visual mapping:
call HTMLmap("vnoremap", "<lead>ti", "<ESC>`>a</[{TITLE}]><C-O>`<<[{TITLE}]><ESC>", 2)
" Motion mapping:
call HTMLmapo('<lead>ti', 0)

"       TT      Teletype Text (monospaced)      HTML 2.0
call HTMLmap("inoremap", "<lead>tt", "<[{TT></TT}]><ESC>bhhi")
" Visual mapping:
call HTMLmap("vnoremap", "<lead>tt", "<ESC>`>a</[{TT}]><C-O>`<<[{TT}]><ESC>", 2)
" Motion mapping:
call HTMLmapo('<lead>tt', 0)

"       U       Underlined Text         HTML 2.0
call HTMLmap("inoremap", "<lead>un", "<C-R>=<SID>tag('u','i')<CR>")
" Visual mapping:
call HTMLmap("vnoremap", "<lead>un", "<C-C>:execute \"normal \" . <SID>tag('u','v')<CR>", 2)
" Motion mapping:
call HTMLmapo('<lead>un', 0)

"       UL      Unordered List          HTML 2.0
call HTMLmap("inoremap", "<lead>ul", "<[{UL}]><CR></[{UL}]><ESC>O")
" Visual mapping:
call HTMLmap("vnoremap", "<lead>ul", "<ESC>`>a<CR></[{UL}]><C-O>`<<[{UL}]><CR><ESC>", 1)
" Motion mapping:
call HTMLmapo('<lead>ul', 0)

"       VAR     Variable                HTML 3.0
call HTMLmap("inoremap", "<lead>va", "<[{VAR></VAR}]><ESC>bhhi")
" Visual mapping:
call HTMLmap("vnoremap", "<lead>va", "<ESC>`>a</[{VAR}]><C-O>`<<[{VAR}]><ESC>", 2)
" Motion mapping:
call HTMLmapo('<lead>va', 0)

"       Embedded JavaScript
call HTMLmap("inoremap", "<lead>js", "<[{SCRIPT TYPE}]=\"text/javascript\" [{LANGUAGE}]=\"javascript\"><CR><!--<CR>// --><CR></[{SCRIPT}]><ESC>kO")

"       Sourced JavaScript
call HTMLmap("inoremap", "<lead>sj", "<[{SCRIPT SRC}]=\"\" [{TYPE}]=\"text/javascript\" [{LANGUAGE}]=\"javascript\"></[{SCRIPT}]><C-O>5F\"")

"       EMBED
call HTMLmap("inoremap", "<lead>eb", "<[{EMBED SRC=\"\" WIDTH=\"\" HEIGHT}]=\"\" /><CR><[{NOEMBED></NOEMBED}]><ESC>k$5F\"i")

"       OBJECT
call HTMLmap("inoremap", "<lead>ob", "<[{OBJECT DATA=\"\" WIDTH=\"\" HEIGHT}]=\"\"><CR></[{OBJECT}]><ESC>k$5F\"i")

" Table stuff:
call HTMLmap("inoremap", "<lead>ca", "<[{CAPTION></CAPTION}]><ESC>bhhi")
call HTMLmap("inoremap", "<lead>ta", "<[{TABLE}]><CR></[{TABLE}]><ESC>O")
call HTMLmap("inoremap", "<lead>tr", "<[{TR}]><CR></[{TR}]><ESC>O")
call HTMLmap("inoremap", "<lead>td", "<[{TD}]><CR></[{TD}]><ESC>O")
call HTMLmap("inoremap", "<lead>th", "<[{TH></TH}]><ESC>bhhi")
" Visual mappings:
call HTMLmap("vnoremap", "<lead>ca", "<ESC>`>a<CR></[{CAPTION}]><C-O>`<<[{CAPTION}]><CR><ESC>", 1)
call HTMLmap("vnoremap", "<lead>ta", "<ESC>`>a<CR></[{TABLE}]><C-O>`<<[{TABLE}]><CR><ESC>", 1)
call HTMLmap("vnoremap", "<lead>tr", "<ESC>`>a<CR></[{TR}]><C-O>`<<[{TR}]><CR><ESC>", 1)
call HTMLmap("vnoremap", "<lead>td", "<ESC>`>a<CR></[{TD}]><C-O>`<<[{TD}]><CR><ESC>", 1)
call HTMLmap("vnoremap", "<lead>th", "<ESC>`>a</[{TH}]><C-O>`<<[{TH}]><ESC>", 2)
" Motion mappings:
call HTMLmapo("<lead>ca", 0)
call HTMLmapo("<lead>ta", 0)
call HTMLmapo("<lead>tr", 0)
call HTMLmapo("<lead>td", 0)
call HTMLmapo("<lead>th", 0)

" Interactively generate a table of Rows x Columns:
call HTMLmap("nnoremap", "<lead>tA", ":call HTMLgenerateTable()<CR>")

function! HTMLgenerateTable()
    let byteoffset = line2byte(line('.')) + col('.') - 1

    let rows    = inputdialog("Number of rows: ") + 0
    let columns = inputdialog("Number of columns: ") + 0

    if (! (rows > 0 && columns > 0))
        echo "Rows and columns must be integers."
        return
    endif

    let border = inputdialog("Border width of table [none]: ") + 0

    let r = 0
    let c = 0

    if (border)
        exe s:HTMLconvertCase("normal o<[{TABLE BORDER}]=" . border . ">\<ESC>")
    else
        exe s:HTMLconvertCase("normal o<[{TABLE}]>\<ESC>")
    endif

    while r < rows
        let r = r + 1
        let c = 0

        exe s:HTMLconvertCase("normal o<[{TR}]>\<ESC>")

        while c < columns
            let c = c + 1
            exe s:HTMLconvertCase("normal o<[{TD}]>\<CR></[{TD}]>\<ESC>")
        endwhile

        exe s:HTMLconvertCase("normal o</[{TR}]>\<ESC>")

    endwhile

    exe s:HTMLconvertCase("normal o</[{TABLE}]>\<ESC>")

    if byteoffset == -1
      go 1
    else
      execute ":go " . byteoffset
    endif

    normal jjj^

endfunction

" Frames stuff:
call HTMLmap("inoremap", "<lead>fs", "<[{FRAMESET ROWS=\"\" COLS}]=\"\"><CR></[{FRAMESET}]><ESC>BBhhi")
call HTMLmap("inoremap", "<lead>fr", "<[{FRAME SRC}]=\"\" /><ESC>F\"i")
call HTMLmap("inoremap", "<lead>nf", "<[{NOFRAMES}]><CR></[{NOFRAMES}]><ESC>O")
" Visual mappings:
call HTMLmap("vnoremap", "<lead>fs", "<ESC>`>a<CR></[{FRAMESET}]><C-O>`<<[{FRAMESET ROWS=\"\" COLS}]=\"\"><CR><ESC>k$3F\"")
call HTMLmap("vnoremap", "<lead>fr", "<ESC>`>a\" /><C-O>`<<[{FRAME SRC=\"<ESC>")
call HTMLmap("vnoremap", "<lead>nf", "<ESC>`>a<CR></[{NOFRAMES}]><C-O>`<<[{NOFRAMES}]><CR><ESC>", 1)
" Motion mappings:
call HTMLmapo("<lead>fs", 0)
call HTMLmapo("<lead>fr", 0)
call HTMLmapo("<lead>nf", 0)

"       IFRAME  Inline Frame            HTML 4.0
call HTMLmap("inoremap", "<lead>if", "<[{IFRAME SRC}]=\"\"><CR></[{IFRAME}]><ESC>Bblli")
" Visual mapping:
call HTMLmap("vnoremap", "<lead>if", "<ESC>`>a<CR></[{IFRAME}]><C-O>`<<[{IFRAME SRC}]=\"\"><CR><ESC>k$F\"")
" Motion mapping:
call HTMLmapo('<lead>if', 0)

" Forms stuff:
call HTMLmap("inoremap", "<lead>fm", "<[{FORM ACTION}]=\"\"><CR></[{FORM}]><ESC>k$F\"i")
call HTMLmap("inoremap", "<lead>bu", "<[{INPUT TYPE=\"BUTTON\" NAME=\"\" VALUE}]=\"\" /><ESC>3F\"i")
call HTMLmap("inoremap", "<lead>ch", "<[{INPUT TYPE=\"CHECKBOX\" NAME=\"\" VALUE}]=\"\" /><ESC>3F\"i")
call HTMLmap("inoremap", "<lead>ra", "<[{INPUT TYPE=\"RADIO\" NAME=\"\" VALUE}]=\"\" /><ESC>3F\"i")
call HTMLmap("inoremap", "<lead>hi", "<[{INPUT TYPE=\"HIDDEN\" NAME=\"\" VALUE}]=\"\" /><ESC>3F\"i")
call HTMLmap("inoremap", "<lead>pa", "<[{INPUT TYPE=\"PASSWORD\" NAME=\"\" VALUE=\"\" SIZE}]=\"20\" /><ESC>5F\"i")
call HTMLmap("inoremap", "<lead>te", "<[{INPUT TYPE=\"TEXT\" NAME=\"\" VALUE=\"\" SIZE}]=\"20\" /><ESC>5F\"i")
call HTMLmap("inoremap", "<lead>fi", "<[{INPUT TYPE=\"FILE\" NAME=\"\" VALUE=\"\" SIZE}]=\"20\" /><ESC>5F\"i")
call HTMLmap("inoremap", "<lead>se", "<[{SELECT NAME}]=\"\"><CR></[{SELECT}]><ESC>O")
call HTMLmap("inoremap", "<lead>ms", "<[{SELECT NAME=\"\" MULTIPLE}]><CR></[{SELECT}]><ESC>O")
call HTMLmap("inoremap", "<lead>op", "<[{OPTION></OPTION}]><ESC>F<i")
call HTMLmap("inoremap", "<lead>og", "<[{OPTGROUP LABEL}]=\"\"><CR></[{OPTGROUP}]><ESC>k$F\"i")
call HTMLmap("inoremap", "<lead>tx", "<[{TEXTAREA NAME=\"\" ROWS=\"10\" COLS}]=\"50\"><CR></[{TEXTAREA}]><ESC>k$5F\"i")
call HTMLmap("inoremap", "<lead>su", "<[{INPUT TYPE=\"SUBMIT\" VALUE}]=\"Submit\" />")
call HTMLmap("inoremap", "<lead>re", "<[{INPUT TYPE=\"RESET\" VALUE}]=\"Reset\" />")
call HTMLmap("inoremap", "<lead>la", "<[{LABEL FOR=\"\"></LABEL}]><C-O>F\"")
" Visual mappings:
call HTMLmap("vnoremap", "<lead>fm", "<ESC>`>a<CR></[{FORM}]><C-O>`<<[{FORM ACTION}]=\"\"><CR><ESC>k$F\"", 1)
call HTMLmap("vnoremap", "<lead>bu", "<ESC>`>a\" /><C-O>`<<[{INPUT TYPE=\"BUTTON\" NAME=\"\" VALUE}]=\"<C-O>2F\"", 0)
call HTMLmap("vnoremap", "<lead>ch", "<ESC>`>a\" /><C-O>`<<[{INPUT TYPE=\"CHECKBOX\" NAME=\"\" VALUE}]=\"<C-O>2F\"", 0)
call HTMLmap("vnoremap", "<lead>ra", "<ESC>`>a\" /><C-O>`<<[{INPUT TYPE=\"RADIO\" NAME=\"\" VALUE}]=\"<C-O>2F\"", 0)
call HTMLmap("vnoremap", "<lead>hi", "<ESC>`>a\" /><C-O>`<<[{INPUT TYPE=\"HIDDEN\" NAME=\"\" VALUE}]=\"<C-O>2F\"", 0)
call HTMLmap("vnoremap", "<lead>pa", "<ESC>`>a\" [{SIZE}]=\"20\" /><C-O>`<<[{INPUT TYPE=\"PASSWORD\" NAME=\"\" VALUE}]=\"<C-O>2F\"", 0)
call HTMLmap("vnoremap", "<lead>te", "<ESC>`>a\" [{SIZE}]=\"20\" /><C-O>`<<[{INPUT TYPE=\"TEXT\" NAME=\"\" VALUE}]=\"<C-O>2F\"", 0)
call HTMLmap("vnoremap", "<lead>fi", "<ESC>`>a\" [{SIZE}]=\"20\" /><C-O>`<<[{INPUT TYPE=\"FILE\" NAME=\"\" VALUE}]=\"<C-O>2F\"", 0)
call HTMLmap("vnoremap", "<lead>se", "<ESC>`>a<CR></[{SELECT}]><C-O>`<<[{SELECT NAME}]=\"\"><CR><ESC>k$F\"", 1)
call HTMLmap("vnoremap", "<lead>ms", "<ESC>`>a<CR></[{SELECT}]><C-O>`<<[{SELECT NAME=\"\" MULTIPLE}]><CR><ESC>k$F\"", 1)
call HTMLmap("vnoremap", "<lead>op", "<ESC>`>a</[{OPTION}]><C-O>`<<[{OPTION}]><ESC>", 2)
call HTMLmap("vnoremap", "<lead>og", "<ESC>`>a<CR></[{OPTGROUP}]><C-O>`<<[{OPTGROUP LABEL}]=\"\"><CR><ESC>k$F\"", 1)
call HTMLmap("vnoremap", "<lead>tx", "<ESC>`>a<CR></[{TEXTAREA}]><C-O>`<<[{TEXTAREA NAME=\"\" ROWS=\"10\" COLS}]=\"50\"><CR><ESC>k$5F\"", 1)
call HTMLmap("vnoremap", "<lead>la", "<ESC>`>a</[{LABEL}]><C-O>`<<[{LABEL FOR}]=\"\"><C-O>F\"", 0)
call HTMLmap("vnoremap", "<lead>lA", "<ESC>`>a\"></[{LABEL}]><C-O>`<<[{LABEL FOR}]=\"<C-O>f<", 0)
" Motion mappings:
call HTMLmapo("<lead>fm", 0)
call HTMLmapo("<lead>bu", 1)
call HTMLmapo("<lead>ch", 1)
call HTMLmapo("<lead>ra", 1)
call HTMLmapo("<lead>hi", 1)
call HTMLmapo("<lead>pa", 1)
call HTMLmapo("<lead>te", 1)
call HTMLmapo("<lead>fi", 1)
call HTMLmapo("<lead>se", 0)
call HTMLmapo("<lead>ms", 0)
call HTMLmapo("<lead>op", 0)
call HTMLmapo("<lead>og", 0)
call HTMLmapo("<lead>tx", 0)
call HTMLmapo("<lead>la", 1)
call HTMLmapo("<lead>lA", 1)

" ----------------------------------------------------------------------------


" ---- Special Character (Character Entities) Mappings: ----------------- {{{1

" Convert the character under the cursor or the highlighted string to straight
" HTML entities:
call HTMLmap("nnoremap", "<lead>&", "s<C-R>=HTMLencodeString(@\")<CR><Esc>")
call HTMLmap("vnoremap", "<lead>&", "s<C-R>=HTMLencodeString(@\")<CR><Esc>")

call HTMLmap("inoremap", "&&", "&amp;")
call HTMLmap("inoremap", "&cO", "&copy;")
call HTMLmap("inoremap", "&rO", "&reg;")
call HTMLmap("inoremap", "&tm", "&trade;")
call HTMLmap("inoremap", "&'", "&quot;")
call HTMLmap("inoremap", "&<", "&lt;")
call HTMLmap("inoremap", "&>", "&gt;")
call HTMLmap("inoremap", "&<space>", "&nbsp;")
call HTMLmap("inoremap", "<lead><space>", "&nbsp;")
call HTMLmap("inoremap", "&#", "&pound;")
call HTMLmap("inoremap", "&Y=", "&yen;")
call HTMLmap("inoremap", "&c\\|", "&cent;")
call HTMLmap("inoremap", "&A`", "&Agrave;")
call HTMLmap("inoremap", "&A'", "&Aacute;")
call HTMLmap("inoremap", "&A^", "&Acirc;")
call HTMLmap("inoremap", "&A~", "&Atilde;")
call HTMLmap("inoremap", "&A\"", "&Auml;")
call HTMLmap("inoremap", "&Ao", "&Aring;")
call HTMLmap("inoremap", "&AE", "&AElig;")
call HTMLmap("inoremap", "&C,", "&Ccedil;")
call HTMLmap("inoremap", "&E`", "&Egrave;")
call HTMLmap("inoremap", "&E'", "&Eacute;")
call HTMLmap("inoremap", "&E^", "&Ecirc;")
call HTMLmap("inoremap", "&E\"", "&Euml;")
call HTMLmap("inoremap", "&I`", "&Igrave;")
call HTMLmap("inoremap", "&I'", "&Iacute;")
call HTMLmap("inoremap", "&I^", "&Icirc;")
call HTMLmap("inoremap", "&I\"", "&Iuml;")
call HTMLmap("inoremap", "&N~", "&Ntilde;")
call HTMLmap("inoremap", "&O`", "&Ograve;")
call HTMLmap("inoremap", "&O'", "&Oacute;")
call HTMLmap("inoremap", "&O^", "&Ocirc;")
call HTMLmap("inoremap", "&O~", "&Otilde;")
call HTMLmap("inoremap", "&O\"", "&Ouml;")
call HTMLmap("inoremap", "&O/", "&Oslash;")
call HTMLmap("inoremap", "&U`", "&Ugrave;")
call HTMLmap("inoremap", "&U'", "&Uacute;")
call HTMLmap("inoremap", "&U^", "&Ucirc;")
call HTMLmap("inoremap", "&U\"", "&Uuml;")
call HTMLmap("inoremap", "&Y'", "&Yacute;")
call HTMLmap("inoremap", "&a`", "&agrave;")
call HTMLmap("inoremap", "&a'", "&aacute;")
call HTMLmap("inoremap", "&a^", "&acirc;")
call HTMLmap("inoremap", "&a~", "&atilde;")
call HTMLmap("inoremap", "&a\"", "&auml;")
call HTMLmap("inoremap", "&ao", "&aring;")
call HTMLmap("inoremap", "&ae", "&aelig;")
call HTMLmap("inoremap", "&c,", "&ccedil;")
call HTMLmap("inoremap", "&e`", "&egrave;")
call HTMLmap("inoremap", "&e'", "&eacute;")
call HTMLmap("inoremap", "&e^", "&ecirc;")
call HTMLmap("inoremap", "&e\"", "&euml;")
call HTMLmap("inoremap", "&i`", "&igrave;")
call HTMLmap("inoremap", "&i'", "&iacute;")
call HTMLmap("inoremap", "&i^", "&icirc;")
call HTMLmap("inoremap", "&i\"", "&iuml;")
call HTMLmap("inoremap", "&n~", "&ntilde;")
call HTMLmap("inoremap", "&o`", "&ograve;")
call HTMLmap("inoremap", "&o'", "&oacute;")
call HTMLmap("inoremap", "&o^", "&ocirc;")
call HTMLmap("inoremap", "&o~", "&otilde;")
call HTMLmap("inoremap", "&o\"", "&ouml;")
call HTMLmap("inoremap", "&x", "&times;")
call HTMLmap("inoremap", "&u`", "&ugrave;")
call HTMLmap("inoremap", "&u'", "&uacute;")
call HTMLmap("inoremap", "&u^", "&ucirc;")
call HTMLmap("inoremap", "&u\"", "&uuml;")
call HTMLmap("inoremap", "&y'", "&yacute;")
call HTMLmap("inoremap", "&y\"", "&yuml;")
call HTMLmap("inoremap", "&2<", "&laquo;")
call HTMLmap("inoremap", "&2>", "&raquo;")
call HTMLmap("inoremap", "&\"", "&uml;")
call HTMLmap("inoremap", "&/", "&divide;")
call HTMLmap("inoremap", "&o/", "&oslash;")
call HTMLmap("inoremap", "&!", "&iexcl;")
call HTMLmap("inoremap", "&?", "&iquest;")
call HTMLmap("inoremap", "&de", "&deg;")
call HTMLmap("inoremap", "&mu", "&micro;")
call HTMLmap("inoremap", "&pa", "&para;")
call HTMLmap("inoremap", "&.", "&middot;")
call HTMLmap("inoremap", "&14", "&frac14;")
call HTMLmap("inoremap", "&12", "&frac12;")
call HTMLmap("inoremap", "&34", "&frac34;")
call HTMLmap("inoremap", "&n-", "&ndash;")  " Math symbol.
call HTMLmap("inoremap", "&m-", "&mdash;")  " Sentence break.
call HTMLmap("inoremap", "&--", "&mdash;")  " ditto
call HTMLmap("inoremap", "&3.", "&hellip;")
" ----------------------------------------------------------------------------

" ---- Browser Remote Controls: ----------------------------------------- {{{1
if has("unix")
  if !exists("*LaunchBrowser")
    runtime! browser_launcher.vim
  endif

  if exists("*LaunchBrowser")
    " Firefox: View current file, starting Netscape if it's not running:
    call HTMLmap("nnoremap", "<lead>ff", ":call LaunchBrowser('f',0)<CR>")
    " Firefox: Open a new window, and view the current file:
    call HTMLmap("nnoremap", "<lead>nff", ":call LaunchBrowser('f',1)<CR>")
    " Firefox: Open a new tab, and view the current file:
    call HTMLmap("nnoremap", "<lead>tff", ":call LaunchBrowser('f',2)<CR>")

    " Mozilla: View current file, starting Netscape if it's not running:
    call HTMLmap("nnoremap", "<lead>mo", ":call LaunchBrowser('m',0)<CR>")
    " Mozilla: Open a new window, and view the current file:
    call HTMLmap("nnoremap", "<lead>nmo", ":call LaunchBrowser('m',1)<CR>")
    " Mozilla: Open a new tab, and view the current file:
    call HTMLmap("nnoremap", "<lead>tmo", ":call LaunchBrowser('m',2)<CR>")

    " Netscape: View current file, starting Netscape if it's not running:
    call HTMLmap("nnoremap", "<lead>ns", ":call LaunchBrowser('n',0)<CR>")
    " Netscape: Open a new window, and view the current file:
    call HTMLmap("nnoremap", "<lead>nns", ":call LaunchBrowser('n',1)<CR>")

    " Opera: View current file, starting Opera if it's not running:
    call HTMLmap("nnoremap", "<lead>oa", ":call LaunchBrowser('o',0)<CR>")
    " Opera: View current file in a new window, starting Opera if it's not running:
    call HTMLmap("nnoremap", "<lead>noa", ":call LaunchBrowser('o',1)<CR>")
    " Opera: Open a new tab, and view the current file:
    call HTMLmap("nnoremap", "<lead>toa", ":call LaunchBrowser('o',2)<CR>")

    " Lynx:  (This happens anyway if there's no DISPLAY environmental variable.)
    call HTMLmap("nnoremap","<lead>ly",":call LaunchBrowser('l',0)<CR>")
    " Lynx in an xterm:      (This happens regardless if you're in the Vim GUI.)
    call HTMLmap("nnoremap", "<lead>nly", ":call LaunchBrowser('l',1)<CR>")
  endif
elseif has("win32")
  " Internet Explorer:
  "SetIfUnset html_internet_explorer C:\program\ files\internet\ explorer\iexplore
  "function! HTMLstartExplorer(file)
  "  if executable(g:html_internet_explorer)
  "    exe '!start ' g:html_internet_explorer . ' ' . a:file
  "  else
  "    exe '!start explorer ' . a:file
  "  endif
  "endfunction
  "call HTMLmap("nnoremap", "<lead>ie", ":call HTMLstartExplorer(expand('%:p'))<CR>")

  " This assumes that IE is installed and the file explorer will become IE
  " when given an URL to open:
  call HTMLmap("nnoremap", "<lead>ie", ":exe '!start explorer ' . expand('%:p')<CR>")
endif

" ----------------------------------------------------------------------------

endif " ! exists("b:did_html_mappings")

" ---- ToolBar Buttons: ------------------------------------------------- {{{1
if ! has("gui_running")
  augroup HTMLplugin
  au!
  execute 'autocmd GUIEnter * source ' . expand('<sfile>:p')
  augroup END
elseif exists("did_html_menus")
  if &filetype ==? "html" || &filetype ==? "xhtml"
    amenu enable HTML
    amenu enable HTML.*
    if exists('g:did_html_toolbar')
      amenu enable ToolBar.*
    endif
  endif
else

if (! exists('g:no_html_toolbar')) && (has("toolbar") || has("win32") || has("gui_gtk")
  \ || (v:version >= 600 && (has("gui_athena") || has("gui_motif") || has("gui_photon"))))

  set guioptions+=T

  " A kluge to overcome a problem with the GTK2 interface:
  command! -nargs=+ HTMLtmenu call HTMLtmenu(<f-args>)
  function! HTMLtmenu(icon, level, menu, tip)
    if has('gui_gtk2') && v:version <= 602 && ! has('patch240')
      exe 'tmenu icon=' . a:icon . ' ' . a:level . ' ' . a:menu . ' ' . a:tip
    else
      exe 'tmenu ' . a:level . ' ' . a:menu . ' ' . a:tip
    endif
  endfunction

  "tunmenu ToolBar
  unmenu ToolBar
  unmenu! ToolBar

  tmenu 1.10          ToolBar.Open      Open file
  amenu 1.10          ToolBar.Open      :browse e<CR>
  tmenu 1.20          ToolBar.Save      Save current file
  amenu 1.20          ToolBar.Save      :w<CR>
  tmenu 1.30          ToolBar.SaveAll   Save all files
  amenu 1.30          ToolBar.SaveAll   :wa<CR>

   menu 1.50          ToolBar.-sep1-    <nul>

  HTMLtmenu Template  1.60  ToolBar.Template   Create\ Template
  exe 'amenu          1.60  ToolBar.Template'  g:html_map_leader . 'html'

   menu               1.65  ToolBar.-sep2-     <nul>

  HTMLtmenu Paragraph 1.70  ToolBar.Paragraph  Create\ Paragraph
  exe 'imenu          1.70  ToolBar.Paragraph' g:html_map_leader . 'pp'
  exe 'vmenu          1.70  ToolBar.Paragraph' g:html_map_leader . 'pp'
  exe 'nmenu          1.70  ToolBar.Paragraph' 'i' . g:html_map_leader . 'pp'
  HTMLtmenu Break     1.80  ToolBar.Break      Line\ Break
  exe 'imenu          1.80  ToolBar.Break'     g:html_map_leader . 'br'
  exe 'vmenu          1.80  ToolBar.Break'     g:html_map_leader . 'br'
  exe 'nmenu          1.80  ToolBar.Break'     'i' . g:html_map_leader . 'br'

   menu               1.85  ToolBar.-sep3-     <nul>

  HTMLtmenu Link      1.90  ToolBar.Link       Create\ Hyperlink
  exe 'imenu          1.90  ToolBar.Link'      g:html_map_leader . 'ah'
  exe 'vmenu          1.90  ToolBar.Link'      g:html_map_leader . 'ah'
  exe 'nmenu          1.90  ToolBar.Link'      'i' . g:html_map_leader . 'ah'
  HTMLtmenu Target    1.100 ToolBar.Target     Create\ Target\ (Named\ Anchor)
  exe 'imenu          1.100 ToolBar.Target'    g:html_map_leader . 'an'
  exe 'vmenu          1.100 ToolBar.Target'    g:html_map_leader . 'an'
  exe 'nmenu          1.100 ToolBar.Target'    'i' . g:html_map_leader . 'an'
  HTMLtmenu Image     1.110 ToolBar.Image      Insert\ Image
  exe 'imenu          1.110 ToolBar.Image'     g:html_map_leader . 'im'
  exe 'vmenu          1.110 ToolBar.Image'     g:html_map_leader . 'im'
  exe 'nmenu          1.110 ToolBar.Image'     'i' . g:html_map_leader . 'im'

   menu               1.115 ToolBar.-sep4-     <nul>

  HTMLtmenu Hline     1.120 ToolBar.Hline      Create\ Horizontal\ Rule
  exe 'imenu          1.120 ToolBar.Hline'     g:html_map_leader . 'hr'
  exe 'nmenu          1.120 ToolBar.Hline'     'i' . g:html_map_leader . 'hr'

   menu               1.125 ToolBar.-sep5-     <nul>

  HTMLtmenu Table     1.130 ToolBar.Table      Create\ Table
  exe 'imenu          1.130 ToolBar.Table'     '<ESC>' . g:html_map_leader . 'tA'
  exe 'nmenu          1.130 ToolBar.Table'     g:html_map_leader . 'tA'

   menu               1.135 ToolBar.-sep6-     <nul>

  HTMLtmenu Blist     1.140 ToolBar.Blist      Create\ Bullet\ List
  exe 'imenu          1.140 ToolBar.Blist'     g:html_map_leader . 'ul' . g:html_map_leader . 'li'
  exe 'vmenu          1.140 ToolBar.Blist'     g:html_map_leader . 'uli' . g:html_map_leader . 'li<ESC>'
  exe 'nmenu          1.140 ToolBar.Blist'     'i' . g:html_map_leader . 'ul' . g:html_map_leader . 'li'
  HTMLtmenu Nlist     1.150 ToolBar.Nlist      Create\ Numbered\ List
  exe 'imenu          1.150 ToolBar.Nlist'     g:html_map_leader . 'ol' . g:html_map_leader . 'li'
  exe 'vmenu          1.150 ToolBar.Nlist'     g:html_map_leader . 'oli' . g:html_map_leader . 'li<ESC>'
  exe 'nmenu          1.150 ToolBar.Nlist'     'i' . g:html_map_leader . 'ol' . g:html_map_leader . 'li'
  HTMLtmenu Litem     1.160 ToolBar.Litem      Add\ List\ Item
  exe 'imenu          1.160 ToolBar.Litem'     g:html_map_leader . 'li'
  exe 'nmenu          1.160 ToolBar.Litem'     'i' . g:html_map_leader . 'li'

   menu               1.165 ToolBar.-sep7-     <nul>

  HTMLtmenu Bold      1.170 ToolBar.Bold       Bold
  exe 'imenu          1.170 ToolBar.Bold'      g:html_map_leader . 'bo'
  exe 'vmenu          1.170 ToolBar.Bold'      g:html_map_leader . 'bo'
  exe 'nmenu          1.170 ToolBar.Bold'      'i' . g:html_map_leader . 'bo'
  HTMLtmenu Italic    1.180 ToolBar.Italic     Italic
  exe 'imenu          1.180 ToolBar.Italic'    g:html_map_leader . 'it'
  exe 'vmenu          1.180 ToolBar.Italic'    g:html_map_leader . 'it'
  exe 'nmenu          1.180 ToolBar.Italic'    'i' . g:html_map_leader . 'it'
  HTMLtmenu Underline 1.190 ToolBar.Underline  Underline
  exe 'imenu          1.190 ToolBar.Underline' g:html_map_leader . 'un'
  exe 'vmenu          1.190 ToolBar.Underline' g:html_map_leader . 'un'
  exe 'nmenu          1.190 ToolBar.Underline' 'i' . g:html_map_leader . 'un'

   menu               1.195 ToolBar.-sep8-    <nul>

  tmenu               1.200 ToolBar.Cut       Cut to clipboard
  vmenu               1.200 ToolBar.Cut       "*x
  tmenu               1.210 ToolBar.Copy      Copy to clipboard
  vmenu               1.210 ToolBar.Copy      "*y
  tmenu               1.220 ToolBar.Paste     Paste from Clipboard
  nmenu               1.220 ToolBar.Paste     i<C-R>*<Esc>
  vmenu               1.220 ToolBar.Paste     "-xi<C-R>*<Esc>
  menu!               1.220 ToolBar.Paste     <C-R>*

   menu               1.225 ToolBar.-sep9-    <nul>

  tmenu               1.230 ToolBar.Find      Find...
  tmenu               1.240 ToolBar.Replace   Find & Replace

  if has("win32") || has("win16") || has("gui_gtk") || has("gui_motif")
    amenu 1.250 ToolBar.Find    :promptfind<CR>
    vunmenu     ToolBar.Find
    vmenu       ToolBar.Find    y:promptfind <C-R>"<CR>
    amenu 1.260 ToolBar.Replace :promptrepl<CR>
    vunmenu     ToolBar.Replace
    vmenu       ToolBar.Replace y:promptrepl <C-R>"<CR>
  else
    amenu 1.250 ToolBar.Find    /
    amenu 1.260 ToolBar.Replace :%s/
    vunmenu     ToolBar.Replace
    vmenu       ToolBar.Replace :s/
  endif


  if exists("*LaunchBrowser")
    amenu 1.500 ToolBar.-sep50- <nul>

    let s:browsers = LaunchBrowser()
    
    if s:browsers =~ 'f'
      HTMLtmenu Firefox  1.510 ToolBar.Firefox   Launch\ Firefox\ on\ Current\ File
      exe 'amenu         1.510 ToolBar.Firefox'  g:html_map_leader . 'ff'
    elseif s:browsers =~ 'm'
      HTMLtmenu Mozilla  1.510 ToolBar.Mozilla   Launch\ Mozilla\ on\ Current\ File
      exe 'amenu         1.510 ToolBar.Mozilla'  g:html_map_leader . 'mo'
    elseif s:browsers =~ 'n'
      HTMLtmenu Netscape 1.510 ToolBar.Netscape  Launch\ Netscape\ on\ Current\ File
      exe 'amenu         1.510 ToolBar.Netscape' g:html_map_leader . 'ns'
    endif

    if s:browsers =~ 'o'
      HTMLtmenu Opera    1.520 ToolBar.Opera     Launch\ Opera\ on\ Current\ File
      exe 'amenu         1.520 ToolBar.Opera'    g:html_map_leader . 'oa'
    endif

    if s:browsers =~ 'l'
      HTMLtmenu Lynx     1.530 ToolBar.Lynx      Launch\ Lynx\ on\ Current\ File
      exe 'amenu         1.530 ToolBar.Lynx'     g:html_map_leader . 'ly'
    endif

  elseif maparg(g:html_map_leader . 'ie', 'n') != ""
    amenu 1.500 ToolBar.-sep50- <nul>

    tmenu 1.510 ToolBar.IE Launch Internet Explorer on Current File
    exe 'amenu 1.510 ToolBar.IE' g:html_map_leader . 'ie'
  endif

  amenu 1.998 ToolBar.-sep99- <nul>
  tmenu 1.999 ToolBar.Help    HTML Help
  amenu 1.999 ToolBar.Help    :help HTML<CR>

  delcommand HTMLtmenu
  delfunction HTMLtmenu

  let did_html_toolbar = 1
endif  " (! exists('g:no_html_toolbar')) && (has("toolbar") || has("win32") [...]
" ----------------------------------------------------------------------------

" ---- Menu Items: ------------------------------------------------------ {{{1

augroup HTML_menu_autos
au!
autocmd BufLeave,BufWinLeave *
 \ if &filetype ==? "html" || &filetype ==? "xhtml" |
   \ amenu disable HTML |
   \ amenu disable HTML.* |
   \ if exists('g:did_html_toolbar') |
   \ amenu disable ToolBar.* |
   \ amenu enable ToolBar.Open |
   \ amenu enable ToolBar.Save |
   \ amenu enable ToolBar.SaveAll |
   \ amenu enable ToolBar.Cut |
   \ amenu enable ToolBar.Copy |
   \ amenu enable ToolBar.Paste |
   \ amenu enable ToolBar.Find |
   \ amenu enable ToolBar.Replace |
   \ endif |
 \ endif
autocmd BufEnter,BufWinEnter *
 \ if &filetype ==? "html" || &filetype ==? "xhtml" |
   \ amenu enable HTML |
   \ amenu enable HTML.* |
   \ if exists('g:did_html_toolbar') |
   \ amenu enable ToolBar.* |
   \ endif |
 \ endif
augroup END

exe 'amenu HTM&L.Template<tab>' . g:html_map_leader . 'html' g:html_map_leader . 'html'

if exists("*LaunchBrowser")
  let s:browsers = LaunchBrowser()

  if s:browsers =~ 'f'
    exe 'amenu HTML.Preview.Firefox<tab>' . g:html_map_leader . 'ff' g:html_map_leader . 'ff'
    exe 'amenu HTML.Preview.Firefox\ (New\ Window)<tab>' . g:html_map_leader . 'nff' g:html_map_leader . 'nff'
    exe 'amenu HTML.Preview.Firefox\ (New\ Tab)<tab>' . g:html_map_leader . 'tff' g:html_map_leader . 'tff'
    amenu HTML.Preview.-sep1-                            <nop>
  endif
  if s:browsers =~ 'm'
    exe 'amenu HTML.Preview.Mozilla<tab>' . g:html_map_leader . 'mo' g:html_map_leader . 'mo'
    exe 'amenu HTML.Preview.Mozilla\ (New\ Window)<tab>' . g:html_map_leader . 'nmo' g:html_map_leader . 'nmo'
    exe 'amenu HTML.Preview.Mozilla\ (New\ Tab)<tab>' . g:html_map_leader . 'tmo' g:html_map_leader . 'tmo'
    amenu HTML.Preview.-sep2-                            <nop>
  endif
  if s:browsers =~ 'n'
    exe 'amenu HTML.Preview.Netscape<tab>' . g:html_map_leader . 'ns' g:html_map_leader . 'ns'
    exe 'amenu HTML.Preview.Netscape\ (New\ Window)<tab>' . g:html_map_leader . 'nns' g:html_map_leader . 'nns'
    amenu HTML.Preview.-sep3-                            <nop>
  endif
  if s:browsers =~ 'o'
    exe 'amenu HTML.Preview.Opera<tab>' . g:html_map_leader . 'oa' g:html_map_leader . 'oa'
    exe 'amenu HTML.Preview.Opera\ (New\ Window)<tab>' . g:html_map_leader . 'noa' g:html_map_leader . 'noa'
    exe 'amenu HTML.Preview.Opera\ (New\ Tab)<tab>' . g:html_map_leader . 'toa' g:html_map_leader . 'toa'
    amenu HTML.Preview.-sep4-                            <nop>
  endif
  if s:browsers =~ 'l'
    exe 'amenu HTML.Preview.Lynx<tab>' . g:html_map_leader . 'ly' g:html_map_leader . 'ly'
  endif
elseif maparg(g:html_map_leader . 'ie', 'n') != ""
  exe 'amenu HTML.Preview.Internet\ Explorer<tab>' . g:html_map_leader . 'ie' g:html_map_leader . 'ie'
endif

 menu HTML.-sep1- <nul>

" Character Entities menu:   {{{2

let b:save_encoding=&encoding
let &encoding='latin1'

nmenu HTML.Character\ Entities.Convert\ to\ Entity<tab>;\&         ;&
vmenu HTML.Character\ Entities.Convert\ to\ Entity<tab>;\&         ;&
 menu HTML.Character\ Entities.-sep0- <nul>
imenu HTML.Character\ Entities.Ampersand<tab>\&\&                  &&
imenu HTML.Character\ Entities.Greaterthan\ (>)<tab>\&>            &>
imenu HTML.Character\ Entities.Lessthan\ (<)<tab>\&<               &<
imenu HTML.Character\ Entities.Space\ (nonbreaking\)<tab>\&<space> &<space>
imenu HTML.Character\ Entities.Quotation\ mark\ (")<tab>\&'        &'
 menu HTML.Character\ Entities.-sep1- <nul>
imenu HTML.Character\ Entities.Cent\ (�)<tab>\&c\|                 &c\|
imenu HTML.Character\ Entities.Pound\ (�)<tab>\&#                  &#
imenu HTML.Character\ Entities.Yen\ (�)<tab>\&Y=                   &Y=
imenu HTML.Character\ Entities.Left\ Angle\ Quote\ (�)<tab>\&2<    &2<
imenu HTML.Character\ Entities.Right\ Angle\ Quote\ (�)<tab>\&2>   &2>
imenu HTML.Character\ Entities.Copyright\ (�)<tab>\&cO             &cO
imenu HTML.Character\ Entities.Registered\ (�)<tab>\&rO            &rO
imenu HTML.Character\ Entities.Trademark\ (TM)<tab>\&tm            &tm
imenu HTML.Character\ Entities.Multiply\ (�)<tab>\&x               &x
imenu HTML.Character\ Entities.Divide\ (�)<tab>\&/                 &/
imenu HTML.Character\ Entities.Inverted\ Exlamation\ (�)<tab>\&!   &!
imenu HTML.Character\ Entities.Inverted\ Question\ (�)<tab>\&?     &?
imenu HTML.Character\ Entities.Degree\ (�)<tab>\&de                &de
imenu HTML.Character\ Entities.Micro/Greek\ mu\ (�)<tab>\&mu       &mu
imenu HTML.Character\ Entities.Paragraph\ (�)<tab>\&pa             &pa
imenu HTML.Character\ Entities.Middle\ Dot\ (�)<tab>\&\.           &.
imenu HTML.Character\ Entities.One\ Quarter\ (�)<tab>\&14          &14
imenu HTML.Character\ Entities.One\ Half\ (�)<tab>\&12             &12
imenu HTML.Character\ Entities.Three\ Quarters\ (�)<tab>\&34       &34
imenu HTML.Character\ Entities.En\ dash\ (-)<tab>\&n-              &n-
imenu HTML.Character\ Entities.Em\ dash\ (--)<tab>\&m-/\&--        &m-
imenu HTML.Character\ Entities.Ellipsis\ (\.\.\.)<tab>\&3\.        &3.
imenu HTML.Character\ Entities.-sep2- <nul>
imenu HTML.Character\ Entities.Graves.A-grave\ (�)<tab>\&A` &A`
imenu HTML.Character\ Entities.Graves.a-grave\ (�)<tab>\&a` &a`
imenu HTML.Character\ Entities.Graves.E-grave\ (�)<tab>\&E` &E`
imenu HTML.Character\ Entities.Graves.e-grave\ (�)<tab>\&e` &e`
imenu HTML.Character\ Entities.Graves.I-grave\ (�)<tab>\&I` &I`
imenu HTML.Character\ Entities.Graves.i-grave\ (�)<tab>\&i` &i`
imenu HTML.Character\ Entities.Graves.O-grave\ (�)<tab>\&O` &O`
imenu HTML.Character\ Entities.Graves.o-grave\ (�)<tab>\&o` &o`
imenu HTML.Character\ Entities.Graves.U-grave\ (�)<tab>\&U` &U`
imenu HTML.Character\ Entities.Graves.u-grave\ (�)<tab>\&u` &u`
imenu HTML.Character\ Entities.Acutes.A-acute\ (�)<tab>\&A' &A'
imenu HTML.Character\ Entities.Acutes.a-acute\ (�)<tab>\&a' &a'
imenu HTML.Character\ Entities.Acutes.E-acute\ (�)<tab>\&E' &E'
imenu HTML.Character\ Entities.Acutes.e-acute\ (�)<tab>\&e' &e'
imenu HTML.Character\ Entities.Acutes.I-acute\ (�)<tab>\&I' &I'
imenu HTML.Character\ Entities.Acutes.i-acute\ (�)<tab>\&i' &i'
imenu HTML.Character\ Entities.Acutes.O-acute\ (�)<tab>\&O' &O'
imenu HTML.Character\ Entities.Acutes.o-acute\ (�)<tab>\&o' &o'
imenu HTML.Character\ Entities.Acutes.U-acute\ (�)<tab>\&U' &U'
imenu HTML.Character\ Entities.Acutes.u-acute\ (�)<tab>\&u' &u'
imenu HTML.Character\ Entities.Acutes.Y-acute\ (�)<tab>\&Y' &Y'
imenu HTML.Character\ Entities.Acutes.y-acute\ (�)<tab>\&y' &y'
imenu HTML.Character\ Entities.Tildes.A-tilde\ (�)<tab>\&A~ &A~
imenu HTML.Character\ Entities.Tildes.a-tilde\ (�)<tab>\&a~ &a~
imenu HTML.Character\ Entities.Tildes.N-tilde\ (�)<tab>\&N~ &N~
imenu HTML.Character\ Entities.Tildes.n-tilde\ (�)<tab>\&n~ &n~
imenu HTML.Character\ Entities.Tildes.O-tilde\ (�)<tab>\&O~ &O~
imenu HTML.Character\ Entities.Tildes.o-tilde\ (�)<tab>\&o~ &o~
imenu HTML.Character\ Entities.Circumflexes.A-circumflex\ (�)<tab>\&A^ &A^
imenu HTML.Character\ Entities.Circumflexes.a-circumflex\ (�)<tab>\&a^ &a^
imenu HTML.Character\ Entities.Circumflexes.E-circumflex\ (�)<tab>\&E^ &E^
imenu HTML.Character\ Entities.Circumflexes.e-circumflex\ (�)<tab>\&e^ &e^
imenu HTML.Character\ Entities.Circumflexes.I-circumflex\ (�)<tab>\&I^ &I^
imenu HTML.Character\ Entities.Circumflexes.i-circumflex\ (�)<tab>\&i^ &i^
imenu HTML.Character\ Entities.Circumflexes.O-circumflex\ (�)<tab>\&O^ &O^
imenu HTML.Character\ Entities.Circumflexes.o-circumflex\ (�)<tab>\&o^ &o^
imenu HTML.Character\ Entities.Circumflexes.U-circumflex\ (�)<tab>\&U^ &U^
imenu HTML.Character\ Entities.Circumflexes.u-circumflex\ (�)<tab>\&u^ &u^
imenu HTML.Character\ Entities.Umlauts.A-umlaut\ (�)<tab>\&A" &A"
imenu HTML.Character\ Entities.Umlauts.a-umlaut\ (�)<tab>\&a" &a"
imenu HTML.Character\ Entities.Umlauts.E-umlaut\ (�)<tab>\&E" &E"
imenu HTML.Character\ Entities.Umlauts.e-umlaut\ (�)<tab>\&e" &e"
imenu HTML.Character\ Entities.Umlauts.I-umlaut\ (�)<tab>\&I" &I"
imenu HTML.Character\ Entities.Umlauts.i-umlaut\ (�)<tab>\&i" &i"
imenu HTML.Character\ Entities.Umlauts.O-umlaut\ (�)<tab>\&O" &O"
imenu HTML.Character\ Entities.Umlauts.o-umlaut\ (�)<tab>\&o" &o"
imenu HTML.Character\ Entities.Umlauts.U-umlaut\ (�)<tab>\&U" &U"
imenu HTML.Character\ Entities.Umlauts.u-umlaut\ (�)<tab>\&u" &u"
imenu HTML.Character\ Entities.Umlauts.y-umlaut\ (�)<tab>\&y" &y"
imenu HTML.Character\ Entities.Umlauts.Umlaut\ (�)<tab>\&"    &"
imenu HTML.Character\ Entities.\ \ \ \ \ \ \ etc\.\.\..A-ring\ (�)<tab>\&Ao      &Ao
imenu HTML.Character\ Entities.\ \ \ \ \ \ \ etc\.\.\..a-ring\ (�)<tab>\&ao      &ao
imenu HTML.Character\ Entities.\ \ \ \ \ \ \ etc\.\.\..AE-ligature\ (�)<tab>\&AE &AE
imenu HTML.Character\ Entities.\ \ \ \ \ \ \ etc\.\.\..ae-ligature\ (�)<tab>\&ae &ae
imenu HTML.Character\ Entities.\ \ \ \ \ \ \ etc\.\.\..C-cedilla\ (�)<tab>\&C,   &C,
imenu HTML.Character\ Entities.\ \ \ \ \ \ \ etc\.\.\..c-cedilla\ (�)<tab>\&c,   &c,
imenu HTML.Character\ Entities.\ \ \ \ \ \ \ etc\.\.\..O-slash\ (�)<tab>\&O/     &O/
imenu HTML.Character\ Entities.\ \ \ \ \ \ \ etc\.\.\..o-slash\ (�)<tab>\&o/     &o/
" Normal mode versions of the above.  If you change the above, it's usually
" easier to just delete it yank the above, paste it, and run a pair of
" substitute commands.
nmenu HTML.Character\ Entities.Ampersand<tab>\&\&                  i&&<ESC>
nmenu HTML.Character\ Entities.Greaterthan\ (>)<tab>\&>            i&><ESC>
nmenu HTML.Character\ Entities.Lessthan\ (<)<tab>\&<               i&<<ESC>
nmenu HTML.Character\ Entities.Space\ (nonbreaking\)<tab>\&<space> i&<space><ESC>
nmenu HTML.Character\ Entities.Quotation\ mark\ (")<tab>\&'        i&'<ESC>
nmenu HTML.Character\ Entities.Cent\ (�)<tab>\&c\|                 i&c\|<ESC>
nmenu HTML.Character\ Entities.Pound\ (�)<tab>\&#                  i&#<ESC>
nmenu HTML.Character\ Entities.Yen\ (�)<tab>\&Y=                   i&Y=<ESC>
nmenu HTML.Character\ Entities.Left\ Angle\ Quote\ (�)<tab>\&2<    i&2<<ESC>
nmenu HTML.Character\ Entities.Right\ Angle\ Quote\ (�)<tab>\&2>   i&2><ESC>
nmenu HTML.Character\ Entities.Copyright\ (�)<tab>\&cO             i&cO<ESC>
nmenu HTML.Character\ Entities.Registered\ (�)<tab>\&rO            i&rO<ESC>
nmenu HTML.Character\ Entities.Trademark\ (TM)<tab>\&tm            i&tm<ESC>
nmenu HTML.Character\ Entities.Multiply\ (�)<tab>\&x               i&x<ESC>
nmenu HTML.Character\ Entities.Divide\ (�)<tab>\&/                 i&/<ESC>
nmenu HTML.Character\ Entities.Inverted\ Exlamation\ (�)<tab>\&!   i&!<ESC>
nmenu HTML.Character\ Entities.Inverted\ Question\ (�)<tab>\&?     i&?<ESC>
nmenu HTML.Character\ Entities.Degree\ (�)<tab>\&de                i&de<ESC>
nmenu HTML.Character\ Entities.Micro/Greek\ mu\ (�)<tab>\&mu       i&mu<ESC>
nmenu HTML.Character\ Entities.Paragraph\ (�)<tab>\&pa             i&pa<ESC>
nmenu HTML.Character\ Entities.Middle\ Dot\ (�)<tab>\&\.           i&.<ESC>
nmenu HTML.Character\ Entities.One\ Quarter\ (�)<tab>\&14          i&14<ESC>
nmenu HTML.Character\ Entities.One\ Half\ (�)<tab>\&12             i&12<ESC>
nmenu HTML.Character\ Entities.Three\ Quarters\ (�)<tab>\&34       i&34<ESC>
nmenu HTML.Character\ Entities.En\ dash\ (-)<tab>\&n-              i&n-
nmenu HTML.Character\ Entities.Em\ dash\ (--)<tab>\&m-/\&--        i&m-
nmenu HTML.Character\ Entities.Ellipsis\ (\.\.\.)<tab>\&3\.        i&3.
nmenu HTML.Character\ Entities.Graves.A-grave\ (�)<tab>\&A` i&A`<ESC>
nmenu HTML.Character\ Entities.Graves.a-grave\ (�)<tab>\&a` i&a`<ESC>
nmenu HTML.Character\ Entities.Graves.E-grave\ (�)<tab>\&E` i&E`<ESC>
nmenu HTML.Character\ Entities.Graves.e-grave\ (�)<tab>\&e` i&e`<ESC>
nmenu HTML.Character\ Entities.Graves.I-grave\ (�)<tab>\&I` i&I`<ESC>
nmenu HTML.Character\ Entities.Graves.i-grave\ (�)<tab>\&i` i&i`<ESC>
nmenu HTML.Character\ Entities.Graves.O-grave\ (�)<tab>\&O` i&O`<ESC>
nmenu HTML.Character\ Entities.Graves.o-grave\ (�)<tab>\&o` i&o`<ESC>
nmenu HTML.Character\ Entities.Graves.U-grave\ (�)<tab>\&U` i&U`<ESC>
nmenu HTML.Character\ Entities.Graves.u-grave\ (�)<tab>\&u` i&u`<ESC>
nmenu HTML.Character\ Entities.Acutes.A-acute\ (�)<tab>\&A' i&A'<ESC>
nmenu HTML.Character\ Entities.Acutes.a-acute\ (�)<tab>\&a' i&a'<ESC>
nmenu HTML.Character\ Entities.Acutes.E-acute\ (�)<tab>\&E' i&E'<ESC>
nmenu HTML.Character\ Entities.Acutes.e-acute\ (�)<tab>\&e' i&e'<ESC>
nmenu HTML.Character\ Entities.Acutes.I-acute\ (�)<tab>\&I' i&I'<ESC>
nmenu HTML.Character\ Entities.Acutes.i-acute\ (�)<tab>\&i' i&i'<ESC>
nmenu HTML.Character\ Entities.Acutes.O-acute\ (�)<tab>\&O' i&O'<ESC>
nmenu HTML.Character\ Entities.Acutes.o-acute\ (�)<tab>\&o' i&o'<ESC>
nmenu HTML.Character\ Entities.Acutes.U-acute\ (�)<tab>\&U' i&U'<ESC>
nmenu HTML.Character\ Entities.Acutes.u-acute\ (�)<tab>\&u' i&u'<ESC>
nmenu HTML.Character\ Entities.Acutes.Y-acute\ (�)<tab>\&Y' i&Y'<ESC>
nmenu HTML.Character\ Entities.Acutes.y-acute\ (�)<tab>\&y' i&y'<ESC>
nmenu HTML.Character\ Entities.Tildes.A-tilde\ (�)<tab>\&A~ i&A~<ESC>
nmenu HTML.Character\ Entities.Tildes.a-tilde\ (�)<tab>\&a~ i&a~<ESC>
nmenu HTML.Character\ Entities.Tildes.N-tilde\ (�)<tab>\&N~ i&N~<ESC>
nmenu HTML.Character\ Entities.Tildes.n-tilde\ (�)<tab>\&n~ i&n~<ESC>
nmenu HTML.Character\ Entities.Tildes.O-tilde\ (�)<tab>\&O~ i&O~<ESC>
nmenu HTML.Character\ Entities.Tildes.o-tilde\ (�)<tab>\&o~ i&o~<ESC>
nmenu HTML.Character\ Entities.Circumflexes.A-circumflex\ (�)<tab>\&A^ i&A^<ESC>
nmenu HTML.Character\ Entities.Circumflexes.a-circumflex\ (�)<tab>\&a^ i&a^<ESC>
nmenu HTML.Character\ Entities.Circumflexes.E-circumflex\ (�)<tab>\&E^ i&E^<ESC>
nmenu HTML.Character\ Entities.Circumflexes.e-circumflex\ (�)<tab>\&e^ i&e^<ESC>
nmenu HTML.Character\ Entities.Circumflexes.I-circumflex\ (�)<tab>\&I^ i&I^<ESC>
nmenu HTML.Character\ Entities.Circumflexes.i-circumflex\ (�)<tab>\&i^ i&i^<ESC>
nmenu HTML.Character\ Entities.Circumflexes.O-circumflex\ (�)<tab>\&O^ i&O^<ESC>
nmenu HTML.Character\ Entities.Circumflexes.o-circumflex\ (�)<tab>\&o^ i&o^<ESC>
nmenu HTML.Character\ Entities.Circumflexes.U-circumflex\ (�)<tab>\&U^ i&U^<ESC>
nmenu HTML.Character\ Entities.Circumflexes.u-circumflex\ (�)<tab>\&u^ i&u^<ESC>
nmenu HTML.Character\ Entities.Umlauts.A-umlaut\ (�)<tab>\&A" i&A"<ESC>
nmenu HTML.Character\ Entities.Umlauts.a-umlaut\ (�)<tab>\&a" i&a"<ESC>
nmenu HTML.Character\ Entities.Umlauts.E-umlaut\ (�)<tab>\&E" i&E"<ESC>
nmenu HTML.Character\ Entities.Umlauts.e-umlaut\ (�)<tab>\&e" i&e"<ESC>
nmenu HTML.Character\ Entities.Umlauts.I-umlaut\ (�)<tab>\&I" i&I"<ESC>
nmenu HTML.Character\ Entities.Umlauts.i-umlaut\ (�)<tab>\&i" i&i"<ESC>
nmenu HTML.Character\ Entities.Umlauts.O-umlaut\ (�)<tab>\&O" i&O"<ESC>
nmenu HTML.Character\ Entities.Umlauts.o-umlaut\ (�)<tab>\&o" i&o"<ESC>
nmenu HTML.Character\ Entities.Umlauts.U-umlaut\ (�)<tab>\&U" i&U"<ESC>
nmenu HTML.Character\ Entities.Umlauts.u-umlaut\ (�)<tab>\&u" i&u"<ESC>
nmenu HTML.Character\ Entities.Umlauts.y-umlaut\ (�)<tab>\&y" i&y"<ESC>
nmenu HTML.Character\ Entities.Umlauts.Umlaut\ (�)<tab>\&"    i&"<ESC>
nmenu HTML.Character\ Entities.\ \ \ \ \ \ \ etc\.\.\..A-ring\ (�)<tab>\&Ao      i&Ao<ESC>
nmenu HTML.Character\ Entities.\ \ \ \ \ \ \ etc\.\.\..a-ring\ (�)<tab>\&ao      i&ao<ESC>
nmenu HTML.Character\ Entities.\ \ \ \ \ \ \ etc\.\.\..AE-ligature\ (�)<tab>\&AE i&AE<ESC>
nmenu HTML.Character\ Entities.\ \ \ \ \ \ \ etc\.\.\..ae-ligature\ (�)<tab>\&ae i&ae<ESC>
nmenu HTML.Character\ Entities.\ \ \ \ \ \ \ etc\.\.\..C-cedilla\ (�)<tab>\&C,   i&C,<ESC>
nmenu HTML.Character\ Entities.\ \ \ \ \ \ \ etc\.\.\..c-cedilla\ (�)<tab>\&c,   i&c,<ESC>
nmenu HTML.Character\ Entities.\ \ \ \ \ \ \ etc\.\.\..O-slash\ (�)<tab>\&O/     i&O/<ESC>
nmenu HTML.Character\ Entities.\ \ \ \ \ \ \ etc\.\.\..o-slash\ (�)<tab>\&o/     i&o/<ESC>

let &encoding=b:save_encoding
unlet b:save_encoding

" Colors menu:   {{{2

nmenu HTML.Colors.&A.AliceBlue<TAB>(#F0F8FF)            i#F0F8FF<ESC>
nmenu HTML.Colors.&A.AntiqueWhite<TAB>(#FAEBD7)         i#FAEBD7<ESC>
nmenu HTML.Colors.&A.Aqua<TAB>(#00FFFF)                 i#00FFFF<ESC>
nmenu HTML.Colors.&A.Aquamarine<TAB>(#7FFFD4)           i#7FFFD4<ESC>
nmenu HTML.Colors.&A.Azure<TAB>(#F0FFFF)                i#F0FFFF<ESC>

nmenu HTML.Colors.&B.Beige<TAB>(#F5F5DC)                i#F5F5DC<ESC>
nmenu HTML.Colors.&B.Bisque<TAB>(#FFE4C4)               i#FFE4C4<ESC>
nmenu HTML.Colors.&B.Black<TAB>(#000000)                i#000000<ESC>
nmenu HTML.Colors.&B.BlanchedAlmond<TAB>(#FFEBCD)       i#FFEBCD<ESC>
nmenu HTML.Colors.&B.Blue<TAB>(#0000FF)                 i#0000FF<ESC>
nmenu HTML.Colors.&B.BlueViolet<TAB>(#8A2BE2)           i#8A2BE2<ESC>
nmenu HTML.Colors.&B.Brown<TAB>(#A52A2A)                i#A52A2A<ESC>
nmenu HTML.Colors.&B.Burlywood<TAB>(#DEB887)            i#DEB887<ESC>

nmenu HTML.Colors.&C.CadetBlue<TAB>(#5F9EA0)            i#5F9EA0<ESC>
nmenu HTML.Colors.&C.Chartreuse<TAB>(#7FFF00)           i#7FFF00<ESC>
nmenu HTML.Colors.&C.Chocolate<TAB>(#D2691E)            i#D2691E<ESC>
nmenu HTML.Colors.&C.Coral<TAB>(#FF7F50)                i#FF7F50<ESC>
nmenu HTML.Colors.&C.CornflowerBlue<TAB>(#6495ED)       i#6495ED<ESC>
nmenu HTML.Colors.&C.Cornsilk<TAB>(#FFF8DC)             i#FFF8DC<ESC>
nmenu HTML.Colors.&C.Crimson<TAB>(#DC143C)              i#DC143C<ESC>
nmenu HTML.Colors.&C.Cyan<TAB>(#00FFFF)                 i#00FFFF<ESC>

nmenu HTML.Colors.&D.DarkBlue<TAB>(#00008B)             i#00008B<ESC>
nmenu HTML.Colors.&D.DarkCyan<TAB>(#008B8B)             i#008B8B<ESC>
nmenu HTML.Colors.&D.DarkGoldenrod<TAB>(#B8860B)        i#B8860B<ESC>
nmenu HTML.Colors.&D.DarkGray<TAB>(#A9A9A9)             i#A9A9A9<ESC>
nmenu HTML.Colors.&D.DarkGreen<TAB>(#006400)            i#006400<ESC>
nmenu HTML.Colors.&D.DarkKhaki<TAB>(#BDB76B)            i#BDB76B<ESC>
nmenu HTML.Colors.&D.DarkMagenta<TAB>(#8B008B)          i#8B008B<ESC>
nmenu HTML.Colors.&D.DarkOliveGreen<TAB>(#556B2F)       i#556B2F<ESC>
nmenu HTML.Colors.&D.DarkOrange<TAB>(#FF8C00)           i#FF8C00<ESC>
nmenu HTML.Colors.&D.DarkOrchid<TAB>(#9932CC)           i#9932CC<ESC>
nmenu HTML.Colors.&D.DarkRed<TAB>(#8B0000)              i#8B0000<ESC>
nmenu HTML.Colors.&D.DarkSalmon<TAB>(#E9967A)           i#E9967A<ESC>
nmenu HTML.Colors.&D.DarkSeagreen<TAB>(#8FBC8F)         i#8FBC8F<ESC>
nmenu HTML.Colors.&D.DarkSlateBlue<TAB>(#483D8B)        i#483D8B<ESC>
nmenu HTML.Colors.&D.DarkSlateGray<TAB>(#2F4F4F)        i#2F4F4F<ESC>
nmenu HTML.Colors.&D.DarkTurquoise<TAB>(#00CED1)        i#00CED1<ESC>
nmenu HTML.Colors.&D.DarkViolet<TAB>(#9400D3)           i#9400D3<ESC>
nmenu HTML.Colors.&D.DeepPink<TAB>(#FF1493)             i#FF1493<ESC>
nmenu HTML.Colors.&D.DeepSkyblue<TAB>(#00BFFF)          i#00BFFF<ESC>
nmenu HTML.Colors.&D.DimGray<TAB>(#696969)              i#696969<ESC>
nmenu HTML.Colors.&D.Dodgerblue<TAB>(#1E90FF)           i#1E90FF<ESC>

nmenu HTML.Colors.&F.Firebrick<TAB>(#B22222)            i#B22222<ESC>
nmenu HTML.Colors.&F.FloralWhite<TAB>(#FFFAF0)          i#FFFAF0<ESC>
nmenu HTML.Colors.&F.ForestGreen<TAB>(#228B22)          i#228B22<ESC>
nmenu HTML.Colors.&F.Fuchsia<TAB>(#FF00FF)              i#FF00FF<ESC>

nmenu HTML.Colors.&G.Gainsboro<TAB>(#DCDCDC)            i#DCDCDC<ESC>
nmenu HTML.Colors.&G.GhostWhite<TAB>(#F8F8FF)           i#F8F8FF<ESC>
nmenu HTML.Colors.&G.Gold<TAB>(#FFD700)                 i#FFD700<ESC>
nmenu HTML.Colors.&G.Goldenrod<TAB>(#DAA520)            i#DAA520<ESC>
nmenu HTML.Colors.&G.Gray<TAB>(#808080)                 i#808080<ESC>
nmenu HTML.Colors.&G.Green<TAB>(#008000)                i#008000<ESC>
nmenu HTML.Colors.&G.GreenYellow<TAB>(#ADFF2F)          i#ADFF2F<ESC>

nmenu HTML.Colors.&H-K.Honeydew<TAB>(#F0FFF0)           i#F0FFF0<ESC>
nmenu HTML.Colors.&H-K.HotPink<TAB>(#FF69B4)            i#FF69B4<ESC>
nmenu HTML.Colors.&H-K.IndianRed<TAB>(#CD5C5C)          i#CD5C5C<ESC>
nmenu HTML.Colors.&H-K.Indigo<TAB>(#4B0082)             i#4B0082<ESC>
nmenu HTML.Colors.&H-K.Ivory<TAB>(#FFFFF0)              i#FFFFF0<ESC>
nmenu HTML.Colors.&H-K.Khaki<TAB>(#F0E68C)              i#F0E68C<ESC>

nmenu HTML.Colors.&L.Lavender<TAB>(#E6E6FA)             i#E6E6FA<ESC>
nmenu HTML.Colors.&L.LavenderBlush<TAB>(#FFF0F5)        i#FFF0F5<ESC>
nmenu HTML.Colors.&L.LawnGreen<TAB>(#7CFC00)            i#7CFC00<ESC>
nmenu HTML.Colors.&L.LemonChiffon<TAB>(#FFFACD)         i#FFFACD<ESC>
nmenu HTML.Colors.&L.LightBlue<TAB>(#ADD8E6)            i#ADD8E6<ESC>
nmenu HTML.Colors.&L.LightCoral<TAB>(#F08080)           i#F08080<ESC>
nmenu HTML.Colors.&L.LightCyan<TAB>(#E0FFFF)            i#E0FFFF<ESC>
nmenu HTML.Colors.&L.LightGoldenrodYellow<TAB>(#FAFAD2) i#FAFAD2<ESC>
nmenu HTML.Colors.&L.LightGreen<TAB>(#90EE90)           i#90EE90<ESC>
nmenu HTML.Colors.&L.LightGrey<TAB>(#D3D3D3)            i#D3D3D3<ESC>
nmenu HTML.Colors.&L.LightPink<TAB>(#FFB6C1)            i#FFB6C1<ESC>
nmenu HTML.Colors.&L.LightSalmon<TAB>(#FFA07A)          i#FFA07A<ESC>
nmenu HTML.Colors.&L.LightSeaGreen<TAB>(#20B2AA)        i#20B2AA<ESC>
nmenu HTML.Colors.&L.LightSkyBlue<TAB>(#87CEFA)         i#87CEFA<ESC>
nmenu HTML.Colors.&L.LightSlaTegray<TAB>(#778899)       i#778899<ESC>
nmenu HTML.Colors.&L.LightSteelBlue<TAB>(#B0C4DE)       i#B0C4DE<ESC>
nmenu HTML.Colors.&L.LightYellow<TAB>(#FFFFE0)          i#FFFFE0<ESC>
nmenu HTML.Colors.&L.Lime<TAB>(#00FF00)                 i#00FF00<ESC>
nmenu HTML.Colors.&L.LimeGreen<TAB>(#32CD32)            i#32CD32<ESC>
nmenu HTML.Colors.&L.Linen<TAB>(#FAF0E6)                i#FAF0E6<ESC>

nmenu HTML.Colors.&M.Magenta<TAB>(#FF00FF)              i#FF00FF<ESC>
nmenu HTML.Colors.&M.Maroon<TAB>(#800000)               i#800000<ESC>
nmenu HTML.Colors.&M.MediumAquamarine<TAB>(#66CDAA)     i#66CDAA<ESC>
nmenu HTML.Colors.&M.MediumBlue<TAB>(#0000CD)           i#0000CD<ESC>
nmenu HTML.Colors.&M.MediumOrchid<TAB>(#BA55D3)         i#BA55D3<ESC>
nmenu HTML.Colors.&M.MediumPurple<TAB>(#9370DB)         i#9370DB<ESC>
nmenu HTML.Colors.&M.MediumSeaGreen<TAB>(#3CB371)       i#3CB371<ESC>
nmenu HTML.Colors.&M.MediumSlateBlue<TAB>(#7B68EE)      i#7B68EE<ESC>
nmenu HTML.Colors.&M.MediumSpringGreen<TAB>(#00FA9A)    i#00FA9A<ESC>
nmenu HTML.Colors.&M.MediumTurquoise<TAB>(#48D1CC)      i#48D1CC<ESC>
nmenu HTML.Colors.&M.MediumVioletRed<TAB>(#C71585)      i#C71585<ESC>
nmenu HTML.Colors.&M.MidnightBlue<TAB>(#191970)         i#191970<ESC>
nmenu HTML.Colors.&M.Mintcream<TAB>(#F5FFFA)            i#F5FFFA<ESC>
nmenu HTML.Colors.&M.Mistyrose<TAB>(#FFE4E1)            i#FFE4E1<ESC>
nmenu HTML.Colors.&M.Moccasin<TAB>(#FFE4B5)             i#FFE4B5<ESC>

nmenu HTML.Colors.&N.NavajoWhite<TAB>(#FFDEAD)          i#FFDEAD<ESC>
nmenu HTML.Colors.&N.Navy<TAB>(#000080)                 i#000080<ESC>

nmenu HTML.Colors.&O.OldLace<TAB>(#FDF5E6)              i#FDF5E6<ESC>
nmenu HTML.Colors.&O.Olive<TAB>(#808000)                i#808000<ESC>
nmenu HTML.Colors.&O.OliveDrab<TAB>(#6B8E23)            i#6B8E23<ESC>
nmenu HTML.Colors.&O.Orange<TAB>(#FFA500)               i#FFA500<ESC>
nmenu HTML.Colors.&O.OrangeRed<TAB>(#FF4500)            i#FF4500<ESC>
nmenu HTML.Colors.&O.Orchid<TAB>(#DA70D6)               i#DA70D6<ESC>

nmenu HTML.Colors.&P.PaleGoldenrod<TAB>(#EEE8AA)        i#EEE8AA<ESC>
nmenu HTML.Colors.&P.PaleGreen<TAB>(#98FB98)            i#98FB98<ESC>
nmenu HTML.Colors.&P.PaleTurquoise<TAB>(#AFEEEE)        i#AFEEEE<ESC>
nmenu HTML.Colors.&P.PaleVioletred<TAB>(#DB7093)        i#DB7093<ESC>
nmenu HTML.Colors.&P.Papayawhip<TAB>(#FFEFD5)           i#FFEFD5<ESC>
nmenu HTML.Colors.&P.Peachpuff<TAB>(#FFDAB9)            i#FFDAB9<ESC>
nmenu HTML.Colors.&P.Peru<TAB>(#CD853F)                 i#CD853F<ESC>
nmenu HTML.Colors.&P.Pink<TAB>(#FFC0CB)                 i#FFC0CB<ESC>
nmenu HTML.Colors.&P.Plum<TAB>(#DDA0DD)                 i#DDA0DD<ESC>
nmenu HTML.Colors.&P.PowderBlue<TAB>(#B0E0E6)           i#B0E0E6<ESC>
nmenu HTML.Colors.&P.Purple<TAB>(#800080)               i#800080<ESC>

nmenu HTML.Colors.&R.Red<TAB>(#FF0000)                  i#FF0000<ESC>
nmenu HTML.Colors.&R.RosyBrown<TAB>(#BC8F8F)            i#BC8F8F<ESC>
nmenu HTML.Colors.&R.RoyalBlue<TAB>(#4169E1)            i#4169E1<ESC>

nmenu HTML.Colors.&S.SaddleBrown<TAB>(#8B4513)          i#8B4513<ESC>
nmenu HTML.Colors.&S.Salmon<TAB>(#FA8072)               i#FA8072<ESC>
nmenu HTML.Colors.&S.SandyBrown<TAB>(#F4A460)           i#F4A460<ESC>
nmenu HTML.Colors.&S.SeaGreen<TAB>(#2E8B57)             i#2E8B57<ESC>
nmenu HTML.Colors.&S.Seashell<TAB>(#FFF5EE)             i#FFF5EE<ESC>
nmenu HTML.Colors.&S.Sienna<TAB>(#A0522D)               i#A0522D<ESC>
nmenu HTML.Colors.&S.Silver<TAB>(#C0C0C0)               i#C0C0C0<ESC>
nmenu HTML.Colors.&S.SkyBlue<TAB>(#87CEEB)              i#87CEEB<ESC>
nmenu HTML.Colors.&S.SlateBlue<TAB>(#6A5ACD)            i#6A5ACD<ESC>
nmenu HTML.Colors.&S.SlateGray<TAB>(#708090)            i#708090<ESC>
nmenu HTML.Colors.&S.Snow<TAB>(#FFFAFA)                 i#FFFAFA<ESC>
nmenu HTML.Colors.&S.SpringGreen<TAB>(#00FF7F)          i#00FF7F<ESC>
nmenu HTML.Colors.&S.SteelBlue<TAB>(#4682B4)            i#4682B4<ESC>

nmenu HTML.Colors.&T-Z.Tan<TAB>(#D2B48C)                i#D2B48C<ESC>
nmenu HTML.Colors.&T-Z.Teal<TAB>(#008080)               i#008080<ESC>
nmenu HTML.Colors.&T-Z.Thistle<TAB>(#D8BFD8)            i#D8BFD8<ESC>
nmenu HTML.Colors.&T-Z.Tomato<TAB>(#FF6347)             i#FF6347<ESC>
nmenu HTML.Colors.&T-Z.Turquoise<TAB>(#40E0D0)          i#40E0D0<ESC>
nmenu HTML.Colors.&T-Z.Violet<TAB>(#EE82EE)             i#EE82EE<ESC>


imenu HTML.Colors.&A.AliceBlue<TAB>(#F0F8FF)            #F0F8FF
imenu HTML.Colors.&A.AntiqueWhite<TAB>(#FAEBD7)         #FAEBD7
imenu HTML.Colors.&A.Aqua<TAB>(#00FFFF)                 #00FFFF
imenu HTML.Colors.&A.Aquamarine<TAB>(#7FFFD4)           #7FFFD4
imenu HTML.Colors.&A.Azure<TAB>(#F0FFFF)                #F0FFFF

imenu HTML.Colors.&B.Beige<TAB>(#F5F5DC)                #F5F5DC
imenu HTML.Colors.&B.Bisque<TAB>(#FFE4C4)               #FFE4C4
imenu HTML.Colors.&B.Black<TAB>(#000000)                #000000
imenu HTML.Colors.&B.BlanchedAlmond<TAB>(#FFEBCD)       #FFEBCD
imenu HTML.Colors.&B.Blue<TAB>(#0000FF)                 #0000FF
imenu HTML.Colors.&B.BlueViolet<TAB>(#8A2BE2)           #8A2BE2
imenu HTML.Colors.&B.Brown<TAB>(#A52A2A)                #A52A2A
imenu HTML.Colors.&B.Burlywood<TAB>(#DEB887)            #DEB887

imenu HTML.Colors.&C.CadetBlue<TAB>(#5F9EA0)            #5F9EA0
imenu HTML.Colors.&C.Chartreuse<TAB>(#7FFF00)           #7FFF00
imenu HTML.Colors.&C.Chocolate<TAB>(#D2691E)            #D2691E
imenu HTML.Colors.&C.Coral<TAB>(#FF7F50)                #FF7F50
imenu HTML.Colors.&C.CornflowerBlue<TAB>(#6495ED)       #6495ED
imenu HTML.Colors.&C.Cornsilk<TAB>(#FFF8DC)             #FFF8DC
imenu HTML.Colors.&C.Crimson<TAB>(#DC143C)              #DC143C
imenu HTML.Colors.&C.Cyan<TAB>(#00FFFF)                 #00FFFF

imenu HTML.Colors.&D.DarkBlue<TAB>(#00008B)             #00008B
imenu HTML.Colors.&D.DarkCyan<TAB>(#008B8B)             #008B8B
imenu HTML.Colors.&D.DarkGoldenrod<TAB>(#B8860B)        #B8860B
imenu HTML.Colors.&D.DarkGray<TAB>(#A9A9A9)             #A9A9A9
imenu HTML.Colors.&D.DarkGreen<TAB>(#006400)            #006400
imenu HTML.Colors.&D.DarkKhaki<TAB>(#BDB76B)            #BDB76B
imenu HTML.Colors.&D.DarkMagenta<TAB>(#8B008B)          #8B008B
imenu HTML.Colors.&D.DarkOliveGreen<TAB>(#556B2F)       #556B2F
imenu HTML.Colors.&D.DarkOrange<TAB>(#FF8C00)           #FF8C00
imenu HTML.Colors.&D.DarkOrchid<TAB>(#9932CC)           #9932CC
imenu HTML.Colors.&D.DarkRed<TAB>(#8B0000)              #8B0000
imenu HTML.Colors.&D.DarkSalmon<TAB>(#E9967A)           #E9967A
imenu HTML.Colors.&D.DarkSeagreen<TAB>(#8FBC8F)         #8FBC8F
imenu HTML.Colors.&D.DarkSlateBlue<TAB>(#483D8B)        #483D8B
imenu HTML.Colors.&D.DarkSlateGray<TAB>(#2F4F4F)        #2F4F4F
imenu HTML.Colors.&D.DarkTurquoise<TAB>(#00CED1)        #00CED1
imenu HTML.Colors.&D.DarkViolet<TAB>(#9400D3)           #9400D3
imenu HTML.Colors.&D.DeepPink<TAB>(#FF1493)             #FF1493
imenu HTML.Colors.&D.DeepSkyblue<TAB>(#00BFFF)          #00BFFF
imenu HTML.Colors.&D.DimGray<TAB>(#696969)              #696969
imenu HTML.Colors.&D.Dodgerblue<TAB>(#1E90FF)           #1E90FF

imenu HTML.Colors.&F.Firebrick<TAB>(#B22222)            #B22222
imenu HTML.Colors.&F.FloralWhite<TAB>(#FFFAF0)          #FFFAF0
imenu HTML.Colors.&F.ForestGreen<TAB>(#228B22)          #228B22
imenu HTML.Colors.&F.Fuchsia<TAB>(#FF00FF)              #FF00FF

imenu HTML.Colors.&G.Gainsboro<TAB>(#DCDCDC)            #DCDCDC
imenu HTML.Colors.&G.GhostWhite<TAB>(#F8F8FF)           #F8F8FF
imenu HTML.Colors.&G.Gold<TAB>(#FFD700)                 #FFD700
imenu HTML.Colors.&G.Goldenrod<TAB>(#DAA520)            #DAA520
imenu HTML.Colors.&G.Gray<TAB>(#808080)                 #808080
imenu HTML.Colors.&G.Green<TAB>(#008000)                #008000
imenu HTML.Colors.&G.GreenYellow<TAB>(#ADFF2F)          #ADFF2F

imenu HTML.Colors.&H-K.Honeydew<TAB>(#F0FFF0)           #F0FFF0
imenu HTML.Colors.&H-K.HotPink<TAB>(#FF69B4)            #FF69B4
imenu HTML.Colors.&H-K.IndianRed<TAB>(#CD5C5C)          #CD5C5C
imenu HTML.Colors.&H-K.Indigo<TAB>(#4B0082)             #4B0082
imenu HTML.Colors.&H-K.Ivory<TAB>(#FFFFF0)              #FFFFF0
imenu HTML.Colors.&H-K.Khaki<TAB>(#F0E68C)              #F0E68C

imenu HTML.Colors.&L.Lavender<TAB>(#E6E6FA)             #E6E6FA
imenu HTML.Colors.&L.LavenderBlush<TAB>(#FFF0F5)        #FFF0F5
imenu HTML.Colors.&L.LawnGreen<TAB>(#7CFC00)            #7CFC00
imenu HTML.Colors.&L.LemonChiffon<TAB>(#FFFACD)         #FFFACD
imenu HTML.Colors.&L.LightBlue<TAB>(#ADD8E6)            #ADD8E6
imenu HTML.Colors.&L.LightCoral<TAB>(#F08080)           #F08080
imenu HTML.Colors.&L.LightCyan<TAB>(#E0FFFF)            #E0FFFF
imenu HTML.Colors.&L.LightGoldenrodYellow<TAB>(#FAFAD2) #FAFAD2
imenu HTML.Colors.&L.LightGreen<TAB>(#90EE90)           #90EE90
imenu HTML.Colors.&L.LightGrey<TAB>(#D3D3D3)            #D3D3D3
imenu HTML.Colors.&L.LightPink<TAB>(#FFB6C1)            #FFB6C1
imenu HTML.Colors.&L.LightSalmon<TAB>(#FFA07A)          #FFA07A
imenu HTML.Colors.&L.LightSeaGreen<TAB>(#20B2AA)        #20B2AA
imenu HTML.Colors.&L.LightSkyBlue<TAB>(#87CEFA)         #87CEFA
imenu HTML.Colors.&L.LightSlaTegray<TAB>(#778899)       #778899
imenu HTML.Colors.&L.LightSteelBlue<TAB>(#B0C4DE)       #B0C4DE
imenu HTML.Colors.&L.LightYellow<TAB>(#FFFFE0)          #FFFFE0
imenu HTML.Colors.&L.Lime<TAB>(#00FF00)                 #00FF00
imenu HTML.Colors.&L.LimeGreen<TAB>(#32CD32)            #32CD32
imenu HTML.Colors.&L.Linen<TAB>(#FAF0E6)                #FAF0E6

imenu HTML.Colors.&M.Magenta<TAB>(#FF00FF)              #FF00FF
imenu HTML.Colors.&M.Maroon<TAB>(#800000)               #800000
imenu HTML.Colors.&M.MediumAquamarine<TAB>(#66CDAA)     #66CDAA
imenu HTML.Colors.&M.MediumBlue<TAB>(#0000CD)           #0000CD
imenu HTML.Colors.&M.MediumOrchid<TAB>(#BA55D3)         #BA55D3
imenu HTML.Colors.&M.MediumPurple<TAB>(#9370DB)         #9370DB
imenu HTML.Colors.&M.MediumSeaGreen<TAB>(#3CB371)       #3CB371
imenu HTML.Colors.&M.MediumSlateBlue<TAB>(#7B68EE)      #7B68EE
imenu HTML.Colors.&M.MediumSpringGreen<TAB>(#00FA9A)    #00FA9A
imenu HTML.Colors.&M.MediumTurquoise<TAB>(#48D1CC)      #48D1CC
imenu HTML.Colors.&M.MediumVioletRed<TAB>(#C71585)      #C71585
imenu HTML.Colors.&M.MidnightBlue<TAB>(#191970)         #191970
imenu HTML.Colors.&M.Mintcream<TAB>(#F5FFFA)            #F5FFFA
imenu HTML.Colors.&M.Mistyrose<TAB>(#FFE4E1)            #FFE4E1
imenu HTML.Colors.&M.Moccasin<TAB>(#FFE4B5)             #FFE4B5

imenu HTML.Colors.&N.NavajoWhite<TAB>(#FFDEAD)          #FFDEAD
imenu HTML.Colors.&N.Navy<TAB>(#000080)                 #000080

imenu HTML.Colors.&O.OldLace<TAB>(#FDF5E6)              #FDF5E6
imenu HTML.Colors.&O.Olive<TAB>(#808000)                #808000
imenu HTML.Colors.&O.OliveDrab<TAB>(#6B8E23)            #6B8E23
imenu HTML.Colors.&O.Orange<TAB>(#FFA500)               #FFA500
imenu HTML.Colors.&O.OrangeRed<TAB>(#FF4500)            #FF4500
imenu HTML.Colors.&O.Orchid<TAB>(#DA70D6)               #DA70D6

imenu HTML.Colors.&P.PaleGoldenrod<TAB>(#EEE8AA)        #EEE8AA
imenu HTML.Colors.&P.PaleGreen<TAB>(#98FB98)            #98FB98
imenu HTML.Colors.&P.PaleTurquoise<TAB>(#AFEEEE)        #AFEEEE
imenu HTML.Colors.&P.PaleVioletred<TAB>(#DB7093)        #DB7093
imenu HTML.Colors.&P.Papayawhip<TAB>(#FFEFD5)           #FFEFD5
imenu HTML.Colors.&P.Peachpuff<TAB>(#FFDAB9)            #FFDAB9
imenu HTML.Colors.&P.Peru<TAB>(#CD853F)                 #CD853F
imenu HTML.Colors.&P.Pink<TAB>(#FFC0CB)                 #FFC0CB
imenu HTML.Colors.&P.Plum<TAB>(#DDA0DD)                 #DDA0DD
imenu HTML.Colors.&P.PowderBlue<TAB>(#B0E0E6)           #B0E0E6
imenu HTML.Colors.&P.Purple<TAB>(#800080)               #800080

imenu HTML.Colors.&R.Red<TAB>(#FF0000)                  #FF0000
imenu HTML.Colors.&R.RosyBrown<TAB>(#BC8F8F)            #BC8F8F
imenu HTML.Colors.&R.RoyalBlue<TAB>(#4169E1)            #4169E1

imenu HTML.Colors.&S.SaddleBrown<TAB>(#8B4513)          #8B4513
imenu HTML.Colors.&S.Salmon<TAB>(#FA8072)               #FA8072
imenu HTML.Colors.&S.SandyBrown<TAB>(#F4A460)           #F4A460
imenu HTML.Colors.&S.SeaGreen<TAB>(#2E8B57)             #2E8B57
imenu HTML.Colors.&S.Seashell<TAB>(#FFF5EE)             #FFF5EE
imenu HTML.Colors.&S.Sienna<TAB>(#A0522D)               #A0522D
imenu HTML.Colors.&S.Silver<TAB>(#C0C0C0)               #C0C0C0
imenu HTML.Colors.&S.SkyBlue<TAB>(#87CEEB)              #87CEEB
imenu HTML.Colors.&S.SlateBlue<TAB>(#6A5ACD)            #6A5ACD
imenu HTML.Colors.&S.SlateGray<TAB>(#708090)            #708090
imenu HTML.Colors.&S.Snow<TAB>(#FFFAFA)                 #FFFAFA
imenu HTML.Colors.&S.SpringGreen<TAB>(#00FF7F)          #00FF7F
imenu HTML.Colors.&S.SteelBlue<TAB>(#4682B4)            #4682B4

imenu HTML.Colors.&T-Z.Tan<TAB>(#D2B48C)                #D2B48C
imenu HTML.Colors.&T-Z.Teal<TAB>(#008080)               #008080
imenu HTML.Colors.&T-Z.Thistle<TAB>(#D8BFD8)            #D8BFD8
imenu HTML.Colors.&T-Z.Tomato<TAB>(#FF6347)             #FF6347
imenu HTML.Colors.&T-Z.Turquoise<TAB>(#40E0D0)          #40E0D0
imenu HTML.Colors.&T-Z.Violet<TAB>(#EE82EE)             #EE82EE

" Font Styles menu:   {{{2

exe 'imenu HTML.Font\ Styles.Bold<tab>' . g:html_map_leader . 'bo' g:html_map_leader . 'bo'
exe 'vmenu HTML.Font\ Styles.Bold<tab>' . g:html_map_leader . 'bo' g:html_map_leader . 'bo'
exe 'nmenu HTML.Font\ Styles.Bold<tab>' . g:html_map_leader . 'bo' 'i' . g:html_map_leader . 'bo'
exe 'imenu HTML.Font\ Styles.Italics<tab>' . g:html_map_leader . 'it' g:html_map_leader . 'it'
exe 'vmenu HTML.Font\ Styles.Italics<tab>' . g:html_map_leader . 'it' g:html_map_leader . 'it'
exe 'nmenu HTML.Font\ Styles.Italics<tab>' . g:html_map_leader . 'it' 'i' . g:html_map_leader . 'it'
exe 'imenu HTML.Font\ Styles.Underline<tab>' . g:html_map_leader . 'un' g:html_map_leader . 'un'
exe 'vmenu HTML.Font\ Styles.Underline<tab>' . g:html_map_leader . 'un' g:html_map_leader . 'un'
exe 'nmenu HTML.Font\ Styles.Underline<tab>' . g:html_map_leader . 'un' 'i' . g:html_map_leader . 'un'
exe 'imenu HTML.Font\ Styles.Big<tab>' . g:html_map_leader . 'bi' g:html_map_leader . 'bi'
exe 'vmenu HTML.Font\ Styles.Big<tab>' . g:html_map_leader . 'bi' g:html_map_leader . 'bi'
exe 'nmenu HTML.Font\ Styles.Big<tab>' . g:html_map_leader . 'bi' 'i' . g:html_map_leader . 'bi'
exe 'imenu HTML.Font\ Styles.Small<tab>' . g:html_map_leader . 'sm' g:html_map_leader . 'sm'
exe 'vmenu HTML.Font\ Styles.Small<tab>' . g:html_map_leader . 'sm' g:html_map_leader . 'sm'
exe 'nmenu HTML.Font\ Styles.Small<tab>' . g:html_map_leader . 'sm' 'i' . g:html_map_leader . 'sm'
 menu HTML.Font\ Styles.-sep1- <nul>
exe 'imenu HTML.Font\ Styles.Font\ Size<tab>' . g:html_map_leader . 'fo' g:html_map_leader . 'fo'
exe 'vmenu HTML.Font\ Styles.Font\ Size<tab>' . g:html_map_leader . 'fo' g:html_map_leader . 'fo'
exe 'nmenu HTML.Font\ Styles.Font\ Size<tab>' . g:html_map_leader . 'fo' 'i' . g:html_map_leader . 'fo'
exe 'imenu HTML.Font\ Styles.Font\ Color<tab>' . g:html_map_leader . 'fc' g:html_map_leader . 'fc'
exe 'vmenu HTML.Font\ Styles.Font\ Color<tab>' . g:html_map_leader . 'fc' g:html_map_leader . 'fc'
exe 'nmenu HTML.Font\ Styles.Font\ Color<tab>' . g:html_map_leader . 'fc' 'i' . g:html_map_leader . 'fc'
 menu HTML.Font\ Styles.-sep2- <nul>
exe 'imenu HTML.Font\ Styles.CITE<tab>' . g:html_map_leader . 'ci' g:html_map_leader . 'ci'
exe 'vmenu HTML.Font\ Styles.CITE<tab>' . g:html_map_leader . 'ci' g:html_map_leader . 'ci'
exe 'nmenu HTML.Font\ Styles.CITE<tab>' . g:html_map_leader . 'ci' 'i' . g:html_map_leader . 'ci'
exe 'imenu HTML.Font\ Styles.CODE<tab>' . g:html_map_leader . 'co' g:html_map_leader . 'co'
exe 'vmenu HTML.Font\ Styles.CODE<tab>' . g:html_map_leader . 'co' g:html_map_leader . 'co'
exe 'nmenu HTML.Font\ Styles.CODE<tab>' . g:html_map_leader . 'co' 'i' . g:html_map_leader . 'co'
exe 'imenu HTML.Font\ Styles.Inserted\ Text<tab>' . g:html_map_leader . 'in' g:html_map_leader . 'in'
exe 'vmenu HTML.Font\ Styles.Inserted\ Text<tab>' . g:html_map_leader . 'in' g:html_map_leader . 'in'
exe 'nmenu HTML.Font\ Styles.Inserted\ Text<tab>' . g:html_map_leader . 'in' 'i' . g:html_map_leader . 'in'
exe 'imenu HTML.Font\ Styles.Deleted\ Text<tab>' . g:html_map_leader . 'de' g:html_map_leader . 'de'
exe 'vmenu HTML.Font\ Styles.Deleted\ Text<tab>' . g:html_map_leader . 'de' g:html_map_leader . 'de'
exe 'nmenu HTML.Font\ Styles.Deleted\ Text<tab>' . g:html_map_leader . 'de' 'i' . g:html_map_leader . 'de'
exe 'imenu HTML.Font\ Styles.Emphasize<tab>' . g:html_map_leader . 'em' g:html_map_leader . 'em'
exe 'vmenu HTML.Font\ Styles.Emphasize<tab>' . g:html_map_leader . 'em' g:html_map_leader . 'em'
exe 'nmenu HTML.Font\ Styles.Emphasize<tab>' . g:html_map_leader . 'em' 'i' . g:html_map_leader . 'em'
exe 'imenu HTML.Font\ Styles.Keyboard\ Text<tab>' . g:html_map_leader . 'kb' g:html_map_leader . 'kb'
exe 'vmenu HTML.Font\ Styles.Keyboard\ Text<tab>' . g:html_map_leader . 'kb' g:html_map_leader . 'kb'
exe 'nmenu HTML.Font\ Styles.Keyboard\ Text<tab>' . g:html_map_leader . 'kb' 'i' . g:html_map_leader . 'kb'
exe 'imenu HTML.Font\ Styles.Sample\ Text<tab>' . g:html_map_leader . 'sa' g:html_map_leader . 'sa'
exe 'vmenu HTML.Font\ Styles.Sample\ Text<tab>' . g:html_map_leader . 'sa' g:html_map_leader . 'sa'
exe 'nmenu HTML.Font\ Styles.Sample\ Text<tab>' . g:html_map_leader . 'sa' 'i' . g:html_map_leader . 'sa'
exe 'imenu HTML.Font\ Styles.Strikethrough<tab>' . g:html_map_leader . 'sk' g:html_map_leader . 'sk'
exe 'vmenu HTML.Font\ Styles.Strikethrough<tab>' . g:html_map_leader . 'sk' g:html_map_leader . 'sk'
exe 'nmenu HTML.Font\ Styles.Strikethrough<tab>' . g:html_map_leader . 'sk' 'i' . g:html_map_leader . 'sk'
exe 'imenu HTML.Font\ Styles.STRONG<tab>' . g:html_map_leader . 'st' g:html_map_leader . 'st'
exe 'vmenu HTML.Font\ Styles.STRONG<tab>' . g:html_map_leader . 'st' g:html_map_leader . 'st'
exe 'nmenu HTML.Font\ Styles.STRONG<tab>' . g:html_map_leader . 'st' 'i' . g:html_map_leader . 'st'
exe 'imenu HTML.Font\ Styles.Subscript<tab>' . g:html_map_leader . 'sb' g:html_map_leader . 'sb'
exe 'vmenu HTML.Font\ Styles.Subscript<tab>' . g:html_map_leader . 'sb' g:html_map_leader . 'sb'
exe 'nmenu HTML.Font\ Styles.Subscript<tab>' . g:html_map_leader . 'sb' 'i' . g:html_map_leader . 'sb'
exe 'imenu HTML.Font\ Styles.Superscript<tab>' . g:html_map_leader . 'sp' g:html_map_leader . 'sp'
exe 'vmenu HTML.Font\ Styles.Superscript<tab>' . g:html_map_leader . 'sp' g:html_map_leader . 'sp'
exe 'nmenu HTML.Font\ Styles.Superscript<tab>' . g:html_map_leader . 'sp' 'i' . g:html_map_leader . 'sp'
exe 'imenu HTML.Font\ Styles.Teletype\ Text<tab>' . g:html_map_leader . 'tt' g:html_map_leader . 'tt'
exe 'vmenu HTML.Font\ Styles.Teletype\ Text<tab>' . g:html_map_leader . 'tt' g:html_map_leader . 'tt'
exe 'nmenu HTML.Font\ Styles.Teletype\ Text<tab>' . g:html_map_leader . 'tt' 'i' . g:html_map_leader . 'tt'
exe 'imenu HTML.Font\ Styles.Variable<tab>' . g:html_map_leader . 'va' g:html_map_leader . 'va'
exe 'vmenu HTML.Font\ Styles.Variable<tab>' . g:html_map_leader . 'va' g:html_map_leader . 'va'
exe 'nmenu HTML.Font\ Styles.Variable<tab>' . g:html_map_leader . 'va' 'i' . g:html_map_leader . 'va'


" Frames menu:   {{{2

exe 'imenu HTML.Frames.FRAMESET<tab>' . g:html_map_leader . 'fs' g:html_map_leader . 'fs'
exe 'vmenu HTML.Frames.FRAMESET<tab>' . g:html_map_leader . 'fs' g:html_map_leader . 'fs'
exe 'nmenu HTML.Frames.FRAMESET<tab>' . g:html_map_leader . 'fs' 'i' . g:html_map_leader . 'fs'
exe 'imenu HTML.Frames.FRAME<tab>' . g:html_map_leader . 'fr' g:html_map_leader . 'fr'
exe 'vmenu HTML.Frames.FRAME<tab>' . g:html_map_leader . 'fr' g:html_map_leader . 'fr'
exe 'nmenu HTML.Frames.FRAME<tab>' . g:html_map_leader . 'fr' 'i' . g:html_map_leader . 'fr'
exe 'imenu HTML.Frames.NOFRAMES<tab>' . g:html_map_leader . 'nf' g:html_map_leader . 'nf'
exe 'vmenu HTML.Frames.NOFRAMES<tab>' . g:html_map_leader . 'nf' g:html_map_leader . 'nf'
exe 'nmenu HTML.Frames.NOFRAMES<tab>' . g:html_map_leader . 'nf' 'i' . g:html_map_leader . 'nf'
exe 'imenu HTML.Frames.IFRAME<tab>' . g:html_map_leader . 'if' g:html_map_leader . 'if'
exe 'vmenu HTML.Frames.IFRAME<tab>' . g:html_map_leader . 'if' g:html_map_leader . 'if'
exe 'nmenu HTML.Frames.IFRAME<tab>' . g:html_map_leader . 'if' 'i' . g:html_map_leader . 'if'


" Headers menu:   {{{2

exe 'imenu HTML.Headers.Header\ Level\ 1<tab>' . g:html_map_leader . 'h1' g:html_map_leader . 'h1'
exe 'imenu HTML.Headers.Header\ Level\ 2<tab>' . g:html_map_leader . 'h2' g:html_map_leader . 'h2'
exe 'imenu HTML.Headers.Header\ Level\ 3<tab>' . g:html_map_leader . 'h3' g:html_map_leader . 'h3'
exe 'imenu HTML.Headers.Header\ Level\ 4<tab>' . g:html_map_leader . 'h4' g:html_map_leader . 'h4'
exe 'imenu HTML.Headers.Header\ Level\ 5<tab>' . g:html_map_leader . 'h5' g:html_map_leader . 'h5'
exe 'imenu HTML.Headers.Header\ Level\ 6<tab>' . g:html_map_leader . 'h6' g:html_map_leader . 'h6'
exe 'vmenu HTML.Headers.Header\ Level\ 1<tab>' . g:html_map_leader . 'h1' g:html_map_leader . 'h1'
exe 'vmenu HTML.Headers.Header\ Level\ 2<tab>' . g:html_map_leader . 'h2' g:html_map_leader . 'h2'
exe 'vmenu HTML.Headers.Header\ Level\ 3<tab>' . g:html_map_leader . 'h3' g:html_map_leader . 'h3'
exe 'vmenu HTML.Headers.Header\ Level\ 4<tab>' . g:html_map_leader . 'h4' g:html_map_leader . 'h4'
exe 'vmenu HTML.Headers.Header\ Level\ 5<tab>' . g:html_map_leader . 'h5' g:html_map_leader . 'h5'
exe 'vmenu HTML.Headers.Header\ Level\ 6<tab>' . g:html_map_leader . 'h6' g:html_map_leader . 'h6'
exe 'nmenu HTML.Headers.Header\ Level\ 1<tab>' . g:html_map_leader . 'h1' 'i' . g:html_map_leader . 'h1'
exe 'nmenu HTML.Headers.Header\ Level\ 2<tab>' . g:html_map_leader . 'h2' 'i' . g:html_map_leader . 'h2'
exe 'nmenu HTML.Headers.Header\ Level\ 3<tab>' . g:html_map_leader . 'h3' 'i' . g:html_map_leader . 'h3'
exe 'nmenu HTML.Headers.Header\ Level\ 4<tab>' . g:html_map_leader . 'h4' 'i' . g:html_map_leader . 'h4'
exe 'nmenu HTML.Headers.Header\ Level\ 5<tab>' . g:html_map_leader . 'h5' 'i' . g:html_map_leader . 'h5'
exe 'nmenu HTML.Headers.Header\ Level\ 6<tab>' . g:html_map_leader . 'h6' 'i' . g:html_map_leader . 'h6'


" Lists menu:   {{{2

exe 'imenu HTML.Lists.Ordered\ List<tab>' . g:html_map_leader . 'ol' g:html_map_leader . 'ol'
exe 'vmenu HTML.Lists.Ordered\ List<tab>' . g:html_map_leader . 'ol' g:html_map_leader . 'ol'
exe 'nmenu HTML.Lists.Ordered\ List<tab>' . g:html_map_leader . 'ol' 'i' . g:html_map_leader . 'ol'
exe 'imenu HTML.Lists.Unordered\ List<tab>' . g:html_map_leader . 'ul' g:html_map_leader . 'ul'
exe 'vmenu HTML.Lists.Unordered\ List<tab>' . g:html_map_leader . 'ul' g:html_map_leader . 'ul'
exe 'nmenu HTML.Lists.Unordered\ List<tab>' . g:html_map_leader . 'ul' 'i' . g:html_map_leader . 'ul'
exe 'imenu HTML.Lists.List\ Item<tab>' . g:html_map_leader . 'li' g:html_map_leader . 'li'
exe 'nmenu HTML.Lists.List\ Item<tab>' . g:html_map_leader . 'li' 'i' . g:html_map_leader . 'li'
exe 'imenu HTML.Lists.List\ Header<tab>' . g:html_map_leader . 'lh' g:html_map_leader . 'lh'
exe 'vmenu HTML.Lists.List\ Header<tab>' . g:html_map_leader . 'lh' g:html_map_leader . 'lh'
exe 'nmenu HTML.Lists.List\ Header<tab>' . g:html_map_leader . 'lh' 'i' . g:html_map_leader . 'lh'
 menu HTML.Lists.-sep1- <nul>
exe 'imenu HTML.Lists.Definition\ List<tab>' . g:html_map_leader . 'dl' g:html_map_leader . 'dl'
exe 'vmenu HTML.Lists.Definition\ List<tab>' . g:html_map_leader . 'dl' g:html_map_leader . 'dl'
exe 'nmenu HTML.Lists.Definition\ List<tab>' . g:html_map_leader . 'dl' 'i' . g:html_map_leader . 'dl'
exe 'imenu HTML.Lists.Definition\ Term<tab>' . g:html_map_leader . 'dt' g:html_map_leader . 'dt'
exe 'nmenu HTML.Lists.Definition\ Term<tab>' . g:html_map_leader . 'dt' 'i' . g:html_map_leader . 'dt'
exe 'imenu HTML.Lists.Definition\ Body<tab>' . g:html_map_leader . 'dd' g:html_map_leader . 'dd'
exe 'nmenu HTML.Lists.Definition\ Body<tab>' . g:html_map_leader . 'dd' 'i' . g:html_map_leader . 'dd'


" Tables menu:   {{{2

exe 'nmenu HTML.Tables.Interactive\ Table<tab>' . g:html_map_leader . 'ta' g:html_map_leader . 'ta'
exe 'imenu HTML.Tables.TABLE<tab>' . g:html_map_leader . 'ta' g:html_map_leader . 'ta'
exe 'vmenu HTML.Tables.TABLE<tab>' . g:html_map_leader . 'ta' g:html_map_leader . 'ta'
exe '"nmenu HTML.Tables.TABLE<tab>' . g:html_map_leader . 'ta' 'i' . g:html_map_leader . 'ta'
exe 'imenu HTML.Tables.Row<TAB>' . g:html_map_leader . 'tr' g:html_map_leader . 'tr'
exe 'vmenu HTML.Tables.Row<TAB>' . g:html_map_leader . 'tr' g:html_map_leader . 'tr'
exe 'nmenu HTML.Tables.Row<TAB>' . g:html_map_leader . 'tr' 'i' . g:html_map_leader . 'tr'
exe 'imenu HTML.Tables.Data<tab>' . g:html_map_leader . 'td' g:html_map_leader . 'td'
exe 'vmenu HTML.Tables.Data<tab>' . g:html_map_leader . 'td' g:html_map_leader . 'td'
exe 'nmenu HTML.Tables.Data<tab>' . g:html_map_leader . 'td' 'i' . g:html_map_leader . 'td'
exe 'imenu HTML.Tables.CAPTION<tab>' . g:html_map_leader . 'ca' g:html_map_leader . 'ca'
exe 'vmenu HTML.Tables.CAPTION<tab>' . g:html_map_leader . 'ca' g:html_map_leader . 'ca'
exe 'nmenu HTML.Tables.CAPTION<tab>' . g:html_map_leader . 'ca' 'i' . g:html_map_leader . 'ca'
exe 'imenu HTML.Tables.Header<tab>' . g:html_map_leader . 'th' g:html_map_leader . 'th'
exe 'vmenu HTML.Tables.Header<tab>' . g:html_map_leader . 'th' g:html_map_leader . 'th'
exe 'nmenu HTML.Tables.Header<tab>' . g:html_map_leader . 'th' 'i' . g:html_map_leader . 'th'


" Forms menu:   {{{2

exe 'imenu HTML.Forms.FORM<TAB>' . g:html_map_leader . 'fm' g:html_map_leader . 'fm'
exe 'vmenu HTML.Forms.FORM<TAB>' . g:html_map_leader . 'fm' g:html_map_leader . 'fm'
exe 'nmenu HTML.Forms.FORM<TAB>' . g:html_map_leader . 'fm' 'i' . g:html_map_leader . 'fm'
exe 'imenu HTML.Forms.BUTTON<TAB>' . g:html_map_leader . 'bu' g:html_map_leader . 'bu'
exe 'vmenu HTML.Forms.BUTTON<TAB>' . g:html_map_leader . 'bu' g:html_map_leader . 'bu'
exe 'nmenu HTML.Forms.BUTTON<TAB>' . g:html_map_leader . 'bu' 'i' . g:html_map_leader . 'bu'
exe 'imenu HTML.Forms.CHECKBOX<TAB>' . g:html_map_leader . 'ch' g:html_map_leader . 'ch'
exe 'vmenu HTML.Forms.CHECKBOX<TAB>' . g:html_map_leader . 'ch' g:html_map_leader . 'ch'
exe 'nmenu HTML.Forms.CHECKBOX<TAB>' . g:html_map_leader . 'ch' 'i' . g:html_map_leader . 'ch'
exe 'imenu HTML.Forms.RADIO<TAB>' . g:html_map_leader . 'ra' g:html_map_leader . 'ra'
exe 'vmenu HTML.Forms.RADIO<TAB>' . g:html_map_leader . 'ra' g:html_map_leader . 'ra'
exe 'nmenu HTML.Forms.RADIO<TAB>' . g:html_map_leader . 'ra' 'i' . g:html_map_leader . 'ra'
exe 'imenu HTML.Forms.HIDDEN<TAB>' . g:html_map_leader . 'hi' g:html_map_leader . 'hi'
exe 'vmenu HTML.Forms.HIDDEN<TAB>' . g:html_map_leader . 'hi' g:html_map_leader . 'hi'
exe 'nmenu HTML.Forms.HIDDEN<TAB>' . g:html_map_leader . 'hi' 'i' . g:html_map_leader . 'hi'
exe 'imenu HTML.Forms.PASSWORD<TAB>' . g:html_map_leader . 'pa' g:html_map_leader . 'pa'
exe 'vmenu HTML.Forms.PASSWORD<TAB>' . g:html_map_leader . 'pa' g:html_map_leader . 'pa'
exe 'nmenu HTML.Forms.PASSWORD<TAB>' . g:html_map_leader . 'pa' 'i' . g:html_map_leader . 'pa'
exe 'imenu HTML.Forms.TEXT<TAB>' . g:html_map_leader . 'te' g:html_map_leader . 'te'
exe 'vmenu HTML.Forms.TEXT<TAB>' . g:html_map_leader . 'te' g:html_map_leader . 'te'
exe 'nmenu HTML.Forms.TEXT<TAB>' . g:html_map_leader . 'te' 'i' . g:html_map_leader . 'te'
exe 'imenu HTML.Forms.SELECT<TAB>' . g:html_map_leader . 'se' g:html_map_leader . 'se'
exe 'vmenu HTML.Forms.SELECT<TAB>' . g:html_map_leader . 'se' g:html_map_leader . 'se'
exe 'nmenu HTML.Forms.SELECT<TAB>' . g:html_map_leader . 'se' 'i' . g:html_map_leader . 'se'
exe 'imenu HTML.Forms.SELECT\ MULTIPLE<TAB>' . g:html_map_leader . 'ms' g:html_map_leader . 'ms'
exe 'vmenu HTML.Forms.SELECT\ MULTIPLE<TAB>' . g:html_map_leader . 'ms' g:html_map_leader . 'ms'
exe 'nmenu HTML.Forms.SELECT\ MULTIPLE<TAB>' . g:html_map_leader . 'ms' 'i' . g:html_map_leader . 'ms'
exe 'imenu HTML.Forms.OPTION<TAB>' . g:html_map_leader . 'op' g:html_map_leader . 'op'
exe 'vmenu HTML.Forms.OPTION<TAB>' . g:html_map_leader . 'op' '<ESC>a' g:html_map_leader . 'op'
exe 'nmenu HTML.Forms.OPTION<TAB>' . g:html_map_leader . 'op' 'i' . g:html_map_leader . 'op'
exe 'imenu HTML.Forms.OPTGROUP<TAB>' . g:html_map_leader . 'og' g:html_map_leader . 'og'
exe 'vmenu HTML.Forms.OPTGROUP<TAB>' . g:html_map_leader . 'og' g:html_map_leader . 'og'
exe 'nmenu HTML.Forms.OPTGROUP<TAB>' . g:html_map_leader . 'og' 'i' . g:html_map_leader . 'og'
exe 'imenu HTML.Forms.TEXTAREA<TAB>' . g:html_map_leader . 'tx' g:html_map_leader . 'tx'
exe 'vmenu HTML.Forms.TEXTAREA<TAB>' . g:html_map_leader . 'tx' g:html_map_leader . 'tx'
exe 'nmenu HTML.Forms.TEXTAREA<TAB>' . g:html_map_leader . 'tx' 'i' . g:html_map_leader . 'tx'
exe 'imenu HTML.Forms.SUBMIT<TAB>' . g:html_map_leader . 'su' g:html_map_leader . 'su'
exe 'vmenu HTML.Forms.SUBMIT<TAB>' . g:html_map_leader . 'su' '<ESC>a' . g:html_map_leader . 'su'
exe 'nmenu HTML.Forms.SUBMIT<TAB>' . g:html_map_leader . 'su' 'a' . g:html_map_leader . 'su'
exe 'imenu HTML.Forms.RESET<TAB>' . g:html_map_leader . 're' g:html_map_leader . 're'
exe 'vmenu HTML.Forms.RESET<TAB>' . g:html_map_leader . 're' '<ESC>a' . g:html_map_leader . 're'
exe 'nmenu HTML.Forms.RESET<TAB>' . g:html_map_leader . 're' 'a' . g:html_map_leader . 're'
exe 'imenu HTML.Forms.LABEL<TAB>' . g:html_map_leader . 'la' g:html_map_leader . 'la'
exe 'vmenu HTML.Forms.LABEL<TAB>' . g:html_map_leader . 'la' g:html_map_leader . 'la'
exe 'nmenu HTML.Forms.LABEL<TAB>' . g:html_map_leader . 'la' 'a' . g:html_map_leader . 'la'

" }}}2

 menu HTML.-sep2- <nul>

exe 'imenu HTML.BODY<tab>' . g:html_map_leader . 'bd' g:html_map_leader . 'bd'
exe 'vmenu HTML.BODY<tab>' . g:html_map_leader . 'bd' g:html_map_leader . 'bd'
exe 'nmenu HTML.BODY<tab>' . g:html_map_leader . 'bd' 'i' . g:html_map_leader . 'bd'
exe 'imenu HTML.CENTER<tab>' . g:html_map_leader . 'ce' g:html_map_leader . 'ce'
exe 'vmenu HTML.CENTER<tab>' . g:html_map_leader . 'ce' g:html_map_leader . 'ce'
exe 'nmenu HTML.CENTER<tab>' . g:html_map_leader . 'ce' 'i' . g:html_map_leader . 'ce'
exe 'imenu HTML.Comment<tab>' . g:html_map_leader . 'cm' g:html_map_leader . 'cm'
exe 'vmenu HTML.Comment<tab>' . g:html_map_leader . 'cm' g:html_map_leader . 'cm'
exe 'nmenu HTML.Comment<tab>' . g:html_map_leader . 'cm' 'i' . g:html_map_leader . 'cm'
exe 'imenu HTML.HEAD<tab>' . g:html_map_leader . 'he' g:html_map_leader . 'he'
exe 'vmenu HTML.HEAD<tab>' . g:html_map_leader . 'he' g:html_map_leader . 'he'
exe 'nmenu HTML.HEAD<tab>' . g:html_map_leader . 'he' 'i' . g:html_map_leader . 'he'
exe 'imenu HTML.Horizontal\ Rule<tab>' . g:html_map_leader . 'hr' g:html_map_leader . 'hr'
exe 'nmenu HTML.Horizontal\ Rule<tab>' . g:html_map_leader . 'hr' 'i' . g:html_map_leader . 'hr'
exe 'imenu HTML.HTML<tab>' . g:html_map_leader . 'ht' g:html_map_leader . 'ht'
exe 'vmenu HTML.HTML<tab>' . g:html_map_leader . 'ht' g:html_map_leader . 'ht'
exe 'nmenu HTML.HTML<tab>' . g:html_map_leader . 'ht' 'i' . g:html_map_leader . 'ht'
exe 'imenu HTML.Hyperlink<tab>' . g:html_map_leader . 'ah' g:html_map_leader . 'ah'
exe 'vmenu HTML.Hyperlink<tab>' . g:html_map_leader . 'ah' g:html_map_leader . 'ah'
exe 'nmenu HTML.Hyperlink<tab>' . g:html_map_leader . 'ah' 'i' . g:html_map_leader . 'ah'
exe 'imenu HTML.Inline\ Image<tab>' . g:html_map_leader . 'im' g:html_map_leader . 'im'
exe 'vmenu HTML.Inline\ Image<tab>' . g:html_map_leader . 'im' g:html_map_leader . 'im'
exe 'nmenu HTML.Inline\ Image<tab>' . g:html_map_leader . 'im' 'i' . g:html_map_leader . 'im'
if exists("*MangleImageTag")
  exe 'imenu HTML.Update\ Image\ Size\ Attributes<tab>' . g:html_map_leader . 'mi' g:html_map_leader . 'mi'
  exe 'nmenu HTML.Update\ Image\ Size\ Attributes<tab>' . g:html_map_leader . 'mi' g:html_map_leader . 'mi'
endif
exe 'imenu HTML.Line\ Break<tab>' . g:html_map_leader . 'br' g:html_map_leader . 'br'
exe 'nmenu HTML.Line\ Break<tab>' . g:html_map_leader . 'br' 'i' . g:html_map_leader . 'br'
exe 'imenu HTML.Named\ Anchor<tab>' . g:html_map_leader . 'an' g:html_map_leader . 'an'
exe 'vmenu HTML.Named\ Anchor<tab>' . g:html_map_leader . 'an' g:html_map_leader . 'an'
exe 'nmenu HTML.Named\ Anchor<tab>' . g:html_map_leader . 'an' 'i' . g:html_map_leader . 'an'
exe 'imenu HTML.Paragraph<tab>' . g:html_map_leader . 'pp' g:html_map_leader . 'pp'
exe 'vmenu HTML.Paragraph<tab>' . g:html_map_leader . 'pp' g:html_map_leader . 'pp'
exe 'nmenu HTML.Paragraph<tab>' . g:html_map_leader . 'pp' 'i' . g:html_map_leader . 'pp'
exe 'imenu HTML.Preformatted\ Text<tab>' . g:html_map_leader . 'pr' g:html_map_leader . 'pr'
exe 'vmenu HTML.Preformatted\ Text<tab>' . g:html_map_leader . 'pr' g:html_map_leader . 'pr'
exe 'nmenu HTML.Preformatted\ Text<tab>' . g:html_map_leader . 'pr' 'i' . g:html_map_leader . 'pr'
exe 'imenu HTML.TITLE<tab>' . g:html_map_leader . 'ti' g:html_map_leader . 'ti'
exe 'vmenu HTML.TITLE<tab>' . g:html_map_leader . 'ti' g:html_map_leader . 'ti'
exe 'nmenu HTML.TITLE<tab>' . g:html_map_leader . 'ti' 'i' . g:html_map_leader . 'ti'

exe 'imenu HTML.More\.\.\..ADDRESS<tab>' . g:html_map_leader . 'ad' g:html_map_leader . 'ad'
exe 'vmenu HTML.More\.\.\..ADDRESS<tab>' . g:html_map_leader . 'ad' g:html_map_leader . 'ad'
exe 'nmenu HTML.More\.\.\..ADDRESS<tab>' . g:html_map_leader . 'ad' 'i' . g:html_map_leader . 'ad'
exe 'imenu HTML.More\.\.\..BASE\ HREF<tab>' . g:html_map_leader . 'bh' g:html_map_leader . 'bh'
exe 'vmenu HTML.More\.\.\..BASE\ HREF<tab>' . g:html_map_leader . 'bh' g:html_map_leader . 'bh'
exe 'nmenu HTML.More\.\.\..BASE\ HREF<tab>' . g:html_map_leader . 'bh' 'i' . g:html_map_leader . 'bh'
exe 'imenu HTML.More\.\.\..BLOCKQUTE<tab>' . g:html_map_leader . 'bl' g:html_map_leader . 'bl'
exe 'vmenu HTML.More\.\.\..BLOCKQUTE<tab>' . g:html_map_leader . 'bl' g:html_map_leader . 'bl'
exe 'nmenu HTML.More\.\.\..BLOCKQUTE<tab>' . g:html_map_leader . 'bl' 'i' . g:html_map_leader . 'bl'
exe 'imenu HTML.More\.\.\..Defining\ Instance<tab>' . g:html_map_leader . 'df' g:html_map_leader . 'df'
exe 'vmenu HTML.More\.\.\..Defining\ Instance<tab>' . g:html_map_leader . 'df' g:html_map_leader . 'df'
exe 'nmenu HTML.More\.\.\..Defining\ Instance<tab>' . g:html_map_leader . 'df' 'i' . g:html_map_leader . 'df'
exe 'imenu HTML.More\.\.\..Document\ Division<tab>' . g:html_map_leader . 'dv' g:html_map_leader . 'dv'
exe 'vmenu HTML.More\.\.\..Document\ Division<tab>' . g:html_map_leader . 'dv' g:html_map_leader . 'dv'
exe 'nmenu HTML.More\.\.\..Document\ Division<tab>' . g:html_map_leader . 'dv' 'i' . g:html_map_leader . 'dv'
exe 'imenu HTML.More\.\.\..EMBED<tab>' . g:html_map_leader . 'eb' g:html_map_leader . 'eb'
exe 'nmenu HTML.More\.\.\..EMBED<tab>' . g:html_map_leader . 'eb' 'i' . g:html_map_leader . 'eb'
exe 'imenu HTML.More\.\.\..ISINDEX<tab>' . g:html_map_leader . 'ii' g:html_map_leader . 'ii'
exe 'nmenu HTML.More\.\.\..ISINDEX<tab>' . g:html_map_leader . 'ii' 'i' . g:html_map_leader . 'ii'
exe 'imenu HTML.More\.\.\..JavaScript<tab>' . g:html_map_leader . 'js' g:html_map_leader . 'js'
exe 'nmenu HTML.More\.\.\..JavaScript<tab>' . g:html_map_leader . 'js' 'i' . g:html_map_leader . 'js'
exe 'imenu HTML.More\.\.\..LINK\ HREF<tab>' . g:html_map_leader . 'lk' g:html_map_leader . 'lk'
exe 'vmenu HTML.More\.\.\..LINK\ HREF<tab>' . g:html_map_leader . 'lk' g:html_map_leader . 'lk'
exe 'nmenu HTML.More\.\.\..LINK\ HREF<tab>' . g:html_map_leader . 'lk' 'i' . g:html_map_leader . 'lk'
exe 'imenu HTML.More\.\.\..Linked\ CSS<tab>' . g:html_map_leader . 'ls' g:html_map_leader . 'ls'
exe 'vmenu HTML.More\.\.\..Linked\ CSS<tab>' . g:html_map_leader . 'ls' g:html_map_leader . 'ls'
exe 'nmenu HTML.More\.\.\..Linked\ CSS<tab>' . g:html_map_leader . 'ls' 'i' . g:html_map_leader . 'ls'
exe 'imenu HTML.More\.\.\..META<tab>' . g:html_map_leader . 'me' g:html_map_leader . 'me'
exe 'vmenu HTML.More\.\.\..META<tab>' . g:html_map_leader . 'me' g:html_map_leader . 'me'
exe 'nmenu HTML.More\.\.\..META<tab>' . g:html_map_leader . 'me' 'i' . g:html_map_leader . 'me'
exe 'imenu HTML.More\.\.\..Quoted\ Text<tab>' . g:html_map_leader . 'qu' g:html_map_leader . 'qu'
exe 'vmenu HTML.More\.\.\..Quoted\ Text<tab>' . g:html_map_leader . 'qu' g:html_map_leader . 'qu'
exe 'nmenu HTML.More\.\.\..Quoted\ Text<tab>' . g:html_map_leader . 'qu' 'i' . g:html_map_leader . 'qu'
exe 'imenu HTML.More\.\.\..SPAN<tab>' . g:html_map_leader . 'sn' g:html_map_leader . 'sn'
exe 'vmenu HTML.More\.\.\..SPAN<tab>' . g:html_map_leader . 'sn' g:html_map_leader . 'sn'
exe 'nmenu HTML.More\.\.\..SPAN<tab>' . g:html_map_leader . 'sn' 'i' . g:html_map_leader . 'sn'
exe 'imenu HTML.More\.\.\..STYLE<tab>' . g:html_map_leader . 'cs' g:html_map_leader . 'cs'
exe 'vmenu HTML.More\.\.\..STYLE<tab>' . g:html_map_leader . 'cs' g:html_map_leader . 'cs'
exe 'nmenu HTML.More\.\.\..STYLE<tab>' . g:html_map_leader . 'cs' 'i' . g:html_map_leader . 'cs'

let did_html_menus = 1
endif  " ! has("gui_running"))
" ---------------------------------------------------------------------------

" ---- Clean Up: -------------------------------------------------------- {{{1

silent! unlet s:browsers

" Restore cpoptions:
let &cpoptions = s:savecpo
unlet s:savecpo

" vim:ts=2:sw=2:expandtab:tw=78:fo=croq2:comments=b\:\":
" vim600:fdm=marker:fdc=3:cms=\ "\ %s:
