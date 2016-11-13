
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
    ruby << EOF
    require 'fileutils'
    auto_remove = VIM::evaluate("a:auto_remove")
    project_dir = VIM::evaluate("s:rxy_cmake_project_dir")
    if File::exists?(project_dir + "/build")
        if auto_remove
            FileUtils.rmtree(project_dir + "/build")
            Dir.mkdir(project_dir + "/build")
        end
    else
        Dir.mkdir(project_dir + "/build")
    end
EOF
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

augroup testgroup
    autocmd!
    autocmd BufWritePost rxy-cmake.vim :so %
    autocmd BufWritePost rxy-cmake.vim :call Rxy_cmake_find_project_path()
    autocmd BufWritePost rxy-cmake.vim :call Rxy_cmake_deal_build_dir(1)
    autocmd BufWritePost rxy-cmake.vim :call Rxy_cmake_run_cmake_or_make_in_build(1)
    autocmd BufWritePost rxy-cmake.vim :call Rxy_cmake_run_cmake_or_make_in_build(0)
augroup END

