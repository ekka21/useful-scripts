ACCOUNT=
NAME=
r:=us-east-2
t:=latest
APP=$(NAME):$(t)
ECR=$(ACCOUNT).dkr.ecr.$(r).amazonaws.com/$(NAME)

.PHONY: build run tag push login help h
build:
	docker build -t $(APP) .
tag:
	docker tag $(APP) $(ECR):$(t)
push: login
	docker push $(ECR):$(t)
login:
	aws ecr get-login-password --region $(r) | docker login --username AWS --password-stdin $(ECR)

.PHONY: help h
h: help
help: ## Help me!!
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
