by RAM

# Paquete Openocd

La versión estable para Debian suele estar muy desactualizado para lo que se
suele necesitar. Además no es raro tener que customizar algún archivo de
configuración o hasta cambiar algo de código, así que re empaquetarlo
rápidamente es deseable.

openocd: submodulo git de openocd.
debian:  archivos de control de Debian (tomados de testing).
custom:  archivos nuevos o modificados que no están en el repositorio oficial.
         Idealmente debería estar vacío (todo aportado e incluido en el
         mainstream).

## Armar paquete

Para que pida log de nueva versión:
$ make new

Para generar el paquete sin cambiar log:
$ make old

## Aportes

Parches subidos mediante gerrit de openocd:

* Subidos 12/2012. Correcciones 01/2013. Aceptados 03/2013.
* http://openocd.zylin.com/1095: ft2232_channel option added
  SET le agregó soporte al driver FT2232 para poder seleccionar el canal desde
  los archivos de configuración del cable.
* http://openocd.zylin.com/1096: interface: opendous_ftdi config file added
  http://openocd.zylin.com/1097: opendous_ftdi config file added
  RAM agregó archivos de configuración del cable para los drivers FT2232 y
  FTDI.
* http://openocd.zylin.com/1098: doc: opendous interface based on ft2232H
  RAM documento el cable opendous (basado en chip ft2232h) y la opción de
  selección de canal para el driver FT2232.
