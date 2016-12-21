#!/bin/zsh
echo "the current script assumes a debian linux environment with zsh already setup"
echo "Do you wish to continue?"
select yn in "Yes" "No"; do
    case $yn in
        Yes )

#install dependencies in debian
sudo apt-get install -y make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev;
#install pyenv
git clone https://github.com/yyuu/pyenv.git ~/.pyenv;
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zshenv;
echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zshenv;
echo 'eval "$(pyenv init -)"' >> ~/.zshenv;
#install pyenv-virtualenv
git clone https://github.com/yyuu/pyenv-virtualenv.git ~/.pyenv/plugins/pyenv-virtualenv;
echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.zshenv;
exec $SHELL;
#setup the pyenv for simpleApp
pyenv install 3.5.1;
pyenv virtualenv 3.5.1 simpleApp;
echo "simpleApp" > .python-version;
#pip install project dependancies
sudo apt install $(cat Aptfile);
pip install -r requirements.txt;
#install web req
cd web;
npm install;
bower install;
#finish install:
echo"cp backend/config/live.py.sample backend/config/live.py";
cd ../;
python manage.py -c file run-server;
echo "navigate to http://localhost:5000/ should be setup";
;;
No ) exit;;
esac
done
