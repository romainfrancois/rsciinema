HTMLWidgets.widget({

  name: 'asciinemaPlayer',

  type: 'output',

  factory: function(el, width, height) {

    // TODO: define shared variables for this instance

    return {

      renderValue: function(x) {
        $(el).empty() ;
        $(el).append( $("<asciinema-player src='"+ x.src +"' />") ) ;
      },

      resize: function(width, height) {}

    };
  }
});
