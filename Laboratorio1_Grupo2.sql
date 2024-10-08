CREATE DATABASE Gestion_Operaciones_Bancarias
USE Gestion_Operaciones_Bancarias

----------------------------- TABLA CLIENTES--------------------------------------------------
CREATE TABLE Cliente(
ClienteID INT PRIMARY KEY IDENTITY(1,1),
Nombre varchar (100) Not null,
Direccion varchar (255) Not null,
Correo varchar (255) UNIQUE Not null,
Telefono varchar (20),
NumeroIdentificacion BIGINT UNIQUE Not null);

INSERT INTO Cliente (Nombre, Direccion, Correo, Telefono, NumeroIdentificacion)
VALUES
('Juan P�rez', 'Av. Siempre Viva 123, Ciudad', 'juan.perez@example.com', '555-1234', 123456789),
('Ana G�mez', 'Calle Falsa 456, Ciudad', 'ana.gomez@example.com', '555-5678', 987654321),
('Carlos L�pez', 'Avenida Libertad 789, Ciudad', 'carlos.lopez@example.com', '555-8765', 456789123),
('Maria Fern�ndez', 'Calle Real 321, Ciudad', 'maria.fernandez@example.com', '555-4321', 321654987),
('Luis Mart�nez', 'Plaza Central 654, Ciudad', 'luis.martinez@example.com', '555-6789', 987321456);


----------------------------- TABLA SUCURSALES--------------------------------------------------
CREATE TABLE Sucursales(
SucursalID	INT PRIMARY KEY IDENTITY(1,1),
NombreSucursal varchar (100) not null,
Direccion varchar (255) not null,
GerenteResponsable varchar (100) not null
);

INSERT INTO Sucursales (NombreSucursal, Direccion, GerenteResponsable)
VALUES
('Sucursal Norte', 'Av. Norte 100, Ciudad', 'Pedro Alvarez'),
('Sucursal Sur', 'Calle Sur 200, Ciudad', 'Laura Torres'),
('Sucursal Este', 'Av. Este 300, Ciudad', 'Andr�s Mart�nez'),
('Sucursal Oeste', 'Calle Oeste 400, Ciudad', 'Luc�a Ram�rez'),
('Sucursal Centro', 'Plaza Central 500, Ciudad', 'Miguel G�mez');


----------------------------- TABLA CUENTAS BANCARIAS--------------------------------------------------

CREATE TABLE Cuentas_Bancarias(
CuentaID INT PRIMARY KEY IDENTITY(1,1),
Numero_Cuenta BIGINT UNIQUE Not null,
Tipo_Cuenta  varchar (100) Check(Tipo_Cuenta IN ('Ahorros','Corriente')) Not null,
Saldo Decimal (15,2) Default 0.00,
Fecha_Apertura Date Not null,
ClienteID int,
SucursalID int
CONSTRAINT FK_ClienteID FOREIGN KEY (ClienteID) REFERENCES Cliente(ClienteID),
CONSTRAINT FK_SucursalID1 FOREIGN KEY (SucursalID) REFERENCES Sucursales(SucursalID)
);

INSERT INTO Cuentas_Bancarias (Numero_Cuenta, Tipo_Cuenta, Saldo, Fecha_Apertura, ClienteID, SucursalID)
VALUES
(000110001234, 'Ahorros', 1500.00, '2024-01-15', 1, 1),
(000110005678, 'Corriente', 2000.00, '2024-02-20', 2, 2),
(000110009101, 'Ahorros', 3000.00, '2024-03-10', 3, 3),
(000110001121, 'Corriente', 4000.00, '2024-04-05', 4, 4),
(000110003141, 'Ahorros', 5000.00, '2024-05-25', 5, 5);


----------------------------- TABLA EMPLEADOS--------------------------------------------------
CREATE TABLE Empleados(
EmpleadoID INT PRIMARY KEY IDENTITY(1,1),
Nombre varchar (100) not null,
Cargo varchar (100) not null,
FechaContratacion date not null,
Salario	Decimal (15,2) not null,
Contacto varchar (100),
SucursalID INT
CONSTRAINT FK_SucursalID FOREIGN KEY (SucursalID) REFERENCES Sucursales(SucursalID)
);

