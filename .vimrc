syntax enable

set autoindent
set backspace=indent,eol,start
set clipboard=unnamed,unnamedplus
set expandtab
set hlsearch
set incsearch
set mouse=a
set nocompatible
set number
set ruler
set smartindent
set shiftwidth=4
set tabstop=4
set title

set nobackup
set noswapfile

:command Id :set autoindent | :set smartindent
:command Noid :set noautoindent | :set nosmartindent

" Split
nnoremap sp :<C-u>sp<CR>
nnoremap sv :<C-w>vs<CR>
nnoremap sj <C-w>j
nnoremap sk <C-w>k
nnoremap sl <C-w>l
nnoremap sh <C-w>h

if has("unix")
    " IME auto turnoff
    set iminsert=0
    set imsearch=0
    set imcmdline
    set imactivatefunc=ImActivate
    function! ImActivate(active)
        if a:active
            call system('fcitx-remote -c')
        else
            call system('fcitx-remote -o')
        endif
    endfunction
    set imstatusfunc=ImStatus
    function! ImStatus()
        return system('fcitx-remote')[0] is# '2'
    endfunction

    function! ImInActivate()
      call system('fcitx-remote -c')
    endfunction
    inoremap <silent> <C-[> <ESC>:call ImInActivate()<CR>
endif

" expandtab
let _curfile=expand("%:r")
if _curfile == 'Makefile'
    set noexpandtab
endif

:autocmd BufEnter *.go setlocal noexpandtab
:autocmd BufEnter *.go2 setlocal noexpandtab
:autocmd BufReadPost *.go2 set syntax=go

" C/C++
autocmd BufRead,BufNewFile *.c,*.cpp,*.h,*.hpp set ts=8 sw=8 cindent noexpandtab
