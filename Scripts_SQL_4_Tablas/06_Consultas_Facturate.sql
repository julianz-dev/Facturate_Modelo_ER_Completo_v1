/*
   FACTURATE - 15 CONSULTAS DE ANALISIS DE VENTAS
   Motor: Microsoft SQL Server
   Base de datos: Facturate (tablas: clientes, productos, ventas, detalles_venta)

   Antes de ejecutar:
   - Correr en orden los scripts 01 a 05 (esquema y carga de datos).
   - Las respuestas indicadas en cada consulta corresponden a la carga completa:
     500 clientes, 1.000 productos, 400 ventas y 1.200 detalles.
   - Salvo la consulta 4, todas usan estado_venta = 'CONFIRMADA', porque las
     ventas en BORRADOR o ANULADA no se consideran plata realmente vendida.
   - En las consultas 2 y 13 se filtra es_generico = 0 para excluir al
     "Consumidor final", que agrupa a muchos compradores anonimos.
*/

USE Facturate;
GO

/* ------------------------------------------------------------------
   1. Que producto se vendio mas (en unidades)?
   ------------------------------------------------------------------ */
SELECT TOP 3
    p.codigo_producto,
    p.nombre_producto,
    SUM(d.cantidad) AS unidades_vendidas
FROM detalles_venta AS d
INNER JOIN ventas    AS v ON v.venta_id    = d.venta_id
INNER JOIN productos AS p ON p.producto_id = d.producto_id
WHERE v.estado_venta = 'CONFIRMADA'
GROUP BY p.codigo_producto, p.nombre_producto
ORDER BY unidades_vendidas DESC;
GO
/* RESPUESTA: Concentrador de puertos Lenovo (FAC-PRD-0047) con 22 unidades.
   Le siguen Logitech K120 (16) y Refrigeracion por aire Thermaltake UX (14). */


/* ------------------------------------------------------------------
   2. Que cliente gasto mas?
   ------------------------------------------------------------------ */
SELECT TOP 3
    c.nombre_razon_social,
    COUNT(*) AS compras,
    FORMAT(SUM(v.total_venta), 'C0', 'es-CO') AS total_gastado
FROM ventas AS v
INNER JOIN clientes AS c ON c.cliente_id = v.cliente_id
WHERE v.estado_venta = 'CONFIRMADA'
  AND c.es_generico = 0
GROUP BY c.cliente_id, c.nombre_razon_social
ORDER BY SUM(v.total_venta) DESC;
/* RESPUESTA: Equipos y Suministros San Jose S.A.S. con $45.729.800 (1 compra).
   Despues: Manuela Tomas Arango Marin ($33.489.400, 2 compras) y
   Pablo Moreno Restrepo ($29.068.900, 3 compras).
   Sin el filtro es_generico = 0 ganaria "Consumidor final" con $65.457.545. */


/* ------------------------------------------------------------------
   3. Cuanto se vendio en total?
   ------------------------------------------------------------------ */
SELECT
    COUNT(*) AS ventas_confirmadas,
    FORMAT(SUM(subtotal), 'C0', 'es-CO') AS subtotal,
    FORMAT(SUM(descuento_total), 'C0', 'es-CO') AS descuentos,
    FORMAT(SUM(total_venta), 'C0', 'es-CO') AS total_vendido
FROM ventas
WHERE estado_venta = 'CONFIRMADA';
/* RESPUESTA: 360 ventas | subtotal $1.546.702.400 | descuentos $7.581.940 |
   total vendido $1.539.120.460. */


/* ------------------------------------------------------------------
   4. Cuantas ventas hay por estado?
   ------------------------------------------------------------------ */
SELECT
    estado_venta,
    COUNT(*) AS cantidad,
    FORMAT(SUM(total_venta), 'C0', 'es-CO') AS total
FROM ventas
GROUP BY estado_venta
ORDER BY estado_venta;
/* RESPUESTA: ANULADA 15 ($53.253.000) | BORRADOR 25 ($133.371.800) |
   CONFIRMADA 360 ($1.539.120.460). */


/* ------------------------------------------------------------------
   5. Cual es el metodo de pago mas usado?
   ------------------------------------------------------------------ */
SELECT
    metodo_pago,
    COUNT(*) AS ventas,
    FORMAT(SUM(total_venta), 'C0', 'es-CO') AS total
