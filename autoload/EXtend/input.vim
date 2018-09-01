" ==============================================================================
" File: autoload/EXtend/input.vim
" Description: Utilities for retrieving data from the user.
" Author: Saul Axel <saulaxel.50@gmail.com>
" ==============================================================================

" =====[ReadChar and its auxiliary]=====
function! s:FixMetaKeys() abort
    let l:char = getchar(0)
    if l:char
        return eval('"\<M-' . nr2char(l:char) . '>"')
    else
        return "\<Esc>"
    endif
endfunction

function! EXtend#input#ReadChar() abort
    try
        let l:char = getchar()

        if type(l:char) == type(0)
            let l:char = nr2char(l:char)
        endif
    catch /^Vim:Interrupt$/
        let l:char = "\<C-c>"
    endtry

    if !has('nvim') && l:char ==# "\<Esc>"
        let l:char = s:FixMetaKeys()
    endif

    return l:char
endfunction

" =====[Functions to control ReadLine]=====
" Moving the cursor
function! EXtend#input#Utf8CharsToStart(str, cur)
    let l:cur = a:cur
    let l:num_chars = 0
    while l:cur > 0
        let l:char_code = char2nr(a:str[l:cur])

        if l:char_code < 128 || l:char_code >= 192
            break
        endif

        let l:cur -= 1
        let l:num_chars += 1
    endwhile

    return l:num_chars
endfunction

function! EXtend#input#Utf8CharLength(char)
    let l:char_code = char2nr(a:char)

    if l:char_code >= 240
        return 4
    elseif l:char_code >= 224
        return 3
    elseif l:char_code >= 192
        return 2
    else
        return 1
    endif
endfunction

function! EXtend#input#MoveCursorLeft(dt) abort
    let l:str = a:dt.string

    if a:dt.cursor_pos - 1 <= 0
        let a:dt.cursor_pos = 0
        return
    endif

    let a:dt.cursor_pos -= 1
    let a:dt.cursor_pos -=  EXtend#input#Utf8CharsToStart(l:str, a:dt.cursor_pos)
endfunction

function! EXtend#input#MoveCursorRight(dt) abort
    let l:str  = a:dt.string
    let l:slen = strlen(l:str)

    if a:dt.cursor_pos + 1 >= l:slen
        let a:dt.cursor_pos = l:slen
        return
    endif

    let a:dt.cursor_pos += EXtend#input#Utf8CharLength(l:str[a:dt.cursor_pos])
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

function! EXtend#input#MoveCursorWORDLeft(dt) abort
    let a:dt.cursor_pos = s:PreviousWordIndex(a:dt.string, a:dt.cursor_pos)
endfunction

function! EXtend#input#MoveCursorWORDRight(dt) abort
    let l:new_pos = s:NextWordIndex(a:dt.string, a:dt.cursor_pos)
    if l:new_pos == a:dt.cursor_pos
        let a:dt.cursor_pos += 1
    elseif a:dt.string[l:new_pos] =~# '\s'
        let a:dt.cursor_pos = l:new_pos + 1
    elseif l:new_pos > a:dt.cursor_pos
        let a:dt.cursor_pos = l:new_pos
    endif

    let a:dt.cursor_pos -= EXtend#input#Utf8CharsToStart(a:dt.string, a:dt.cursor_pos)
endfunction

function! EXtend#input#MoveCursorToStart(dt) abort
    let a:dt.cursor_pos = 0
endfunction

function! EXtend#input#MoveCursorToEnd(dt) abort
    let a:dt.cursor_pos = strlen(a:dt.string)
endfunction

" Deleting
function! EXtend#input#DeleteChar(dt) abort
    if a:dt.cursor_pos ==# 0
        return
    endif

    let l:str = a:dt.string

    call EXtend#input#MoveCursorLeft(a:dt)

    let l:cur  = a:dt.cursor_pos
    let l:clen = EXtend#input#Utf8CharLength(l:str[l:cur])

    if l:cur ==# 0
        let a:dt.string = l:str[l:clen : ]
    else
        let a:dt.string = l:str[ : l:cur - 1] . l:str[l:cur + l:clen : ]
    endif
