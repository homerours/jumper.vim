" Update database whenever a new file is opened
function s:JumperUpdate(weight)
    let l:filename = expand('%:p')
    if stridx(l:filename, '/.git/') == -1
        silent execute '!jumper -f ${__JUMPER_FILES} -w' .. a:weight .. ' -a ' .. l:filename
    endif
endfunction

" Update database whenever the file changes
function s:JumperBufWrite()
    if getbufinfo('%')[0].changed
        call s:JumperUpdate(0.2)
    endif
endfunction

autocmd BufReadPre,BufNewFile *  call s:JumperUpdate(1) 
autocmd BufWritePre *  call s:JumperBufWrite() 

" Jump
command! -nargs=+ Z :cd `jumper -f ${__JUMPER_FOLDERS} -n 1 '<args>'`
command! -nargs=+ Zf :edit `jumper -f ${__JUMPER_FILES} -n 1 '<args>'`

" Fuzzy-finders, FZF required
let s:jumper_files = 'jumper -f ${__JUMPER_FILES} -c -n 150'
let s:jumper_folders = 'jumper -f ${__JUMPER_FOLDERS} -c -n 150'

command! JumperFiles call fzf#run(fzf#wrap({'source': s:jumper_files, 'options': '--ansi --disabled --keep-right --bind "change:reload:sleep 0.05; ' .. s:jumper_files .. ' {q} || true"'}))
command! JumperFolders call fzf#run(fzf#wrap({'source': s:jumper_folders, 'options': '--ansi --disabled --keep-right --bind "change:reload:sleep 0.05; ' .. s:jumper_folders .. ' {q} || true"', 'sink': 'FZF'}))

function s:open_at_line(name)
    let sp = split(a:name,':')
    execute "edit +".sp[1]." ".sp[0]
endfunction

let s:jumper_rg = 'jumper -f ${__JUMPER_FILES} \"\" | xargs rg -i --column --line-number --color=always'
command! JumperFu call fzf#run(fzf#wrap({'options': '--ansi --disabled --query "" --bind "start:reload:sleep 0.1; '.. s:jumper_rg .. ' {q} || true" --bind "change:reload:sleep 0.1; ' .. s:jumper_rg .. ' {q} || true" --delimiter : --preview "bat --color=always {1} --highlight-line {2}" --preview-window "up,60%,border-bottom,+{2}+3/3,~3"', 'sink': function('s:open_at_line')}))

nnoremap <C-u> :JumperFiles<CR>
nnoremap <C-y> :JumperFolders<CR>
nnoremap <leader>fu :JumperFu<CR>
