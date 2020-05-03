" Brian Lubars' VIM RC File
" The commands in this are executed when the GUI is started.
"
set ch=2                      " Make command line two lines high
set mousehide                 " Hide the mouse when typing text

set guifont=Lucida_Console:h9:cANSI
set termguicolors
set tags=tags;/               " recursively search for tags file
set backspace=indent,eol,start
set si                        " smart indent
set ts=2
set sw=2                      " auto-indent tab spaces
set softtabstop=2
set expandtab
set modeline
set listchars=tab:>-,trail:-  " highlight tabs and trailing spaces
set list
set matchtime=2               " show matching bracket for 0.2 seconds
set number                    " show line numbers

" Only do this for Vim version 5.0 and later.
if version >= 500
  " I like highlighting strings inside C comments
  let c_comment_strings=1

  " Switch on syntax highlighting if it wasn't on yet.
  if !exists("syntax_on")
    syntax on
  endif

  au BufNewFile,BufRead *.rs set filetype=rust

  " Switch on search pattern highlighting.
  set hlsearch

  "color koehler
  "colorscheme blubars3
  "colorscheme darkblue "peachpuff darkblue also good for html
  colorscheme desert

  set background=dark
  set cursorline
endif

function! FindTypes()
  if filereadable("./types.vim")
    so ./types.vim
  elseif filereadable("../types.vim")
    so ../types.vim
  elseif filereadable("../../types.vim")
    so ../../types.vim
  elseif filereadable("../../../types.vim")
    so ../../../types.vim
  else
    return
  endif
endfunction

autocmd BufEnter * call FindTypes()

function! GenerateTagsAndSyntax()
  let cwd = getcwd()
  let tagfilename = cwd . "/tags"
  let cmd = 'ctags -f ' . tagfilename . ' --c-kinds=+p-x-l-c-n --languages=c,c++ -R .'
  "let resp = system(cmd)
  "let cmd2 = 'python C:\Users\blubars\Desktop\syntax_from_tags.py -f ' . tagfilename
  "let resp2 = system(cmd2)
  "so ./types.vim
endfunction

noremap <F1> :call GenerateTagsAndSyntax()<CR>

" set up cmds for latex compiling
" compiling:
nnoremap <leader>c :w<CR>:!rubber --pdf --warn all %<CR>
" viewing pdf:
nnoremap <leader>v :!mupdf %:r.pdf &<CR><CR>

