# ex: set tabstop=2 noexpandtab :
.PHONY: build
build:
	@echo "Building ingress-nginx init containers.."
	build/build_init_containers.sh $(CONFIG_ENTRY)

.PHONY: upload
upload:
	@echo "Uploading the built containers.."
	build/upload_init_containers.sh $(RELEASE)
