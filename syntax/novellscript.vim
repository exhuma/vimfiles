" Vim syntax file
" Language:	novell
" Author:	Michel Albert <michel@albert.lu>
" Version:	2009070101
" Copyright:	Copyright (c) 2009 Michel Albert
" Licence:	You may redistribute this under the same terms as Vim itself

syntax case ignore

syntax keyword n_keyword
             \ context drive lastlogintime no_default profile
             \ shift tree on off # @

syn keyword n_conditional
          \ if then else and or

syn keyword n_statement
          \ break display exit fire phasers goto attach fdisplay include map
          \ pause regread set write

syn keyword n_constant
          \ day day_of_week month month_name nday_of_week short_year year
          \ access_server
          \ error_level
          \ dialup offline
          \ file_server network_address
          \ am_pm greeting_time hour hour24 minute second
          \ cn login_alias_context full_name login_context login_name not member of password_expires requester_context user_id
          \ machine netware_requester os os_version p_station platform shell_type shell_version smachine
          \ station winver

syn match n_path     ![a-z][a-z0-9]\+:[a-z0-9_.-]\+\([/\\][a-z0-9_.-]\+\)*!
syn match n_constant /member of/
syn match StringVars /%[A-Za-z0-9_]\+\|<%\?[a-z0-9_]\+>/
syn match n_operator /[=<>;]/
syn match n_variable /%[A-Za-z0-9_]\+\|\*[0-9]\+\|<%\?[a-z0-9_]\+>/
syn match n_dletter /[a-z]:/
syn match n_number /[0-9]\+/
syn match n_label /^\s*[a-zA-Z][a-zA-Z0-9_]\+:/
syn match n_comment /^\s*[;*].*$\|^\s*rem\(ark\)\?\s\+.*$/

syn region n_string start=/"/ end=/"/ contains=StringVars

hi link StringVars    Identifier
hi link n_keyword     Keyword
hi link n_string      String
hi link n_variable    Identifier
hi link n_operator    Operator
hi link n_dletter     Special
hi link n_number      Number
hi link n_label       Label
hi link n_comment     Comment
hi link n_conditional Conditional
hi link n_statement   Statement
hi link n_constant    Constant
hi link n_path        StorageClass

if exists("b:current_syntax")
  finish
endif

let b:current_syntax = "novell"

