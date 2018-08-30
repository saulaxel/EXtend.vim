" ==============================================================================
" File: autoload/input.vim
" Description: Utilities for retrieving data from the user.
" Author: Saul Axel <saulaxel.50@gmail.com>
" ==============================================================================

" =====[ReadChar and its auxiliary]=====
function! sub_op#input#ReadChar() abort
    try
        let l:char = getchar()

        if type(l:char) == type(0)
            let l:char = nr2char(l:char)
        endif

    catch /^Vim:Interrupt$/
        let l:char = "\<C-c>"
    endtry

    return l:char
endfunction

" =====[Functions to control ReadLine]=====
" Moving the cursor
function! sub_op#input#MoveCursorLeft(dt) abort
    let a:dt.cursor_pos = max([0, a:dt.cursor_pos - 1])
endfunction

function! sub_op#input#MoveCursorRight(dt) abort
    let a:dt.cursor_pos = min([strlen(a:dt.string), a:dt.cursor_pos + 1])
endfunction

function! s:PreviousWordIndex(text, curr_index) abort
    let l:index = min([a:curr_index, strlen(a:text) - 1])

    if l:index > 0 && a:text[l:index] =~# '\S'
        let l:index -= 1
    endif

    while l:index > 0 && a:text[l:index] =~# '\s'
        let l:index -= 1
    endwhile

    while l:index > 0 && a:text[l:index - 1] =~# '\S'
        let l:index -= 1
    endwhile

    return l:index
endfunction

function! s:NextWordIndex(text, curr_index) abort
    let l:index   = min([a:curr_index, strlen(a:text) - 1])
    let l:textlen = strlen(a:text)

    while l:index < l:textlen - 1 && a:text[l:index] =~# '\S'
        let l:index += 1
    endwhile

    while l:index < l:textlen - 1 && a:text[l:index] =~# '\s'
        let l:index += 1
    endwhile

    return l:index
endfunction

function! sub_op#input#MoveCursorWORDLeft(dt) abort
    let a:dt.cursor_pos = s:PreviousWordIndex(a:dt.string, a:dt.cursor_pos)
endfunction

function! sub_op#input#MoveCursorWORDRight(dt) abort
    let l:new_pos = s:NextWordIndex(a:dt.string, a:dt.cursor_pos)
    if l:new_pos == a:dt.cursor_pos
        let a:dt.cursor_pos += 1
    elseif a:dt.string[l:new_pos] =~# '\s'
        let a:dt.cursor_pos = l:new_pos + 1
    elseif l:new_pos > a:dt.cursor_pos
        let a:dt.cursor_pos = l:new_pos
    endif
endfunction

function! sub_op#input#MoveCursorToStart(dt) abort
    let a:dt.cursor_pos = 0
endfunction

function! sub_op#input#MoveCursorToEnd(dt) abort
    let a:dt.cursor_pos = strlen(a:dt.string)
endfunction

" Deleting
function! sub_op#input#DeleteChar(dt) abort
    if a:dt.cursor_pos ==# 0
        return
    endif

    let l:str = a:dt.string
    let l:cur = a:dt.cursor_pos

    if l:cur ==# 1
        let a:dt.string = l:str[1 : ]
    else
        let a:dt.string = l:str[ : l:cur - 2] . l:str[l:cur : ]
    endif

    let a:dt.cursor_pos -= 1
endfunction

function! sub_op#input#InsertAtCurrentPosition(dt) abort
    let l:str = a:dt.string
    let l:cur = a:dt.cursor_pos

    if l:cur == 0
        let a:dt.string = a:dt.char . l:str
    elseif l:cur == strlen(l:str)
        let a:dt.string .= a:dt.char
    else
        let a:dt.string = l:str[ : l:cur - 1] . a:dt.char . l:str[l:cur : ]
    endif

    let a:dt.cursor_pos += 1
endfunction

function! sub_op#input#DeleteWORD(dt) abort
    if a:dt.cursor_pos == 0
        return
    endif

    let l:str       = a:dt.string
    let l:cut_index = s:PreviousWordIndex(l:str, a:dt.cursor_pos)

    if l:cut_index == 0
        let a:dt.string = l:str[a:dt.cursor_pos : ]
    else
        let a:dt.string = l:str[ : l:cut_index - 1] . l:str[a:dt.cursor_pos : ]
    endif
    let a:dt.cursor_pos = l:cut_index
endfunction

