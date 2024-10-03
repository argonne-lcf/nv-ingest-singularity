#!/bin/bash

# Ensure necessary directories exist
mkdir -p $PWD/cache
mkdir -p $PWD/data
mkdir -p $PWD/cuda
mkdir -p $PWD/run
mkdir -p $PWD/grafana
mkdir -p $PWD/redisinsight
mkdir -p $PWD/tmp
mkdir -p $PWD/redis_data

# Ensure necessary environment variables are set
export no_proxy=localhost,127.0.0.1
export NO_PROXY=localhost,127.0.0.1
export NGC_API_KEY=${NGC_API_KEY:-ngcapikey}
export DATASET_ROOT=/grand/datascience/atanikanti/nv-ingest/data
export NV_INGEST_ROOT=/grand/datascience/atanikanti/nv-ingest
export NIM_NGC_API_KEY=${NIM_NGC_API_KEY:-$NGC_API_KEY}
export NVIDIA_BUILD_API_KEY=${NVIDIA_BUILD_API_KEY:-${NGC_API_KEY:-ngcapikey}}
export MINIO_BUCKET=${MINIO_BUCKET:-nv-ingest}
export DATASET_ROOT=${DATASET_ROOT:-/path/to/dataset}
export NV_INGEST_ROOT=${NV_INGEST_ROOT:-/path/to/nv-ingest}
export REDIS_CONTAINER=redis-stack_latest.sif
export YOLOX_CONTAINER=nv-yolox-structured-images-v1_0.1.0.sif
export DEPLOT_CONTAINER=deplot_1.0.0.sif
export CACHED_CONTAINER=cached_0.1.0.sif
export PADDLE_CONTAINER=paddleocr_0.1.0.sif
export NV_EMBEDQA_CONTAINER=nv-embedqa-e5-v5_1.0.1.sif
export NV_INGEST_CONTAINER=nv-ingest_24.08.sif
export OTEL_CONTAINER=opentelemetry-collector-contrib_0.91.0.sif
export ZIPKIN_CONTAINER=zipkin_latest.sif
export PROMETHEUS_CONTAINER=prometheus_latest.sif
export GRAFANA_CONTAINER=grafana_latest.sif
# Create environment files for each service

cat <<EOL > redis-env-file.sh
#!/bin/bash
export LANG=C.UTF-8
export LC_ALL=C.UTF-8
EOL

cat <<EOL > yolox-env-file.sh
#!/bin/bash
export LANG=C.UTF-8
export LC_ALL=C.UTF-8
export NIM_HTTP_API_PORT=8000
export NIM_TRITON_LOG_VERBOSE=1
export NGC_API_KEY=$NGC_API_KEY
export CUDA_VISIBLE_DEVICES=1
EOL

cat <<EOL > deplot-env-file.sh
#!/bin/bash
export LANG=C.UTF-8
export LC_ALL=C.UTF-8
export NIM_HTTP_API_PORT=8000
export NIM_TRITON_LOG_VERBOSE=1
export NGC_API_KEY=$NGC_API_KEY
export CUDA_VISIBLE_DEVICES=0
EOL

cat <<EOL > cached-env-file.sh
#!/bin/bash
export LANG=C.UTF-8
export LC_ALL=C.UTF-8
export NIM_HTTP_API_PORT=8000
export NIM_TRITON_LOG_VERBOSE=1
export NGC_API_KEY=$NGC_API_KEY
export CUDA_VISIBLE_DEVICES=1
EOL

cat <<EOL > paddle-env-file.sh
#!/bin/bash
export LANG=C.UTF-8
export LC_ALL=C.UTF-8
export NIM_HTTP_API_PORT=8000
export NIM_TRITON_LOG_VERBOSE=1
export NGC_API_KEY=$NGC_API_KEY
export CUDA_VISIBLE_DEVICES=1
EOL

cat <<EOL > embedding-env-file.sh
#!/bin/bash
export LANG=C.UTF-8
export LC_ALL=C.UTF-8
export NIM_HTTP_API_PORT=8000
export NIM_TRITON_LOG_VERBOSE=1
export NGC_API_KEY=$NGC_API_KEY
export CUDA_VISIBLE_DEVICES=1
EOL

cat <<EOL > nv-ingest-env-file.sh
#!/bin/bash
export LANG=C.UTF-8
export LC_ALL=C.UTF-8
export CACHED_GRPC_ENDPOINT=cached:8001
export CACHED_HTTP_ENDPOINT=""
export DEPLOT_GRPC_ENDPOINT=""
export DEPLOT_HTTP_ENDPOINT=http://deplot:8000/v1/chat/completions
export DOUGHNUT_GRPC_TRITON=triton-doughnut:8001
export INGEST_LOG_LEVEL=INFO
export MESSAGE_CLIENT_HOST=redis
export MESSAGE_CLIENT_PORT=6379
export MINIO_BUCKET=$MINIO_BUCKET
export NGC_API_KEY=$NGC_API_KEY
export NVIDIA_BUILD_API_KEY=$NGC_API_KEY
export OTEL_EXPORTER_OTLP_ENDPOINT=otel-collector:4317
export PADDLE_GRPC_ENDPOINT=paddle:8001
export PADDLE_HTTP_ENDPOINT=""
export REDIS_MORPHEUS_TASK_QUEUE=morpheus_task_queue
export TABLE_DETECTION_GRPC_TRITON=yolox:8001
export TABLE_DETECTION_HTTP_TRITON=""
export YOLOX_GRPC_ENDPOINT=yolox:8001
export YOLOX_HTTP_ENDPOINT=""
export CUDA_VISIBLE_DEVICES=1
EOL

