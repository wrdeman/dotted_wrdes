#!/bin/bash

# sudo pip install flake8
# sudo pip install ropemacs

sudo rm /usr/bin/emacs
sudo cp emacs/emacs_usr /usr/bin/emacs
sudo cp emacs/emacs_init /etc/init.d/emacs
sudo chmod 775 /usr/bin/emacs
sudo chmod 775 /etc/init.d/emacs
