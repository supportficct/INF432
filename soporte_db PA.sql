





USE bd_soporte_apruebeme_please2



	
--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


CREATE FUNCTION dbo.getRandomDate
(
	@lower DATE,
	@upper DATE
)
RETURNS DATE
AS
BEGIN
	DECLARE @random DATE
	SELECT @random = DATEADD(day, DATEDIFF(DAY, @lower, @upper) * seed, @lower) FROM dbo.seeder
	RETURN @random
END


--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


CREATE PROCEDURE PEDIDO_COMPRA 
@MOUNT INT, @DATEMIN DATE, @DATEMAX DATE
AS 
	DECLARE @DATE DATE;
	DECLARE @Upper INT;
	DECLARE @Lower INT
	DECLARE @MINEMPLEADO INT ;
	DECLARE @MAXEMPLEADO INT;
	DECLARE @MINPRODUCT INT ;
	DECLARE @MAXPRODUCT INT;
	DECLARE @EMPLEADO INT;
	DECLARE @c INT; 
	--select dbo.getRandomDate (GETDATE(),DATEADD(MONTH,10,GETDATE()));
	SET @DATE = (select [dbo].[getRandomDate](@DATEMIN,@DATEMAX));
	SET @c = 0 ;
	SET @Lower = 1 ---- The lowest random number
	SET @Upper = 20 ---- The highest random number
	
	
	
	SET @MINPRODUCT =( SELECT TOP 1 id_producto FROM producto ORDER BY id_producto ASC ); 
	SET @MAXPRODUCT =  (SELECT TOP 1 id_producto FROM producto ORDER BY id_producto DESC );
	SET @MINEMPLEADO = ( SELECT TOP 1 id_empleado  	FROM empleado	ORDER BY id_empleado ASC) ;
	SET @MAXEMPLEADO =  (SELECT TOP 1 id_empleado  	FROM empleado	ORDER BY id_empleado DESC );
	
	SET @EMPLEADO =  ROUND(((@MAXEMPLEADO - @MINEMPLEADO -1) * RAND() + @MINEMPLEADO), 0);
	
	DECLARE @PRODUCT INT =  ROUND(((@MAXPRODUCT - @MINPRODUCT -1) * RAND() + @MINPRODUCT), 0);
	DECLARE @CONTADORDETALLE INT = 0;
	DECLARE @CANTIDADRANDOMPRODUCTOS INT = ROUND(((@Upper - @Lower -1) * RAND() + @Lower), 0);
	DECLARE @VALORCOMPRAPRODUCTO INT ;
	
	
	DECLARE @QUANTITY  INT = ROUND(((20 - 1 -1) * RAND() + 1), 0);
	WHILE @c < @MOUNT
			BEGIN
			
			INSERT INTO pedido(fecha,valor_total,id_empleado, detalle) 
			VALUES(@DATE,NULL,@EMPLEADO,'Pedido Solicitado');
			DECLARE @PED  INT = SCOPE_IDENTITY ();
			
			---//// PEDIDOS QUE SE VUELVEN COMPRAS 
						DECLARE @R INT = ROUND(((2 - 0 -1) * RAND() + 0), 0);
							IF @R =1 -- Se vuelve compra dicho pedido
								BEGIN	
									DECLARE @MINPROVEEDOR INT=( SELECT TOP 1 id_proveedor  	FROM proveedor	ORDER BY id_proveedor ASC);
									DECLARE @MAXPROVEEDOR INT= (SELECT TOP 1 id_proveedor  	FROM proveedor	ORDER BY id_proveedor DESC );
									DECLARE @PROVEEDOR INT = ROUND(((@MAXPROVEEDOR - @MINPROVEEDOR -1) * RAND() + @MINPROVEEDOR), 0);
									--//CABEZERA DE LA COMPRA
									DECLARE @Varia int = ROUND(((25 - 1 -1) * RAND() + 1), 0);
									DECLARE @FECHA_COMPRA date = DATEADD(day, @Varia, @DATE);
									INSERT INTO compra(iva,fecha,fecha_pedido,totalCompra,subtotal,id_pedido_compra,id_proveedor) 
									values(0.13,@FECHA_COMPRA,@DATE,NULL,NULL,@PED,@PROVEEDOR);
									DECLARE @COMPRAID INT = SCOPE_IDENTITY ();
									
								END;
					
					------///	
			
				WHILE 	@CONTADORDETALLE <@CANTIDADRANDOMPRODUCTOS
					BEGIN
					--////DETALLES DE PEDIDO
						DECLARE @VALORPRECIO INT = (SELECT TOP 1 valor from Precio inner join producto on producto.id_precio=Precio.id 
						where producto.id_producto=1 ORDER BY NEWID());
						DECLARE @VALORCOMPRA INT  = ROUND(((@VALORPRECIO - (@VALORPRECIO-@VALORPRECIO*0.60) -1) * RAND() + @VALORPRECIO), 0);
						--select @VALORCOMPRA 
						
						INSERT INTO detalle_pedido_producto (cantidad,valor_compra,id_pedido_compra,id_producto) 
						values (@QUANTITY,@VALORCOMPRA*@QUANTITY,@PED , @PRODUCT);
					
					--///DETALLE DE LA COMPRA 	
						IF @R = 1
							BEGIN
								DECLARE @PRECIOUNITARIO INT = @VALORCOMPRA;
								DECLARE @SUBTOTAL INT = @PRECIOUNITARIO*@QUANTITY;
								INSERT INTO detalle_compra_producto(id_producto,id_compra,cantidad,precioUnitario,subtotal)
								VALUES(@PRODUCT,@COMPRAID,@QUANTITY,@PRECIOUNITARIO,@SUBTOTAL);
								---////
								
							---	UPDATE dbo.almacen_producto_stock SET cantidad_actual = cantidad_actual+@QUANTITY;
								--//
							END
					--//FINDETALLE DE COMPRA		
						--//////////
						SET @QUANTITY   = ROUND(((10 - 1 -1) * RAND() + 1), 0);
						SET @PRODUCT =ROUND(((@MAXPRODUCT - @MINPRODUCT -1) * RAND() + @MINPRODUCT), 0);
						SET @CONTADORDETALLE= @CONTADORDETALLE+1;	
					END
				
			-- Actualiza la cabezera con el valor total del pedido			
			DECLARE @VALORTORAL  INT = 	(SELECT SUM(valor_compra) from detalle_pedido_producto where id_pedido_compra = @PED );					
			UPDATE pedido SET valor_total = @VALORTORAL WHERE pedido.id_pedido_compra=  @PED;  
			
 			SET @c=@c+1;
 			SET @DATE = (select [dbo].[getRandomDate](@DATEMIN,@DATEMAX));
 			SET @CONTADORDETALLE = 0 ;
			SET @CANTIDADRANDOMPRODUCTOS  = ROUND(((@Upper - @Lower -1) * RAND() + @Lower), 0);
			--///SE ACTUALIZA LA CABEZERA DE LA COMPRA
				IF @R=1
				BEGIN
					DECLARE @SUBTOTALCOMPRA INT = (SELECT SUM(subtotal) FROM detalle_compra_producto 
					WHERE detalle_compra_producto.id_compra=@COMPRAID);	
					UPDATE compra SET subtotal = @SUBTOTALCOMPRA WHERE compra.id_compra=@COMPRAID; 
					UPDATE compra SET iva = @SUBTOTALCOMPRA*compra.iva WHERE compra.id_compra=@COMPRAID; 
					UPDATE compra SET totalCompra = @SUBTOTALCOMPRA+compra.iva WHERE compra.id_compra=@COMPRAID;	
				END;
			--//FIN ACTUALIZACION CABEZERA COMPRA	
			
			END;
