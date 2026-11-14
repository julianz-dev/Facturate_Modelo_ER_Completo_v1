/*
   FACTURATE - SIMULACION ACADEMICA DE VENTA Y RECAUDO
   Motor: Microsoft SQL Server
   Alcance: 4 tablas
      1. clientes
      2. productos
      3. ventas
      4. detalles_venta

   IMPORTANTE:
   - Este script crea una base DEMO independiente para no modificar
     la base completa Facturate.
   - Se omiten FKs hacia negocios, usuarios, categorias, tipos_items
     y origenes porque esas tablas no forman parte de esta simulacion.
   - El recaudo se simplifica a un unico metodo de pago por venta;
     en el modelo completo de Facturate se utilizara pagos_venta.
*/

/* 1. Crear la base de datos si todavía no existe */

IF DB_ID(N'Facturate') IS NULL
BEGIN
    CREATE DATABASE Facturate;
END;
GO

USE Facturate;
GO

/* 2. Tabla: clientes */

IF OBJECT_ID(N'dbo.clientes', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.clientes
    (
        cliente_id BIGINT IDENTITY(1,1) NOT NULL,
        tipo_documento NVARCHAR(20) NULL,
        numero_documento NVARCHAR(30) NULL,
        nombre_razon_social NVARCHAR(150) NOT NULL,
        activo BIT NOT NULL
            CONSTRAINT DF_clientes_activo DEFAULT (1),
        es_generico BIT NOT NULL
            CONSTRAINT DF_clientes_es_generico DEFAULT (0),

        CONSTRAINT PK_clientes PRIMARY KEY (cliente_id),
        CONSTRAINT CK_clientes_nombre
            CHECK (LEN(LTRIM(RTRIM(nombre_razon_social))) > 0),
        CONSTRAINT CK_clientes_documento_pareja
            CHECK
            (
                (tipo_documento IS NULL AND numero_documento IS NULL)
                OR
                (
                    tipo_documento IS NOT NULL
                    AND numero_documento IS NOT NULL
                    AND LEN(LTRIM(RTRIM(tipo_documento))) > 0
                    AND LEN(LTRIM(RTRIM(numero_documento))) > 0
                )
            )
    );
END;
GO

/* Un documento no se puede repetir (cuando se informa). */
IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE name = N'UX_clientes_documento'
        AND object_id = OBJECT_ID(N'dbo.clientes')
)
BEGIN
    CREATE UNIQUE INDEX UX_clientes_documento
        ON dbo.clientes (tipo_documento, numero_documento)
        WHERE numero_documento IS NOT NULL;
END;
GO

/* En esta demostración se permite un único cliente genérico. */
IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE name = N'UX_clientes_generico'
        AND object_id = OBJECT_ID(N'dbo.clientes')
)
BEGIN
    CREATE UNIQUE INDEX UX_clientes_generico
        ON dbo.clientes (es_generico)
        WHERE es_generico = 1;
END;
GO

/* 3. Tabla: productos */

IF OBJECT_ID(N'dbo.productos', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.productos
    (
        producto_id BIGINT IDENTITY(1,1) NOT NULL,
        codigo_producto NVARCHAR(50) NOT NULL,
        nombre_producto NVARCHAR(150) NOT NULL,
        descripcion NVARCHAR(500) NULL,
        precio_venta DECIMAL(14,2) NOT NULL,
        activo BIT NOT NULL
            CONSTRAINT DF_productos_activo DEFAULT (1),

        CONSTRAINT PK_productos PRIMARY KEY (producto_id),
        CONSTRAINT UQ_productos_codigo UNIQUE (codigo_producto),
        CONSTRAINT CK_productos_codigo
            CHECK (LEN(LTRIM(RTRIM(codigo_producto))) > 0),
        CONSTRAINT CK_productos_nombre
            CHECK (LEN(LTRIM(RTRIM(nombre_producto))) > 0),
        CONSTRAINT CK_productos_precio
            CHECK (precio_venta >= 0)
    );
END;
GO

/* 4. Tabla: ventas */

IF OBJECT_ID(N'dbo.ventas', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.ventas
    (
        venta_id BIGINT IDENTITY(1,1) NOT NULL,
        uuid_local UNIQUEIDENTIFIER NOT NULL
            CONSTRAINT DF_ventas_uuid_local DEFAULT (NEWID()),
        cliente_id BIGINT NOT NULL,
        fecha_venta DATETIME2(0) NOT NULL
            CONSTRAINT DF_ventas_fecha DEFAULT (SYSUTCDATETIME()),
        estado_venta VARCHAR(20) NOT NULL
            CONSTRAINT DF_ventas_estado DEFAULT ('BORRADOR'),
        subtotal DECIMAL(14,2) NOT NULL
            CONSTRAINT DF_ventas_subtotal DEFAULT (0),
        descuento_total DECIMAL(14,2) NOT NULL
            CONSTRAINT DF_ventas_descuento DEFAULT (0),
        impuesto_total DECIMAL(14,2) NOT NULL
            CONSTRAINT DF_ventas_impuesto DEFAULT (0),
        total_venta DECIMAL(14,2) NOT NULL
            CONSTRAINT DF_ventas_total DEFAULT (0),
        metodo_pago VARCHAR(20) NULL,
        valor_recibido DECIMAL(14,2) NOT NULL
            CONSTRAINT DF_ventas_valor_recibido DEFAULT (0),
        cambio AS
        (
            CONVERT
            (
                DECIMAL(14,2),
                CASE
                    WHEN metodo_pago = 'EFECTIVO'
                        AND valor_recibido > total_venta
                    THEN valor_recibido - total_venta
                    ELSE 0
                END
            )
        ) PERSISTED,

        CONSTRAINT PK_ventas PRIMARY KEY (venta_id),
        CONSTRAINT UQ_ventas_uuid_local UNIQUE (uuid_local),
        CONSTRAINT FK_ventas_clientes
            FOREIGN KEY (cliente_id)
            REFERENCES dbo.clientes (cliente_id),
        CONSTRAINT CK_ventas_estado
            CHECK (estado_venta IN ('BORRADOR', 'CONFIRMADA', 'ANULADA')),
        CONSTRAINT CK_ventas_metodo_pago
            CHECK
            (
                metodo_pago IS NULL
                OR metodo_pago IN
                ('EFECTIVO', 'TARJETA', 'TRANSFERENCIA', 'QR', 'OTRO')
            ),
        CONSTRAINT CK_ventas_importes_no_negativos
            CHECK
            (
                subtotal >= 0
                AND descuento_total >= 0
                AND impuesto_total >= 0
                AND total_venta >= 0
                AND valor_recibido >= 0
            ),
        CONSTRAINT CK_ventas_descuento_no_supera_subtotal
            CHECK (descuento_total <= subtotal),
        CONSTRAINT CK_ventas_total
            CHECK (total_venta = subtotal - descuento_total + impuesto_total),
        CONSTRAINT CK_ventas_recaudo_confirmado
            CHECK
            (
                estado_venta <> 'CONFIRMADA'
                OR
                (
                    metodo_pago IS NOT NULL
                    AND
                    (
                        (metodo_pago = 'EFECTIVO' AND valor_recibido >= total_venta)
                        OR
                        (metodo_pago <> 'EFECTIVO' AND valor_recibido = total_venta)
                    )
                )
            )
    );
END;
GO

/* 5. Tabla: detalles_venta */

IF OBJECT_ID(N'dbo.detalles_venta', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.detalles_venta
    (
        detalle_venta_id BIGINT IDENTITY(1,1) NOT NULL,
        venta_id BIGINT NOT NULL,
        producto_id BIGINT NOT NULL,
        cantidad INT NOT NULL,
        precio_unitario DECIMAL(14,2) NOT NULL,
        descripcion_producto NVARCHAR(500) NOT NULL,
        subtotal DECIMAL(14,2) NOT NULL,

        CONSTRAINT PK_detalles_venta PRIMARY KEY (detalle_venta_id),
        CONSTRAINT FK_detalles_venta_ventas
            FOREIGN KEY (venta_id)
            REFERENCES dbo.ventas (venta_id),
        CONSTRAINT FK_detalles_venta_productos
            FOREIGN KEY (producto_id)
            REFERENCES dbo.productos (producto_id),
        CONSTRAINT CK_detalles_venta_cantidad
            CHECK (cantidad > 0),
        CONSTRAINT CK_detalles_venta_precio
            CHECK (precio_unitario >= 0),
        CONSTRAINT CK_detalles_venta_subtotal
            CHECK
            (
                subtotal = CONVERT(DECIMAL(14,2), cantidad * precio_unitario)
            ),
        CONSTRAINT CK_detalles_venta_descripcion
            CHECK (LEN(LTRIM(RTRIM(descripcion_producto))) > 0)
    );
END;
GO