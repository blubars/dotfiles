" Brian Lubars neovim config
"+-----------------------------------------------
"|  PLUGINS
"+-----------------------------------------------
" PLUGIN USAGE:
" * PLUG: :PlugInstall, :PlugUpdate, :PlugClean, :PlugStatus, :PlugUpgrade
" * NERDCOMMENTER: <leader>cc/cu = single line; multiple, add number
call plug#begin('~/.local/share/nvim/plugged')
Plug 'tpope/vim-surround'
Plug 'nvim-lua/plenary.nvim'  " Lua functions required for typescript-tools
Plug 'antoinemadec/FixCursorHold.nvim'  " required for neotest
Plug 'nvim-neotest/neotest'
Plug 'nvim-neotest/neotest-python'
Plug 'nvim-neotest/nvim-nio'  " Required for neotest-python
Plug 'pmizio/typescript-tools.nvim'  " TS LSP
" Plug 'nvim-treesitter/nvim-treesitter'
" Gives a floating line at the top showing the function/class
" Plug 'nvim-treesitter/nvim-treesitter-context'
Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.3' }
Plug 'BurntSushi/ripgrep'
Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
"Plug 'mhartington/formatter.nvim'  " Lua formatter: defines Format, FormatWrite
Plug 'cohama/lexima.vim'
Plug 'scrooloose/nerdcommenter'
"Plug 'neomake/neomake'
"Plug 'sheerun/vim-polyglot'
"Plug 'numirias/semshi'
"Plug 'sbdchd/neoformat'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'janko/vim-test'
"Plug 'tpope/vim-dispatch'  " compilers to use with make, used as a vim-test strategy)
"Plug 'tartansandal/vim-compiler-pytest'
Plug 'kassio/neoterm' " neovim terminal :T/:Tnew
Plug 'tpope/vim-fugitive'
Plug 'majutsushi/tagbar'
" THEMES:
" Plug 'morhetz/gruvbox'
Plug 'ellisonleao/gruvbox.nvim'
Plug 'nanotech/jellybeans.vim'
Plug 'sickill/vim-monokai'
Plug 'saltstack/salt-vim'  " syntax highlighting for *.sls
Plug 'Glench/Vim-Jinja2-Syntax'  " syntax highlighting for *.jinja[2]
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/nvim-cmp'  " autocompletion
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-cmdline'
Plug 'dcampos/nvim-snippy'
Plug 'dcampos/cmp-snippy'
Plug 'honza/vim-snippets'
Plug 'onsails/lspkind.nvim'
Plug 'lukas-reineke/lsp-format.nvim'
call plug#end()

"+-----------------------------------------------
"|  Global options
"+-----------------------------------------------
set noswapfile
set background=light
set mouse=a     " mouse scrolling & selecting
set backspace=indent,eol,start
" See: https://stackoverflow.com/questions/234564/tab-key-4-spaces-and-auto-indent-after-curly-braces-in-vim/234578#234578
filetype plugin indent on
set ts=4
set sw=4
set softtabstop=4
set expandtab
set modeline
set list  " show whitespace as characters (excl space). See listchars
"set tw=84  " auto-wrap. use "gq" to reformat (or "gw<movement>")
set tw=120  " auto-wrap. use "gq" to reformat (or "gw<movement>")

" default: tcqj
" t = auto-wrap text using tw
" c = auto-wrap comments
" q = allow formatting of comments with "gq"
" n = recognize numbered lists
set fo=cqj
autocmd FileType vim,lua setlocal ts=2 sw=2

set number      " show linenumbers"
" Always spell check when writing a commit message.
" Also consider adding a custom dictionary per repo to catch typos.
autocmd FileType gitcommit setlocal spell

"+-----------------------------------------------
"|  Terminal buffer
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
"|   LOCAL ENVS / PATHS
"+-----------------------------------------------
" We would like things like python and node to use the local project config,
" rather than global settings.
" The easiest way to do this is to assume a fixed directory structure.
" Use python virtualenv:
let g:python3_host_prog='/Users/brianlubars/.pyenv/versions/3.8.10/envs/venv-nvim/bin/python3'
let g:python_host_prog='/Users/brianlubars/.pyenv/versions/3.8.10/envs/venv-nvim/bin/python'
"let g:node_host_prog='/Users/brianlubars/.asdf/installs/nodejs/25.2.1'



"+-----------------------------------------------
"|   LSP
"+-----------------------------------------------
" moved these settings to its own file.
lua require('init')

