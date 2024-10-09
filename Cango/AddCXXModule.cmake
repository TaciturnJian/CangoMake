#[[
	<NAME>
	|- <HEADER_DIR>
	|	|- c++ header files(headers for library output: <NAMESPACE>_<NAME>. every "::" in namespace will be replaced by "_")
	|
	|- <SOURCE_DIR>
	|	|- c++ source files(sources for library output)
	|
	|- <TESTER_DIR>
	|	|- c++ executable files(every file has main function for executable output: <NAMESPACE>_<NAME>_<TESTER_FILENAME>)
	|
	|- CMakeLists.txt(
	|	a simple cmakelists.txt would call these functions in order:
	|		cmake_minimum_required(VERSION 3.28)
	|		project(<NAMESPACE>.<NAME>)
	|		Add_CXX_Module(
	|			NAME <NAME>
	|			NAMESPACE <NAMESPACE>
	|			CXX_STANDARD <CXX_STANDARD> # default: 26
	|			HEADER_DIR <HEADER_DIR>		# default: include
	|			SOURCE_DIR <SOURCE_DIR>		# default: src
	|			TESTER_DIR <TESTER_DIR>		# default: test
	|			LINKS <LINKS>				# specify libraries to link, usually the targets in cmake like ${OpenCV_LIBS}, fmt::fmt etc.
	|		)
	|	)
	|
	|- ...
]]#

include_guard()

# 输出日志，当上下文变量 ARG_QUIET 为真时不输出
macro(Cango_AddCXXModule_Log log)
	if (NOT ${ARG_QUIET})
		message(STATUS ${log})
	endif()
endmacro()

# 检查 ARG_NAME，缺少则报错
macro(Cango_AddCXXModule_GuardArgs_Name)
	if ("${ARG_NAME}" STREQUAL "")
		message(FATAL_ERROR "${PROJECT_NAME}> 缺少参数：NAME")
	endif()
endmacro()

# 检查 NAMESPACE，缺少则警告，并设置禁用别名相关变量
macro(Cango_AddCXXModule_GuardArgs_Namespace)
	if ("${ARG_NAMESPACE}" STREQUAL "")
		Cango_AddCXXModule_Log("${PROJECT_NAME}> 缺少参数：NAMESPACE。将禁用别名")
	endif()
endmacro()

# 检查 SOURCE_DIR，缺少则警告，并设置为默认值 src
macro(Cango_AddCXXModule_GuardArgs_SourceDir)
	if ("${ARG_SOURCE_DIR}" STREQUAL "")
		Cango_AddCXXModule_Log("${PROJECT_NAME}> 缺少参数：SOURCE_DIR。将设置为 src")
		set(ARG_SOURCE_DIR "src")
	endif()
endmacro()

# 检查 HEADER_DIR，缺少则警告，并设置为默认值 include
macro(Cango_AddCXXModule_GuardArgs_HeaderDir)
	if ("${ARG_HEADER_DIR}" STREQUAL "")
		Cango_AddCXXModule_Log("${PROJECT_NAME}> 缺少参数：HEADER_DIR。将设置为 include")
		set(ARG_HEADER_DIR "include")
	endif()
endmacro()

# 检查 CXX_STANDARD，缺少则警告，并设置为默认值 26
# 若给定值小于 20，则报错
macro(Cango_AddCXXModule_GuardArgs_CXXStandard)
	if ("${ARG_CXX_STANDARD}" STREQUAL "")
		Cango_AddCXXModule_Log("${PROJECT_NAME}> 缺少参数：CXX_STANDARD。将设置为 26")
		set(ARG_CXX_STANDARD 26)
	elseif (${ARG_CXX_STANDARD} LESS 20)
		message(FATAL_ERROR "${PROJECT_NAME}> 参数 CXX_STANDARD 不得小于 20")
	endif()
endmacro()

