
/*
Station
*/

(function() {
  var __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  window.Station = (function(_super) {

    __extends(Station, _super);

    function Station() {
      Station.__super__.constructor.apply(this, arguments);
    }

    Station.prototype.brand = '';

    Station.prototype.name = '';

    Station.location({
      lat: 0,
      lon: 0
    });

    Station.prices({
      diesel: 0,
      E10: 0,
      octane_98: 0
    });

    Station.services({
      air: true,
      store: true
    });

    Station.prototype.initialize = function() {};

    return Station;

  })(Backbone.Model);

}).call(this);