endfunction

function! EXtend#input#InsertAtCurrentPosition(dt) abort
    let l:str = a:dt.string
    let l:cur = a:dt.cursor_pos

    if l:cur == 0
        let a:dt.string = a:dt.char . l:str
    elseif l:cur == strlen(l:str)
        let a:dt.string .= a:dt.char
    else
        let a:dt.string = l:str[ : l:cur - 1] . a:dt.char . l:str[l:cur : ]
    endif

    let a:dt.cursor_pos += strlen(a:dt.char)
endfunction

function! EXtend#input#DeleteWORD(dt) abort
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

function! EXtend#input#DeleteToStart(dt) abort
    if a:dt.cursor_pos == 0
        return
    endif

    let a:dt.string = a:dt.string[a:dt.cursor_pos : ]
    let a:dt.cursor_pos = 0
endfunction

function! EXtend#input#DeleteToEnd(dt) abort
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
    call EXtend#matches#PointHighlight('cursor_match',
                \ g:EXtend_highlight_position, a:new_pos[1], a:new_pos[2])
endfunction

function! EXtend#input#MovePosLeft(dt) abort
    if a:dt.pos[2] > 1
        if a:dt.pos[2] >= col('$')
            let a:dt.pos[2] = col('$') - 1
        else
            let a:dt.pos[2] -= 1
        endif

        call s:UpdatePos(a:dt.pos)
    endif
endfunction

function! EXtend#input#MovePosRight(dt) abort
    if a:dt.pos[2] < col('$')
        let a:dt.pos[2] += 1
        call s:UpdatePos(a:dt.pos)
    endif
endfunction

function! EXtend#input#MovePosUp(dt) abort
    if a:dt.pos[1] > 1
        let a:dt.pos[1] -= 1

        call s:UpdatePos(a:dt.pos)
    endif
endfunction

function! EXtend#input#MovePosDown(dt) abort
    if a:dt.pos[1] < line('$')
        let a:dt.pos[1] += 1

        call s:UpdatePos(a:dt.pos)
    endif
endfunction

function! EXtend#input#MovePosToStart(dt) abort
    let a:dt.pos[2] = 1
    call s:UpdatePos(a:dt.pos)
endfunction

function! EXtend#input#MovePosToEnd(dt) abort
    let a:dt.pos[2] = col('$')
    call s:UpdatePos(a:dt.pos)
endfunction

" Moving viewport
function! EXtend#input#ViewPortDown(dt) abort
    execute "normal! \<C-e>"
endfunction

function! EXtend#input#ViewPortUp(dt) abort
    execute "normal! \<C-y>"
endfunction

function! EXtend#input#ViewPortHalfPageDown(dt) abort
    execute "normal! \<C-u>"
endfunction

function! EXtend#input#ViewPortHalfPageUp(dt) abort
    execute "normal! \<C-d>"
endfunction

function! EXtend#input#ViewPortPageDown(dt) abort
    execute "normal! \<C-f>"
endfunction

function! EXtend#input#ViewPortPageUp(dt) abort
    execute "normal! \<C-b>"
endfunction

" Others
function! EXtend#input#CompleteRegister(dt) abort
    let l:added_word     = EXtend#registers#GetRegisterOrCompletion()
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

function! EXtend#input#ExitLoop(dt) abort
    let a:dt.exit_loop = 1
endfunction

