"AUTHOR:   Atsushi Mizoue <asionfb@gmail.com>
"WEBSITE:  https://github.com/AtsushiM/jasmine-helper.vim
"VERSION:  0.1
"LICENSE:  MIT

let s:save_cpo = &cpo
set cpo&vim

function! jasminehelper#dirCheck(target)
    let i = 0
    let dir = expand('%:p:h').'/'
    let flg = 0

    while i < 5
        if !isdirectory(dir.'/'.a:target)
            let dir = dir.'../'
        else
            let flg = 1
            break
        endif

        let i = i + 1
    endwhile

    if flg == 0
        let dir = ''
    endif

    return dir
endfunction

function! jasminehelper#JasmineSpecCopy()
    let createspec = getcwd().'/spec'

    if isdirectory(createspec)
        echo 'already spec init.'
        return
    endif

    let cmd = 'cp -r '.g:jasmine_helper_dir_spec_dir.' '.createspec
    call system(cmd)
    echo cmd
endfunction

function! jasminehelper#JasmineInit()
    let dir = jasminehelper#dirCheck('js')

    if dir == ''
        echo 'not find "js" directory.'
        return
    endif

    let orgdir = expand('%:p:h').'/'

    exec 'silent cd '.dir
    call jasminehelper#JasmineSpecCopy()
    exec 'silent cd '.orgdir
endfunction

function! jasminehelper#JasmineClassNameReplace(className)
    let orgdir = getcwd()
    if !isdirectory(a:className)
        echo 'not find "'.a:className.'" directory.'
        return
    endif

    exec 'silent cd '.a:className

    let classNameLow = tolower(a:className)
    let check = split(classNameLow, '\.')
    if len(check) != 1
        let classNameLow = check[len(check) - 1]
    endif

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
endfunction

function! jasminehelper#JasmineListUpJS()
    let orgdir = expand('%:p:h')
    let dir = jasminehelper#dirCheck('spec')

    if dir == ''
        echo 'not found "spec" directory.'
        return
    endif

    let dir = dir.'spec/_src'

    exec 'silent cd '.dir

    let list = split(substitute("".system('ls -F | grep /'), "\n", "", 'g'), '/')

    let listBase = []
    let listClass = []
    let listTest = []
    let testFile = []
    let testPath = []
    for listi in list
        if listi != '_template'
            let listBase = add(listBase, listi.'\n\')
            let listTest = add(listTest, '../_src/'.listi.'/test.js'.'\n\')

            let testFile = readfile(listi.'/test.js')
            let testPath = matchlist(testFile[0], '\v(.{-})"(.{-})"(.*)')
            let listClass = add(listClass, testPath[2].'\n\')
        endif
    endfor

    let listBase = extend(extend(['<script type="template" id="jasmineBaseList">\'], listBase), ['</script>\'])
    let listClass = extend(extend(['<script type="template" id="jasmineClassList">\'], listClass), ['</script>\'])
    let listTest = extend(extend(['<script type="template" id="jasmineTestList">\'], listTest), ['</script>\'])
    call writefile(extend(extend(['document.write(''\'],extend(listBase, extend(listClass, listTest))), ["');"]), '../list.js')

    exec 'silent cd '.orgdir
endfunction

function! jasminehelper#JasmineAdd(...)
    let dir = jasminehelper#dirCheck('spec')

    if dir == ''
        echo 'no find "spec" directory.'
        return
    endif

    let dir = dir.'spec/_src'
    let cmd1 = 'cp -r _template '
    let cmd2 = 'rm -rf '
    let makename = expand('%:r')

    if a:0 != 0
        let makename = a:000[0]
    endif

    if makename == ''
        echo 'no target dircotry.'
        return
    endif

    if isdirectory(makename)
        echo 'already maked "'.makename.'" directory.'
        return
    endif

    let cmd1 = cmd1.makename
    let cmd2 = cmd2.makename.'/.*'
    let orgdir = expand('%:p:h').'/'

    exec 'silent cd '.dir

    call system(cmd1)
    call system(cmd2)

    call jasminehelper#JasmineClassNameReplace(makename)

    exec 'vs '.makename.'/test.js'

    call jasminehelper#JasmineListUpJS()

    exec 'silent cd '.orgdir
endfunction

function! jasminehelper#JasmineTemplate()
    let dir = jasminehelper#dirCheck('spec')
    let tempdir = dir.'spec/src/_template'

    if dir == '' || !isdirectory(tempdir)
        echo 'not find "'.tempdir.'" directory'
        return
    endif

    exec 'e '.tempdir.'/test.js'
endfunction

let &cpo = s:save_cpo
