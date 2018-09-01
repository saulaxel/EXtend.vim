*extend.txt* The substitute command evolves into an operator

           $$$$$$$$\ $$\   $$\   $$\                               $$\
           $$  _____|$$ |  $$ |  $$ |                              $$ |
       $$\ $$ |      \$$\ $$  |$$$$$$\    $$$$$$\  $$$$$$$\   $$$$$$$ |
       \__|$$$$$\     \$$$$  / \_$$  _|  $$  __$$\ $$  __$$\ $$  __$$ |
           $$  __|    $$  $$<    $$ |    $$$$$$$$ |$$ |  $$ |$$ /  $$ |
       $$\ $$ |      $$  /\$$\   $$ |$$\ $$   ____|$$ |  $$ |$$ |  $$ |
       \__|$$$$$$$$\ $$ /  $$ |  \$$$$  |\$$$$$$$\ $$ |  $$ |\$$$$$$$ |
           \________|\__|  \__|   \____/  \_______|\__|  \__| \_______|
                  When the Ex commands evolve into operators
                  __________________________________________

Version: 0.1
Author: Saúl Axel <saulaxel.50@gmail.com>

==============================================================================
CONTENTS                                                     *extend-contents*

    0. Introduction and installation ........ |extend-intro|
    1. Usage ................................ |extend-usage|
    1.1 Basic operators ..................... |extend-usage-operators|
    1.2 All operators ....................... |extend-usage-operators|
    1.3 Insert objects and registers ........ |extend-usage-insert-reg|
    1.4 Moving the position above text ...... |extend-usage-move-pos|
    1.5 Changing the matching mode .......... |extend-usage-matching-mode|
    1.6 Editing in the prompt line .......... |extend-usage-prompt-edit|
    1.7 Modifying the range dynamically ..... |extend-usage-modify-range|
    1.8 Moving the window viewport .......... |extend-usage-modify-viewport|
    2. Mappings ............................. |extend-mappings|
    3. Configuration ........................ |extend-configuration|
    3.1 Highlight colors .................... |extend-configuration-colors|
    3.2 Enabling and disabling operators .... |extend-configuration-operators|
    3.3 Readline() key handlers ............. |extend-configuration-readline|
    4. Bug reports and contributing ......... |extend-bugreports|
    5. Changelog ............................ |extend-changelog|

==============================================================================
0  Introduction                                                 *extend-intro*

Some commands like :substitute and :global are extremely powerfull, but with
that great power comes a lot of trouble. The dealing with regular expressions,
with search of complete words or free text, the case-sensitiveness, magicness,
line ranges that we can't visualize and most importantly, the fact that these
commands can't be applied as if they were operators are just some of the
points that make these Ex commands so awkward to use in the common workflow.

In response of all that concerns comes EXtend.vim, that provides the
functionality of those venerable Ex commands packed into easy to use
operators, a highlight system that provides visual feedback by shows the range
of operation and the text to be operated in the fly and an steroids-provided
input line with two virtual cursors: one for editing the text you type as in
any other input line, and a second one  that moves over the text of the buffer
and lets you pick up words from it and insert them on the input line.

Take all that and add the ability to customize every color, keystroke and
mapping to your own needs and you got a tool that can easily merge into your
vim workflow and make your life much easier.

==============================================================================
1  Usage                                                        *extend-usage*

Basic operators:                                *extend-usage-basic-operators*
---------------

The following are the main commands that this plugin emulates/extends and its
associated operators:
    - Substitute <=> <Leader>s
    - Global     <=> <Leader>g
    - VGlobal    <=> <Leader>v

**Note**: These are the default mappings for the operators. All of these
can be disabled and/or remapped. See |extend-configuration|.

As all the operators will follow the same logic, we will mostly show examples
of substitution rather than the others, because it is most easy to demonstrate.

