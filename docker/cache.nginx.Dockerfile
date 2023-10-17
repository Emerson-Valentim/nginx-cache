FROM alpine

COPY ./docker/cache.conf /var/tmp/nginx.conf
RUN sed -i 's/${APP}/app/g' /var/tmp/nginx.conf

ENTRYPOINT ["tail", "-f", "/dev/null"]

FROM nginx:1.24.0-alpine-slim

COPY --from=0 /var/tmp/nginx.conf /etc/nginx/nginx.conf
