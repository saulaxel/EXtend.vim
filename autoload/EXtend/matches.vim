" ==============================================================================
" File: autoload/EXtend/matches.vim
" Description: Creating and deleting highlight matches withing a specific range
" Author: Saul Axel <saulaxel.50@gmail.com>
" ==============================================================================
let s:matches = {}

function! EXtend#matches#RangeHighlight(name, hl, pattern, start, end) abort
    call EXtend#matches#DeleteHighlight(a:name)

    try
        let s:matches[a:name] = matchadd(a:hl,
                              \   '\%>' . (a:start - 1) . 'l\%<' . (a:end + 1)
                              \ . 'l' . a:pattern)
    catch
        " The regular expression was not valid
    endtry
endfunction

function! EXtend#matches#PointHighlight(name, hl, line, col) abort
    call EXtend#matches#DeleteHighlight(a:name)

    let s:matches[a:name] = matchadd(a:hl,
                            \ '\%' . (a:line) . 'l\%' . (a:col) . 'c', 11)
endfunction

function! EXtend#matches#DeleteHighlight(name) abort
    if has_key(s:matches, a:name) && s:matches[a:name] != -1
        call matchdelete(s:matches[a:name])
        let s:matches[a:name] = -1
    endif
endfunction

function! EXtend#matches#DeleteAllHighlights() abort
    for l:match_name in keys(s:matches)
        call EXtend#matches#DeleteHighlight(l:match_name)
    endfor
endfunction
" vim:tw=80:et:ts=4:sts=4:sw=4:fdm=marker:spell:spl=en
