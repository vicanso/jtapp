(function() {

  jQuery(function($) {
    return $.ajax({
      url: '/error',
      dataType: 'json'
    }).success(function(data) {}).fail(function() {
      return console.dir(arguments);
    });
  });

}).call(this);
