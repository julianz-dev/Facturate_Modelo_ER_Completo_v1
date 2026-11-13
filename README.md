# FACTURATE — Modelo Entidad-Relación

**Modelo de datos conceptual y lógico para Facturate, un sistema de recaudo digital simple orientado a pequeños negocios.**

Este repositorio documenta la estructura de datos propuesta para Facturate mediante diagramas entidad-relación (ER), vistas organizadas por módulos, fuentes editables de Graphviz y un inventario de relaciones entre entidades.

El objetivo es facilitar la comprensión de las entidades del sistema, sus atributos, las claves que las identifican y las relaciones que permiten representar los procesos principales del negocio.

---

## Contenido del modelo

| Elemento documentado | Cantidad |
|---|---:|
| Módulos funcionales | **10** |
| Entidades / tablas | **61** |
| Campos documentados | **310** |
| Relaciones FK representadas | **90** |

> **Versión del modelo:** 1.0  
> **Fuente estructural:** `BaseDeDatos_Facturate(5).xlsx`  
> **Notación:** Crow's Foot.

Las cantidades anteriores describen el contenido documentado y representado en los diagramas. No significan que todas las tablas y restricciones estén implementadas físicamente en SQL Server.

## 1. Mapa general de módulos

El modelo se organiza en diez módulos funcionales que agrupan las entidades de acuerdo con las responsabilidades de Facturate.

<p align="center">
  <a href="diagramas_svg/00_Resumen_Modulos.svg">
    <img src="vistas_png/00_Resumen_Modulos.png" alt="Mapa general de los diez módulos funcionales de Facturate" width="100%">
  </a>
</p>

*Selecciona la imagen para abrir el diagrama SVG en mayor resolución.*

| Código | Módulo | Alcance funcional |
|---|---|---|
| A | Usuarios y negocio | Negocios, usuarios, roles y datos de contacto. |
| B | Catálogo e inventario | Categorías, productos, inventarios, movimientos y alertas. |
| C | Compras y gastos | Proveedores, compras, detalles de compra y gastos. |
| D | Ventas | Clientes, ventas, detalles, pagos, descuentos e impuestos. |
| E | Facturación | Facturas, correcciones y configuración relacionada. |
| F | Configuración | Parámetros y catálogos configurables del negocio. |
| G | Caja | Cierres, arqueos y sus respectivos detalles. |
| H | Devoluciones | Devoluciones, detalles, motivos y pagos asociados. |
| I | Offline | Información y procesos asociados a la operación sin conexión. |
| J | Portal y soporte | Solicitudes de contacto y recursos de apoyo. |

## 2. Modelo ER completo

A continuación se presenta la vista integral del modelo, con las **61 entidades y sus campos documentados**, junto con las relaciones representadas entre los módulos.

<p align="center">
  <a href="diagramas_svg/01_Modelo_Completo.svg">
    <img src="vistas_png/01_Modelo_Completo.png" alt="Diagrama entidad-relación completo de Facturate con 61 entidades y sus relaciones" width="100%">
  </a>
</p>

*El modelo completo puede ser extenso para visualizarlo en una sola pantalla. Para inspeccionar los nombres de las tablas, columnas y relaciones, abre la imagen en una pestaña nueva o utiliza el SVG, que permite ampliar sin pérdida de calidad.*

- [Abrir modelo ER completo en SVG](diagramas_svg/01_Modelo_Completo.svg)
- [Abrir modelo ER completo en PNG](vistas_png/01_Modelo_Completo.png)
- [Consultar mapa de módulos en SVG](diagramas_svg/00_Resumen_Modulos.svg)

## 3. Diagramas ER por módulo

Además de la vista completa, el repositorio contiene diagramas independientes para facilitar la revisión de cada área funcional.

<details>
  <summary><strong>A. Usuarios y negocio</strong></summary>

  Incluye las entidades relacionadas con la administración del negocio, usuarios, roles y datos de contacto.

  <p align="center">
    <a href="diagramas_svg/01_A_USUARIOS_Y_NEGOCIO.svg">
      <img src="vistas_png/01_A_USUARIOS_Y_NEGOCIO.png" alt="Diagrama ER del módulo A: Usuarios y negocio" width="100%">
    </a>
  </p>

  [Abrir SVG](diagramas_svg/01_A_USUARIOS_Y_NEGOCIO.svg) · [Abrir PNG](vistas_png/01_A_USUARIOS_Y_NEGOCIO.png)
</details>

<details>
  <summary><strong>B. Catálogo e inventario</strong></summary>

  Agrupa productos, categorías, tipos de ítem, inventarios, movimientos y alertas de inventario.

  <p align="center">
    <a href="diagramas_svg/02_B_CAT_LOGO_E_INVENTARIO.svg">
      <img src="vistas_png/02_B_CAT_LOGO_E_INVENTARIO.png" alt="Diagrama ER del módulo B: Catálogo e inventario" width="100%">
    </a>
  </p>

  [Abrir SVG](diagramas_svg/02_B_CAT_LOGO_E_INVENTARIO.svg) · [Abrir PNG](vistas_png/02_B_CAT_LOGO_E_INVENTARIO.png)
