README
======
A starting point for DSOS Python data query.

For Docker Engine installation (Community Edition; CE):
- [docker-ce on Ubuntu](https://docs.docker.com/engine/install/ubuntu/),
- [docker-ce on Fedora](https://docs.docker.com/engine/install/fedora/),
- [docker-ce on CentOS](https://docs.docker.com/engine/install/centos/).

[meminfo.csv](meminfo.csv) is the CSV version of the meminfo container.

```sh
$ docker pull ovishpc/ldms-agg # this contains sos/dsos libraries
$ tar xzf store.tgz # extract meminf-1 and meminfo-2 stores

# Create 'dsos' overlay network
$ docker network create --scope=swarm --attachable -d overlay dsos

# start dsos-1 and dsos-2;
#   dsos-1 provides `/store/meminfo` container with `store/meminfo-1`
#   dsos-2 provides `/store/meminfo` container with `store/meminfo-2`
$ ./start-dsosd-12.sh
$ docker ps # check if they run

# start `dsos-dev` that also use ovishpc/ldms-agg since it is the smallest image
# containing sos/dsos. Override the entrypoint to '/bin/bash'
$ docker run -it --name dsos-dev --hostname dsos-dev --network dsos \
             --entrypoint /bin/bash ovishpc/ldms-agg

# distributed-sos config file; basically inform Sos.Session a list of hosts to
# look for containers.
(dsos-dev) $ cat >dsos.conf <<EOF
dsos-1
dsos-2
EOF

# query dsos database with Python
(dsos-dev) $ python3 -i
Python 3.10.6 (main, Nov 14 2022, 16:10:14) [GCC 11.3.0] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> from sosdb import Sos
>>> session = Sos.Session("dsos.conf")
>>> cont = session.open("/store/meminfo")
>>> q = cont.query(1024*1024)
>>> q.select('SELECT * FROM meminfo')
>>> data = q.next()
>>> data
                                            timestamp  component_id  job_id  app_id  MemTotal  MemFree  MemAvailable  ...  HugePages_Free  HugePages_Rsvd  HugePages_Surp  Hugepagesize  Hugetlb  DirectMap4k  DirectMap2M
2023-03-13 19:53:02.001765 2023-03-13 19:53:02.001765             1       0       0   2031012  1047256       1631228  ...               0               0               0          2048        0       106432      1990656
2023-03-13 19:53:03.002108 2023-03-13 19:53:03.002108             1       0       0   2031012  1047256       1631228  ...               0               0               0          2048        0       106432      1990656
2023-03-13 19:53:04.001401 2023-03-13 19:53:04.001401             1       0       0   2031012  1047256       1631228  ...               0               0               0          2048        0       106432      1990656
2023-03-13 19:53:05.001651 2023-03-13 19:53:05.001651             1       0       0   2031012  1047256       1631228  ...               0               0               0          2048        0       106432      1990656
2023-03-13 19:53:06.001872 2023-03-13 19:53:06.001872             1       0       0   2031012  1047256       1631228  ...               0               0               0          2048        0       106432      1990656
...                                               ...           ...     ...     ...       ...      ...           ...  ...             ...             ...             ...           ...      ...          ...          ...
2023-03-13 21:06:13.001203 2023-03-13 21:06:13.001203             4       0       0   2031012  1165824       1681988  ...               0               0               0          2048        0       102336      1994752
2023-03-13 21:06:14.001232 2023-03-13 21:06:14.001232             4       0       0   2031012  1165824       1681988  ...               0               0               0          2048        0       102336      1994752
2023-03-13 21:06:15.001314 2023-03-13 21:06:15.001314             4       0       0   2031012  1165824       1681988  ...               0               0               0          2048        0       102336      1994752
2023-03-13 21:06:16.001386 2023-03-13 21:06:16.001386             4       0       0   2031012  1165824       1681988  ...               0               0               0          2048

[17568 rows x 56 columns]
>>> type(data)
<class 'pandas.core.frame.DataFrame'>
>>> next_data = q.next()
>>> next_data
>>> type(next_data)
<class 'NoneType'>
>>> # No more data
```
