include_guard()

include("Cango/Common/CangoArgs")
include("Cango/ControlPanel/Cango_Quiet")

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
	CangoArgsOptions(QUIET)
	CangoArgsValues(DIRECTORY)
	CangoArgsLists(NAMES)
	cmake_parse_arguments(ARG "${ARGS_OPTIONS}" "${ARGS_VALUES}" "${ARGS_LISTS}" ${ARGN})
	CangoApplyQuiet()
	CangoLog("${PROJECT_NAME}> 添加子模块列表(${ARG_NAMES})")
	foreach (module_name ${ARG_NAMES})
		add_subdirectory(${PROJECT_SOURCE_DIR}/${ARG_DIRECTORY}/${module_name})
	endforeach()
endfunction()
