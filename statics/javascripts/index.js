(function() {

  jQuery(function($) {
    return $.ajax({
      url: '/error',
      dataType: 'json'
    }).success(function(data) {
      return console.dir(data);
    }).error(function(data) {
      return console.dir(data);
    });
  });

}).call(this);
