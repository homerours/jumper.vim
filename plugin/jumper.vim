if exists("g:loaded_jumper_vim")
  finish
endif
let g:loaded_jumper_vim = 1

" Update database whenever a new file is opened
function s:JumperUpdate(database_file, filename, weight)
    if stridx(a:filename, '/.git/') == -1
        silent execute '!jumper -f ' .. a:database_file .. ' -w ' .. a:weight .. ' -a ' .. a:filename
    endif
endfunction

" Update database whenever the file changes
function s:JumperBufWrite()
    if getbufinfo('%')[0].changed
        call s:JumperUpdate($__JUMPER_FILES, expand('%:p'), 0.3)
    endif
endfunction

autocmd BufReadPre,BufNewFile *  call s:JumperUpdate($__JUMPER_FILES, expand('%:p'), 1) 
autocmd BufWritePre *  call s:JumperBufWrite() 
autocmd DirChanged *  call s:JumperUpdate($__JUMPER_FOLDERS, getcwd(), 1) 

" :Z and :Zf commands
function! FoldersCompletion(ArgLead, CmdLine, CursorPos)
    return systemlist("jumper -f $__JUMPER_FOLDERS -n 12 " .. a:ArgLead)
endfunction
function! FilesCompletion(ArgLead, CmdLine, CursorPos)
    return systemlist("jumper -f $__JUMPER_FILES -n 12 " .. a:ArgLead)
endfunction

command! -complete=customlist,FoldersCompletion -nargs=+ Z :cd `jumper -f $__JUMPER_FOLDERS -n 1 '<args>'`
command! -complete=customlist,FilesCompletion -nargs=+ Zf :edit `jumper -f $__JUMPER_FILES -n 1 '<args>'`

" Fuzzy-finders, FZF required
let s:jumper_files = 'jumper -f $__JUMPER_FILES -cHo -n 150'
let s:jumper_folders = 'jumper -f $__JUMPER_FOLDERS -cHo -n 150'

command! JumperFiles call fzf#run(fzf#wrap({'source': s:jumper_files, 'options': '--ansi --disabled --keep-right --bind "change:reload:sleep 0.05; ' .. s:jumper_files .. ' {q} || true"'}))
command! JumperFolders call fzf#run(fzf#wrap({'source': s:jumper_folders, 'options': '--ansi --disabled --keep-right --bind "change:reload:sleep 0.05; ' .. s:jumper_folders .. ' {q} || true"', 'sink': 'FZF'}))

function s:open_at_line(name)
    let sp = split(a:name,':')
    execute "edit +".sp[1]." ".sp[0]
endfunction

let s:jumper_rg = 'jumper -f $__JUMPER_FILES \"\" | xargs rg -i --column --line-number --color=always'
command! JumperFindInFiles call fzf#run(fzf#wrap({'options': '--ansi --disabled --query "" --bind "start:reload:sleep 0.1; '.. s:jumper_rg .. ' {q} || true" --bind "change:reload:sleep 0.1; ' .. s:jumper_rg .. ' {q} || true" --delimiter : --preview "bat --color=always {1} --highlight-line {2}" --preview-window "up,60%,border-bottom,+{2}+3/3,~3"', 'sink': function('s:open_at_line')}))

nnoremap <C-u> :JumperFiles<CR>
nnoremap <C-y> :JumperFolders<CR>
nnoremap <leader>fu :JumperFindInFiles<CR>
