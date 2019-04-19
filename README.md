This repo will serve as a single source of the config files, scripts and steps for setting up a qmail server.


Build instructions:
```
docker build -t qmail:centos-7 . 
```
**Note:** The above will take about 7+ minutes to build. So be patient :)


Run instructions:
```
docker run  -v /sys/fs/cgroup:/sys/fs/cgroup:ro -v /tmp/$(mktemp -d):/run   -P -d qmail:centos-7
```