INSERT INTO Empleados (Nombre, Cargo, FechaContratacion, Salario, Contacto, SucursalID)
VALUES
('Pedro Alvarez', 'Gerente', '2020-01-15', 55000.00, '555-1111', 1),
('Laura Torres', 'Asistente', '2021-06-01', 40000.00, '555-2222', 2),
('Andr�s Mart�nez', 'Cajero', '2019-08-23', 35000.00, '555-3333', 3),
('Luc�a Ram�rez', 'Oficial de Cr�dito', '2022-03-15', 42000.00, '555-4444', 4),
('Miguel G�mez', 'Gerente', '2018-12-30', 60000.00, '555-5555', 5);


----------------------------- TABLA TRANSACCION--------------------------------------------------
CREATE TABLE Transacciones(
TransaccionID INT PRIMARY KEY IDENTITY(1,1),
Tipo_Transaccion varchar(100) CHECK(Tipo_Transaccion IN('Deposito','Retiro','Transferencia')) not null,
FechaTransaccion date not null,
Monto decimal (15,2) not null,
CuentaOrigenID	int,
CuentaDestinoID int,
SucursalID int
CONSTRAINT FK_CuentaOrigenID FOREIGN KEY (CuentaOrigenID) REFERENCES Cuentas_Bancarias(CuentaID),
CONSTRAINT FK_CuentaDestinoID FOREIGN KEY (CuentaDestinoID) REFERENCES Cuentas_Bancarias(CuentaID),
CONSTRAINT FK_SucursalID3 FOREIGN KEY (SucursalID) REFERENCES Sucursales(SucursalID)
)


INSERT INTO Transacciones (Tipo_Transaccion, FechaTransaccion, Monto, CuentaOrigenID, CuentaDestinoID, SucursalID)
VALUES
('Deposito', '2024-06-10', 500.00, 3, 5, 1),
('Retiro', '2024-06-11', 200.00, 2, 4, 2),
('Transferencia', '2024-06-12', 1500.00, 3, 4, 3),
('Deposito', '2024-06-13', 700.00, 1, 5, 5),
('Transferencia', '2024-08-28', 1000.00,3, 2, 1);




---------------------------------PROCEDIENTO DEPOSITO----------------------------------------------
CREATE PROCEDURE sp_Realizar_Deposito
    @CuentaDestinoID BIGINT,
    @Monto DECIMAL(15, 2),
    @SucursalID INT = NULL
AS
BEGIN
    BEGIN TRANSACTION;

    BEGIN TRY
        -- Verificar que el monto sea positivo
        IF @Monto <= 0
        BEGIN
            THROW 50003, 'El monto debe ser mayor que cero.', 1;
        END

        -- Dep�sito en la cuenta destino
        UPDATE Cuentas_Bancarias
        SET Saldo = Saldo + @Monto
        WHERE CuentaID = @CuentaDestinoID;

        -- Verificar que el dep�sito fue exitoso
        IF @@ROWCOUNT = 0
        BEGIN
            THROW 50005, 'Cuenta destino no encontrada.', 1;
        END

        -- Registrar la transacci�n
        INSERT INTO Transacciones (Tipo_Transaccion, FechaTransaccion, Monto, CuentaDestinoID, SucursalID)
        VALUES ('Deposito', GETDATE(), @Monto, @CuentaDestinoID, @SucursalID);

        -- Confirmar transacci�n
        COMMIT;
    END TRY
    BEGIN CATCH
        -- Revertir cambios en caso de error
        ROLLBACK;

        -- Opcional: manejar el error o lanzar una excepci�n
        -- Puedes capturar m�s detalles sobre el error aqu� si lo necesitas
        THROW;
    END CATCH;
END;

EXEC sp_Realizar_Deposito
    @CuentaDestinoID = 2,
    @Monto = 500.00,
    @SucursalID = 1;






---------------------------------PROCEDIENTO RETIRO----------------------------------------------
CREATE PROCEDURE sp_Realizar_Retiro
    @CuentaOrigenID BIGINT,
    @Monto DECIMAL(15, 2),
    @SucursalID INT = NULL
