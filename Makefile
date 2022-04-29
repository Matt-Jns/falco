include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile
include ../images.Makefile

CHART_NAME := falco
APP_ID ?= $(CHART_NAME)

TRACK ?= 0.31

EXPORTER_TAG ?= exporter
METRICS_EXPORTER_TAG ?= v0.5.1

VERIFY_WAIT_TIMEOUT = 1800

SOURCE_REGISTRY ?= marketplace.gcr.io/google
IMAGE_FALCO ?= $(SOURCE_REGISTRY)/falco:$(TRACK)
IMAGE_FALCO_EXPORTER ?= $(SOURCE_REGISTRY)/falco-exporter:$(EXPORTER_TAG)
IMAGE_PROMETHEUS_TO_SD ?= k8s.gcr.io/prometheus-to-sd:$(METRICS_EXPORTER_TAG)


# Main image
image-$(CHART_NAME) := $(call get_sha256,$(IMAGE_FALCO))

# List of images used in application
ADDITIONAL_IMAGES := falco-exporter prometheus-to-sd

# Additional images variable names should correspond with ADDITIONAL_IMAGES list
image-falco := $(call get_sha256,$(IMAGE_FALCO))
image-falco-exporter := $(call get_sha256,$(IMAGE_FALCO_EXPORTER))
image-prometheus-to-sd := $(call get_sha256,$(IMAGE_PROMETHEUS_TO_SD))

C2D_CONTAINER_RELEASE := $(call get_c2d_release,$(image-$(CHART_NAME)))

BUILD_ID := $(shell date --utc +%Y%m%d-%H%M%S)
RELEASE ?= $(C2D_CONTAINER_RELEASE)-$(BUILD_ID)
NAME ?= $(APP_ID)-1

# Additional variables

ifdef METRICS_EXPORTER_ENABLED
  METRICS_EXPORTER_ENABLED_FIELD = , "metrics.exporter.enabled": $(METRICS_EXPORTER_ENABLED)
endif

APP_PARAMETERS ?= { \
  "name": "$(NAME)", \
  "namespace": "$(NAMESPACE)" \
  $(METRICS_EXPORTER_ENABLED_FIELD) \
}

# c2d_deployer.Makefile provides the main targets for installing the application.
# It requires several APP_* variables defined above, and thus must be included after.
include ../c2d_deployer.Makefile


# Build tester image
app/build:: .build/$(CHART_NAME)/tester
