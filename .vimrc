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
Plugin 'tomtom/tcomment_vim'
Plugin 'christoomey/vim-tmux-navigator'
Plugin 'airblade/vim-gitgutter'
Plugin 'leafgarland/typescript-vim'
Plugin 'rking/ag.vim'
Plugin 'Chiel92/vim-autoformat'
Plugin 'Shougo/vimproc'
Plugin 'Quramy/tsuquyomi'
Plugin 'Shougo/unite.vim'
Plugin 'mhartington/vim-typings'
Plugin 'majutsushi/tagbar'

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

" disable the arrrows 
noremap <Up> <NOP>
noremap <Down> <NOP>
noremap <Left> <NOP>
noremap <Right> <NOP>

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

let g:syntastic_json_checkers=['jsonlint']
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_typescript_tsc_fname = ''
let g:syntastic_typescript_checkers=['tslint']

" shortcut to save
noremap ; :w<CR>

" code formatting
noremap <F3> :Autoformat<CR>

" TagBar
nmap <F8> :TagbarToggle<CR>
" let g:ctrlp_custom_ignore = {
"   \ 'dir':  '\v[\/]\.(git|node_modules)$',
"   \ 'file': '\v\.(pyc|swo)$',
"   \ }
let g:ctrlp_custom_ignore = 'node_modules\|DS_Store\|git\|collected_static\|bower_components'

"Easier mapleader than the default "\"
let mapleader = ","
" type ,p to insert breakpoint. ^[ is at the end.  Insert with ctrl v and then
" esc
" " (the github web gui doesn't display control characters, but it is there)
nnoremap <leader>p oimport ipdb;ipdb.set_trace()<Esc>
nnoremap <leader><S-p> Oimport ipdb;ipdb.set_trace()<Esc>

nnoremap <leader>t oimport pytest;pytest.set_trace()<Esc>
nnoremap <leader><S-t> Oimport pytest;pytest.set_trace()<Esc>

nnoremap <leader>c oconsole.log();<Esc>
nnoremap <leader>d odebugger;<Esc>


" You can configure ag.vim to always start searching from your project root instead of the cwd
" sudo apt-get install silversearcher-ag
let g:ag_working_path_mode="r"


nnoremap <silent> <F4> :let _s=@/<Bar>:%s/\s\+$//e<Bar>:let @/=_s<Bar>:nohl<CR>


" disable typescript-vim indentation
let g:typescript_indent_disable = 1


fun! <SID>StripTrailingWhitespaces()
   let l = line(".")
   let c = col(".")
   %s/\s\+$//e
   call cursor(l, c)
endfun

autocmd FileType c,cpp,java,php,ruby,python,typescript autocmd BufWritePre <buffer> :call <SID>StripTrailingWhitespaces()    
