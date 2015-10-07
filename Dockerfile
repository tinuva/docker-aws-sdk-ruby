FROM ruby:2.0

# Copied from evarga/jenkins-slave
# Install a basic SSH server
RUN apt-get update -y
RUN apt-get install -y openssh-server
RUN sed -i 's|session    required     pam_loginuid.so|session    optional     pam_loginuid.so|g' /etc/pam.d/sshd
RUN mkdir -p /var/run/sshd

# Set password for root. We are installing Ruby as root, so need to run as root
RUN echo "root:root" | chpasswd

# Standard SSH port
EXPOSE 22

RUN sed -i -e 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# Set up our Ruby environment - from ruby:2.0-onbuild
# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

RUN mkdir -p /home/jenkins
WORKDIR /home/jenkins

COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock
RUN bundle install

CMD ["/usr/sbin/sshd", "-D"]
