" ==============================================================================
" File: plugin/sub_op.vim
" Description: Creates the operators to call the substitute-operator plugin and
"              its corresponding functions.
" Author: Saul Axel <saulaxel.50@gmail.com>
" ==============================================================================
if expand('%:p') ==# expand('<sfile>:p')
    unlet! g:sub_op_loaded
endif

if exists('g:sub_op_loaded') || &compatible || v:version < 700
    finish
endif
let g:sub_op_loaded = 1

" =====[ Configuration ]=====
let g:sub_op_default_mappings = get(g:, 'sub_op_default_mappings', 1)
let g:sub_op_key_handlers = get(g:, 'sub_op_key_handlers', {})

" =====[ Plugs ]=====
nnoremap <silent> <Plug>SubstituteEmptyNormal
                \ :<C-u>call sub_op#pos#Save()
                \ <bar>set operatorfunc=OperatorSubstitute<CR>g@
xnoremap <silent> <Plug>SubstituteEmptyVisual
                \ <Esc>:call sub_op#pos#Save()<CR>
                \ <bar>gv:<C-u>call OperatorSubstitute('selection', 1)<CR>
nnoremap <silent> <Plug>SubstituteEmptyOneLine
                \ :<C-u>call sub_op#pos#Save()
                \ <bar>call OperatorSubstitute('singleline', 1)<CR>

nnoremap <silent> <Plug>SubstituteWordNormal
                \ :<C-u>call sub_op#pos#Save()
                \ <bar>set operatorfunc=OperatorSubstituteWord<CR>g@
xnoremap <silent> <Plug>SubstituteWordVisual
                \ <Esc>:call sub_op#pos#Save()<CR>
                \ <bar>gv:<C-u>call OperatorSubstituteWord('selection', 1)<CR>
nnoremap <silent> <Plug>SubstituteWordOneLine
                \ :<C-u>call sub_op#pos#Save()
                \ <bar>call OperatorSubstituteWord('singleline')<CR>

nnoremap <silent> <Plug>SubstituteWORDNormal
                \ :<C-u>call sub_op#pos#Save()
                \ <bar>set operatorfunc=OperatorSubstituteWORD<CR>g@
xnoremap <silent> <Plug>SubstituteWORDVisual
                \ <Esc>:call sub_op#pos#Save()<CR>
                \ <bar>gv:<C-u>call OperatorSubstituteWORD('selection', 1)<CR>
nnoremap <silent> <Plug>SubstituteWORDOneLine
                \ :<C-u>call sub_op#pos#Save()
                \ <bar>call OperatorSubstituteWORD('singleline', 1)<CR>

" =====[ Default mappings ]=====
if g:sub_op_default_mappings
    nmap <Leader>se   <Plug>SubstituteEmptyNormal
    xmap <Leader>se   <Plug>SubstituteEmptyVisual
    nmap <Leader>see  <Plug>SubstituteEmptyOneLine

    nmap <Leader>sw   <Plug>SubstituteWordNormal
    xmap <Leader>sw   <Plug>SubstituteWordVisual
    nmap <Leader>sww  <Plug>SubstituteWordOneLine

    nmap <Leader>sW   <Plug>SubstituteWORDNormal
    xmap <Leader>sW   <Plug>SubstituteWORDVisual
    nmap <Leader>sWW  <Plug>SubstituteWORDOneLine
endif

function! OperatorSubstitute(type, ...)
    let [l:first_line, l:last_line] = s:GetLines(a:type, a:0)
    call sub_op#SubstituteInRange(l:first_line, l:last_line)
    call sub_op#pos#Restore()
endfunction

function! OperatorSubstituteWord(type, ...) abort
    let [l:first_line, l:last_line] = s:GetLines(a:type, a:0)
    call sub_op#pos#Restore() " First restore is to get <cword> correctly
    call sub_op#SubstituteInRange(l:first_line, l:last_line,
                                    \ expand('<cword>'), 1)
    call sub_op#pos#Restore()
endfunction

function! OperatorSubstituteWORD(type, ...) abort
    let [l:first_line, l:last_line] = s:GetLines(a:type, a:0)
    call sub_op#pos#Restore()
    call sub_op#SubstituteInRange(l:first_line, l:last_line,
                                    \ expand('<cWORD>'), 0)
    call sub_op#pos#Restore()
endfunction

function! s:GetLines(type, extra_args_len)
    if a:type ==# 'singleline'
        return [line('.'), line('.') + max([0, v:count - 1])]
    elseif a:extra_args_len != 0
        let [l:first_line, l:last_line] = [line("'<"), line("'>")]

        if l:first_line > l:last_line
            let [l:first_line, l:last_line] = [l:last_line, l:first_line]
        endif
    else
        let [l:first_line, l:last_line] = [line("'["), line("']")]
    endif

    return [l:first_line, l:last_line]
endfunction
" vim:tw=80:et:ts=4:sts=4:sw=4:fdm=marker:spell:spl=en
