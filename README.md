# vim-cwdtabline

Cwdtabline takes over the `tabline` and renders each tab as the last component of the cwd of the active window in that tab.

![cwdtabline](https://raw.githubusercontent.com/lag13/images/master/cwdtabline.png)

### Motivation

Tabs are a collection of windows. One use of tabs is to preserve a layout of
windows; a user can build up an efficient window layout for the task at hand
and if they need to work on something else they open a new tab and their
original layout will be preserved. Another use of tabs, which I find most
useful, is having one tab for each project I'm working on. Each tab's cwd can
sit in the root of the repository which makes working with files in that
repository much nicer. For this use case the default display of tabs is not
terribly helpful whatsoever:

![defaulttabline](https://raw.githubusercontent.com/lag13/images/master/defaulttabline.png)

Hence this plugin was born.

### TODOS

The things I had to do to get this plugin to work were pretty hacky (remapping
`<CR>` in command line mode, modifying command line history, etc...) so
suggestions for improvements would be much appreciated.

There is a plugin for displaying buffers on the tabline:
https://github.com/ap/vim-buftabline. I'd like to modify cwdtabline so these
two plugins can work nicely together. I'm picturing that when there is one tab
then buffers get displayed using buftabline but when there are 2 or more tabs
then cwdtabline takes over. My thought behind this is that for tiny personal
projects you might only be working on a couple files in a single repository
and navigating between files with something like `<C-n>` and `<C-p>` (assuming
they've been remapped to `:bnext` and `:bprev` respectively) might be faster.
But when multiple tabs get used you'd definitely want to see those tabs
instead of buffers.
