MIRROR = http://ftp.se.debian.org
armhf = debian/dists/buster/main/installer-armhf/current/images
sha256sums = $(armhf)/SHA256SUMS

.PHONY: all
all: \
		out/netboot.img \
		out/initrd-preseed.gz

.PHONY: clean
clean:
	-rm -r debian out

out/netboot.img: \
		$(armhf)/netboot/SD-card-images/firmware.BeagleBoneBlack.img.gz \
		$(armhf)/netboot/SD-card-images/partition.img.gz \
		| out
	zcat $^ > $@

out: ; mkdir -p $@

out/initrd-preseed: out/netboot_partition/initrd preseed.cfg
	cp $< $@
	echo preseed.cfg | cpio --format=newc --create --append --file=$@

%.gz: %
	gzip --keep --force $<

out/netboot_partition/initrd: out/netboot_partition/initrd.gz
	gunzip --keep --force $<

out/netboot_partition/initrd.gz: mount_point=/media/netboot_partition.img
out/netboot_partition/initrd.gz: out/netboot_partition.img | out/netboot_partition
	udevil mount $< $(mount_point) \
		&& cp -T $(mount_point)/$(notdir $@) $@ \
		; udevil unmount $<

out/netboot_partition: ; mkdir -p $@

out/netboot_partition.img: $(armhf)/netboot/SD-card-images/partition.img.gz | out
	zcat $< > $@

$(armhf)/%: | $(sha256sums)
	mkdir -p $(dir $@)
	curl --location --silent --output $@ "$(MIRROR)/$@"
	grep '$*' $(sha256sums) | awk '{print $$1, "./$@"}' | sha256sum --check -

$(sha256sums): | $(dir $(sha256sums))
	curl --location --no-progress-meter --output $@ '$(MIRROR)/$@'

$(dir $(sha256sums)): ; mkdir -p $@
