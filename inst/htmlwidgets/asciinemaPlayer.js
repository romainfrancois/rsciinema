HTMLWidgets.widget({

  name: 'asciinemaPlayer',

  type: 'output',

  factory: function(el, width, height) {

    // TODO: define shared variables for this instance

    return {

      renderValue: function(x) {
        $(el).empty() ;

        var $player = $("<asciinema-player src='"+ x.src +"' />" ) ;
        $player.attr("cols", x.cols) ;
        $player.attr("rows", x.rows) ;
        if( x.autoplay ){
          $player.attr("autoplay", true) ;
        }
        if( x.loop ){
          $player.attr("loop", true) ;
        }
        $player.attr("start-at", x.start_at ) ;
        $player.attr("speed", x.speed ) ;
        $(el).append( $player ) ;
      },

      resize: function(width, height) {}

    };
  }
});
