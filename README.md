# CangoMake - cmake scripts to simplify project configuration

## introduction

To configure a c++ project(a library plus some executables), we usually use these functions in CMakeLists.txt:

```cmake
cmake_minimum_required(VERSION 3.28)
project(MyProject.ModuleA)

# configure library
aux_source_directory(src module_sources)
add_library(MyProject_ModuleA ${module_sources})
target_link_libraries(MyProject_ModuleA PUBLIC fmt::fmt PUBLIC spdlog::spdlog)
set_target_properties(MyProject_ModuleA PROPERTIES CXX_STANDARD 26)
target_include_directories(MyProject_ModuleA PUBLIC include)

# configure executables
aux_source_directory(tests module_tests)
foreach(test ${module_tests})
    get_filename_component(test_name ${test} NAME_WE)
    add_executable(${test_name} ${test})
    target_link_libraries(${test_name} PRIVATE MyProject_ModuleA)
    set_target_properties(${test_name} PROPERTIES CXX_STANDARD 26)
endforeach()
```

CangoMake provide a function to simplify this procedure, with much more readable and maintainable code:

```cmake
cmake_minimum_required(VERSION 3.28)
project(MyProject.ModuleA)

AddCXXModule(
    NAME ModuleA
    NAMESPACE MyProject
    CXX_STANDARD 26
    HEADER_DIR include
    SOURCE_DIR src
    TESTER_DIR tests
    LINKS
        fmt::fmt
        spdlog::spdlog
)
```

And if something goes wrong, CangoMake will give you a more readable error message.

The api with prefix of "Cango" means it's an internal function, and should not be called directly.

## setup

To make use of CangoMake, you can download all the cmake files in this project, and include them easily in your CMakeLists.txt:

```cmake
list(APPEND CMAKE_MODULE_PATH "<Path>/CangoMake") # where CangoMake Contains "Cango.cmake"
include("Cango")
```
