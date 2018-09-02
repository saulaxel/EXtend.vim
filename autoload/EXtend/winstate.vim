" ==============================================================================
" File: autoload/EXtend/pos.vim
" Description: Saving and restoring cursor position
" Author: Saul Axel <saulaxel.50@gmail.com>
" ==============================================================================

let s:winview = {}

function! EXtend#winstate#Save() abort
    let s:winview = winsaveview()
endfunction

function! EXtend#winstate#Restore() abort
    call winrestview(s:winview)
endfunction
" vim:tw=80:et:ts=4:sts=4:sw=4:fdm=marker:spell:spl=en
