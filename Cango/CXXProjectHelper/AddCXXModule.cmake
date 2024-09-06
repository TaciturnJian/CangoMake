include_guard()

include("Cango/ControlPanel/Cango_Quiet")
include("Cango/Common/CangoArgs")
include("Cango/Common/RequireLibrary")

#[[
	@brief 
		为 C++ 模块中的可选参数提供默认值。
		受影响的变量有：
			ARG_QUIET
			ARG_VERSION
			ARG_AUTHORS
			ARG_COPYRIGHT
			ARG_RELEASE
			ARG_NAMESPACE
			ARG_CXX_STANDARD
			ARG_HEADER_DIR
			ARG_SOURCE_DIR
			ARG_TESTER_DIR
			ARG_DOCKEN_DIR
#]]
macro (GuardCXXModuleOptionalArgs)
	CangoApplyQuiet()
	GuardVariable(ARG_VERSION 1.0.0.0)
	GuardVariable(ARG_AUTHORS Sango)
	GuardVariable(ARG_COPYRIGHT "2024, ${ARG_AUTHORS}")
	GuardVariable(ARG_RELEASE ${ARG_VERSION})
	GuardVariable(ARG_NAMESPACE Cango)
	GuardVariable(ARG_CXX_STANDARD 26)
	GuardVariable(ARG_HEADER_DIR Headers)
	GuardVariable(ARG_SOURCE_DIR Sources)
	GuardVariable(ARG_TESTER_DIR Testers)
	GuardVariable(ARG_DOCKEN_DIR Dockens)
endmacro()

#[[
	@brief 添加一个 C++ 模块，在之前请调用 project 函数
	@param [QUIET] 省略大多数输出
	@param [DOC] 指定生成 Doxygen 和 Sphinx 文档
	@param NAME <模块名称> 指定模块名称
	@param [NAMESPACE <模块命名空间>] 指定模块命名空间，默认为 Cango
	@param [AUTHORS <模块作者1> [<模块作者2> ...] ] 指定模块作者，默认为 Sango
	@param [COPYRIGHT <版权信息>] 指定模块版权，默认为 2024, ${AUTHORS}
	@param [VERSION <模块版本>] 指定模块版本，默认为 1.0.0.0
	@param [RELEASE <模块发布版本>] 指定模块发布版本，默认为 ${VERSION}
	@param [CXX_STANDARD <c++标准>] 指定模块 c++ 标准，默认为 20
	@param [HEADER_DIR <头文件目录>] 指定模块头文件目录，默认为 Headers
	@param [SOURCE_DIR <源文件目录>] 指定模块源文件目录，默认为 Sources
	@param [TESTER_DIR <可执行程序文件目录>] 指定模块可执行程序文件目录，默认为 Testers
	@param [DOCKEN_DIR <文档目录>] 指定模块文档目录，默认为 Dockens
	@param [LINKS <链接对象>] 指定模块需要连接的对象，如果缺少会报错
#]]
function(AddCXXModule)
	CangoArgsOptions(QUIET DOC)
	CangoArgsValues(NAME NAMESPACE AUTHORS COPYRIGHT VERSION RELEASE CXX_STANDARD HEADER_DIR SOURCE_DIR TESTER_DIR DOCKEN_DIR)
	CangoArgsLists(LINKS)
	cmake_parse_arguments(ARG "${ARGS_OPTIONS}" "${ARGS_VALUES}" "${ARGS_LISTS}" ${ARGN})
	GuardCXXModuleOptionalArgs()

	set(module_fullname ${ARG_NAMESPACE}_${ARG_NAME})
	set(module_aliasname ${ARG_NAMESPACE}::${ARG_NAME})
	CangoLog("${CMAKE_PROJECT_NAME}> 正在添加模块(${module_aliasname} -> ${module_fullname})")

	aux_source_directory(${PROJECT_SOURCE_DIR}/${ARG_SOURCE_DIR} module_sources)
	add_library(${module_fullname} STATIC ${module_sources})
	add_library(${module_aliasname} ALIAS ${module_fullname})
	target_include_directories(${module_fullname} PUBLIC ${ARG_HEADER_DIR})
	set_target_properties(${module_fullname} PROPERTIES CXX_STANDARD ${ARG_CXX_STANDARD})
	if (NOT "${ARG_LINKS}" STREQUAL "")
		list(JOIN ARG_LINKS ";" module_links)
		RequireLibraries(module_links)
		target_link_libraries(${module_fullname} PUBLIC ${module_links})
	endif()

	aux_source_directory(${PROJECT_SOURCE_DIR}/${ARG_TESTER_DIR} testers)
	list(LENGTH testers tester_count)
	foreach(tester ${testers})
		get_filename_component(tester_name ${tester} NAME_WLE)
		set(tester_fullname ${module_fullname}_${tester_name})
		CangoLog("${module_aliasname}> 正在添加程序：${tester_fullname}")
		add_executable(${tester_fullname} ${tester})
		target_link_libraries(${tester_fullname} PRIVATE ${module_fullname})
		set_target_properties(${tester_fullname} PROPERTIES CXX_STANDARD ${ARG_CXX_STANDARD})
	endforeach()

	if (${ARG_DOC})
		set(module_dockens ${PROJECT_SOURCE_DIR}/${ARG_DOCKEN_DIR})
		set(module_doxygen_index ${module_doxygen_out}/xml/index.xml)
		set(module_doxyfile_in ${module_dockens}/Doxyfile.in)
		set(module_doxyfile_out ${PROJECT_BINARY_DIR}/Doxyfile)
		set(module_doxygen_name ${module_fullname}_Doxygen)
		CangoLog("${module_aliasname}> 正在添加 Doxygen 文档：${module_doxygen_name}")
		configure_file(${module_doxyfile_in} ${module_doxyfile_out} @ONLY)
		add_custom_command(
			TARGET ${module_fullname}
			POST_BUILD
			COMMAND ${DOXYGEN_EXECUTABLE} ${module_doxyfile_out}
			DEPENDES 
				${module_doxyfile_in} 
			COMMENT "正在生成 ${module_aliasname} 模块的 Doxygen 文档"
		)

		set(module_confpy_in ${module_dockens}/conf.in)
		set(module_confpy_out  ${PROJECT_BINARY_DIR}/xml/conf.py)
		set(module_sphinx_name ${module_fullname}_Sphinx)
		CangoLog("${module_aliasname}> 正在添加 Sphinx 文档：${module_sphinx_name}")
		configure_file(${module_confpy_in} ${module_confpy_out} @ONLY) 
		file(COPY ${module_dockens}/index.rst DESTINATION ${PROJECT_BINARY_DIR}/xml/)
		add_custom_command(
			TARGET ${module_fullname}
			POST_BUILD
			COMMAND ${SPHINX_EXECUTABLE} 
				-b html 
				"-Dbreathe_projects.CodeHelper=${PROJECT_BINARY_DIR}/xml"
				${PROJECT_BINARY_DIR}/xml
				${PROJECT_BINARY_DIR}
			DEPENDS
				${module_dockens}/index.rst
				${module_confpy_out}
				${module_doxygen_index}
			COMMENT "正在生成 ${module_aliasname} 模块的 Sphinx 文档"
		)
	endif()
endfunction()

