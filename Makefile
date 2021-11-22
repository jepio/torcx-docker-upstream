TORCX_PKG = docker\:9999

.PHONY: build
build: $(TORCX_PKG).torcx.squashfs $(TORCX_PKG).torcx.tgz
	
torcx.squashfs:
	mksquashfs rootfs/ $@ -noappend -all-root
torcx.tgz:
	tar -C rootfs -czf "$@" .

.PHONY: %.squashfs
%.squashfs: torcx.squashfs
	mv $< $@

.PHONY: %.tgz
%.tgz: torcx.tgz
	mv $< $@
