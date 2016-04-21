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
Plugin 'leafgarland/typescript-vim'
Plugin 'tomtom/tcomment_vim'
Plugin 'christoomey/vim-tmux-navigator'
Plugin 'airblade/vim-gitgutter'
Plugin 'altercation/vim-colors-solarized'

Plugin 'Chiel92/vim-autoformat'

" sudo apt-get install python-autopep8
" npm install -g js-beautify
" npm install -g typescript-formatter

call vundle#end()
filetype plugin indent on
<Down>" git clone https://github.com/gmarik/vundle.git ~/.vim/bundle/vundle
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

" shortcut to save
noremap ; :w<CR>

" code formatting
noremap <F3> :Autoformat<CR>

let g:ctrlp_custom_ignore = {
  \ 'dir':  '\v[\/]\.(git)$',
  \ 'file': '\v\.(pyc|swo)$',
  \ }


"Easier mapleader than the default "\"
let mapleader = ","
" type ,p to insert breakpoint. ^[ is at the end.  Insert with ctrl v and then
" esc
" " (the github web gui doesn't display control characters, but it is there)
nnoremap <leader>p oimport ipdb;ipdb.set_trace()<Esc>
nnoremap <leader><S-p> Oimport ipdb;ipdb.set_trace()<Esc>

nnoremap <leader>t oimport pytest;pytest.set_trace()<Esc>
nnoremap <leader><S-t> Oimport pytest;pytest.set_trace()<Esc>




nnoremap <silent> <F4> :let _s=@/<Bar>:%s/\s\+$//e<Bar>:let @/=_s<Bar>:nohl<CR>

syntax enable
set background=dark
colorscheme solarized
