FROM debian:jessie


# Use fast mirrors
RUN echo "deb http://debian.mirror.neology.co.za/debian jessie main\n"\
         "deb http://security.debian.org/ jessie/updates main contrib non-free\n"\
         "deb http://debian.mirror.neology.co.za/debian jessie-updates main \n"> /etc/apt/sources.list


# Install apt deps
RUN apt-get update && apt-get install -y  \
  build-essential \
  curl \
  freetds-bin \
  freetds-dev \
  git \
  less \
  libbz2-dev \
  libncurses5-dev \
  libncurses5-dev \
  libpq-dev \
  libreadline-dev \
  libsqlite3-dev \
  libssl-dev \
  llvm \
  odbcinst1debian2 \
  openssh-client \
  python3 \
  python3-dev \
  python3-pip \
  tdsodbc \
  tmux \
  unixodbc-dev \
  silversearcher-ag \
  htop \
  iotop \
  vim \
  wget \
  zlib1g-dev \
  zsh


# ODBC
COPY ./odbcinst.ini /etc/odbcinst.ini

# Non-root user set up
RUN useradd -Um -s /bin/zsh craig

# Zsh
USER root
WORKDIR /home/craig
COPY .zshrc .zshrc
RUN chown craig:craig .zshrc
RUN chsh -s /bin/zsh craig


# Vim
USER root
WORKDIR /home/craig
COPY .vimrc .vimrc
COPY solarized.vim .vim/colors/
RUN mkdir -p .vim/autoload .vim/bundle
RUN curl -LSso .vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim
RUN chown -R craig:craig .vim


# Pyenv
USER craig
WORKDIR /home/craig
RUN git clone https://github.com/yyuu/pyenv.git .pyenv
RUN git clone https://github.com/yyuu/pyenv-virtualenv.git .pyenv/plugins/pyenv-virtualenv
# Set up pyenv for use with zsh
RUN echo 'export PYENV_ROOT="$HOME/.pyenv"' >> .zshenv
RUN echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> .zshenv
RUN echo 'eval "$(pyenv init -)"' >> .zshenv
# Set up pyenv for use in build steps
ENV HOME=/home/craig
ENV PYENV_ROOT $HOME/.pyenv
ENV PATH $PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH
RUN pyenv install 3.5.1
RUN pyenv virtualenv 3.5.1 basic
RUN pyenv global basic
RUN pyenv rehash


# Python deps (Should be working with pyenv pip)
USER craig
WORKDIR /home/craig
RUN pip install pip==8.1.2
COPY requirements.txt backend-service/requirements.txt
RUN pip install -r backend-service/requirements.txt


# Source code
USER root
WORKDIR /home/craig
COPY . backend-service
RUN chown -R craig:craig backend-service


USER craig
WORKDIR /home/craig/backend-service


# Set reasonable locale (Python needs a unicode locale.)
# See: https://github.com/docker-library/python/issues/13
ENV LANG C.UTF-8
