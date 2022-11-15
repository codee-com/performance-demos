TOPTARGETS := run build clean

SUBDIRS := $(wildcard */.)

$(TOPTARGETS): $(SUBDIRS)
$(SUBDIRS):
		$(MAKE) -C $@ $(MAKECMDGOALS)

.PHONY: $(TOPTARGETS) $(SUBDIRS)

PWA_OMP_ACC_OFFLOAD_FILE := main-pwa-acc-offload.c

parallelize: clean-parallelize
	pwdirectives --acc serial/main.c:matmul:15:5 -o $(PWA_OMP_ACC_OFFLOAD_FILE) -- -I serial/include

clean-parallelize:
	rm -f $(PWA_OMP_ACC_OFFLOAD_FILE)

clean: clean-parallelize $(SUBDIRS)
