set encoding=utf-8

set nocompatible
set number
set cursorline

syntax enable
set showmatch
set tabstop=4
set shiftwidth=4
set textwidth=78
let NERDTreeWinSize=20

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" Plugin list
" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'
" Git plugin not hosted on GitHub
Plugin 'git://git.wincent.com/command-t.git'
" File List
Plugin 'preservim/nerdtree'
" AutoCompletion
Plugin 'davidhalter/jedi-vim'
" All of your Plugins must be added before the following line
call vundle#end() " required
filetype plugin indent on " required

" map

" NERDTree
map <F2> :NERDTreeToggle <CR>

" run
map <F5> :call SaveRun() <CR>
func SaveRun()
	exec "w"
	if &filetype == "python"
		exec "!python3 %"
	endif
endfunction
