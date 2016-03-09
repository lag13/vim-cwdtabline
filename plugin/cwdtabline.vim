" cwdtabline.vim - The cwd of each tab's active window in the tabline
" Author: Lucas Groenendaal <groenendaal92@gmail.com>

if exists("g:loaded_cwdtabline") || &cp || v:version < 700
    finish
endif
let g:loaded_cwdtabline = 1

augroup cwdtabline
    autocmd!
    autocmd TabEnter * call s:update_tabline()
    autocmd WinEnter * call s:update_tabline()
augroup END

" TODO: Get this to work for commands run in the command line window

" TODO: This mapping will trash any existing mapping of <CR> in the command
" line. See if we can keep any old mapping and still update the tabline.
cnoremap <CR> <CR>:call <SID>update_tabline()<CR>

function! s:update_tabline()
    if tabpagenr('$') <= 1
        return
    endif
    let cur_tab = tabpagenr()
    let tabs = []
    for i in range(1, tabpagenr('$'))
        noautocmd execute "tabnext " . i
        let cwd = getcwd()
        let tab = { 'label': ' ' . fnamemodify(cwd, ':t') . ' ' }
        let tab.highlight = cur_tab == i ? '%#TabLineSel#' : '%#TabLine#'
        let tabs += [tab]
    endfor
    noautocmd execute "tabnext " . cur_tab
    let &tabline = join(map(tabs,'printf("%s%s", v:val.highlight, v:val.label)'), '') . '%#TabLineFill#'
endfunction
