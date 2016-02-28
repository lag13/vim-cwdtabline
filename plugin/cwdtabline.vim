" cwdtabline.vim - The cwd of each tab's active window in the tabline
" Author: Lucas Groenendaal <groenendaal92@gmail.com>

if exists("g:loaded_cwdtabline") || &cp || v:version < 700
    finish
endif
let g:loaded_cwdtabline = 1

augroup cwdtabline
    autocmd!
    autocmd TabEnter * call s:update_tabline()
    autocmd BufLeave * call s:update_tabline()
augroup END

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
        let tab.highlight = cur_tab == i ? 'TabLineSel' : 'TabLine'
        let tabs += [tab]
    endfor
    noautocmd execute "tabnext " . cur_tab
    let &tabline = '%1X' . join(map(tabs,'printf("%%#%s#%s", v:val.highlight, v:val.label)'), '') . '%#TabLineFill#'
endfunction
