#GameFramework

GameFramework is a framework to easily develop turn based games

## to start the server:

* start mongo process:

```shell
$ mongod --dbpath ~/Path/to/my/db
```

* launch sinatra:

``` shell
$ cd bin/
$ ./launch_sinatra
```

* create user

```shell
$ ruby lib/gameframework/domain/create_user.rb <user> <password>
```

go to _localhost:10000/web/index.html_ in your browser

Post a move to tictactoe match:

curl -v -XPOST -d'{"id":"move", "params":{"x":0, "y":0}}' http://localhost:10000/games/TicTacToe/5511223a110d460e81000001/event\?token\=P4YtVfpwnyr9yL594eFjVwWHyhFYOuDbVrlsXoxv29vzCb5RSpyPvLUeHNpLPb8BuvQKX4ggo_OAqL7v5zKUqg