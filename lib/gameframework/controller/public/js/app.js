App = Ember.Application.create({
  LOG_TRANSITIONS: true,
});

var attr = DS.attr;

App.Game = DS.Model.extend({
  name: attr(),
  uri: attr()
});

App.Match = DS.Model.extend({
  player1: attr(),
  player2: attr(),
  active: attr(),
  uri: attr()
});

App.Router.map(function() {
  this.resource('games', function() {
    this.route('matchlist', {path: '/:game_id'});
  });
});

App.GamesRoute = Ember.Route.extend({
  model: function() {
    return this.store.find('game');    
  }
});

App.GamesMatchlistRoute = Ember.Route.extend({
  model: function(params) {
    var store = this.store;
    return $.getJSON("http://localhost:10000/games/" + params.game_id)      
      .then(function(response) {
        return response.map(function (match) {
          return store.createRecord('match', match);
        });
    });
  }
});