GO
	
	
	
	
--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


 create TRIGGER INGRESO_COMPRA
    ON compra after UPDATE
    AS
		IF UPDATE(totalCompra)
		BEGIN
		
						DECLARE @id_compra INT = (SELECT id_compra FROM inserted);
                        DECLARE @IMPUESTO float; 
                        DECLARE @ARANCEL float;
                        DECLARE @MAS float;
                        SET @id_compra = (SELECT id_compra FROM inserted);
                        DECLARE @sub float = (SELECT subtotal FROM inserted);
                        DECLARE @total float= (SELECT totalCompra FROM inserted);
                        DECLARE @conceptos int = (SELECT count(*) FROM concepto);
                        DECLARE @R INT = ROUND(((10 - 0 -1) * RAND() + 0), 0);
                        
                        SET @MAS = 0;
                                IF @R > 4
                                BEGIN        
                                        SET @ARANCEL = ROUND((@sub * 0.45),2); 
                                        SET @IMPUESTO = ROUND((@sub * 0.15), 2);
                                        --SET @MAS = @ARANCEL + @IMPUESTO + @total;
                                        SET @MAS = @ARANCEL + @IMPUESTO;
                                        INSERT INTO compra_valorada (impuesto,arancel,id_compra) 
                                        VALUES (@IMPUESTO,@ARANCEL,@id_compra);
                                        --UPDATE compra set totalCompra = @MAS WHERE id_compra = @id_compra
                                END
                        DECLARE @suma_gasto BIGINT = 0;
                                IF @R > 2
                                BEGIN
                                        DECLARE @Ciclo INT = ROUND(((@conceptos - 1) * RAND() + 1), 0);
                                        
                                                WHILE @Ciclo > 0 
                                                BEGIN
                                                        DECLARE @gasto INT = ROUND(((150 - 1) * RAND() + 1), 0);
                                                        INSERT INTO gasto (id_concepto, id_compra, monto, id_tipo_moneda) 
                                                        VALUES (@Ciclo, @id_compra,@gasto,2);--SIEMPRE EN Bs
                                                        SET @Ciclo = @Ciclo - 1;        
                                                        SET @suma_gasto = @suma_gasto + @gasto;
                                                END        
                                               
                                END        
                        DECLARE @MAS_GASTOS BIGINT = @MAS + @suma_gasto + @total;
                        UPDATE compra set totalCompra = @MAS_GASTOS WHERE id_compra = @id_compra        
                                                                
                                
		DECLARE @random_empleado INT = ROUND(((19 - 1) * RAND() + 1), 0);
		DECLARE @DATE DATE = (SELECT fecha FROM inserted);
		DECLARE @Varia int = ROUND(((2) * RAND() + 0), 0);
		DECLARE @FECHA_INGRESO date = DATEADD(day, @Varia, @DATE);
									
		INSERT INTO ingreso (formaPago,montoTotal,debitoFiscal,creditoFiscal,fecha,id_compra, id_empleado)
		 VALUES ('Contado Eddy',0,0,0,@FECHA_INGRESO,@id_compra,@random_empleado);
		
		DECLARE @montoTotal INT = 0;
		
		DECLARE @id_ingreso INT = SCOPE_IDENTITY ();
			DECLARE @id_producto INT,@cantidad INT,@subtotal INT;
				DECLARE cDetalle CURSOR FOR
				SELECT id_producto,cantidad,subtotal from detalle_compra_producto where id_compra = @id_compra
					OPEN cDetalle
						FETCH next from cDetalle INTO @id_producto,@cantidad,@subtotal
							WHILE (@@FETCH_STATUS = 0 )
								BEGIN
										SET @montoTotal = @montoTotal + @subtotal;
							
										DECLARE @concepto int = (SELECT count(*) FROM sucursal);
										DECLARE @id_almacen_random INT = ROUND(((@concepto - 1) * RAND() + 1), 0);
											
										INSERT INTO detalle_ingreso_producto (cantidad,subtotal,id_ingreso,id_producto,id_almacen)
										VALUES (@cantidad,@subtotal,@id_ingreso,@id_producto,@id_almacen_random);						
		
					DECLARE @cantidad_disponible INT = 
					(SELECT cantidad_disponible FROM almacen_producto_stock WHERE id_almacen = @id_almacen_random AND id_producto = @id_producto);		
					DECLARE @cantidad_actual INT = 
					(SELECT cantidad_actual FROM almacen_producto_stock WHERE id_almacen = @id_almacen_random AND id_producto = @id_producto);
					
					print 'Antes : *************************************************************************************'; 
					print 'Producto = ' + CAST (@id_producto AS VARCHAR(10)) ;
					print 'Sucursal = '+ CAST (@id_almacen_random AS VARCHAR(10)) ; 
					print 'Cantidad Actual = '+ CAST (@cantidad_actual AS VARCHAR(10)) ;
					print 'Cantidad Disponible = '+ CAST (@cantidad_disponible AS VARCHAR(10));
					print 'Despues : *************************************************************************************';
								
				--	IF(@id_compra = 1)
				--	BEGIN 
				--		PRINT 'PRIMERA Y UNICA VEZ'
				--		UPDATE almacen_producto_stock 
				--		SET cantidad_actual = (cantidad_actual + 0 ), cantidad_disponible = (cantidad_disponible + 0 )--create
				---		WHERE id_almacen = @id_almacen_random AND id_producto = @id_producto		
				--	END
			--		ELSE
				--	BEGIN
						DECLARE @existe INT = (select cantidad_actual from almacen_producto_stock where id_almacen = @id_almacen_random AND id_producto = @id_producto);
						if @existe is null
						begin						
							DECLARE @max INT = ROUND(((25 - 20) * RAND() + 20), 0);
							DECLARE @min INT = ROUND(((10 - 5) * RAND() + 5), 0);	
							DECLARE @disponible INT = ROUND(((5 - 1) * RAND() + 1), 0);	
						
							INSERT INTO almacen_producto_stock(id_almacen,id_producto,cantidad_actual,cantidad_maxima,cantidad_minima,cantidad_disponible) 
							values(@id_almacen_random,@id_producto,@cantidad,@max,@min,@disponible);
						end
						else
						begin 
							UPDATE almacen_producto_stock 
							SET cantidad_actual = (cantidad_actual + @cantidad ), cantidad_disponible = (cantidad_disponible + @cantidad )--alter
							WHERE id_almacen = @id_almacen_random AND id_producto = @id_producto
						end;
				--	END;													
					print 'Actualizo [almacen_producto_stock] = '+ CAST (@id_almacen_random AS VARCHAR(10)) + ' - ' + CAST (@id_producto AS VARCHAR(10))+ ' - ' ;
					--//INSERTAR EL KARDEX-INGRESO DEL PRODUCTO	
					INSERT INTO KARDEX (id_producto,id_almacen,ingresos_egresos,tipo,fecha) 
					VALUES(@id_producto,@id_almacen_random,@cantidad,'I',@FECHA_INGRESO); 
					   
										DECLARE @stock_min INT = ROUND(((70 - 1) * RAND() + 1), 0);
										DECLARE @stock_max INT = ROUND(((100 - 1) * RAND() + 1), 0);

										INSERT INTO producto_almacen (id_almacen,id_producto,costo_especifico,stock_min,stock_max) 
										VALUES (@id_almacen_random,@id_producto,@subtotal,@stock_min,@stock_max);
																		
									FETCH next from cDetalle INTO @id_producto,@cantidad,@subtotal
						END
					CLOSE cDetalle
				DEALLOCATE cDetalle				
				
		DECLARE @debitoFiscal INT = @montoTotal * 0.13;
		DECLARE @creditoFiscal INT = @montoTotal * 0.16;
		
		UPDATE ingreso SET montoTotal = @montoTotal,debitoFiscal = @debitoFiscal, creditoFiscal = @creditoFiscal
		WHERE 	id_ingreso = @id_ingreso
		 
		
		
		END
	GO


