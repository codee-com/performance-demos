TOPTARGETS := run build clean

SUBDIRS := $(wildcard */.)

$(TOPTARGETS): $(SUBDIRS)
$(SUBDIRS):
		$(MAKE) -C $@ $(MAKECMDGOALS)

.PHONY: $(TOPTARGETS) $(SUBDIRS)

PWA_OMP_MULTI_FILE := coulomb-pwa-omp-multi.c
PWA_ACC_OFFLOAD_FILE := coulomb-pwa-acc-offload.c

parallelize: clean-parallelize
	pwdirectives serial/coulomb.c:coulomb:26:2 -o $(PWA_OMP_MULTI_FILE)
	pwdirectives --acc serial/coulomb.c:coulomb:26:2 -o $(PWA_ACC_OFFLOAD_FILE) 
	sed -i 's/copyin(cols, rows, scaleX, scaleY, size, vec\[:\], x0, y0, z0) copyout(mat\[:\])/copyin(cols, rows, scaleX, scaleY, size, vec\[0:size\], x0, y0, z0) copyout(mat\[0:rows\*cols\])/g' $(PWA_ACC_OFFLOAD_FILE)

clean-parallelize:
	rm -f $(PWA_OMP_MULTI_FILE) $(PWA_ACC_OFFLOAD_FILE)

clean: clean-parallelize $(SUBDIRS)
