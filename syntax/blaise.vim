" Vim syntax file
" Language:	blaise
" Author:	Michel Albert <michel.albert@statec.etat.lu>
" Version:	2011072601
" Copyright:	Copyright (c) 2006 Michel Albert
" Licence:	You may redistribute this under the same terms as Vim itself

"
" A function to simplify the definition of Blaise sections. As there are no
" explicit end-tokens, the sections must end on a large list of possible
" tokens. This function generates a syntax rule including these tokens.
" Additional closing tokens may be specified on call.
"
fun! s:defineSection( name, ... )

   " The keywords where sections are closed
   let l:closings = [
      \ 'USES',
      \ 'AUXFIELDS',
      \ 'EXPORT',
      \ 'EXTERNALS',
      \ 'FIELDS',
      \ 'IMPORT',
      \ 'LAYOUT',
      \ 'LIBRARIES',
      \ 'LOCALS',
      \ 'PARAMETERS',
      \ 'RULES',
      \ 'SETTINGS',
      \ 'TRANSIT',
      \ 'TYPE',
      \ 'PROCEDURE',
      \ '\(INCLUDE ".\{-}"\)']

   " add any additional parameters to the closing keywords
   call extend(l:closings, a:000)

      "\.'end=/\n\(\<\(' . join(l:closings, '\|') . '\)\>\)\@=/ '
   let l:synStatement = 'syn region BlaSection matchgroup=Title '
      \.'start=/\<' . a:name . '\>/ '
      \.'end=/\n\(\_^\s\{-}\<\(' . join(l:closings, '\|') . '\)\s\{-}\_$\)\@=/ '
      \.'fold contains=ALL'

   exec l:synStatement
endfun

"
" This function is used as VIM indent expression. If returns the number of
" spaces with which the current line should be indented. It's based on
" 'shiftwith'
"
fun! BlaiseIndent(lnum)

   let l:dedents = [
      \ '\(DATAMODEL \w\{-}\( ".\{-}"\)\?\)',
      \ '\<ENDMODEL\>',
      \ '\(TABLE \w\{-}\( ".\{-}"\)\?\)',
      \ '\<ENDTABLE\>',
      \ '\(BLOCK \w\{-}\( ".\{-}"\)\?\)',
      \ '\<ENDBLOCK\>',
      \ '\<PRIMARY\>',
      \ '\<USES\>',
      \ '\<AUXFIELDS\>',
      \ '\<EXPORT\>',
      \ '\<EXTERNALS\>',
      \ '\<FIELDS\>',
      \ '\<IMPORT\>',
      \ '\<LAYOUT\>',
      \ '\<LIBRARIES\>',
      \ '\<LOCALS\>',
      \ '\<PARAMETERS\>',
      \ '\<RULES\>',
      \ '\<SETTINGS\>',
      \ '\<TRANSIT\>',
      \ '\<TYPE\>',
      \ '\<PROCEDURE\>']

   let l:indentlevel = -1

   let l:line = getline(a:lnum)

   " dedent sections (and some other keywords)
   for section in l:dedents
      if l:line =~ '^\s\{-}'.section.'\s\{-\}$'
         let l:indentlevel = foldlevel(a:lnum)-1
         break
      endif
   endfor

   " in case the 'if' is on the same line as the 'endif', ignore the following
   " rule!
   if !(l:line =~ '\<IF\>' && l:line =~ '\<ENDIF\>')
      " dedent 'if's
      if l:line =~ '\(\<\(ELSE\|END\)\?IF\>\|\<ELSE\>\)'
         let l:indentlevel = foldlevel(a:lnum)-1
      endif
   endif

   " in case the 'for' is on the same line as the 'enddo', ignore the following
   " rule!
   if !(l:line =~ '\<FOR\>' && l:line =~ '\<ENDDO\>')
      " dedent 'FORs'
      if l:line =~ '\<\(FOR\|ENDDO\)\>'
         let l:indentlevel = foldlevel(a:lnum)-1
      endif
   endif

   " Indent multiline strings. Again, the indent level is based on the fold
   " level. This rule, dedents the beginning of the string (in other words, a
   " line that does not start but ends as string, and where the following line
   " starts as string).
   if synIDattr(synID(a:lnum, 1, 1), "name") !~ 'BlaString' && synIDattr(synID(a:lnum, col("$")-1, 1), "name") =~ 'BlaString' && synIDattr(synID(nextnonblank(a:lnum+1), 1, 1), "name") =~ 'BlaString'
      let l:indentlevel = foldlevel(a:lnum)-1
   endif


   if l:indentlevel == -1
      let l:indentlevel = foldlevel(a:lnum)
   endif
   return l:indentlevel * &shiftwidth

