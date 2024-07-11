include_guard()

include("Cango/Common/GuardVariable")

#[[
	@brief 
		如果全局的编译类型和输出目录没有设置，则设置默认值。
		影响的变量：
			CMAKE_BUILD_TYPE
			CMAKE_RUNTIME_OUTPUT_DIRECTORY
			CMAKE_LIBRARY_OUTPUT_DIRECTORY
			CMAKE_ARCHIVE_OUTPUT_DIRECTORY
#]]
macro (GuardGlobalBuildDirectory)
	GuardVariable(CMAKE_BUILD_TYPE Release)
	GuardVariable(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/bin)
	GuardVariable(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/bin)
	GuardVariable(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/bin)
endmacro()
