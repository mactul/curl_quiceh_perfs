# How to use

Once you have docker and docker-compose installed on your machine and once the docker daemon is running, you must start the docker compose:

```sh
docker-compose build && docker-compose up
```

If done for the first time, this operation will take a little more than 10 minutes

Once the docker-compose is up, quiceh-server is running and you have a container named `client` that can run tests

For example, use:
```sh
docker exec -it client curl-http3-default-perf
```
or
```sh
docker exec -it quiceh-client-default-perf
```

These 2 commands will generate files in the `perf_record` directory.

You can then use
```sh
./visualize_perf.sh perf_record/curl_http3_perf.data
```
or
```sh
./visualize_perf.sh perf_record/quiceh_client_perf.data
```

To visualize graphically the flame graph with the number of cycles taken by each function.


If you want to run a specific command on the client container, other than de default ones provided and still be able to visualize your datas with `./visualize_perf.sh`, you can use the hotspot_perf command in the client container.
An exemple is shown in [quiceh-client-default-perf](./images/curl_quiceh/quiceh-client-default-perf).