#!/bin/bash

# create project
read -p "project_name [Project Name]:"  project_name
if [ -z "$project_name" ];then
	project_name='ProjectName'
fi

# create app
read -p "project_app [demo]:"  app_name
if [ -z "$app_name" ];then
	app_name='demo'
fi

# if use celery
read -p "use_celery [n]:"  use_celery
if [ -z "$use_celery" ];then
    :
fi
    use_celery='y'

Shell_folder=$(dirname $(readlink -f "$0"))

# dirname shell folder =  project base folder
Env_folder=$(dirname $Shell_folder)

#project settings directory
Project_folder=$Env_folder/$project_name/$project_name

# settings file
Filename=$Project_folder/settings.py

# app directory
App_folder=$Env_folder/$project_name/$app_name

# pip install
echo "install related package ..."
pip install -r requirements.txt

# start project
cd $Env_folder
django-admin startproject $project_name
# start app
cd $project_name
python manage.py startapp $app_name
cd $Shell_folder

# change allowed_hosts
sed -i "/ALLOWED_HOSTS/c ALLOWED_HOSTS = \[\'*\'\]" $Filename
sed -i 's/INSTALLED_APPS/DJANGO_APPS/g' $Filename
sed -i "/MIDDLEWARE/i THIRD_PARTY_APPS = \[\'corsheaders\',\'rest_framework\',\'django_extensions\'\] \n" $Filename
sed -i "/MIDDLEWARE/i LOCAL_APPS = \[\'$app_name\'\] \n" $Filename
sed -i '/MIDDLEWARE/i INSTALLED_APPS = DJANGO_APPS + THIRD_PARTY_APPS + LOCAL_APPS \n' $Filename


#　add cros
sed -i '/App/i \# 跨域增加忽略' $Filename
sed -i '/App/i CORS_ALLOW_CREDENTIALS = True' $Filename
sed -i '/App/i CORS_ORIGIN_ALLOW_ALL = True \n' $Filename
sed -i "/common/i \    \'corsheaders.middleware.CorsMiddleware\'," $Filename


# change timezone
sed -i  's/UTC/Asia\/Shanghai/g'  $Filename

# add resrframework
cat djangorestframework.conf >> $Filename


# add celery
if [ -n "$use_celery" ]; then
    # rename command/directory
    sed -i "s/test/$project_name/g"  celery_config/celery_worker.conf celery_config/celery_beat.conf
    sed -i "/yourdir/c directory=$Env_folder/$project_name"  celery_config/celery_worker.conf celery_config/celery_beat.conf
    sed -i "s/mytest/$project_name/g"  celery_config/celery.py
    cp celery_config/celery_* $App_folder
    cat celery_config/django_celery.conf >> $Filename
    cp celery_config/__init__.py  celery_config/celery.py  $Project_folder
    cp celery_config/tasks.py  $App_folder/
else
    :
fi

# add test view  and change urls
cp test_dir/*.py  $App_folder
sed -i 's/import path/import path,include/g' $Project_folder/urls.py
sed -i "/admin.site.urls/a  \    path(\'test/\', include(\'$app_name.urls\'))," $Project_folder/urls.py

# migrate
cd $Env_folder/$project_name
python manage.py migrate
echo "[****SUCCESS****]: Project initialized, keep up the good work!"
echo "[****SUCCESS****]: Django is running at http://localhost:8000/test/hello_django/, Open your brower to access it!"
python manage.py runserver 0:8000

#if hash chromium-browser 2>/dev/null; then
#    chromium-browser 127.0.0.1:8000/test/hello_django/
#else
#    echo "[****SUCCESS****]: Django is running at http://localhost:8000/test/hello_django/, Open your brower to access it!"
#fi


