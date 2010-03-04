syn match Debug_Comment "#[a-zA-Z]*#.*" containedin=.*Comment
syn match Leo_block "#@.*"
syn region Robodoc start="#\*\*\*\*" end="#\*\*\*" contains=RoboTag
:runtime! syntax/robodoc.vim

" Abbreviations
iab vimode # vim: set shiftwidth=3 tabstop=3 expandtab:# vim: set foldmethod=marker foldmarker=#****,}}} foldenable foldlevel=0:
