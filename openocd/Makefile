# by RAM

ODIR=temp
VENDOR=cmnb-hdl

all:
	$(info * make new    -> Para empaquetar una nueva versión. Pide escribir changelog con nombre de nueva versión.)
	$(info * make old    -> Para empaquetar la última versión. No pide escribir changelog.)
	$(info * make clean  -> Borra archivos generados.)

version:
	dch --local $(VENDOR)

update:
	@git submodule update --init; cd openocd; git checkout master; git pull; ./bootstrap

prepare: update
	rm -fr $(ODIR); mkdir $(ODIR); cp -r openocd/* $(ODIR); cp -r debian $(ODIR); cp -r custom/* $(ODIR)

package: prepare
	cd $(ODIR); debuild -us -uc -b

new: version package

old: package

clean:
	rm -fr $(ODIR)
	rm -fr openocd_*

