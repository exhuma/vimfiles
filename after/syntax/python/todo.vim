syntax match TodoCommentL1 /# TODO (1) #.*$/ contains=pythonTodo
syntax match TodoCommentL2 /# TODO (2) #.*$/ contains=pythonTodo
syntax match TodoCommentL3 /# TODO (3) #.*$/ contains=pythonTodo

hi TodoCommentL1 ctermbg=052 ctermfg=214 guifg=#00ff00  guibg=#ffff00 gui=none
hi TodoCommentL2 ctermbg=058 ctermfg=226 guifg=#00ff00  guibg=#ffff00 gui=none
hi TodoCommentL3 ctermbg=028 ctermfg=223 guifg=#00ff00  guibg=#ffff00 gui=none
