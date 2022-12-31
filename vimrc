if !has('nvim')
  set nocompatible
endif

" disable the magic "vim: .." lines in files
set nomodeline

" we like to keep all swap files in the same directory, but when you
" open two files with the same name and then try to recover from a
" power cord unplugged by mistake, big problems may arise, so let's
" try to live without them
set noswapfile

if has('nvim')
  if has('mac') " speeds up neovim startup on macos
    let g:clipboard = {
          \ 'name': 'pbcopy',
          \ 'copy': {
          \    '+': 'pbcopy',
          \    '*': 'pbcopy',
          \  },
          \ 'paste': {
          \    '+': 'pbpaste',
          \    '*': 'pbpaste',
          \ },
          \ 'cache_enabled': 0,
          \ }
  endif

  set clipboard+=unnamedplus
else
  set clipboard=unnamed,unnamedplus

  " http://vim.wikia.com/wiki/Working_with_Unicode
  if has('multi_byte')
    if &termencoding == ''
      let &termencoding = &encoding
    endif
    set encoding=utf-8
    scriptencoding utf-8
    setglobal fileencoding=utf-8
    set fileencodings=ucs-bom,utf-8,latin1
  endif

  " allow backspacing over everything in insert mode
  set backspace=indent,eol,start

  " fish shell is supported since vim 7.4.276
  if version < 704 || (version == 704 && !has('patch276'))
    if &shell =~# 'fish$'
      set shell=bash
    endif
  endif

  " remove comments symbols when joining lines
  if version > 703 || (version == 703 && has('patch541'))
    set formatoptions+=j
  endif

  " for screens bigger than 232 columns
  if has('mouse_sgr')
    set ttymouse=sgr
  endif

  " do highlight as you search
  set incsearch
  set hlsearch

  " always show the status line
  set laststatus=2

  set autoindent
  set smarttab

  syntax enable
  set wildmenu
  set ttyfast
endif

" don't reload a file when it's changed from the outside
set noautoread

" hide unsaved buffers
set hidden

" airline suggests setting ttimoutline to avoid delays
" when switching modes. steve losh also suggests these
set notimeout
set ttimeout
set ttimeoutlen=10

set lazyredraw
set noshowcmd

" can't type these right...
abbreviate lenght length
abbreviate heigth height

" common mistakes in command line
cabbrev rg Rg
cabbrev Wq wq
cabbrev Wa wa
cabbrev Qa qa
cabbrev W w
cabbrev Q q
cabbrev E e
cabbrev R r

set completeopt-=preview
" http://stackoverflow.com/questions/2169645/
set complete=.,w,b,t

" use the mouse but don't put us in visual mode
set mouse=nicr

let mapleader="\<Space>"

" http://rbtnn.hateblo.jp/entry/2014/12/28/010913
augroup vimrc
  autocmd!
augroup END

" ----------------------------------------------------------------------
" FOLDER MANAGEMENT ----------------------------------------------------
" ----------------------------------------------------------------------

let s:base = has('nvim') ? '~/.config/nvim' : '~/.vim'

function! s:EnsureExists(path)
  let l:dir = expand(a:path)
  if !isdirectory(l:dir)
    call mkdir(l:dir)
  endif
endfunction

let spellfile = s:base . '/spell/it.utf8.add'
let g:sessiondir = '~/.cache/vim_session'
set backupdir=~/.cache/vim_backup

call <SID>EnsureExists(s:base . '/spell')
call <SID>EnsureExists('~/.cache')
call <SID>EnsureExists(g:sessiondir)
call <SID>EnsureExists(&backupdir)

if exists('+undofile')
  set undofile
  set undodir=~/.cache/vim_undo
  call <SID>EnsureExists(&undodir)
endif

" ----------------------------------------------------------------------
" PLUGINS --------------------------------------------------------------
" ----------------------------------------------------------------------

if empty(glob(s:base . '/autoload/plug.vim'))
  execute '!curl -fLso ' . s:base . '/autoload/plug.vim --create-dirs'
        \ 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd vimrc VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin(s:base . '/plugged')

Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'neoclide/coc.nvim', {'branch': 'release'}

Plug 'airblade/vim-gitgutter'
Plug 'mbbill/undotree'
Plug 'dyng/ctrlsf.vim'

