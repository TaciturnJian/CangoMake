include_guard()

option(Cango_Quiet "省略不重要的日志输出，让 cmake 过程更为安静" NO)

#[[
	@brief 省略不重要的项目输出
#]]
macro(CangoBeQuiet)
	set(Cango_Quiet YES)
endmacro()

include("Cango/Common/GuardVariable")
GuardVariable(Cango_Quiet NO)
include("Cango/Common/CangoLog")

#[[
	@brief 
		应用 Cango_Quiet 的值到当前上下文的变量 ARG_QUIET
	@note 
		请注意变量名和大小写。
		ARG_QUIET 一般用于告知 CangoLog 是否输出日志
#]]
macro(CangoApplyQuiet)
	GuardVariable(Cango_Quiet NO)
	GuardVariable(ARG_QUIET ${Cango_Quiet})
endmacro()



