ARG BASE_IMAGE=wolframresearch/wolframengine
FROM ${BASE_IMAGE} as base

SHELL [ "/bin/bash", "-c" ]

FROM base as builder

USER root

ENV TZ=Asia/Tokyo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && \
    apt-get -qq -y update && \
    apt-get -qq -y install \
      software-properties-common \
      wget curl \ 
      make nodejs build-essential libssl-dev zlib1g-dev libbz2-dev \
      libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev \
      libncursesw5-dev xz-utils tk-dev libffi-dev liblzma-dev git
FROM base

USER root

SHELL [ "/bin/bash", "-c" ]
ENV TZ=Asia/Tokyo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && \
    apt-get -qq -y update && \
    apt-get -qq -y install \
      software-properties-common \
      wget curl \ 
      make nodejs build-essential libssl-dev zlib1g-dev libbz2-dev \
      libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev \
      libncursesw5-dev xz-utils tk-dev libffi-dev liblzma-dev git && \
    apt-get -y autoclean && \
    apt-get -y autoremove && \
    rm -rf /var/lib/apt/lists/*

# Create non-root user "docker" with uid 1000
RUN adduser \
      --shell /bin/bash \
      --gecos "default user" \
      --uid 1000 \
      --disabled-password \
      docker && \
    chown -R docker /home/docker && \
    mkdir -p /home/docker/work && \
    chown -R docker /home/docker/work && \
    mkdir /work && \
    chown -R docker /work && \
    chmod -R 777 /work && \
    mkdir /docker && \
    printf '#!/bin/bash\n\njupyter lab --no-browser --ip 0.0.0.0 --port 8888\n' > /docker/entrypoint.sh && \
    chown -R docker /docker && \
    cp /root/.bashrc /etc/.bashrc && \
    echo 'if [ -f /etc/.bashrc ]; then . /etc/.bashrc; fi' >> /etc/profile && \
    echo "SHELL=/bin/bash" >> /etc/environment

# Use C.UTF-8 locale to avoid issues with ASCII encoding
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

ENV PATH=/home/docker/.local/bin:"${PATH}"

USER docker

ENV HOME=/home/docker
ENV PYENV_ROOT=$HOME/.pyenv
ENV PATH=$PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH
ARG PYTHON_VERSION=3.11.4
RUN git clone https://github.com/pyenv/pyenv.git ~/.pyenv && \
    pyenv install $PYTHON_VERSION && \
    pyenv global $PYTHON_VERSION &&\
    python -m pip install --upgrade pip &&  \
    pip install --no-cache-dir \
    nodejs \
    jupyterlab \
    jupyterlab_code_formatter \
    jupyterlab-git \
    lckr-jupyterlab-variableinspector \
    jupyterlab_widgets \
    ipywidgets \
    import-ipynb

WORKDIR /home/docker
ARG WOLFRAM_ID
ARG WOLFRAM_PASSWORD
RUN git clone https://github.com/WolframResearch/WolframLanguageForJupyter && \
    cd WolframLanguageForJupyter/ && \
    wolframscript \
        -activate \
        -username "${WOLFRAM_ID}" \
        -password "${WOLFRAM_PASSWORD}" && \
    wolframscript -activate && \
    ./configure-jupyter.wls add

ENV USER ${USER}
ENV HOME /home/docker
WORKDIR ${HOME}/work

ENV PATH=${HOME}/.local/bin:${PATH}

# Run with login shell to trigger /etc/profile
# c.f. https://youngstone89.medium.com/unix-introduction-bash-startup-files-loading-order-562543ac12e9
ENTRYPOINT ["/bin/bash", "-l"]

CMD ["/docker/entrypoint.sh"]