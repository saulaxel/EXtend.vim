" ==============================================================================
" File: autoload/sub_op.vim
" Description: Main logic of the plugin.
" Author: Saul Axel <saulaxel.50@gmail.com>
" ==============================================================================

" =====[Constant data]==================
let s:magic_prefixes = ['\V', '\M', '\m', '\v']

" =====[Auxiliary functions]=============
function! s:StateFlagsToString() abort
    let l:wl = s:WordLimits()
    let l:result = '[ '
               \ . (s:replace_complete_words ? l:wl[0] . 'CW' . l:wl[1] : 'NCW') . ' | '
               \ . s:magic_prefixes[s:magic_mode] . ' | '
               \ . (s:case_sensitive ? '\C' : '\c') . ' | '
               \ . (s:selected_corner == 1 ? '^' : 'v')
               \ . ' ]'
    return l:result
endfunction

function! s:WordLimits() abort
    return (s:magic_prefixes[s:magic_mode] ==# '\v' ? ['<', '>'] : ['\<', '\>'])
endfunction

function! s:GetPatternPrompt() abort
    return s:StateFlagsToString() . ' Pattern:'
endfunction

function! s:GetReplacementPrompt() abort
    return s:StateFlagsToString() . ' Replacement:'
endfunction

let s:selection_match_id = -1
function! s:HighlightSelection() abort
    call sub_op#matches#RangeHighlight('range_match', 'Visual', '.*',
                                   \ s:selection_start, s:selection_end)
endfunction

function! s:HighlightText(text) abort
    if empty(a:text)
        call sub_op#matches#DeleteHighlight('text_match')
        return
    endif
    let l:pattern = (s:case_sensitive ? '\C' : '\c')
                \ . (s:magic_prefixes[s:magic_mode])
    let l:wl = s:WordLimits()
    if s:replace_complete_words
        let l:pattern .= l:wl[0] . a:text . l:wl[1]
    else
        let l:pattern .= a:text
    endif

    call sub_op#matches#RangeHighlight('text_match', 'IncSearch', l:pattern,
                                   \ s:selection_start, s:selection_end)
endfunction

" =====[Readline event functions]=======
function! s:CancelOperation(dt)
    let a:dt.exit_loop = 1
    let a:dt.string    = "\<Esc>"
endfunction

function! s:UpdatedPrompt(old_pmt) abort
    return s:StateFlagsToString() . a:old_pmt[stridx(a:old_pmt, ']') + 1 : ]
endfunction

function! s:ToggleCompleteWords(dt) abort
    let s:replace_complete_words = !s:replace_complete_words
    let a:dt.prompt = s:UpdatedPrompt(a:dt.prompt)
endfunction

function! s:RotateMagicMode(dt) abort
    let s:magic_mode = (s:magic_mode + 1) % 4
    let a:dt.prompt = s:UpdatedPrompt(a:dt.prompt)
endfunction

function! s:ToggleSensitiveness(dt) abort
    let s:case_sensitive = !s:case_sensitive
    let a:dt.prompt = s:UpdatedPrompt(a:dt.prompt)
endfunction

let s:selected_corner = 1
function! s:ChangeSelectionEnd(dt) abort
    let s:selected_corner = (s:selected_corner == 1 ? 2 : 1)
    let a:dt.prompt       = s:UpdatedPrompt(a:dt.prompt)
endfunction

function! s:SelectionUp(dt) abort
    if s:selected_corner == 2 && (s:selection_end <= s:selection_start)
        call s:ChangeSelectionEnd(a:dt)
    endif

    if s:selected_corner == 1
        if s:selection_start > 1
            let s:selection_start -=1
        endif
    else
        if s:selection_end > 1
            let s:selection_end -= 1
        endif
    endif
    call s:HighlightSelection()
endfunction

function! s:SelectionDown(dt) abort
    if s:selected_corner == 1 && (s:selection_start >= s:selection_end)
        call s:ChangeSelectionEnd(a:dt)
    endif

    if s:selected_corner == 1
        if s:selection_start < line('$')
            let s:selection_start += 1
        endif
    else
        if s:selection_end < line('$')
            let s:selection_end += 1
        endif
    endif
    call s:HighlightSelection()
endfunction

function! s:OnPatternChange(dt) abort
    call s:HighlightText(a:dt.string)
endfunction

function! s:OnReplacementChange(dt) abort
    call s:HighlightText(s:original_text)
endfunction

let s:key_handlers = {
\   "\<Esc>": function('s:CancelOperation'),
\   "\<C-c>": function('s:ToggleCompleteWords'),
\   "\<C-s>": function('s:ToggleSensitiveness'),
\   "\<C-g>": function('s:RotateMagicMode'),
\   "\<C-p>": function('s:SelectionUp'),
\   "\<C-n>": function('s:SelectionDown'),
\   "\<C-o>": function('s:ChangeSelectionEnd'),
\   'afterOperation': ''
\}

let s:key_handlers = extend(s:key_handlers, g:sub_op_key_handlers)
" =====[Main plugin function]===========
function! s:RestoreHighlightState(old_hlsearch)
    let &hlsearch = a:old_hlsearch
    call sub_op#matches#DeleteAllHighlights()
endfunction

function! sub_op#SubstituteInRange(start, end, ...) abort
    let [l:old_hlsearch, &hlsearch] = [&hlsearch, 0]

    let s:selection_start = a:start
    let s:selection_end   = a:end

    let s:original_text          = get(a:, 1, '')
    let s:replace_complete_words = get(a:, 2, 0)
    let s:case_sensitive         = &ignorecase ? 0 : 1
    let s:magic_mode             = &magic ? 2 : 1

    call s:HighlightSelection()
    call sub_op#pos#Restore()

    if empty(s:original_text)
        let s:key_handlers.afterOperation = function('s:OnPatternChange')
        let s:original_text =
                \ sub_op#input#ReadLine(s:GetPatternPrompt(), s:key_handlers)

        if s:original_text ==# "\<Esc>"
            call s:RestoreHighlightState(l:old_hlsearch)
            echo 'Substitute canceled'
            return
        endif
    endif
    call s:HighlightText(s:original_text)

    let s:key_handlers.afterOperation = function('s:OnReplacementChange')
    let s:replacement =
            \ sub_op#input#ReadLine(s:GetReplacementPrompt(), s:key_handlers)

    if s:replacement ==# "\<Esc>"
        call s:RestoreHighlightState(l:old_hlsearch)
        echo 'Substitute canceled'
        return
    endif

    let l:wl = s:WordLimits()
    let s:original_text = s:magic_prefixes[s:magic_mode]
                      \ . (s:replace_complete_words ? l:wl[0] : '')
                      \ . escape(s:original_text, '/\')
                      \ . (s:replace_complete_words ? l:wl[1] : '')
                      \ . (s:case_sensitive ? '\C' : '\c')

    let s:replacement = escape(s:replacement, '/\')

    " Makes the substitution
    execute s:selection_start . ',' . s:selection_end
                  \ . 's/' . s:original_text . '/' . s:replacement
                  \ . '/e' . (&gdefault ? '' : 'g')

    call s:RestoreHighlightState(l:old_hlsearch)
endfunction
" vim:tw=80:et:ts=4:sts=4:sw=4:fdm=marker:spell:spl=en
