commit=$(shell git rev-parse --short HEAD)
date=$(shell date +'%Y%m%d-%H%M%S')
REPO=registry.cn-shanghai.aliyuncs.com
NAMESPACE=shuishan
RELEASE_TAG:=release-$(commit)-$(date)
IMAGE_NAME=zzjnotebook
IMAGE_URL=${REPO}/$(NAMESPACE)/$(IMAGE_NAME)

.PHONY: build submodules

build: 
	docker build --rm --no-cache -t ${IMAGE_URL}:$(RELEASE_TAG) -t ${IMAGE_URL} .

submodules:
	git submodule update --init --recursive

release: build
	docker push ${IMAGE_URL}:$(RELEASE_TAG)
	docker push ${IMAGE_URL}

test:
	docker run -it -p 9797:9000 ${IMAGE_URL}

dev:
	hugo server -D