# 检查 TESTER_DIR，缺少则警告，并设置为默认值 test
macro(Cango_AddCXXModule_GuardArgs_TesterDir)
	if ("${ARG_TESTER_DIR}" STREQUAL "")
		Cango_AddCXXModule_Log("${PROJECT_NAME}> 缺少参数：TESTER_DIR。将设置为 test")
		set(ARG_TESTER_DIR "test")
	endif()
endmacro()

# 检查所有参数
macro(Cango_AddCXXModule_GuardArgs)
	Cango_AddCXXModule_GuardArgs_Name()
	Cango_AddCXXModule_GuardArgs_Namespace()
	Cango_AddCXXModule_GuardArgs_HeaderDir()
	Cango_AddCXXModule_GuardArgs_SourceDir()
	Cango_AddCXXModule_GuardArgs_CXXStandard()
	Cango_AddCXXModule_GuardArgs_TesterDir()
endmacro()

# 设置模块名称
macro(Cango_AddCXXModule_ConfigureNames)
	# 没有命名空间时，只有全名
	# 全名 fullname = NAME
	# 有命名空间时，有别名和全名
	# 别名 aliasname = NAMESPACE::NAME
	# 全名 fullname = aliasname.replace("::", "_")
	if ("${ARG_NAMESPACE}" STREQUAL "")
		set(module_fullname ${ARG_NAME})
		set(module_aliasname ${ARG_NAME})
	else()
		set(module_aliasname ${ARG_NAMESPACE}::${ARG_NAME})
		string(REPLACE "::" "_" module_fullname ${module_aliasname})
	endif()
endmacro()

# 添加源文件
macro(Cango_AddCXXModule_AddSources)
	# 寻找模块的所有源文件，如果没有找到至少一个源文件，则报错
	set(module_source_dir ${PROJECT_SOURCE_DIR}/${ARG_SOURCE_DIR})
	aux_source_directory(${PROJECT_SOURCE_DIR}/${ARG_SOURCE_DIR} module_sources)
	list(LENGTH module_sources module_sources_count)
	if (module_sources_count EQUAL 0)
		message(FATAL_ERROR "${PROJECT_NAME}> 在目标目录没有找到源文件：${module_source_dir}")
	else()
		Cango_AddCXXModule_Log("${module_aliasname}> 找到${module_sources_count}个源文件")
	endif()

	# 将源文件添加到生成，如果可以，则添加别名
	add_library(${module_fullname} STATIC ${module_sources})
	if (NOT "${module_aliasname}" STREQUAL "")
		add_library(${module_aliasname} ALIAS ${module_fullname})
	endif()
endmacro()

#[[
	检查库是否存在，如果不存在则报错。
	先会检查 ((libraryName).replace("::","_"))_FOUND 是否为真，如果为真则忽略后续过程。
	然后检查 $libraryName} 是否为生成目标，如果为生成目标则不会报错，并缓存 ((libraryName).replace("::","_"))_FOUND 为真。
	如果两个检查都没通过，则报错缺少对象。
	不负责寻找包，只做检查。

	Values:
		libraryName 要检查的库的名称
#]]
function(Cango_AddCXXModule_RequireLibrary libraryName)
	string(REPLACE "::" "_" library_name ${libraryName})
	set(library_found ${library_name}_FOUND)
	if (${library_found})
		return()
	endif()

	if (TARGET ${libraryName})
		set(${library_found} TRUE CACHE BOOL "Found library as traget")
		return()
	endif()

	message(FATAL_ERROR "${PROJECT_NAME}> 缺少对象：${libraryName}")
endfunction()