Now, imagine you have the following code from an imaginary programming
language and you want to replace the variable "i" and "j" from the second
"for" (the one of the center) with "line" and "col" respectively.
>
    for (var i = 0; i < N; i++) {
        println('Processing . . .')
    }
    for (var i = 0; i < LINES; i++) {
        for (var j = 0; j < COLUMNS; j++) {
            print(mat[i][j], ' ')
        }
        println()
    }
    for (var j = 0; j < M; j++) {
        println('More processing . . .')
    }

Positioned just over the f of the inner for, you can type:

    <Leader>sa{i<C-c><Enter>line<Enter>

To substitute "i" by "line", and later:

    <Leader>sa{j<C-c><Enter>col<Enter>

To substitute "j" by "col".

Now let's explain these sequences by parts:

    * <Leader>s     : Operator "Substitute".

    * a{            : Text object "around brackets", where the operator will
                      be applied.

    * i<C-c><Enter> : The substitution text and <Enter> to terminate input().
                      The <C-c> (Ctrl + c) keystroke turns On the "full word
                      matching" so that "i" is matched only when not inside a
                      word. Without <C-c>, the i in print/println would also be
                      substituted. <C-c> could actually be used in any time
                      between the { and the final <Enter>

    * line<Enter>   : The string to substitute "i" with and <Enter> to finish.

Just after applying the operator on the object, a Highlight of full lines will
appear showing the zone in which the operator will take effect. A little later
when writing the pattern, the matching text inside the range will be also
highlighted.
Those highlights should be cleared when the substitution is finished or
canceled, but in cases where an error is encountered it is possible that the
highlights remain in the text. In case this happens, the highlights can be
manually cleared as follows:

    :call substitute#matches#DeleteAllHighlights()<Enter>

One thing to note is that the operators from this plugin, just like ex
commands normally do, act always on full lines (linewise). That is the reason
we could use the object "a{" despite the fact that the variable "i" was not
really inside the brackets but over the line of the starting bracket.

Looking good so far, but now we want to be more verbose and change "line" by
"line_num" and "col" by "column_num". The previous method would swill be ok
but what if we make the plugin to insert words by us so we can reduce a little
typing.
The operator <Leader>sw (Substitute current word) is similar to the
<Leader>s, but instead of ask for input twice it only does it once. That is,
because it automatically takes the word under the cursor as the pattern.
Another difference between then is that <Leader>sw start with the flag of
"complete words" so we no longer need to press <C-c>.

We can then position on the "print(mat[line][col])" instruction because that
is where nearest the words "line" and "col" are so we can move less. With the
cursor over "line" we type:

    <Leader>sw2a{line_num<Enter>

And later, over "col":

    <Leader>sw2a{column_num<Enter>

All operators:                                    *extend-usage-all-operators*
---------------

When an operator is used with de notation {operator}{text_object_or_movement},
it is said that it was used in "operator pending mode" in which the operator
is active waiting for the text it will operate on. Operators can also be used
from visual mode, where they operate on the visual selection currently active.
Finally, some builtin operators provide an "apply to current line" notations
that consist on repeating the last letter of the operator.
All of that types of operations are provided by this plugin with the addition
of an "apply to entire buffer" version that consists in appending "e" to the
operator.

This plugin provides the three options for all of its operators. The default
keystrokes for using them are:

   \__       |             Mode             |   Normal   | Current word |
Name  \__    |                              |            |              |
-------------+------------------------------+------------+--------------+
             |       Operator pending       | <Leader>s  | <Leader>sw   |
Substitute   |         Visual mode          | <Leader>ss | <Leader>sw   |
             |  Normal Mode Current line    | <Leader>ss | <Leader>sww  |
             |  Normal Mode Entire buffer   | <Leader>se | <Leader>swe  |
-------------+------------------------------+------------+--------------+
             |       Operator pending       | <Leader>g  | <Leader>gw   |
Global       |         Visual mode          | <Leader>gg | <Leader>gw   |
             |  Normal Mode Current line    | <Leader>gg | <Leader>gww  |
             |  Normal Mode Entire buffer   | <Leader>ge | <Leader>gwe  |
-------------+------------------------------+------------+--------------+
             |       Operator pending       | <Leader>v  | <Leader>vw   |
VGlobal      |         Visual mode          | <Leader>vv | <Leader>vw   |
             |  Normal Mode Current line    | <Leader>vv | <Leader>vww  |
             |  Normal Mode Entire buffer   | <Leader>ve | <Leader>vwe  |

Note that, unlike built-in vim operators, there is also need to repeat the
last letter for the visual mode of all "normal" versions. This is to avoid the
delay that would be present otherwise while disambiguating the command.

There is also an extra kind of operations that is applied only in visual mode.
For understanding its reason we should think about the two reasons we could
have for select a text before a substitute or global:
    * For the command to be used in that range (the most common)
    * For the matching pattern for the command to be the selected text

The previous commands all used the selection for the first reason. If the
visual selection is used as the pattern, we need another way to select the
range so these mappings also works like operators (enter in operator pending
mode after applied) although they were invoked from visual mode: ¡These are
like hybrids!.

The operators in this case are are:

    | <Leader>sx | Substitute current selection              |
    | <Leader>gx | Global with current selection as pattern  |
    | <Leader>vx | VGlobal with current selection as pattern |

In the next example, we want to delete the endings of the variables "_var" and
set them all to false:

    let first_var = true
    let second_var = true
    let third_var = true

The way to do it is select "_var = true" from the any of the variables and
press:

    <Leader>sxap = false<Enter>

*Note*: The "entire" commands from the first table applied from visual mode also
work with the current selection as the pattern, just because if the range will
be all the buffer the visual selection can be used for other purposes.

Insert objects and registers                         *extend-usage-insert-reg*
---------------

In insert and command mode, pressing <C-r>{reg} inserts the contents of the
register {reg} onto the line we are editing. Additionally, in command mode we
can also choose press the following keystrokes instead of {reg} to insert an
object below the cursor:

    <C-w>   <=>   Word under cursor
    <C-A>   <=>   WORD under cursor
    <C-f>   <=>   File name
    <C-p>   <=>   Path under cursor

All of that also work inside the ReadLine() promt (the function that this
plugin uses). For example, take the following code where we want to substitute
g:variable by s:script_local_variable:
>
    let g:variable=10

    let g:variable+=5

    echo 'The variable is ' g:variable

With the cursor just over the "v" of the first "g:variable", we can type:

    <Leader>s4jg:<C-r><C-w><Enter>s:script_local_<C-r><C-w><Enter>

Here <C-r><C-w> is used twice to insert the word "variable". You could also
copy a text into a register {reg} and insert it inside the prompt as you
please.

All of this is mainly useful if we want want to use text like the word under
cursor but also further modify the pattern for some purpose.

Moving the position above text                          *extend-usage-move-pos*
---------------

The ReadLine() functions permits moving the buffer cursor position so that
you can insert objects from different positions. The functions that make this
possible are:

    | Action                        | Default mappings                     |
    +-------------------------------+--------------------------------------+
    | Move buffer position left     | <M-Left>, <M-h>                      |
    |                                                                      |
    |    Internal function: EXtend#input#MovePosLeft                       |
    +-------------------------------+--------------------------------------+
    | Move buffer position right    | <M-Right>, <M-l>                     |
    |                                                                      |
    |    Internal function: EXtend#input#MovePosRight                      |
    +-------------------------------+--------------------------------------+
    | Move buffer position up       | <M-Up>, <M-k>                        |
    |                                                                      |
    |    Internal function: EXtend#input#MovePosUp                         |
    +-------------------------------+--------------------------------------+
    | Move buffer position down     | <M-Down>, <M-j>                      |
    |                                                                      |
    |    Internal function: EXtend#input#MovePosDown                       |
    +-------------------------------+--------------------------------------+
    | Move buffer position to start | <M-a>, <M-A>                         |
    | of current                    |                                      |
    |                                                                      |
    |    Internal function: EXtend#input#MovePosToStart                    |
    +-------------------------------+--------------------------------------+
    | Move buffer position to end   | <End>, <C-e>                         |
    | of current line               |                                      |
    |                                                                      |
    |    Internal function: EXtend#input#MovePosToEnd                      |
    +-------------------------------+--------------------------------------+

**Note**: The mappings starting with Meta (Alt) may not work on all
terminal/guis for vim. If they don't work for you, see |extend-configuration|
for a way to create new associations of keys that work for you.

Consider the following example:

    background-image:
        linear-gradient(...), linear-gradient(...),
        linear-gradient(...), linear-gradient(...);

To change all aparitions of linear-gradient to radial-gradient, you could
position the cursor at the r of linear from any of the available and press:

    <Leader>sap<C-r><C-w>-<M-l><M-l><C-r><C-w><Enter>radial-<C-r><C-w><Enter>

As the "-" is not generally considered part of a word (depending on
'iskeyword'), the first <C-r><C-w> only insert the word "linear". After that a
"-" is manually typed and later <M-l><M-l> is used to move the text position
two characters right just to reach the start of "gradient", which is now
inserted.

Let's make a harder example. Consider the following code:

    function_behavior = 1
    my_function('argument 1', 1231)

    function_behavior = 2
    my_function('arg2', 0x255)

    function_behavior = 3
    my_function('parameter 3', -1)

Imagine that the function "my_function" used to depend upon
the "function_behavior" global variable to work. Later the function is made to
receive a third parameter with the function behavior instead of depending on
that global.
We want to update all function calls based on that. Every time
the function was called, the variable function_behavior was set in the
previous line to a single number flag.

Basically the thing we want to do is change from this:

    function_behavior = <behavior>
    my_function(<first_args>)

To this:

    my_function(<first_args>, <behavior>)

To do this, position over the f in any of the "function_behavior" occurrences
and type:

    <Leader>se<C-r><C-w> = \(.\)\n\s*<M-j><C-r><C-w>(\(.*\))<Enter>
    <C-r><C-w>(\2, \1)<Enter>

For more uses of regular expressions see |pattern-atoms|

Changing the matching mode                         *extend-usage-matching-mode*
---------------

The text inside "[]" at the start of the input prompts of this plugin shows
all status flags that interfere in matching of patterns like follows:

    [ s | NCW | \m | \c | ^ ]
           ^    ^    ^
           |    |    |
           |    |    +-- Sensitiveness
           |    |
           |    +-- Magicness
           |
           +-- Complete words / Non complete words

The following keys can be used to modify these flags:

| Action                                                    | Default mapping |
+-----------------------------------------------------------+-----------------+
| Toggle match mode between "[C]omplete words" (\<CW\>) and | <C-c>           |
| "non-[C]omplete words" (NCW). The initial value is NCW    |                 |
| for the normal, visual and entire operators and \<CW> for |                 |
| the word operations.                                      |                 |
|                                                                             |
|    Internal function: EXtend#ToggleCompleteWords                            |
+-----------------------------------------------------------+-----------------+
| Rotate [M]agicness of the match. Possible values are:     | <C-g>           |
|  - Very No Magic (\V)                                     |                 |
|  - No Magic (\M)                                          |                 |
|  - Magic (\m)                                             |                 |
|  - Very Magic (\v)                                        |                 |
| The initial value is \M is 'magic' is set and \m otherwise|                 |
|                                                                             |
|    Internal function: EXtend#RotateMagicMode                                |
+-----------------------------------------------------------+-----------------+
| Toggle ebtween "Case [S]ensitive" (\C) and "Case          | <C-s>           |
| "in[s]ensitive" (\c). The initial value is \c if          |                 |
| 'ignorecase' is not set and \C if set.                    |                 |
|                                                                             |
|    Internal function: EXtend#ToggleSensitiveness                            |
+-----------------------------------------------------------+-----------------+

If the user manually type any of these flags inside the pattern, generally the
value from the plugin is overwrote, but nothing is really guaranteed.

Editing in the prompt line                           *extend-usage-prompt-edit*
---------------

The prompt line supports the following actions:

    | Action                        | Default mappings                     |
    +-------------------------------+--------------------------------------+
    | Move input cursor left        | <Left>, <C-b>                        |
    |                                                                      |
    |    Internal function: EXtend#input#MoveCursorLeft                    |
    +-------------------------------+--------------------------------------+
    | Move input cursor right       | <Right>, <C-f>                       |
    |                                                                      |
    |    Internal function: EXtend#input#MoveCursorRight                   |
    +-------------------------------+--------------------------------------+
    | Move input cursor a WORD left | <C-Left>, <M-b>                      |
    |                                                                      |
    |    Internal function: EXtend#input#MoveCursorWORDLeft                |
    +-------------------------------+--------------------------------------+
    | Move input cursor a WORD right| <C-Right>, <M-f>                     |
    |                                                                      |
    |    Internal function: EXtend#input#MoveCursorWORDRight               |
    +-------------------------------+--------------------------------------+
    | Move input cursor to start of | <Home>, <C-a>                        |
    |                                                                      |
    |    Internal function: EXtend#input#MoveCursorToStart                 |
    +-------------------------------+--------------------------------------+
    | Move input cursor to end      | <End>, <C-e>                         |
    |                                                                      |
    |    Internal function: EXtend#input#MoveCursorToEnd                   |
    +-------------------------------+--------------------------------------+
    | Delete char backwards         | <BS>, <C-h>                          |
    |                                                                      |
    |    Internal function: EXtend#input#DeleteChar                        |
    +-------------------------------+--------------------------------------+
    | Delete WORD backwards         | <C-BS>, <C-w>                        |
    |                                                                      |
    |    Internal function: EXtend#input#DeleteWord                        |
    +-------------------------------+--------------------------------------+
    | Delete to start               | <C-u>                                |
    |                                                                      |
    |    Internal function: EXtend#input#DeleteToStart                     |
    +-------------------------------+--------------------------------------+
    | Delete to end                 | <C-k>                                |
    |                                                                      |
    |    Internal function: EXtend#input#DeleteToEnd                       |
    +-------------------------------+--------------------------------------+
    | Insert register/object        | <C-r>                                |
    |                                                                      |
    |    Internal function: EXtend#input#CompleteRegister                  |
    +-------------------------------+--------------------------------------+
    | Finish input                  | <Enter>, <C-m>, <NL>, <C-j>, <C-c>   |
    |                                                                      |
    |    Internal function: EXtend#input#ExitLoop                          |
    +-------------------------------+--------------------------------------+
    | Cancel operations             | <Esc>, <C-[>                         |
    |                                                                      |
    |    Internal function: EXtend#CancelOperation                         |
    +-------------------------------+--------------------------------------+

Modifying the range dynamically                    *extend-usage-modify-range*
---------------

If the initial range applied to an operator wasn't accurate there is usually
no need to cancel and retry everything. The prompts of this plugin have a couple
of commands to modify the range of the operation at the same time of the input
writing:

    <C-Up>   or <C-p>   <=>   Move the selected end upwards
    <C-Down> or <C-n>   <=>   Move the selected end downwards
                <C-o>   <=>   Toggle the selected end between start and end of
                              range

      | Action                             | Default mappings            |
      +------------------------------------+-----------------------------+
      | Move the selected end up           | <C-Up>, <C-p>               |
      |                                                                  |
      |    Internal function: EXtend#MoveSelectionUp                     |
      +------------------------------------+-----------------------------+
      | Move the selected end down         | <Right>, <C-f>              |
      |                                                                  |
      |    Internal function: EXtend#MoveSelectionDown                   |
      +------------------------------------+-----------------------------+
      | Toggle the selected end between    | <C-Left>, <M-b>             |
      | start and end of range             |                             |
      |                                                                  |
      |    Internal function: EXtend#ToggleSelectionEnd                  |
      +-------------------------------+----------------------------------+

Just like vim built-in visual selections, the range of this plugin can only be
moved from one side (above or below) called the "selected end". To see which
end is currently selected you can see the fourth section in the status flags
from the prompt:

    [ s | NCM | \C | \v | ^ ]
                        +-+-+
                          |
                          +--- Indicates the selected end. If the symbol is
                               "^" the selected end is the first and if the
                               symbol is "v" the selected end is the last line
                               of range.

Moving the window viewport                      *extend-usage-modify-viewport*
---------------

With the ability to modify the range and move the position over text often
arises the need to move the viewport and be able to see beyond.

The following actions move the viewport while in ReadLine() prompt:

      | Action                             | Default mappings            |
      +------------------------------------+-----------------------------+
      | Move the viewport up               | <M-u>                       |
      |                                                                  |
      |    Internal function: EXtend#input#MoveViewportUp                |
      +------------------------------------+-----------------------------+
      | Move the viewport down             | <M-d>                       |
      |                                                                  |
      |    Internal function: EXtend#input#MoveViewportDown              |
      +------------------------------------+-----------------------------+
      | Move the viewport half page up     | <C-Left>, <M-b>             |
      |                                                                  |
      |    Internal function: EXtend#input#MoveViewportHalfPageUp        |
      +-------------------------------+----------------------------------+
      | Move the viewport half page down   | <C-Left>, <M-b>             |
      |                                                                  |
      |    Internal function: EXtend#input#MoveViewportHalfPageDown      |
      +-------------------------------+----------------------------------+
      | Move the viewport full page up     | <C-Left>, <M-b>             |
      |                                                                  |
      |    Internal function: EXtend#input#MoveViewportPageUp            |
      +-------------------------------+----------------------------------+
      | Move the viewport full page down   | <C-Left>, <M-b>             |
      |                                                                  |
      |    Internal function: EXtend#input#MoveViewportPageDown          |
      +-------------------------------+----------------------------------+

==============================================================================
2  Mappings                                                  *extend-mappings*

The following <Plug> mappings can be used to define your own operators. To
disable the default (non-plug) mappings for these see |extend-configuration|

<Plug>SubstituteNormal

    Operator "Substitute from empty pattern" to be applied from normal mode.
    Starts as a "no complete words" operation.
    Default sequence: <Leader>s  (nmap)

<Plug>SubstituteVisual

    Same as previous operator, to be applied from visual mode.
    Default sequence: <Leader>ss (xmap)

<Plug>SubstituteOneLine

    Same as previous but linewise.
    Default sequence: <Leader>ss (nmap)

<Plug>SubstituteWordNormal

    Operator "Substitute current word" to be applied from normal mode.
    Starts as a "complete words" operation.
    Default sequence: <Leader>sw (nmap)

<Plug>SubstituteWordVisual

    Same as previous operator, to be applied from visual mode.
    Default sequence: <Leader>sw (xmap)

<Plug>SubstituteWordOneLine

    Same as previous but linewise.
    Default sequence: <Leader>sww (nmap)

<Plug>SubstituteFromSelection

    Takes the visual selection as the pattern and starts operation pending mode
    to take the range.
    Default sequence: <Leader>sx (xmap)

<Plug>SubstituteFromSelectionEntire

    Takes the visual selection as the pattern and substitutes in whole buffer.
    Default sequence: <Leader>se (nmap)

<Plug>GlobalNormal

    Operator "apply global from an empty pattern" to be applied from normal
    mode. Starts as a "no complete words" operation.
    Default sequence: <Leader>g  (nmap)

<Plug>GlobalVisual

    Same as previous operator, to be applied from visual mode.
    Default sequence: <Leader>gg (xmap)

<Plug>GlobalOneLine

    Same as previous but linewise.
    Default sequence: <Leader>gg (nmap)

<Plug>GlobalWordNormal

    Operator "Apply global to current word" to be applied from normal mode.
    Starts as a "complete words" operation.
    Default sequence: <Leader>gw (nmap)

<Plug>GlobalWordVisual

    Same as previous operator, to be applied from visual mode.
    Default sequence: <Leader>gw (xmap)

<Plug>GlobalWordOneLine

    Same as previous but linewise.
    Default sequence: <Leader>gww (nmap)

<Plug>GlobalFromSelection

    Takes the visual selection as the pattern and starts operation pending mode
    to take the range.
    Default sequence: <Leader>gx (xmap)

<Plug>GlobalFromSelectionEntire

    Takes the visual selection as the pattern and applies global in whole
    buffer.
    Default sequence: <Leader>ge (nmap)

<Plug>VGlobalNormal

    Operator "apply vglobal from empty pattern" to be applied from normal mode.
    Starts as a "no complete words" operation.
    Default sequence: <Leader>v  (nmap)

<Plug>VGlobalVisual

    Same as previous operator, to be applied from visual mode.
    Default sequence: <Leader>vv (xmap)

<Plug>VGlobalOneLine

    Same as previous but linewise.
    Default sequence: <Leader>vv (nmap)

<Plug>VGlobalWordNormal

    Operator "VGlobal to current word" to be applied from normal mode.
    Starts as a "complete words" operation.
    Default sequence: <Leader>vw (nmap)

<Plug>VGlobalWordVisual

    Same as previous operator, to be applied from visual mode.
    Default sequence: <Leader>vw (xmap)

<Plug>VGlobalWordOneLine

    Same as previous but linewise.
    Default sequence: <Leader>vww (nmap)

<Plug>VGlobalFromSelection

    Takes the visual selection as the pattern and starts operation pending mode
    to take the range.
    Default sequence: <Leader>vx (xmap)

<Plug>VGlobalFromSelectionEntire

    Takes the visual selection as the pattern and applies vglobal in whole
    buffer.
    Default sequence: <Leader>ve (nmap)

==============================================================================
3  Configuration                                        *extend-configuration*

Highlight colors                                 *extend-configuration-colors*
---------------
These variables are string and control the way that things are highlighted in
this plugin.

    g:EXtend_highlight_position
        Highlight group for the cursor from the input line
        Default: CursorColumn

    g:EXtend_highlight_position
        Highlight group of the on buffer emulated cursor
        Default: WildMenu

    g:EXtend_highlight_range
        Highlight group for the operation range
        Default: Visual

    g:EXtend_highlight_pattern
        Highlight group for the words that match the pattern
        Default: IncSearch

You can create your own Highlight group or use any of the preexisting ones.
See |highlight-groups|

Enabling and disabling operators              *extend-configuration-operators*
---------------

The variable g:EXtend_default_mappings controls if default mappings are set to
use the operators. It can be both an integer (boolean) variable or a dictionary.

An integer can be used to either enable (with a true value) or disable (with a
false value) all the operators.
The default value is the integer 1 so all the operators are mapped. To disable
all of them you can put the following in your configuration file:

    let g:EXtend_default_mappings = 0

When a dictionary is used, it can have the following keys each associated with a
integer (boolean) value to enable/disable by parts:

    - substitute
    - global
    - vglobal
    - pattern_empty
    - pattern_word
    - pattern_selection


"substitute", "global" and "vglobal" values can enable/disable the mappings for
those commands. The "pattern_empty" operators are those that ask for both
pattern and replacement/command, "pattern_word" operators are those
that take word under cursor as pattern and "pattern_selection" are the ones that
take visual selection as pattern.

All the values associated to these keys also default to 1 if not present.

For example, if you want mappins only for
substitute and don't need the operations on words (they can easily be emulated)
you can define:

    let g:EXtend_default_mappings = {
    \   'pat_word'  : 0,
    \   'global'    : 0,
    \   'vglobal'   : 0
    \}

g:sub_op_key_handlers

    Dictionary with keycode-funcref associations that define the behavior of
    the ReadLine function.

**Note**: Some keys as <Enter> with <C-m>, <NL> with <C-j>, <Tab> with <C-I>
and <Esc> with <C-[> have the same intermal representation. Consider that if
you want to modify the commands: One new map can modify several.

Readline() key handlers                        *extend-configuration-readline*
---------------

==============================================================================
4  Bug reports and contributing                            *extend-bugreports*

Bug reports and feature request are done through the issues section in github.
Pull request are welcome, especially those that correct the poor-skilled
writing of a non English native speaker as me.

The ReadLine() utility has a default set of commands similar to those of bash
but they can be completely configured. If you make your own layout of commands
(maybe similar to one from another application) and it works well you can
share and I could add to the plugin as an optional key-layout to choose.

It would be awesome if you ported this plugin to some other
editor/vim-emulation-system like the emacs evil mode. If you do this, don't
doubt into contacting me so I can give mention to your plugin.

==============================================================================
5  Changelog                                                *extend-changelog*

    2018-09-01: v0.2
        - New banner and complete documentation
        - More options to configure
        - Correct handling of utf-8 by ReadLine()
        - Many functions made into autoloaded public as part of an "API" to
          enable customization
        - Workaround to make meta keys work in vim. Still looking troublesome
          in some cases so its better to use neovim
        - The operations that default as WORD has ben deleted as mostly
          unnecessary and because they can be easily emulated with the normal
          operators.
        - Now the commands :global and :vglobal can also be used. They come
          with their corresponding operators for empty/word. Ability to rotate
          between these commands via keystrokes
        - New "scope" flag that lets you operate on:
          * Specific lines range
          * All current buffer
          * Argument list
          * Window list
          * Buffer
        - The new scope flag also has new operators "entire" that defaults the
          scope to "All current buffer". The rest can be reach by cycling
          through a specific keystroke.
        - New variables to configure the highlight of elements

    2018-08-30: v0.1
        - First release
        - Substitute empty/word/WORD and selection operators covered
        - Repeat operator's last letter to use operator in single line
        - Plugs and default mappings to the operators
        - Only one configuration variable. It has the purpose of disabling
          default mappings
        - Highlight substitution zone and matching words
        - ReadChar function that handles interruptions
        - Emulation of input() called ReadLine() with some added capabilities:
          * Highlight the cursor position with "CursorColumn" group
          * Custom handling of keystrokes
          * A single extra event (for now) called "afterOperation"
        - Some basic edition functions covered in input.vim for Readline:
          * Move cursor left and right by one char
          * Move cursor left and right by one WORD
          * Move cursor to start and end of input
          * Deleting by chars
          * Deleting by WORDs
          * Deleting from position to start of and end input
          * Insert registers or words through <C-r>
        - Some mon-editing functions covered in input.vim for ReadLine:
          * Move viewport up and down by line, half page and complete page
          * Move position over text right/left/up/down
          * Move position over text to start/end of its line
        - SubstituteInRange function with most of the logic from the plugin,
          which can manage:
          * Substitutions on given ranges
          * Automatic "/" and "\" escaping
          * From very magic to very no magic patterns
          * Case sensitive/insensitive patterns
        - SubstituteInRange also extends ReadLine by providing some extra
          key handlers to perform some substitution-specific things like:
          * Highlight of the zone affected by the substitute and the matches
            of the substitute pattern
          * Change pattern matching type
          * Prompt-update after change of pattern matching type
          * Cancel substitution on <Esc>
          * Move range of substitution dinamically and update Highlight
          * Move viewport so the moving the range makes sense
        - Two Configuration variables
          * g:sub_op_default_mappings: boolean to disable default mappings
          * g:sub_op_key_handlers: dictionary with mappings as keys and
            funrefs as values to customize the behavior of keys while reading
            with ReadLine.


==============================================================================
vim:tw=78:et:ft=help:spell:spl=en
