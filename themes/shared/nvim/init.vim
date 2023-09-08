" set listchars=tab:›\ ,trail:•,extends:#,nbsp:.

call plug#begin()
Plug 'preservim/nerdtree'
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
Plug 'jeffkreeftmeijer/vim-dim'
" Plug 'itchyny/lightline.vim'
call plug#end()

set background=light
set shell=/bin/zsh
set number
set noshowmode

" let g:lightline = {
" 	\ 'colorscheme': 'wombat',
" 	\ 'active': {
" 	\ 	'left': [ [ 'mode' ], [ 'filename' ] ],
" 	\	'right': [ [ 'lineinfo' ] ]
" 	\ }
" 	\ }

colors dim

highlight CursorLine term=bold cterm=bold gui=bold
highlight CursorLineNr term=bold cterm=bold gui=bold
set nocursorline

highlight Comment ctermfg=8 ctermbg=NONE
highlight LineNr ctermfg=0 ctermbg=NONE
highlight StatusLine ctermbg=NONE
highlight StatusLineNC ctermbg=NONE

" set expandtab
" set shiftwidth=3

set tabstop=4
set shiftwidth=4
set softtabstop=0 noexpandtab

nnoremap <silent> <Esc><Esc> :nohl<CR><Esc>

let g:go_fmt_command = "goimports"

" autocmd Filetype java setlocal shiftwidth=4

source ~/.config/nvim/statusline.vim
