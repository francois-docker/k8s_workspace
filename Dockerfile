# This Dockerfile deploy a keystone container :
#       based on ubuntu:14.04, it runs the keystone source code from branch stable/icehouse
#       it has to be linked to a mysql container named db-keystone :
#               -
#
FROM ubuntu:14.04
MAINTAINER Francois Billant <fbillant@gmail.com>

EXPOSE 22 80 2003 4505 4506

ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN apt-get update && \ 
apt-get -y install wget

RUN echo deb http://ppa.launchpad.net/saltstack/salt/ubuntu trusty main | tee /etc/apt/sources.list.d/saltstack.list && \
wget -q -O- "http://keyserver.ubuntu.com:11371/pks/lookup?op=get&search=0x4759FA960E27C0A6" | sudo apt-key add - && \
apt-get update


RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add - && \
apt-get update && \
apt-get upgrade -y

# Install requirements
RUN apt-get install -y curl build-essential openssl libssl-dev apache2 libapache2-mod-wsgi libcairo2 supervisor python-cairo libpq5 postgresql python-m2crypto python-virtualenv git python-dev swig libzmq-dev g++ postgresql-9.1 postgresql-server-dev-9.1 libcairo2-dev python-pip libpq-dev ruby debhelper python-mock python-configobj cdbs gem ruby1.9.1 ruby1.9.1-dev make devscripts software-properties-common python-support

# Install node 0.10.10
RUN cd /root/ && \
git clone https://github.com/joyent/node.git && \
cd node/ && \
git checkout v0.10.10 && \
./configure && \
make -j4 && \
make install

# Install npm
RUN mkdir /root/npm && \
cd /root/npm && \
wget --no-check-certificate https://npmjs.org/install.sh && \
sh install.sh 

# Install dependencies via npm
RUN npm install -g bower && \
npm install -g coffee-script && \
npm install -g grunt-cli

# Install dependencies via gem
RUN gem install compass && \
gem install sass

# Create calamari .deb packages
RUN cd /root && \
git clone https://github.com/ceph/calamari.git && \
cd calamari && \
cd debian && \
mv source source.old && \
cd .. && \
dpkg-buildpackage

RUN cd /root && \
git clone https://github.com/ceph/calamari-clients.git && \
cd calamari-clients/ && \
make build-real


RUN cd /root && \
git clone https://github.com/ceph/Diamond.git && \
cd Diamond/ && \
git checkout calamari && \
dpkg-buildpackage

# Install calamari .deb packages
RUN apt-get install -y debconf-utils dmidecode libjs-jquery libzmq3 python-apt python-async python-crypto python-gevent python-git python-gitdb python-greenlet python-jinja2 python-mako python-markupsafe python-msgpack python-openssl python-pam python-pyasn1 python-serial python-smmap python-sqlalchemy python-sqlalchemy-ext python-twisted python-twisted-bin python-twisted-conch python-twisted-core python-twisted-lore python-twisted-mail python-twisted-names python-twisted-news python-twisted-runner python-twisted-web python-twisted-words python-txamqp python-yaml python-zmq python-zope.interface salt-common salt-master salt-minion && \
cd /root && \
dpkg -i *.deb


# Install calamari content
RUN cd /root/calamari-clients/ && \
mkdir /opt/calamari/webapp/content && \
cp -avr dashboard/dist /opt/calamari/webapp/content/dashboard && \
cp -avr login/dist /opt/calamari/webapp/content/login && \
cp -avr manage/dist /opt/calamari/webapp/content/manage && \
cp -avr admin/dist /opt/calamari/webapp/content/admin

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Fix postgres config
sed -i 's/local   all             all                                     peer/local   all             all                                     md5/" /etc/postgresql/9.1/main/pg_hba.conf
sed -i 's/local   all             all                                     peer/local   all             all                                     md5/" /etc/postgresql/9.3/main/pg_hba.conf

#calamari-ctl initialize

#CMD cd /config && ./config.sh && ./run.sh
CMD ["/usr/bin/supervisord"]
