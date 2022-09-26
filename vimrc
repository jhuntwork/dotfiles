" misc / basic
set ruler
set backspace=2
set nocompatible
set encoding=utf-8
"set number
"set textwidth=80
set mouse=

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
autocmd Filetype yaml setlocal ts=2 sts=2 sw=2
autocmd Filetype json setlocal ts=2 sts=2 sw=2
autocmd Filetype ruby setlocal ts=2 sts=2 sw=2
autocmd FileType go set noexpandtab

" SEARCH highlight
set incsearch
set hlsearch

" Cursor highlight
set cursorline
"set cursorcolumn

" Show hidden chars
"set invlist

au BufRead,BufNewFile *_spec.rb
  \ nmap <F8> :!rspec --color %<CR>

" Remove any trailing whitespace on save
autocmd BufWritePre * :%s/\s\+$//e

" Enable indentation matching for =>'s
filetype plugin indent on

" Syntax checking
execute pathogen#infect()
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_echo_current_error = 1

let g:syntastic_rst_checkers = ['syntastic-rst-sphinx']

let g:syntastic_python_checkers = ['flake8']
let g:syntastic_python_flake8_args = "--max-line-length=80"

let g:syntastic_shell_checkers = ['shellcheck']
let g:syntastic_sh_shellcheck_args = "-x"

highlight SyntasticError guibg=#2f0000

" autopep8
let g:autopep8_disable_show_diff=1

let g:vim_markdown_folding_disabled = 1

set colorcolumn=80
highlight ColorColumn ctermbg=8
let &colorcolumn="80,".join(range(120,999),",")

let g:utl_cfg_hdl_scm_http_system = "silent !open -a Firefox %u"
let g:utl_cfg_hdl_scm_http=g:utl_cfg_hdl_scm_http_system
