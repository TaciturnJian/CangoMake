include_guard()

#[[
	@brief 
		在变量为空时，设置变量的值为给定的默认值
	@param variableName 变量的名称
	@param defaultValue 变量的默认值
#]]
macro(GuardVariable variableName defaultValue)
	if (NOT ${variableName})
		set(${variableName} ${defaultValue})
	endif()
endmacro()