"+-----------------------------------------------
"|  PLUGIN OPTIONS
"+-----------------------------------------------
" CTRLP:
" -- CtrlP [dir] -- find file
" -- CtrlPBuffer -- find in buffers
" -- <F5>--purge cache, <C-f>/C-b> -- cycle modes. c-d:filename, c-j/c-k:navigate list
" -- C-t/c-v/c-x: open sel entry in new tab/split
" -- C-n/C-p: select next/prev string in prompt hist
" -- C-z/C-o: mark/unmark/open files
let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd='CtrlP'
let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files -co --exclude-standard']
" NEOTERM:
let g:neoterm_autoscroll=1
let g:neoterm_default_mod='belowright'
let g:neoterm_keep_term_open=0
" ALE:
"let g:airline#extensions#ale#enabled=1
" VIMFUGITIVE:
autocmd BufReadPost fugitive://* set bufhidden=delete

"augroup black_on_save
  "autocmd!
  "autocmd BufWritePre *.py Black
"augroup end

" run formatters: neoformat prettier, black on save
" Hard-code the node_modules path to prettier. Not portable, but works for now.
"let s:formatprg = findfile('node_modules/.bin/prettier')
"let &formatprg = s:formatprg . ' --stdin'
"let g:neoformat_try_formatprg = 1
"let g:neoformat_try_node_exe = 1

"autocmd BufWritePre *.js Neoformat
"autocmd BufWritePre *.ts Neoformat
"autocmd BufWritePre *.tsx Neoformat
"autocmd BufWritePre *.py execute ':Black'
"autocmd BufWritePre *.tsx,*.ts,*.jsx,*.js EslintFixAll

" Telescope (file/buffer fuzzy-finder)
" ignore the node_modules folder in telescope, which is _huge_
lua << EOF

require('telescope').setup{
  defaults = {
    mappings = {
      i = {
        ["<C-h>"] = "which_key",
      },
    },
    file_ignore_patterns = {"node_modules"}
  },
}
require('telescope').load_extension('fzf')
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<C-q>', builtin.quickfix, {})
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
vim.keymap.set('n', '<leader>ft', builtin.tags, {})
EOF

"+-----------------------------------------------
"|  MAPPING/COMMANDS
"+-----------------------------------------------
"" vim-test transformation to run nose tests via `make singletest`.
" If a command looks like "nosetests ...", transform it to
" "make singletest PYTESTARGS='...'"
function! HonorTransform(cmd) abort
    if a:cmd =~ '^\(poetry\|pipenv\|uv\) run pytest'
        " command if not using docker
        let l:cmd_sans_pytest = "-s ".substitute(a:cmd, '^\(poetry\|pipenv\|uv\) run pytest ', '', '')
        let l:new_cmd = 'make singletest PARALLELISM=1 PYTESTARGS='.shellescape(l:cmd_sans_pytest)
        " command using docker
        " let l:cmd_sans_pytest = "".substitute(a:cmd, '^pipenv run pytest ', '', '')
        " let l:new_cmd = 'make singletest TEST='.shellescape(l:cmd_sans_pytest)
    else
        let l:new_cmd = a:cmd
    endif
    return l:new_cmd
endfunction

" nmap <silent> <leader>tn :TestNearest -vv<CR>
" nmap <silent> <leader>tf :TestFile<CR>
" nmap <silent> <leader>ts :TestSuite<CR>
" nmap <silent> <leader>tl :TestLast<CR>

" generate a new react component and open the file in a new split
"function! NewReactComponentSplit(component_name)
  "let l:cmd = 'silent !yarn generate react '.expand('%:h').' '.a:component_name
  "execute l:cmd
  "execute 'split '.expand('%:h').'/'.a:component_name
"endfunction
"command! -nargs=1 NewReactComponent call NewReactComponentSplit(<f-args>)

set grepprg=rg\ --vimgrep\ -i\ -T\ json\ -g\ '!tags'\ -g\ '!*/{.mypy_cache,.direnv,node_modules,.pytest_cache}/*'

" Custom grep commands. Borrowed from https://chase-seibert.github.io/blog/2013/09/21/vim-grep-under-cursor.html
" Opens search results in a window with links and highlights the matches
command! -nargs=+ Grep execute 'grep! <args> -g ''!*test.*''' | copen | /<args>\c
command! -nargs=+ Grep execute 'grep! <args>' | copen | /<args>\c

