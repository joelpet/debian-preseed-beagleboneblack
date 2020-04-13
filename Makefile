MIRROR = http://ftp.se.debian.org
armhf = debian/dists/buster/main/installer-armhf/current/images
sha256sums = $(armhf)/SHA256SUMS

.PHONY: all
all: \
		out/netboot.img \
		out/netboot-preseed.img

.PHONY: clean
clean:
	-rm -r debian

out: ; mkdir -p $@

out/netboot.img: \
		$(armhf)/netboot/SD-card-images/firmware.BeagleBoneBlack.img.gz \
		$(armhf)/netboot/SD-card-images/partition.img.gz \
		| out
	zcat $^ > $@

out/netboot-preseed.img: \
		$(armhf)/netboot/SD-card-images/firmware.BeagleBoneBlack.img.gz \
		out/netboot_partition-preseed.img.gz \
		| out
	zcat $^ > $@

out/netboot_partition-preseed.img.gz: out/netboot_partition-preseed.img
	gzip --keep $<

out/netboot_partition-preseed.img: out/netboot_partition-preseed
	dd if=/dev/zero of=$@ bs=1M count=50

out/netboot_partition-preseed: \
		out/netboot_partition.img \
		preseed.cfg
	udevil mount $< \
		; cp -rT /media/$(notdir $<) $@ \
		; udevil unmount $<
	gunzip $@/initrd.gz
	echo preseed.cfg | cpio --format=newc --create --append --file=$@/initrd
	gzip $@/initrd

out/netboot_partition.img: $(armhf)/netboot/SD-card-images/partition.img.gz | out
	zcat $< > $@

$(armhf)/%: | $(sha256sums)
	mkdir -p $(dir $@)
	curl --location --silent --output $@ "$(MIRROR)/$@"
	grep '$*' $(sha256sums) | awk '{print $$1, "./$@"}' | sha256sum --check -

$(sha256sums): | $(dir $(sha256sums))
	curl --location --no-progress-meter --output $@ '$(MIRROR)/$@'
$(dir $(sha256sums)): ; mkdir -p $@
