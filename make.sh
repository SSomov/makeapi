#!/bin/bash
python3 -m venv env
source env/bin/activate
pip install django django-rest-framework
python -m django --version
# django-admin startproject core .
cat > task.py <<EOL
from core import settings 

print(settings['INSTALLED_APPS'])
EOL
python task.py

# kernel="2.6.39"
# distro="xyz"
# cat >/etc/myconfig.conf <<EOL
# line 1, ${kernel}
# line 2, 
# line 3, ${distro}
# line 4 line
# ... 
# EOL