


USE bd_soporte_apruebeme_please


selec


EXEC Comprar_Productos

select * from inventario_fisico
select * from quiebre

EXEC mermar


--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	
	EXEC PEDIDO_COMPRA 200, '2017-05-01', '2017-10-10'
	
	EXEC PEDIDO_COMPRA 100, '2017-01-01', '2017-12-28'
	
	EXEC PEDIDO_COMPRA 3200, '2016-05-01', '2016-12-30'



--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	EXEC trimestral '2017', 2

	EXEC VENTAS_ANUALES '2017';
	
	EXEC VENTAS_ANUALES '2016';
	
	EXEC VENTAS_ANUALES '2019';
	
	EXEC VENTAS_ANUALES '2020';
	
	EXEC VENTAS_ANUALES '2021';
	

	
--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


			DECLARE @TOTAL_COMPRA INT = (select top 1 totalCompra from compra WHERE id_compra > 1 order by totalCompra desc);
			PRINT 'Base Datos = ' + CAST( @TOTAL_COMPRA as Varchar(50));

			DECLARE @ID_COMPRA INT = (select top 1 id_compra from compra WHERE id_compra > 1 order by totalCompra desc);
			
			DECLARE @SUB_TOTAL INT = (select SUM(subtotal) from detalle_compra_producto 
			where id_compra = @ID_COMPRA)
			
			DECLARE @IVA FLOAT = (select iva from compra 
			where id_compra = @ID_COMPRA)

			DECLARE @SUM_GASTOS BIGINT = (select SUM(monto) from gasto
			where id_compra = @ID_COMPRA)
			
			DECLARE @IMPUESTO FLOAT = (select impuesto from compra_valorada
			where id_compra = @ID_COMPRA)

			DECLARE @ARANCEL FLOAT = (select arancel from compra_valorada
			where id_compra = @ID_COMPRA)
			
			DECLARE @TOTAL BIGINT = @SUB_TOTAL + @IVA + @SUM_GASTOS + @IMPUESTO + @ARANCEL
			PRINT  'Logica = ' + CAST( @TOTAL as Varchar(60));
	
			
--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


	DECLARE @TODO_KARDEX INT = (select SUM(INGRESOS_EGRESOS) AS TODO_KARDEX from KARDEX);
	PRINT 'TODO_KARDEX : ' + CAST(@TODO_KARDEX AS VARCHAR(10))
	
    DECLARE @IN INT = (select SUM(cantidad) AS INGRESOS from detalle_ingreso_producto); 
    DECLARE @EG INT = (select SUM(cantidad) AS EGRESOS from detalle_egreso);
    PRINT 'INGRESOS = ' + CAST(@IN AS VARCHAR(10))
    PRINT 'EGRESOS = ' + CAST(@EG AS VARCHAR(10))
    PRINT 'INGRESOS - EGRESOS : ' + CAST(@IN - @EG AS VARCHAR(10))
    
    
    
 --///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  
  
  
SELECT COUNT(*) FROM utilidades where utilidad < 0

SELECT * FROM utilidades where utilidad < 0


SELECT (SUM(SubVenta) - SUM(SubCompra))as Util FROM utilidades
   select * from egreso 
       
       
       
       
	SELECT *, (dv.subtotal-dc.subtotal) as utilidad 
	from detalle_compra_producto dc, detalle_venta dv
	where dc.id_producto = dv.id_producto 
       
 --///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  
  
  
    
   select * from KARDEX where tipo = 'E'
    
    
   select COUNT (*) from KARDEX where tipo = 'E'
   select COUNT (*) from detalle_egreso
   select COUNT (*) from detalle_venta 
   
   select * from detalle_egreso where cantidad >0
   
   select * from detalle_venta where cantidad >9
    
		select id_producto from quiebre group by id_producto order by id_producto

		select COUNT (*) from almacen_producto_stock where cantidad_actual<=0
		
		select * from almacen_producto_stock where cantidad_actual<=0
		
		
		select * from almacen_producto_stock where cantidad_actual > 0
		
		select * from almacen_producto_stock
		
		select * from quiebre
		
		
		select COUNT (*) from quiebre
		
		
		
		select * from venta
		
		select * from compra
		
		
		select SUM(cantidad) from detalle_venta where id_venta = 74
		
		
		select SUM(cantidad) from quiebre where id_venta = 74
		
		
		
		select * from quiebre where id_venta = 74
		
		
		select * from detalle_pedido_producto 
		where id_pedido_compra in (
			select id_pedido_compra from pedido where detalle = 'Pedido_Reorden') 
			and id_producto in (
		select id_producto from almacen_producto_stock where cantidad_actual<=0 and id_almacen = 4 and id_producto in (
		select id_producto from quiebre where id_venta = 74))
		
		
		
		select * from almacen_producto_stock where cantidad_actual<0 and id_almacen = 4 and id_producto in (
		select id_producto from quiebre where id_venta = 74)
		
		
		

