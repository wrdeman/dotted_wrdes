set nocompatible
filetype off
":PluginInstall
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

set encoding=utf-8

Plugin 'tpope/vim-fugitive'
Plugin 'scrooloose/syntastic'

Plugin 'Valloric/YouCompleteMe'
Plugin 'vim-scripts/indentpython.vim'
Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'scrooloose/nerdtree'
Plugin 'tmhedberg/SimpylFold'

call vundle#end()
filetype plugin indent on
" git clone https://github.com/gmarik/vundle.git ~/.vim/bundle/vundle
" let Vundle manage Vundle
" " required!
" Bundle 'gmarik/vundle'
"
" " The bundles you install will be listed here
"
" filetype plugin indent on
"
" " The rest of your config follows here

augroup vimrc_autocmds
    autocmd!
    " highlight characters past column 120
    autocmd FileType python highlight Excess ctermbg=DarkGrey guibg=Black
    autocmd FileType python match Excess /\%120v.*/
    autocmd FileType python set nowrap
    augroup END

" ctrlp
let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP'

" nerdtree
map <F2> :NERDTreeToggle<CR>
let NERDTreeIgnore=['\.pyc$', '\~$'] "ignore files in NERDTree

"simply fold
" Enable folding
set foldmethod=indent
set foldlevel=99
" Enable folding with the spacebar
nnoremap <space> za

" Bundle 'klen/python-mode'
" " Python-mode
" 
" " " Activate rope
" " " Keys:
" " " K             Show python docs
" " " <Ctrl-Space>  Rope autocomplete
" " " <Ctrl-c>g     Rope goto definition
" " " <Ctrl-c>d     Rope show documentation
" " " <Ctrl-c>f     Rope find occurrences
" " " <Leader>b     Set, unset breakpoint (g:pymode_breakpoint enabled)
" " " [[            Jump on previous class or function (normal, visual, operator
" " modes)
" " " ]]            Jump on next class or function (normal, visual, operator
" " modes)
" " " [M            Jump on previous class or method (normal, visual, operator
" " modes)
" " " ]M            Jump on next class or method (normal, visual, operator
" " modes)
" let g:pymode_rope = 1
" let g:pymode_rope_completion = 0
" " " Documentation
" let g:pymode_doc = 1
" let g:pymode_doc_key = 'K'
" "
" " "Linting
" let g:pymode_lint = 0 
" let g:pymode_lint_checker = "pyflakes,pep8"
" " " Auto check on save
" let g:pymode_lint_write = 0
" "
" " " Support virtualenv
" let g:pymode_virtualenv = 1
" "
" " " Enable breakpoints plugin
" let g:pymode_breakpoint = 1
" let g:pymode_breakpoint_bind = '<leader>b'
" "
" " " syntax highlighting
" let g:pymode_syntax = 1
" let g:pymode_syntax_all = 1
" let g:pymode_syntax_indent_errors = g:pymode_syntax_all
" let g:pymode_syntax_space_errors = g:pymode_syntax_all
" "
" " " Don't autofold code
" " let g:pymode_folding = 0
" 
" 
" Plugin 'davidhalter/jedi-vim'
" 

" Use <leader>l to toggle display of whitespace
nmap <leader>l :set list!<CR>
" " automatically change window's cwd to file's dir
" set autochdir
"
" " I'm prefer spaces to tabs
set tabstop=4
set shiftwidth=4
set expandtab

" more subtle popup colors
if has ('gui_running')
    highlight Pmenu guibg=#cccccc gui=bold
 endif

 :set colorcolumn=79

"au BufRead,BufNewFile *.py,*.pyw,*.c,*.h match BadWhitespace /\s\+$/

let g:ycm_autoclose_preview_window_after_completion=1
map <leader>g  :YcmCompleter GoToDefinitionElseDeclaration<CR>

let g:syntastic_json_checkers=['jsonlint']
