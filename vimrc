" PRINTER
set pdev=Officejet-6100
set printoptions=paper:A4,syntax:y,wrap:y

" COLORS
colorscheme solarized
set background=dark
syntax enable

" SYNTAX CONTROL
au BufNewFile,BufRead *.frag,*.vert,*.fp,*.vp,*.glsl set syntax=glsl
au BufNewFile,BufRead *.cl setf opencl
au BufNewFile,BufRead *.d set foldmethod=syntax
au BufNewFile,BufRead *.i,*.c set syntax=c|set foldmethod=syntax
au BufNewFile,BufRead *.ii,*.h,*.cpp set syntax=cpp|set foldmethod=syntax
	
" GUI OPTIONS
set guioptions-=T " no toolbar
set guioptions+=LlRrb " no scroll bar
set guioptions-=LlRrb " no scroll bar
set guioptions-=m " no menu

" HIGHLIGHTING
" crosshair
set cursorline
set cursorcolumn
" highlight line with \l
:nnoremap <silent> <Leader>l :exe "let m = matchadd('WildMenu','\\%" . line('.') . "l')"<CR>
" highlight word with \w
:nnoremap <silent> <Leader>w :exe "let m=matchadd('WildMenu','\\<\\w*\\%" . line(".") . "l\\%" . col(".") . "c\\w*\\>')"<CR>
" highlight column with \c
:nnoremap <silent> <Leader>c :exe "let m=matchadd('WildMenu','\\<\\w*\\%" . virtcol(".") . "v\\w*\\>')"<CR>
" clear highlights with \<enter>
:nnoremap <silent> <Leader><CR> :call clearmatches()<CR>

" FONT
set guifont=Monospace\ 10

" VISIBILITY
let g:high_vis = 0
command! Z call ZoomOut()
command! G call ZoomIn()
command! V call ToggleVisibility()
function! ToggleVisibility()
	if g:high_vis == 0
		set guifont=Monospace\ 16
		let g:high_vis = 1
	elseif g:high_vis == 1
		set guifont=Monospace\ 12
		let g:high_vis = 2
	else	
		set guifont=Monospace\ 10
		let g:high_vis = 0
	endif
endfunction
function! ZoomOut()
	set guifont=Monospace\ 8
	let g:high_vis = 2
endfunction
function! ZoomIn()
	set guifont=Monospace\ Bold\ 22
	let g:high_vis = 0
endfunction

" BACKGROUND TOGGLE
let g:bg_color = 0
command! L call ToggleBackground()
function! ToggleBackground()
	if g:bg_color == 1
		set background=dark
		let g:bg_color = 0
	else
		set background=light
		let g:bg_color = 1
	endif
endfunction


" LINES, WHITESPACE, ETC
set nu " number the lines
set autoindent 
set lbr
set wrap
set linebreak
set showbreak=>>>\ \ \ 
set tabstop=4
set shiftwidth=4


" FOLDING
function! MyFoldText()
	let indent_level = indent(v:foldstart)
	let indent_str = repeat(' ', indent_level)
	let no_header = substitute(foldtext(), '[+-]\+\s*[0-9]\+\s*lines:\s','', '')
	return indent_str . no_header
endfunction
set foldtext=MyFoldText()

" accidentally hitting capital letters
command! W write
command! Q quit

" FAST WRAP
command! WR set wrap!

" IN-EDITOR TESTING
au BufNewFile,BufRead *.c,*.cpp command! T call CRunDetailed()
au BufNewFile,BufRead *.c,*.cpp command! F call CRun()

au BufNewFile,BufRead *.d command! T call DUnitTest()
au BufNewFile,BufRead *.d command! F call DRun()

command! I call ShowProjectInfo()
command! D call StartDebugger()

func! ColorLog()
	syn match Comment "[/].*"
	syn match Comment "\({\)\@<=.\{-}\(}\)\@="
	syn match Type "\((\)\@<=[A-Za-z_][A-Za-z0-9_!()\[\], ]\+\()\ {\)\@="
	syn match htmlTagN "\([0-9]\{2}[:]\)\{2}[0-9]\{2}[.][0-9]*"
endfunc


function! DRun()
	execute "wa"
	let log = system ("echo '<<>'; dub;")
	split __COMPILATION_LOG__
	normal! ggdG
	setlocal buftype=nofile
	call append (0, split(log, '\n'))
	call DSyntax ()
endfunction

function! DUnitTest()
	execute "wa"
	let log = system ("echo '<<>'; dub --build=unittest;")
	split __COMPILATION_LOG__
	normal! ggdG
	setlocal buftype=nofile
	call append (0, split(log, '\n'))
	call DSyntax ()
endfunction

