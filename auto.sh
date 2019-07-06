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
    use_celery='n'
else
    use_celery='y'
fi

# choice for postgres
read -p "use postgres to replace default sqlite [n]:"  use_postgres
if [ -z "$use_postgres" ];then
	use_postgres='n'
fi 

if [ ${use_postgres} == "y" ]; then 
	read -p "Postgres DateBase Name [postgres]:" p_name
        if [ -z "$p_name" ];then
		p_name='postgres'
	fi
	read -p "Postgres DateBase User [postgres]:" p_user
        if [ -z "$p_user" ];then
		p_user='postgres'
	fi
	read -p "Postgres DateBase Password ['']:" p_password
        if [ -z "$p_password" ];then
		p_password=''
	fi
	read -p "Postgres DateBase HOST [127.0.0.1]:" p_host
        if [ -z "$p_host" ];then
		p_host='127.0.0.1'
	fi
	read -p "Postgres DateBase PORT [5432]:" p_port
        if [ -z "$p_port" ];then
		p_port=5432
	fi

else
	:
fi

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

# add database csettings
if [ ${use_postgres} == "y" ]; then 
	# install psycopg2
	pip install psycopg2 -i https://pypi.tuna.tsinghua.edu.cn/simple

        sed -i 's/backends.sqlite3/backends.postgresql_psycopg2/g' $Filename
        sed -i '/sqlite3/d' $Filename
        sed -i  "/ENGINE/a  \        \'NAME\': \'$p_name\',"  $Filename
        sed -i  "/'NAME': '$p_name'/a  \        \'USER\': \'$p_user\'," $Filename
        sed -i  "/'USER': '$p_user'/a  \        \'PASSWORD\': \'$p_password\',"  $Filename
	sed -i  "/'PASSWORD': '$p_password'/a  \        \'HOST\': \'$p_host\',"  $Filename
        sed -i  "/'HOST': '$p_host'/a  \        \'PORT\': $p_port,"  $Filename
fi

# change timezone
sed -i  's/UTC/Asia\/Shanghai/g'  $Filename

# add resrframework
cat djangorestframework.conf >> $Filename


# add celery
if [ ${use_celery} == "y" ]; then
    # rename command/directory
    sed -i "s/test/$project_name/g"  celery_config/celery_worker.conf celery_config/celery_beat.conf
    sed -i "/yourdir/c directory=$Env_folder"  celery_config/celery_worker.conf celery_config/celery_beat.conf
    sed -i "s/mytest/$app_name/g"  celery_config/celery.py
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