CREATE TRIGGER VENTAS
--Crea el egreso y tambien  actualiza el stock por egreso.
    ON dbo.venta after UPDATE
    AS
		BEGIN
			IF UPDATE(total_neto)
			BEGIN
				DECLARE @TOTAL  INT = (SELECT total_neto FROM inserted);
				IF @TOTAL>0
						BEGIN	
						PRINT 'HOLA SOY EL TRIGGER'
				DECLARE @producto INT;
				DECLARE @VENTA INT = (SELECT id_venta from inserted);
				DECLARE @CANTIDAD INT;
				DECLARE @EMPLEADO INT = (SELECT id_empleado FROM inserted);
				DECLARE @IDCAJA INT = (SELECT id_caja FROM INSERTED);
				DECLARE @FECHA DATE = (SELECT fecha FROM INSERTED);
				DECLARE @ALMACEN INT = (SELECT id from almacen inner join sucursal 
				on sucursal.id_sucursal=almacen.id_sucursal inner join caja 
				on caja.id_sucursal=sucursal.id_sucursal inner join venta on venta.id_caja = caja.id_caja 
				where venta.id_venta = @VENTA AND caja.id_caja = @IDCAJA );
				
				INSERT INTO egreso(detalle,id_venta,id_empleado,id_almacen) VALUES ('EGRESO POR VENTA',@VENTA,@EMPLEADO,@ALMACEN);
				DECLARE @EGRESO INT= SCOPE_IDENTITY();
				
				declare cursor1 CURSOR 
				FOR  select id_producto,cantidad from detalle_venta where id_venta = @VENTA 
				open cursor1 fetch next from cursor1 into @producto,@CANTIDAD
				while @@FETCH_STATUS = 0 
					begin 
					 DECLARE @STOCK_cantidad_actual INT = (select cantidad_actual from almacen_producto_stock WHERE id_almacen = @ALMACEN and id_producto = @producto)
						IF (@STOCK_cantidad_actual > 0)
						BEGIN---if
							 UPDATE dbo.almacen_producto_stock 
							 SET cantidad_actual = cantidad_actual - @CANTIDAD
							 WHERE id_almacen = @ALMACEN and id_producto = @producto;
					 
							INSERT INTO detalle_egreso(id_egreso,id_producto,cantidad) values (@EGRESO,@producto,@CANTIDAD)		 
							--//INSERTAR EL KARDEX-EGRESO DEL PRODUCTO	
							DECLARE @CANTIDAD_AUX INT = @CANTIDAD * -1 ;
							INSERT INTO KARDEX (id_producto,id_almacen,ingresos_egresos,tipo,fecha) 
							VALUES(@producto,@ALMACEN,@CANTIDAD_AUX,'E',@FECHA)	
						END
						ELSE
						BEGIN 
							print '***************************************E-R-R-O-R*******************************************'; 
							print '***************************************E-R-R-O-R*******************************************'; 
							print '***************************************E-R-R-O-R*******************************************'; 
							print 'Producto = ' + Cast(@producto as varchar(10));
							print 'Cant = ' + Cast(@CANTIDAD as varchar(10));
							print '***************************************E-R-R-O-R*******************************************'; 
							print '***************************************E-R-R-O-R*******************************************'; 
							print '***************************************E-R-R-O-R*******************************************'; 
						END;
		
					 fetch next from cursor1 into @producto,@CANTIDAD 
					 end 
				 close cursor1 
				 deallocate cursor1 
				 --//Actualizar el stock luego de la venta
					END
					
			END
		END	
	
	
	
	
--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



	
	execute GenerarVenta 1200,'01/05/2017', 7557447
	execute GenerarVenta 1200, '01/06/2017', 7557447
	execute GenerarVenta 1200, '01/07/2017', 7557447
	execute GenerarVenta 1200, '01/08/2017', 7557447
	execute GenerarVenta 1200, '01/09/2017', 7557447
	execute GenerarVenta 1200, '01/10/2017', 7557447



--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

