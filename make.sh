#!/bin/bash
python3 -m venv env
source env/bin/activate
pip install django wheel django-rest-framework python-socketio
pip freeze > requirements.txt
# python -m django --version
django-admin startproject core .
mkdir core/settings/
touch core/settings/__init__.py
mv core/settings.py core/settings/base.py
cp core/settings/base.py core/settings/development.py
cp core/settings/base.py core/settings/production.py

# cat > task.py <<EOL
# from core import settings 

# print(settings['INSTALLED_APPS'])
# EOL
# python task.py

cat > run.sh <<EOL
#!/bin/bash

export PYTHONPATH=".:$PYTHONPATH"
# export DJANGO_SETTINGS_MODULE="test_settings"

usage() {
    echo "USAGE: \$0 [command]"
    echo "  dev | -d -- run django debug mode"
    echo "  check - run flake8 checks"
    echo "  shell | -s -- open the Django shell"
    echo "  makemigrate - makemigrate Django"
    echo "  migrate | -mi -- migrate Django"
    echo "  reload 26.06.21.sql | -r -- reload base development and migrate"
    echo "  install | -i -- install packages"
    exit 1
}

source env/bin/activate
# export DEBUG=True
export DJANGO_SETTINGS_MODULE=core.settings.development

case "\$1" in
    "dev" | "-d" )
        python3 -m uvicorn core.asgi:application --reload --port 5000  --ws websockets ;;
    "check" )
        flake8 adminplus/ --exclude=tests*.py ;;
    "shell" | "-s" )
        python manage.py shell ;;
    "makemigrate" )
        python manage.py makemigrations ;;
    "migrate" | "-mi" )
        python manage.py migrate ;;
    "reload" | "-r")
        sudo apt install postgresql postgresql-contrib
        sudo -u postgres dropdb psyhologram
        sudo -u postgres createdb psyhologram
        sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'barabani';"
        sudo -u postgres psql psyhologram < \$2
        python manage.py migrate ;;
    "install" | "-i" )
        pip install -r requirements.txt ;;
    * )
        usage ;;
esac
EOL

chmod +x run.sh

cat > core/asgi.py <<EOL
"""custom asgi"""


import os
import socketio
from django.core.asgi import get_asgi_application


sio = socketio.AsyncServer(async_mode='asgi',
                           cors_allowed_origins=['http://127.0.0.1:3000',
                                                 'https://psyhologram.ru'],
                           logger=False) # socketio logger

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "core.settings.production")
application = get_asgi_application()
application = socketio.ASGIApp(sio, application)
EOL