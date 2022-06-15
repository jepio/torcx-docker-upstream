TORCX_PKG = docker\:9999
ARTIFACTS = rootfs/bin/runc rootfs/bin/docker rootfs/bin/dockerd
ARCH := $(shell go env GOARCH)

.PHONY: build
build: config.json $(TORCX_PKG).torcx.squashfs $(TORCX_PKG).torcx.tgz
	
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
rootfs/bin/dockerd: build/docker
	$(MAKE) -C $< binary
	cd $</bundles/binary-daemon && \
	  install -m 0755 -D -t $(PWD)/rootfs/bin containerd containerd-shim-runc-v2 ctr docker-init docker-proxy dockerd

build/docker-cli:
	git clone https://github.com/docker/cli $@
	mkdir -p build/src/github.com/docker
	ln -sf ../../../docker-cli build/src/github.com/docker/cli
rootfs/bin/docker: build/docker-cli
	DISABLE_WARN_OUTSIDE_CONTAINER=1 GOPATH=$(PWD)/build $(MAKE) -C $< dynbinary
	cd $</build/ && \
	  install -m 0755 -D -t $(PWD)/rootfs/bin docker

.PHONY: clean
clean:
	rm -rf rootfs/bin

config.json: config.yaml
	ct --files-dir . --pretty <$< >$@
