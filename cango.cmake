include_guard()

# @brief cango 库的命名宏，为 name 生成 prefix_name 与 prefix_alias 两个变量
# @param name 由 . 分割的名称，例如 namespace.subspace.name
# @param prefix 生成的变量的前缀
# @details 将 . 替换为 _ 生成 prefix_name ，将 . 替换为 :: 生成 prefix_alias
macro(cango_prefix_naming name prefix)
    string(REPLACE "." "_" ${prefix}_name ${name})
    string(REPLACE "." "::" ${prefix}_alias ${name})
endmacro()

# @brief 添加一个 module 目录下的子模块
# @param name 子模块名称
macro(cango_submodule name)
    add_subdirectory(module/${name})
endmacro()

# @brief 为当前项目 A 添加一个 module 目录下的子模块 A.B
# @param name 子模块的最尾部名称
# @details 添加子文件夹 module/${PROJECT_NAME}.${name}
macro(cango_project_submodule name)
    add_subdirectory(module/${PROJECT_NAME}.${name})
endmacro()

# @brief 为 name 库添加别名，若别名与 name 相同则不做任何事
# @param name 原名
# @param alias 别名
macro(cango_lib_alias name alias)
    if (NOT ${name} STREQUAL ${alias})
        add_library(${alias} ALIAS ${name})
    endif()
endmacro()

# @brief 设置项目的 c++ 标准
# @param standard 整数，表示 c++ 标准
macro(cango_project_cxx_standard standard)
    set(CMAKE_CXX_STANDARD 26)
endmacro()

# @brief 添加一个 header-only c++ 库
# @param name 由 . 分割的项目名称
macro(cango_cpp_ho name)
	cango_prefix_naming(${name} ho)
	add_library(${ho_name} INTERFACE)
    cango_lib_alias(${ho_name} ${ho_alias})
	target_include_directories(${ho_name} INTERFACE include)
endmacro()

# @brief 添加一个生成 header-only c++ 库的项目
# @param name 由 . 分割的项目名称
macro(cango_project_cpp_ho name)
    project(${name})
    cango_cpp_ho(${name})
endmacro()

# @brief 寻找 src 目录下的所有源文件，保存到 prefix_sources 中
# @param prefix 生成的变量的前缀
macro(cango_cpp_src prefix)
    set(${prefix}_sources)
    aux_source_directory(src ${prefix}_sources)
endmacro()

# @brief 添加一个 c++ 库
# @param name 由 . 分割的项目名称
macro(cango_cpp_lib name)
    cango_prefix_naming(${name} lib)
    cango_cpp_src(lib)
    add_library(${lib_name} ${lib_sources})
    cango_lib_alias(${lib_name} ${lib_alias})
    target_include_directories(${lib_name} PUBLIC include)
endmacro()

# @brief 添加一个生成 c++ 库的项目
# @param name 由 . 分割的项目名称
macro(cango_project_cpp_lib name)
    project(${name})
	cango_cpp_lib(${name})
endmacro()

# @brief 为库添加一个 c++ 测试程序，文件 test/name.cpp 自动链接到当前库
# @param name 测试文件的名称
macro(cango_cpp_lib_test name)
    add_executable(${lib_name}_${name} test/${name}.cpp)
    target_link_libraries(${lib_name}_${name} ${lib_alias})
endmacro()

# @brief 为库添加一个 c++ 测试程序，文件 test/name.cpp 自动链接到当前头文件库
# @param name 测试文件的名称
macro(cango_cpp_ho_test name)
    add_executable(${ho_name}_${name} test/${name}.cpp)
    target_link_libraries(${ho_name}_${name} ${ho_alias})
endmacro()

# @brief 为 MSVC 编译器启用 utf-8 编码
macro(cango_msvc_enable_utf8_encoding)
    if (MSVC)
        add_compile_options("/utf-8")
    endif ()
endmacro()

macro(set_target_cpp_standard name standard)
    set_target_properties(${name} PROPERTIES CXX_STANDARD ${standard})
endmacro()

macro(set_global_cpp_standard standard)
    set(CMAKE_CPP_STANDARD ${standard})
endmacro()

macro(set_output_dir dir)
    set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${dir})
    set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${dir})
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${dir})
endmacro()
