# ex: set tabstop=2 noexpandtab :
.PHONY: build
build:
	@echo "Building ingress-nginx init containers.."
	./build_init_containers.sh $(CONFIG_ENTRY)
