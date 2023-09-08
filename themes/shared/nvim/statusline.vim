hi StatuslineAccent ctermbg=7 ctermfg=NONE
hi StatuslineReadOnly ctermbg=15 ctermfg=1
hi StatuslineModified ctermbg=15 ctermfg=2
hi StatuslineLine ctermbg=15 ctermfg=NONE

" Syntax highlight group
function! SyntaxItem() abort
    let l:syntaxname = synIDattr(synID(line("."), col("."), 1), "name")

    if l:syntaxname != ""
        return printf(" %s ", l:syntaxname)
    else
        return ""
    endif
endfunction

" Ale linter status
" function! LinterStatus() abort
"     let l:counts = ale#statusline#Count(bufnr(''))
" 
"     if l:counts.total == 0
"         return ""
"     else
"         return printf(" [%d] ", l:counts.total)
"     endif
" endfunction

" Readonly flag check
function! ReadOnly() abort
    if &readonly || !&modifiable
        return " RO "
    else
        return ""
    endif
endfunction

" Modified flag check
function! Modified() abort
    if &modified
        return " + "
    else
        return ""
    endif
endfunction

" File type
function! FileType() abort
    if len(&filetype) == 0
        return "text"
    endif

    return tolower(&filetype)
endfunction

" NERDTree statusline
let NERDTreeStatusline="%1* nerdtree %5*"

" Always show statusline
set laststatus=2

" Format active statusline
function! ActiveStatusLine() abort
    " Reset statusline
    let l:statusline=""

    " Filename
    let l:statusline.="%#StatuslineAccent# %t "

    " Show if file is readonly
    let l:statusline.="%#StatuslineReadOnly#%{ReadOnly()}"

    " Show if file has been modified
    let l:statusline.="%#StatuslineModified#%{Modified()}"

    " Split right
    let l:statusline.="%5*%="

    " Line and column
    let l:statusline.="%#StatuslineLine# %l:%c %L "

    " File type
    let l:statusline.="%#StatuslineAccent# %{FileType()} "

    " Done
    return l:statusline
endfunction

" Format inactive statusline
function! InactiveStatusLine() abort
    " Reset statusline
    let l:statusline=""

    " Filename
    let l:statusline.="%3* %t "

    " Blank
    let l:statusline.="%5*"

    " Done
    return l:statusline
endfunction

" Set active statusline
function! SetActiveStatusLine() abort
    if &ft ==? 'nerdtree'
        return
    endif

    setlocal statusline=
    setlocal statusline+=%!ActiveStatusLine()
endfunction

" Set inactive statusline
function! SetInactiveStatusLine() abort
    if &ft ==? 'nerdtree'
        return
    endif

    setlocal statusline=
    setlocal statusline+=%!InactiveStatusLine()
endfunction

" Autocmd statusline
augroup statusline
    autocmd!
    autocmd WinEnter,BufEnter * call SetActiveStatusLine()
    autocmd WinLeave,BufLeave * call SetInactiveStatusLine()
augroup end
