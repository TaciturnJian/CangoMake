include_guard()

include("Cango/Common/GuardVariable")
GuardVariable(ARG_QUIET NO)

#[[
	@brief 
		输出一般的消息，如果满足 ARG_QUIET 为真，则不输出 
	@param logMessage 要输出的消息
#]]
macro(CangoLog logMessage)
	if (NOT ${ARG_QUIET})
		message(STATUS ${logMessage})
	endif()
endmacro()