IF OBJECT_ID(N'dbo.PUNTO_REORDEN',N'T') IS NULL
BEGIN
EXECUTE(
'
create TRIGGER PUNTO_REORDEN
    ON dbo.almacen_producto_stock after UPDATE
    AS
				--	DECLARE @cantidad_actual INT = (SELECT cantidad_actual FROM inserted);
					if UPDATE (cantidad_actual)
					begin
						DECLARE @cantidad_actual INT = (SELECT cantidad_actual FROM inserted);
						if(@cantidad_actual = 0)
						begin 
						--	DECLARE @id_egreso INT = (SELECT id_egreso FROM inserted);
							DECLARE @id_producto INT = (SELECT id_producto FROM inserted);
							DECLARE @id_almacen INT = (SELECT id_almacen FROM inserted);
						--	DECLARE @id_almacen INT = (SELECT id_almacen FROM egreso where id_egreso = @id_egreso);
							print ''Aumentar el stock '' + CAST(@cantidad_actual as varchar(50))
							print ''Aumentar el @id_producto '' + CAST(@id_producto as varchar(50))
							print ''Aumentar el @id_almacen '' + CAST(@id_almacen as varchar(50))

							DECLARE @id_empleado INT = (select id_empleado from venta where id_venta = 
														(select top 1 id_venta from venta order by id_venta desc))
							print ''Inserto un pedido'';
							INSERT INTO pedido (fecha, valor_total, id_empleado,detalle) 
							VALUES (getdate(), null, @id_empleado ,''Pedido_Reorden'')
							
							DECLARE @id_pedido INT = SCOPE_IDENTITY();							
							DECLARE @max INT = (select cantidad_maxima from almacen_producto_stock WHERE id_producto = @id_producto and id_almacen = @id_almacen);
							DECLARE @cantidad INT = ROUND(((@max - 1) * RAND() + (@max / 2)), 0);									
							DECLARE @valor_compra INT = (SELECT TOP 1 valor from Precio inner join producto on producto.id_precio=Precio.id where producto.id_producto=1 ORDER BY NEWID());
							
							print ''Inserto el detalle del pedido'';
							INSERT INTO detalle_pedido_producto(cantidad, valor_compra,id_pedido_compra, id_producto)
							VALUES (@cantidad, @valor_compra, @id_pedido , @id_producto )
							
							DECLARE @valor_total INT = @cantidad * @valor_compra;
							
							print ''Actualizo el total del pedido'';
							UPDATE pedido SET valor_total = @valor_total WHERE id_pedido_compra = @id_pedido;
							
							--print ''Aumento el stock'';
							--UPDATE almacen_producto_stock 
							--SET cantidad_disponible = (cantidad_disponible + (@max / 2) ), cantidad_actual = (cantidad_actual + (@max / 2) )
							--WHERE id_almacen = @id_almacen AND id_producto = @id_producto	
							print ''acabo el trigger'';
						end
					end	'
);
END

--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

IF OBJECT_ID(N'dbo.LlenarAlmacen',N'P') IS NULL
BEGIN
EXECUTE(
'
create procedure LlenarAlmacen
as
	BEGIN
		DECLARE @ALMACEN INT = 6;
		DECLARE @PRODUCTOS INT = 3506;
		DECLARE @C INT = 1;
		DECLARE @QUANTITY  INT = 100;
		
		INSERT INTO pedido(fecha,valor_total,id_empleado,detalle) 
		VALUES(getdate(),NULL,1,''Pedido Inicial'');
		DECLARE @PED  INT = 1;
		print ''Pedido Creado''
		
		INSERT INTO compra(iva,fecha,totalCompra,subtotal,id_pedido_compra,id_proveedor) 
		VALUES(0.13,getdate(),NULL,NULL,@PED,1);
		DECLARE @COMPRAID INT = 1;
		print ''Compra Creada''
		
		WHILE @C<=@ALMACEN 
			BEGIN
				DECLARE @P INT = 1 ;
					WHILE @P<=@PRODUCTOS
						BEGIN
											
						DECLARE @VALORPRECIO INT = (SELECT TOP 1 valor from Precio inner join producto on producto.id_precio=Precio.id 
						where producto.id_producto=@P ORDER BY NEWID());
						DECLARE @VALORCOMPRA INT  = ROUND(((@VALORPRECIO - (@VALORPRECIO-@VALORPRECIO*0.12) -1) * RAND() + @VALORPRECIO), 0);
						INSERT INTO detalle_pedido_producto (cantidad,valor_compra,id_pedido_compra,id_producto) 
						values (@QUANTITY,@VALORCOMPRA*@QUANTITY,@PED , @P);
						
						DECLARE @PRECIOUNITARIO INT = @VALORCOMPRA;
						DECLARE @SUBTOTAL INT = @PRECIOUNITARIO*@QUANTITY;
						INSERT INTO detalle_compra_producto(id_producto,id_compra,cantidad,precioUnitario,subtotal)
						VALUES(@P,@COMPRAID,@QUANTITY,@PRECIOUNITARIO,@SUBTOTAL);
				
						SET @P=@P+1;
						END--while producto
				SET @C = @C+1;
			END--while almacen
			
		-- Actualiza la cabezera con el valor total del pedido			
		DECLARE @VALORTORAL  bigint = 	(SELECT SUM(valor_compra) from detalle_pedido_producto where id_pedido_compra = @PED );					
		UPDATE pedido SET valor_total = @VALORTORAL WHERE pedido.id_pedido_compra=  @PED;
		print ''Pedido Actualizado'';  
	
		--///SE ACTUALIZA LA CABEZERA DE LA COMPRA
		DECLARE @SUBTOTALCOMPRA bigint = (SELECT SUM(subtotal) FROM detalle_compra_producto 
		WHERE detalle_compra_producto.id_compra=@COMPRAID);	
		UPDATE compra SET subtotal = @SUBTOTALCOMPRA WHERE compra.id_compra=@COMPRAID; 
		UPDATE compra SET iva = @SUBTOTALCOMPRA*compra.iva WHERE compra.id_compra=@COMPRAID; 
		UPDATE compra SET totalCompra = @SUBTOTALCOMPRA+compra.iva WHERE compra.id_compra=@COMPRAID;	
		print ''Compra Actualizada'';
	END;'
);
END
	