" Vim syntax file
" Language:	blaise
" Author:	Michel Albert <michel.albert@statec.etat.lu>
" Version:	2007070201
" Copyright:	Copyright (c) 2006 Michel Albert
" Licence:	You may redistribute this under the same terms as Vim itself

syntax case ignore
syntax keyword blaKey after alien alternative and array ascii asciirelational
                      \ at attributes auxfields before blaise blaise3 block
                      \ blockstart blockend cadi capi case cati check
                      \ classification datamodel datetype dialog dk do
                      \ dontknow dummy dynamic edittype else elseif embedded
                      \ empty end endblock endcase endclassification enddo
                      \ endif endlibrary endmanipulate endmodel endprint
                      \ endproc endprocedure endquestionnaire endrepeat
                      \ endtable endwhile error exitfor exitrepeat exitwhile
                      \ export externals fieldpane fields fixed for from grid
                      \ hierarchy if import in include infopane inherit
                      \ inputfile instructions integer internet involving
                      \ languages layout levels libraries library linkfields
                      \ locals manipula manipulate newcolumn newline newpage
                      \ nodk nodontknow noempty norefusal norf not of oledb
                      \ open or outputfile parallel parameters primary print
                      \ procedure process prologue questionnaire real refusal
                      \ repeat reservecheck reset response rf router rules
                      \ secondary set settings signal sort string table
                      \ temporaryfile then timetype tlanguage to transit
                      \ trigram type until updatefile uses while

syn region blaComment start=/{/ end=/}/ contains=ALL
syn region blaBlock start=/BLOCK/ end=/ENDBLOCK/ fold contains=blaFields, blaBlock
syn region blaFields start=/FIELDS/ end=/RULES\|SIGNAL\|CHECK\|ENDMODEL/ fold
syn match  BlaOperator /[:=<>+\-*/]/
syn match BlaFunc /\.Search(.*)/
syn match BlaFunc /\.Read/
syn keyword BlaFunc SHOW KEEP UPPERCASE SUBSTRING
syn match StringEscapes !@/\|@[A-Z]\|\^\^\|@@\|@|\|@[A-Z]@\|<\/\=.\{-}>!
syn match StringEscapes /·/
syn match StringVars /\^[A-Za-z0-9]\+/
syn keyword BlaType STRING EMPTY INT INTEGER
syn region BlaString start=/"/ end=/"/ contains=StringEscapes,StringVars
syn region BlaString start=/'/ end=/'/ contains=StringEscapes,StringVars


hi link blaKey Keyword
hi link blaBlock Statement
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

" syn keyword BlaStatement
"       \ IF THEN ELSE ENDIF NEWPAGE
"       \ RESPONSE VAL AND OR NOT TYPE
" 
" syn keyword BlaWord
"       \ DATAMODEL USES PRIMARY SECONDARY EXTERNALS INCLUDE LOCALS FIELDS AUXFIELDS
"       \ INTEGER RULES SIGNAL CHECK ENDMODEL FORMSTATUS NEW LAYOUT BEFORE
"       \ GRID FIELDPANE BLOCK ENDBLOCK TABLE ENDTABLE LIBRARIES LIBRARY
"       \ CLASSIFICATION DYNAMIC LEVELS HIERARCHY ENDCLASSIFICATION END
" syn match BlaWord /DUMMY\(\s*(\d\+)\)\?/
" 
" syn match BlaNumber /\b[0-9.]\+\b/
" 
" syn match BlaNumberRange /[0-9.]\+\.\.[0-9.]\+/
" 
" syn region BlaArray start=/\[/ end=/\]/ contains=BlaNumber
" 
" hi def link BlaWord       Keyword
" hi def link BlaNumber     Number
" hi def link BlaNumberRange  Type
" hi def link BlaArray      Type
" hi def link BlaStatement  Statement

let b:current_syntax = "blaise"