endfun
set indentexpr=BlaiseIndent(v:lnum)

syntax clear
syntax case ignore
syntax sync fromstart

syntax keyword blaKey after alien alternative and array ascii asciirelational
                      \ at attributes before blaise blaise3
                      \ blockstart blockend cadi capi case cati check
                      \ classification datetype dialog dk do
                      \ dontknow dummy dynamic edittype else elseif embedded
                      \ empty end endcase endclassification
                      \ endlibrary endmanipulate endprint
                      \ endproc endquestionnaire endrepeat
                      \ endwhile error exitfor exitrepeat exitwhile
                      \ fieldpane fixed from grid
                      \ hierarchy in infopane inherit
                      \ inputfile instructions integer internet involving
                      \ languages levels library linkfields
                      \ manipula manipulate newcolumn newline newpage
                      \ nodk nodontknow noempty norefusal norf not of oledb
                      \ open or outputfile parallel print
                      \ process prologue questionnaire real refusal
                      \ repeat reservecheck reset response rf router
                      \ secondary set signal sort string
                      \ temporaryfile then timetype tlanguage to
                      \ trigram until updatefile while

syn region blaComment start=/{/ end=/}/
syn region blaBlock start=/\<BLOCK\>/ end=/\<ENDBLOCK\>/ fold contains=ALL
syn region blaTable start=/\<TABLE\>/ end=/\<ENDTABLE\>/ fold contains=ALL
syn region blaFields start=/FIELDS/ end=/RULES\|SIGNAL\|CHECK\|ENDMODEL/ fold
syn match  BlaOperator /[:=<>+\-*/]/
syn match BlaFunc /\.Search(.*)/
syn match BlaFunc /\.Read/
syn keyword BlaFunc SHOW KEEP UPPERCASE SUBSTRING
syn match StringEscapes !@/\|@[A-Z]\|\^\^\|@@\|@|\|@[A-Z]@\|<\/\=.\{-}>!
syn match StringEscapes /·/
syn match StringVars /\^[A-Z0-9_]\+\(\.[a-z0-9_]\+\)*/
syn keyword BlaType STRING EMPTY INT INTEGER
syn region BlaString start=/"/ end=/"/ fold contains=StringEscapes,StringVars
syn region BlaString start=/'/ end=/'/ fold contains=StringEscapes,StringVars

syn region BlaSection matchgroup=Title start=/\<DATAMODEL\>/ end=/\<ENDMODEL\>/ fold contains=ALL
syn region BlaSection matchgroup=Title start=/\<PROCEDURE\>/ end=/\<ENDPROCEDURE\>/ fold contains=ALL

call s:defineSection('USES')
call s:defineSection('AUXFIELDS', 'ENDBLOCK')
call s:defineSection('EXPORT', 'ENDBLOCK')
call s:defineSection('EXTERNALS')
call s:defineSection('FIELDS', 'ENDBLOCK')
call s:defineSection('IMPORT')
call s:defineSection('LAYOUT', 'ENDBLOCK', 'ENDMODEL', 'ENDTABLE')
call s:defineSection('LIBRARIES')
call s:defineSection('LOCALS', 'ENDBLOCK', 'ENDTABLE', 'ENDPROCEDURE', 'ENDMODEL')
call s:defineSection('PARAMETERS')
call s:defineSection('RULES', 'ENDBLOCK', 'ENDTABLE', 'ENDPROCEDURE', 'ENDMODEL')
call s:defineSection('SETTINGS')
call s:defineSection('TRANSIT')
call s:defineSection('TYPE')
call s:defineSection('PRIMARY')

syn region BlaConditional matchgroup=BlaKey start=/\<IF\>/ end=/\<ENDIF\>/ fold contains=ALL
syn region BlaLoop matchgroup=BlaKey start=/\<FOR\>/ end=/\<ENDDO\>/ fold contains=ALL

" Overriding the toke 'INCLUDE' again, as the region match excluded it (due to
" the zero-width '\@=' end-item). This rule ensures it's colored properly
syn keyword blaKey INCLUDE

hi link BlaDataModel Keyword
hi link blaKey Keyword
hi link blaBlock Statement
hi link blaTable Statement
hi link blaFields Type
hi link blaComment Comment
hi link BlaOperator   Operator
hi link BlaFunc       Function
hi link StringVars    Identifier
hi link StringEscapes Operator
hi link BlaType       Type
hi link BlaString     String

if exists("b:current_syntax")
  finish
endif

let b:current_syntax = "blaise"

