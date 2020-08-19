# ex: set tabstop=2 noexpandtab :
.PHONY: build
build:
	@echo "Building ingress-nginx init containers.."
	build/build_init_containers.sh $(CONFIG_ENTRY)

.PHONY: upload
upload:
	@echo "Uploading the built containers.."
	build/upload_init_containers.sh $(RELEASE)

.PHONY: example-build
example-build:
	@echo "Building instana-nginx-hello container image.."
	example/build/build_instana_image.sh

.PHONY: example-upload
example-upload:
	@echo "Uploading instana-nginx-hello container image.."
	example/build/upload_instana_image.sh