--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


create procedure GenerarVenta
@N as int, @FI as date, @AUTORIZACION as int
As
Begin
	while @N>0
	begin---while
	
	DECLARE @EMPLEADO INT;
	DECLARE @CLIENTE INT;
	
	DECLARE @MINEMPLEADO INT ;
	DECLARE @MAXEMPLEADO INT;
	
	DECLARE @MINCLIENTE INT ;
	DECLARE @MAXCLIENTE INT;
	SET @MINEMPLEADO = ( SELECT TOP 1 id_empleado  	FROM empleado	ORDER BY id_empleado ASC) ;
	
	SET @MAXEMPLEADO =  (SELECT TOP 1 id_empleado  	FROM empleado	ORDER BY id_empleado DESC );
	SET @MINCLIENTE = ( SELECT TOP 1 id_cliente  	FROM cliente	ORDER BY id_cliente ASC) ;
	SET @MAXCLIENTE =  (SELECT TOP 1 id_cliente  	FROM cliente	ORDER BY id_cliente DESC );
	SET @EMPLEADO =  ROUND(((@MAXEMPLEADO - @MINEMPLEADO -1) * RAND() + @MINEMPLEADO), 0);
	SET @CLIENTE =  ROUND(((@MAXCLIENTE - @MINCLIENTE -1) * RAND() + @MINCLIENTE), 0);
	
	DECLARE @FECHA DATE;
	SET @FECHA =  DATEADD(DAY,ROUND(RAND()*27+1,0),@FI)
	
	DECLARE @SUMA DECIMAL(12,2);
	
	SET @SUMA=0;
	
	DECLARE @MINCAJA INT = (SELECT TOP 1 id_caja FROM caja	ORDER BY id_caja ASC ); 
	DECLARE @MAXCAJA INT =  (SELECT TOP 1 id_caja FROM caja ORDER BY id_caja DESC );
	DECLARE @NCAJA  INT =  ROUND(((@MAXCAJA - @MINCAJA -1) * RAND() + @MINCAJA), 0);
	--print @NCAJA
	--UPDATE VENTA SET id_caja=@NCAJA WHERE id_venta=@idventa;
	DECLARE @FORMADEPAGO INT =  ROUND(((3 - 1 -1) * RAND() + 1), 0);
	
	insert into venta(fecha,descuento,valor_total,total_neto,id_cliente,id_empleado,id_caja,id_formapago) 
	values (@FECHA,0,0,0,@CLIENTE,@EMPLEADO,@NCAJA,@FORMADEPAGO);
	declare @idventa int =SCOPE_IDENTITY ();
	
	
	DECLARE @ALMACEN INT = (SELECT id from almacen inner join sucursal 
				on sucursal.id_sucursal=almacen.id_sucursal inner join caja 
				on caja.id_sucursal=sucursal.id_sucursal inner join venta on venta.id_caja = caja.id_caja 
				where venta.id_venta = @idventa AND caja.id_caja = @NCAJA );
	
	
	INSERT INTO egreso(detalle,id_venta,id_empleado,id_almacen) 
	VALUES ('EGRESO POR VENTA',@idventa,@EMPLEADO,@ALMACEN);
	DECLARE @EGRESO INT= SCOPE_IDENTITY();
	
	DECLARE @DETALLES INT = ROUND(((7  -1) * RAND() + 1), 0);
	--print @DETALLES
	
	WHILE @DETALLES>0
	BEGIN---while

		DECLARE @CANTIDAD INT = ROUND(((100 - 10 -1) * RAND() + 10), 0);---///ERROR MAX DEL ALMACEN PRODCTO STOCK
		DECLARE @MAXPRODUCT INT;
		DECLARE @MINPRODUCT INT;
		DECLARE @PRECIO DECIMAL(12,2);
		DECLARE @SUCURSAL INT = @ALMACEN;
		DECLARE @PRODUCTO INT = (SELECT TOP 1 producto.id_producto from producto inner join almacen_producto_stock on producto.id_producto=almacen_producto_stock.id_producto inner join almacen on almacen.id = almacen_producto_stock.id_almacen inner join sucursal on sucursal.id_sucursal = almacen.id_sucursal inner join caja on sucursal.id_sucursal = caja.id_sucursal and caja.id_caja= @NCAJA   ORDER BY NEWID())
		DECLARE @STOCK INT = (
		select TOP 1 cantidad_actual from almacen_producto_stock inner join almacen 
		on almacen.id = almacen_producto_stock.id_almacen inner join sucursal 
		on sucursal.id_sucursal = almacen.id_sucursal inner join caja 
		on sucursal.id_sucursal = caja.id_sucursal  
		--where id_producto=4 and caja.id_caja= 130  ORDER BY NEWID());
		where id_producto=@PRODUCTO and caja.id_caja= @NCAJA  ORDER BY NEWID());
		
		if	@STOCK is null
		begin 			
			print '***************************************E-D-D-Y*******************************************';
		end	
								
			IF (@STOCK > @CANTIDAD)
				BEGIN---if
					SET @PRECIO=(SELECT TOP 1 valor from Precio inner join producto on producto.id_precio=Precio.id 
					where producto.id_producto =@PRODUCTO order BY Precio.id DESC);
					
					SET @PRECIO=@PRECIO*1.2;
					
					insert into detalle_venta (cantidad,valor_venta,id_producto,id_venta,subtotal) 
					values(@CANTIDAD,@PRECIO,@PRODUCTO ,@idventa,@CANTIDAD*@PRECIO );	
					SET @SUMA=@SUMA+(@CANTIDAD*@PRECIO);
					
					INSERT INTO detalle_egreso(id_egreso,id_producto,cantidad) 
					values (@EGRESO,@producto,@CANTIDAD)		 
					--//INSERTAR EL KARDEX-EGRESO DEL PRODUCTO	
					DECLARE @CANTIDAD_AUX INT = @CANTIDAD * -1 ;
					INSERT INTO KARDEX (id_producto,id_almacen,ingresos_egresos,tipo,fecha) 
					VALUES(@producto,@ALMACEN,@CANTIDAD_AUX,'E',@FECHA);
					
		BEGIN TRANSACTION
		UPDATE dbo.almacen_producto_stock 
		SET cantidad_actual = cantidad_actual - @CANTIDAD
		WHERE id_almacen = @ALMACEN and id_producto = @PRODUCTO;
		COMMIT TRANSACTION
									
				END
			ELSE	
			BEGIN
				IF (@STOCK > 0)
				BEGIN---if
					DECLARE @VENDER_EXISTENTE INT = @STOCK;	
								SET @PRECIO=(SELECT TOP 1 valor from Precio inner join producto on producto.id_precio=Precio.id 
								where producto.id_producto =@PRODUCTO order BY Precio.id DESC);
								insert into detalle_venta (cantidad,valor_venta,id_producto,id_venta,subtotal) 
								values(@VENDER_EXISTENTE,@PRECIO,@PRODUCTO ,@idventa,@VENDER_EXISTENTE*@PRECIO);		
								SET @SUMA=@SUMA+(@VENDER_EXISTENTE*@PRECIO);
																
								INSERT INTO detalle_egreso(id_egreso,id_producto,cantidad) 
								values (@EGRESO,@producto,@VENDER_EXISTENTE)		 
								--//INSERTAR EL KARDEX-EGRESO DEL PRODUCTO	
								
								DECLARE @CANTIDAD_Exist INT = @VENDER_EXISTENTE * -1 ;
								INSERT INTO KARDEX (id_producto,id_almacen,ingresos_egresos,tipo,fecha) 
								VALUES(@producto,@ALMACEN,@CANTIDAD_Exist,'E',@FECHA)	
								
								DECLARE @PEDIDO_FALTANTE INT = @CANTIDAD - @STOCK;	
							--print '***************************************F-A-L-T-O*******************************************';
								Print 'Ha faltado ' + CAST(@VENDER_EXISTENTE as Varchar(100)) + ' del producto ' + CAST(@PRODUCTO as Varchar(100)) +' de la venta ' +CAST(@idventa as Varchar(100));
								insert into quiebre (fecha,cantidad,id_producto,id_sucursal,id_venta)
								values(@FECHA,@PEDIDO_FALTANTE,@PRODUCTO,@SUCURSAL,@idventa);								
							--print '***************************************F-A-L-T-O*******************************************';	
						
		BEGIN TRANSACTION
		UPDATE dbo.almacen_producto_stock 
		SET cantidad_actual = cantidad_actual - @VENDER_EXISTENTE
		WHERE id_almacen = @ALMACEN and id_producto = @PRODUCTO;
		COMMIT TRANSACTION
			
				END
				ELSE
				BEGIN
					Print 'Generando quiebre del producto ' +CAST(@PRODUCTO as Varchar(100)); 
					insert into quiebre (fecha,cantidad,id_producto,id_sucursal,id_venta) 					
					values(@FECHA,@CANTIDAD,@PRODUCTO,@SUCURSAL,@idventa);	
				END;		
			END
		SET @DETALLES=@DETALLES-1;
	END --while
	
	
	UPDATE VENTA SET valor_total=@SUMA WHERE id_venta=@idventa;
	DECLARE @TOTAL DECIMAL(12,2);
	DECLARE @DESCUENTO DECIMAL(12,2)=  ROUND(((100 - 2 -1) * RAND() + 2), 0);
	
	UPDATE VENTA SET descuento=@DESCUENTO WHERE id_venta=@idventa;
	
	DECLARE @VALORTOTAL DECIMAL(12,2);
	SET @VALORTOTAL=(select valor_total from venta where id_venta=@idventa);
	SET @TOTAL=@VALORTOTAL-@DESCUENTO;
	UPDATE VENTA SET total_neto=@TOTAL WHERE id_venta=@idventa;
	if (@VALORTOTAL=0)
		begin
		print '***************************************E-L-I-M-I-N-A*******************************************';
			delete from egreso where egreso.id_egreso = @EGRESO;
			delete from venta where venta.id_venta = @idventa;
		end
		else 
			begin 
				DECLARE @IT DECIMAL (12,2);
				SET @IT=((@SUMA*3)/100);
				DECLARE @IDCLIENTE INT = (SELECT id_cliente FROM venta WHERE id_venta=@idventa );
				DECLARE @NIT INT = (SELECT nit FROM cliente WHERE id_cliente=@IDCLIENTE);
				
				insert into factura_venta values(@FECHA,@NIT,@SUMA,@IT,@AUTORIZACION,@idventa);
			end
	SET @N=@N-1;
	end--while
