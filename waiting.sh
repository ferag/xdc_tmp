#!/bin/sh
# waitint.sh

cmd="wget https://raw.githubusercontent.com/ferag/xdc_tmp/master/run_test.sh && /bin/bash run_test.sh"

until ls /datasets/CdP/model_2012-01-01_2012-01-03 '\q'; do
  >&2 echo "Model is unavailable - sleeping"
  sleep 10
done

>&2 echo "Model is ready - executing command"
exec $cmd
