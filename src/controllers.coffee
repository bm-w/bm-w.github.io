controllers = angular.module 'bmw', ['bmwDirectives']

controllers.run ['$log', ($log) ->
	$log.debug "Running..."

	(Hammer window).on 'pinch', (event) ->
		console.log "Pinch event:", event
]