End



--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


create PROCEDURE trimestral 
@ANO VARCHAR(4),@trim int
AS 
	BEGIN
	
	DECLARE @C INT = 1; 
	DECLARE @DATE DATE = '01/01/'+@ANO;
	IF @TRIM = 1 
	BEGIN
		SET @DATE  = '01/01/'+@ANO;
		
		WHILE @C <=3 
			BEGIN
			execute GenerarVenta 200,@DATE , 7557447
			SET @DATE = (DATEADD(MONTH,1,@DATE));
			SET @C= @C+1;
			END
	END
	ELSE 
		BEGIN
			IF @TRIM = 2 
			BEGIN
				SET @DATE  = '01/04/'+@ANO;
				
				WHILE @C <=3 
					BEGIN
					execute GenerarVenta 200,@DATE , 7557447
					SET @DATE = (DATEADD(MONTH,1,@DATE));
					SET @C= @C+1;
					END
			END
			ELSE
			BEGIN
				IF @TRIM =3
				BEGIN
					SET @DATE  = '01/06/'+@ANO;
				
					WHILE @C <=3 
					BEGIN
					execute GenerarVenta 200,@DATE , 7557447
					SET @DATE = (DATEADD(MONTH,1,@DATE));
					SET @C= @C+1;
					END
				END
				ELSE
				
				BEGIN
				SET @DATE  = '01/09/'+@ANO;
				
				WHILE @C <=3 
					BEGIN
					execute GenerarVenta 200,@DATE , 7557447
					SET @DATE = (DATEADD(MONTH,1,@DATE));
					SET @C= @C+1;
					END
				END
			END
		END
	END
	
	
	
