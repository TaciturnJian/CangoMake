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
	string(REPLACE "::" "_" library_name ${libraryName})
	set(library_found ${library_name}_FOUND)
	if (${library_found})
		return()
	endif()

	if (TARGET ${libraryName})
		set(${library_found} TRUE CACHE BOOL "Found library as traget")
		return()
	endif()
	
	message(FATAL_ERROR "${PROJECT_NAME}> 缺少对象：${libraryName}")
endfunction(RequireLibrary)

#[[
	@brief 
		对给定的每一个名称调用 RequireLibrary 检查库是否存在。
	@param libraryList 库名称列表
#]]
macro (RequireLibraries libraryListName)
	foreach (library ${${libraryListName}})
		RequireLibrary(${library})
	endforeach()
endmacro()
