"*****************************************************************************
" Init
"*****************************************************************************
set nocompatible
if ! len(glob("$HOME/.vim_backup/"))               "  Create backup dir if not exist
  echomsg "backup directory $HOME/.vim_backup doesn't exist - creating..."
  silent !mkdir $HOME/.vim_backup > /dev/null 2&1
endif

set runtimepath+=$HOME/.vimfiles                   " set custom runtimepath
let &titleold=hostname()                           " Set hostname as title on exit
" *****************************************************************************
" Plugins
" *****************************************************************************
call plug#begin('~/.vimfiles/plugged')             " vim-plug(in) management
Plug 'vim-scripts/FuzzyFinder'                     " Find files
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'vim-scripts/compview'                        " Search matches in seperate window
Plug 'sjl/gundo.vim'                               " Visualise undo tree
Plug 'vim-scripts/L9'                              " dependecy for fuzzyfinder
Plug 'scrooloose/nerdtree', { 'on':  ['NERDTreeToggle', 'NERDTreeFind'] } " Nerdtree file browser
Plug 'myusuf3/numbers.vim'                         " Intelligent line numbers (relative vs. absolute)
" Plug 'bsl/obviousmode'
" Plug 'ervandew/supertab'
Plug 'godlygeek/tabular'                           " Align text
Plug 'majutsushi/tagbar'                           " Tags in window
" Plug 'vim-scripts/taglist.vim'
" Plug 'vim-scripts/TaskList.vim'
Plug 'altercation/vim-colors-solarized'            " solarized colour scheme
Plug 'tpope/vim-fugitive'                          " Git integration
Plug 'junegunn/gv.vim'                             " Git commit browser
Plug 'jpalardy/vim-slime'                          " Send code to a REPL
Plug 'tpope/vim-unimpaired'                        " keyboard shortcuts
Plug 'vim-scripts/ZoomWin'                         " zoom window
"Plug 'Lokaltog/vim-powerline'                      " powerline at bottom
Plug 'vim-airline/vim-airline'                     " airline at bottom
Plug 'vim-airline/vim-airline-themes'              " airline themes
Plug 'garbas/vim-snipmate'                         " snippets management
Plug 'tomtom/tlib_vim'                             " utilities needed by snipmate
Plug 'MarcWeber/vim-addon-mw-utils'                " more utilities needed by snipmate
Plug 'honza/vim-snippets'                          " some snippets
" Plug 'Valloric/YouCompleteMe', { 'do' : '~/.vimfiles/plugged/YouCompleteMe/install.py  --clang-completer' }
Plug 'katusk/vim-qkdb-syntax'                      " kdb syntax highlighting
Plug 'mhinz/vim-signify'                           " git gutter
Plug 'vim-scripts/AutoComplPop'                    " auto complete populator
Plug 'mileszs/ack.vim'                             " vim ack plugin
Plug 'ntpeters/vim-better-whitespace'              " highlight trailing whitespace
Plug 'plasticboy/vim-markdown'                     " vim markdown

" Add plugins & runtimepath
call plug#end()

"*****************************************************************************
" General Settings
"*****************************************************************************
set backspace=indent,eol,start                     " backspace works across lines
set hidden                                         " hide buffers, dont close
set history=10000                                  " 10000 command history
set undolevels=1000                                " lots of undos
set writebackup                                    " make a backup of the original file when writing
set backup                                         " and don't delete it after a succesful write.
set backupskip=                                    " there are no files that shouldn't be backed up.
set updatetime=2000                                " write swap files after 2 seconds of inactivity.
set backupext=~                                    " backup for 'file' is 'file~'
set backupdir^=$HOME/.vim_backup                   " backups are written to $HOME/.backup/ if possible.
set directory^=$HOME/.vim_backup//                 " swap files are also written to $HOME/.backup, too.
set ignorecase                                     " ignore case when searching
set smartcase                                      " but be clever when search includes uppercase
set wrapscan                                       " searches wrap around EOF

"*****************************************************************************
" Text Formatting
"*****************************************************************************
set shiftwidth=2                                   " Use indents of 2 spaces
set tabstop=2                                      " Indentation every 2 columns
set nowrap                                         " dont wrap
set expandtab                                      " expand tabs to spaces
"set autoindent                                     " Copy indent from previous line

"*****************************************************************************
" UI
"*****************************************************************************
set modelines=0                                    " no custom modeline in files
set ruler                                          " show where we are
set number                                         " line numbers
syntax on                                          " enable syntax highlighting
set splitbelow                                     " split always to bottom
set splitright                                     " vsplit always to right
if has('gui_running')                              " for solarized colourscheme
  set background=light
else
  set background=dark
endif
colorscheme solarized

