"AUTHOR:   Atsushi Mizoue <asionfb@gmail.com>
"WEBSITE:  https://github.com/AtsushiM/jasmine-helper.vim
"VERSION:  0.1
"LICENSE:  MIT

let s:save_cpo = &cpo
set cpo&vim

function! jasminehelper#dirCheck(target)
    let i = 0
    let dir = getcwd().'/'

    while i < 5
        if !isdirectory(dir.'/'.a:target)
            let dir = dir.'../'
        else
            break
        endif

        let i = i + 1
    endwhile

    return dir
endfunction

function! jasminehelper#JasmineSpecCopy()
    let createspec = getcwd().'/spec'
    if !isdirectory(createspec)
        let cmd = 'cp -r '.g:jasmine_helper_dir_spec_dir.' '.createspec
        call system(cmd)
        echo cmd
    else
        echo 'already spec init.'
    endif
endfunction

function! jasminehelper#JasmineInit()
    let dir = jasminehelper#dirCheck('js')

    if dir != ''
        let orgdir = getcwd().'/'

        exec 'silent cd '.dir
        call jasminehelper#JasmineSpecCopy()
        exec 'silent cd '.orgdir
    else
        echo 'not find "js" directory.'
    endif
endfunction

function! jasminehelper#JasmineClassNameReplace(className)
    let orgdir = getcwd()
    if isdirectory(a:className)
        exec 'silent cd '.a:className

        let classNameLow = tolower(a:className)
        let targets = ['index.html', 'test.js']

        for i in targets
            let target = readfile(i)
            let target_replace = []

            for target_i in target
                let target_i = substitute(target_i, '%CLASS%', a:className, 'g')
                let target_i = substitute(target_i, '%CLASS_LOW%', classNameLow, 'g')
                let target_replace = add(target_replace, target_i)
            endfor

            call writefile(target_replace, i)
        endfor

        exec 'silent cd '.orgdir
    else
        echo 'not find "'.a:className.'" directory.'
    endif
endfunction

function! jasminehelper#JasmineAdd(...)
    let dir = jasminehelper#dirCheck('spec')

    if dir != ''
        let dir = dir.'spec/'
        let cmd = 'cp -r _template '
        let makename = expand('%:r')

        if a:0 != 0
            let makename = a:000[0]
        endif

        if makename != ''
            let cmd = cmd.makename
        else
            echo 'no target dircotry.'
            finish
        endif

        let orgdir = getcwd().'/'

        exec 'silent cd '.dir

        if !isdirectory(makename)
            call system(cmd)
            echo cmd

            call jasminehelper#JasmineClassNameReplace(makename)
        else
            echo 'already maked "'.makename.'" directory.'
        endif

        exec 'silent cd '.orgdir

    else
        echo 'no find "spec" directory.'
    endif
endfunction

function! jasminehelper#JasmineTemplate()
    let dir = jasminehelper#dirCheck('spec')
    let tempdir = dir.'spec/_template'

    if dir != '' && isdirectory(tempdir)
        exec 'e '.tempdir.'/test.js'
    else
        echo 'not find "'.tempdir.'" directory'
    endif
endfunction

let &cpo = s:save_cpo
