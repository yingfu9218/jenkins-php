FROM jenkins:2.60.3
# if we want to install via apt
USER root
# 时区设置
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai  /etc/localtime \
  && echo 'Asia/Shanghai' >/etc/timezone 
RUN apt-get update && apt-get install -y php  curl php-curl php-pear  php-xdebug  php-gd php-mbstring  php-mcrypt php-xml php-mysql php-bcmath php-dev   ant rsync vim ansible

RUN wget http://pecl.php.net/get/mongodb-1.5.2.tgz && tar -zxvf mongodb-1.5.2.tgz
RUN cd mongodb-1.5.2 && /usr/bin/phpize && ./configure --with-php-config=/usr/bin/php-config && make && make install
RUN cd ../
RUN rm -f  mongodb-1.5.2.tgz && rm -rf  mongodb-1.5.2

RUN echo "extension=mongodb.so" >> /etc/php/7.0/cli/conf.d/mongodb.ini


# install nodejs
# gpg keys listed at https://github.com/nodejs/node#release-team
RUN set -ex \
  && for key in \
    9554F04D7259F04124DE6B476D5A82AC7E37093B \
    94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
    FD3A5288F042B6850C66B31F09FE44734EB7990E \
    71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
    DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
    B9AE9905FFD7803F25714661B63B535A4C206CA9 \
    C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
    56730D5401028683275BD23C23EFEFE93C4CFFFE \
  ; do \
    gpg --keyserver pgp.mit.edu --recv-keys "$key" || \
    gpg --keyserver keyserver.pgp.com --recv-keys "$key" || \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key" ; \
  done

ENV NPM_CONFIG_LOGLEVEL info
ENV NODE_VERSION 8.4.0

RUN ARCH= && dpkgArch="$(dpkg --print-architecture)" \
  && case "${dpkgArch##*-}" in \
    amd64) ARCH='x64';; \
    ppc64el) ARCH='ppc64le';; \
    s390x) ARCH='s390x';; \
    arm64) ARCH='arm64';; \
    armhf) ARCH='armv7l';; \
    *) echo "unsupported architecture"; exit 1 ;; \
  esac \
  && curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-$ARCH.tar.xz" \
  && curl -SLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
  && gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc \
  && grep " node-v$NODE_VERSION-linux-$ARCH.tar.xz\$" SHASUMS256.txt | sha256sum -c - \
  && tar -xJf "node-v$NODE_VERSION-linux-$ARCH.tar.xz" -C /usr/local --strip-components=1 \
  && rm "node-v$NODE_VERSION-linux-$ARCH.tar.xz" SHASUMS256.txt.asc SHASUMS256.txt \
  && ln -s /usr/local/bin/node /usr/local/bin/nodejs

ENV YARN_VERSION 0.27.5

  
RUN npm install -g cnpm --registry=http://registry.npm.taobao.org
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




