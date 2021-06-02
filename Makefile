
#======================================
# => Dependencies
#======================================

#--------------------------------------
# -> Cache
#--------------------------------------
UNAME_OS := $(shell uname -s)
UNAME_ARCH := $(shell uname -m)
UNAME_PLATFORM := $(shell uname -s | tr '[:upper:]' '[:lower:]' | sed 's/darwin/osx/')

# This allows switching between i.e a Docker container and your local setup without overwriting.
CACHE_BASE := .cache

CACHE := $(CACHE_BASE)/$(UNAME_OS)/$(UNAME_ARCH)
# The location where buf will be installed.
CACHE_BIN := $(CACHE)/bin
# Marker files are put into this directory to denote the current version of binaries that are installed.
CACHE_VERSIONS := $(CACHE)/versions
# We do some temporary work here
CACHE_TMP := $(CACHE_BASE)/tmp

# Go tools require that this be set
ifndef GOPATH
	export GOPATH=$(shell go env GOPATH)
endif

# Update the $PATH so we can use buf and protoc directly
export PATH := $(abspath $(CACHE_BIN)):$(abspath $(GOPATH)/bin):$(PATH)
# Update GOBIN to point to CACHE_BIN for source installations
export GOBIN := $(abspath $(CACHE_BIN))
# This is needed to allow versions to be added to Golang modules with go get
export GO111MODULE := on


#--------------------------------------
# -> Versions
#--------------------------------------

# This controls the version of buf to install and use.
BUF_VERSION := 0.19.1
PROTOC_VERSION := 3.15.2
PROTOC_GEN_GO_VERSION := v1.26.0
PROTOC_GEN_GO_GRPC_VERSION := v1.0.0
PROTOC_GEN_GRPC_GATEWAY_VERSION := v2.4.0
PROTOC_GEN_OPENAPI_VERSION := v2.4.0
PROTOC_GEN_VALIDATE_VERSION := v0.6.1
PROTODEP_VERSION := 0.1.3

#--------------------------------------
# -> Downloads
#--------------------------------------

# BUF points to the marker file for the installed version.
# If BUF_VERSION is changed, the binary will be re-downloaded.
BUF := $(CACHE_VERSIONS)/buf/$(BUF_VERSION)
$(BUF):
	@rm -f $(CACHE_BIN)/buf
	@mkdir -p $(CACHE_BIN)
	curl -sSL \
		"https://github.com/bufbuild/buf/releases/download/v$(BUF_VERSION)/buf-$(UNAME_OS)-$(UNAME_ARCH)" \
		-o "$(CACHE_BIN)/buf"
	chmod +x "$(CACHE_BIN)/buf"
	@rm -rf $(dir $(BUF))
	@mkdir -p $(dir $(BUF))
	@touch $(BUF)

PROTOC := $(CACHE_VERSIONS)/protoc/$(PROTOC_VERSION)
$(PROTOC):
	@rm -f $(CACHE_TMP)/protoc.zip
	@rm -f $(CACHE_BIN)/protoc
	@mkdir -p $(CACHE_TMP)
	@mkdir -p $(CACHE_BIN)
	curl -sSL \
		"https://github.com/protocolbuffers/protobuf/releases/download/v$(PROTOC_VERSION)/protoc-$(PROTOC_VERSION)-$(UNAME_PLATFORM)-$(UNAME_ARCH).zip" \
		-o "$(CACHE_TMP)/protoc.zip"
	unzip $(CACHE_TMP)/protoc.zip bin/protoc -d $(CACHE)
	chmod +x "$(CACHE_BIN)/protoc"
	@rm -rf $(dir $(PROTOC))
	@mkdir -p $(dir $(PROTOC))
	@touch $(PROTOC)