FROM ventas
WHERE estado_venta = 'CONFIRMADA'
GROUP BY metodo_pago
ORDER BY ventas DESC;
/* RESPUESTA: EFECTIVO con 126 ventas ($542.370.980).
   Luego TARJETA (90), TRANSFERENCIA (72), QR (54) y OTRO (18). */


/* ------------------------------------------------------------------
   6. En que meses se vendio mas?
   ------------------------------------------------------------------ */
SELECT TOP 3
    YEAR(fecha_venta) AS anio,
    MONTH(fecha_venta) AS mes,
    COUNT(*) AS ventas,
    FORMAT(SUM(total_venta), 'C0', 'es-CO') AS total_vendido
FROM ventas
WHERE estado_venta = 'CONFIRMADA'
GROUP BY YEAR(fecha_venta), MONTH(fecha_venta)
ORDER BY SUM(total_venta) DESC;
/* RESPUESTA: Septiembre 2026 con $194.719.725 (36 ventas).
   Luego agosto ($186.388.315) y mayo ($165.395.250). */


/* ------------------------------------------------------------------
   7. Que producto genero mas ingresos?
   ------------------------------------------------------------------ */
SELECT TOP 3
    p.nombre_producto,
    FORMAT(SUM(d.subtotal), 'C0', 'es-CO') AS ingresos,
    SUM(d.cantidad) AS unidades
FROM detalles_venta AS d
INNER JOIN ventas AS v ON v.venta_id = d.venta_id
INNER JOIN productos AS p ON p.producto_id = d.producto_id
WHERE v.estado_venta = 'CONFIRMADA'
GROUP BY p.producto_id, p.nombre_producto
ORDER BY SUM(d.subtotal) DESC;
/* RESPUESTA: Acelerador AMD Instinct (MI325X) con $45.000.000 (1 unidad).
   Luego Sony Alpha 7 IV ($22.499.700, 3 unidades) y
   Celular Xiaomi 14T Pro ($17.000.000, 5 unidades). */


/* ------------------------------------------------------------------
   8. Cual es el valor promedio de una venta (ticket promedio)?
   ------------------------------------------------------------------ */
SELECT
    FORMAT(AVG(total_venta), 'C2', 'es-CO') AS ticket_promedio
FROM ventas
WHERE estado_venta = 'CONFIRMADA';
/* RESPUESTA: $4.275.334,61 por venta. */


/* ------------------------------------------------------------------
   9. Cual fue la venta de mayor valor?
   ------------------------------------------------------------------ */
SELECT TOP 1
    c.nombre_razon_social,
    v.fecha_venta,
    v.metodo_pago,
    FORMAT(v.total_venta, 'C0', 'es-CO') AS total_venta
FROM ventas AS v
INNER JOIN clientes AS c ON c.cliente_id = v.cliente_id
WHERE v.estado_venta = 'CONFIRMADA'
ORDER BY v.total_venta DESC;
/* RESPUESTA: Equipos y Suministros San Jose S.A.S., 30/09/2026 10:22,
   pago con TARJETA, $45.729.800. */


/* ------------------------------------------------------------------
   10. Cuantas ventas tuvieron descuento y cuanto se descuento en total?
   ------------------------------------------------------------------ */
SELECT
    COUNT(*) AS ventas_con_descuento,
    FORMAT(SUM(descuento_total), 'C0', 'es-CO') AS descuento_acumulado
FROM ventas
WHERE estado_venta = 'CONFIRMADA'
  AND descuento_total > 0;
/* RESPUESTA: 36 ventas con descuento, por un total de $7.581.940. */


/* ------------------------------------------------------------------
   11. Cuantos clientes no tienen ninguna compra confirmada?
   La condicion de estado va en el ON (no en el WHERE) para que el
   LEFT JOIN conserve a los clientes sin ventas.
   ------------------------------------------------------------------ */
SELECT COUNT(*) AS clientes_sin_compras
FROM clientes AS c
LEFT JOIN ventas AS v
       ON v.cliente_id   = c.cliente_id
      AND v.estado_venta = 'CONFIRMADA'
WHERE v.venta_id IS NULL;
GO
/* RESPUESTA: 256 de los 500 clientes. */


/* ------------------------------------------------------------------
   12. Cuanto cambio se devolvio en ventas en efectivo?
   ------------------------------------------------------------------ */
