" ==============================================================================
" File: plugin/extend.vim
" Description: Creates the operators to call the SUB-operator plugin and
"              its corresponding functions.
" Author: Saul Axel <saulaxel.50@gmail.com>
" ==============================================================================
if expand('%:p') ==# expand('<sfile>:p')
    unlet! g:EXtend_loaded
endif

if exists('g:EXtend_loaded') || &compatible || v:version < 700
    finish
endif
let g:EXtend_loaded = 1

" =====[ Configuration ]=====
let g:EXtend_default_mappings  = get(g:, 'EXtend_default_mappings', 1)
if type(g:EXtend_default_mappings) == type({})
    let l:default_maps = g:EXtend_default_mappings

    " Command
    let l:default_maps.substitute = get(l:default_maps, 'substitute', 1)
    let l:default_maps.global     = get(l:default_maps, 'global', 1)
    let l:default_maps.vglobal    = get(l:default_maps, 'vglobal', 1)

    " Type of command
    let l:default_maps.pattern_empty      = get(l:default_maps, 'pattern_empty', 1)
    let l:default_maps.pattern_word       = get(l:default_maps, 'pattern_word', 1)
    let l:default_maps.pattern_substitute = get(l:default_maps, 'pattern_substitute', 1)
endif
let g:EXtend_key_handlers       = get(g:, 'EXtend_key_handlers', {})
let g:EXtend_highlight_position = get(g:, 'EXtend_highlight_position', 'WildMenu')
let g:EXtend_highlight_cursor   = get(g:, 'EXtend_highlight_cursor', 'CursorColumn')
let g:EXtend_highlight_range    = get(g:, 'EXtend_highlight_range', 'Visual')
let g:EXtend_highlight_pattern  = get(g:, 'EXtend_highlight_pattern', 'IncSearch')

" =====[ Plugs ]=====
nnoremap <silent> <Plug>SubstituteNormal
                \ :<C-u>call EXtend#winstate#Save()
                \ <bar>set opfunc=<SID>OperatorSubstitute<CR>g@
xnoremap <silent> <Plug>SubstituteVisual
                \ <Esc>:call EXtend#winstate#Save()<CR>
                \ gv:<C-u>call <SID>OperatorSubstitute('selection', 1)<CR>
nnoremap <silent> <Plug>SubstituteOneLine
                \ :<C-u>call EXtend#winstate#Save()
                \ <bar>call <SID>OperatorSubstitute('singleline', 1)<CR>
nnoremap <silent> <Plug>SubstituteEntire
                \ :<C-u>call EXtend#winstate#Save()
                \ <bar>call <SID>OperatorSubstituteEntire()<CR>

nnoremap <silent> <Plug>SubstituteWordNormal
                \ :<C-u>call EXtend#winstate#Save()
                \ <bar>set opfunc=<SID>OperatorSubstituteWord<CR>g@
xnoremap <silent> <Plug>SubstituteWordVisual
                \ <Esc>:call EXtend#winstate#Save()<CR>
                \ gv:<C-u>call <SID>OperatorSubstituteWord('selection', 1)<CR>
nnoremap <silent> <Plug>SubstituteWordOneLine
                \ :<C-u>call EXtend#winstate#Save()
                \ <bar>call <SID>OperatorSubstituteWord('singleline', 1)<CR>
nnoremap <silent> <Plug>SubstituteWordEntire
                \ :<C-u>call EXtend#winstate#Save()
                \ <bar>call <SID>OperatorSubstituteWordEntire()<CR>

xnoremap <silent> <Plug>SubstituteFromSelection
                \ :<C-u>let g:EXtend_reg_save=@"<CR>
                \ :call EXtend#winstate#Save()<CR>
                \ gvy:<C-u>set opfunc=<SID>OperatorSubstituteFromSelection<CR>g@
xnoremap <silent> <Plug>SubstituteFromSelectionEntire
                \ :<C-u>let g:EXtend_reg_save=@"<CR>
                \ :call EXtend#winstate#Save()<CR>
                \ gvy:<C-u>call <SID>OperatorSubstituteFromSelectionEntire()<CR>


nnoremap <silent> <Plug>GlobalNormal
                \ :<C-u>call EXtend#winstate#Save()
                \ <bar>set opfunc=<SID>OperatorGlobal<CR>g@
xnoremap <silent> <Plug>GlobalVisual
                \ <Esc>:call EXtend#winstate#Save()<Esc>
                \ gv:<C-u>call <SID>OperatorGlobal('selection', 1)<CR>
nnoremap <silent> <Plug>GlobalOneLine
                \ :<C-u>call EXtend#winstate#Save()
                \ <bar>call <SID>OperatorGlobal('singleline', 1)<CR>
nnoremap <silent> <Plug>GlobalEntire
                \ :<C-u>call EXtend#winstate#Save()
                \ <bar>call <SID>OperatorGlobalEntire()<CR>

