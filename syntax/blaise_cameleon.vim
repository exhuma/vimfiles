" Vim syntax file
" Language:	blaise Cameleon
" Author:	Michel Albert <michel.albert@statec.etat.lu>
" Version:	2010060301
" Copyright:	Copyright (c) 2010 Michel Albert
" Licence:	You may redistribute this under the same terms as Vim itself

syntax clear
syntax case ignore

syn keyword camKeyword AND ANSWERCODE ANSWERLOOP ANSWERNAME ANSWERTEXT
         \ ARRAYLOOP ASK ANSWERINDEX BLOCKCALL BLOCKLEVEL BLOCKPROC
         \ COPY ENDANSWERLOOP
         \ ENDARRAYLOOP ENDBLOCKPROC ENDFIELDSLOOP ENDMODELSTART
         \ ENDPREVIOUSBLOCK ENDPROCEDURE ENDSETLOOP ENDTYPESLOOP
         \ ENUMTYPENUMBER FIELDLENGTH FIELDPATH FIELDSLOOP FIRSTPOSITION
         \ FROMLIBRARY LASTPOSITION LENGTH MAXNAMELENGTH METAINFOFILENAME
         \ MODELSTART NOT OR OUTFILE POSITIONCOUNT
         \ PREVIOUSBLOCK PROCEDURE REPLACE SETLOOP
         \ TOSEARCHENUMNUMBER TYPE TYPEINDEX TYPESLOOP VAR
         \ contained

syn keyword camType BLOCK BOOLEAN CLASSIFICATION ENUMERATED OPEN PREDEFINEDTYPE REAL SET STRING TIME contained
syn keyword camFunction BLOCKCALL COPY LENGTH REPLACE contained
syn keyword camConditional IF THEN ELSE ELSEIF ENDIF contained

syn region camComment start=/\[\*/ end=/\]/
syn match camNumber /[0-9]\+/ contained
syn region camString start=/'/ end=/'/ contained
syn region camString2 start=/"/ end=/"/ contained
syn keyword camSpecialValue TRUE FALSE REFUSAL DONTKNOW contained
syn match camOperator !\(:=\|==\|[+&:=*/<>-]\)! contained
syn region camInstruction start=/\[/ end=/\]/ contains=ALL
syn region camHelpComment start=/\[HELP/ end=/\]/
syn match camMacro !\[\([&/]\|:[0-9]\{-}\)\?\]!

hi link camOperator Operator
hi link camComment Comment
hi link camHelpComment Comment
hi link camLiteral String
hi link camKeyword Keyword
hi link camInstruction Normal
hi link camString String
hi link camString2 String
hi link camSpecialValue Boolean
hi link camNumber Number
hi link camConditional Conditional
hi link camFunction Function
hi link camType Type
hi link camMacro Macro

if exists("b:current_syntax")
  finish
endif


let b:current_syntax = "blaise_cameleon"

