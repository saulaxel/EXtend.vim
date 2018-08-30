" ==============================================================================
" File: autoload/matches.vim
" Description: Creating and deleting highlight matches withing a specific range
" Author: Saul Axel <saulaxel.50@gmail.com>
" ==============================================================================
let s:matches = {}

function! sub_op#matches#RangeHighlight(name, hl, pattern, start, end) abort
    call sub_op#matches#DeleteHighlight(a:name)

    let s:matches[a:name] = matchadd(a:hl,
                              \   '\%>' . (a:start - 1) . 'l\%<' . (a:end + 1)
                              \ . 'l' . a:pattern)
endfunction

function! sub_op#matches#PointHighlight(name, hl, line, col) abort
    call sub_op#matches#DeleteHighlight(a:name)

    let s:matches[a:name] = matchadd(a:hl,
                              \   '\%' . (a:line) . 'l\%' . (a:col) . 'c', 11)
endfunction

function! sub_op#matches#DeleteHighlight(name) abort
    if has_key(s:matches, a:name) && s:matches[a:name] != -1
        call matchdelete(s:matches[a:name])
        let s:matches[a:name] = -1
    endif
endfunction

function! sub_op#matches#DeleteAllHighlights() abort
    for l:match_name in keys(s:matches)
        call sub_op#matches#DeleteHighlight(l:match_name)
    endfor
endfunction
" vim:tw=80:et:ts=4:sts=4:sw=4:fdm=marker:spell:spl=en
