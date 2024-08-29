#!/bin/sh
if [ "${pipeline_env:?}" = 'local' ]; then
  docker exec buildx_buildkit_cibuilder0 /bin/sh -c "echo '172.25.3.202 registry.hrz.uni-marburg.de' >> /etc/hosts"
  docker exec buildx_buildkit_cibuilder0 /bin/sh -c "ping -c 3 registry.hrz.uni-marburg.de"
fi
