include_guard()

#[[
	@brief 
		设置参数解析的值变量列表 ARGS_VALUES
	@param ... 值类型的变量的名称列表
#]]
macro (CangoArgsValues)
	set(ARGS_VALUES ${ARGN})
endmacro()