--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

create procedure mermar
as 
begin
	DECLARE @MIN DATE = '01-01-2016';
	DECLARE @MAX DATE = GETDATE();
	DECLARE @FECHA DATE = (dbo.getRandomDate (@MIN,@MAX));
	DECLARE @ALMACEN INT = (SELECT TOP 1 id from almacen order by  newid());
	DECLARE @PRODUCTO INT;
	INSERT INTO inventario_fisico(fecha,id_almacen)VALUES(@FECHA,@ALMACEN);
	DECLARE @INV INT = SCOPE_IDENTITY();
	DECLARE @EMPLEADO INT = (SELECT TOP 1 id_empleado from empleado ORDER BY NEWID());
	INSERT INTO egreso(detalle,id_venta,id_empleado,id_almacen) values ('Egreso por Perdida - mermar',NULL,@EMPLEADO,@ALMACEN)
	DECLARE @EGRESO INT = SCOPE_IDENTITY();
			declare cursor7 CURSOR 
			FOR  select  TOP 650 id_producto from producto order by NEWID();
			open cursor7 fetch next from cursor7 into @PRODUCTO					
				while @@FETCH_STATUS = 0 
					begin 
						DECLARE @FALTANTE INT =ROUND(((10 - 2 -1) * RAND() + 2), 0);
						DECLARE @STOCK INT = (SELECT cantidad_actual from dbo.almacen_producto_stock where id_producto = @PRODUCTO AND id_almacen=@ALMACEN);
						IF @STOCK>0
						BEGIN
							WHILE   @FALTANTE >@STOCK 
							BEGIN
								SET @FALTANTE = ROUND(((@STOCK -2  -1) * RAND() + 3), 0);
							END
							
							INSERT INTO detalle_inventario_producto(faltante,id_inventario_fisico,id_producto) VALUES(@FALTANTE,@INV,@PRODUCTO);
							INSERT INTO detalle_egreso(id_egreso,id_producto,cantidad) VALUES(@EGRESO,@PRODUCTO,@FALTANTE);
							UPDATE dbo.almacen_producto_stock SET cantidad_actual = cantidad_actual - @FALTANTE where id_producto= @PRODUCTO and id_almacen = @ALMACEN;
						END
					 fetch next from cursor7 into @PRODUCTO 
					 end 
				 close cursor7 
				 deallocate cursor7
	--UPDATE dbo.almacen_producto_stock SET cantidad_actual = cantidad_actual - @FALTANTE;
