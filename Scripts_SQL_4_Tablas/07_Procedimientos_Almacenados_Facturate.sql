/* =====================================================================
   FACTURATE - PROCEDIMIENTOS ALMACENADOS
   Motor: Microsoft SQL Server
   Lenguaje: Transact-SQL (T-SQL)
   Base de datos: Facturate
   Alcance: simulacion academica de cuatro tablas

   REQUISITOS PREVIOS:
   - Ejecutar 01_Proyecto_Integrador_Facturate.sql.
   - Ejecutar los scripts de carga 02 a 05 si se desean probar los
     procedimientos con el conjunto completo de datos.
   - Este archivo requiere las tablas dbo.clientes, dbo.productos,
     dbo.ventas y dbo.detalles_venta.

   PROCEDIMIENTOS INCLUIDOS:
   1. dbo.usp_ConsultarProductos
   2. dbo.usp_RegistrarCliente
   3. dbo.usp_ConsultarVentas
   4. dbo.usp_CrearVentaBorrador
   5. dbo.usp_ConfirmarVenta

   NOTAS:
   - CREATE OR ALTER PROCEDURE requiere SQL Server 2016 SP1 o posterior.
   - Los importes se devuelven como valores numericos; el formato
     monetario debe aplicarse en la capa de presentacion.
   - usp_CrearVentaBorrador crea una venta con un unico detalle. Es una
     operacion didactica para esta simulacion de cuatro tablas.
   - Estos procedimientos no representan una interfaz CRUD completa
     ni implementan todos los modulos del modelo ER de 61 entidades.
   ===================================================================== */

IF DB_ID(N'Facturate') IS NULL
BEGIN
    THROW 53020, N'No existe la base de datos Facturate. Ejecute primero el script 01.', 1;
END;
GO

USE Facturate;
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

IF OBJECT_ID(N'dbo.clientes', N'U') IS NULL
   OR OBJECT_ID(N'dbo.productos', N'U') IS NULL
   OR OBJECT_ID(N'dbo.ventas', N'U') IS NULL
   OR OBJECT_ID(N'dbo.detalles_venta', N'U') IS NULL
BEGIN
    THROW 53021, N'Falta una o mas tablas requeridas. Ejecute primero el script 01.', 1;
END;
GO

/* =====================================================================
   1. CONSULTAR PRODUCTOS
   Permite listar productos y aplicar filtros opcionales por estado
   y por coincidencia en codigo o nombre.
   ===================================================================== */
CREATE OR ALTER PROCEDURE dbo.usp_ConsultarProductos
    @solo_activos BIT = 1,
    @buscar NVARCHAR(150) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SET @buscar = NULLIF(LTRIM(RTRIM(@buscar)), N'');

    SELECT
        p.producto_id,
        p.codigo_producto,
        p.nombre_producto,
        p.descripcion,
        p.precio_venta,
        p.activo
    FROM dbo.productos AS p
    WHERE
        (@solo_activos = 0 OR p.activo = 1)
        AND
        (
            @buscar IS NULL
            OR p.codigo_producto LIKE N'%' + @buscar + N'%'
            OR p.nombre_producto LIKE N'%' + @buscar + N'%'
        )
    ORDER BY p.nombre_producto ASC, p.producto_id ASC;
END;
GO

/* =====================================================================
   2. REGISTRAR CLIENTE
   Inserta un cliente y devuelve el identificador generado.
   La tabla aplica DEFAULT(1) a activo. Las restricciones CHECK y los
   indices UNIQUE existentes conservan la integridad de los datos.
   ===================================================================== */
CREATE OR ALTER PROCEDURE dbo.usp_RegistrarCliente
    @nombre_razon_social NVARCHAR(150),
    @cliente_id BIGINT OUTPUT,
    @tipo_documento NVARCHAR(20) = NULL,
    @numero_documento NVARCHAR(30) = NULL,
    @es_generico BIT = 0
