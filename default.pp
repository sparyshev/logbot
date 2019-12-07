exec { 'install "Development Tools"':
  command => '/bin/yum -y group install "Development Tools"',
}

exec { 'Installation of epel':
  command => '/bin/yum -y install epel-release',
}

exec { 'Python packages installation':
  command => '/bin/yum -y install python-pip python-devel python-six',
}

###########################uWSGI Install##################################

exec { 'Install uWSGI':
  command => '/bin/pip install --upgrade pip && /bin/pip install uwsgi',
}

exec { 'Configure uWSGI ini file':
  command => '/bin/mkdir -p /etc/uwsgi/sites && /bin/echo -e "[uwsgi]
 
 # Project directory, Python directory
 chdir = /home/askbot/app/myapp
 home = /home/askbot/app/
 static-map = /m=/home/askbot/app/myapp/static
 wsgi-file = /home/askbot/app/myapp/django.wsgi
 
 master = true
 processes = 5
 
 # Askbot will running under the sock file
 socket = /run/uwsgi/askbot.sock
 chmod-socket = 664
 uid = askbot
 gid = nginx
 vacuum = true
 
 # uWSGI Log file
 logto = /var/log/uwsgi.log" > /etc/uwsgi/sites/askbot.ini',
}

exec { 'Configure uWSGI service file':
  command => '/bin/echo -e "[Unit]
 Description=uWSGI Emperor service
 
 [Service]
 ExecStartPre=/bin/bash -c \'mkdir -p /run/uwsgi; chown askbot:nginx /run/uwsgi\'
 ExecStart=/bin/uwsgi --emperor /etc/uwsgi/sites
 Restart=always
 KillSignal=SIGQUIT
 Type=notify
 NotifyAccess=all
 
 [Install]
 WantedBy=multi-user.target" > /etc/systemd/system/uwsgi.service',
}

exec { 'uWSGI enable':
   command => '/bin/sudo systemctl daemon-reload && /bin/sudo systemctl enable uwsgi',
}


###########################NGINX Install##################################

exec { 'Nginx Install':
  command => '/bin/yum -y install nginx',
}

exec { 'Nginx reconfigure':
  command => '/bin/echo -e "server {
         listen 80;
         server_name askbot.me www.askbot.me;
         location / {
         include         uwsgi_params;
         uwsgi_pass      unix:/run/uwsgi/askbot.sock;
    }
 }" > /etc/nginx/conf.d/askbot.conf',
}

exec { 'Nginx Test Configuration':
  command => '/bin/sudo nginx -t',
}

exec { 'Nginx restart':
   command => '/bin/sudo systemctl start nginx',
}

###########################PostgreSQL Install#############################

exec { 'PostgreSQL packages installation':
  command => '/bin/yum -y install postgresql-server postgresql-devel postgresql-contrib',
}

exec { 'Postgresql init':
  command => '/bin/postgresql-setup initdb',
}

exec { 'Startung and enabling postgresql service':
  command => '/bin/systemctl start postgresql && /bin/systemctl enable postgresql',
}

exec { 'Install psycopg2':
  command => '/bin/pip install psycopg2',
}

exec { 'Setup password for user postgres':
  command => '/bin/sudo -u postgres echo 123456 | /bin/passwd --stdin postgres',
}

exec { 'create database askbotdb in postgresql':
  command => '/bin/sudo -u postgres -H -- psql -c "create database askbotdb;"',
}

exec { 'Create user taras in postgresql':
  command => '/bin/sudo -u postgres -H -- psql -c "create user taras with password \'123456\'"',
}

exec { 'Grant priveleges to user taras by askbotdb database':
  command => '/bin/sudo -u postgres -H -- psql -c "grant all privileges on database askbotdb to taras;"',
}

exec { 'Change postgresql config file':
  command => '/bin/echo -e "local   all             all                                     md5\nhost    all             all             127.0.0.1/32            md5\nhost    all             all             ::1/128                 md5" > /var/lib/pgsql/data/pg_hba.conf',
}

exec { 'restarting postgresql':
  command => '/bin/systemctl restart postgresql',
}

#exec { 'Adding user askbot':
#  command => '/sbin/useradd askbot && echo askbot | passwd --stdin askbot && usermod -a -G wheel askbot',
#}

exec { 'Upgrade pip and install virtualenv six':
  command => '/bin/pip install --upgrade pip && /bin/pip install virtualenv six==1.10',
}
