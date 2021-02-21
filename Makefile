MIRROR = http://ftp.se.debian.org
armhf = debian/dists/buster/main/installer-armhf/current/images
sha256sums = $(armhf)/SHA256SUMS

.PHONY: all
all: out/netboot.img

.PHONY: clean
clean:
	-rm -r debian out

out/netboot.img: \
		$(armhf)/netboot/SD-card-images/firmware.BeagleBoneBlack.img.gz \
		$(armhf)/netboot/SD-card-images/partition.img.gz \
		| out
	zcat $^ > $@

out/hd-media.img: \
		$(armhf)/hd-media/SD-card-images/firmware.BeagleBoneBlack.img.gz \
		$(armhf)/hd-media/SD-card-images/partition.img.gz \
		out/debian-10.8.0-armhf-netinst.iso \
		| out
	zcat $(wordlist 1,2,$^) > $@

out/debian-10.8.0-armhf-netinst.iso: | out
	curl --location --silent --output "$@" \
		"https://cdimage.debian.org/debian-cd/$(VERSION)/armhf/iso-cd/$(notdir $@)"

out: ; mkdir -p $@

%.gz: %
	gzip --keep --force $<

$(armhf)/%: | $(sha256sums)
	mkdir -p $(dir $@)
	curl --location --silent --output $@ "$(MIRROR)/$@"
	grep '$*' $(sha256sums) | awk '{print $$1, "./$@"}' | sha256sum --check -

$(sha256sums): | $(dir $(sha256sums))
	curl --location --no-progress-meter --output $@ '$(MIRROR)/$@'

$(dir $(sha256sums)): ; mkdir -p $@

example-preseed.txt:
	curl --location --no-progress-meter --output $@ 'https://www.debian.org/releases/stable/example-preseed.txt'
