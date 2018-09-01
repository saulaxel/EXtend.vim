
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

Installation
------------------------------------------------------------------------------

Just add the plugin 'saulaxel/EXtend.vim' via your favorite plugin manager.
Example:

    Plug 'saulaxel/EXtend.vim'


Showcase
------------------------------------------------------------------------------

![Substitute word](./screenshots/substitute_word.gif)
![Substitute entire](./screenshots/substitute_entire.gif)
![Move buffer position](./screenshots/move_pos.gif)
![Move operation range](./screenshots/move_range.gif)
![Filter lines](./screenshots/filter.gif)
![Groups](./screenshots/complex_substitute.gif)
vim:tw=78:et:spell:spl=en
