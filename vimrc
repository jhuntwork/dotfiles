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

let g:syntastic_shell_checkers = ['checkbashisms', 'sh', 'shellcheck']
let g:syntastic_sh_shellcheck_args = "-x"

highlight SyntasticError guibg=#2f0000

" autopep8
let g:autopep8_disable_show_diff=1


""" Below is from Google Style Guide

" Indent Python in the Google way.
setlocal indentexpr=GetGooglePythonIndent(v:lnum)

let s:maxoff = 50 " maximum number of lines to look backwards.

function GetGooglePythonIndent(lnum)

  " Indent inside parens.
  " Align with the open paren unless it is at the end of the line.
  " E.g.
  "   open_paren_not_at_EOL(100,
  "                         (200,
  "                          300),
  "                         400)
  "   open_paren_at_EOL(
  "       100, 200, 300, 400)
  call cursor(a:lnum, 1)
  let [par_line, par_col] = searchpairpos('(\|{\|\[', '', ')\|}\|\]', 'bW',
        \ "line('.') < " . (a:lnum - s:maxoff) . " ? dummy :"
        \ . " synIDattr(synID(line('.'), col('.'), 1), 'name')"
        \ . " =~ '\\(Comment\\|String\\)$'")
  if par_line > 0
    call cursor(par_line, 1)
    if par_col != col("$") - 1
      return par_col
    endif
  endif

  " Delegate the rest to the original function.
  return GetPythonIndent(a:lnum)

endfunction

let pyindent_nested_paren="&sw*2"
let pyindent_open_paren="&sw*2"

set colorcolumn=80
highlight ColorColumn ctermbg=8
