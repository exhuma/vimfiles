function! FoldText()
    let line = getline(v:foldstart)
    let isComment = stridx(line, '/*')
    let output = ""

    if isComment >= 0
       let output = substitute(getline(v:foldstart+1), ' \{-}\*', '***', '')
    else
       let output = substitute(line, '{.*', '{...}', '')
    endif

    let output = substitute(output, '^\s*\(.\{-}\)', '\1', '')

    let size = 1 + v:foldend - v:foldstart
    if size < 10
        let size = " " . size
    endif
    if size < 100
        let size = " " . size
    endif
    if size < 1000
        let size = " " . size
    endif
    return repeat('  ', foldlevel(v:foldstart)-1) . "[" . size . "] " . output
endfunction

syn region foldBraces start=/{/ end=/}/ transparent fold keepend extend

setl foldtext=FoldText()

syn region javaScriptComment start="/\*"  end="\*/" fold contains=@Spell,javaScriptCommentTodo
set foldmethod=syntax

" Adhering to google code style
set tabstop=2
set shiftwidth=2
