# pixelfed-docker

Run pixelfed in a docker compose environment

## Requirements

You need to have the following CLI installed and set up.

- `docker` with the [compose plugin](https://docs.docker.com/compose/install/linux/).

## Installation

Pull the docker images
```shell
docker compose pull
```

Run the setup script
```shell
./setup.sh
```

Start the database
```shell
docker compose up -d database
```

Run the migrations
```shell
docker compose --profile migration up pixelfed-migrations
```

## Usage

Start the whole stack

```shell
docker compose up -d
```

Get a shell inside the pixelfed container (to run commands like `php artisan user:create` e.g.)

```shell
docker compose exec pixelfed sh
```

# Advanced Usage
You can add additional env var (e.g. for S3) in the `.env.extra` file. Refer to the [pixelfed documentation](https://docs.pixelfed.org/technical-documentation/config/) for more informations.

## Contributing

Pull requests are welcome. For major changes, please open an issue first
to discuss what you would like to change.

Please make sure to update tests as appropriate.

## License

[MIT](https://choosealicense.com/licenses/mit/)
