"AUTHOR:   Atsushi Mizoue <asionfb@gmail.com>
"WEBSITE:  https://github.com/AtsushiM/jasmine-helper.vim
"VERSION:  0.1
"LICENSE:  MIT

" if !executable('sass')
"     echohl ErrorMsg
"     echo 'requires sass.'
"     echohl None
"     finish
" endif

if exists("g:loaded_jasmine_helper")
    finish
endif

let g:loaded_jasmine_helper = 1

let s:save_cpo = &cpo
set cpo&vim

let g:jasmine_helper_dir = expand('<sfile>:p:h:h').'/'
let g:jasmine_helper_dir_spec_dir = g:jasmine_helper_dir.'spec/'
let g:jasmine_helper_dir_spec_template_dir = g:jasmine_helper_spec_dir.'_template/'

if !exists("g:jasmine_helper_src_js_dirname")
    let g:jasmine_helper_src_js_dirname = 'js'
endif
if !exists("g:jasmine_helper_test_js_dirname")
    let g:jasmine_helper_test_js_dirname = 'spec'
endif

command! JasmineInit call jasminehelper#JasmineInit()
command! -nargs=* JasmineAdd call jasminehelper#JasmineAdd(<f-args>)
command! JasmineTemplate call jasminehelper#JasmineTemplate()
command! JasmineListUpJS call jasminehelper#JasmineListUpJS()

let &cpo = s:save_cpo