nnoremap <silent> <Plug>GlobalWordNormal
                \ :<C-u>call EXtend#winstate#Save()
                \ <bar>set opfunc=<SID>OperatorGlobalWord<CR>g@
xnoremap <silent> <Plug>GlobalWordVisual
                \ <Esc>:call EXtend#winstate#Save()<CR>
                \ gv:<C-u>call <SID>OperatorGlobalWord('selection', 1)<CR>
nnoremap <silent> <Plug>GlobalWordOneLine
                \ :<C-u>call EXtend#winstate#Save()
                \ <bar>call <SID>OperatorGlobalWord('singleline', 1)<CR>
nnoremap <silent> <Plug>GlobalWordEntire
                \ :<C-u>call EXtend#winstate#Save()
                \ <bar>call <SID>OperatorGlobalWordEntire()<CR>

xnoremap <silent> <Plug>GlobalFromSelection
                \ :<C-u>let g:EXtend_reg_save=@"<CR>
                \ :call EXtend#winstate#Save()<CR>
                \ gvy:<C-u>set opfunc=<SID>OperatorGlobalFromSelection<CR>g@
xnoremap <silent> <Plug>GlobalFromSelectionEntire
                \ :<C-u>let g:EXtend_reg_save=@"<CR>
                \ :call EXtend#winstate#Save()<CR>
                \ gvy:<C-u>call <SID>OperatorGlobalFromSelectionEntire()<CR>


nnoremap <silent> <Plug>VGlobalNormal
                \ :<C-u>call EXtend#winstate#Save()
                \ <bar>set opfunc=<SID>OperatorVGlobal<CR>g@
xnoremap <silent> <Plug>VGlobalVisual
                \ <Esc>:call EXtend#winstate#Save()<CR>
                \ gv:<C-u>call <SID>OperatorVGlobal('selection', 1)<CR>
nnoremap <silent> <Plug>VGlobalOneLine
                \ :<C-u>call EXtend#winstate#Save()
                \ <bar>call <SID>OperatorVGlobal('singleline', 1)<CR>
nnoremap <silent> <Plug>VGlobalEntire
                \ :<C-u>call EXtend#winstate#Save()
                \ <bar>call <SID>OperatorVGlobalEntire()<CR>

nnoremap <silent> <Plug>VGlobalWordNormal
                \ :<C-u>call EXtend#winstate#Save()
                \ <bar>set opfunc=<SID>OperatorVGlobalWord<CR>g@
xnoremap <silent> <Plug>VGlobalWordVisual
                \ <Esc>:call EXtend#winstate#Save()<CR>
                \ gv:<C-u>call <SID>OperatorVGlobalWord('selection', 1)<CR>
nnoremap <silent> <Plug>VGlobalWordOneLine
                \ :<C-u>call EXtend#winstate#Save()
                \ <bar>call <SID>OperatorVGlobalWord('singleline', 1)<CR>
nnoremap <silent> <Plug>VGlobalWordEntire
                \ :<C-u>call EXtend#winstate#Save()
                \ <bar>call <SID>OperatorVGlobalWordEntire()<CR>

xnoremap <silent> <Plug>VGlobalFromSelection
                \ :<C-u>let g:EXtend_reg_save=@"<CR>
                \ :call EXtend#winstate#Save()<CR>
                \ gvy:<C-u>set opfunc=<SID>OperatorSubstituteFromSelection<CR>g@
xnoremap <silent> <Plug>VGlobalFromSelectionEntire
                \ :<C-u>let g:EXtend_reg_save=@"<CR>
                \ :call EXtend#winstate#Save()<CR>
                \ gvy:<C-u>call <SID>OperatorVGlobalFromSelectionEntire()<CR>

" =====[ Default mappings ]=====
function! s:MappingsActive(command, type) abort
    return g:EXtend_default_mappings[a:command] && g:EXtend_default_mappings[a:type]
endfunction

if s:MappingsActive('substitute', 'pattern_empty')
    nmap <Leader>s   <Plug>SubstituteNormal
    xmap <Leader>ss  <Plug>SubstituteVisual
    nmap <Leader>ss  <Plug>SubstituteOneLine
    nmap <Leader>se  <Plug>SubstituteEntire
endif

if s:MappingsActive('substitute', 'pattern_word')
    nmap <Leader>sw   <Plug>SubstituteWordNormal
    xmap <Leader>sw   <Plug>SubstituteWordVisual
    nmap <Leader>sww  <Plug>SubstituteWordOneLine
    nmap <Leader>swe  <Plug>SubstituteWordEntire
endif

if s:MappingsActive('substitute', 'pattern_selection')
    xmap <Leader>sx  <Plug>SubstituteFromSelection
    xmap <Leader>se  <Plug>SubstituteFromSelectionEntire
endif

if s:MappingsActive('global', 'pattern_empty')
    nmap <Leader>g   <Plug>GlobalNormal
    xmap <Leader>gg  <Plug>GlobalVisual
    nmap <Leader>gg  <Plug>GlobalOneLine
    nmap <Leader>ge  <Plug>GlobalEntire