SELECT
    FORMAT(SUM(cambio), 'C0', 'es-CO') AS cambio_total,
    COUNT(*) AS ventas_con_cambio
FROM ventas
WHERE estado_venta = 'CONFIRMADA'
  AND metodo_pago = 'EFECTIVO'
  AND cambio > 0;
/* RESPUESTA: $129.020 de cambio en 103 ventas
   (las otras 23 ventas en efectivo se pagaron justo). */


/* ------------------------------------------------------------------
   13. Que clientes compraron mas veces?
   ------------------------------------------------------------------ */
SELECT TOP 5
    c.nombre_razon_social,
    COUNT(*) AS compras,
    FORMAT(SUM(v.total_venta), 'C0', 'es-CO') AS total_gastado
FROM ventas AS v
INNER JOIN clientes AS c ON c.cliente_id = v.cliente_id
WHERE v.estado_venta = 'CONFIRMADA'
  AND c.es_generico = 0
GROUP BY c.cliente_id, c.nombre_razon_social
ORDER BY compras DESC, SUM(v.total_venta) DESC;
/* RESPUESTA (el maximo es 4 compras; se desempata por total gastado):
   Drogueria del Valle Ltda.          4 compras  $21.712.815
   Panaderia Nuevo Horizonte S.A.S.   4 compras  $11.947.810
   Laura Cardenas Restrepo            4 compras   $9.569.710
   Pablo Moreno Restrepo              3 compras  $29.068.900
   Vanessa Rojas Medina               3 compras  $23.069.305 */


/* ------------------------------------------------------------------
   14. Cuanto se vende por tipo de documento del cliente?
   ------------------------------------------------------------------ */
SELECT
    ISNULL(c.tipo_documento, 'SIN DOCUMENTO') AS tipo_documento,
    COUNT(*) AS ventas,
    FORMAT(SUM(v.total_venta), 'C0', 'es-CO') AS total
FROM ventas AS v
INNER JOIN clientes AS c ON c.cliente_id = v.cliente_id
WHERE v.estado_venta = 'CONFIRMADA'
GROUP BY ISNULL(c.tipo_documento, 'SIN DOCUMENTO')
ORDER BY SUM(v.total_venta) DESC;
/* RESPUESTA:
   CC             257 ventas  $1.119.695.765
   NIT             63 ventas    $288.131.840
   CE              19 ventas     $65.835.310
   SIN DOCUMENTO   21 ventas     $65.457.545  (Consumidor final) */


/* ------------------------------------------------------------------
   15. Cuantos productos distintos del catalogo se han vendido?
   ------------------------------------------------------------------ */
SELECT COUNT(DISTINCT d.producto_id) AS productos_vendidos
FROM detalles_venta AS d
INNER JOIN ventas AS v ON v.venta_id = d.venta_id
WHERE v.estado_venta = 'CONFIRMADA';
GO
/* RESPUESTA: 574 de los 1.000 productos (426 nunca se han vendido). */


/* ------------------------------------------------------------------
   16. ¿Cuáles son los 3 productos más caros del catálogo?
   ------------------------------------------------------------------ */
SELECT TOP 3
    nombre_producto,
    FORMAT(precio_venta, 'C0', 'es-CO') AS precio,
    descripcion
FROM productos
ORDER BY precio_venta DESC;
GO

/* ------------------------------------------------------------------
   17. Insert para producto de prueba
   ------------------------------------------------------------------ */

INSERT INTO dbo.productos
(codigo_producto, nombre_producto, descripcion, precio_venta)
VALUES
    (N'TEST-DELETE-001', N'Producto temporal DELETE', N'Registro para prueba de eliminación', 15000.00);
GO

SELECT
    producto_id,
    codigo_producto,
    nombre_producto,
    descripcion,
    precio_venta,
    activo
FROM dbo.productos
WHERE codigo_producto = N'TEST-DELETE-001';
GO

/* ------------------------------------------------------------------
   18. Sentencia DELETE para producto de prueba
   ------------------------------------------------------------------ */

DELETE FROM dbo.productos
WHERE producto_id = 1001
  AND codigo_producto = N'TEST-DELETE-001';
GO

SELECT *
FROM dbo.productos
WHERE producto_id = 1001;
GO