PROTOC_GEN_GO := $(CACHE_VERSIONS)/protoc-gen-go/$(PROTOC_GEN_GO_VERSION)
$(PROTOC_GEN_GO):
	$(eval BUF_TMP := $(shell mktemp -d))
	cd $(BUF_TMP); \
	  go get google.golang.org/protobuf/cmd/protoc-gen-go@$(PROTOC_GEN_GO_VERSION)
	@rm -rf $(BUF_TMP)
	@rm -rf $(dir $(PROTOC_GEN_GO))
	@mkdir -p $(dir $(PROTOC_GEN_GO))
	@touch $(PROTOC_GEN_GO)

PROTOC_GEN_GO_GRPC := $(CACHE_VERSIONS)/protoc-gen-go-grpc/$(PROTOC_GEN_GO_GRPC_VERSION)
$(PROTOC_GEN_GO_GRPC):
	$(eval BUF_TMP := $(shell mktemp -d))
	cd $(BUF_TMP); \
	  go get google.golang.org/grpc/cmd/protoc-gen-go-grpc@$(PROTOC_GEN_GO_GRPC_VERSION)
	@rm -rf $(BUF_TMP)
	@rm -rf $(dir $(PROTOC_GEN_GO_GRPC))
	@mkdir -p $(dir $(PROTOC_GEN_GO_GRPC))
	@touch $(PROTOC_GEN_GO_GRPC)

PROTOC_GEN_GRPC_GATEWAY := $(CACHE_VERSIONS)/protoc-gen-grpc-gateway/$(PROTOC_GEN_GRPC_GATEWAY_VERSION)
$(PROTOC_GEN_GRPC_GATEWAY):
	$(eval BUF_TMP := $(shell mktemp -d))
	cd $(BUF_TMP); \
	  go get github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-grpc-gateway@$(PROTOC_GEN_GRPC_GATEWAY_VERSION)
	@rm -rf $(BUF_TMP)
	@rm -rf $(dir $(PROTOC_GEN_GRPC_GATEWAY))
	@mkdir -p $(dir $(PROTOC_GEN_GRPC_GATEWAY))
	@touch $(PROTOC_GEN_GRPC_GATEWAY)

PROTOC_GEN_OPENAPI := $(CACHE_VERSIONS)/protoc-gen-openapiv2/$(PROTOC_GEN_OPENAPI_VERSION)
$(PROTOC_GEN_OPENAPI):
	$(eval BUF_TMP := $(shell mktemp -d))
	cd $(BUF_TMP); \
	  go get github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-openapiv2@$(PROTOC_GEN_OPENAPI_VERSION)
	@rm -rf $(BUF_TMP)
	@rm -rf $(dir $(PROTOC_GEN_OPENAPI))
	@mkdir -p $(dir $(PROTOC_GEN_OPENAPI))
	@touch $(PROTOC_GEN_OPENAPI)

PROTOC_GEN_VALIDATE := $(CACHE_VERSIONS)/protoc-gen-validate/$(PROTOC_GEN_VALIDATE_VERSION)
$(PROTOC_GEN_VALIDATE):
	$(eval BUF_TMP := $(shell mktemp -d))
	cd $(BUF_TMP); \
	  go get github.com/envoyproxy/protoc-gen-validate@$(PROTOC_GEN_VALIDATE_VERSION)
	@rm -rf $(BUF_TMP)
	@rm -rf $(dir $(PROTOC_GEN_VALIDATE))
	@mkdir -p $(dir $(PROTOC_GEN_VALIDATE))
	@touch $(PROTOC_GEN_VALIDATE)

PROTODEP := $(CACHE_VERSIONS)/protodep/$(PROTODEP_VERSION)
$(PROTODEP):
	$(eval BUF_TMP := $(shell mktemp -d))
	cd $(BUF_TMP); \
	  go get github.com/stormcat24/protodep@$(PROTODEP_VERSION)
	@rm -rf $(BUF_TMP)
	@rm -rf $(dir $(PROTODEP))
	@mkdir -p $(dir $(PROTODEP))
	@touch $(PROTODEP)


# deps allows us to install deps without running any checks.
.PHONY: deps
deps: $(BUF) $(PROTOC) $(PROTOC_GEN_GO) $(PROTOC_GEN_GO_GRPC) $(PROTOC_GEN_GRPC_GATEWAY) $(PROTOC_GEN_OPENAPI) $(PROTOC_GEN_VALIDATE) $(PROTODEP)

