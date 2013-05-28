jQuery ($) ->
	$.ajax({url :'/error', dataType : 'json'}).success((data) ->
	).fail () ->
		console.dir arguments
