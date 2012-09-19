"AUTHOR:   Atsushi Mizoue <asionfb@gmail.com>
"WEBSITE:  https://github.com/AtsushiM/jasmine-helper.vim
"VERSION:  0.1
"LICENSE:  MIT

let s:save_cpo = &cpo
set cpo&vim

function! jasminehelper#removePathDot(path)
    let pathary = split(a:path, '/', 1)
    let retary = []

    for i in pathary
        if i != '..'
            let retary = add(retary, i)
        else
            unlet retary[-1]
        endif
    endfor

    let path = join(retary, '/')

    return path
endfunction

function! jasminehelper#dirCheck(target)
    let i = 0
    let dir = expand('%:p:h').'/'
    let flg = 0

    while i < 10
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

function! jasminehelper#relativePath(base, target)
    let baseAry = split(a:base, '/')
    let targetAry = split(a:target, '/')

    let baseMaxLen = len(baseAry)
    let targetMaxLen = len(targetAry)
    let i = 0

    while i < baseMaxLen
        if baseAry[i] == targetAry[i]
            let i = i + 1
        else
            break
        endif
    endwhile

    let diff = baseMaxLen - i

    if diff == 0
        return baseAry[baseMaxLen - 1]
    endif

    let path = ''
    let j = diff

    while j > 1
        let path = '../'.path

        let j = j - 1
    endwhile

    while i < targetMaxLen - 1
        let path = path.targetAry[i].'/'

        let i = i + 1
    endwhile

    let path = path.targetAry[i]

    return path
endfunction

function! jasminehelper#JasmineSpecCopy()
    let createspec = getcwd().'/'.g:jasmine_helper_test_js_dirname

    if isdirectory(createspec)
        echo 'already '.g:jasmine_helper_test_js_dirname.' init.'
        return
    endif

    let cmd = 'cp -r '.g:jasmine_helper_dir_spec_dir.' '.createspec
    call system(cmd)
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

function! jasminehelper#JasmineClassNameReplace(basedir, className, classPath)
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
    let jasminelibpath = matchlist(jasminehelper#relativePath(fnamemodify('index.html', ':p'), a:basedir.'/'), '\v(.*)/')[1]
    let testjspath = jasminehelper#relativePath(fnamemodify('test.js', ':p'), a:classPath)

    for i in targets
        let target = readfile(i)
        let target_replace = []

        for target_i in target
            let target_i = substitute(target_i, '%BASE_PATH%', jasminelibpath, 'g')
            let target_i = substitute(target_i, '%CLASS_PATH%', testjspath, 'g')
            let target_i = substitute(target_i, '%CLASS%', a:className, 'g')
            let target_i = substitute(target_i, '%CLASS_LOW%', classNameLow, 'g')
            let target_replace = add(target_replace, target_i)
        endfor

        call writefile(target_replace, i)
    endfor

    exec 'silent cd '.orgdir
endfunction

function! jasminehelper#JasmineTestPathReplace(testPath)
    let file = expand('%:p')
    let target = readfile(file)
    let target_replace = []

    for target_i in target
        let target_i = substitute(target_i, '%JASMINE_TEST_PATH%', jasminehelper#relativePath(file, a:testPath), 'g')
        let target_replace = add(target_replace, target_i)
    endfor

    call writefile(target_replace, file)
    exec 'e '.file
    return file
endfunction

function! jasminehelper#JasmineListUpJS()
    let orgdir = expand('%:p:h')
    let dir = jasminehelper#dirCheck(g:jasmine_helper_test_js_dirname)

    if dir == ''
        echo 'not found "'.g:jasmine_helper_test_js_dirname.'" directory.'
        return
    endif

    let dir = dir.g:jasmine_helper_test_js_dirname.'/_src'

    exec 'silent cd '.dir

    " let list = split(substitute("".system('ls -F | grep /'), "\n", "", 'g'), '/')
    let list = split(glob("**/*/", "\n"))

    let listBase = []
    let listClass = []
    let listTest = []
    let testFile = []
    let testPath = []
    for listi in list
        if listi != '_template/'
            if filereadable(listi.'test.js')
                let listBase = add(listBase, listi.'\n\')
                let listTest = add(listTest, '../_src/'.listi.'test.js'.'\n\')

                let testFile = readfile(listi.'test.js')
                let testPath = matchlist(testFile[0], '\v(.{-})"(.{-})"(.*)')
                let listClass = add(listClass, testPath[2].'\n\')
            endif
        endif
    endfor

    let listBase = extend(extend(['<script type="text/template" id="jasmineBaseList">\'], listBase), ['</script>\'])
    let listClass = extend(extend(['<script type="text/template" id="jasmineClassList">\'], listClass), ['</script>\'])
    let listTest = extend(extend(['<script type="text/template" id="jasmineTestList">\'], listTest), ['</script>\'])
    call writefile(extend(extend(['document.write(''\'],extend(listBase, extend(listClass, listTest))), ["');"]), '../list.js')

    exec 'silent cd '.orgdir
endfunction

function! jasminehelper#JasmineAdd(...)
    let dir = jasminehelper#dirCheck(g:jasmine_helper_test_js_dirname)

    if dir == ''
        echo 'no find "'.g:jasmine_helper_test_js_dirname.'" directory.'
        return
    endif

    let basedir = dir.g:jasmine_helper_test_js_dirname
    let dir = basedir.'/_src'
    let cmd1 = 'cp -r '.dir.'/_template '
    let cmd2 = 'rm -rf '
    let makename = expand('%:r')
    let orgdir = getcwd()

    let srcpath = matchlist(expand('%:p:h').'/', '\v(.*)/'.g:jasmine_helper_src_js_dirname.'/(.*)')[2]

    if a:0 != 0
        let makename = a:000[0]
    endif

    if makename == ''
        echo 'no target dircotry.'
        return
    endif

    if srcpath != ''
        let dir = dir.'/'.srcpath
    endif

    let dir = jasminehelper#removePathDot(dir)
    let dir = matchlist(dir, '\v(.*)/$')[1]

    if isdirectory(dir)
        echo 'already maked "'.dir.'/'.makename.'" directory.'
        return
    endif

    let srcfile = jasminehelper#JasmineTestPathReplace(dir.'/'.makename.'/test.js')

    call mkdir(dir, 'p')

    let cmd1 = cmd1.makename
    let cmd2 = cmd2.makename.'/.*'

    exec 'silent cd '.dir

    call system(cmd1)
    call system(cmd2)

    call jasminehelper#JasmineClassNameReplace(fnamemodify(basedir, ':p'), makename, srcfile)

    exec 'vs '.makename.'/test.js'

    call jasminehelper#JasmineListUpJS()

    exec 'silent cd '.orgdir
endfunction

function! jasminehelper#JasmineTemplate()
    let dir = jasminehelper#dirCheck(g:jasmine_helper_test_js_dirname)
    let tempdir = dir.g:jasmine_helper_test_js_dirname.'/_src/_template'

    if dir == '' || !isdirectory(tempdir)
        echo 'not find "'.tempdir.'" directory'
        return
    endif

    exec 'e '.tempdir.'/test.js'
endfunction

let &cpo = s:save_cpo
