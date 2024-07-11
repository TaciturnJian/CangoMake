include_guard()

#[[
	@brief 
		设置参数解析的选项变量列表 ARGS_OPTIONS
	@param ... 选项类型的变量的名称列表
#]]
macro (CangoArgsOptions)
	set(ARGS_OPTIONS ${ARGN})
endmacro()
