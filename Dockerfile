FROM jenkins/jenkins:2.167
# if we want to install via apt
USER root
# 时区设置
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai  /etc/localtime \
  && echo 'Asia/Shanghai' >/etc/timezone 
RUN apt-get update && apt-get install -y php  curl php-curl php-pear  php-xdebug  php-gd php-mbstring  php-mcrypt php-xml php-mysql php-bcmath php-dev php-zip  ant rsync vim 

RUN wget http://pecl.php.net/get/mongodb-1.5.2.tgz && tar -zxvf mongodb-1.5.2.tgz
RUN cd mongodb-1.5.2 && /usr/bin/phpize && ./configure --with-php-config=/usr/bin/php-config && make && make install
RUN cd ../
RUN rm -f  mongodb-1.5.2.tgz && rm -rf  mongodb-1.5.2

RUN echo "extension=mongodb.so" >> /etc/php/7.0/cli/conf.d/mongodb.ini


# install nodejs

RUN wget https://nodejs.org/dist/v10.13.0/node-v10.13.0-linux-x64.tar.xz && xz -d node-v10.13.0-linux-x64.tar.xz && tar -xvf node-v10.13.0-linux-x64.tar && rm -f node-v10.13.0-linux-x64.tar.xz  && mv node-v10.13.0-linux-x64 /usr/local/node


 
ENV PATH /usr/local/node/bin:$PATH


RUN npm install -g cnpm --registry=http://registry.npm.taobao.org
RUN npm install -g @vue/cli
# drop back to the regular jenkins user - good practice
# drop back to the regular jenkins user - good practice
RUN mkdir /home/jenkins
RUN chown jenkins:jenkins /home/jenkins
USER jenkins
# Install composer, yes we can't install it in $JENKINS_HOME :(
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/home/jenkins
RUN ls -lh /home/jenkins/
# Install required php tools.
RUN /home/jenkins/composer.phar --working-dir="/home/jenkins" -n require phing/phing:2.* notfloran/phing-composer-security-checker:~1.0 \
    phploc/phploc:* phpunit/phpunit:~4.0 pdepend/pdepend:~2.0 phpmd/phpmd:~2.2 sebastian/phpcpd:* \
   squizlabs/php_codesniffer:* mayflower/php-codebrowser:~1.1 codeception/codeception:*
#RUN echo "export PATH=$PATH:/home/jenkins/.composer/vendor/bin" >> /var/jenkins_home/.bashrc 
#设置中国composer源
RUN /home/jenkins/composer.phar config -g repo.packagist composer https://packagist.phpcomposer.com