function! sub_op#input#DeleteToStart(dt) abort
    if a:dt.cursor_pos == 0
        return
    endif

    let a:dt.string = a:dt.string[a:dt.cursor_pos : ]
    let a:dt.cursor_pos = 0
endfunction

function! sub_op#input#DeleteToEnd(dt) abort
    let l:str = a:dt.string
    let l:cur = a:dt.cursor_pos
    if l:cur == strlen(l:str)
        return
    endif

    if l:cur == 0
        let a:dt.string = ''
    else
        let l:str           = l:str[ : l:cur - 1]
        let a:dt.cursor_pos = strlen(a:dt.string)
    endif
endfunction

" Moving the pos inside the text
function! s:UpdatePos(new_pos)
    call setpos('.', a:new_pos)
    call sub_op#matches#PointHighlight('cursor_match', 'Cursor',
                                         \ a:new_pos[1], a:new_pos[2])
endfunction

function! sub_op#input#MovePosLeft(dt) abort
    if a:dt.pos[2] > 1
        if a:dt.pos[2] >= col('$')
            let a:dt.pos[2] = col('$') - 1
        else
            let a:dt.pos[2] -= 1
        endif

        call s:UpdatePos(a:dt.pos)
    endif
endfunction

function! sub_op#input#MovePosRight(dt) abort
    if a:dt.pos[2] < col('$')
        let a:dt.pos[2] += 1
        call s:UpdatePos(a:dt.pos)
    endif
endfunction

function! sub_op#input#MovePosUp(dt) abort
    if a:dt.pos[1] > 1
        let a:dt.pos[1] -= 1

        call s:UpdatePos(a:dt.pos)
    endif
endfunction

function! sub_op#input#MovePosDown(dt) abort
    if a:dt.pos[1] < line('$')
        let a:dt.pos[1] += 1

        call s:UpdatePos(a:dt.pos)
    endif
endfunction

function! sub_op#input#MovePosToStart(dt) abort
    let a:dt.pos[2] = 1
    call s:UpdatePos(a:dt.pos)
endfunction

function! sub_op#input#MovePosToEnd(dt) abort
    let a:dt.pos[2] = col('$')
    call s:UpdatePos(a:dt.pos)
endfunction

" Moving viewport
function! sub_op#input#ViewPortDown(dt) abort
    execute "normal! \<C-e>"
endfunction

function! sub_op#input#ViewPortUp(dt) abort
    execute "normal! \<C-y>"
endfunction

function! sub_op#input#ViewPortHalfPageDown(dt) abort
    execute "normal! \<C-u>"
endfunction

function! sub_op#input#ViewPortHalfPageUp(dt) abort
    execute "normal! \<C-d>"
endfunction

function! sub_op#input#ViewPortPageDown(dt) abort
    execute "normal! \<C-f>"
endfunction

function! sub_op#input#ViewPortPageUp(dt) abort
    execute "normal! \<C-b>"
endfunction

" Others
function! sub_op#input#CompleteRegister(dt) abort
    let l:added_word     = sub_op#registers#GetRegisterOrCompletion()
    let l:added_word_len = strlen(l:added_word)

    let l:str = a:dt.string
    let l:idx = a:dt.cursor_pos

    if l:idx == 0
        let a:dt.string      = l:added_word . l:str
        let a:dt.cursor_pos  = l:added_word_len
    elseif l:idx == strlen(a:dt.string)
        let a:dt.string      = l:str . l:added_word
        let a:dt.cursor_pos += l:added_word_len
    else
        let a:dt.string      = l:str[ : l:idx - 1] . l:added_word . l:str[l:idx : ]
        let a:dt.cursor_pos += l:added_word_len
    endif
endfunction

function! sub_op#input#ExitLoop(dt) abort
    let a:dt.exit_loop = 1
endfunction

function! sub_op#input#Nothing(dt) abort
    return
endfunction

" =====[Default key-bindings for the functions]=====
function! s:AssignKeys(key_list, function_name)
    for l:key in a:key_list
        let s:default_key_handlers[l:key] = function(a:function_name)
    endfor
endfunction