endif

if s:MappingsActive('global', 'pattern_word')
    nmap <Leader>gw   <Plug>GlobalWordNormal
    xmap <Leader>gw   <Plug>GlobalWordVisual
    nmap <Leader>gww  <Plug>GlobalWordOneLine
    nmap <Leader>gwe  <Plug>GlobalWordEntire
endif

if s:MappingsActive('global', 'pattern_selection')
    xmap <Leader>gx  <Plug>GlobalFromSelection
    xmap <Leader>ge  <Plug>GlobalFromSelectionEntire
endif

if s:MappingsActive('vglobal', 'pattern_empty')
    nmap <Leader>v   <Plug>VGlobalNormal
    xmap <Leader>vv  <Plug>VGlobalVisual
    nmap <Leader>vv  <Plug>VGlobalOneLine
    nmap <Leader>ve  <Plug>VGlobalEntire
endif

if s:MappingsActive('vglobal', 'pattern_word')
    nmap <Leader>vw   <Plug>VGlobalWordNormal
    xmap <Leader>vw   <Plug>VGlobalWordVisual
    nmap <Leader>vww  <Plug>VGlobalWordOneLine
    nmap <Leader>vwe  <Plug>VGlobalWordEntire
endif

if s:MappingsActive('vglobal', 'pattern_selection')
    xmap <leader>vx  <Plug>VGlobalFromSelection
    xmap <leader>ve  <Plug>VGlobalFromSelectionEntire
endif

" Standard operators
function! s:NormalOperator(command, entire, type, argc)
    let l:range = (a:entire ? '%' : s:GetLines(a:type, a:argc))
    call EXtend#ExCommandInRange(a:command, l:range)
    call EXtend#winstate#Restore()
endfunction

function! s:OperatorSubstitute(type, ...)
    call s:NormalOperator(0, 0, a:type, a:0)
endfunction

function! s:OperatorGlobal(type, ...)
    call s:NormalOperator(1, 0, a:type, a:0)
endfunction

function! s:OperatorVGlobal(type, ...) abort
    call s:NormalOperator(2, 0, a:type, a:0)
endfunction


function! s:OperatorSubstituteEntire()
    call s:NormalOperator(0, 1, 0, 0)
endfunction

function! s:OperatorGlobalEntire()
    call s:NormalOperator(1, 1, 0, 0)
endfunction

function! s:OperatorVGlobalEntire() abort
    call s:NormalOperator(2, 1, 0, 0)
endfunction

" Operators for word and WORD
function! s:WordOperator(command, entire, type, argc)
    let l:range = (a:entire ? '%' : s:GetLines(a:type, a:argc))
    call EXtend#winstate#Restore() " First restore is to get <cword> correctly
    call EXtend#ExCommandInRange(a:command, l:range, expand('<cword>'), 1)
    call EXtend#winstate#Restore()
endfunction

function! s:OperatorSubstituteWord(type, ...) abort
    call s:WordOperator(0, 0, a:type, a:0)
endfunction

function! s:OperatorGlobalWord(type, ...) abort
    call s:WordOperator(1, 0, a:type, a:0)
endfunction

function! s:OperatorVGlobalWord(type, ...) abort
    call s:WordOperator(2, 0, a:type, a:0)
endfunction


function! s:OperatorSubstituteWordEntire() abort
    call s:WordOperator(0, 1, 0, 0)
endfunction

function! s:OperatorGlobalWordEntire() abort
    call s:WordOperator(1, 1, 0, 0)
endfunction

function! s:OperatorVGlobalWordEntire() abort
    call s:WordOperator(2, 1, 0, 0)
endfunction

" Operators that take the current selection as pattern
let g:EXtend_reg_save = ''
function! s:FromSelectionOperator(command, entire, type, args)
    let l:range = (a:entire ? '%' : s:GetLines(a:type, a:args))

    call EXtend#ExCommandInRange(a:command, l:range, @", 0)
    call EXtend#winstate#Restore()
    let @" = g:EXtend_reg_save
endfunction

function! s:OperatorSubstituteFromSelection(type, ...) abort
    call s:FromSelectionOperator(0, 0, a:type, a:0)
endfunction

function! s:OperatorGlobalFromSelection(type, ...) abort
    call s:FromSelectionOperator(1, 0, a:type, a:0)
endfunction

function! s:OperatorVGlobalFromSelection(type, ...) abort
    call s:FromSelectionOperator(2, 0, a:type, a:0)
endfunction


function! s:OperatorSubstituteFromSelectionEntire()
    call s:FromSelectionOperator(0, 1, 0, 0)
endfunction

function! s:OperatorGlobalFromSelectionEntire()
    call s:FromSelectionOperator(1, 1, 0, 0)
endfunction

function! s:OperatorVGlobalFromSelectionEntire()
    call s:FromSelectionOperator(2, 1, 0, 0)
endfunction

" Auxiliary to get the start and end line
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
