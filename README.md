# How to use

Once you have docker and docker-compose installed on your machine and once the docker daemon is running, you must start the docker compose:
To do that, use, the `run_docker_compose.sh` script to ensure that every depend file is created.

```sh
./run_docker_compose.sh
```

If done for the first time, this operation will take a little more than 10 minutes

Once the docker-compose is up, quiceh-server, quiche-server and nginx are running.  
You have 2 containers, quiceh-client and quiche-client that you can use for profiling quiceh and quiche.

For example, use:
```sh
docker exec -it quiceh-client curl-http3-default-perf
```
or
```sh
docker exec -it quiceh-client quiceh-client-default-perf
```

These 2 commands will generate files in the `perf_record/quiceh` directory.

You can then use
```sh
./visualize_perf.sh perf_record/quiceh/curl_http3_perf.data
```
or
```sh
./visualize_perf.sh perf_record/quiceh/quiceh_client_perf.data
```

To visualize graphically the flame graph with the number of cycles taken by each function.


If you want to run a specific command on the client container, other than de default ones provided and still be able to visualize your datas with `./visualize_perf.sh`, you can use the hotspot_perf command in the client container.
An exemple is shown in [quiceh-client-default-perf](./images/curl_quiceh/quiceh-client-default-perf).