call pathogen#infect()
call pathogen#helptags()

set nocompatible
filetype plugin on
" allow backspacing over everything in insert mode
set backspace=indent,eol,start
set nobackup            " DON'T keep a backup file
set history=50          " keep 50 lines of command line history
set ruler               " show the cursor position all the time
set showcmd             " display incomplete commands
set incsearch           " do incremental searching
set hlsearch            " hilight search
set expandtab           " insert spaces instead of tabs
set tabstop=2
set number              " line numbers
set cindent
set autoindent
set mouse=a             " use mouse in xterm to scroll
set scrolloff=5         " 5 lines bevore and after the current line when scrolling
set ignorecase          " ignore case
set smartcase           " but don't ignore it, when search string contains uppercase letters
set hid                 " allow switching buffers, which have unsaved changes
set shiftwidth=2        " 2 characters for indenting
set showmatch           " showmatch: Show the matching bracket for the last ')'?
set nowrap              " don't wrap by default
set completeopt=menu,longest,preview
set confirm
set vb t_vb=            " disable beep
set ai
syn on
colorscheme elflord
if has("mac") || has("macunix")
    set lines=49
    set columns=90
    set guifont=Courier_New_Bold:h12
endif

" Protect large files from sourcing and other overhead.
" Files become read only
if !exists("my_auto_commands_loaded")
  let my_auto_commands_loaded = 1
  " Large files are > 10M
  " Set options:
  " eventignore+=FileType (no syntax highlighting etc
  " assumes FileType always on)
  " noswapfile (save copy of file)
  " bufhidden=unload (save memory when other file is viewed)
  " buftype=nowritefile (is read-only)
  " undolevels=-1 (no undo possible)
  let g:LargeFile = 1024 * 1024 * 10
  augroup LargeFile
    autocmd BufReadPre * let f=expand("<afile>") | if getfsize(f) > g:LargeFile | set eventignore+=FileType | setlocal noswapfile bufhidden=unload buftype=nowrite undolevels=-1 | else | set eventignore-=FileType | endif
    augroup END
  endif
""""""""""""""""""""""""""""""""""" Commands """""""""""""""""""""""""""""""""""
" Delete all buffers
com! Bdall bufdo bd
com! Bd call Closebufferkeeptab()
com! Be call Closebufferopendir()

""""""""""""""""""""""""""""""""""" Mappings """""""""""""""""""""""""""""""""""
"MOVEMENT
"--------
" Go to previous/next buffer with Alt-< and Alt-> respectively (angle bracket)
map ¼ :bp <CR>
map ¾ :bn <CR>
" Go to previous/next tab with Shift-left/right arrow respectively
map <S-Right> :tabnext <CR>
map <S-Left> :tabprev <CR>
" Map Ctrl-j,k for page up/down
nmap <C-J> <C-F>
nmap <C-K> <C-B>

"BUFFERS
"-------
" Delete all buffers (Maps Bdall)
map ,bda :Bdall <CR>
" Show current directory
map ,dir :echo expand("%:p:h") <CR>

"EDIT
"----
" Insert a line below the current line
map ,o :a<CR><CR>.<CR>
" Insert a line above the current line
map ,O :i<CR><CR>.<CR>

" Replace word under cursor with default register
map ,r "_cw<ESC>p

"PLUGINS
"-------
"NERDTree
nmap <silent> <Leader>p :NERDTreeToggle<CR>

" NERDCommenter Command-/ to toggle comments
map <D-/> <plug>NERDCommenterToggle<CR>
imap <D-/> <Esc><plug>NERDCommenterToggle<CR>i

""""""""""""""""""""""""""""""""" Autocommands """""""""""""""""""""""""""""""""
" Change the directory where buffer is located
autocmd BufEnter * cd %:p:h
autocmd FileType javascript set omnifunc=javascriptcomplete#CompleteJS
autocmd FileType html set omnifunc=htmlcomplete#CompleteTags
autocmd FileType css set omnifunc=csscomplete#CompleteCSS

" HTML (tab width 2 chr, no wrapping)
autocmd FileType html set sw=2
autocmd FileType html set ts=2
autocmd FileType html set sts=2
autocmd FileType html set textwidth=0
" XHTML (tab width 2 chr, no wrapping)
autocmd FileType xhtml set sw=2
autocmd FileType xhtml set ts=2
autocmd FileType xhtml set sts=2
autocmd FileType xhtml set textwidth=0
" CSS (tab width 2 chr, wrap at 79th char)
autocmd FileType css set sw=2
autocmd FileType css set ts=2
autocmd FileType css set sts=2

"""""""""""""""""""""""""""""""""" Functions """""""""""""""""""""""""""""""""""
set diffexpr=MyDiff()
function! MyDiff()
    let opt = ""
    if &diffopt =~ "icase"
     let opt = opt . "-i "
    endif
    if &diffopt =~ "iwhite"
     let opt = opt . "-b "
    endif

    let commandpath = ""

    if has("win32") || has("win16")
       let commandpath = "C:\\_vim\\vim71\\diff"
    elseif has("mac") || has("macunix") || has("unix")
       let commandpath = "/usr/bin/diff"
    elseif has("win32unix")
       let commandpath = "C:\\cygwin\\bin\\diff"
    else
        echo "Unknown version of OS"
        break
    endif

    silent execute "!" . commandpath . " -a " . opt . v:fname_in 
    \ . " " . v:fname_new . " > " . v:fname_out
endfunction

set patchexpr=MyPatch()
function! MyPatch()
    let commandpath = ""

    if has("win32") || has("win16")
       let commandpath = "E:\\vim\\vim71\\patch"
    elseif has("mac") || has("macunix") || has("unix")
       let commandpath = "/usr/bin/patch"
    elseif has("win32unix")
       let commandpath = "E:\\cygwin\\bin\\patch"
    else
        echo "Unknown version of OS"
        break
    endif

    silent execute "!" . commandpath . " -o " . v:fname_out . " "
    \ . v:fname_in " < " . v:fname_diff
endfunction

function! Gotononamebuffer()
    for i in range(tabpagenr('$'))
        buflist = tabpagebuflist(i+1)
        for buf in buflist
            if bufname(buf) == "" && bufexists(buf)
                b buf
                break
            endif
        endfor
    endfor
    enew
endfunction

" Closing the buffer while keeping tab
function! Closebufferkeeptab()
    let numwin = winnr('$')

    " More than one window
    if numwin != 1
        bd
    else
        call Gotononamebuffer()
        bd #
    endif 
endfunction

" Opens current directory view then deletes the last buffer
function! Closebufferopendir()
    call Closebufferkeeptab()
    e .
endfunction
"------------------------------------------------------------------------------"
"                              JAVA DEVELOPMENT                                "
"------------------------------------------------------------------------------"
""""""""""""""""""""""""""""""" Code Completion """"""""""""""""""""""""""""""""
set complete=],.,b,w,t,k
if has("win32") || has("win16") || has("win32unix")
    set dictionary=C:\\_vim\_vimKeywords
elseif has("mac") || has("macunix") || has("unix")
    set dictionary=~/.vimKeywords
endif

" Set up tab for code completion
inoremap  =InsertTabWrapper ("forward")
inoremap =InsertTabWrapper ("backward")

function! InsertTabWrapper(direction)
  let col = col('.') - 1
  if !col || getline('.')[col - 1] !~ '\k'
    return "\"
  elseif "backward" == a:direction
    return "\"
  else
    return "\"
  endif
endfunction
"------------------------------------------------------------------------------"
"                     END OF SECTION FOR JAVA DEVELOPEMNT                      "
"------------------------------------------------------------------------------"
