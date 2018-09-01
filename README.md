
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
that great power comes a lot of troube. The dealing with regular expressions,
with search of complete words or free text, the case-sensitiveness, magicness,
line ranges that we can't visualize and most importantly, the fact that these
commands can't be applied as if they were operators are just some of the
points that make these ex commands so akward to use in the common workflow.

In response of all that concerns vomes EXtend.vim, that provides the
functionality of those venerable ex commands packed into easy to use
operators, a highlight system that shows the range of operation and the text
to be substituted in the fly to provide a great visual feedback and an
steroids-provided input line with two virtual cursors: one for editing the
text you type as in any other input line, and a second one  that moves over
the text of the buffer and lets you pick up words from it and insert them on
the input line.

Take all that and add the ability customize every color, keystroke and mapping
to your own needs and what you got a must-have plugin to add to your vim
toolchain.

vim:tw=78:et:spell:spl=en
