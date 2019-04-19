FROM centos:7

# Setup systemd as instructed by: https://hub.docker.com/_/centos
RUN ( cd /lib/systemd/system/sysinit.target.wants/; \
  for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
  rm -f /lib/systemd/system/multi-user.target.wants/*;\
  rm -f /etc/systemd/system/*.wants/*;\
  rm -f /lib/systemd/system/local-fs.target.wants/*; \
  rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
  rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
  rm -f /lib/systemd/system/basic.target.wants/*;\
  rm -f /lib/systemd/system/anaconda.target.wants/*;

# Mount the following at container runtime:
# -v /sys/fs/cgroup:/sys/fs/cgroup:ro
# -v /tmp/$(mktemp -d):/run   (fedora / ubuntu)

VOLUME [ "/sys/fs/cgroup" ]

CMD ["/usr/sbin/init"]

EXPOSE 25 80 443 110 143 993 995 587

RUN mkdir scripts

# Copy only the software-packages.sh and perl-modules.* files to the scripts directory.
# We will not copy entire scripts directory at the moment, because we keep adding scripts all the time.
# If we copy entire scripts directory now, Docker will see a change in context,
#   and will start to run the rpm/yum and perl installation steps again. That takes a lot of time.

COPY scripts/rpm-packages.sh  scripts/
COPY scripts/perl-modules.*  scripts/

# Run the two scripts, so we have use cache features . Otherwise each build takes 7 minutes. Not cool!
RUN  scripts/rpm-packages.sh && scripts/perl-modules.sh

# copy rest/all scripts to the scripts/ directory. 
COPY scripts/ scripts/

# copy local copy of various software, just in case.
COPY software software

# ENV:
# The FQDN of the the mail server (this host) is needed so we can configure qmail properly.
# We can't use "hostname -f" because when these scripts run inside a docker container,
#   the "hostname -f" command returns the name of the container.

ENV  QMAIL_FQDN  mail.example.com

# From this point on we can run individual scripts to configure qmail.
RUN     scripts/users-and-groups.sh \
    &&  scripts/download-patch-install-qmail.sh \
    &&  scripts/download-install-ezmlm-idx.sh \
    &&  scripts/download-install-autorespond.sh \
    &&  scripts/download-install-maildrop.sh

# COPY docker-entrypoint.d docker-entrypoint.d
# COPY docker-entrypoint.sh /



