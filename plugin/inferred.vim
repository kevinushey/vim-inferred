" Location:     plugin/inferred.vim
" Author:       Kevin Ushey <http://kevinushey.github.io>
" Version:      0.1
" License:      Same as Vim itself.  See :help license

if exists('g:loaded_inferred') || &cp
    finish
endif
let g:loaded_inferred = 1

function! s:InsideStringOrComment(row) abort

    let syntax = synIDattr(synIDtrans(synID(a:row, 1, 1)), 'name')
    
    if stridx(syntax, 'Comment') != -1
        return 1
    endif

    if stridx(syntax, 'String') != -1
        return 1
    endif

    return 0

endfunction

function! s:InferredTabs() abort
    execute 'setlocal noexpandtab'
endfunction

function! s:InferredSpaces(indent) abort
    execute 'setlocal expandtab'
    execute 'setlocal tabstop=' . a:indent
    execute 'setlocal shiftwidth=' . a:indent
endfunction

function! s:Inferred() abort

    if &buftype ==# 'help' || &buftype ==# 'terminal' || &buftype ==# 'quickfix'
        return
    endif

    let scores = map(range(128), 0)

    let row = 1
    let sz = max([line('$'), 200])
    while row <= sz

        if (s:InsideStringOrComment(row))
            let row += 1
            continue
        endif

        let indent = matchstr(getline(row), '\v^\s*')

        if match(indent, '\t') != -1
            return s:InferredTabs()
        elseif strlen(indent) > 0
            let scores[strlen(indent)] += 1
        endif

        let row += 1

    endwhile

    let score  = 1
    let indent = &tabstop

    for candidate in [2, 3, 4]

        let computed = candidate
        for value in range(candidate, 4, candidate)
            let computed += scores[value]
        endfor

        if computed >= score
            let score = computed
            let indent = candidate
        endif

        let candidate += 1

    endfor

    return s:InferredSpaces(indent)

endfunction

augroup VimInferred
    autocmd!
    autocmd BufEnter * call <SID>Inferred()
augroup END


