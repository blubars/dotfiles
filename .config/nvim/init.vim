" Brian Lubars neovim config 2020

"+-----------------------------------------------
"|  PLUGINS
"+-----------------------------------------------
" PLUGIN USAGE:
" * PLUG: :PlugInstall, :PlugUpdate, :PlugClean, :PlugStatus, :PlugUpgrade
" * NERDCOMMENTER: <leader>cc/cu = single line; multiple, add number
" * Codi: Codi [filetype] activates Codi for the current buffer;
"   Codi! deactivates Codi for the current buffer; Codi!! [filetype] toggles.
call plug#begin('~/.local/share/nvim/plugged')
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
"Plug 'jiangmiao/auto-pairs'
Plug 'scrooloose/nerdcommenter'
" Plug 'neomake/neomake'
Plug 'sheerun/vim-polyglot'
Plug 'numirias/semshi'
"Plug 'sbdchd/neoformat'
"Plug 'psf/black'
Plug '/usr/local/opt/fzf'
Plug 'junegunn/fzf.vim'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'janko/vim-test'
Plug 'kassio/neoterm' " neovim terminal :T/:Tnew
Plug 'tpope/vim-fugitive'
Plug 'metakirby5/codi.vim'
Plug 'majutsushi/tagbar'
Plug 'dense-analysis/ale'

" THEMES
Plug 'morhetz/gruvbox'
Plug 'nanotech/jellybeans.vim'
Plug 'sickill/vim-monokai'
"Plug 'icymind/NeoSolarized' -- doesn't work right
call plug#end()

"+-----------------------------------------------
"|  TERMINAL BUFFER
"+-----------------------------------------------
" NVIM TERMINAL USAGE: :terminal, :vnew term://bash, new term://bash; i=start typing
"   ctrl-N to leave insert, exit to close
"let &shell='/usr/bin/bash --login'  "need --login to source .bash_profile
let &shell='/bin/zsh'
"autocmd TermOpen term://* startinsert   "start in insert mode
"autocmd TermEnter startinsert   "start in insert mode
autocmd TermOpen * nnoremap <buffer> <CR> G$i
" navigate windows from any mode
"tnoremap <Esc> <c-\><c-n>
tnoremap <c-h> <c-\><c-n><C-w>h
tnoremap <c-j> <c-\><c-n><C-w>j
tnoremap <c-k> <c-\><c-n><C-w>k
tnoremap <c-l> <c-\><c-n><C-w>l
inoremap <c-h> <c-\><c-n><C-w>h
inoremap <c-j> <c-\><c-n><C-w>j
inoremap <c-k> <c-\><c-n><C-w>k
inoremap <c-l> <c-\><c-n><C-w>l
nnoremap <c-h> <c-w>h
nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k
nnoremap <c-l> <c-w>l

"+-----------------------------------------------
"|  OPTIONS
"+-----------------------------------------------
set background=dark
set mouse=a     " mouse scrolling & selecting
set backspace=indent,eol,start
set si          " smart indent"
set ts=4
set sw=4
set softtabstop=4
set expandtab
set modeline
set list
set number      " show linenumbers"

" set up colors/highlighting
syntax on
set hlsearch
colorscheme monokai "monokai jellybeans, gruvbox 
"let g:airline_theme='bubblegum'
set listchars=tab:>-,trail:-
hi Whitespace ctermbg=160
hi Search ctermbg=136

" make it easier to find current pane
augroup BgHighlight
    autocmd!
    autocmd WinEnter * set cul "cursorline
    autocmd WinLeave * set nocul
augroup END

" Use python virtualenv:
let g:python3_host_prog='/Users/brianlubars/.pyenv/versions/3.6.8/envs/venv-nvim/bin/python3'
let g:python_host_prog='/Users/brianlubars/.pyenv/versions/3.6.8/envs/venv-nvim/bin/python'

"Ctrl-P
"CtrlP [dir] -- find file
"CtrlPBuffer -- find in buffers
"<F5>--purge cache, <C-f>/C-b> -- cycle modes. c-d:filename, c-j/c-k:navigate
"list
"C-t/c-v/c-x:open sel entry in new tab/split
"C-n/C-p:select next/prev string in prompt hist
"C-z/C-o:mark/unmark/open files
let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd='CtrlP'
let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files -co --exclude-standard']

let g:neoterm_autoscroll=1
let g:neoterm_default_mod='belowright'
let g:neoterm_keep_term_open=0

"Ale
let g:airline#extensions#ale#enabled=1

autocmd BufReadPost fugitive://* set bufhidden=delete
"+-----------------------------------------------
"|  MAPPING/COMMANDS
"+-----------------------------------------------
" run formatters: neoformat prettier, black on save
"autocmd BufWritePre *.js Neoformat
"autocmd BufWritePre *.py execute ':Black'
"
"" vim-test transformation to run nose tests via `make singletest`.
" If a command looks like "nosetests ...", transform it to
" "make singletest NOSEARGS='...'"
function! HonorTransform(cmd) abort
    if a:cmd =~ '^nosetests '
        let l:cmd_sans_nosetests = "-s ".substitute(a:cmd, '^nosetests ', '', '')
        let l:new_cmd = 'make singletest TEST_PROCESSES=0 TEST_DB_COUNT=1 NOSEARGS='.shellescape(l:cmd_sans_nosetests)
    else
        let l:new_cmd = a:cmd
    endif
    return l:new_cmd
endfunction

" Force use of nosetest over pytest
let test#python#pytest#file_pattern = '\vMATCH_NOTHING_AT_ALL$'
let test#python#nose#file_pattern = '\v(^|[\b_\.-])[Tt]est.*\.py$'
let g:test#custom_transformations = {'honor': function('HonorTransform')}
let g:test#transformation = 'honor'
let test#strategy='neoterm'  "'neovim'

" reload vimrc
map <leader>r :source ~/.config/nvim/init.vim<CR>

"tags: C-]/C-t -- up/down tag stack
"      ts=search, tn/tp=next/prev def, ts=list
map <leader>t :!ctags -R .<CR>

" Tagbar config
nmap <leader>d :TagbarToggle<CR>
let g:tagbar_left = 1

"+-----------------------------------------------
"|  FOLDING
"+-----------------------------------------------
" za -- toggle fold.
" set foldmethod=indent
" set foldlevel=99
nnoremap <space> za

"+-----------------------------------------------
"|  FZF (:F)
"+-----------------------------------------------
"set rtp+=/usr/local/opt/fzf
"let g:rg_command = '
"  \ rg --column --line-number --no-heading --fixed-strings --ignore-case --no-ignore --hidden --follow --color "always"
"  \ -g "*.{js,json,php,md,styl,jade,html,config,py,cpp,c,go,hs,rb,conf}"
"  \ -g "!{.git,node_modules,vendor}/*" '
"
"command! -bang -nargs=* F call fzf#vim#grep(g:rg_command .shellescape(<q-args>), 1, <bang>0)
