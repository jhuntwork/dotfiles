" misc / basic
set ruler
set backspace=2
set nocompatible
set encoding=utf-8

" colors / schemes
syntax on
colorscheme railscasts
set t_Co=256

" indenting
set smartindent
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab
autocmd Filetype c setlocal ts=2 sts=2 sw=2

" SEARCH highlight
set incsearch
set hlsearch

" Cursor highlight
set cursorline
"set cursorcolumn

" Show hidden chars
"set invlist

" Set up puppet manifest and spec options
au BufRead,BufNewFile *.pp
  \ set filetype=puppet
au BufRead,BufNewFile *_spec.rb
  \ nmap <F8> :!rspec --color %<CR>

" Enable indentation matching for =>'s
filetype plugin indent on

" Syntax checking
execute pathogen#infect()
let g:syntastic_python_checkers = ['flake8']
let g:syntastic_check_on_open = 1
let g:syntastic_echo_current_error = 1
let g:syntastic_python_flake8_args = "--max-line-length=80"
highlight SyntasticError guibg=#2f0000

" autopep8
let g:autopep8_disable_show_diff=1
