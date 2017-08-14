



USE bd_soporte_apruebeme_please




select * from almacen_producto_stock 

select COUNT(*) from almacen_producto_stock 




select * from quiebre
select * from detalle_compra_producto where id_producto = 500

--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


select * from KARDEX where id_almacen=1 and id_producto = 2


Declare @idproducto int = 2;
Declare @Almacen int = 1;
select a.cantidad_disponible - SUM(egresos+ingresos) from KARDEX k,almacen_producto_stock a where k.id_almacen = @Almacen and k.id_producto = @idproducto
and k.id_almacen =a.id_almacen and k.id_producto = a.id_producto 
group by a.cantidad_disponible

select * from KARDEX
exec PEDIDO_COMPRA 1200, '2017-05-01', '2017-05-05'

--///////////////////////////////////////////////////////////////////////////	COMPRA

select * from pedido order by id_pedido_compra desc


select * from detalle_pedido_producto order by id_detalle_compra desc


select * from compra order by id_compra desc

select DATEDIFF(day,p.fecha,c.fecha) from pedido p, compra c where c.id_pedido_compra = p.id_pedido_compra


select * from detalle_compra_producto order by id_detalle desc


select * from compra order by totalCompra desc


	DECLARE @TOTAL_COMPRA INT = (select top 1 totalCompra from compra order by totalCompra desc);
	PRINT 'Base Datos = ' + CAST( @TOTAL_COMPRA as Varchar(50));

	DECLARE @ID_COMPRA INT = (select top 1 id_compra from compra order by totalCompra desc);
	
	DECLARE @SUB_TOTAL INT = (select SUM(subtotal) from detalle_compra_producto 
	where id_compra = @ID_COMPRA)
	
	DECLARE @IVA FLOAT = (select iva from compra 
	where id_compra = @ID_COMPRA)
	
	DECLARE @SUM_GASTOS bigINT = (select SUM(monto) from gasto
	where id_compra = @ID_COMPRA)
	
	DECLARE @IMPUESTO FLOAT = (select impuesto from compra_valorada
	where id_compra = @ID_COMPRA)

	DECLARE @ARANCEL FLOAT = (select arancel from compra_valorada
	where id_compra = @ID_COMPRA)
	
	DECLARE @TOTAL bigINT = @SUB_TOTAL + @IVA + @SUM_GASTOS + @IMPUESTO + @ARANCEL
	PRINT  'Logica = ' + CAST( @TOTAL as Varchar(60));
	
	
	

	
	SELECT DISTINCT id_producto
      FROM  KARDEX  
      GROUP by id_producto order by id_producto 
      
    SELECT * FROM detalle_compra_producto ORDER BY id_detalle DESC
    
    
    SELECT * FROM detalle_ingreso_producto ORDER BY id_detalle_ingreso_producto DESC
	select * from KARDEX where tipo = 'I' ORDER BY id_KARDEX DESC
	
    select * from KARDEX ORDER BY id_KARDEX DESC
    
select SUM(INGRESOS_EGRESOS) AS TODO_KARDEX from KARDEX GROUP BY id_producto

