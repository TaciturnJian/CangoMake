include_guard()

#[[
	@brief 
		设置参数解析的列表变量列表 ARGS_LISTS
	@param ... 列表类型的变量的名称列表
#]]
macro (CangoArgsLists)
	set(ARGS_LISTS ${ARGN})
endmacro()
