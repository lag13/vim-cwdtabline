" cwdtabline.vim - The cwd of each tab's active window in the tabline
" Author: Lucas Groenendaal <groenendaal92@gmail.com>

if exists("g:loaded_cwdtabline") || &cp || v:version < 700
    finish
endif
let g:loaded_cwdtabline = 1

" So my autocommand in insert mode in the command line window takes effect
runtime! plugin/endwise.vim

augroup cwdtabline
    autocmd!
    autocmd TabEnter * call s:update_tabline()
    autocmd WinEnter * call s:update_tabline()
    autocmd CmdwinEnter * nnoremap <buffer> <CR> <C-c><C-\>e<SID>update_tabline_after_command()<CR><CR>
    autocmd CmdwinEnter * inoremap <buffer> <CR> <C-c><C-\>e<SID>update_tabline_after_command()<CR><CR>
augroup END

cnoremap <CR> <C-\>e<SID>update_tabline_after_command()<CR><CR>

function! s:update_tabline()
    call s:clean_history()
    if tabpagenr('$') <= 1
        return
    endif
    let cur_tab = tabpagenr()
    let tabs = []
    let prev_label = ""
    for t in range(1, tabpagenr('$'))
        execute "noautocmd tabnext " . t
        let [label, prev_label] = s:getlabel(getcwd(), prev_label)
        let tab = { 'label': ' ' . label . ' ' }
        let tab.highlight = cur_tab == t ? '%#TabLineSel#' : '%#TabLine#'
        let tabs += [tab]
    endfor
    execute "noautocmd tabnext " . cur_tab
    let &tabline = join(map(tabs,'printf("%s%s", v:val.highlight, v:val.label)'), '') . '%#TabLineFill#'
endfunction

function s:getlabel(cwd, prev_label)
    let last_label = a:prev_label
    if a:cwd ==# '/'
        let label = a:cwd
    else
        if fnamemodify(a:cwd, ':~') ==# '~/'
            let label = '~'
        else
            let label = fnamemodify(a:cwd, ':t')
        endif
    endif
    if label ==# last_label
        let last_label = label
        let label = '"'
    else
        let last_label = label
    endif
    return [label, last_label]
endfunction

" This function was taken from the help page on <SID>. What it does is grab
" the id number of the current script. I wouldn't need this function at all if
" I made the update_tabline function global.
function s:sid()
    return matchstr(expand('<sfile>'), '<SNR>\zs\d\+\ze_sid$')
endfun

" This string gets appended to the command line so that commands which should
" be updating the tabline (:lcd, :cd, :tabmove, etc...) do. The reason I don't
" try appending this string to every command is because we would lose any
" output that that command could have. If vim had a CmdFinished event or
" something similar then there would be no need for all this nonsense and I
" could just add another autocommd.
let s:call_update_tabline = " | call <SNR>" . s:sid() . "_update_tabline()"

function! s:update_tabline_after_command()
    let cmdline = getcmdline()
    if getcmdtype() ==# ':'
        let update_tabline_after = ['\<cd\>', '\<lcd\?\>', '\<tabm\(o\|ov\|ove\)\>']
        if match(cmdline, join(update_tabline_after, '\|')) != -1
            return cmdline . s:call_update_tabline
        endif
    endif
    return cmdline
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
