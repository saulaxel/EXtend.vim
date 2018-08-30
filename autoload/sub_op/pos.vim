" ==============================================================================
" File: autoload/pos.vim
" Description: Saving and restoring cursor position
" Author: Saul Axel <saulaxel.50@gmail.com>
" ==============================================================================

let s:pos = []

function! sub_op#pos#Save() abort
    let s:pos = getpos('.')
endfunction

function! sub_op#pos#Restore() abort
    call setpos('.', s:pos)
endfunction
" vim:tw=80:et:ts=4:sts=4:sw=4:fdm=marker:spell:spl=en
