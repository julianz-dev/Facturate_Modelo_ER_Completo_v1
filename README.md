# Facturate — Modelo Entidad-Relación

Repositorio del modelo entidad-relación (ER) completo de **Facturate**, un sistema de recaudo digital simple orientado a pequeños negocios.

Este repositorio reúne la representación visual y las fuentes editables del modelo de datos, organizadas por módulos funcionales. Su propósito es facilitar la consulta de las entidades, sus atributos y las relaciones documentadas entre ellas.

## Resumen del modelo

La versión publicada en este repositorio documenta:

| Elemento | Cantidad |
|---|---:|
| Módulos funcionales | 10 |
| Entidades / tablas | 61 |
| Campos documentados | 310 |
| Relaciones FK representadas | 90 |

> **Versión de referencia:** Modelo ER v1.0, elaborado a partir del archivo fuente `BaseDeDatos_Facturate(5).xlsx`.

## Organización del repositorio

```text
Facturate_Modelo_ER_Completo_v1/
│
├── diagramas_svg/
│   ├── 00_Resumen_Modulos.svg
│   ├── 01_Modelo_Completo.svg
│   └── diagramas detallados de los módulos A–J
│
├── fuentes_dot/
│   ├── 00_Resumen_Modulos.dot
│   ├── 01_Modelo_Completo.dot
│   └── fuentes Graphviz de los módulos A–J
│
├── vistas_png/
│   ├── 00_Resumen_Modulos.png
│   ├── 01_Modelo_Completo.png
│   └── vistas PNG de los módulos A–J
│
├── relaciones_fk.csv
├── LEEME.txt
└── index.html
```

### Descripción de los archivos

- **`diagramas_svg/`**: diagramas en formato SVG, adecuados para ampliar y consultar los detalles sin pérdida de calidad.
- **`fuentes_dot/`**: archivos fuente de Graphviz (`.dot`) que permiten editar y regenerar los diagramas.
- **`vistas_png/`**: versiones PNG para consulta rápida y uso en documentos o presentaciones.
- **`relaciones_fk.csv`**: listado de las relaciones documentadas, con tabla padre, tabla hija, columnas FK, opcionalidad, unicidad y observaciones.
- **`LEEME.txt`**: notas sobre la fuente, la notación, los criterios de representación y los puntos pendientes de validación.
- **`index.html`**: página de navegación para abrir las vistas generales y los diagramas detallados.

## Módulos funcionales

El modelo se divide en diez módulos:

| Código | Módulo |
|---|---|
| A | Usuarios y negocio |
| B | Catálogo e inventario |
| C | Compras y gastos |
| D | Ventas |
| E | Facturación |
| F | Configuración |
| G | Caja |
| H | Devoluciones |
| I | Offline |
| J | Portal y soporte |

## Visualización de los diagramas

Puedes consultar el modelo desde la página de navegación:

**[Abrir visualizador del modelo ER](https://julianz-dev.github.io/Facturate_Modelo_ER_Completo_v1/)**

También puedes abrir directamente las vistas principales:

- [Mapa de módulos (SVG)](diagramas_svg/00_Resumen_Modulos.svg)
- [Modelo ER completo (SVG)](diagramas_svg/01_Modelo_Completo.svg)
- [Modelo ER completo (PNG)](vistas_png/01_Modelo_Completo.png)
- [Registro de relaciones FK (CSV)](relaciones_fk.csv)
- [Notas y convenciones](LEEME.txt)

### Diagramas por módulo

| Módulo | Diagrama SVG |
|---|---|
| A. Usuarios y negocio | [Abrir](diagramas_svg/01_A_USUARIOS_Y_NEGOCIO.svg) |
| B. Catálogo e inventario | [Abrir](diagramas_svg/02_B_CAT_LOGO_E_INVENTARIO.svg) |
| C. Compras y gastos | [Abrir](diagramas_svg/03_C_COMPRAS_Y_GASTOS.svg) |
| D. Ventas | [Abrir](diagramas_svg/04_D_VENTAS.svg) |
| E. Facturación | [Abrir](diagramas_svg/05_E_FACTURACI_N.svg) |
| F. Configuración | [Abrir](diagramas_svg/06_F_CONFIGURACI_N.svg) |
| G. Caja | [Abrir](diagramas_svg/07_G_CAJA.svg) |
| H. Devoluciones | [Abrir](diagramas_svg/08_H_DEVOLUCIONES.svg) |
| I. Offline | [Abrir](diagramas_svg/09_I_OFFLINE.svg) |
| J. Portal y soporte | [Abrir](diagramas_svg/10_J_PORTAL_SOPORTE.svg) |

## Notación de relaciones

Los diagramas utilizan notación **Crow's Foot**:

- Una barra (`|`) en el extremo del padre representa uno.
- Un círculo junto a la pata de cuervo en el extremo hijo representa cero o muchos.
- Un círculo junto a la barra en el extremo del padre indica que la FK es opcional (`NULL`).
- En una FK marcada como única (`UNIQUE`), el extremo hijo se representa como cero o uno.
- Las etiquetas de las relaciones identifican las columnas FK.
- Las relaciones señaladas como **compuestas** agrupan varias columnas en una FK compuesta, según la definición documentada en el archivo fuente.

Para conocer los criterios completos de representación, consulta [LEEME.txt](LEEME.txt).

## Editar y regenerar diagramas

Los archivos `.dot` se pueden modificar como texto y regenerar mediante Graphviz.

Ejemplo para exportar un archivo DOT a SVG:

```bash
dot -Tsvg fuentes_dot/01_Modelo_Completo.dot -o diagramas_svg/01_Modelo_Completo.svg
```

Para generar una imagen PNG:

```bash
dot -Tpng fuentes_dot/01_Modelo_Completo.dot -o vistas_png/01_Modelo_Completo.png
```

Los diagramas SVG se pueden abrir directamente en un navegador.

## Alcance y consideraciones técnicas

Este repositorio contiene una **representación conceptual/lógica inicial** del modelo de datos. Los diagramas reflejan las tablas, campos, tipos de datos y marcadores PK, FK, UNIQUE y NULL documentados en el archivo fuente.

Es importante tener en cuenta:

- Los diagramas no constituyen un script DDL validado para SQL Server.
- Las relaciones representadas no implican que todas las restricciones FK estén implementadas y verificadas físicamente en una base de datos.
- Algunas relaciones entre módulos requieren confirmar claves candidatas —por ejemplo, combinaciones `negocio_id + id`— antes de implementarse como FK compuestas reales.
- En algunas relaciones compuestas, el archivo fuente requiere confirmar la correspondencia completa de las columnas destino.
- El modelo no resuelve por sí solo reglas de negocio que necesitan lógica adicional, transacciones o triggers.

Por tanto, antes de utilizar este modelo como definición física de una base de datos, es necesario validar las claves candidatas, las restricciones, las cardinalidades y las reglas de negocio.

## Fuente del modelo

La versión 1.0 se elaboró a partir del archivo **`BaseDeDatos_Facturate(5).xlsx`**, aportado como fuente de estructura y relaciones.

El modelo conserva lo documentado en ese archivo y no incorpora automáticamente recomendaciones o correcciones posteriores que no estén reflejadas en la fuente.

## Proyecto

**Facturate — Sistema de Recaudo Digital Simple**

Modelo ER organizado para apoyar el diseño, análisis y evolución de la estructura de datos del proyecto.
