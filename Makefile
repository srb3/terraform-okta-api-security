.PHONY: all build test out clean

SHELL = /bin/bash

all: all_default

all_default: build_default test_default
build_default: build_deployment_default
test_default: test_deployment_default
clean_default: clean_deployment_default

build_deployment_default:
	@pushd examples/default; \
	terraform init; \
	terraform apply -auto-approve; \
	popd

test_deployment_default:
	@echo "run tests"

clean_deployment_default:
	@pushd examples/default; \
	terraform destroy -auto-approve; \
	popd
