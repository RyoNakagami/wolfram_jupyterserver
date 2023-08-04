https://www.wolfram.com/engine/free-license/

docker run \
  --rm \
  -ti \
  --publish 8888:8888 \
  --user $(id -u $USER):$(id -g $USER) \
  --volume $PWD:/home/docker/work \
  ryonak/wolfram-jupyterserver:latest