AS
BEGIN
    BEGIN TRANSACTION;

    BEGIN TRY
        -- Verificar que el monto sea positivo
        IF @Monto <= 0
        BEGIN
            THROW 50003, 'El monto debe ser mayor que cero.', 1;
        END

        -- Retiro de la cuenta origen
        UPDATE Cuentas_Bancarias
        SET Saldo = Saldo - @Monto
        WHERE CuentaID = @CuentaOrigenID;

        -- Verificar que el retiro fue exitoso
        IF @@ROWCOUNT = 0
        BEGIN
            THROW 50004, 'Cuenta origen no encontrada o saldo insuficiente.', 1;
        END

        -- Registrar la transacci�n
        INSERT INTO Transacciones (Tipo_Transaccion, FechaTransaccion, Monto, CuentaOrigenID, SucursalID)
        VALUES ('Retiro', GETDATE(), @Monto, @CuentaOrigenID, @SucursalID);

        -- Confirmar transacci�n
        COMMIT;
    END TRY
    BEGIN CATCH
        -- Revertir cambios en caso de error
        ROLLBACK;

        -- Opcional: manejar el error o lanzar una excepci�n
        -- Puedes capturar m�s detalles sobre el error aqu� si lo necesitas
        THROW;
    END CATCH;
END;

EXEC sp_Realizar_Retiro
    @CuentaOrigenID = 5,
    @Monto = 500.00,
    @SucursalID = 1;

---------------------------------PROCEDIENTO TRANSACCION----------------------------------------------
CREATE PROCEDURE Realizar_Transferencia
	@CuentaDestinoID BIGINT,
    @CuentaOrigenID BIGINT,
    @Monto DECIMAL(15, 2),
    @SucursalID INT = NULL
AS
BEGIN
    BEGIN TRANSACTION;

    BEGIN TRY
        -- Verificar que el monto sea positivo
        IF @Monto <= 0
        BEGIN
            THROW 50003, 'El monto debe ser mayor que cero.', 1;
        END

        -- Retiro de la cuenta origen
        UPDATE Cuentas_Bancarias
        SET Saldo = Saldo - @Monto
        WHERE CuentaID = @CuentaOrigenID;

        -- Verificar que el retiro fue exitoso
        IF @@ROWCOUNT = 0
        BEGIN
            THROW 50004, 'Cuenta origen no encontrada o saldo insuficiente.', 1;
        END

        -- Dep�sito en la cuenta destino
        UPDATE Cuentas_Bancarias
        SET Saldo = Saldo + @Monto
        WHERE CuentaID = @CuentaDestinoID;

        -- Verificar que el dep�sito fue exitoso
        IF @@ROWCOUNT = 0
        BEGIN
            THROW 50005, 'Cuenta destino no encontrada.', 1;
        END

        -- Registrar la transacci�n
        INSERT INTO Transacciones (Tipo_Transaccion, FechaTransaccion, Monto, CuentaOrigenID, CuentaDestinoID, SucursalID)
        VALUES ('Transferencia', GETDATE(), @Monto, @CuentaOrigenID, @CuentaDestinoID, @SucursalID);

        -- Confirmar transacci�n
        COMMIT;
    END TRY
    BEGIN CATCH
        -- Revertir cambios en caso de error
        ROLLBACK;

        -- Opcional: manejar el error o lanzar una excepci�n
        -- Puedes capturar m�s detalles sobre el error aqu� si lo necesitas
        THROW;
    END CATCH;
END;


EXEC Realizar_Transferencia
    @CuentaOrigenID = 3,
    @CuentaDestinoID = 2,
    @Monto = 500.00,
    @SucursalID = 1;


--------------------------------------------------------------------------------------------------------------------------------------------
select * from Cuentas_Bancarias
select * from Cliente
select * from Sucursales
select * from Empleados
select * from Transacciones
drop table Transacciones
drop table Cuentas_Bancarias
drop table Empleados
drop table Sucursales
drop table Cliente


