jQuery ($) ->
	$.ajax({url :'/error', dataType : 'json'}).success((data) ->
    console.dir data
	).error (data) ->
		console.dir data
