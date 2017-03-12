# Bar Manager

### Instructions:

`docker-compose build`

`docker-compose run web rake db:create`

`docker-compose run web rake db:migrate`

`docker-compose run web rake db:seed`

`docker-compose up`

### Caching in development mode:

`docker-compose run web rake dev:cache`