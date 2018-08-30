*sub-op.txt* The substitute command evolves into an operator
                                __    _        __          ~
                               / /   | |      / /          ~
                      _ ___   / /   _| |__   / /__  _ __   ~
                     (_/ __| / / | | | '_ \ / / _ \| '_ \  ~
                      _\__ \/ /| |_| | |_) / / (_) | |_) | ~
                     (_)___/_/  \__,_|_.__/_/ \___/| .__/  ~
                                                   | |     ~
                                                   |_|     ~

Version: 1.0
Author: Saúl Axel <saulaxel.50@gmail.com>

==============================================================================
CONTENTS                                             *sub-op-contents*

    0. Introduction and installation .......... |sub-op-intro|
    1. Usage .................................. |sub-op-usage|
    1.1 Operators: ............................ |sub-op-usage-operators|
    1.2 One liners: ........................... |sub-op-usage-one-liners|
    1.3 Insert objects and registers .......... |sub-op-usage-insert-reg|
    1.4 Moving the position above text ........ |sub-op-usage-move-pos|
    1.5 Changing the matching mode ............ |sub-op-usage-matching-mode|
    1.6 Editing in the prompt line ............ |sub-op-usage-prompt-edit|
    1.7 Modifying the range dynamically ....... |sub-op-usage-modify-range|
    2. Mappings ............................... |sub-op-mappings|
    3. Configuration .......................... |sub-op-configuration|
    4. Bug reports and contributing ........... |sub-op-bugreports|
    5. Changelog .............................. |sub-op-changelog|

==============================================================================
0  Introduction                                                 *sub-op-intro*

Operators are like the verbs in the world of vim, and one of the greatest
thing about them is their ability to be composed into limitless actions if you
combine them with the lots of text objects and motions (both built-in and
provided by plugins).

Considering how great they are, don't you get pissed off an action only exists
as a command but not as a operator? The answer for me is yes, and one of the
worst cases for me is the :substitute command because of how useful it is and
how much it is used.

And the good news if you are like me are that we no longer have to endure this
situation. The solution: *sub-op-operator* .

This plugin provides several mappings for easy defining the range of a
substitution from nothing, and to automatically select for the pattern to
substitute to be some special text like the word under cursor. Adding the fact
that it also enables an easy switching of some pattern matching settings as
the magic level or the case-sensitiveness, this plugin can be wholy considered
as an easy to use :substitute.

==============================================================================
1  Usage                                                        *sub-op-usage*

Operators:                                            *sub-op-usage-operators*
---------------

The plugin provides several default mappings that can be disabled
(see *sub-op-Configuration* ). The mappings are divided into three
categories:
    - Substitute from empty pattern <=> <Leader>se
    - Substitute current word       <=> <Leader>sw
    - Substitute current WORD       <=> <Leader>sW

Note: The <Leader> key depends on g:mapleader. By default it is equal to "\"

For example, imagine you have the following code and you want to replace the
variable "i" and "j" from the second "for" with "line" and "col" respectively.
>
    for (var i = 0; i < N; i++) {
        println('Processing . . .')
    }
    for (var i = 0; i < LINES; i++) {
       |for (var j = 0; j < COLUMNS; j++) {
            print(mat[i][j], ' ');
        }
        println()
    }
    for (var j = 0; j < M; j++) {
        println('More processing . . .')
    }