Plug 'michaeljsmith/vim-indent-object'
Plug 'junegunn/vim-easy-align'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'
Plug 'wellle/targets.vim'
Plug 'tpope/vim-repeat'

Plug 'HerringtonDarkholme/yats.vim'
Plug 'MaxMEllon/vim-jsx-pretty'
Plug 'pangloss/vim-javascript'
Plug 'groenewege/vim-less'
Plug 'ap/vim-css-color'
Plug 'dag/vim-fish'

Plug 'cvlmtg/vim-256noir'

call plug#end()

" load matchit.vim, but only if the user hasn't installed a newer version
if !exists('g:loaded_matchit') && findfile('plugin/matchit.vim', &rtp) ==# ''
  runtime! macros/matchit.vim
endif

let loaded_netrwPlugin = 1

" ctrlsf ---------------------------------------------------------------

let g:ctrlsf_regex_pattern = 1
let g:ctrlsf_winsize = '30%'
let g:ctrlsf_auto_close = {
      \ "normal" : 0,
      \ "compact": 0
      \}

" just a little shortcut
function! SmartCtrlSF(args)
  if &columns < 120
    let g:ctrlsf_position = 'bottom'
  else
    let g:ctrlsf_position = 'left'
  endif
  call ctrlsf#Search(a:args, 0)
endfunction

command! -nargs=* -complete=file Rg call SmartCtrlSF(<q-args>)

" grep the word under the cursor
nmap <leader>a :Rg <C-R><C-W><CR>

" fzf ------------------------------------------------------------------

