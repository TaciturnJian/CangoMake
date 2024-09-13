include_guard()

macro(Cango_AddModulesInDirectory_Log log)
	if (NOT ARG_QUIET)
		message(STATUS ${log})
	endif()
endmacro()

macro(Cango_AddModulesInDirectory_GuardArgs_Directory)
	if ("${ARG_DIRECTORY}" STREQUAL "")
		message(FATAL_ERROR "${PROJECT_NAME}> 缺少参数：DIRECTORY")
	endif()
endmacro()

macro(Cango_AddModulesInDirectory_Process)
	list(LENGTH ARG_NAMES modules_count)
	list(JOIN ARG_NAMES "|" modules)
	set(module_dir ${PROJECT_SOURCE_DIR}/${ARG_DIRECTORY})
	Cango_AddModulesInDirectory_Log("${PROJECT_NAME}> 在目录中添加${modules_count}个子模块(${modules})：${module_dir}")
	foreach (module_name ${ARG_NAMES})
		add_subdirectory(${module_dir}/${module_name})
	endforeach()
endmacro()

#[[
	@brief 
		将指定目录下的所有模块添加到当前项目中
	@param [QUIET] 如果不指定，将设置为项目默认值
	@param DIRECTORY <文件夹路径>
	@param NAMES <模块名称1> [<模块名称2> ...]
	@example
		AddModulesInDirectory(
			QUIET
			DIRECTORY "Submodules"
			NAMES 
				"Module1" 
				"Module2"
		)
#]]
function (AddModulesInDirectory)
	set(ARGS_OPTIONS QUIET)
	set(ARGS_VALUES DIRECTORY)
	set(ARGS_LISTS NAMES)
	cmake_parse_arguments(ARG "${ARGS_OPTIONS}" "${ARGS_VALUES}" "${ARGS_LISTS}" ${ARGN})

	Cango_AddModulesInDirectory_GuardArgs_Directory()
	Cango_AddModulesInDirectory_Process()
endfunction()
