app = angular.module 'bmw', []

app.run ['$log', ($log) ->
	$log.debug "Running..."
]
