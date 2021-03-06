by RAM

# Repositorio de paquetes Debian

Las versiones estable para Debian suelen estar muy desactualizadas, y con
software de desarrollo electrónico suele ser necesario versiones más nuevas
(por soporte de hardware o nuevas prestaciones convenientes).
Otras veces, nuevamente en desarrollo electrónico, ni siquiera están
empaquetadas (muy nuevas o con componentes no libres).
En este repo hay paquetes de software que suelo utilizar.

## (Re)empaquetamiento Debian

Cuando el paquete ya existe en Debian, podemos reutilizar su directorio de
control de empaquetado (''debian''). Normalmente, lo que hago es:
* Agregar repos de fuentes en /etc/apt/sources.list
```
 deb-src http://http.us.debian.org/debian/ estable main contrib non-free
 deb-src http://http.us.debian.org/debian/ testing main contrib non-free
 deb-src http://http.us.debian.org/debian/ unstable main contrib non-free
```
* Actualizar fuentes de software del sistema:
```
 # apt-get update
```
* Bajar fuentes y dependencias de fabricación del paquete que me interesa:
```
 $ apt-get source openocd/testing
 $ apt-get build-dep openocd/testing
```
* Copiar directorio *debian* y automatizar con Makefile el empaquetado.
