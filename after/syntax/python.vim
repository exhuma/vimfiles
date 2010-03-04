syn match Note_Comment "#note#.*" containedin=.*Comment
syn match Debug_Comment "#[a-zA-Z ]*#.*" containedin=.*Comment
syn region Robodoc start="\"\"\"-" end="-\"\"\"" contains=RoboTag
:runtime! syntax/robodoc.vim

" Abbreviations
iab vimode # vim: set shiftwidth=3 tabstop=3 expandtab:# vim: set foldmethod=marker foldmarker={{{,}}} foldenable foldlevel=0:
