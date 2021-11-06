RELEASE = buster
VERSION = current
MIRROR = http://ftp.se.debian.org
armhf = debian/dists/$(RELEASE)/main/installer-armhf/$(VERSION)/images
sha256sums = $(armhf)/SHA256SUMS

.PHONY: all
all: out/hd-media.img out/netboot.img

.PHONY: clean
clean:
	-rm -r debian out

.PHONY: out/hd-media.img
out/hd-media.img: out/hd-media_$(RELEASE)_$(VERSION).img
	ln --force "$<" "$@"

out/hd-media_$(RELEASE)_$(VERSION).img: \
		$(armhf)/hd-media/SD-card-images/firmware.BeagleBoneBlack.img.gz \
		$(armhf)/hd-media/SD-card-images/partition.img.gz \
		| out
	zcat $(wordlist 1,2,$^) > $@

.PHONY: out/netboot.img
out/netboot.img: out/netboot_$(RELEASE)_$(VERSION).img
	ln --force "$<" "$@"

out/netboot_$(RELEASE)_$(VERSION).img: \
		$(armhf)/netboot/SD-card-images/firmware.BeagleBoneBlack.img.gz \
		$(armhf)/netboot/SD-card-images/partition.img.gz \
		| out
	zcat $(wordlist 1,2,$^) > $@

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
	curl --location --no-progress-meter --output $@ 'https://www.debian.org/releases/$(RELEASE)/example-preseed.txt'
