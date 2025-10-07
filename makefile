PROTOC := $(shell which protoc)
PLUGIN := $(shell which protoc-gen-openapiv2)

ifeq ($(PROTOC),)
$(error "protoc not found in PATH")
endif

ifeq ($(PLUGIN),)
$(error "protoc-gen-openapiv2 not found in PATH. Install it with: go install github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-openapiv2@latest")
endif

APPS_DIR = apps/smart_home
GRPC_API_DIR = grpc_api
PROTO_DIRS = $(APPS_DIR)/user_service/$(GRPC_API_DIR) \
             $(APPS_DIR)/device_service/$(GRPC_API_DIR) \
             $(APPS_DIR)/heating_service/$(GRPC_API_DIR) \
             $(APPS_DIR)/telemetry_service/$(GRPC_API_DIR)
PROTO_FILES = $(foreach dir,$(PROTO_DIRS),$(wildcard $(dir)/*.proto))

GOOGLEAPIS_DIR := third_party/googleapis

.PHONY: all openapi clean init-submodules

all: openapi

init-submodules:
	@if [ ! -d "$(GOOGLEAPIS_DIR)" ]; then \
		echo "Googleapis submodule not found, cloning..."; \
		git submodule add https://github.com/googleapis/googleapis.git $(GOOGLEAPIS_DIR); \
	fi
	@git submodule update --init --recursive

openapi:
	@mkdir -p docs/api
	@echo "Генерация OpenApi JSON..."
	@$(PROTOC) -I. $(foreach dir,$(PROTO_DIRS),-I$(dir)) \
      -I $(GOOGLEAPIS_DIR) \
      --openapiv2_out=docs/api \
      --openapiv2_opt=allow_merge=true,merge_file_name=internal_services_openapi \
      $(PROTO_FILES)
	@if ! command -v yq >/dev/null 2>&1; then \
		echo "yq не найден. Установите его: https://github.com/mikefarah/yq"; \
		exit 1; \
	fi
	@echo "Генерация YAML из JSON..."
	@yq -o=yaml docs/api/internal_services_openapi.swagger.json > docs/api/internal_services_openapi.yaml
	@echo "Удаление JSON..."
	@rm -f docs/api/internal_services_openapi.swagger.json

clean:
	rm -f docs/api/generated_openapi.yaml