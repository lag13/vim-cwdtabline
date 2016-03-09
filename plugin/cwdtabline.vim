" cwdtabline.vim - The cwd of each tab's active window in the tabline
" Author: Lucas Groenendaal <groenendaal92@gmail.com>

if exists("g:loaded_cwdtabline") || &cp || v:version < 700
    finish
endif
let g:loaded_cwdtabline = 1

augroup cwdtabline
    autocmd!
    autocmd TabEnter * let t:cwdtabline = getcwd()
    autocmd WinEnter * let t:cwdtabline = getcwd()
    autocmd VimEnter * let t:cwdtabline = getcwd()
    autocmd TabEnter * call s:update_tabline()
    autocmd WinEnter * call s:update_tabline()
    autocmd CmdwinEnter * nnoremap <buffer> <CR> <C-c><C-\>e<SID>update_tabline_after_command()<CR><CR>
    " This mapping works except it seems like endwise is making a mapping in command
    " line mode insert as well which is throwing it off
    " autocmd CmdwinEnter * inoremap <buffer> <CR> <C-c><C-\>e<SID>update_tabline_after_command()<CR><CR>
augroup END

" TODO: The only case left where things don't work as expected is when issuing
" the :cd command. The :cd command can change the directory of multiple
" windows so I need to somehow update multiple t:cwdtabline variables. I feel
" like this might not be possible. It brings us back to the original issue I
" had where I cannot find out the cwd() of the active window of another tab
" without first going to that tab which I believe I cannot do because of the
" command line window. Or can we? <C-c> brings us out of the command line
" window so maybe tabnext's are free game?

cnoremap <CR> <C-\>e<SID>update_tabline_after_command()<CR><CR>

function! s:update_tabline()
    call s:clean_history()
    if tabpagenr('$') <= 1
        return
    endif
    let cur_tab = tabpagenr()
    let tabs = []
    for t in range(1, tabpagenr('$'))
        let cwd = gettabvar(t, 'cwdtabline')
        let tab = { 'label': ' ' . fnamemodify(cwd, ':t') . ' ' }
        let tab.highlight = cur_tab == t ? '%#TabLineSel#' : '%#TabLine#'
        let tabs += [tab]
    endfor
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
let s:call_update_tabline = " | let t:cwdtabline = getcwd() | call <SNR>" . s:sid() . "_update_tabline()"

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
