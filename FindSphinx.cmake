include_guard()

find_program(SPHINX_EXECUTABLE
    NAMES sphinx-build
    DOC "sphinx-build 程序的路径"
)

include(FindPackageHandleStandardArgs)

find_package_handle_standard_args(Sphinx
    "找不到 sphinx-build"
    SPHINX_EXECUTABLE
)
