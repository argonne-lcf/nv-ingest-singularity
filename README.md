# nv-ingest-singularity
Steps to run nv-ingest on Polaris using apptainer.


# Load apptainer module and setup environment

```bash
source load-modules.sh
```

# Setup nvcr login with nvcr token

```bash
apptainer remote login --username \$oauthtoken docker://nvcr.io
```

# Build container images

```bash
source build-containers.sh
```

# Run container images

```bash
source run-apptainer.sh
```

# TODO

* Fix `--network` for apptainer [portmap](https://apptainer.org/docs/user/1.0/networking.html)
* Fix passing arguments to container for services `prometheus` and `otel-collector`