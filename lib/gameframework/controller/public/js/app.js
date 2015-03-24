App = Ember.Application.create({
  LOG_TRANSITIONS: true,
});

var attr = DS.attr;

App.Game = DS.Model.extend({
  name: attr(),
  rels: attr()
});

App.Match = DS.Model.extend({
  player1: attr(),
  player2: attr(),
  active: attr(),
  uri: attr()
});

App.Router.map(function() {
  this.route('games', function() {
    this.route('matchlist', {path: '/:game_id'});
  });
  this.route('login');
});

App.AuthenticatedRoute = Ember.Route.extend({
  redirectToLogin: function(transition) {
    alert('You must log in!');
    var loginController = this.controllerFor('login');
    loginController.set('attemptedTransition', transition);
    this.transitionTo('login');
  },

  getJSONWithToken: function(url) {
    var token = this.controllerFor('login').get('token');
    return $.getJSON(url, {token: token})
  },

  actions: {
    error: function(reason, transition) {
      if (reason.status === 401) {
        this.redirectToLogin(transition);
      } else {
        alert('Something went wrong');
      }
    }
  }
});

App.GamesRoute = Ember.Route.extend({
  model: function() {
    return this.store.find('game');    
  }
});

App.LoginRoute = Ember.Route.extend({
  setupController: function(controller, context) {
    controller.reset();
  }
});


App.GamesMatchlistRoute = App.AuthenticatedRoute.extend({
  model: function(params) {
    var store = this.store;
    var game = store.getById('game', params.game_id);
    var uri = game.get("rels").uri;
    this.getJSONWithToken(uri)
      .then(function(response) {
        return response.map(function (match) {
          return store.createRecord('match', match);
        });
    });
  },
});

App.LoginController = Ember.Controller.extend({
  reset: function() {
    this.setProperties({
      username: "",
      password: "",
      errorMessage: ""
    });
  },
  actions: {
    login: function() {
      var self = this, data = this.getProperties('username', 'password');
      // Clear out any error messages.
      this.set('errorMessage', null);
      Ember.$.post('/auth', data).then(function(response) {
        self.set('errorMessage', response.message);
        if (response.success) {
          self.set('token', response.token);
          var attemptedTransition = self.get('attemptedTransition');
          if (attemptedTransition) {
            attemptedTransition.retry();
            self.set('attemptedTransition', null);            
          } else {
            self.transitionToRoute('games');            
          }
        }
      });
    }
  }
});