function! DSyntax()
	" build messages
	syn region Comment start="[<][<][>]" end="[<][>][>]"
	" errors
	syn match Special ".*[Ee]rror.*" containedin=ALL
	" stack trace
	syn match Underlined "[.]\?[/].\+(.*) \[0x[a-f0-9]\+\]"
	" warnings
	syn match Preproc "\(\w\|\s\)*[Ww]arni.*" containedin=ALL
	" start run
	syn match vimCmdSep "Running\ [.][/]\w\+"
	" deprecation warnings
	syn match Preproc "Deprecation:.*" containedin=Comment
	" line numbers
	syn match CustomLine "\((\)\@<=[0-9]\+\():\)\@=" containedin=Comment
	" linker error
	syn match Special "undefined reference" containedin=Comment
	" shared error
	syn keyword Type shared containedin=ALL
	" translate signal numbers
	execute "0"
	execute "%s/\\(code\ -1\\)/\\1:  SIGHUP/e"
	execute "%s/\\(code\ -2\\)/\\1:  SIGINT/e"
	execute "%s/\\(code\ -3\\)/\\1:  SIGQUIT/e"
	execute "%s/\\(code\ -5\\)/\\1:  SIGTRAP/e"
	execute "%s/\\(code\ -6\\)/\\1:  SIGABRT/e"
	execute "%s/\\(code\ -8\\)/\\1:  SIGFPE/e"
	execute "%s/\\(code\ -9\\)/\\1:  SIGKILL/e"
	execute "%s/\\(code\ -11\\)/\\1: SIGSEGV/e"
	execute "%s/\\(code\ -14\\)/\\1: SIGALRM/e"
	execute "%s/\\(code\ -15\\)/\\1: SIGTERM/e"
endfunction

function! CRun()
	execute "wa"
	! ./test.sh;
endfunction

function! CRunDetailed()
	execute "wa"
	let log = system ("./test.sh;")
	split __COMPILATION_LOG__
	normal! ggdG
	setlocal buftype=nofile
	syn match vimCmdSep "COMPILE SUCCESS!"
	syn match Error "COMPILE FAILED!"
	syn match Comment "^\([.][/]\|[/]\).*"
	syn match htmlTagN "\([a-z][:]\)\@<=[0-9]\+" containedin=Comment
	syn keyword Error error containedin=Comment
	syn keyword Preproc warning containedin=Comment
	syn keyword Identifier note containedin=Comment
	" jebus save me from c++ template error messages
	syn match Error "^\s*^\s*$" containedin=Comment
	syn match Type "required from \(here\)*" containedin=Comment
	syn match Type "In instantiation of" containedin=Comment
	syn match Special "\(could not\|cannot\) convert" containedin=Comment
	syn match Special "no known conversion" containedin=Comment
	syn match Special "undefined reference.*" containedin=Comment
	syn match Special "no matching function for call" containedin=Comment
	syn match Type "In function.*:" containedin=Comment
	syn match Special "\(conversion\|non-scalar type\|requested\)" containedin=Comment
	syn keyword Type from to containedin=Comment
	call append (0, split(log, '\n'))
	execute "0"
endfunction

function! ShowProjectInfo()
	execute "wa"
	let log = system ("./info.sh;")
	split __INFORMATION__
	normal! ggdG
	set syntax=d
	set nofoldenable
	syn match Comment "^.\{-}[:][0-9]\+[:]"
	setlocal buftype=nofile
	call append (0, split(log, '\n'))
	execute "0"
endfunction

let g:debugging = 0
function! StartDebugger()
	execute "wa"
	! ./test.sh -c;
	if g:debugging == 0
		execute "Pyclewn"
		let g:debugging = 1
	endif
	"bug: this assumes the file name is a.out. how to autodetect?
	execute "Cfile a.out"
endfunction

" MACROS
" create fancy block
let @f = 'o{}€kl€K8€K9€K9€K8€kl€kl...}€kr€krzc>>zoo	' 
" collapse fancy brace into single line
let @r = 'k0f{lDa€kD€krdwA €kDdw' 
" convert camelCase to underscores
let @u = 'vaw:s/[a-z]-€kb[€kb€kl€kl€kl€kl€kl\(€kr€kr€kr€kr€kr\)\([A-Z]\)/\1_\L\2/g' 
" convert from underscores to camelCase
let @c = 'vaw:s/_\(\_€kb)€kl€kl.€kr€kr/€kl€kl€kl€kb[a-z]€kr€kr€kr\U\1/g' 
" natural numbers
let @n = 'au2115'
" create section
let @s = 'A {€K8€K9}€K9€K8}€kuf}h'
" create mixin block
let @m = 'amixin(q{});O	'

" DEBUGGER MOVEMENTS
map <F3> :C bt <CR>
map <F4> :C s <CR>
map <F5> :C n <CR>
function! GDBPrint (arg)
	execute "C p " a:arg
endfunction
function! GDBRun ()
	execute "C r"
endfunction
function! GDBBreak (arg)
	execute "C b " a:arg
endfunction
function! GDBBackTrace ()
	execute "C bt"
endfunction
command! -nargs=1 P call GDBPrint (<f-args>)
command! R call GDBRun ()
command! -nargs=1 B call GDBBreak (<f-args>)
command! BT call GDBBackTrace ()
