TOPTARGETS := run build clean

SUBDIRS := $(wildcard */.)

$(TOPTARGETS): $(SUBDIRS)
$(SUBDIRS):
		$(MAKE) -C $@ $(MAKECMDGOALS)

.PHONY: $(TOPTARGETS) $(SUBDIRS)

PWA_OMP_MULTI_FILE := cg-pwa-omp-multi.c

parallelize: clean-parallelize
	pwdirectives serial/CG/cg.c:conj_grad:458:5 -o $(PWA_OMP_MULTI_FILE) -- -I serial/common

clean-parallelize:
	rm -f $(PWA_OMP_MULTI_FILE) $(PWA_OMP_ACC_OFFLOAD_FILE)

clean: clean-parallelize $(SUBDIRS)