end 


--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

create view utilidades
as	
	SELECT dv.id_producto as Producto, v.id_cliente as cliente, c.id_sucursal as sucursal, dv.subtotal as SubVenta, dc.subtotal as SubCompra, (dv.subtotal-dc.subtotal) as utilidad 
	from detalle_compra_producto dc, detalle_venta dv, venta v, caja c
	where dc.id_producto = dv.id_producto  and dv.id_venta = v.id_venta and v.id_caja = c.id_caja
go

select * from utilidades

--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

select * from pedido
select * from  compra
select * from ingreso
select SUM(detalle_compra_producto.subtotal) from detalle_compra_producto
select SUM(compra.subtotal) from compra

create view tardanzas as 
select c.id_compra,c.id_proveedor, DATEDIFF(DAY,ped.fecha,i.fecha) as tardanza from pedido as ped, compra as c, ingreso as i 
where c.id_pedido_compra = ped.id_pedido_compra and i.id_compra=c.id_compra
group by c.id_compra,ped.fecha,i.fecha,c.id_proveedor

create view	hechos as
select p.id_producto,dt.subtotal,pr.id_proveedor,t.tardanza,c.fecha  
from compra as c,tardanzas t,detalle_compra_producto dt,proveedor pr, producto p
where t.id_compra=c.id_compra and dt.id_compra= c.id_compra 
and dt.id_producto=p.id_producto and c.id_proveedor=pr.id_proveedor


create view COMPRASDETAILS AS
select  dc.id_producto,ped.fecha  as pedidofecha,c.fecha as comprafecha,c.id_compra,c.id_proveedor,c.subtotal,i.fecha as ingresfecha, DATEDIFF(DAY,ped.fecha,i.fecha) as tardanza from pedido as ped, compra as c, ingreso as i 
,detalle_compra_producto as dc
where c.id_pedido_compra = ped.id_pedido_compra and i.id_compra=c.id_compra
and dc.id_compra=c.id_compra
order by c.id_compra 


SELECT * FROM COMPRASDETAILS
SELECT SUM(TARDANZA) FROM COMPRASDETAILS

select SUM(compra.subtotal) FROM compra
select SUM(detalle_compra_producto.subtotal) from detalle_compra_producto



SELECT SUM(subtotal) from detalle_compra_producto

SELECT * from detalle_venta
SELECT SUM(subtotal) from detalle_venta

select SUM(subVenta) from utilidades

	SELECT  *, (dv.subtotal-dc.subtotal) as utilidad 
	from detalle_compra_producto dc, detalle_venta dv
	where dc.id_producto = dv.id_producto 
	
	
	
 