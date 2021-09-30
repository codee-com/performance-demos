TOPTARGETS := run build clean

SUBDIRS := $(wildcard */.)

$(TOPTARGETS): $(SUBDIRS)
$(SUBDIRS):
		$(MAKE) -C $@ $(MAKECMDGOALS)

.PHONY: $(TOPTARGETS) $(SUBDIRS)

PWA_OMP_MULTI_FILE := pi-pwa-omp-multi.c
PWA_OMP_ACC_OFFLOAD_FILE := pi-pwa-acc-offload.c

parallelize: clean-parallelize
	pwdirectives serial/pi.c:main:31:5 -o $(PWA_OMP_MULTI_FILE)
	pwdirectives --acc serial/pi.c:main:31:5 -o $(PWA_OMP_ACC_OFFLOAD_FILE)

clean-parallelize:
	rm -f $(PWA_OMP_MULTI_FILE) $(PWA_OMP_ACC_OFFLOAD_FILE)

clean: clean-parallelize $(SUBDIRS)