cat <<EOL > zipkin-env-file.sh
#!/bin/bash
export LANG=C.UTF-8
export LC_ALL=C.UTF-8
export JAVA_OPTS="-Xms2g -Xmx2g -XX:+ExitOnOutOfMemoryError"
EOL

# redis
apptainer instance run -C \
    -B ./redis_data:/data \
    -B /grand/datascience/atanikanti/nv-ingest \
    -B ./redis-env-file.sh:/.singularity.d/env/env-file.sh \
    -B ./redisinsight:/redisinsight \
    $REDIS_CONTAINER \
    redis

sleep 5

# yolox
apptainer instance run -C \
    --nv \
    -B ./cache:/home/nvs/.cache \
    -B ./cache:/opt/nim/.cache \
    -B /grand/datascience/atanikanti/nv-ingest \
    -B ./yolox-env-file.sh:/.singularity.d/env/env-file.sh \
    $YOLOX_CONTAINER \
    yolox

sleep 5

# deplot
apptainer instance run -C \
    --nv \
    -B ./cache:/opt/nim/.cache \
    -B /grand/datascience/atanikanti/nv-ingest \
    -B ./deplot-env-file.sh:/.singularity.d/env/env-file.sh \
    $DEPLOT_CONTAINER \
    deplot

sleep 5

# cached
apptainer instance run -C \
    --nv \
    -B ./cache:/home/nvs/.cache \
    -B ./cache:/opt/nim/.cache \
    -B /grand/datascience/atanikanti/nv-ingest \
    -B ./cuda:/usr/local/cuda \
    -B ./cached-env-file.sh:/.singularity.d/env/env-file.sh \
    $CACHED_CONTAINER \
    cached

sleep 5

# paddle
apptainer instance run -C \
    --nv \
    -B ./cache:/home/nvs/.cache \
    -B ./cache:/opt/nim/.cache \
    -B /grand/datascience/atanikanti/nv-ingest \
    -B ./paddle-env-file.sh:/.singularity.d/env/env-file.sh \
    $PADDLE_CONTAINER \
    paddle

sleep 5

# embedding
apptainer instance run -C \
    --nv \
    -B /grand/datascience/atanikanti/nv-ingest \
    -B ./run:/opt/nim/run/nim \
    -B ./cache:/opt/nim/.cache \
    -B ./tmp:/tmp \
    -B ./embedding-env-file.sh:/.singularity.d/env/env-file.sh \
    $NV_EMBEDQA_CONTAINER \
    embedding

sleep 5

# nv-ingest-ms-runtime
apptainer instance run -C \
    --nv \
    -B $DATASET_ROOT:/workspace/data \
    -B /grand/datascience/atanikanti/nv-ingest \
    -B ./nv-ingest-env-file.sh:/.singularity.d/env/env-file.sh \
    $NV_INGEST_CONTAINER \
    nv-ingest-ms-runtime

sleep 5

# zipkin
apptainer instance run -C \
    -B /grand/datascience/atanikanti/nv-ingest \
    -B ./zipkin-env-file.sh:/.singularity.d/env/env-file.sh \
    $ZIPKIN_CONTAINER \
    zipkin

sleep 5

# otel-collector
apptainer instance run -C \
    -B ./config/otel-collector-config.yaml:/etc/otel-collector-config.yaml \
    -B /grand/datascience/atanikanti/nv-ingest \
    $OTEL_COLLECTOR \
    otel-collector \
    "--config=/etc/otel-collector-config.yaml"

sleep 5

# prometheus
apptainer instance run -C \
    -B ./config/prometheus.yaml:/etc/prometheus/prometheus-config.yaml \
    -B /grand/datascience/atanikanti/nv-ingest \
    $PROMETHEUS \
    prometheus \
    "--web.console.templates=/etc/prometheus/consoles" \
    "--web.console.libraries=/etc/prometheus/console_libraries" \
    "--storage.tsdb.retention.time=1h" \
    "--config.file=/etc/prometheus/prometheus-config.yaml" \
    "--storage.tsdb.path=/prometheus" \
    "--web.enable-lifecycle" \
    "--web.route-prefix=/" \
    "--enable-feature=exemplar-storage" \
    "--enable-feature=otlp-write-receiver"

sleep 5

# grafana
apptainer instance run -C \
    -B /grand/datascience/atanikanti/nv-ingest \
    -B ./grafana:/var/lib/grafana \
    $GRAFANA_CONTAINER \
    grafana-service

# Clean up environment files if necessary
# rm yolox-env-file.sh deplot-env-file.sh cached-env-file.sh paddle-env-file.sh embedding-env-file.sh nv-ingest-env-file.sh zipkin-env-file.sh