------------------------------------------CONSULTAS---------------------------------------------------------------------------------
--1. Combinaci�n de Tablas: Escribe una consulta que combine las tablas Clientes y
--Cuentas Bancarias para listar todos los clientes con sus respectivas cuentas bancarias.

SELECT c.ClienteID, c.Nombre, c.Direccion, c.Correo, c.Telefono, c.NumeroIdentificacion,o.CuentaID, o.Numero_Cuenta, o.Tipo_Cuenta, 
		o.Saldo, o.Fecha_Apertura,s.NombreSucursal
FROM Cliente AS c INNER JOIN Cuentas_Bancarias AS o ON c.ClienteID = o.ClienteID
INNER JOIN Sucursales AS s ON o.SucursalID = s.SucursalID

--2. Uso de DISTINCT: Crea una consulta que utilice DISTINCT para obtener todos los tipos
---�nicos de cuentas bancarias que existen en el banco.

SELECT DISTINCT Tipo_Cuenta FROM Cuentas_Bancarias;

---3. Uso de LIKE: Escribe una consulta para buscar clientes cuyo nombre comience con una
---letra espec�fica utilizando la cl�usula LIKE.

SELECT * FROM Cliente WHERE Nombre Like 'a%'

----4. Uso de IN: Escribe una consulta que utilice IN para listar todas las transacciones
---realizadas en ciertas sucursales espec�ficas.

SELECT * FROM Transacciones WHERE SucursalID IN (1, 3, 5);

---5. Uso de BETWEEN: Crea una consulta para encontrar todas las transacciones realizadas
---dentro de un rango de fechas utilizando BETWEEN.

SELECT * FROM Transacciones Where FechaTransaccion BETWEEN '10/08/1995' and '20/11/2024'

---6.Uso de Subconsultas: Escribe una subconsulta para listar los clientes que tienen un
---saldo mayor que el saldo promedio de todas las cuentas.

WITH SaldoPromedio AS (
    SELECT AVG(Saldo) AS Saldo_Promedio
    FROM Cuentas_Bancarias
)

SELECT DISTINCT * FROM Cliente c
JOIN Cuentas_Bancarias cb ON c.ClienteID = cb.CLienteID
WHERE cb.Saldo > (SELECT Saldo_Promedio FROM SaldoPromedio)


---7. Uso de GROUP BY: Crea una consulta que agrupe las transacciones por tipo y calcule el
---n�mero total de transacciones para cada tipo utilizando GROUP BY.

SELECT 
    Tipo_Transaccion, 
    COUNT(*) AS Numero_Transacciones
FROM 
    Transacciones
GROUP BY 
    Tipo_Transaccion;

---8. Uso de HAVING: Escribe una consulta similar a la anterior, pero agrega una condici�n
---HAVING para mostrar solo los tipos de transacci�n con m�s de un cierto n�mero de transacciones.

SELECT Tipo_Transaccion, COUNT(*) AS Numero_Transacciones FROM Transacciones
GROUP BY Tipo_Transaccion
HAVING COUNT(*) > 1

---9.Uso de COUNT: Crea una consulta que utilice COUNT para determinar cu�ntas cuentas
---bancarias est�n activas en el banco.

select count(*) AS Total_Cuentas_Bancarias from Cuentas_Bancarias 

---10.Uso de SUM: Escribe una consulta que utilice SUM para calcular el total de dinero
---depositado en un tipo espec�fico de cuenta bancaria.

SELECT SUM(Saldo) AS Total_Dinero_Depositado 
FROM Cuentas_Bancarias
WHERE Tipo_Cuenta = ('Corriente')

----11. Uso de MAX y MIN: Crea una consulta que utilice MAX y MIN para encontrar el mayor
---y menor saldo de cuenta entre todos los clientes.
SELECT 
    MIN(o.Saldo) AS SaldoMinimo,
    MAX(o.Saldo) AS SaldoMaximo
FROM 
    Cuentas_Bancarias AS o;

-- Obtener la lista de clientes y saldos de sus cuentas
SELECT 
    c.ClienteID, 
    c.Nombre, 
    o.Saldo
FROM 
    Cliente AS c
INNER JOIN 
    Cuentas_Bancarias AS o ON c.ClienteID = o.ClienteID;

