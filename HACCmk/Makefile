TOPTARGETS := run build clean

SUBDIRS := $(wildcard */.)

$(TOPTARGETS): $(SUBDIRS)
$(SUBDIRS):
		$(MAKE) -C $@ $(MAKECMDGOALS)

.PHONY: $(TOPTARGETS) $(SUBDIRS)

PWA_OMP_MULTI_FILE := main-pwa-omp-multi.c

parallelize: clean-parallelize
	pwdirectives --config serial/pw.json serial/main.c:main:132:7 -o $(PWA_OMP_MULTI_FILE)

clean-parallelize:
	rm -f $(PWA_OMP_MULTI_FILE)

clean: clean-parallelize $(SUBDIRS)
