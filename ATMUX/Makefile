TOPTARGETS := run build clean

SUBDIRS := $(wildcard */.)

$(TOPTARGETS): $(SUBDIRS)
$(SUBDIRS):
		$(MAKE) -C $@ $(MAKECMDGOALS)

.PHONY: $(TOPTARGETS) $(SUBDIRS)

PWA_OMP_MULTI_FILE := atmux-pwa-omp-multi.c

parallelize: clean-parallelize
	pwdirectives --explicit-privatization y serial/atmux.c:atmux:22:5 -o $(PWA_OMP_MULTI_FILE) -- -I serial/lib/
	sed -i 's/\/\* y start \*\//0/g' $(PWA_OMP_MULTI_FILE)
	sed -i 's/\/\* y length \*\//n/g' $(PWA_OMP_MULTI_FILE)

clean-parallelize:
	rm -f $(PWA_OMP_MULTI_FILE) $(PWA_OMP_ACC_OFFLOAD_FILE)

clean: clean-parallelize $(SUBDIRS)
