MIRROR = http://ftp.se.debian.org
armhf = debian/dists/buster/main/installer-armhf/current/images
sha256sums = $(armhf)/SHA256SUMS

.PHONY: all
all: $(armhf)/netboot/SD-card-images/complete_image.img

.PHONY: clean
clean:
	-rm -r debian

$(armhf)/netboot/SD-card-images/complete_image.img: \
$(armhf)/netboot/SD-card-images/firmware.BeagleBoneBlack.img.gz \
$(armhf)/netboot/SD-card-images/partition.img.gz
	zcat $^ > $@

$(armhf)/%: | $(sha256sums)
	mkdir -p $(dir $@)
	curl --location --silent --output $@ "$(MIRROR)/$@"
	grep '$*' $(sha256sums) | awk '{print $$1, "./$@"}' | sha256sum --check -

$(sha256sums): | $(dir $(sha256sums))
	curl --location --no-progress-meter --output $@ '$(MIRROR)/$@'
$(dir $(sha256sums)): ; mkdir -p $@
