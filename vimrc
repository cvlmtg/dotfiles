if !has('nvim')
  set nocompatible
endif

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

if has('nvim')
  set clipboard+=unnamedplus
else
  " use the system clipboard (on osx/tmux this doesn't work)
  if !(has('mac') && exists('$TMUX'))
      set clipboard=unnamed,unnamedplus
  endif
endif

" disable the magic "vim: .." lines in files
set nomodeline

" we like to keep all swap files in the same directory, but when you
" open two files with the same name and then try to recover from a
" power cord unplugged by mistake, big problems may arise, so let's
" try to live without them
set noswapfile

if !has('nvim')
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

let &g:spellfile = s:base . '/spell/it.utf8.add'
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
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin()

Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'prabirshrestha/asyncomplete-buffer.vim'
Plug 'prabirshrestha/asyncomplete-lsp.vim'
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'yami-beta/asyncomplete-omni.vim'
Plug 'prabirshrestha/async.vim'
Plug 'prabirshrestha/vim-lsp'
Plug 'junegunn/fzf.vim'

Plug 'craigemery/vim-autotag'
Plug 'airblade/vim-gitgutter'
Plug 'itchyny/vim-gitbranch'
Plug 'mbbill/undotree'
Plug 'dyng/ctrlsf.vim'

Plug 'michaeljsmith/vim-indent-object'
Plug 'junegunn/vim-easy-align'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'
Plug 'wellle/targets.vim'
Plug 'tpope/vim-repeat'
Plug 'sareyko/neat.vim', { 'on': 'Neat' }
Plug 'w0rp/ale'

Plug 'mustache/vim-mustache-handlebars'
Plug 'MaxMEllon/vim-jsx-pretty'
Plug 'kchmck/vim-coffee-script'
Plug 'pangloss/vim-javascript'
Plug 'groenewege/vim-less'
Plug 'mtscout6/vim-cjsx'
Plug 'dag/vim-fish'

Plug 'altercation/vim-colors-solarized'
Plug 'cvlmtg/vim-256noir'
Plug 'morhetz/gruvbox'

call plug#end()

" load matchit.vim, but only if the user hasn't installed a newer version
if !exists('g:loaded_matchit') && findfile('plugin/matchit.vim', &rtp) ==# ''
    runtime! macros/matchit.vim
endif

" neat -----------------------------------------------------------------
" brew install html-xml-utils

let neat#html#commands = [ ':% !hxnormalize -x' ]

" ctrlsf ---------------------------------------------------------------

let g:ctrlsf_regex_pattern = 1
let g:ctrlsf_winsize = '30%'
let g:ctrlsf_auto_close = 0

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
nmap <leader>a <Plug>CtrlSFCCwordPath<CR>

" ale ------------------------------------------------------------------

let g:ale_statusline_format = [ '✖ %d', '⚠ %d', '' ]
let g:ale_sign_warning = '⚠'
let g:ale_sign_error = '✖'

let g:ale_linters = {
      \   'javascript': [ 'eslint' ],
      \ }

" toggle location list to see linting errors
nmap <leader>l :lwindow<CR>

" move between linting errors
nmap <silent> <C-k> <Plug>(ale_previous_wrap)
nmap <silent> <C-j> <Plug>(ale_next_wrap)

" fzf ------------------------------------------------------------------

