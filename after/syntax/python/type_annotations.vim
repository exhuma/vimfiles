
syn match pythonTypeHint
    \ "\(:\s\{-}[a-zA-Z0-9_]\+\(\[.\{-}\]\)\?\)\|\(\s\{-\}->\s\{-}[a-zA-Z0-9_\[\]]\+:\@=\)"
    \ conceal cchar=¤

hi pythonTypeHint ctermfg=60
