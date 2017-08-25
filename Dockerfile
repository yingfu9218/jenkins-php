FROM jenkins
# if we want to install via apt
USER root
RUN apt-get update && apt-get install -y  ant rsync vim ansible
RUN apt-get update \
  && apt-get install -y \
	  php  curl php-pear php-cli php-sqlite php-curl php-gd php-xdebug php-codecoverage \
	  phpunit phploc php-codesniffer pdepend phpmd phpcpd phpdox \
# drop back to the regular jenkins user - good practice
RUN mkdir /home/jenkins
RUN chown jenkins:jenkins /home/jenkins
USER jenkins
# Install composer, yes we can't install it in $JENKINS_HOME :(
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/home/jenkins

# Install required php tools.
#RUN /home/jenkins/composer.phar --working-dir="/home/jenkins" -n require phing/phing:2.* notfloran/phing-composer-security-checker:~1.0 \
#    phploc/phploc:* phpunit/phpunit:~4.0 pdepend/pdepend:~2.0 phpmd/phpmd:~2.2 sebastian/phpcpd:* \
#    squizlabs/php_codesniffer:* mayflower/php-codebrowser:~1.1 codeception/codeception:*
RUN echo "export PATH=$PATH:/home/jenkins/.composer/vendor/bin" >> $JENKINS_HOME/.bashrc # Keep dreaming!
