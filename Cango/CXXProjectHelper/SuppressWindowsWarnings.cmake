include_guard()

#[[
	@brief
		抑制 Windows 编译时的警告
#]]
macro (SuppressWindowsWarnings)
	if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
		add_compile_options("/source-charset:utf-8")	# 抑制 visual studio warning C4819
		add_definitions(-D_WIN32_WINNT=0x0601)			# 抑制 boost asio 报错
	endif()
endmacro()