AS
BEGIN
    SET NOCOUNT ON;

    SET @cliente_id = NULL;
    SET @nombre_razon_social = LTRIM(RTRIM(@nombre_razon_social));
    SET @tipo_documento = NULLIF(LTRIM(RTRIM(@tipo_documento)), N'');
    SET @numero_documento = NULLIF(LTRIM(RTRIM(@numero_documento)), N'');

    IF @nombre_razon_social IS NULL OR @nombre_razon_social = N''
    BEGIN
        THROW 53022, N'El nombre o razon social es obligatorio.', 1;
    END;

    IF @es_generico IS NULL
    BEGIN
        THROW 53041, N'El indicador es_generico debe ser 0 o 1.', 1;
    END;

    IF
    (
        (@tipo_documento IS NULL AND @numero_documento IS NOT NULL)
        OR
        (@tipo_documento IS NOT NULL AND @numero_documento IS NULL)
    )
    BEGIN
        THROW 53023, N'Debe informar tipo y numero de documento, o dejar ambos sin valor.', 1;
    END;

    IF @es_generico = 1
       AND EXISTS
       (
           SELECT 1
           FROM dbo.clientes
           WHERE es_generico = 1
       )
    BEGIN
        THROW 53024, N'Ya existe un cliente generico. La simulacion permite solo uno.', 1;
    END;

    IF @numero_documento IS NOT NULL
       AND EXISTS
       (
           SELECT 1
           FROM dbo.clientes
           WHERE tipo_documento = @tipo_documento
             AND numero_documento = @numero_documento
       )
    BEGIN
        THROW 53025, N'Ya existe un cliente con ese tipo y numero de documento.', 1;
    END;

    BEGIN TRY
        INSERT INTO dbo.clientes
        (
            tipo_documento,
            numero_documento,
            nombre_razon_social,
            es_generico
        )
        VALUES
        (
            @tipo_documento,
            @numero_documento,
            @nombre_razon_social,
            @es_generico
        );

        SET @cliente_id = CONVERT(BIGINT, SCOPE_IDENTITY());

        SELECT
            cliente_id,
            tipo_documento,
            numero_documento,
            nombre_razon_social,
            activo,
            es_generico
        FROM dbo.clientes
        WHERE cliente_id = @cliente_id;
    END TRY
    BEGIN CATCH
        /* Los indices UNIQUE tambien protegen frente a inserciones
           simultaneas que superen las validaciones previas. */
        IF ERROR_NUMBER() IN (2601, 2627)
        BEGIN
            THROW 53026, N'No fue posible registrar el cliente porque se duplicaria un valor unico.', 1;
        END;

        THROW;
    END CATCH;
END;
GO

/* =====================================================================
   3. CONSULTAR VENTAS
   Permite filtrar por estado, rango de fechas y cliente generico.
   La fecha final se considera inclusiva durante todo ese dia.
   ===================================================================== */
CREATE OR ALTER PROCEDURE dbo.usp_ConsultarVentas
    @estado_venta VARCHAR(20) = NULL,
    @fecha_desde DATE = NULL,
    @fecha_hasta DATE = NULL,
    @incluir_generico BIT = 1
AS
BEGIN
    SET NOCOUNT ON;

    SET @estado_venta = NULLIF(LTRIM(RTRIM(@estado_venta)), '');

    IF @estado_venta IS NOT NULL
       AND @estado_venta NOT IN ('BORRADOR', 'CONFIRMADA', 'ANULADA')
    BEGIN
        THROW 53027, N'Estado no valido. Use BORRADOR, CONFIRMADA o ANULADA.', 1;
    END;

    IF @fecha_desde IS NOT NULL
       AND @fecha_hasta IS NOT NULL
       AND @fecha_desde > @fecha_hasta
    BEGIN
        THROW 53028, N'La fecha inicial no puede ser posterior a la fecha final.', 1;
    END;

    IF @fecha_hasta = CONVERT(DATE, '99991231', 112)
    BEGIN
        THROW 53029, N'La fecha final debe ser anterior al maximo valor permitido para evitar desbordamiento.', 1;
    END;

    SELECT
        v.venta_id,
        v.fecha_venta,
        v.estado_venta,
        v.cliente_id,
        c.nombre_razon_social,
        c.es_generico,
        v.subtotal,
        v.descuento_total,
        v.impuesto_total,
        v.total_venta,
        v.metodo_pago,
        v.valor_recibido,
        v.cambio
    FROM dbo.ventas AS v
    INNER JOIN dbo.clientes AS c
        ON c.cliente_id = v.cliente_id
    WHERE
        (@estado_venta IS NULL OR v.estado_venta = @estado_venta)
        AND
        (@fecha_desde IS NULL OR v.fecha_venta >= CONVERT(DATETIME2(0), @fecha_desde))
        AND
        (
            @fecha_hasta IS NULL
            OR v.fecha_venta < DATEADD(DAY, 1, CONVERT(DATETIME2(0), @fecha_hasta))
        )
        AND
        (@incluir_generico = 1 OR c.es_generico = 0)
    ORDER BY v.fecha_venta DESC, v.venta_id DESC;
END;
GO

/* =====================================================================
   4. CREAR VENTA EN BORRADOR CON UN DETALLE
   Crea la cabecera y su primer detalle dentro de una transaccion.
   El precio y la descripcion se toman del catalogo en el momento de
   crear el detalle, conservando una copia historica en detalles_venta.
   La venta queda en BORRADOR y sin metodo de pago.
   ===================================================================== */
