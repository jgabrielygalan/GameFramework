App = Ember.Application.create({
  LOG_TRANSITIONS: true,
});

App.ApplicationController = Ember.Controller.extend({
  needs: ['login'],
  isLoggedIn: Ember.computed.alias('controllers.login.isLoggedIn'),
  name: Ember.computed.alias('controllers.login.username')
});


var attr = DS.attr;

App.Game = DS.Model.extend({
  name: attr(),
  rels: attr()
});

App.Match = DS.Model.extend({
  players: attr(Array),
  active: attr(),
  state: attr(),
  rels: attr()
});

App.Router.map(function() {
  this.route('games');
  this.route('matches');
  this.route('login');
  this.route('match', { path: '/match/:match_id' });
});

App.AuthenticatedRoute = Ember.Route.extend({
  beforeModel: function(transition) {
    if (!this.controllerFor('login').isLoggedIn) {
      this.redirectToLogin(transition);
    }
  },

  redirectToLogin: function(transition) {
    alert('You must log in!');    
    this.controllerFor('login').set('attemptedTransition', transition);
    this.transitionTo('login');
  },

  getJSONWithToken: function(url, transition) {
    var token = this.controllerFor('login').get('token');
    return $.getJSON(url, {token: token});
  },

  actions: {
    error: function(reason, transition) {
      if (reason.status === 401) {
        this.redirectToLogin(transition);
      } else {
        console.log(reason);
        alert('Something went wrong');
      }
    }
  }
});

App.GamesRoute = Ember.Route.extend({
  model: function() {
    return this.store.find('game'); // TODO: change with the appropriate AJAX call to the well-known entry point.   
  }
});

App.MatchesRoute = App.AuthenticatedRoute.extend({
  model: function() {
    var store = this.store;
    return this.getJSONWithToken("/matches").then(function(response) {
        return response.map(function (match) {
          return store.push('match', match);
        });
    });
  },
});


App.MatchRoute = App.AuthenticatedRoute.extend({
  model: function(params) {
    return this.store.getById('match', params.match_id);
    // if we haven't gone through the matches route, there won't be anything in the store, and this will fail.
    // So bookmarks to the match won't work.
  },
});


App.LoginRoute = Ember.Route.extend({
  setupController: function(controller, context) {
    controller.reset();
  }
});

App.LoginController = Ember.Controller.extend({
  reset: function() {
    this.setProperties({
      username: "",
      password: "",
      errorMessage: ""
    });
  },

  isLoggedIn: true,
  token: "P4YtVfpwnyr9yL594eFjVwWHyhFYOuDbVrlsXoxv29vzCb5RSpyPvLUeHNpLPb8BuvQKX4ggo_OAqL7v5zKUqg",

  actions: {
    login: function() {
      var self = this, data = this.getProperties('username', 'password');
      // Clear out any error messages.
      this.set('errorMessage', null);
      Ember.$.post('/auth', data).then(function(response) {
        self.set('errorMessage', response.message);
        if (response.success) {
          self.set('token', response.token);
          self.set('isLoggedIn', true);
          var attemptedTransition = self.get('attemptedTransition');
          if (attemptedTransition) {
            console.log("Attempting to transition again to: " + attemptedTransition);
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