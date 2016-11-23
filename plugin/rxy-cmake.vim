
let s:rxy_cmake_project_dir =''

function! Rxy_cmake_find_project_path()
    ruby << EOF
    project_possible_dir =  $curbuf.name
    num_of_repeat =  project_possible_dir.count("/")
    num_of_repeat.times {
        tem_index =  project_possible_dir.rindex("/")
        project_possible_dir = project_possible_dir[0,tem_index]
        if File::exists?(project_possible_dir + '/.git') 
            break
        end
    }
    if (File::directory?(project_possible_dir + '/.git') && 
        File::exists?(project_possible_dir + '/CMakeLists.txt')
        )
        VIM::command("let s:rxy_cmake_project_dir="+"'"+project_possible_dir+"'")
    else
        VIM::command("let s:rxy_cmake_project_dir=''")
    end
EOF
echom "the project dir is". s:rxy_cmake_project_dir
endfunction

function! Rxy_cmake_deal_build_dir(auto_remove)
    let l:build_dir_exists = 0
    let l:decide_remove = 0
    ruby << EOF
    project_dir = VIM::evaluate("s:rxy_cmake_project_dir")
    if File::exists?(project_dir + "/build")
        VIM::command("let l:build_dir_exists=1")
    else
        VIM::command("let l:build_dir_exists=0")
    end
EOF
    if ( l:build_dir_exists == 1)
        if((a:auto_remove == 1) || (input("build dir exists, y to rebuild it:") ==# 'y'))
            let l:decide_remove = 1
        else
            let l:decide_remove = 0
        endif
    else
        ruby <<EOF
        project_dir = VIM::evaluate("s:rxy_cmake_project_dir")
        Dir.mkdir(project_dir + "/build")
EOF
        return
    endif
    if l:decide_remove == 1
        ruby << EOF
        require 'fileutils'
        project_dir = VIM::evaluate("s:rxy_cmake_project_dir")
        FileUtils.rmtree(project_dir + "/build")
        Dir.mkdir(project_dir + "/build")
EOF
    endif
endfunction

function! Rxy_cmake_run_cmake_or_make_in_build(isCmake)
    let l:currend_dir = getcwd()
    execute "cd " . s:rxy_cmake_project_dir . '/build'

    if (a:isCmake == 1)
        execute "!cmake .."
    elseif (a:isCmake == 0)
        execute "make"
    end

    execute "cd " . l:currend_dir
endfunction

"augroup testgroup
    "autocmd!
    "autocmd BufWritePost rxy-cmake.vim :so %
    "autocmd BufWritePost rxy-cmake.vim :call Rxy_cmake_find_project_path()
    "autocmd BufWritePost rxy-cmake.vim :call Rxy_cmake_deal_build_dir(0)
    "autocmd BufWritePost rxy-cmake.vim :call Rxy_cmake_run_cmake_or_make_in_build(1)
    "autocmd BufWritePost rxy-cmake.vim :call Rxy_cmake_run_cmake_or_make_in_build(0)
"augroup END

function! Rxy_cmake_preCmake()
    call Rxy_cmake_find_project_path()
    if s:rxy_cmake_project_dir ==# ''
        echohl ErrorMsg
        echo "Can not find the project dir"
        echohl None
        return
    endif
    call Rxy_cmake_deal_build_dir(0)
    call Rxy_cmake_run_cmake_or_make_in_build(1)
endfunction

"augroup rxyCmakeGroup
    "autocmd!
    autocmd FileType c,cpp command! -nargs=0 Rcmake call Rxy_cmake_preCmake()
    autocmd FileType c,cpp command! Rmake call Rxy_cmake_run_cmake_or_make_in_build(0)
"augroup END
