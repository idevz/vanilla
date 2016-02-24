## Build

````
wget https://raw.githubusercontent.com/idevz/vanilla/master/docker/Dockerfile \
     https://raw.githubusercontent.com/idevz/vanilla/master/docker/supervisord.conf && \
docker build -t idevz/vanilla .
````

## Create your app

```
docker run -v "$PWD":/tmp --rm idevz/vanilla vanilla new $your_app
```

Here `$your_app` should be the name of your app, such as 'pet_store'.

## Start the server

````
docker run -v "$your_app_dir":/tmp -d -p 9110:9110 idevz/vanilla
````

Here `$your_app_dir` should be where your app locates on, such as '/home/vanilla/pet_store'.
