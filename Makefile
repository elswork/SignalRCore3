SNAME ?= SignalRCore3
NAME ?= elswork/$(SNAME)
VER ?= `cat VERSION`
TAG ?= 3.0-buster-slim
BASENAME ?= mcr.microsoft.com/dotnet/core/aspnet
ARCH2 ?= armv7l
ARCH3 ?= aarch64
GOARCH := $(shell uname -m)
ifeq ($(GOARCH),x86_64)
	GOARCH := amd64
endif

# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

# DOCKER TASKS
# Build the container

debug: ## Build the container
	docker build -t $(NAME):$(GOARCH) \
	--build-arg BASEIMAGE=$(BASENAME):$(TAG) \
	--build-arg VERSION=$(SNAME)_$(GOARCH)_$(VER) .
build: ## Build the container
	docker build --no-cache -t $(NAME):$(GOARCH) \
	--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
	--build-arg VCS_REF=`git rev-parse --short HEAD` \
	--build-arg BASEIMAGE=$(BASENAME):$(TAG) \
	--build-arg VERSION=$(SNAME)_$(GOARCH)_$(VER) \
	. > ../builds/$(SNAME)_$(GOARCH)_$(VER)_`date +"%Y%m%d_%H%M%S"`.txt
tag: ## Tag the container
	docker tag $(NAME):$(GOARCH) $(NAME):$(GOARCH)_$(VER)
push: ## Push the container
	docker push $(NAME):$(GOARCH)_$(VER)
	docker push $(NAME):$(GOARCH)	
deploy: build tag push
manifest: ## Create an push manifest
	docker manifest create $(NAME):$(VER) \
	$(NAME):$(GOARCH)_$(VER) \
	$(NAME):$(ARCH2)_$(VER) \
	$(NAME):$(ARCH3)_$(VER)
	docker manifest push --purge $(NAME):$(VER)
	docker manifest create $(NAME):latest $(NAME):$(GOARCH) \
	$(NAME):$(ARCH2) \
	$(NAME):$(ARCH3)
	docker manifest push --purge $(NAME):latest
start: ## Start Theia IDE
	docker run -d -p 3000:3000 -v "$(pwd):/home/project:cached" $(NAME)