CREATE OR ALTER PROCEDURE dbo.usp_CrearVentaBorrador
    @cliente_id BIGINT,
    @producto_id BIGINT,
    @cantidad INT,
    @venta_id BIGINT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @precio_venta DECIMAL(14,2);
    DECLARE @descripcion_producto NVARCHAR(500);
    DECLARE @subtotal DECIMAL(14,2);

    SET @venta_id = NULL;

    IF @cantidad IS NULL OR @cantidad <= 0
    BEGIN
        THROW 53030, N'La cantidad debe ser un entero mayor que cero.', 1;
    END;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS
        (
            SELECT 1
            FROM dbo.clientes WITH (UPDLOCK, HOLDLOCK)
            WHERE cliente_id = @cliente_id
              AND activo = 1
        )
        BEGIN
            THROW 53031, N'El cliente no existe o se encuentra inactivo.', 1;
        END;

        SELECT
            @precio_venta = precio_venta,
            @descripcion_producto = CONVERT
            (
                NVARCHAR(500),
                CONCAT
                (
                    nombre_producto,
                    CASE
                        WHEN NULLIF(LTRIM(RTRIM(descripcion)), N'') IS NOT NULL
                        THEN N' - ' + descripcion
                        ELSE N''
                    END
                )
            )
        FROM dbo.productos WITH (UPDLOCK, HOLDLOCK)
        WHERE producto_id = @producto_id
          AND activo = 1;

        IF @precio_venta IS NULL
        BEGIN
            THROW 53032, N'El producto no existe o se encuentra inactivo.', 1;
        END;

        SET @subtotal = TRY_CONVERT(DECIMAL(14,2), @precio_venta * @cantidad);

        IF @subtotal IS NULL
        BEGIN
            THROW 53033, N'El importe calculado supera la capacidad del tipo DECIMAL(14,2).', 1;
        END;

        INSERT INTO dbo.ventas (cliente_id)
        VALUES (@cliente_id);

        SET @venta_id = CONVERT(BIGINT, SCOPE_IDENTITY());

        INSERT INTO dbo.detalles_venta
        (
            venta_id,
            producto_id,
            cantidad,
            precio_unitario,
            descripcion_producto,
            subtotal
        )
        VALUES
        (
            @venta_id,
            @producto_id,
            @cantidad,
            @precio_venta,
            @descripcion_producto,
            @subtotal
        );

        UPDATE dbo.ventas
        SET
            subtotal = @subtotal,
            descuento_total = 0,
            impuesto_total = 0,
            total_venta = @subtotal
        WHERE venta_id = @venta_id;

        COMMIT TRANSACTION;

        SELECT
            v.venta_id,
            v.fecha_venta,
            v.estado_venta,
            v.cliente_id,
            c.nombre_razon_social,
            v.subtotal,
            v.descuento_total,
            v.impuesto_total,
            v.total_venta
        FROM dbo.ventas AS v
        INNER JOIN dbo.clientes AS c
            ON c.cliente_id = v.cliente_id
        WHERE v.venta_id = @venta_id;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
        BEGIN
            ROLLBACK TRANSACTION;
        END;

        SET @venta_id = NULL;
        THROW;
    END CATCH;
END;
GO

/* =====================================================================
   5. CONFIRMAR VENTA
   Confirma una venta que este en BORRADOR y tenga al menos un detalle.
   Valida metodo de pago y valor recibido antes del UPDATE.
   EFECTIVO permite recibir mas que el total (el cambio es calculado
   por la columna persistida dbo.ventas.cambio).
   Otros metodos exigen recibir exactamente el total.
   ===================================================================== */
