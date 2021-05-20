" auto-install vim-plug
if empty(glob('~/.config/nvim/autoload/plug.vim'))
  silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  "autocmd VimEnter * PlugInstall
  "autocmd VimEnter * PlugInstall | source $MYVIMRC
endif

call plug#begin('~/.config/nvim/autoload/plugged')

    " Better Syntax Support
    Plug 'sheerun/vim-polyglot'
    " File Explorer
    Plug 'scrooloose/NERDTree'
    " Auto pairs for '(' '[' '{'
    Plug 'jiangmiao/auto-pairs'
    "gruvbox theme
    Plug 'morhetz/gruvbox'
    "Conq of code
    Plug 'neoclide/coc.nvim', {'branch': 'release'}
    "Status Line, Airline
    Plug 'vim-airline/vim-airline'
    "Colorizer
    Plug 'norcalli/nvim-colorizer.lua' 

    Plug 'pangloss/vim-javascript'    " JavaScript support
    Plug 'leafgarland/typescript-vim' " TypeScript syntax
    Plug 'maxmellon/vim-jsx-pretty'   " JS and JSX syntax
    Plug 'jparise/vim-graphql'        " GraphQL syntax

    Plug 'mattn/emmet-vim'            " Emmet completion like html...

    "Variable colors c++, WIP
    "Plug 'jackguo380/vim-lsp-cxx-highlight'

    "onedark theme
    Plug 'joshdick/onedark.vim'
    call plug#end()

