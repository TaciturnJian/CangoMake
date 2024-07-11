include_guard()

#[[
	@brief 
		覆盖整个 CMake 项目的 C++ 标准版本
	@param standard 指定 C++ 的标准
#]]
macro (OverrideGlobalCXXStandard standard)
	set(CMAKE_CXX_STANDARD ${standard})
endmacro()