" -I: ignore binary files; -n: line number; -e: pattern to match in search
"command! -nargs=+ Grep execute 'silent grep! -I -r -n --exclude "*.{json,pyc}" --exclude "*.test.*" --exclude "*_test.*" --exclude tags --exclude-dir ".mypy_cache" --exclude-dir ".direnv" --exclude-dir "*/node_modules/*" --exclude-dir "thrift" --exclude-dir ".pytest_cache" . -e <args>' | copen | execute 'silent /<args>'
"command! -nargs=+ GrepAll execute 'silent grep! -I -r -n --exclude "*.{json,pyc,}" --exclude tags --exclude-dir ".mypy_cache" --exclude-dir ".direnv" --exclude-dir "*/node_modules/*" --exclude-dir "thrift" --exclude-dir ".pytest_cache" . -e <args>' | copen | execute 'silent /<args>'
" shift-control-* Greps for the word under the cursor
:nmap <leader>g :Grep <c-r>=expand("<cword>")<cr><cr>

"let test#python#pytest#file_pattern = '\vMATCH_NOTHING_AT_ALL$'
let test#python#runner = 'pytest'
let test#python#pytest#file_pattern = '\v(^|[\b_\.-])[Tt]est.*\.py$'
let g:test#custom_transformations = {'honor': function('HonorTransform')}
let g:test#transformation = 'honor'
let test#strategy='neoterm'  "'neovim'

" reload vimrc
map <leader>r :source ~/.config/nvim/init.vim<CR>
" tags: C-]/C-t -- up/down tag stack
"      ts=search, tn/tp=next/prev def, ts=list
map <leader>T :!ctags --exclude='*.json' --exclude='\.+*' --exclude='*thrift' --exclude='*.sql' -R .<CR>

" Tagbar config
nmap <leader>d :TagbarToggle<CR>
let g:tagbar_left = 1

" <C-space> for keyword completion help
imap <C-space> <C-X><C-N>

" Replace word under cursor with one from clipboard
" Also can use a range in vim's builtin search.
"   E.g., visiual:   `:'<,'>s/foo/bar/g`
" Also useful:
"  -- <C-r>" -- paste word into command line from register
"  -- <C-r><C-[w/a]> -- paste [word/WORD] under cursor into command line
map <leader>p :

"+-----------------------------------------------
"|  FOLDING
"+-----------------------------------------------
"| za -- toggle fold.
"+-----------------------------------------------
set foldmethod=indent
set foldlevel=3
nnoremap <silent> <Space><Space> @=(foldlevel('.')?'za':"\<Space>")<CR>
"nnoremap <space> za

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

"+-----------------------------------------------
"|  USEFUL COMMAND REFERENCE
"+-----------------------------------------------
" INSERT MODE:
" CTRL-D: delete one shiftwidth of indent at start of current line
" 0 CTRL-D: delete all indent in current line
" CTRL-X -- completion.
"   <C-X><C-N> -- keywords in current file
"   <C-X><C-]> -- tags
"   <C-X><C-O> -- omni completion
"   <C-X>s -- spelling suggestions
"   <C-N>/<C-P> -- navigate list
"   <C-E>/<C-Y> to esc without/with accepting.

""" Colors
lua << EOF
local gruvbox = require('gruvbox')
gruvbox.setup({
  terminal_colors = true, -- add neovim terminal colors
  undercurl = true,
  underline = true,
  bold = true,
  italic = {
    strings = false,
    emphasis = true,
    comments = true,
    operators = false,
    folds = false,
  },
  invert_selection = false,
  invert_intend_guides = false,
  inverse = true, -- invert background for search, diffs, statuslines and errors
  contrast = "hard", -- can be "hard", "soft" or empty string
  palette_overrides = {},
  overrides = {
    Whitespace = { fg = "#fbf1c7", bg = "#fb4934" },
    -- CursorLine = { bg = "#3c3836" },
    -- Function = { fg = "#8ec07c", bold = true},
    NormalFloat = { fg = "#ebdbb2", bg = "#32302f", },
  },
  transparent_mode = false,
})
vim.cmd("colorscheme gruvbox")
EOF

"let g:gruvbox_contrast_dark = 'hard'  "options: soft|medium|hard
"colorscheme gruvbox "monokai jellybeans, gruvbox

" set up colors/highlighting
"syntax on
set hlsearch
let g:airline_theme='base16_gruvbox_dark_medium'
set listchars=tab:>-,trail:-
" hi Whitespace ctermbg=160
" hi Search ctermbg=136
let g:sls_use_jinja_syntax = 1

" make it easier to find current pane
augroup BgHighlight
    autocmd!
    autocmd WinEnter * set cul "cursorline
    autocmd WinLeave * set nocul
augroup END
