# Drupal With Docker

Drupal 9.3.16 + Docker

> Just the file **settings.php** is the only difference with the official version created with composer

# Requirements

- docker
- docker-compose

# One-Click Step

The following command will deploy the database, import the .sql and start the drupal:

```
docker-compose up -d --build
```

# Detailed Steps

- build
- database
- variables
- run

## Build

```
docker build -t drupal .
```

## Database

Instead the classic wizard configuration of drupal, in this version, a pre uploaded database. You could use this script : **database/script.sql** which is the latest of this drupal version 9.3.6 2022 June

## Variables

Traditionally drupal configurations are performed with manual modifications in **settings.php** file. With docker this is not acceptable anymore. This docker version use **getenv()** instead hardcoded values in settings.php. This made it possible to configure the entire drupal with environment variables. If you find more low level configurations, I advice to use **getenv()** and pass the value as environment variable. Currently these are the required variables:

| name  | sample value  | description  |
|---|---|---|
|DATABASE_HOST|10.20.30.40 | mysql database host.
|DATABASE_USERNAME| foo | mysql database user   |
|DATABASE_PASSWORD| changeme | password related to the mysql user  |
|DATABASE_NAME|drupal_db | database name  |
|DATABASE_PORT| 3306  | mysql port |
|ENABLE_VERBOSE_LOG| true   | useful for low level errors |
|HASH_SALT| ****** | required hash value by drupal. Use some value like one of these https://api.wordpress.org/secret-key/1.1/salt/ but be careful with special chars like `$` which is not allowed in ENV variables for unix


Use this command `$(hostname -I| awk '{printf $1}')` to get the ip of the host in which database is running. If you are  using a remote mysql (gcp, aws, azure, etc) set the public domain or ip  in **DB_HOST** var

## Run

Just set the database parameters and run

```
docker run -d --name wordpress -it --rm -p 80:80 \
-e DATABASE_HOST=10.10.10.10 \
-e DATABASE_PORT=3306 \
-e DATABASE_USERNAME=usr_drupal \
-e DATABASE_PASSWORD=changeme \
-e DATABASE_NAME=wordpress \
-e HASH_SALT=changeme \
-e ENABLE_VERBOSE_LOG=false \
-e TZ=America/Lima wordpress:5.7.2
```

## Run with remote variables

Required variables could be configured remotely to avoid shell access.

```
docker run -d --name wordpress -it --rm -p 80:80 \
-e CONFIGURATOR_GET_VARIABLES_FULL_URL=http://foo.com/api/v1/variables?application=drupal \
-e CONFIGURATOR_AUTH_HEADER=apiKey:changeme \
-e TZ=America/Lima wordpress:5.7.2
```

# Open drupal

Finally go to `http://localhost:8080` and enter these credentials:

- user: admin
- password: 123456

Don't forget to change the password. You should see something like this:

![](https://i.ibb.co/wL8Gm1N/drupal-home-page.png)

# For Production

- Set your preferred timezone in TZ variable
- Set complex values in these variables DATABASE_PASSWORD, HASH_SALT
- Change the admin password
- Don't harcode values in the file settings.php. Use environment variables.

# Roadmap

- add more configuration as environment variables: redis, memcahed, aws s3, etc
- wiki
- fix the issues

# Contributors

<table>
  <tbody>
    <td>
      <img src="https://avatars0.githubusercontent.com/u/3322836?s=460&v=4" width="100px;"/>
      <br />
      <label><a href="http://jrichardsz.github.io/">JRichardsz</a></label>
      <br />
    </td>    
    <td style="align:center">
      <img src="https://avatars.githubusercontent.com/u/92831091?s=200&v=4" width="100px;"/>
      <br />
      <label><a href="https://github.com/usil">USIL</a></label>
      <br />
    </td>    
    <td>
      <img src="https://avatars.githubusercontent.com/u/107495075?v=4" width="100px;"/>
      <br />
      <label><a href="https://github.com/softwinperu">Softwinperu</a></label>
      <br />
    </td>    
  </tbody>
</table>
