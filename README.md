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

## Contributing

Pull requests are welcome. For major changes, please open an issue first
to discuss what you would like to change.

Please make sure to update tests as appropriate.

## License

[MIT](https://choosealicense.com/licenses/mit/)