CREATE OR ALTER PROCEDURE dbo.usp_ConfirmarVenta
    @venta_id BIGINT,
    @metodo_pago VARCHAR(20),
    @valor_recibido DECIMAL(14,2)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @estado_actual VARCHAR(20);
    DECLARE @subtotal_cabecera DECIMAL(14,2);
    DECLARE @subtotal_detalles DECIMAL(14,2);
    DECLARE @total_venta DECIMAL(14,2);

    SET @metodo_pago = UPPER(LTRIM(RTRIM(@metodo_pago)));

    IF @metodo_pago IS NULL
       OR @metodo_pago NOT IN ('EFECTIVO', 'TARJETA', 'TRANSFERENCIA', 'QR', 'OTRO')
    BEGIN
        THROW 53034, N'Metodo de pago no valido.', 1;
    END;

    IF @valor_recibido IS NULL OR @valor_recibido < 0
    BEGIN
        THROW 53035, N'El valor recibido debe ser mayor o igual que cero.', 1;
    END;

    BEGIN TRY
        BEGIN TRANSACTION;

        SELECT
            @estado_actual = estado_venta,
            @subtotal_cabecera = subtotal,
            @total_venta = total_venta
        FROM dbo.ventas WITH (UPDLOCK, HOLDLOCK)
        WHERE venta_id = @venta_id;

        IF @estado_actual IS NULL
        BEGIN
            THROW 53036, N'La venta indicada no existe.', 1;
        END;

        IF @estado_actual <> 'BORRADOR'
        BEGIN
            THROW 53037, N'Solo se pueden confirmar ventas que esten en estado BORRADOR.', 1;
        END;

        SELECT @subtotal_detalles = CONVERT(DECIMAL(14,2), SUM(subtotal))
        FROM dbo.detalles_venta
        WHERE venta_id = @venta_id;

        IF @subtotal_detalles IS NULL
        BEGIN
            THROW 53038, N'No se puede confirmar una venta sin detalles.', 1;
        END;

        IF @subtotal_detalles <> @subtotal_cabecera
        BEGIN
            THROW 53042, N'El subtotal de los detalles no coincide con el subtotal de la venta.', 1;
        END;

        IF @metodo_pago = 'EFECTIVO' AND @valor_recibido < @total_venta
        BEGIN
            THROW 53039, N'En pagos en efectivo, el valor recibido no puede ser inferior al total.', 1;
        END;

        IF @metodo_pago <> 'EFECTIVO' AND @valor_recibido <> @total_venta
        BEGIN
            THROW 53040, N'Para este metodo de pago, el valor recibido debe coincidir con el total.', 1;
        END;

        UPDATE dbo.ventas
        SET
            estado_venta = 'CONFIRMADA',
            metodo_pago = @metodo_pago,
            valor_recibido = @valor_recibido
        WHERE venta_id = @venta_id;

        COMMIT TRANSACTION;

        SELECT
            venta_id,
            fecha_venta,
            estado_venta,
            subtotal,
            descuento_total,
            impuesto_total,
            total_venta,
            metodo_pago,
            valor_recibido,
            cambio
        FROM dbo.ventas
        WHERE venta_id = @venta_id;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
        BEGIN
            ROLLBACK TRANSACTION;
        END;

        THROW;
    END CATCH;
END;
GO

/* =====================================================================
   EJEMPLOS DE EJECUCION
   Ejecutar individualmente y revisar los resultados. Los ejemplos
   que modifican datos estan comentados para evitar inserciones o
   confirmaciones accidentales.
   ===================================================================== */

-- 1. Consultar todos los productos activos.
-- EXEC dbo.usp_ConsultarProductos;
-- GO

-- 2. Buscar productos por nombre o codigo.
-- EXEC dbo.usp_ConsultarProductos
--     @solo_activos = 1,
--     @buscar = N'Lenovo';
-- GO

-- 3. Registrar un cliente de prueba y recuperar el ID generado.
-- DECLARE @nuevo_cliente_id BIGINT;
-- EXEC dbo.usp_RegistrarCliente
--     @nombre_razon_social = N'Cliente de prueba - Procedimiento',
--     @tipo_documento = N'CC',
--     @numero_documento = N'999999991',
--     @cliente_id = @nuevo_cliente_id OUTPUT;
-- SELECT @nuevo_cliente_id AS cliente_id_generado;
-- GO

-- 4. Consultar ventas confirmadas dentro de un rango de fechas.
-- EXEC dbo.usp_ConsultarVentas
--     @estado_venta = 'CONFIRMADA',
--     @fecha_desde = '2026-01-01',
--     @fecha_hasta = '2026-12-31',
--     @incluir_generico = 0;
-- GO

-- 5. Flujo completo: crear una venta en borrador y confirmarla.
-- Reemplace los IDs por un cliente y producto activos existentes.
-- Este ejemplo usa TARJETA; por eso el valor recibido debe ser igual
-- al total calculado por el procedimiento de creacion.
-- DECLARE @nueva_venta_id BIGINT;
-- DECLARE @total_nueva_venta DECIMAL(14,2);
-- EXEC dbo.usp_CrearVentaBorrador
--     @cliente_id = 1,
--     @producto_id = 1,
--     @cantidad = 2,
--     @venta_id = @nueva_venta_id OUTPUT;
-- SELECT @total_nueva_venta = total_venta
-- FROM dbo.ventas
-- WHERE venta_id = @nueva_venta_id;
-- EXEC dbo.usp_ConfirmarVenta
--     @venta_id = @nueva_venta_id,
--     @metodo_pago = 'TARJETA',
--     @valor_recibido = @total_nueva_venta;
-- GO
