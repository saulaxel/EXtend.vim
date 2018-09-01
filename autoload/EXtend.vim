" ==============================================================================
" File: autoload/EXtend.vim
" Description: Main logic of the plugin.
" Author: Saul Axel <saulaxel.50@gmail.com>
" ==============================================================================

" =====[Constant data]==================
let s:magic_prefixes = ['\V', '\M', '\m', '\v']
let s:command_name   = ['substitute', 'global', 'vglobal']

let s:scopes = ['', '%', 'argdo %', 'windo %', 'bufdo %']

" =====[Auxiliary functions]=============
function! s:StateFlagsToString() abort
    let l:wl = s:WordLimits()
    let l:result = '[ '
               \ . s:GetScope()
               \ . s:command_name[s:command][0] . ' | '
               \ . (s:complete_words ? l:wl[0] . 'CW' . l:wl[1] : 'NCW') . ' | '
               \ . s:magic_prefixes[s:magic_mode] . ' | '
               \ . (s:case_sensitive ? '\C' : '\c') . ' | '
               \ . (s:selected_corner == 1 ? '^' : 'v')
               \ . ' ]'
    return l:result
endfunction

function! s:WordLimits() abort
    return (s:magic_prefixes[s:magic_mode] ==# '\v' ? ['<', '>'] : ['\<', '\>'])
endfunction

function! s:GetScope()
    if s:operation_scope
        return s:scopes[s:operation_scope]
    else
        return s:selection_start . ',' . s:selection_end
    endif
endfunction

function! s:GetPatternPrompt() abort
    return s:StateFlagsToString() . ' Pattern:'
endfunction

function! s:GetReplacementPrompt() abort
    return s:StateFlagsToString() . ' Replacement:'
endfunction

function! s:HighlightSelection() abort
    if s:operation_scope
        call EXtend#matches#DeleteHighlight('range_match')
        return
    endif

    call EXtend#matches#RangeHighlight('range_match',
                \ g:EXtend_highlight_range,  '.*',
                \ s:selection_start, s:selection_end)
endfunction

function! s:HighlightPattern(pattern) abort
    if empty(a:pattern)
        call EXtend#matches#DeleteHighlight('pattern_match')
        return
    endif
    let l:pattern = (s:case_sensitive ? '\C' : '\c')
                \ . (s:magic_prefixes[s:magic_mode])
    let l:wl = s:WordLimits()
    if s:complete_words
        let l:pattern .= l:wl[0] . a:pattern . l:wl[1]
    else
        let l:pattern .= a:pattern
    endif

    call EXtend#matches#RangeHighlight('pattern_match',
                \ g:EXtend_highlight_pattern,
                \ l:pattern, s:selection_start, s:selection_end)
endfunction

" =====[ReadLine event functions]=======
function! EXtend#CancelOperation(dt)
    let a:dt.exit_loop = 1
    let a:dt.string    = "\<Esc>"
endfunction

function! EXtend#UpdatePrompt(dt) abort
    let l:pmt = a:dt.prompt
    let a:dt.prompt = s:StateFlagsToString() . l:pmt[stridx(l:pmt, ']') + 1 : ]
endfunction

function! EXtend#RotateCommand(dt) abort
    let s:command   = (s:command + 1) % 3
    call EXtend#UpdatePrompt(a:dt)
endfunction

function! EXtend#RotateOperationScope(dt) abort
    let s:operation_scope = (s:operation_scope + 1) % 5
    call EXtend#UpdatePrompt(a:dt)
    call s:HighlightSelection()
endfunction

function! EXtend#ToggleCompleteWords(dt) abort
    let s:complete_words = !s:complete_words
    call EXtend#UpdatePrompt(a:dt)
endfunction

function! EXtend#RotateMagicMode(dt) abort
    let s:magic_mode = (s:magic_mode + 1) % 4
    call EXtend#UpdatePrompt(a:dt)
endfunction

function! EXtend#ToggleSensitiveness(dt) abort
    let s:case_sensitive = !s:case_sensitive
    call EXtend#UpdatePrompt(a:dt)
endfunction

let s:selected_corner = 1
function! EXtend#ToggleSelectionEnd(dt) abort
    let s:selected_corner = (s:selected_corner == 1 ? 2 : 1)
    call EXtend#UpdatePrompt(a:dt)
