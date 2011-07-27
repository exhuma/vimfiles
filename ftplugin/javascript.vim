function! FoldText()
    let line = getline(v:foldstart)
    let isComment = stridx(line, '/*')

    if isComment >= 0
       return substitute(getline(v:foldstart+1), ' \{-}\*', '***', '')
    else
       return substitute(line, '{.*', '{...}', '')
    endif

endfunction

syn region foldBraces start=/{/ end=/}/ transparent fold keepend extend

setl foldtext=FoldText()

syn region javaScriptComment start="/\*"  end="\*/" fold contains=@Spell,javaScriptCommentTodo
set foldmethod=syntax
