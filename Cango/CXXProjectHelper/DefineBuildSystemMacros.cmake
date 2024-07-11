include_guard()

#[[
	@brief 
		为 C++ 编译时定义一些与编译类型和系统类型有关的宏
#]]
macro (DefineBuildSystemMacros)
	if (CMAKE_BUILD_TYPE STREQUAL "Release")
		add_definitions(-D_RELEASE)
	elseif (CMAKE_BUILD_TYPE STREQUAL "Debug")
		add_definitions(-D_DEBUG)
	endif()
	
	if (CMAKE_SYSTEM_NAME STREQUAL "Windows")
		add_definitions(-D_WINDOWS) 
	elseif (CMAKE_SYSTEM_NAME STREQUAL "Linux")
		add_definitions(-D_LINUX)
	endif()
endmacro()

