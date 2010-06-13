" Vim syntax file
" Language:	PSP (Python Server Pages)
" Maintainer:	Tom von Schwerdtner <tvon@etria.com>
" URL:		http://www.etria.org/
" Last change:	2003 Feb 26
" Credits :     Mostly a slight variation on the jsp sytax file

" For version 5.x: Clear all syntax items
" For version 6.x: Quit when a syntax file was already loaded
if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

if !exists("main_syntax")
  let main_syntax = 'psp'
endif

" Source HTML syntax
if version < 600
  source <sfile>:p:h/html.vim
else
  runtime! syntax/html.vim
endif
unlet b:current_syntax

" Next syntax items are case-sensitive
syn case match

" Include Java syntax
syn include @pspPython <sfile>:p:h/python.vim

syn region pspScriptlet matchgroup=pspTag start=/<%/  keepend end=/%>/ contains=@pspPython
syn region pspComment                     start=/<%--/        end=/--%>/
syn region pspDecl      matchgroup=pspTag start=/<%!/ keepend end=/%>/ contains=@pspPython
syn region pspExpr      matchgroup=pspTag start=/<%=/ keepend end=/%>/ contains=@pspPython
syn region pspDirective                   start=/<%@/         end=/%>/ contains=htmlString,pspDirName,pspDirArg

syn keyword pspDirName contained include page taglib
syn keyword pspDirArg contained imports extends method isThreadSafe formatter
syn keyword pspDirArg contained isInstanceSafe indentType indentSpaces gobbleWhitespace
syn region pspCommand start=/<psp:/ start=/<\/psp:/ keepend end=/>/ end=/\/>/ contains=htmlString,pspCommandName,pspCommandArg
" Do it right at some point...
"syn region pspInclude start=/<psp:include/ start=/<\/psp:/ keepend end=/>/ end=/\/>/ contains=path
"syn region pspInsert start=/<psp:insert/ start=/<\/psp:/ keepend end=/>/ end=/\/>/ contains=file

syn keyword pspCommandName contained include insert method
syn keyword pspCommandArg contained path file

" Define the default highlighting.
" For version 5.7 and earlier: only when not done already
" For version 5.8 and later: only when an item doesn't have highlighting yet
if version >= 508 || !exists("did_psp_syn_inits")
  if version < 508
    let did_psp_syn_inits = 1
    command -nargs=+ HiLink hi link <args>
  else
    command -nargs=+ HiLink hi def link <args>
  endif
  " java.vim has redefined htmlComment highlighting
  HiLink htmlComment     Comment
  HiLink htmlCommentPart Comment
  " Be consistent with html highlight settings
  HiLink pspComment      htmlComment
  HiLink pspTag          htmlTag
  HiLink pspDirective    pspTag
  HiLink pspDirName      htmlTagName
  HiLink pspDirArg       htmlArg
  HiLink pspCommand      pspTag
  HiLink pspCommandName  htmlTagName
  HiLink pspCommandArg   htmlArg
  delcommand HiLink
endif

if main_syntax == 'psp'
  unlet main_syntax
endif

let b:current_syntax = "psp"

" vim: ts=8