select SUM(INGRESOS_EGRESOS) AS TODO_KARDEX from KARDEX
where id_producto in (

	SELECT id_producto, SUM(INGRESOS_EGRESOS) 
      FROM  KARDEX  
      GROUP by id_producto
      order by id_producto 


	SELECT id_producto, (INGRESOS_EGRESOS) 
      FROM  KARDEX  
      where id_producto = 4 
      order by id_producto 
      
      
select * from quiebre where id_producto = 4 order by id_producto

select * from almacen_producto_stock where id_producto = 4 order by id_producto




	DECLARE @TODO_KARDEX INT = (select SUM(INGRESOS_EGRESOS) AS TODO_KARDEX from KARDEX);
	PRINT 'TODO_KARDEX : ' + CAST(@TODO_KARDEX AS VARCHAR(10))
	
    DECLARE @IN INT = (select SUM(cantidad) AS INGRESOS from detalle_ingreso_producto); 
    DECLARE @EG INT = (select SUM(cantidad) AS EGRESOS from detalle_egreso);
    PRINT 'INGRESOS = ' + CAST(@IN AS VARCHAR(10))
    PRINT 'EGRESOS = ' + CAST(@EG AS VARCHAR(10))
    PRINT 'INGRESOS + EGRESOS : ' + CAST(@IN - @EG AS VARCHAR(10))
    
    
	
---///////////////////////////////////////////////////PRUEBA PEINADO	
	select * from egreso
	
	select * from detalle_egreso where id_egreso = 6005

select id_producto from detalle_compra_producto order by id_producto



select * from almacen_producto_stock 
where id_almacen = 1 and id_producto in (select id_producto 
															from detalle_compra_producto) 	
	
	select MIN(fecha) Minima ,MAX(Fecha) FEchamax from venta 
	


--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


execute GenerarVenta 200, '01/06/2017', 7557447

--///////////////////////////////////////////////////////////////////////////	VENTA
update almacen_producto_stock set cantidad_actual = cantidad_actual -750
select * from detalle_venta where id_venta = 169398

select * from venta where id_venta = 169399
select * from detalle_venta where id_producto = 449
select * from almacen_producto_stock where cantidad_actual = 0 
select SUM(subtotal) from detalle_venta

select * from detalle_venta where id_venta = 105



select top 1 id_venta from venta where id_venta > 10 order by total_neto desc

select id_sucursal from venta v, caja c where v.id_venta = 19 AND v.id_caja = c.id_caja

select * from detalle_venta where id_venta = 19

SELECT * FROM egreso where id_venta = 19

select * from detalle_egreso where id_egreso = 19 order by id_producto desc

select * from almacen_producto_stock 
where id_almacen = 6 and id_producto in (select id_producto from detalle_egreso where id_egreso = 4)  
order by id_producto desc


/*
cuando se vende no se afecto a cantidad_disponible -ver eso-							ok
hacer datos mas reales de la tabla almacen_producto_stock								ok
en la tabla almacen_producto_stock la cantidad_actual es > a la cantidad_disponible		ok
validar cuando la cantidad_actual sea CERO												falla
-- quiebre + venta <= hay ese dia
*/



SELECT SUM(detalle_venta.valor_venta) FROM detalle_venta
DELETE FROM compra WHERE totalCompra is null
SELECT SUM(detalle_compra_producto.subtotal) FROM detalle_compra_producto
SELECT * FROM compra
SELECT * FROM detalle_compra_producto



UPDATE almacen_producto_stock SET cantidad_actual = 0 WHERE id_producto = 1 and id_almacen = 6


select * from caja

select * from venta inner join quiebre on quiebre.id_venta = venta.id_venta
select * from detalle_venta where id_venta = 168332 and id_producto =248
select * from almacen_producto_stock

update almacen_producto_stock set cantidad_actual = cantidad_actual - 800, cantidad_disponible= cantidad_disponible-800






	--	INSERT INTO almacen_producto_stock(id_almacen,id_producto,cantidad_actual,cantidad_maxima,cantidad_minima,cantidad_disponible) 
	--	values(@C,@P,100,200,50,70);
												
							
	--	INSERT INTO ingreso (formaPago,montoTotal,debitoFiscal,creditoFiscal,fecha,id_compra, id_empleado)
	--	 VALUES (''Inicio Almacen'',0,0,0,getdate(),@id_compra,@random_empleado);
		 
	--	INSERT INTO KARDEX (id_producto,id_almacen,ingresos_egresos,tipo,fecha) 
	--	VALUES(@id_producto,@id_almacen_random,@cantidad,''I'',getdate()); 
	
	
	
	IF OBJECT_ID(N'dbo.Compra_Foranea',N'T')IS NULL
BEGIN
EXECUTE(
'
 CREATE TRIGGER Compra_Foranea
 ON dbo.compra after UPDATE
    AS
                IF UPDATE(totalCompra)
                BEGIN

                END'
);
END

--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



	

SELECT * FROM dbo.detalle_pedido_producto where id_pedido_compra = 19561
select * from pedido
select * from compra
SELECT * FROM dbo.detalle_compra_producto where id_compra = 9024
select * from ingreso
select * from dbo.detalle_ingreso_producto where id_ingreso =5654
SELECT * FROM dbo.almacen_producto_stock where id_producto = 3504
    
--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

SELECT * FROM compra


SELECT * FROM devolucion


exec DEVOLUCION_COMPRA 3

alter PROCEDURE DEVOLUCION_COMPRA @MOUNT INT
AS
	DECLARE @DATE DATETIME = getdate();
	DECLARE @compra_count int = (SELECT count(*) FROM compra);
	DECLARE @compra_random INT = ROUND(((@compra_count - 1) * RAND() + 1), 0);
	DECLARE @I INT = 0; 
	WHILE(@MOUNT > @I)
		BEGIN		
			SET @I = @I + 1;
			DECLARE @id_compra INT = (SELECT top 1 c.id_compra FROM compra c 
			where c.id_compra not in (select id_compra from devolucion ) ORDER BY NEWID());
			if(@id_compra) is null
			begin 
				print 'no moleste casero';
			end
			else
			begin
			print cast( @id_compra as varchar(50))
			INSERT INTO devolucion (detalle,fecha,id_compra) VALUES ('Producto dañado', GETDATE(),@id_compra);
			end
			
			------
			
			--// aqui sobre el detalle de la compra
			
			------
			
		END
GO