</details>

<details>
  <summary><strong>C. Compras y gastos</strong></summary>

  Representa proveedores, compras, detalles de compra, categorías de gastos y gastos.

  <p align="center">
    <a href="diagramas_svg/03_C_COMPRAS_Y_GASTOS.svg">
      <img src="vistas_png/03_C_COMPRAS_Y_GASTOS.png" alt="Diagrama ER del módulo C: Compras y gastos" width="100%">
    </a>
  </p>

  [Abrir SVG](diagramas_svg/03_C_COMPRAS_Y_GASTOS.svg) · [Abrir PNG](vistas_png/03_C_COMPRAS_Y_GASTOS.png)
</details>

<details>
  <summary><strong>D. Ventas</strong></summary>

  Representa clientes, ventas, detalles de venta, pagos, descuentos e impuestos asociados a las operaciones comerciales.

  <p align="center">
    <a href="diagramas_svg/04_D_VENTAS.svg">
      <img src="vistas_png/04_D_VENTAS.png" alt="Diagrama ER del módulo D: Ventas" width="100%">
    </a>
  </p>

  [Abrir SVG](diagramas_svg/04_D_VENTAS.svg) · [Abrir PNG](vistas_png/04_D_VENTAS.png)
</details>

<details>
  <summary><strong>E. Facturación</strong></summary>

  Agrupa las entidades de facturas, correcciones y configuración relacionada con la emisión de documentos.

  <p align="center">
    <a href="diagramas_svg/05_E_FACTURACI_N.svg">
      <img src="vistas_png/05_E_FACTURACI_N.png" alt="Diagrama ER del módulo E: Facturación" width="100%">
    </a>
  </p>

  [Abrir SVG](diagramas_svg/05_E_FACTURACI_N.svg) · [Abrir PNG](vistas_png/05_E_FACTURACI_N.png)
</details>

<details>
  <summary><strong>F. Configuración</strong></summary>

  Contiene las entidades destinadas a parametrizar características y opciones de cada negocio.

  <p align="center">
    <a href="diagramas_svg/06_F_CONFIGURACI_N.svg">
      <img src="vistas_png/06_F_CONFIGURACI_N.png" alt="Diagrama ER del módulo F: Configuración" width="100%">
    </a>
  </p>

  [Abrir SVG](diagramas_svg/06_F_CONFIGURACI_N.svg) · [Abrir PNG](vistas_png/06_F_CONFIGURACI_N.png)
</details>

<details>
  <summary><strong>G. Caja</strong></summary>

  Representa cierres de caja, arqueos y los detalles asociados a los movimientos y métodos de pago.

  <p align="center">
    <a href="diagramas_svg/07_G_CAJA.svg">
      <img src="vistas_png/07_G_CAJA.png" alt="Diagrama ER del módulo G: Caja" width="100%">
    </a>
  </p>

  [Abrir SVG](diagramas_svg/07_G_CAJA.svg) · [Abrir PNG](vistas_png/07_G_CAJA.png)
</details>

<details>
  <summary><strong>H. Devoluciones</strong></summary>

  Organiza las entidades de devoluciones, motivos, detalles y pagos de devolución.

  <p align="center">
    <a href="diagramas_svg/08_H_DEVOLUCIONES.svg">
      <img src="vistas_png/08_H_DEVOLUCIONES.png" alt="Diagrama ER del módulo H: Devoluciones" width="100%">
    </a>
  </p>

  [Abrir SVG](diagramas_svg/08_H_DEVOLUCIONES.svg) · [Abrir PNG](vistas_png/08_H_DEVOLUCIONES.png)
</details>

<details>
  <summary><strong>I. Offline</strong></summary>

  Incluye las entidades documentadas para apoyar la operación y sincronización sin conexión.

  <p align="center">
    <a href="diagramas_svg/09_I_OFFLINE.svg">
      <img src="vistas_png/09_I_OFFLINE.png" alt="Diagrama ER del módulo I: Offline" width="100%">
    </a>
  </p>

  [Abrir SVG](diagramas_svg/09_I_OFFLINE.svg) · [Abrir PNG](vistas_png/09_I_OFFLINE.png)
</details>

<details>
  <summary><strong>J. Portal y soporte</strong></summary>

  Reúne las entidades documentadas para solicitudes de contacto y recursos de aprendizaje.

  <p align="center">
    <a href="diagramas_svg/10_J_PORTAL_SOPORTE.svg">
      <img src="vistas_png/10_J_PORTAL_SOPORTE.png" alt="Diagrama ER del módulo J: Portal y soporte" width="100%">
    </a>
  </p>

  [Abrir SVG](diagramas_svg/10_J_PORTAL_SOPORTE.svg) · [Abrir PNG](vistas_png/10_J_PORTAL_SOPORTE.png)
</details>

## 4. Relaciones y notación Crow's Foot

Los diagramas utilizan notación **Crow's Foot** para representar las cardinalidades y la opcionalidad de las relaciones.

