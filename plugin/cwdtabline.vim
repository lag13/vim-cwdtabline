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
    autocmd CmdwinEnter * nnoremap <buffer> <CR> <C-c><C-\>e<SID>update_tabline_after_command()<CR><CR>
    " This mapping works except for endwise which maps <CR> in the command
    " line window to its normal function:
    " autocmd CmdwinEnter * inoremap <buffer> <CR> <C-c><C-\>e<SID>update_tabline_after_command()<CR><CR>
augroup END

cnoremap <CR> <C-\>e<SID>update_tabline_after_command()<CR><CR>

function! s:update_tabline()
    call s:clean_history()
    if tabpagenr('$') <= 1
        return
    endif
    let cur_tab = tabpagenr()
    let tabs = []
    for t in range(1, tabpagenr('$'))
        execute "noautocmd tabnext " . t
        let cwd = getcwd()
        let tab = { 'label': ' ' . fnamemodify(cwd, ':t') . ' ' }
        let tab.highlight = cur_tab == t ? '%#TabLineSel#' : '%#TabLine#'
        let tabs += [tab]
    endfor
    execute "noautocmd tabnext " . cur_tab
    let &tabline = join(map(tabs,'printf("%s%s", v:val.highlight, v:val.label)'), '') . '%#TabLineFill#'
endfunction

" This function was taken from the help page on <SID>. What it does is grab
" the id number of the current script. I wouldn't need this function at all if
" I made the update_tabline function global.
function s:sid()
    return matchstr(expand('<sfile>'), '<SNR>\zs\d\+\ze_sid$')
endfun

" This string gets appended to the command line whenever we do an :lcd or :cd
" command. The reason I do this is so that whenever we run an :lcd or :cd
" command any changes in the working directory are immediately reflected in
" the tabline. If vim had a CmdFinished event or something similar then there
" would be no need for all this nonsense and I could just add another
" autocommd.
let s:call_update_tabline = " | call <SNR>" . s:sid() . "_update_tabline()"

function! s:update_tabline_after_command()
    let cmdline = getcmdline()
    if match(cmdline, '\<l\?cd\>') != -1
        return cmdline . s:call_update_tabline
    else
        return cmdline
    endif
endfunction

" Attempts to clean up the history by removing the s:call_update_tabline
" string from the latest command. That way our command history appears as we
" expect it to.
function s:clean_history()
    let last_cmd = histget('cmd', -1)
    let i = stridx(last_cmd, s:call_update_tabline, '')
    if i != -1
        call histdel('cmd', -1)
        call histadd('cmd', strpart(last_cmd, 0, i))
    endif
endfunction
