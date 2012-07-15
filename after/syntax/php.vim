syn match Debug_Comment "#[a-zA-Z]*#.*" containedin=.*Comment

if exists("php_parent_error_open")
  syn region  phpComment  start="/\*" end="\*/" contained contains=phpTodo fold
else
  syn region  phpComment  start="/\*" end="\*/" contained contains=phpTodo extend fold
endif