Positioned just over the f of the inner for (marked with |), you can
type:

    <Leader>sea{i<C-c><Enter>line<Enter>

To substitute "i" by "line", and later:

    <Leader>sea{j<C-c><Enter>col<Enter>

To substitute "j" by "col".

Note: You can also manually select the lines you want to operate on and press
the operator later instead of using "a{".

Now let's explain these sequences by parts:

    * <Leader>se    : Operator "Substitute from empty".

    * a{            : Text object "around brackets", where the operator will
                      be applied.

    * i<C-c><Enter> : The pattern to substitute and <Enter> to terminate
                      input(). The <C-c> (Ctrl + c) keystroke turns on the
                      "full word matching" so that "i" is matched only when
                      not inside a word. Without <C-c>, the i in print/println
                      would also be substituted. <C-c> could actually be used
                      in any time between the { and the final <Enter>

    * line<Enter>   : The string to substitute "i" with (line). Input is
                      finished by <Enter>

Just after applying the operator on the object, a Highlight of full lines will
appear showing the zone in which the operator will take effect. A little later
when writing the pattern, the matching text inside the range will be also
highlighted in the fly.
Those highlights should be cleared when the substitution is finished or
canceled, but in cases where an error is encountered it is possible that the
highlights remain in the text. In case this happens, the highlights can be
manually cleared with the following code:

    :call substitute#matches#DeleteAllHighlights()<CR>

Looking good so far, but now we want to be more verbose change "line" by
"line_num" and "col" by "column_num". The previous method would swill be ok
but what if we make the plugin to insert words by us so we can reduce typing.
The operator <Leader>sw (Substitute current word) is similar to the
<Leader>se, but it automatically takes the word under the cursor as the
pattern to substitute and matches that pattern as "full word", so we now
position on the "print(mat[line][col])" instruction because that is where
nearest the words "line" and "col" are so we can move less. With the cursor
over "line" we type:

    <Leader>sw2a{line_num<Enter>

And later, over "col" we press:

    <Leader>sw2a{column_num<Enter>

Finally, the operator <Leader>sW works like <Leader>sw, but operates on big
WORDS and matches in mode "not full words" by default.

One liners:                                          *sub-op-usage-one-liners*
---------------

Just like vim built-in operators, all the operators of sub-op can be
automatically applied to just the current line by repeating one more time the
last letter of the mapping. The operators that work on single lines are then:

    <Leader>see  <=>  Substitute (from empty) current line
    <Leader>sww  <=>  Substitute word under cursor in current line
    <Leader>sWW  <=>  Substitute WORD under cursor in current line

These commands can take a numeric prefix, in which case the range will be
{count} lines from the line where the command was applied.

Insert objects and registers                         *sub-op-usage-insert-reg*
---------------

We already know how to substitute the word under the cursor, but, what if we
don't want a word to be the patter but only a part of the pattern. We can't
achieve that using <Leader>sw, because it don't even shows a prompt where we
could edit the pattern and instead goes straight to the prompt of the
replacement text.

For this kind of situations we can always use the insertion of text via
<C-r>. In insert and command mode, pressing <C-r>{reg} inserts the contents of
the register {reg} onto the line we are editing.
Additionally, in command mode we can also choose press the following
keystrokes instead of {reg} to insert an object below the cursor:

    <C-w>   <=>   Word under cursor
    <C-A>   <=>   WORD under cursor
    <C-f>   <=>   File name
    <C-p>   <=>   Path under cursor

All of that also work inside the prompts from any of the mappings of this
plugin. For example, take the following code where we want to substitute
g:variable by s:script_local_variable:
>
    let g:variable=10

    let g:variable+=5

    echo 'The variable is ' g:variable

With the cursor just over the "v" of the first "g:variable", we can type:

    <Leader>se4jg:<C-r><C-w><Enter>s:script_local_<C-r><C-w><Enter>

Here <C-r><C-w> is used twice to insert the word "variable". You could also
copy a text into a register {reg} and insert it inside the prompt as you
please.

Moving the position above text                          *sub-op-usage-move-pos*
---------------

It it also likely for the text around you to have several words that you want
to insert so this plugin has several commands to move the position over the
text so you can insert different object in the input line.

The commands for moving the text position are:

    <M-Left>  or <M-h>  <=> Move text position left
    <M-Right> or <M-l>  <=> Move text position right
    <M-Up>    or <M-k>  <=> Move text position up
    <M-Down>  or <M-j>  <=> Move text position down
    <M-a>     or <M-A>  <=> Move text position to start of its line
    <M-e>     or <M-E>  <=> Move text position to end of its line

Note: The mappings starging with Meta (Alt) may not work on all terminal/guis
for vim. If they don't dork for you, see |sub-op-configuration| for a way to
create new associations of keys that work for you.

Consider the following example:

    background-image:
        linear-gradient(...), linear-gradient(...),
        linear-gradient(...), linear-gradient(...);

To change all aparitions of linear-gradient to radial-gradient, you could
position the cursor at the r of linear from any of the available and press:

    <Leader>seap<C-r><C-w>-<M-l><M-l><C-r><C-w><Enter>radial-<C-r><C-w><Enter>

As the "-" is not generally considered part of a word (depending on
'iskeyword'), the first <C-r><C-w> only insert the word "linear". A "-" is
manually typed and later <M-l><M-l> is used to move the text position two
characters right just to reach the start of "gradient", which is now inserted.

Changint the matching mode                         *sub-op-usage-matching-mode*
---------------

The text inside "[]" at the start of the input prompts of this plugin shows
all status flags that interfere in matching of patterns like follows:

    [ NCW | \m | \c | ^ ]
       ^    ^    ^
       |    |    |
       |    |    +-- Sensitiveness
       |    |
       |    +-- Magicness
       |
       +-- Complete words / Non complete words

The following keys can be used to modify these flags:

    <C-c>   <=>   Toggle match between "[C]omplete words" (\<CW\>) and "non
                  [C]omplete words" (NCW). The initial value is NCW for
                  <Leader>ge and <Leader>gW and \<CW\> for <Leader>gw.

    <C-g>   <=>   Rotate [M]agicness of the match: Very No Magic (\V),
                  No Magic (\M), Magic (\m) and Very Magic (\v). The initial
                  value is \M if 'magic' is not set and \m if 'magic' is set.

    <C-s>   <=>   Toggle between "Case [S]ensitive" (\C) and
                  "Case in[s]ensitive" (\c). Initial value is that of
                  'ignorecase' translated to a flag.

If any of these flags also appear on the pattern, they generally overwrite the
value from the plugin, but nothing is really guaranteed.

Editing in the prompt line                           *sub-op-usage-prompt-edit*
---------------

The following are default mappings of the prompt line that can be used to edit
the patterns:

    <Left>    or <C-b>  <=>  Move input cursor left
    <Right>   or <C-f>  <=>  Move input cursor right
    <C-Left>  or <M-b>  <=>  Move input cursor one WORD left
    <C-Right> or <M-f>  <=>  Move input cursor one WORD right
    <Home>    or <C-a>  <=>  Move input cursor to start of text
    <End>     or <C-e>  <=>  Move input cursor to end of text
    <BS>      or <C-h>  <=>  Delete char backwards
    <C-BS>    or <C-w>  <=>  Delete WORD backwards
    <C-u>               <=>  Delete from cursor position to start of text
    <C-s>               <=>  Delete from cursor position to end of text
    <C-r>               <=>  Insert content of register or object below cursor

    <Enter> or <C-m> or <=>  Finish input and current text is returned
    <NL>    or <C-j> or
    <C-c>

    <Esc> or <C-[>      <=>  Finish input and cancel substitution

Note: The reason of the great quantity of mappings associated with finishing
input is that various keys are associated with the same internal
representation. Such is the case with <Enter> (<CR>) and <C-m>, <NL>/<C-j>
and <Esc>/<C-j>. If you remap one key from these pairs, the corresponding mate
will also be maped.

Modifying the range dinamically                    *sub-op-usage-modify-range*
---------------

If the initial range applied to an operator wasn't accurrate there is usually
no need to cancel and retry everything. There are a couple of commands that
can modify the range of the sustitution while writing the patterns:

    <C-Up>   or <C-p>   <=>   Move the selected end upwards
    <C-Down> or <C-n>   <=>   Move the selected end downwards
                <C-o>   <=>   Toggle the selected end between start and end of
                              range

Just like vim built-in visual selections, the range of this plugin can only be
moved from one side (above or below) called the "selected end". To see which
end is currently selected you can see the fourth section in the status flags
from the prompt:

    [ NCM | \C | \v | ^ ]
                    +-+-+
                      |
                      +--- Indicates the selected end. If the symbol is "^"
                           the selected end is the start and if the symbol is
                           "v" the selected end is the end.

==============================================================================
2  Mappings                                                  *sub-op-mappings*

The following <Plug> mappings can be used to define your own operators. To
disable the default (non-plug) mappings for these see |sub-op-configuration|

<Plug>SubstituteEmptyNormal

    Operator "Substitute from empty pattern" to be applied from normal mode.
    Starts as a "no complete words" operation.
    Default mapping: <Leader>se

<Plug>SubstituteEmptyVisual

    Same as previous operator, to be applied from visual mode.
    Default mapping: <Leader>se

<Plug>SubstituteEmptyOneLine

    Same as previos. Applied on single line by default.
    Default mapping: <Leader>see

<Plug>SubstituteWordNormal

    Operator "Substitute current word" to be applied from normal mode.
    Starts as a "complete words" operation.
    Default mapping: <Leader>sw

<Plug>SubstituteWordVisual

    Same as previous operator, to be applied from visual mode.
    Default mapping: <Leader>sw

<Plug>SubstituteWordOneLine

    Same as previos. Applied on single line by default.
    Default mapping: <Leader>sww

<Plug>SubstituteWORDNormal

    Operator "Substitute current WORD" to be applied from normal mode.
    Starts as a "no complete words" operation.
    Default mapping: <Leader>sW

<Plug>SubstituteWORDVisual

    Same as previous operator, to be applied from visual mode.
    Default mapping: <Leader>sW

<Plug>SubstituteWORDOneLine

    Same as previos. Applied on single line by default.
    Default mapping: <Leader>sWW

==============================================================================
3  Configuration                                        *sub-op-configuration*

g:sub_op_default_mappings

    Boolean variable that defines if default mappings are created.
    Default value: 1

g:sub_op_key_handlers

    Dictionary with keycode-funcref associations that define the behavior of
    the ReadLine function.

==============================================================================
4  Bug reports and contributing                            *sub-op-bugreports*

Bug reports and feature request are done through the issues section in github.
Pull request are welcome, especially those that correct the poor-skilled
writing of a non english native speaker as me.

==============================================================================
5  Changelog                                                *sub-op-changelog*

    2018-08-30: v1.0
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
