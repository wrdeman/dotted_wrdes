set nocompatible
filetype on
":PluginInstall
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

set encoding=utf-8
Plugin 'VundleVim/Vundle.vim'

Plugin 'tpope/vim-unimpaired.git'
Plugin 'tpope/vim-fugitive'

Plugin 'w0rp/ale'
Plugin 'Valloric/YouCompleteMe'
Plugin 'vim-scripts/indentpython.vim'
Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'scrooloose/nerdtree'
Plugin 'tmhedberg/SimpylFold'
Plugin 'tomtom/tcomment_vim'
Plugin 'christoomey/vim-tmux-navigator'
Plugin 'airblade/vim-gitgutter'
Plugin 'rking/ag.vim'
Plugin 'leafgarland/typescript-vim'
Plugin 'Chiel92/vim-autoformat'
Plugin 'Shougo/vimproc'
Plugin 'Quramy/tsuquyomi'
Plugin 'Shougo/unite.vim'
Plugin 'mhartington/vim-typings'
Plugin 'majutsushi/tagbar'
Plugin 'qpkorr/vim-bufkill'
Plugin 'heavenshell/vim-pydocstring'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'bling/vim-bufferline'
Plugin 'baverman/vial'
Plugin 'baverman/vial-http'
call vundle#end()
set hidden
filetype plugin on
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

" disable the arrrows
noremap <Up> <NOP>
noremap <Down> <NOP>
noremap <Left> <NOP>
noremap <Right> <NOP>
syntax on
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

" Use <leader>l to toggle display of whitespace
nmap <leader>l :set list!<CR>
" " automatically change window's cwd to file's dir
" set autochdir
"
" " I'm prefer spaces to tabs
set tabstop=4
set shiftwidth=4
set expandtab

" set two space for typescript
autocmd Filetype ts setlocal ts=2 sw=2 expandtab
autocmd Filetype typescript setlocal ts=2 sw=2 expandtab
autocmd Filetype html setlocal ts=2 sw=2 expandtab
autocmd Filetype json setlocal ts=2 sw=2 expandtab

autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab
autocmd FileType yaml setl indentkeys-=<:>

set relativenumber
set number

" more subtle popup colors
if has ('gui_running')
    highlight Pmenu guibg=#cccccc gui=bold
endif

:set colorcolumn=79

"au BufRead,BufNewFile *.py,*.pyw,*.c,*.h,*.ts match BadWhitespace /\s\+$/

let g:ycm_autoclose_preview_window_after_completion=1
map <leader>g  :YcmCompleter GoToDefinitionElseDeclaration<CR>

" let g:syntastic_python_checkers=["pep8", "flake8"]
" " let g:syntastic_python_flake8_args='--ignore=E501'
" " let g:syntastic_python_pep8_args='--ignore=E501,E402'
" "
" let g:syntastic_json_checkers=['jsonlint']
" set statusline+=%#warningmsg#
" set statusline+=%{SyntasticStatuslineFlag()}
" set statusline+=%*
" let g:syntastic_typescript_checkers = ['tslint', 'tsc']
" let g:syntastic_always_populate_loc_list = 1
" let g:syntastic_auto_loc_list = 1
" let g:syntastic_check_on_open = 1
" let g:syntastic_check_on_wq = 0
" let g:syntastic_typescript_tsc_fname = ''
" let g:syntastic_typescript_checkers=['tslint']

nmap <silent> <]-l> <Plug>(ale_previous_wrap)
nmap <silent> <[-l> <Plug>(ale_next_wrap)

" shortcut to pydoc
nmap <silent> <C-i> <Plug>(pydocstring)

" shortcut to save
noremap ; :w<CR>

" code formatting
noremap <F3> :Autoformat<CR>

" TagBar
nmap <F8> :TagbarToggle<CR>
let g:tagbar_type_typescript = {
            \ 'ctagstype': 'typescript',
            \ 'kinds': [
            \ 'c:classes',
            \ 'n:modules',
            \ 'f:functions',
            \ 'v:variables',
            \ 'v:varlambdas',
            \ 'm:members',
            \ 'i:interfaces',
            \ 'e:enums',
            \ ]
            \ }



" let g:ctrlp_custom_ignore = {
"   \ 'dir':  '\v[\/]\.(git|node_modules)$',
"   \ 'file': '\v\.(pyc|swo)$',
"   \ }
let g:ctrlp_custom_ignore = 'node_modules\|DS_Store\|git\|collected_static\|bower_components\|htmlcov\|client'

"Easier mapleader than the default "\"
let mapleader = ","
" type ,p to insert breakpoint. ^[ is at the end.  Insert with ctrl v and then
" esc
" " (the github web gui doesn't display control characters, but it is there)
nnoremap <leader>i oimport ipdb;ipdb.set_trace()<Esc>
nnoremap <leader><S-i> Oimport ipdb;ipdb.set_trace()<Esc>

nnoremap <leader>p oimport pdb;pdb.set_trace()<Esc>
nnoremap <leader><S-p> Oimport pdb;pdb.set_trace()<Esc>

nnoremap <leader>t oimport pytest;pytest.set_trace()<Esc>
nnoremap <leader><S-t> Oimport pytest;pytest.set_trace()<Esc>

nnoremap <leader>c oconsole.log();<Esc>
nnoremap <leader>d odebugger;<Esc>


" You can configure ag.vim to always start searching from your project root instead of the cwd
" sudo apt-get install silversearcher-ag
let g:ag_working_path_mode="r"


nnoremap <silent> <F4> :let _s=@/<Bar>:%s/\s\+$//e<Bar>:let @/=_s<Bar>:nohl<CR>

nnoremap <S-j> :%!python -m json.tool<CR>

" disable typescript-vim indentation
let g:typescript_indent_disable = 1


fun! <SID>StripTrailingWhitespaces()
    let l = line(".")
    let c = col(".")
    %s/\s\+$//e
    call cursor(l, c)
endfun

autocmd FileType c,cpp,java,php,ruby,python,typescript autocmd BufWritePre <buffer> :call <SID>StripTrailingWhitespaces()


""" COLOURS 
" Set typewriter as colorscheme
" colorscheme typewriter-night

" Set typewriter airline theme
" let g:airline_theme = 'typewriter'

" Change the cursor from block to i-beam in INSERT mode
let &t_SI = "\e[5 q"
let &t_EI = "\e[1 q"
augroup myCmds
  au!
  autocmd VimEnter * silent !echo -ne "\e[1 q"
augroup END
""" COLOURS END
