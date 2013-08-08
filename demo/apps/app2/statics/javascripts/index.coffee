jQuery ($) ->
	$.ajax({url :'/error', dataType : 'json'}).success((data) ->
	).fail (xhr, res) ->
		console.dir arguments
