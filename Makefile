TORCX_PKG = docker\:9999
ARTIFACTS = rootfs/bin/runc rootfs/bin/docker
ARCH := $(shell go env GOARCH)

.PHONY: build
build: $(TORCX_PKG).torcx.squashfs $(TORCX_PKG).torcx.tgz
	
torcx.squashfs: $(ARTIFACTS)
	mksquashfs rootfs/ $@ -noappend -all-root
torcx.tgz: $(ARTIFACTS)
	tar -C rootfs --owner root --group root -czf "$@" .

.PHONY: %.squashfs
%.squashfs: torcx.squashfs
	mv $< $@

.PHONY: %.tgz
%.tgz: torcx.tgz
	mv $< $@

build/runc:
	git clone https://github.com/opencontainers/runc $@
rootfs/bin/runc: build/runc
	$(MAKE) -C $< release
	install -m 0755 -D $</release/*/runc.$(ARCH) $@

build/docker:
	git clone https://github.com/moby/moby $@
rootfs/bin/docker: build/docker

