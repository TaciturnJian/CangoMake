include_guard()

#[[
	@brief
		检查库是否存在，如果不存在则报错。
		先会检查 ${libraryName}_FOUND 是否为真，如果为真则忽略后续过程。
		然后检查 $libraryName} 是否为生成目标，如果为生成目标则不会报错，并缓存 ${libraryName}_FOUND 为真。
		如果两个检查都没通过，则报错缺少对象。
	@param libraryName 库的名称
#]]
function(RequireLibrary libraryName)
	if (${libraryName}_FOUND)
		return()
	endif()

	if (TARGET ${libraryName})
		set(${libraryName}_FOUND TRUE CACHE FORCE ON)
		return()
	endif()
	message(FATAL_ERROR "${PROJECT_NAME}> 缺少对象：${libraryName}")
endfunction(RequireLibrary)

#[[
	@brief 
		对给定的每一个名称调用 RequireLibrary 检查库是否存在。
	@param libraryList 库名称列表
#]]
macro (RequireLibraries libraryList)
	foreach (library ${libraryList})
		RequireLibrary(${library})
	endforeach()
endmacro()