- **Barra (`|`)**: representa el lado «uno».
- **Círculo + pata de cuervo**: representa cero o muchos.
- **Círculo + barra**: representa una relación opcional (cero o uno).
- **FK marcada como UNIQUE**: representa como máximo un registro relacionado en el extremo hijo.
- **Relación compuesta**: agrupa varias columnas que participan en una misma clave foránea, según la definición de la fuente.

El archivo [`relaciones_fk.csv`](relaciones_fk.csv) permite consultar el inventario de relaciones en formato tabular. Incluye:

- `tabla_padre`: entidad referenciada.
- `tabla_hija`: entidad que contiene la FK.
- `columnas_fk`: columna o conjunto de columnas de la relación.
- `opcional`: indica si la relación está documentada como opcional.
- `unica`: indica si la FK está marcada como única.
- `observacion`: notas sobre la relación.

## 5. Archivos y organización del repositorio

```text
Facturate_Modelo_ER_Completo_v1/
│
├── diagramas_svg/       # Diagramas vectoriales
├── fuentes_dot/         # Fuentes editables de Graphviz
├── vistas_png/          # Imágenes PNG de los diagramas
├── relaciones_fk.csv    # Inventario de relaciones FK
├── LEEME.txt            # Convenciones y límites del modelo
├── index.html           # Página de navegación de diagramas
└── README.md            # Documentación principal del repositorio
```

### Función de cada carpeta y archivo

| Recurso | Descripción |
|---|---|
| `diagramas_svg/` | Diagramas vectoriales que se pueden ampliar sin pérdida de calidad. |
| `fuentes_dot/` | Archivos fuente de Graphviz para editar y regenerar los diagramas. |
| `vistas_png/` | Versiones rasterizadas para visualización rápida, documentación y presentaciones. |
| `relaciones_fk.csv` | Registro tabular de las 90 relaciones representadas. |
| `LEEME.txt` | Fuente, notación, criterios de representación y puntos pendientes de validación. |
| `index.html` | Página de navegación con enlaces a las vistas generales y modulares. |

## 6. Visualizador del modelo

El repositorio incluye una página HTML para navegar entre los diagramas:

**[Abrir visualizador del modelo ER](https://julianz-dev.github.io/Facturate_Modelo_ER_Completo_v1/)**

Desde allí se puede acceder al mapa de módulos, al modelo completo y a las vistas detalladas.

## 7. Editar y regenerar diagramas

Los archivos de la carpeta `fuentes_dot/` son fuentes Graphviz editables. Después de modificar un archivo `.dot`, se puede regenerar su representación SVG o PNG con Graphviz.

Ejemplo para generar el SVG del modelo completo:

```bash
dot -Tsvg fuentes_dot/01_Modelo_Completo.dot -o diagramas_svg/01_Modelo_Completo.svg
```

Ejemplo para generar su versión PNG:

```bash
dot -Tpng fuentes_dot/01_Modelo_Completo.dot -o vistas_png/01_Modelo_Completo.png
```

Al regenerar un diagrama, conserva la correspondencia entre el archivo fuente, la versión SVG y la versión PNG para mantener actualizadas las vistas del repositorio.

## 8. Alcance, criterios y limitaciones

Este repositorio presenta una **representación conceptual/lógica inicial** del modelo de datos de Facturate. Los diagramas reflejan las tablas, campos, tipos de datos y marcadores PK, FK, UNIQUE y NULL documentados en el archivo fuente.

Ten en cuenta las siguientes limitaciones:

1. Los diagramas **no constituyen un script DDL validado** para crear la base de datos en Microsoft SQL Server.
2. Las 90 relaciones FK son relaciones representadas en el modelo; no se afirma que todas estén implementadas y verificadas físicamente en una instancia de SQL Server.
3. Algunas relaciones entre módulos requieren confirmar claves candidatas —por ejemplo, combinaciones `negocio_id + id`— antes de implementarse como claves foráneas compuestas reales.
4. En algunas relaciones compuestas, la fuente requiere confirmar la correspondencia completa de las columnas de destino.
5. Las cardinalidades se derivan de la nulabilidad y de los marcadores UNIQUE documentados en la fuente.
6. El modelo por sí solo no define todas las reglas de negocio que podrían requerir lógica adicional, transacciones o triggers.

Antes de utilizar el modelo como definición física de una base de datos, se deben validar las claves candidatas, restricciones, cardinalidades y reglas de negocio contra el DDL y los requisitos vigentes.

## 9. Fuente documental

La versión 1.0 se elaboró a partir del archivo **`BaseDeDatos_Facturate(5).xlsx`**, utilizado como fuente de estructura y relaciones.

El modelo conserva lo documentado en ese archivo y no incorpora automáticamente recomendaciones de auditorías o correcciones posteriores que no estén reflejadas en la fuente.

Para consultar los criterios de representación y las observaciones pendientes, revisa [`LEEME.txt`](LEEME.txt).

---

## Proyecto

**Facturate — Sistema de Recaudo Digital Simple**

Repositorio de documentación del modelo entidad-relación, preparado para apoyar el análisis, consulta y evolución de la estructura de datos del proyecto.
