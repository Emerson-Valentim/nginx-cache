### What is being tested

* If NGINX allows multiple instances sharing the same cache directory.
* If NGINX allows cache invalidation using Cache-Control header.
* If NGINX allows any background no-request cache refresh.
* If NGINX allows outage cache even if cache is not valid anymore.

### How to run
After installing the dependencies with `npm install` simply run `make up` and all the required containers will be set up.

### How to test
There are four variations of request with two configurable headers. The two available headers are;

| Name       | Type | Values      | Description                                      |
|------------|------|-------------|--------------------------------------------------|
|x-invalidate|string|"yes" or"no  |Either Cache-Control will be added or no          |
|x-error     |string|"yes" or "no"|Either an error status code will be returned or no|

You can attach each instance using;
``` shell
docker logs --follow nginx-poc-app-1      # Server
docker logs --follow nginx-poc-cache-1-1  # First cache
docker logs --follow nginx-poc-cache-2-1  # Second cache
docker logs --follow nginx-poc-lb-1       # Load balancer
```

### Conclusions
NGINX can handle shared cache volumes and also invalidate cache using `Cache-Control` header, but it will be applied only if the request reaches the server (in this example). Also, there's no built in way to force refresh requests in background without requiring a new request to trigger it, but it's possible to make a new request immediately if there's no `updating` configured in `proxy_cache_use_stale`. Considering a possible outage of the server, this same configuration key `proxy_cache_use_stale` allows cache even if the cache key is not valid anymore, but only if server responds with `error,timeout,http_500,http_502,http_503,http_504`.