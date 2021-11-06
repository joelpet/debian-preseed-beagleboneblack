RELEASE = buster
VERSION = current
DAILY_VERSION = daily
MIRROR = http://ftp.se.debian.org
armhf = debian/dists/$(RELEASE)/main/installer-armhf/$(VERSION)/images
sha256sums = $(armhf)/SHA256SUMS

.PHONY: all
all: out/hd-media.img out/hd-media-daily.img out/netboot.img out/netboot-daily.img

.PHONY: clean
clean:
	-rm -r debian out

example-preseed.txt:
	curl --location --no-progress-meter --output $@ 'https://www.debian.org/releases/$(RELEASE)/example-preseed.txt'

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
	curl --location --no-progress-meter --create-dirs --output $@ "$(MIRROR)/$@"
	grep '$*' $(sha256sums) | awk '{print $$1, "./$@"}' | sha256sum --check -

$(sha256sums): | $(dir $(sha256sums))
	curl --location --no-progress-meter --output $@ '$(MIRROR)/$@'

$(dir $(sha256sums)): ; mkdir -p $@

.PHONY: out/hd-media-daily.img
out/hd-media-daily.img: out/hd-media-daily_$(DAILY_VERSION).img
	ln --force "$<" "$@"

out/hd-media-daily_$(DAILY_VERSION).img: \
		daily-images/armhf/$(DAILY_VERSION)/hd-media/SD-card-images/firmware.BeagleBoneBlack.img.gz \
		daily-images/armhf/$(DAILY_VERSION)/hd-media/SD-card-images/partition.img.gz \
		| out
	zcat $(wordlist 1,2,$^) > $@

daily-images/armhf/$(DAILY_VERSION)/%: | daily-images/armhf/$(DAILY_VERSION)/SHA256SUMS
	curl --location --no-progress-meter --create-dirs --output $@ "https://d-i.debian.org/$@"
	grep '$*' daily-images/armhf/$(DAILY_VERSION)/SHA256SUMS | awk '{print $$1, "./$@"}' | sha256sum --check -

daily-images/armhf/$(DAILY_VERSION)/SHA256SUMS:
	curl --location --no-progress-meter --create-dirs --output $@ 'https://d-i.debian.org/$@'

.PHONY: out/netboot-daily.img
out/netboot-daily.img: out/netboot-daily_$(DAILY_VERSION).img
	ln --force "$<" "$@"

out/netboot-daily_$(DAILY_VERSION).img: \
		daily-images/armhf/$(DAILY_VERSION)/netboot/SD-card-images/firmware.BeagleBoneBlack.img.gz \
		daily-images/armhf/$(DAILY_VERSION)/netboot/SD-card-images/partition.img.gz \
		| out
	zcat $(wordlist 1,2,$^) > $@