set wildignore+=*/tmp/*,*/cache/*,*/node_modules/*,*/vendor/*

let g:fzf_command_prefix = 'Fzf'

nnoremap <leader><Space> :<C-u>LspDefinition<CR>
nnoremap <leader>b :<C-u>FzfBuffers<CR>
nnoremap <leader>f :<C-u>FzfGitFiles<CR>

" complete -------------------------------------------------------------

let g:asyncomplete_remove_duplicates = 1
let g:asyncomplete_auto_popup = 0
let g:lsp_async_completion = 1
let g:lsp_log_file = ''

call asyncomplete#register_source(asyncomplete#sources#buffer#get_source_options({
      \ 'name': 'buffer',
      \ 'whitelist': ['*'],
      \ 'blacklist': ['go'],
      \ 'completor': function('asyncomplete#sources#buffer#completor'),
      \ }))

call asyncomplete#register_source(asyncomplete#sources#omni#get_source_options({
      \ 'name': 'omni',
      \ 'whitelist': ['*'],
      \ 'blacklist': ['html'],
      \ 'completor': function('asyncomplete#sources#omni#completor')
      \  }))

" npm install -g typescript-language-server

if executable('typescript-language-server')
  call lsp#register_server({
        \ 'name': 'typescript-language-server',
        \ 'cmd': { server_info->[&shell, &shellcmdflag, 'typescript-language-server --stdio']},
        \ 'root_uri': { server_info->lsp#utils#path_to_uri(lsp#utils#find_nearest_parent_directory(lsp#utils#get_buffer_path(), '.git/..'))},
        \ 'whitelist': ['typescript', 'javascript', 'javascript.jsx']
        \ })
endif

" <CR>: close popup and save indent.
function! s:smartCr()
  if !pumvisible()
    return "\<CR>"
  end

  return "\<C-y>"
endfunction
inoremap <silent> <CR> <C-r>=<SID>smartCr()<CR>

function! s:smartTab()
    if pumvisible()
      return "\<C-n>"
    endif

    let l:line = getline('.')
    let l:col = col('.') - 2

    " trigger the autocomplete only if the
    " character before the cursor is not a space
    if strcharpart(l:line, l:col, 1) =~ '^\s\=$'
      return "\<Tab>"
    endif

    return asyncomplete#force_refresh()
endfunction
inoremap <silent> <Tab> <C-r>=<SID>smartTab()<CR>
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

" close popup with <space>
imap <expr> <Space> pumvisible() ? "\<C-y>\<Space>" : "\<Space>"

" easy align -----------------------------------------------------------

vmap <Enter> <Plug>(EasyAlign)

" undotree -------------------------------------------------------------

nnoremap <leader>u :UndotreeToggle<CR>
let g:undotree_WindowLayout = 2

" gitgutter ------------------------------------------------------------

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

" show available completions
set wildmode=longest,full

" keep more context when scrolling off the end of a buffer
set scrolljump=3
set scrolloff=3

" show matching brackets
set showmatch

" set codes for 24bit term colors
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"

" change cursor shape in insert mode
if !has('nvim')
  if exists('$TMUX')
    let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
    let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"
  else
    let &t_SI = "\<Esc>]50;CursorShape=1\x7"
    let &t_EI = "\<Esc>]50;CursorShape=0\x7"
  endif
end

if has('gui_running')
    set guicursor+=a:blinkon0 " disable cursor blinking
    set guioptions-=e         " textual tabs in gui mode
    set guioptions-=T         " do not show the toolbar
    set guioptions-=r         " do not show the scrollbars
    set guioptions-=m         " remove menu bar
    set guioptions-=L
    set lines=52 columns=84

    " in fullscreen maximize columns and rows
    set guifont=DejaVu\ Sans\ Mono:h12
    set fuopt=maxvert,maxhorz
endif

let g:solarized_termcolors=256
let g:solarized_underline=0

let g:gruvbox_contrast_dark='hard'
let g:gruvbox_sign_column='dark0'
let g:gruvbox_italic=0

let s:colorscheme='256_noir'

if s:colorscheme == 'solarized'
    set background=light
else
    set background=dark
endif

set cursorline

if !has("gui_vimr")
  exe 'colorscheme ' . s:colorscheme
else
  colorscheme gruvbox
endif

" customize spelling colors to avoid unreadable
" combinations of background and foreground
highlight clear SpellBad
highlight SpellBad term=standout,underline ctermfg=1 cterm=underline
highlight clear SpellCap
highlight SpellCap term=underline cterm=underline
highlight clear SpellRare
highlight SpellRare term=underline cterm=underline
highlight clear SpellLocal
highlight SpellLocal term=underline cterm=underline

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

    " no idea if there's a faster alternative
    redir => l:signlist
    silent! execute 'sign place buffer='. bufnr('%')
    redir END
    if strlen(l:signlist) > 18
        let l:padding += 2
    endif

    if l:padding > 0
        " + 1 becuase for some reason vim eats one of the spaces
        let l:column .= repeat(' ', l:padding + 1) . l:vc
    else
        let l:column .= l:vc
    endif

    return l:column . ' '
endfunction

function! s:ShortenPath(path, everything)
  if a:everything == 1
    return substitute(a:path, '\(\w\)\%([-.]\|\w\)\+/', '\1/', 'g')
  end

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
    let l:width  = winwidth(0) - 50
    let l:path   = expand('%')
    let l:bufnum = bufnr('%')

    " shorten file path if too long. available space depends on a
    " lot of things, so to keep this function simple let's assume
    " that 'a lot of things' is 50 characters long
    if strlen(l:path) > l:width
        let l:path = <SID>ShortenPath(l:path, 0)

        if strlen(l:path) > l:width
          let l:path = <SID>ShortenPath(l:path, 1)
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

function! StatuslinePaste()
    if exists('g:actual_curbuf') && g:actual_curbuf == bufnr('%') && &paste
        return 'P'
    endif

    return ''
endfunction

function! StatuslineBranch()
    let l:branch = gitbranch#name()

    if !empty(l:branch)
        let l:branch = <SID>ShortenPath(l:branch, 1)
        let l:branch = ' ⎇  ' . l:branch
    endif
    return l:branch
endfunction

" set the statusline format
set statusline=%#LineNr#%{StatuslineColumn()}%*
set statusline+=\ %{StatuslinePath()}

" paste mode and errors/warnings from the linter
set statusline+=\ %#IncSearch#%{StatuslinePaste()}
set statusline+=%(\ %{ALEGetStatusLine()}\ %)
set statusline+=%*

" right side
set statusline+=%=

set statusline+=%{StatuslineBranch()}
" file format and file type
set statusline+=\ \|\ %{&ff}\ 

" ----------------------------------------------------------------------
" REMAPS ---------------------------------------------------------------
" ----------------------------------------------------------------------

inoremap jj <Esc>

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
" american keyboards. even if {} are useful motions, I never
" use them with the italian keyboard, so remap them on the
" american one.
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
    let [l:lnum1, l:col1] = getpos("'<")[1:2]
    let [l:lnum2, l:col2] = getpos("'>")[1:2]
    let l:lines = getline(l:lnum1, l:lnum2)
    let l:lines[-1] = l:lines[-1][: l:col2 - (&selection == 'inclusive' ? 1 : 2)]
    let l:lines[0] = l:lines[0][l:col1 - 1 :]
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
    let s:restore_reg = @"
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
set foldnestmax=8

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

" use space in normal mode to toggle folding
nnoremap <silent> <expr> <Enter> <SID>SmartFold()

let g:xml_syntax_folding = 1
let g:javaScript_fold = 1
let g:php_folding = 2

" ----------------------------------------------------------------------
" FILE FORMATS ---------------------------------------------------------
" ----------------------------------------------------------------------

" this should speed up vim a bit with rbenv
if isdirectory($HOME . '/.rbenv')
    let g:ruby_path = $HOME . '/.rbenv/shims'
endif

autocmd vimrc FileType ruby
            \ setlocal expandtab textwidth=0 |
            \ setlocal spell spelllang=it,en

autocmd vimrc FileType xml
            \ setlocal foldmethod=syntax |
            \ setlocal foldnestmax=20

autocmd vimrc FileType fish
            \ setlocal formatoptions+=ro |
            \ setlocal iskeyword+=-

" '-' should be part of the word, not a separator
autocmd vimrc FileType css
            \ setlocal iskeyword+=-

" write C123 to jump to line 123 of the compiled js
autocmd vimrc FileType coffee
            \ command! -nargs=1 C CoffeeCompile | :<args>

autocmd vimrc FileType coffee
            \ setlocal expandtab textwidth=0 |
            \ setlocal spell spelllang=it,en |
            \ setlocal foldmethod=indent

autocmd vimrc FileType javascript
            \ setlocal expandtab textwidth=0 |
            \ setlocal spell spelllang=it,en

" under linux we need to specify "spellfile" because
" usually /usr/local/share is not writable
autocmd vimrc FileType cucumber
            \ setlocal spell spelllang=it,en |
            \ setlocal textwidth=76

autocmd vimrc Filetype gitcommit
            \ let &l:spellfile=s:base.'/spell/it.utf8.add' |
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
            \ setlocal iskeyword-=-,:$ |
            \ setlocal foldnestmax=2

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

function! s:GetCurrentGitBranch()
    " http://stackoverflow.com/questions/2863756
    let l:branch = <SID>sub(system('git rev-parse --abbrev-ref HEAD 2> /dev/null'), '\n$', '')
    if empty(l:branch)
        return ''
    endif
    return l:branch
endfunction

function! s:sub(str, pat, rep)
    " borrowed from fugitive.vim by tpope
    return substitute(a:str, '\v\C' . a:pat, a:rep, '')
endfunction

function! s:getSessionDir()
    let l:branch = <SID>GetCurrentGitBranch()
    let l:sessiondir = expand(g:sessiondir) . getcwd() . '/' . l:branch
    return l:sessiondir
endfunction

set sessionoptions=curdir,folds,tabpages

" use this once to create a session. it
" is then loaded and updated automatically
nnoremap <leader>m :call <SID>MakeSession()<CR>

autocmd vimrc VimEnter * nested :call <SID>LoadSession()
autocmd vimrc VimLeave * :call <SID>UpdateSession()

" save and restore cursor position on file load
function! s:ResCur()
    if line("'\"") <= line('$')
        normal! g`"
        return 1
    endif
endfunction

autocmd vimrc BufReadPost * call s:ResCur()
