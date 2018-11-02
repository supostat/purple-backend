# README
Start project:
```console
$ docker-compose up
```
Create databases:
```console
$ docker-compose run app bundle exec rails db:create
```
Run migrations:
```console
$ docker-compose run app bundle exec rails db:migrate
```
Run bash:
```console
$ docker-compose exec app bash
```
Debugging:
```console
$ docker attach purple-project_app_1
```