set wildignore+=*/tmp/*,*/cache/*,*/node_modules/*,*/vendor/*

let g:fzf_layout = { 'down': '40%' }
let g:fzf_command_prefix = 'Fzf'

nnoremap <leader>l :<C-u>FzfLines<CR>
nnoremap <leader>b :<C-u>FzfBuffers<CR>
nnoremap <leader>h :<C-u>FzfHelptags<CR>
nnoremap <leader>f :<C-u>FzfGitFiles --exclude-standard --cached --others<CR>

" complete -------------------------------------------------------------

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~ '\s'
endfunction

" Insert <tab> when previous text is space, refresh completion if not.
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()

inoremap <expr> <S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

inoremap <expr> <CR> coc#pum#visible() ? coc#pum#confirm() : "\<CR>"

" move between linting errors
nmap <silent> <C-k> <Plug>(coc-diagnostic-prev)
nmap <silent> <C-j> <Plug>(coc-diagnostic-next)

" show function signature
nnoremap <silent> <leader>d :call CocAction('doHover')<CR>

" suppress the annoying 'match x of y', 'The only match'
" and 'Pattern not found' messages
set shortmess+=c

if exists('&signcolumn') " Vim 7.4.2201
  set signcolumn=yes
endif

let g:coc_global_extensions = [
      \ 'coc-css',
      \ 'coc-eslint',
      \ 'coc-html',
      \ 'coc-json',
      \ 'coc-tsserver'
      \ ]

" easy align -----------------------------------------------------------

vmap <Enter> <Plug>(EasyAlign)

" undotree -------------------------------------------------------------

nnoremap <leader>u :UndotreeToggle<CR>
let g:undotree_WindowLayout = 2

" gitgutter ------------------------------------------------------------

let g:gitgutter_override_sign_column_highlight = 0
let g:gitgutter_show_msg_on_hunk_jumping = 0
let g:gitgutter_map_keys = 0
set updatetime=1000

" ----------------------------------------------------------------------
" APPEARANCE -----------------------------------------------------------
" ----------------------------------------------------------------------

set synmaxcol=1000

set number
if has('nvim') || version > 702
  set relativenumber
endif

set nojoinspaces

" ignore case unless we type a uppercase letter
set ignorecase
set smartcase

" live substitution preview
if has('nvim')
  set inccommand=nosplit
endif

" keep more context when scrolling off the end of a buffer
set scrolljump=5
set scrolloff=5

" show matching brackets
set showmatch

" change cursor shape in insert mode
if !has('nvim')
  let &t_SI = "\e[6 q"
  let &t_EI = "\e[2 q"
end

set termguicolors
set background=dark
set cursorline

colorscheme 256_noir

" customize spelling colors to avoid unreadable
" combinations of background and foreground
highlight clear SpellBad
highlight SpellBad term=underline cterm=underline gui=underline
highlight clear SpellCap
highlight SpellCap term=underline cterm=underline gui=underline
highlight clear SpellRare
highlight SpellRare term=underline cterm=underline gui=underline
highlight clear SpellLocal
highlight SpellLocal term=underline cterm=underline gui=underline

" ----------------------------------------------------------------------
" STATUSLINE -----------------------------------------------------------
" ----------------------------------------------------------------------

" copied and modified from http://www.blaenkdenum.com/posts/a-simpler-vim-statusline/
function! StatuslineColumn()
  let l:vc           = virtcol('.')
  let l:ruler_width  = max([strlen(line('$')), (&numberwidth - 1)])
  let l:column_width = strlen(l:vc)
  let l:padding      = l:ruler_width - l:column_width
  let l:column       = ''

  if exists('&signcolumn') && &signcolumn == 'yes'
    let l:padding += 2
  else
    " no idea if there's a faster alternative
    redir => l:signlist
    silent! execute 'sign place buffer='. bufnr('%')
    redir END
    if strlen(l:signlist) > 18
      let l:padding += 2
    endif
  endif

  if l:padding > 0
    " + 1 becuase for some reason vim eats one of the spaces
    let l:column .= repeat(' ', l:padding + 1) . l:vc
  else
    let l:column .= l:vc
  endif

  return l:column . ' '
endfunction

function! s:ShortenPath(path)
  let l:parts = split(a:path, '/')

  if len(l:parts) < 3
    return a:path
  end

  let l:path  = l:parts[0:-3]
  let l:names = l:parts[-2:]

  let l:path = map(l:path, 'v:val[0]')
  let l:list = l:path + l:names

  return join(l:list, '/')
endfunction

function! StatuslinePath()
  let l:width  = winwidth(0) - 30
  let l:path   = expand('%')
  let l:bufnum = bufnr('%')

  " shorten file path if too long. available space depends on a
  " lot of things, so to keep this function simple let's assume
  " that 'a lot of things' is 30 characters long

  if strlen(l:path) > l:width
    let l:path = <SID>ShortenPath(l:path)

    if strlen(l:path) > l:width
      let l:path = pathshorten(l:path)
    end
  endif
  if getbufvar(l:bufnum, '&modified')
    let l:path .= ' +'
  endif

  if getbufvar(l:bufnum, '&readonly')
    let l:path .= ' ‼'
  endif

  return l:path
endfunction

function! LinterStatus() abort
  let l:info = get(b:, 'coc_diagnostic_info', {})
  let l:msgs = []

  if empty(l:info)
    return ''
  endif

  if get(l:info, 'error', 0)
    call add(l:msgs, '✖ ' . l:info['error'])
  endif

  let l:information = get(l:info, 'information', 0)
  let l:warnings = get(l:info, 'warning', 0)
  let l:total = l:information + l:warnings

  if l:total
    call add(l:msgs, '⚠ ' . l:total)
  endif

  return join(msgs, ' ')
endfunction

" set the statusline format
set statusline=%#LineNr#%{StatuslineColumn()}%*
set statusline+=\ %{StatuslinePath()}

" errors/warnings from the linter
set statusline+=%(\ %{LinterStatus()}\ %)
set statusline+=%*

" ----------------------------------------------------------------------
" REMAPS ---------------------------------------------------------------
" ----------------------------------------------------------------------

inoremap jj <Esc>

" since <C-i> is the same as <Tab>, use <C-p> to
" move forward the jump list (it's near <C-o>)
nnoremap <C-p> <C-i>

" save the jump if large enough
nnoremap <expr> k (v:count > 5 ? "m'" . v:count : '') . 'k'
nnoremap <expr> j (v:count > 5 ? "m'" . v:count : '') . 'j'

" map <Esc> in terminal mode (except when we use fzf)
if has('nvim')
  tnoremap <silent><expr> <Esc> (b:term_title =~# 'bin/fzf' ? '<Esc>' : '<C-\><C-n>')
endif

" to switch splits
nnoremap <Tab> <C-W>w
nnoremap <S-Tab> <C-W>W

" next and previous tab or buffer when no tabs are open
nnoremap <expr> ç tabpagenr('$') == 1 ? ':bprevious<CR>' : ':tabp<CR>'
nnoremap <expr> ° tabpagenr('$') == 1 ? ':bnext<CR>' : ':tabn<CR>'
" even if {} are useful motions, I never use them with the italian
" keyboard, so remap them on the american one.
nnoremap <expr> { tabpagenr('$') == 1 ? ':bprevious<CR>' : ':tabp<CR>'
nnoremap <expr> } tabpagenr('$') == 1 ? ':bnext<CR>' : ':tabn<CR>'
" switch to last visited buffer
nnoremap § :b#<CR>
nnoremap \ :b#<CR>

" use virtual lines
noremap <Down> gj
noremap <Up> gk

" record a macro with "qq" and execute it with "Q"
nnoremap Q @q

" enough is enough
nnoremap ZZ >>

" easier to remember
nnoremap <leader>s z=

" save files owned by root
cmap w!! %!sudo tee > /dev/null %

" can't type <C-]> on the italian keyboard...
autocmd vimrc FileType help
      \ nnoremap <buffer> <CR> <C-]> |
      \ nnoremap <buffer> <BS> <C-T>

" use ":e %%" to insert the current file path
cnoremap <expr> %% getcmdtype() == ':' ? expand('%:h').'/' : '%%'

" use ctrl-v to paste in the command line
cmap <expr> <C-v> getcmdtype() =~ '[/?:]' ? '<C-r>"' : '<C-v>'

" visually select the text that was last edited/pasted
nnoremap <expr> gV '`[' . strpart(getregtype(), 0, 1) . '`]'

" http://stackoverflow.com/questions/5010162
autocmd vimrc VimEnter * noremap Y y$

" like the original *, but don't jump to the next match
function! s:SuperStar()
  let l:w='\<' . expand('<cword>') . '\>'

  call histadd('/', l:w)
  let @/=l:w

  " http://stackoverflow.com/a/3766135
  return ":set hlsearch\<CR>:normal wb\<CR>"
endfunction

nnoremap <expr> * <SID>SuperStar()

" http://stackoverflow.com/questions/1533565
function! s:GetVisualSelection()
  let [ l:lnum1, l:col1 ] = getpos("'<")[1:2]
  let [ l:lnum2, l:col2 ] = getpos("'>")[1:2]
  let l:lines = getline(l:lnum1, l:lnum2)

  let l:last = l:col2 - (&selection == 'inclusive' ? 1 : 2)
  let l:prev = l:col1 - 1

  let l:lines[-1] = l:lines[-1][:l:last]
  let l:lines[0]  = l:lines[0][prev:]

  return join(l:lines, "\n")
endfunction

" search the visually selected block of text
function! s:SearchSelection()
  let l:tmp = <SID>GetVisualSelection()
  let l:tmp = escape(l:tmp, '\"')
  let l:tmp = substitute(l:tmp, '\_s\+$', '\\s\\*', '')
  let l:tmp = substitute(l:tmp, '^\_s\+', '\\s\\*', '')
  let l:tmp = substitute(l:tmp, '\_s\+',  '\\_s\\+', 'g')
  let l:tmp = '\V' . l:tmp
  call histadd('/', l:tmp)
  let @/ = l:tmp
endfunction

xnoremap <silent> <s-n> :call <SID>SearchSelection()<CR><s-n><s-n>
xnoremap <silent> n :call <SID>SearchSelection()<CR>nn

" vp doesn't replace paste buffer
function! RestoreRegister()
  if &clipboard == 'unnamed'
    let @* = s:restore_reg
  elseif &clipboard == 'unnamedplus'
    let @+ = s:restore_reg
  else
    let @" = s:restore_reg
  endif
  return ''
endfunction

function! s:SaveRegister()
  if &clipboard == 'unnamed'
    let s:restore_reg = @*
  elseif &clipboard == 'unnamedplus'
    let s:restore_reg = @+
  else
    let s:restore_reg = @"
  endif
  return "p@=RestoreRegister()\<cr>"
endfunction

xnoremap <silent> <expr> p <SID>SaveRegister()

" ----------------------------------------------------------------------
" WHITE SPACES ---------------------------------------------------------
" ----------------------------------------------------------------------

function! StripTrailingWhitespaces()
  " preparation: save last search
  " and cursor position.
  let l:search = @/
  let l:line = line('.')
  let l:col = col('.')
  " do the business
  %s/\s\+$//e
  " clean up: restore previous search
  " history and cursor position
  let @/=l:search
  call cursor(l:line, l:col)
endfunction

" show tabs and trailing spaces
" ctrl-k >> to insert »
" ctrl-k .M to insert ·
set listchars=tab:»·,trail:·,nbsp:·
set list

" ----------------------------------------------------------------------
" TAB - INDENTING ------------------------------------------------------
" ----------------------------------------------------------------------

" indent/outdent to nearest tabstops
set shiftround

" no real tabs please!
set expandtab

" how many spaces should a tab be
set softtabstop=2
set shiftwidth=2
set tabstop=2

" indend / unindent selected text
xnoremap <S-Tab> <gv
xnoremap <Tab> >gv

" ----------------------------------------------------------------------
" FOLDING --------------------------------------------------------------
" ----------------------------------------------------------------------

set foldlevelstart=99
set foldmethod=syntax
set foldnestmax=16

" http://vim.wikia.com/wiki/Keep_folds_closed_while_inserting_text
" Don't screw up folds when inserting text that might affect them,
" until leaving insert mode. Foldmethod is local to the window.
" Protect against screwing up folding when switching between windows.
autocmd vimrc InsertEnter *
      \ if !exists('w:last_fdm') |
      \   let w:last_fdm = &foldmethod |
      \   setlocal foldmethod=manual |
      \ endif
autocmd vimrc InsertLeave,WinLeave *
      \ if exists('w:last_fdm') |
      \   let &l:foldmethod = w:last_fdm |
      \   unlet w:last_fdm |
      \ endif

function! s:SmartFold()
  if !foldlevel('.')
    return "\<Enter>"
  end

  " the first line of current fold
  let l:foldline = foldclosed('.')

  " close the current fold
  if l:foldline == -1
    return 'zc'
  end

  let l:line = getline(l:foldline)
  " open the current fold only for classes
  " and tests, open recursively everything else
  if l:line =~? '\s*class ' || l:line =~? '\s*describe(\='
    return 'zo'
  endif

  if indent(l:foldline) == 0
    return 'zO'
  endif

  let l:nb   = prevnonblank(l:foldline - 1)
  let l:line = getline(l:nb)

  if l:line =~? '\s*class ' || l:line =~? '\s*describe(\='
    return 'zo'
  else
    return 'zO'
  endif
endfunction

" use enter in normal mode to toggle folding
nnoremap <silent> <expr> <Enter> <SID>SmartFold()

let g:xml_syntax_folding = 1
let g:php_folding = 2

" ----------------------------------------------------------------------
" FILE TYPES -----------------------------------------------------------
" ----------------------------------------------------------------------

function! s:JsFindFile(name)
  if a:name =~ '^\.'
    let l:base = simplify(expand('%:h') . '/' . a:name)
    let l:list = glob(l:base . '.*', 0, 1)
    let l:file = get(l:list, 0, a:name)

    if filereadable(l:file)
      return l:file
    endif

    return a:name
  endif

  " https://damien.pobel.fr/post/configure-neovim-vim-gf-javascript-import/
  let l:nodeModules = './node_modules/' . a:name . '/'
  let l:packagePath = l:nodeModules . 'package.json'

  if filereadable(l:packagePath)
    let l:json = json_decode(join(readfile(l:packagePath)))
    let l:main = get(l:json, 'main', 'index.js')

    return l:nodeModules . l:main
  endif

  return ''
endfunction

function! s:JsGotoFile(split, tab) abort
  let l:name = matchstr(getline('.'), &include)
  let l:file = <SID>JsFindFile(l:name)

  " https://gist.github.com/romainl/2ecbf1aaf60b4c0e2c135569d516fbd8
  if len(l:file) > 1
    let l:cmds = {
          \ "11": "silent tab vsplit ",
          \ "10": "silent vsplit ",
          \ "00": "silent edit "
          \ }

    execute l:cmds[a:split . a:tab] . l:file
    return
  endif

  echohl WarningMsg
  echo "Can't find file " . l:name
  echohl None
endfunction

autocmd vimrc FileType javascript,javascriptreact,typescript,typescriptreact
      \ setlocal include=\\(\\<require\\s*(\\s*\\\|\\<import\\>\\\|\\<export\\>\\)[^;\"']*[\"']\\zs[^\"']* |
      \ nnoremap <silent> <buffer> gf      :call <SID>JsGotoFile(0, 0)<CR>|
      \ nnoremap <silent> <buffer> <C-w>f  :call <SID>JsGotoFile(1, 0)<CR>|
      \ nnoremap <silent> <buffer> <C-w>gf :call <SID>JsGotoFile(1, 1)<CR>|
      \ nmap <buffer> <leader><Space> <Plug>(coc-definition)|
      \ setlocal suffixes=.js,.jsx,.ts,.tsx |
      \ setlocal expandtab textwidth=0 |
      \ setlocal spell spelllang=it,en

autocmd vimrc FileType ruby
      \ setlocal expandtab textwidth=0 |
      \ setlocal spell spelllang=it,en |
      \ setlocal suffixesadd=.rb

autocmd vimrc FileType xml
      \ setlocal foldmethod=syntax |
      \ setlocal foldnestmax=20

autocmd vimrc FileType fish
      \ setlocal formatoptions+=ro |
      \ setlocal iskeyword+=-

" '-' should be part of the word, not a separator
autocmd vimrc FileType css
      \ setlocal iskeyword+=-

autocmd vimrc FileType cucumber
      \ setlocal spell spelllang=it,en |
      \ setlocal textwidth=76

autocmd vimrc FileType markdown
      \ setlocal spell spelllang=it,en

autocmd vimrc Filetype gitcommit
      \ setlocal spell spelllang=it,en |
      \ setlocal textwidth=72

" Syntax highlight HTML code inside PHP strings.
let g:php_htmlInStrings = 1
" Syntax highlight SQL code inside PHP strings.
let g:php_sql_query = 1
" Disable PHP short tags.
let g:php_noShortTags = 1
" indentiamo gli switch come si deve
let g:PHP_vintage_case_default_indent = 1

" remove "$" and "-" for broken js/css/html syntax plugins
" remove ":" as it is considered a separator
autocmd vimrc FileType php
      \ setlocal spell spelllang=it,en |
      \ setlocal commentstring=//\ %s |
      \ setlocal iskeyword-=-,:$

" this should speed up vim a bit with rbenv
if isdirectory($HOME . '/.rbenv')
  let g:ruby_path = $HOME . '/.rbenv/shims'
endif

" ----------------------------------------------------------------------
" SESSION MANAGEMENT ---------------------------------------------------
" ----------------------------------------------------------------------

" creates a session (I don't remember where i stole this)
function! s:MakeSession()
  let b:sessiondir = <SID>getSessionDir()
  if (filewritable(b:sessiondir) != 2)
    exe 'silent !mkdir -p ' b:sessiondir
    redraw!
  endif
  let b:filename = b:sessiondir . '/session.vim'
  exe 'mksession! ' . b:filename
endfunction

" updates a session, BUT ONLY IF IT ALREADY EXISTS
" and we actually loaded it (i.e. we edited a random
" file launching vim from within a dir with a session)
function! s:UpdateSession()
  if s:sessionloaded == 1
    let b:sessiondir = <SID>getSessionDir()
    let b:sessionfile = b:sessiondir . '/session.vim'
    if (filereadable(b:sessionfile))
      exe 'mksession! ' . b:sessionfile
    endif
  endif
endfunction

" loads a session if it exists and we started without arguments
let s:sessionloaded = 0

function! s:LoadSession()
  if argc() == 0
    let b:sessiondir = <SID>getSessionDir()
    let b:sessionfile = b:sessiondir . '/session.vim'
    if (filereadable(b:sessionfile))
      exe 'source ' b:sessionfile
      let s:sessionloaded = 1
    else
      echo 'No session loaded.'
    endif
  else
    let b:sessionfile = ''
    let b:sessiondir = ''
  endif
endfunction

function! s:getSessionDir()
  return expand(g:sessiondir) . getcwd()
endfunction

set sessionoptions=curdir,folds,tabpages

" use this once to create a session. it
" is then loaded and updated automatically
nnoremap <leader>m :call <SID>MakeSession()<CR>

autocmd vimrc VimEnter * nested :call <SID>LoadSession()
autocmd vimrc VimLeave * :call <SID>UpdateSession()