#--------------------------------------
# -> Third-Party Dependencies
#--------------------------------------

# protodeps downloads our third party proto dependencies
.PHONY: protodeps
protodeps: $(PROTODEP)
	protodep up --force --use-https

#======================================
# => Code Generation
#======================================

# The base directory to use to find *.proto files
PROTOS_BASE_DIR := proto
# The base directory for code generation of proto files
PROTOS_OUT_DIR := .
# The base directory for code generation of swagger files
OPENAPI_OUT_DIR := .

# The files to run protoc on
EXCLUDE := -path ./third_party -prune -o
PROTO_DEFS := $(shell find $(PROTOS_BASE_DIR) $(EXCLUDE) -type f -name '*.proto' -print)
PROTO_GOS := $(patsubst $(PROTOS_BASE_DIR)/%.proto,$(PROTOS_OUT_DIR)/%.pb.go,$(PROTO_DEFS))
PROTO_GOS_GRPC := $(patsubst %.pb.go,%_grpc.pb.go,$(PROTO_GOS))
PROTO_GOS_GATEWAY := $(patsubst %.pb.go,%.pb.gw.go,$(PROTO_GOS))
PROTO_GOS_OPENAPI := $(patsubst $(PROTOS_BASE_DIR)/%.proto,$(OPENAPI_OUT_DIR)/%.swagger.json,$(PROTO_DEFS))
PROTO_GOS_VALIDATE := $(patsubst %.pb.go,%.pb.validate.go,$(PROTO_GOS))

# protos triggers generation for all protos
.PHONY: protos
protos: deps $(PROTO_GOS)

# regenerate the *.pb.go files whenever the source protos change
# regenerate the *_grpc.pb.go files whenever the source protos change
# regenerate the *.pb.gw.go files whenever the source protos change
# regenerate the *.swagger.json files whenever the source protos change
# regenerate the *.pb.validate.go files whenever the source protos change
$(PROTO_GOS) $(PROTO_GOS_GRPC) $(PROTO_GOS_GATEWAY) $(PROTO_GOS_OPENAPI) $(PROTO_GOS_VALIDATE): $(PROTO_DEFS)
	$(eval PROTO_DEF := $(filter $(PROTOS_BASE_DIR)/$(@D)/%.proto,$(^)))
	@echo "🤖 Generating ${@} from $(PROTO_DEF)"
	$(eval PROTO := $(patsubst $(PROTOS_BASE_DIR)/%.proto,%.proto,$(PROTO_DEF)))
	buf image build -o - | protoc --descriptor_set_in=/dev/stdin $(PROTOC_GO_OPT) $(PROTOC_GO_GRPC_OPT) $(PROTOC_GRPC_GATEWAY_OPT) $(PROTOC_OPENAPI_OPT) $(PROTOC_VALIDATE_OPT) $(PROTO)

# Plugins string for go builds (must end in ':')
PROTOC_GO_PLUGINS := plugins=grpc:

# Options string appended to the protoc-gen-go command
PROTOC_GO_OPT := --go_out=paths=source_relative:$(PROTOS_OUT_DIR)

# Options string appended to the protoc-gen-go-grpc build command
PROTOC_GO_GRPC_OPT := --go-grpc_out=paths=source_relative,require_unimplemented_servers=false:$(PROTOS_OUT_DIR)

# Options string appended to grpc-gateway build command
PROTOC_GRPC_GATEWAY_OPT := --grpc-gateway_out=logtostderr=true,paths=source_relative:$(PROTOS_OUT_DIR)

# Options string appended to openapiv2 build command
PROTOC_OPENAPI_OPT := --openapiv2_out=logtostderr=true,json_names_for_fields=false,simple_operation_ids=true:$(OPENAPI_OUT_DIR)

# Options string appended to validator build command
PROTOC_VALIDATE_OPT := --validate_out=lang=go,logtostderr=true,paths=source_relative:$(PROTOS_OUT_DIR)