"*****************************************************************************
" Visual Cues
"*****************************************************************************
set title                                          " show title in window titlebar
set hlsearch                                       " highlight search
set incsearch                                      " incremental search highlight
set showmatch                                      " show matching braces
set mat=5                                          " duration to show match
set laststatus=2                                   " always show status line
set visualbell                                     " disable audio bell, use visual instead
set scrolloff=3                                    " start scrolling 3 lines before top/bottom
set sidescrolloff=3                                " start scrolling 2 chars befrore left/right
" *****************************************************************************
" Remapping
" *****************************************************************************
let mapleader = ","                                " remap leader key
command W w                                        " remap :W to :w
command Q q                                        " remap :Q to :q
inoremap jj <ESC>
" insert new line
map <leader><Enter> o<ESC>
" clear last search
map <silent> <leader>cs <ESC>:noh<CR>
" better mark jumping
nnoremap ' `
map <leader>, <C-^>
map <leader>ls :buffers<CR>
" move text up/down with unimpared plugin
nmap <leader><Up> [e
nmap <leader><Down> ]e
vmap <leader><Up> [egv
vmap <leader><Down> ]egv
" switch off search highlight
map <silent> <leader>q	:q<CR>
map <silent> <leader>qa	:qa<CR>
map <silent> <leader>wq	:wq<CR>
map <leader>W :w !sudo tee $<CR>
" easier window navigation
map <c-h> <c-w>h
map <c-j> <c-w>j
map <c-k> <c-w>k
map <c-l> <c-w>l
" strip trailing whitespace
map <silent><leader>ss :call StripWhitespace ()<CR>
" Fugitive mappings
map <leader>gs :Gstatus<CR><C-w>10+
map <leader>gc :Gcommit<CR><C-w>10+
map <leader>gd :Gdiff<CR>
map <leader>gw :Gwrite<CR>
map <leader>gr :Gread<CR>
" Open tag defintion in vsplit
map <A-]> :vsp <CR>:exec("tag ".expand("<cword>"))<CR>
" NERD Tree
map <leader>ex :NERDTreeToggle<CR>
" FuzzyFinder
map <leader>ff :FufFile<CR>
map <leader>fr :FufRenewCache<CR>
"junegunn fzf
map <leader>fs :FZF<CR>
map <leader>ft :Tags<CR>
map <leader>fl :BLines<CR>                " lines in current buffer
map <leader>fL :Lines<CR>                 " lines in loaded buffers
map <leader>fb :Buffers<CR>
map <leader>fc :BCommits<CR>              " commits for current buffer
map <leader>fC :Commits<CR>               " all commits


" Gundo
nnoremap <leader>u :GundoToggle<CR>
" TagBar
nmap <leader>tb :TagbarToggle<CR>
" NumbersToggle
nmap <leader>rnt :NumbersToggle<CR>
" TagList
map <leader>tl <Plug>TaskList
" CompView (search result list pane)
map <leader>sl <Plug>CompView
" ZoomWin
map <leader><leader> <c-w>o
"*****************************************************************************
" Auto Commands
"*****************************************************************************
if has ("autocmd")
  au BufNewFile,BufRead *.q set filetype=q         " add q filetype
  au FileType q set omnifunc=OmniQ                 " enable omnicomplete for q
  au FileType python set omnifunc=pythoncomplete#Complete
endif

"*****************************************************************************
" Functions
"*****************************************************************************
function! StripWhitespace ()
  let save_cursor = getpos(".")
  let old_query = getreg('/')
  :%s/\s\+$//e
  call setpos('.', save_cursor)
  call setreg('/', old_query)
endfunction

"*****************************************************************************
" Plugins
"*****************************************************************************
" Solarized
let g:solarized_termcolors=256                     " For solarized colourscheme

" vim-airline theme
let g:airline_theme='solarized'

" junegunn fzf
"
" This is the default extra key bindings
let g:fzf_action = {
  \ 'ctrl-t': 'tab split',
  \ 'ctrl-x': 'split',
  \ 'ctrl-k': 'vsplit' }

" SuperTab defaults
let g:SuperTabDefaultCompletionType = "context"
let g:SuperTabContextDefaultCompletionType = "<C-X><C-O>"
let g:SuperTabMappingForward = '<nul>'
let g:SuperTabMappingBackward = '<s-nul>'

" Exuberent ctags
set tags=./tags;/,$HOME/.vimtags

" vim-slime settings
let g:slime_target         = "screen"
let g:slime_paste_file     = "$HOME/.slime_paste"

" FuzzyFinder settings
let g:FuzzyFinderOptions = { 'Base':{}, 'File':{} }
let g:FuzzyFinderOptions.Base.ignore_case = 1
let g:FuzzyFinderOptions.File.excluded_path = '\.git$|\.svn$|\.bin$|\.swp'

" Gundo
let g:gundo_width = 60
let g:gundo_preview_height = 40
let g:gundo_preview_bottom = 1

" TagBar
let g:tagbar_type_q = {
    \ 'ctagstype' : 'q',
    \ 'kinds'     : [
        \ 'f:function',
        \ 'v:variables',
    \ ]
\ }

" TaskList
let g:tlTokenList = ['TODO', 'FIXME', 'XXX', 'CHAT']
let g:tlRememberPosition =1
" Powerline
" let g:Powerline_symbols = 'fancy'
" MiniBufExplorer
let g:miniBufExplorerMoreThanOne=3
let g:miniBufExplSplitBelow=0

" SnipMate
source $HOME/.vimfiles/plugged/vim-snipmate/after/plugin/snipMate.vim
