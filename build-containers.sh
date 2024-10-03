#!/bin/bash
apptainer pull docker://redis/redis-stack
apptainer pull docker://nvcr.io/ohlfw0olaadg/ea-participants/nv-yolox-structured-images-v1:0.1.0
apptainer pull docker://nvcr.io/ohlfw0olaadg/ea-participants/deplot:1.0.0
apptainer pull docker://nvcr.io/ohlfw0olaadg/ea-participants/cached:0.1.0
apptainer pull docker://nvcr.io/ohlfw0olaadg/ea-participants/paddleocr:0.1.0
apptainer pull docker://nvcr.io/nim/nvidia/nv-embedqa-e5-v5:1.0.1
apptainer pull docker://nvcr.io/ohlfw0olaadg/ea-participants/nv-ingest:24.08
apptainer pull docker://otel/opentelemetry-collector-contrib:0.91.0
apptainer pull docker://openzipkin/zipkin
apptainer pull docker://prom/prometheus:latest
apptainer pull docker://grafana/grafana