function! EXtend#input#Nothing(dt) abort
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
" Free keys: ^Q^Y^D^L^Z^X^V^\(^_ - ^/)
call s:AssignKeys(["\<Left>", "\<C-b>"], 'EXtend#input#MoveCursorLeft')
call s:AssignKeys(["\<Right>", "\<C-f>"], 'EXtend#input#MoveCursorRight')
call s:AssignKeys(["\<C-Left>", "\<M-b>"], 'EXtend#input#MoveCursorWORDLeft')
call s:AssignKeys(["\<C-Right>", "\<M-f>"], 'EXtend#input#MoveCursorWORDRight')
call s:AssignKeys(["\<Home>", "\<C-a>"], 'EXtend#input#MoveCursorToStart')
call s:AssignKeys(["\<End>", "\<C-e>"], 'EXtend#input#MoveCursorToEnd')
" Delete operations
call s:AssignKeys(["\<BS>", "\<C-h>"], 'EXtend#input#DeleteChar')
call s:AssignKeys(["\<C-BS>", "\<C-w>"], 'EXtend#input#DeleteWORD')
call s:AssignKeys(["\<C-u>"], 'EXtend#input#DeleteToStart')
call s:AssignKeys(["\<C-k>"], 'EXtend#input#DeleteToEnd')
" Moving the point
call s:AssignKeys(["\<M-Left>", "\<M-h>"], 'EXtend#input#MovePosLeft')
call s:AssignKeys(["\<M-Right>", "\<M-l>"], 'EXtend#input#MovePosRight')
call s:AssignKeys(["\<M-Up>", "\<M-k>"], 'EXtend#input#MovePosUp')
call s:AssignKeys(["\<M-Down>", "\<M-j>"], 'EXtend#input#MovePosDown')
call s:AssignKeys(["\<M-a>", "\<M-A>"], 'EXtend#input#MovePosToStart')
call s:AssignKeys(["\<M-e>", "\<M-E>"], 'EXtend#input#MovePosToEnd')
" Moving the viewport
call s:AssignKeys(["\<M-u>"], 'EXtend#input#ViewPortUp')
call s:AssignKeys(["\<M-d>"], 'EXtend#input#ViewPortDown')
call s:AssignKeys(["\<M-U>"], 'EXtend#input#ViewPortHalfPageUp')
call s:AssignKeys(["\<M-D>"], 'EXtend#input#ViewPortHalfPageDown')
call s:AssignKeys(["\<PageDown>", "\<M-v>"], 'EXtend#input#ViewPortPageDown')
call s:AssignKeys(["\<PageUp>", "\<M-V>"], 'EXtend#input#ViewPortPageUp')
" Others
call s:AssignKeys(["\<C-r>"], 'EXtend#input#CompleteRegister')
call s:AssignKeys(["\<CR>", "\<Esc>", "\<C-c>", "\<NL>"], 'EXtend#input#ExitLoop')

function! EXtend#input#ReadLine(prompt, key_handlers) abort
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

        let l:dt.char = EXtend#input#ReadChar()

        let l:c = l:dt.char

        if has_key(a:key_handlers, l:c)
            call a:key_handlers[l:c](l:dt)
        elseif has_key(s:default_key_handlers, l:c)
            call s:default_key_handlers[l:c](l:dt)
        else
            " Direct writing
            call EXtend#input#InsertAtCurrentPosition(l:dt)
        endif
        call s:ExecuteEvent(l:dt, a:key_handlers, 'afterOperation')
    endwhile

    return l:dt.string
endfunction

function! s:PrintCurrentString(dt) abort
    let l:cur  = a:dt.cursor_pos
    let l:str  = a:dt.string
    let l:slen = strlen(l:str)
    let l:clen = EXtend#input#Utf8CharLength(l:str[l:cur])

    if l:cur == l:slen
        echon l:str
        execute 'echohl' g:EXtend_highlight_cursor
        echon ' '
        echohl Normal
    elseif l:slen == l:clen
        execute 'echohl' g:EXtend_highlight_cursor
        echon l:str
        echohl Normal
    elseif l:cur == 0
        execute 'echohl' g:EXtend_highlight_cursor
        echon l:str[0 : l:clen - 1]
        echohl Normal
        echon l:str[l:clen : ]
    else
        echon l:str[ : l:cur - 1]
        execute 'echohl' g:EXtend_highlight_cursor
        echon l:str[l:cur : l:cur + l:clen - 1]
        echohl Normal
        echon l:str[l:cur + l:clen : ]
    endif
endfunction

function! s:ExecuteEvent(dt, key_handlers, event) abort
    if has_key(a:key_handlers, a:event) && !empty(a:key_handlers[a:event])
        call a:key_handlers[a:event](a:dt)
    endif
endfunction
" vim:tw=80:et:ts=4:sts=4:sw=4:fdm=marker:spell:spl=en