# 设置属性
macro(Cango_AddCXXModule_SetProperties)
	# 设置头文件目录
	target_include_directories(${module_fullname} PUBLIC ${ARG_HEADER_DIR})
	Cango_AddCXXModule_Log("${module_aliasname}> 设置头文件目录：${ARG_HEADER_DIR}")

	# 设置 C++ 标准
	set_property(TARGET ${module_fullname} PROPERTY CXX_STANDARD ${ARG_CXX_STANDARD})
	Cango_AddCXXModule_Log("${module_aliasname}> 设置 C++ 标准：${ARG_CXX_STANDARD}")

	# 链接到其他库
	if (NOT "${ARG_LINKS}" STREQUAL "")
		list(JOIN ARG_LINKS ";" module_links)
		list(JOIN ARG_LINKS "|" module_links_text)
		Cango_AddCXXModule_Log("${module_aliasname}> 链接到库：${module_links_text}")
		foreach (library ${module_links})
			Cango_AddCXXModule_RequireLibrary(${library})
		endforeach()
		target_link_libraries(${module_fullname} PUBLIC ${module_links})
	endif()
endmacro()

# 添加可执行程序
macro(Cango_AddCXXModule_AddExecutables)
	# 获得所有可执行程序的源文件
	set(module_tester_dir ${PROJECT_SOURCE_DIR}/${ARG_TESTER_DIR})
	aux_source_directory(${module_tester_dir} module_testers)
	list(LENGTH module_testers module_testers_count)
	if (module_testers_count EQUAL 0)
		Cango_AddCXXModule_Log("${module_aliasname}> 在目标目录没有找到可执行程序：${module_tester_dir}")
	else()
		Cango_AddCXXModule_Log("${module_aliasname}> 准备添加${module_testers_count}个可执行程序")

		# 为每个可执行程序添加生成
		foreach(tester ${module_testers})
			# 获取可执行程序的名称
			get_filename_component(tester_name ${tester} NAME_WLE)
			set(tester_fullname ${module_fullname}_${tester_name})
			Cango_AddCXXModule_Log("${module_aliasname}> 添加程序：${tester_fullname}")

			# 链接到模块，确保c++标准与模块一致
			add_executable(${tester_fullname} ${tester})
			target_link_libraries(${tester_fullname} PRIVATE ${module_fullname})
			set_property(TARGET ${tester_fullname} PROPERTY CXX_STANDARD ${ARG_CXX_STANDARD})
		endforeach()
	endif()
endmacro()

#[[
	添加一个 C++ 模块，在之前请调用 project 函数
	Options:
	 	QUIET 省略大多数输出

	Values:
		Name 模块名称
		[Namespace] 模块命名空间，如果指定，则生成的模块会有别名 (Namespace_Name).replace("::", "_")
		[CXX_STANDARD] 模块 c++ 标准，默认为 26
		[HEADER_DIR] 模块头文件目录，默认为 Headers
		[SOURCE_DIR] 模块源文件目录，默认为 Sources
		[TESTER_DIR] 模块可执行程序文件目录，默认为 Testers

	Lists:
		[LINKS] 模块要链接的对象，如果缺少会报错


	@param NAME <模块名称> 指定模块名称
	@param [NAMESPACE <模块命名空间>] 指定模块命名空间，默认为 Cango
	@param [CXX_STANDARD <c++标准>] 指定模块 c++ 标准，默认为 20
	@param [HEADER_DIR <头文件目录>] 指定模块头文件目录，默认为 Headers
	@param [SOURCE_DIR <源文件目录>] 指定模块源文件目录，默认为 Sources
	@param [TESTER_DIR <可执行程序文件目录>] 指定模块可执行程序文件目录，默认为 Testers
	@param [LINKS <链接对象>] 指定模块需要连接的对象，如果缺少会报错
#]]
function(AddCXXModule)
	set(ARGS_OPTIONS QUIET)
	set(ARGS_VALUES NAME NAMESPACE VERSION CXX_STANDARD HEADER_DIR SOURCE_DIR TESTER_DIR)
	set(ARGS_LISTS LINKS)
	cmake_parse_arguments(ARG "${ARGS_OPTIONS}" "${ARGS_VALUES}" "${ARGS_LISTS}" ${ARGN})

	Cango_AddCXXModule_GuardArgs()

	Cango_AddCXXModule_ConfigureNames()
	Cango_AddCXXModule_AddSources()
	Cango_AddCXXModule_SetProperties()
	Cango_AddCXXModule_AddExecutables()
endfunction()

