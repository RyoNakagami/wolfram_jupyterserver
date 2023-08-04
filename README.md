# wolfram_jupyterserver

- Docker image with Jupyter Lab and Wolfram Language Engine kernel for Jupyter

This repository is based on the following repositories

- [pyenv](https://github.com/pyenv/pyenv)
- [wolfram-jupyter](https://github.com/matthewfeickert/wolfram-jupyter)
- [wolframresearch/wolframengine](https://hub.docker.com/r/wolframresearch/wolframengine)
- [WolframLanguageForJupyter](https://github.com/WolframResearch/WolframLanguageForJupyter)


## Docker features

The Docker image contains:

- pyenv
    - It make you able to choose any python version as long as it is managed in pyenv repository
- Wolfram Language Engine v13.2.0
- Jupyter Lab
- Wolfram Language kernel for Jupyter


## Prerequisites
### Must have

- Wolfram account
- [Free Wolfram Engine License ](https://www.wolfram.com/engine/free-license/)
- `jq` command
    - [jq official document](https://jqlang.github.io/jq/)

### Better to have

- [GnuPG > gpg](https://www.gnupg.org/documentation/manuals/gnupg24/gpg.1.html)

## Build

```bash
$ bash ./build.sh <your-config-json-file>
```

config json file must be formatted as follows:

```json
{
    "WOLFRAM_ID":"your Wolfram ID",
    "WOLFRAM_PASSWORD":"your Wolfram ID password"
}
```

Keeping config info in a raw data might cause a safty issue. So, I strongly recommend that
the json file be gpg-encrypted. `./build.sh` can automatically detect whether your config file is json file or gpg file 
by checking its file extension.


## Usage

After running the following command, Jupyter Lab actumatically starts up and it becomes accessible via your web-browser.

```
docker run \
  --rm \
  -ti \
  --publish 8888:8888 \
  --user $(id -u $USER):$(id -g $USER) \
  --volume $PWD:/home/docker/work \
  ryonak/wolfram-jupyterserver:latest
```

## Documentation

For more info, please check [this Documentation](https://ryonakagami.github.io/2023/03/09/wolfram-engine-setup/), written in Japanese