let s:default_key_handlers = {}
" Movement operations
call s:AssignKeys(["\<Left>", "\<C-b>"], 'sub_op#input#MoveCursorLeft')
call s:AssignKeys(["\<Right>", "\<C-f>"], 'sub_op#input#MoveCursorRight')
call s:AssignKeys(["\<C-Left>", "\<M-b>"], 'sub_op#input#MoveCursorWORDLeft')
call s:AssignKeys(["\<C-Right>", "\<M-f>"], 'sub_op#input#MoveCursorWORDRight')
call s:AssignKeys(["\<Home>", "\<C-a>"], 'sub_op#input#MoveCursorToStart')
call s:AssignKeys(["\<End>", "\<C-e>"], 'sub_op#input#MoveCursorToEnd')
" Delete operations
call s:AssignKeys(["\<BS>", "\<C-h>"], 'sub_op#input#DeleteChar')
call s:AssignKeys(["\<C-BS>", "\<C-w>"], 'sub_op#input#DeleteWORD')
call s:AssignKeys(["\<C-u>"], 'sub_op#input#DeleteToStart')
call s:AssignKeys(["\<C-s>"], 'sub_op#input#DeleteToEnd')
" Moving the point
call s:AssignKeys(["\<M-Left>", "\<M-h>"], 'sub_op#input#MovePosLeft')
call s:AssignKeys(["\<M-Right>", "\<M-l>"], 'sub_op#input#MovePosRight')
call s:AssignKeys(["\<M-Up>", "\<M-k>"], 'sub_op#input#MovePosUp')
call s:AssignKeys(["\<M-Down>", "\<M-j>"], 'sub_op#input#MovePosDown')
call s:AssignKeys(["\<M-a>", "\<M-A>"], 'sub_op#input#MovePosToStart')
call s:AssignKeys(["\<M-e>", "\<M-E>"], 'sub_op#input#MovePosToEnd')
" Moving the viewport
call s:AssignKeys(["\<M-u>"], 'sub_op#input#ViewPortUp')
call s:AssignKeys(["\<M-d>"], 'sub_op#input#ViewPortDown')
call s:AssignKeys(["\<M-U>"], 'sub_op#input#ViewPortHalfPageUp')
call s:AssignKeys(["\<M-D>"], 'sub_op#input#ViewPortHalfPageDown')
call s:AssignKeys(["\<PageDown>", "\<M-v>"], 'sub_op#input#ViewPortPageDown')
call s:AssignKeys(["\<PageUp>", "\<M-V>"], 'sub_op#input#ViewPortPageUp')
" Others
call s:AssignKeys(["\<C-r>"], 'sub_op#input#CompleteRegister')
call s:AssignKeys(["\<CR>", "\<Esc>", "\<C-c>", "\<NL>"], 'sub_op#input#ExitLoop')

function! sub_op#input#ReadLine(prompt, key_handlers) abort
    let l:dt = {
    \   'prompt': a:prompt,
    \   'char': '',
    \   'string': '',
    \   'cursor_pos': 0,
    \   'pos': getpos('.'),
    \   'exit_loop': 0
    \}

    call s:UpdatePos(l:dt.pos)
    while !l:dt.exit_loop
        echon l:dt.prompt
        call s:PrintCurrentString(l:dt)
        redraw

        let l:dt.char = sub_op#input#ReadChar()

        let l:c = l:dt.char
        if has_key(a:key_handlers, l:c)
            call a:key_handlers[l:c](l:dt)
        elseif has_key(s:default_key_handlers, l:c)
            call s:default_key_handlers[l:c](l:dt)
        else
            " Direct writing
            call sub_op#input#InsertAtCurrentPosition(l:dt)
        endif
        call s:ExecuteEvent(l:dt, a:key_handlers, 'afterOperation')
    endwhile

    return l:dt.string
endfunction

function! s:PrintCurrentString(dt) abort
    let l:cur  = a:dt.cursor_pos
    let l:str  = a:dt.string
    let l:slen = strlen(l:str)

    if l:cur == l:slen
        echon l:str
        echohl CursorColumn
        echon ' '
        echohl Normal
    elseif l:slen == 1
        echohl CursorColumn
        echon l:str
        echohl Normal
    elseif l:cur == 0
        echohl CursorColumn
        echon l:str[0]
        echohl Normal
        echon l:str[1 : ]
    else
        echon l:str[ : l:cur - 1]
        echohl CursorColumn
        echon l:str[l:cur]
        echohl Normal
        echon l:str[l:cur + 1 : ]
    endif
endfunction

function! s:ExecuteEvent(dt, key_handlers, event) abort
    if has_key(a:key_handlers, a:event) && !empty(a:key_handlers[a:event])
        call a:key_handlers[a:event](a:dt)
    endif
endfunction
" vim:tw=80:et:ts=4:sts=4:sw=4:fdm=marker:spell:spl=en
