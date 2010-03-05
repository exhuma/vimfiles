syn match epydocTags "@\(param\|type\|return\|rtype\|keyword\|raise\|ivar\|cvar\|var\|type\|group\|sort\|note\|attention\|bug\|warning\|version\|todo\|deprecated\|since\|status\|change\|permission\|requires\|precondition\|postcondition\|invariant\|author\|organization\|copyright\|license\|contact\|summary\|see\)\>" containedin=pythonString

syn match Note_Comment "#note#.*" containedin=.*Comment
syn match Todo_Comment "#\(TODO\|todo\)#.*" containedin=.*Comment
syn match Todo_Comment "@todo:.*" containedin=pythonString
syn match Debug_Comment "#[a-zA-Z ]*#.*" containedin=.*Comment

syn match PreProc "^#!.*"
syn region Robodoc start="\"\"\"-" end="-\"\"\"" contains=RoboTag

hi link epydocTags Special

:runtime! syntax/robodoc.vim

" Abbreviations
iab vimode # vim: set shiftwidth=3 tabstop=3 expandtab:# vim: set foldmethod=marker foldmarker={{{,}}} foldenable foldlevel=0:
