App = Ember.Application.create({});

var games = [{
  id: '1',
  title: "Tic Tac Toe",
  description: "Place your pieces to try to get three in line",
}, {
  id: '2',
  title: "Ginkgopolis",
  description: "Expand the city, overbuild buildings to have majority in each neighborhood.",
}];

App.Game = DS.Model.extend({
  name: DS.attr('string'),
  uri: DS.attr('string')
});



App.Router.map(function() {
  this.resource('matches');
  this.resource('games', function() {
    this.resource('game', { path: ':post_id' });
  });
});

App.GamesRoute = Ember.Route.extend({
  model: function() {
    return this.store.findAll('game');    
  }
});

App.GameRoute = Ember.Route.extend({
  model: function(params) {
    return games.findBy('id', params.game_id);
  }
});

//App.PostController = Ember.ObjectController.extend({});

var showdown = new Showdown.converter();
