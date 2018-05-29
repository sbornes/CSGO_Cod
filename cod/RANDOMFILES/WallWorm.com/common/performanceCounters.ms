
if (::wallworm_installation_path == undefined) then (
	::wallworm_installation_path = pathConfig.removePathLeaf (pathConfig.removePathLeaf (getFilenamePath (getThisScriptFilename())))
)
fileIn (::wallworm_installation_path + "/WallWorm.com/common/config.ms")

if ::wallworm_enablePerformanceCounters then (
	try (
		::wallworm_helpers_performanceCounters = DotNetClass "WallWorm.Helpers.PerformanceCounters"

		::wallworm_performanceCounter_start = function wallworm_performanceCounter_start groupName functionName = (
			local funcName = functionName as String
			::wallworm_helpers_performanceCounters.StartCounter funcName
			free funcName
		)

		::wallworm_performanceCounter_stop = function wallworm_performanceCounter_stop groupName functionName = (
			local funcName = functionName as String
			::wallworm_helpers_performanceCounters.StopCounter funcName
			free funcName
		)

		::wallworm_performanceCounter_reset = function wallworm_performanceCounter_reset = (
			::wallworm_helpers_performanceCounters.Reset()
		)

		::wallworm_performanceCounter_showData = function wallworm_performanceCounter_showData = (
			local data = (::wallworm_helpers_performanceCounters.BuildTimerOutput() as String)
			if ::wallworm_debug == true then (
				messageBox data
			)
			format "%" data
			free data
		)
	) catch (
		::wallworm_performanceCounter_start = function start_innerThunk groupName functionName = ()
		::wallworm_performanceCounter_stop = function stop_innerThunk groupName functionName = ()
		::wallworm_performanceCounter_reset = function reset_innerThunk = ()
		::wallworm_performanceCounter_showData = function getData_innerThunk = ()
	)
) else (
	::wallworm_performanceCounter_start = function start_innerThunk groupName functionName = ()
	::wallworm_performanceCounter_stop = function stop_innerThunk groupName functionName = ()
	::wallworm_performanceCounter_reset = function reset_innerThunk = ()
	::wallworm_performanceCounter_showData = function getData_innerThunk = ()
)
