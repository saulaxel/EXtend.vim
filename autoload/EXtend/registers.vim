" ==============================================================================
" File: autoload/EXtend/registers.vim
" Description: Get the different expansions of <C-r>{x} as is pressed in command
"              mode
" Author: Saul Axel <saulaxel.50@gmail.com>
" ==============================================================================

let s:object_expansion_words = {
\   "\<C-w>" : '<cword>',
\   "\<C-a>" : '<cWORD>',
\   "\<C-f>" : '<cfile>',
\   "\<C-p>" : '<cfile>'
\}

function! EXtend#registers#GetRegisterOrCompletion() abort
    let l:reg = EXtend#input#ReadChar()

    if l:reg ==# "\<C-r>"
        return EXtend#registers#GetRegisterOrCompletion()
    endif

    if l:reg ==# '='
        try
            return eval(EXtend#input#ReadLine('=', {}))
        catch
            echohl ErrorMsg
            echo 'Expression error'
            echohl Normal
            call getchar()
            return ''
        endtry
    endif

    if l:reg =~# '[0-9A-Za-z"%#:-\."]'
        call append('.', l:reg . 'XXXXXXXX')
        return getreg(l:reg)
    endif

    let l:expansion_word = get(s:object_expansion_words, l:reg, '')

    if l:expansion_word ==# ''
        return ''
    else
        return expand(l:expansion_word)
    endif
endfunction
" vim:tw=80:et:ts=4:sts=4:sw=4:fdm=marker:spell:spl=en