endfunction

function! EXtend#MoveSelectionUp(dt) abort
    if s:selected_corner == 2 && (s:selection_end <= s:selection_start)
        call EXtend#ToggleSelectionEnd(a:dt)
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
    call EXtend#UpdatePrompt(a:dt)
endfunction

function! EXtend#MoveSelectionDown(dt) abort
    if s:selected_corner == 1 && (s:selection_start >= s:selection_end)
        call EXtend#ToggleSelectionEnd(a:dt)
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
    call EXtend#UpdatePrompt(a:dt)
endfunction

function! s:OnPatternChange(dt) abort
    call s:HighlightPattern(a:dt.string)
endfunction

function! s:OnReplacementChange(dt) abort
    call s:HighlightPattern(s:pattern)
endfunction

let s:key_handlers = {
\   "\<Esc>": function('EXtend#CancelOperation'),
\   "\<C-_>": function('EXtend#RotateOperationScope'),
\   "\<C-\>": function('EXtend#RotateCommand'),
\   "\<C-c>": function('EXtend#ToggleCompleteWords'),
\   "\<C-s>": function('EXtend#ToggleSensitiveness'),
\   "\<C-g>": function('EXtend#RotateMagicMode'),
\   "\<C-p>": function('EXtend#MoveSelectionUp'),
\   "\<C-n>": function('EXtend#MoveSelectionDown'),
\   "\<C-o>": function('EXtend#ToggleSelectionEnd'),
\   'afterOperation': ''
\}

let s:key_handlers = extend(s:key_handlers, g:EXtend_key_handlers)
" =====[Main plugin function]===========
function! s:RestoreHighlightState(old_hlsearch)
    let &hlsearch = a:old_hlsearch
    call EXtend#matches#DeleteAllHighlights()
endfunction

function! EXtend#ExCommandInRange(command, initial_range, ...) abort
    let [l:old_hlsearch, &hlsearch] = [&hlsearch, 0]

    let s:command = a:command

    if type(a:initial_range) == type([])
        let s:selection_start = a:initial_range[0]
        let s:selection_end   = a:initial_range[1]

        let s:operation_scope = 0
    else
        let s:selection_start = 1
        let s:selection_end   = line('$')

        let s:operation_scope = 1
    endif

    let s:pattern        = get(a:, 1, '')
    let s:complete_words = get(a:, 2, 0)
    let s:case_sensitive = &ignorecase ? 0 : 1
    let s:magic_mode     = &magic ? 2 : 1

    call s:HighlightSelection()
    call EXtend#pos#Restore()

    if empty(s:pattern)
        let s:key_handlers.afterOperation = function('s:OnPatternChange')
        let s:pattern =
                \ EXtend#input#ReadLine(s:GetPatternPrompt(), s:key_handlers)

        if s:pattern ==# "\<Esc>"
            call s:RestoreHighlightState(l:old_hlsearch)
            echo 'Operation canceled'
            return
        endif
    endif
    call s:HighlightPattern(s:pattern)

    let s:key_handlers.afterOperation = function('s:OnReplacementChange')
    let s:second_text =
            \ EXtend#input#ReadLine(s:GetReplacementPrompt(), s:key_handlers)

    if s:second_text ==# "\<Esc>"
        call s:RestoreHighlightState(l:old_hlsearch)
        echo 'Operation canceled'
        return
    endif

    let l:wl = s:WordLimits()
    let s:pattern = s:magic_prefixes[s:magic_mode]
                \ . (s:complete_words ? l:wl[0] : '')
                \ . escape(s:pattern, '&')
                \ . (s:complete_words ? l:wl[1] : '')
                \ . (s:case_sensitive ? '\C' : '\c')

    let s:second_text = escape(s:second_text, '&')

    " Executes the command
    let l:full_command = s:GetScope() . s:command_name[s:command]
                     \ . '&' . s:pattern . '&' . s:second_text

    if s:command == 0
        let l:full_command .= '&e' . (&gdefault ? '' : 'g')
    endif

    execute l:full_command

    call s:RestoreHighlightState(l:old_hlsearch)
endfunction
" vim:tw=80:et:ts=4:sts=4:sw=4:fdm=marker:spell:spl=en
