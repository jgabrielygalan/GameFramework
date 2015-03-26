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

go to _localhost:10000/index.html_ in your browser
