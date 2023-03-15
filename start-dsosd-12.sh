#!/bin/bash

SDIR=$(realpath $(dirname $0))


for I in {1,2}; do
	NAME=dsos-${I}
	docker run -dit --name ${NAME} --hostname ${NAME} --network dsos \
	   -v ${SDIR}/store/meminfo-${I}:/store/meminfo:rw \
	   -v ${SDIR}/store/vmstat-${I}:/store/vmstat:rw \
	   -v ${SDIR}/store/procstat-${I}:/store/procstat:rw \
	   --entrypoint /bin/bash \
	   ovishpc/ldms-agg \
		   -c 'rpcbind && dsosd >/var/log/dsosd.log 2>&1'
done
