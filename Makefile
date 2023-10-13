up: app cache lb

app:
	npm run build;
	docker-compose up -d app;

cache:
	docker-compose up -d cache-1 cache-2;

lb:
	docker-compose up -d lb;