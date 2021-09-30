TOPTARGETS := run build clean

SUBDIRS := $(wildcard */.)

$(TOPTARGETS): $(SUBDIRS)
$(SUBDIRS):
		$(MAKE) -C $@ $(MAKECMDGOALS)

.PHONY: $(TOPTARGETS) $(SUBDIRS)

PWA_OMP_MULTI_FILE := canny-pwa-omp-multi.c

parallelize: clean-parallelize
	rm -f $(PWA_OMP_MULTI_FILE)
	pwdirectives serial/canny.c:gaussian_smooth:492:4 \
	             serial/canny.c:gaussian_smooth:474:4 \
	             -o $(PWA_OMP_MULTI_FILE)

clean-parallelize:
	rm -f $(PWA_OMP_MULTI_FILE) $(PWA_OMP_ACC_OFFLOAD_FILE)

clean: clean-parallelize $(SUBDIRS)
