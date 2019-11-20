### Linux:
`只支持linux 测试环境为Ubuntu`，我这边用的是python虚拟环境，也可不需要
##### Set virtualenv

- `mkdir envdir`
- `cd envdir`
- `pipenv --python 3.x`
- `pipenv shell`


##### Auto create 
- `git clone https://github.com/fantasyhh/MyAutoDjango`
- `cd MyAutoDjango`
- `chmod u+x auto.sh`
-  `./auto.sh`


###### Notice
if  you get `you need to install postgresql-server-dev-X.Y for building a server-side extension or libpq-dev for building a client-side application？` when you choose postgresql and `pip install psycopg2`， you should run `sudo apt-get install libpq-dev python-dev` first before  `./auto.sh`
