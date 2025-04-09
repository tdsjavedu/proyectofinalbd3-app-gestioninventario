SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `mydb` DEFAULT CHARACTER SET utf8 ;
USE `mydb` ;

-- -----------------------------------------------------
-- Table `mydb`.`Almacenes`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`Almacenes` (
  `idAlmacenes` INT NOT NULL,
  `Direccion` VARCHAR(45) NULL,
  PRIMARY KEY (`idAlmacenes`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`Usuarios`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`Usuarios` (
  `idUsuarios` INT NOT NULL,
  `Nombre` VARCHAR(45) NULL,
  `Numero` INT NULL,
  `Correo` VARCHAR(45) NULL,
  `Puesto` VARCHAR(45) NULL,
  `Almacenes_idAlmacenes` INT NOT NULL,
  PRIMARY KEY (`idUsuarios`, `Almacenes_idAlmacenes`),
  INDEX `fk_Usuarios_Almacenes1_idx` (`Almacenes_idAlmacenes` ASC),
  CONSTRAINT `fk_Usuarios_Almacenes1`
    FOREIGN KEY (`Almacenes_idAlmacenes`)
    REFERENCES `mydb`.`Almacenes` (`idAlmacenes`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`Transacciones`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`Transacciones` (
  `idTransaccion` INT NOT NULL,
  `Fecha` DATETIME NULL,
  `Usuarios_idUsuarios` INT NOT NULL,
  `Usuarios_Almacenes_idAlmacenes` INT NOT NULL,
  `Historial transacciones` VARCHAR(45) NULL,
  PRIMARY KEY (`idTransaccion`, `Usuarios_idUsuarios`, `Usuarios_Almacenes_idAlmacenes`),
  INDEX `fk_Transacciones_Usuarios1_idx` (`Usuarios_idUsuarios` ASC, `Usuarios_Almacenes_idAlmacenes` ASC),
  CONSTRAINT `fk_Transacciones_Usuarios1`
    FOREIGN KEY (`Usuarios_idUsuarios` , `Usuarios_Almacenes_idAlmacenes`)
    REFERENCES `mydb`.`Usuarios` (`idUsuarios` , `Almacenes_idAlmacenes`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`Producto`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`Producto` (
  `idProducto` INT NOT NULL,
  `Nombre Producto` VARCHAR(45) NULL,
  `Description` VARCHAR(45) NULL,
  `Precio Unitario` VARCHAR(45) NULL,
  `Stock Disponible` VARCHAR(45) NULL,
  `Transacciones_idTransaccion` INT NOT NULL,
  `Transacciones_Usuarios_idUsuarios` INT NOT NULL,
  `Transacciones_Usuarios_Almacenes_idAlmacenes` INT NOT NULL,
  PRIMARY KEY (`idProducto`, `Transacciones_idTransaccion`, `Transacciones_Usuarios_idUsuarios`, `Transacciones_Usuarios_Almacenes_idAlmacenes`),
  INDEX `fk_Producto_Transacciones1_idx` (`Transacciones_idTransaccion` ASC, `Transacciones_Usuarios_idUsuarios` ASC, `Transacciones_Usuarios_Almacenes_idAlmacenes` ASC),
  CONSTRAINT `fk_Producto_Transacciones1`
    FOREIGN KEY (`Transacciones_idTransaccion` , `Transacciones_Usuarios_idUsuarios` , `Transacciones_Usuarios_Almacenes_idAlmacenes`)
    REFERENCES `mydb`.`Transacciones` (`idTransaccion` , `Usuarios_idUsuarios` , `Usuarios_Almacenes_idAlmacenes`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`Producto_has_Almacenes`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`Producto_has_Almacenes` (
  `Producto_idProducto` INT NOT NULL,
  `Almacenes_idAlmacenes` INT NOT NULL,
  PRIMARY KEY (`Producto_idProducto`, `Almacenes_idAlmacenes`),
  INDEX `fk_Producto_has_Almacenes_Almacenes1_idx` (`Almacenes_idAlmacenes` ASC),
  INDEX `fk_Producto_has_Almacenes_Producto_idx` (`Producto_idProducto` ASC),
  CONSTRAINT `fk_Producto_has_Almacenes_Producto`
    FOREIGN KEY (`Producto_idProducto`)
    REFERENCES `mydb`.`Producto` (`idProducto`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Producto_has_Almacenes_Almacenes1`
    FOREIGN KEY (`Almacenes_idAlmacenes`)
    REFERENCES `mydb`.`Almacenes` (`idAlmacenes`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;



/* Trigger para evitar duplicados en productos */
DELIMITER //
CREATE TRIGGER evitar_duplicidad_productos
BEFORE INSERT ON producto
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM producto WHERE nombre_producto = NEW.nombre_producto) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: El producto ya existe.';
    END IF;
END;
//
DELIMITER ;



/* Trigger para actualizar el stock despues de una venta */
DELIMITER //
CREATE TRIGGER actualizacion_Stock_PostVenta
AFTER INSERT ON transacciones
FOR EACH ROW
BEGIN
    UPDATE producto
    SET stock_disponible = stock_disponible - NEW.cantidad
    WHERE Producto_idProducto = NEW.Producto_idProducto;
END;
//
DELIMITER ;


/* Procemiento para registrar un producto nuevo */
DELIMITER //
CREATE PROCEDURE insertar_producto (
    IN p_nombre VARCHAR(100),
    IN p_descripcion TEXT,
    IN p_precio DECIMAL(10,2),
    IN p_stock INT,
    IN p_ubicacion VARCHAR(50)
)
BEGIN
    INSERT INTO producto (nombre_producto, descripcion, precio_unitario, stock_disponible, Transacciones_Usuarios_Almacenes_idAlmacenes)
    VALUES (p_nombre, p_descripcion, p_precio, p_stock, p_ubicacion);
END;
//

DELIMITER ;

/* Procedimiento para generar un reporte de inventario */
DELIMITER //
CREATE PROCEDURE reporte_inventario()
BEGIN
    SELECT idProducto, nombre_producto, stock_disponible, precio_unitario, 
           (stock_disponible * precio_unitario) AS valor_total
    FROM producto;
END;
//
DELIMITER ;

/*Procedimiento para registrar una venta */
DELIMITER //
CREATE PROCEDURE registrar_venta (
    IN p_id_usuario INT,
    IN p_id_producto INT,
    IN p_cantidad INT
)
BEGIN
    DECLARE v_precio DECIMAL(10,2);

    -- Obtener el precio del producto
    SELECT precio_unitario INTO v_precio FROM producto WHERE idProducto = p_id_producto;

    -- Insertar la transacción
    INSERT INTO transaccion (Usuarios_idUsuario, idProducto, cantidad, Fecha, valor_total)
    VALUES (p_id_usuario, p_id_producto, p_cantidad, NOW(), (p_cantidad * v_precio));

    -- Actualizar el stock
    UPDATE producto 
    SET stock_disponible = stock_disponible - p_cantidad 
    WHERE idProducto = p_id_producto;
END;
//

DELIMITER ;


/* Procedimiento para registrar un producto nuevo */
DELIMITER $$

CREATE PROCEDURE RegistrarProducto(
	IN p_codigo INT,
    IN p_nombre VARCHAR(100),
    IN p_descripcion TEXT,
    IN p_precio DECIMAL(10,2),
    IN p_stock INT
)
BEGIN
    INSERT INTO producto (idProducto, nombre_producto, descripcion, precio_unitario, stock_disponible)
    VALUES (p_codigo, p_nombre, p_descripcion, p_precio, p_stock);
END$$

DELIMITER ;
ALTER TABLE producto MODIFY COLUMN descripcion TEXT;
ALTER TABLE producto CHANGE `Description` descripcion VARCHAR(45);
DESCRIBE producto;
CALL RegistrarProducto(1,'Laptop HP', 'Laptop 16GB RAM', 850.50, 20);
DROP Procedure if exists RegistrarProducto;
/* Procedimiento para actualizar un producto */
DELIMITER $$
CREATE PROCEDURE ActualizarProducto(
    IN p_id_Producto INT,
    IN p_nombreproducto VARCHAR(100),
    IN p_Descripcion_producto TEXT,
    IN p_precio_unitario DECIMAL(10,2),
    IN p_stock_disponible INT,
    IN p_idAlmacenes INT
)
BEGIN
    UPDATE producto
    SET nombre_producto = p_nombre, 
        descripcion = p_descripcion, 
        precio_unitario = p_precio, 
        stock_disponible = p_stock, 
        Transacciones_Usuarios_Almacenes_idAlmacenes = p_id_almacen
    WHERE idProducto = p_id_Producto;
END$$
DELIMITER $$

/*Procedimiento para eliminar un producto */
DELIMITER $$
CREATE PROCEDURE EliminarProducto(
    IN p_codigo INT
)
BEGIN
    DELETE FROM producto WHERE idProducto = p_codigo;
END$$
DELIMITER ;



/*Partición horizontal*/
-- Llenando tablas



INSERT INTO mydb.Transacciones (idTransaccion, Fecha, Producto_idProducto, Usuarios_idUsuarios, Almacenes_idAlmacenes) VALUES
(1, '2021-05-10', 1, 1),
(2, '2021-07-22', 2, 2),
(3, '2021-11-15', 3, 3),
(4, '2022-01-18', 1, 1),
(5, '2022-03-09', 2, 2),
(6, '2022-06-25', 3, 3),
(7, '2023-02-10', 1, 1),
(8, '2023-04-16', 2, 2),
(9, '2023-08-05', 3, 3),
(10, '2024-01-30', 1, 1);

INSERT INTO mydb.producto 
(idProducto, nombre_producto, descripcion, precio_unitario, stock_disponible) 
VALUES
(3, 'Mouse Logitech', 'Mouse inalámbrico', 25.50, 100),
(4, 'Teclado Mecánico', 'Teclado RGB', 80.00, 80),
(5, 'Monitor Dell', 'Monitor 24 pulgadas', 200.00, 50),
(6, 'Audífonos Sony', 'Audífonos Noise Cancelling', 120.00, 40),
(7, 'Cámara Canon', 'Cámara DSLR', 900.00, 15),
(8, 'Tablet Samsung', 'Tablet 10 pulgadas', 350.00, 20),
(9, 'Impresora HP', 'Impresora láser', 150.00, 35),
(10, 'SSD Kingston', 'SSD 1TB', 100.00, 60);

TRUNCATE TABLE Producto_has_Almacenes;
INSERT INTO mydb.Producto_has_Almacenes (Producto_idProducto, Almacenes_idAlmacenes, stock_almacen) VALUES
(1, 1, 10),
(2, 1, 15),
(3, 2, 25),
(4, 3, 15),
(5, 1, 19),
(6, 2, 26),
(7, 3, 3),
(8, 1, 5),
(9, 2, 16),
(10, 3, 20);

INSERT INTO Inventario_Particionado2 (Producto_idProducto, idProducto, idAlmacenes, Stock) VALUES 
(1,1,1,13);

-- Partición Horizontal por año

CREATE TABLE Inventario_Particionado2 (
    Producto_idProducto INT NOT NULL,
    idProducto INT NOT NULL,
    idAlmacenes INT NOT NULL,
    Stock INT,
    PRIMARY KEY (Producto_idProducto, idAlmacenes)
)
PARTITION BY LIST (idAlmacenes) (
    PARTITION almacén_1 VALUES IN (1),
    PARTITION almacén_2 VALUES IN (2),
    PARTITION almacén_3 VALUES IN (3),
    PARTITION almacen_4 VALUES IN (4)
    );

SELECT 
	TABLE_NAME,
    PARTITION_NAME,
    TABLE_ROWS
FROM
	information_schema.PARTITIONS
WHERE
	TABLE_NAME = 'Inventario_Particionado2';

ANALYZE TABLE Inventario_Particionado2;

SELECT * from producto_has_almacenes;
SELECT * FROM transacciones;
SELECT * FROM Almacenes;
SELECT * FROM producto;
SELECT * FROM Usuarios;
SELECT * FROM Inventario_Particionado2;
ALTER TABLE producto_has_almacenes ADD COLUMN stock_almacen INT;
SHOW Tables;


-- Crear la tabla para las transacciones de 2021
CREATE TABLE mydb.Transacciones_2021 (
    idTransaccion INT PRIMARY KEY,
    Fecha DATE,
    Usuarios_idUsuarios INT,
    Usuarios_Almacenes_idAlmacenes INT,
    FOREIGN KEY (Usuarios_idUsuarios) REFERENCES mydb.Usuarios(idUsuarios),
    FOREIGN KEY (Usuarios_Almacenes_idAlmacenes) REFERENCES mydb.Almacenes(idAlmacenes)
);

-- Crear la tabla para las transacciones de 2022
CREATE TABLE mydb.Transacciones_2022 (
    idTransaccion INT PRIMARY KEY,
    Fecha DATE,
    Usuarios_idUsuarios INT,
    Usuarios_Almacenes_idAlmacenes INT,
    FOREIGN KEY (Usuarios_idUsuarios) REFERENCES mydb.Usuarios(idUsuarios),
    FOREIGN KEY (Usuarios_Almacenes_idAlmacenes) REFERENCES mydb.Almacenes(idAlmacenes)
);

-- Crear la tabla para las transacciones de 2023
CREATE TABLE mydb.Transacciones_2023 (
    idTransaccion INT PRIMARY KEY,
    Fecha DATE,
    Usuarios_idUsuarios INT,
    Usuarios_Almacenes_idAlmacenes INT,
    FOREIGN KEY (Usuarios_idUsuarios) REFERENCES mydb.Usuarios(idUsuarios),
    FOREIGN KEY (Usuarios_Almacenes_idAlmacenes) REFERENCES mydb.Almacenes(idAlmacenes)
);
INSERT INTO mydb.usuarios (idUsuarios, Nombre, Numero, Correo, Puesto, Almacenes_idAlmacenes) Values
(1, 'Jaime Valeriano', 4567899, 'gerente@negocio.com', 'Gerente General', 1),
(2, 'Jorge Solis', 8989898, 'programador@negocio.com', 'Programador', 2),
(3, 'Isaac Luismi', 677789, 'disenador@negocio.com', 'Disenador', 3);

-- Insertar datos en Transacciones_2021
INSERT INTO mydb.Transacciones_2021 (idTransaccion, Fecha, Usuarios_idUsuarios, Usuarios_Almacenes_idAlmacenes)
VALUES
(1, '2021-05-10', 1, 1),
(2, '2021-07-22', 2, 2),
(3, '2021-11-15', 3, 3);

-- Insertar datos en Transacciones_2022
INSERT INTO mydb.Transacciones_2022 (idTransaccion, Fecha, Usuarios_idUsuarios, Usuarios_Almacenes_idAlmacenes)
VALUES
(4, '2022-01-18', 1, 1),
(5, '2022-03-09', 2, 2),
(6, '2022-06-25', 3, 3);

-- Insertar datos en Transacciones_2023
INSERT INTO mydb.Transacciones_2023 (idTransaccion, Fecha, Usuarios_idUsuarios, Usuarios_Almacenes_idAlmacenes)
VALUES
(7, '2023-02-10', 1, 1),
(8, '2023-04-16', 2, 2),
(9, '2023-08-05', 3, 3),
(10, '2024-01-30', 1, 1);

CREATE VIEW mydb.Vista_Transacciones AS
SELECT * FROM mydb.Transacciones_2021
UNION ALL
SELECT * FROM mydb.Transacciones_2022
UNION ALL
SELECT * FROM mydb.Transacciones_2023;

SELECT * FROM mydb.Vista_Transacciones;


/*Partición vertical*/
-- Crear tabla para los detalles básicos del producto
CREATE TABLE mydb.Producto_Detalles (
    idProducto INT PRIMARY KEY,
    Nombre_Producto VARCHAR(45),
    Description VARCHAR(45)
);

-- Crear tabla para la información de inventario
CREATE TABLE mydb.Producto_Inventario (
    idProducto INT PRIMARY KEY,
    Precio_Unitario VARCHAR(45),
    Stock_Disponible VARCHAR(45),
    Transacciones_idTransaccion INT,
    Transacciones_Usuarios_idUsuarios INT,
    Transacciones_Usuarios_Almacenes_idAlmacenes INT,
    FOREIGN KEY (idProducto) REFERENCES mydb.Producto_Detalles(idProducto),
    FOREIGN KEY (Transacciones_idTransaccion) REFERENCES mydb.Transacciones(idTransaccion),
    FOREIGN KEY (Transacciones_Usuarios_idUsuarios) REFERENCES mydb.Usuarios(idUsuarios),
    FOREIGN KEY (Transacciones_Usuarios_Almacenes_idAlmacenes) REFERENCES mydb.Almacenes(idAlmacenes)
);

-- Insertar datos en Producto_Detalles (detalles básicos del producto)
INSERT INTO mydb.Producto_Detalles (idProducto, Nombre_Producto, Description)
VALUES
(1, 'Laptop HP', 'Laptop 16GB RAM'),
(2, 'Smartphone Samsung', 'Smartphone 128GB'),
(3, 'Mouse Logitech', 'Mouse inalámbrico'),
(4, 'Teclado Mecánico', 'Teclado RGB'),
(5, 'Monitor Dell', 'Monitor 24 pulgadas'),
(6, 'Audífonos Sony', 'Audífonos Noise Cancelling'),
(7, 'Cámara Canon', 'Cámara DSLR'),
(8, 'Tablet Samsung', 'Tablet 10 pulgadas'),
(9, 'Impresora HP', 'Impresora láser'),
(10, 'SSD Kingston', 'SSD 1TB');

-- Insertar datos en Producto_Inventario (información de inventario)
INSERT INTO mydb.Producto_Inventario (idProducto, Precio_Unitario, Stock_Disponible, Transacciones_idTransaccion, Transacciones_Usuarios_idUsuarios, Transacciones_Usuarios_Almacenes_idAlmacenes)
VALUES
(1, '850.50', '50', 1, 1, 1),
(2, '450.00', '30', 1, 1, 1),
(3, '25.50', '100', 2, 2, 2),
(4, '80.00', '80', 3, 3, 3),
(5, '200.00', '25', 4, 1, 1),
(6, '120.00', '40', 5, 2, 2),
(7, '900.00', '15', 6, 3, 3),
(8, '350.00', '20', 7, 1, 1),
(9, '150.00', '35', 8, 2, 2),
(10, '100.00', '60', 9, 3, 3);

CREATE VIEW mydb.Vista_Producto AS
SELECT 
    p.idProducto, 
    p.Nombre_Producto, 
    p.Description, 
    i.Precio_Unitario, 
    i.Stock_Disponible, 
    i.Transacciones_idTransaccion, 
    i.Transacciones_Usuarios_idUsuarios, 
    i.Transacciones_Usuarios_Almacenes_idAlmacenes
FROM 
    mydb.Producto_Detalles p
JOIN 
    mydb.Producto_Inventario i ON p.idProducto = i.idProducto;

SELECT * FROM mydb.Vista_Producto;



/*Filtros Avanzados*/
-- Reporte de productos vendidos en el 2023, por precio, solo aquellos con más de 50 unidades vendidas, agrupadas por el nombre de productos y ordenado de manera descendente por unidades vendidas 
SELECT 
    p.nombre_producto, 
    SUM(p.stock_disponible) AS Unidades_Vendidas, 
    SUM(CAST(p.precio_unitario AS DECIMAL(10,2))) AS Total_Ventas
FROM 
    mydb.producto p
JOIN 
    mydb.transacciones t ON t.idTransaccion = t.idTransaccion
WHERE 
    t.Fecha BETWEEN '2023-01-01' AND '2023-12-31'  -- Filtrar solo ventas de 2023
    AND CAST(p.precio_unitario AS DECIMAL(10,2)) > 100  -- Filtrar productos con precio mayor a 100
GROUP BY 
    p.nombre_producto
HAVING 
    SUM(p.stock_disponible) > 50  -- Filtrar productos con más de 50 unidades vendidas
ORDER BY 
    Unidades_Vendidas DESC
LIMIT 0, 1000;


SELECT * from producto_has_almacenes;
SELECT * FROM transacciones;
SELECT * FROM Almacenes;
SELECT * FROM producto;
SELECT * FROM Usuarios;
SELECT * FROM Inventario_Particionado2;
-- Filtro por rango de precio entre 100 y 500
SELECT 
    nombre_producto, 
    precio_unitario
FROM 
    mydb.producto
WHERE 
    CAST(precio_unitario AS DECIMAL(10,2)) BETWEEN 100 AND 500
LIMIT 0, 1000;

/*Reportes Agrupados*/
-- Reporte que agrupa productos vendidos por usuarios
CREATE VIEW Reporte_Ventas_Usuario AS
SELECT 
    u.Nombre AS Usuario,
    p.nombre_producto,  
    SUM(p.stock_disponible) AS Unidades_Vendidas,  
    SUM(CAST(p.precio_unitario AS DECIMAL(10,2))) AS Total_Ventas
FROM 
    mydb.producto p
JOIN 
    mydb.Transacciones t ON t.idTransaccion = t.idTransaccion
JOIN 
    mydb.Usuarios u ON t.Usuarios_idUsuarios = u.idUsuarios
GROUP BY 
    u.Nombre, p.nombre_producto;

SELECT * 
FROM Reporte_Ventas_Usuario 
WHERE Usuario = 'Jaime Valeriano' AND Unidades_Vendidas > 1;

ALTER TABLE transacciones Drop Column `Historial transacciones`;

INSERT INTO transacciones (Fecha, Producto_idProducto, Usuarios_idUsuarios, Usuarios_Almacenes_idAlmacenes, cantidad)
VALUES (now(),1,1,1,3);


SHOW TRIGGERS WHERE `table` = 'transacciones';
SHOW CREATE TRIGGER actualizacion_Stock_PostVenta;

ALTER TABLE transacciones DROP Foreign KEY `Producto_idProducto`;
DROP TRIGGER IF EXISTS actualizacion_Stock_PostVenta;

DELIMITER $$

CREATE TRIGGER actualizacion_Stock_PostVenta
AFTER INSERT ON transacciones
FOR EACH ROW
BEGIN
    UPDATE producto
    SET stock_disponible = stock_disponible - NEW.cantidad
    WHERE idProducto = NEW.Producto_idProducto;
END$$

DELIMITER ;


-- Crear un usuario con privilegios de administrador
CREATE USER 'admin-basededatos'@'localhost' IDENTIFIED BY 'd@tabas3@dm1n**';
GRANT ALL PRIVILEGES ON * . * TO 'admin-basededatos'@'localhost';

FLUSH PRIVILEGES;

CREATE USER 'analista-bd1'@'localhost' IDENTIFIED BY '@nal1$t@un0';
GRANT SELECT ON mydb . producto to 'analist-bd1'@'localhost';

Flush Privileges;

