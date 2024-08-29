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
('Juan Pérez', 'Av. Siempre Viva 123, Ciudad', 'juan.perez@example.com', '555-1234', 123456789),
('Ana Gómez', 'Calle Falsa 456, Ciudad', 'ana.gomez@example.com', '555-5678', 987654321),
('Carlos López', 'Avenida Libertad 789, Ciudad', 'carlos.lopez@example.com', '555-8765', 456789123),
('Maria Fernández', 'Calle Real 321, Ciudad', 'maria.fernandez@example.com', '555-4321', 321654987),
('Luis Martínez', 'Plaza Central 654, Ciudad', 'luis.martinez@example.com', '555-6789', 987321456);


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
('Sucursal Este', 'Av. Este 300, Ciudad', 'Andrés Martínez'),
('Sucursal Oeste', 'Calle Oeste 400, Ciudad', 'Lucía Ramírez'),
('Sucursal Centro', 'Plaza Central 500, Ciudad', 'Miguel Gómez');


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
('Andrés Martínez', 'Cajero', '2019-08-23', 35000.00, '555-3333', 3),
('Lucía Ramírez', 'Oficial de Crédito', '2022-03-15', 42000.00, '555-4444', 4),
('Miguel Gómez', 'Gerente', '2018-12-30', 60000.00, '555-5555', 5);


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
('Deposito', '2024-06-10', 500.00, 3, 6, 1),
('Retiro', '2024-06-11', 200.00, 2, 4, 2),
('Transferencia', '2024-06-12', 1500.00, 3, 4, 3),
('Deposito', '2024-06-13', 700.00, 6, 5, 5),
('Transferencia', '2024-08-28', 1000.00, 6, 2, 1);




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

        -- Depósito en la cuenta destino
        UPDATE Cuentas_Bancarias
        SET Saldo = Saldo + @Monto
        WHERE CuentaID = @CuentaDestinoID;

        -- Verificar que el depósito fue exitoso
        IF @@ROWCOUNT = 0
        BEGIN
            THROW 50005, 'Cuenta destino no encontrada.', 1;
        END

        -- Registrar la transacción
        INSERT INTO Transacciones (Tipo_Transaccion, FechaTransaccion, Monto, CuentaDestinoID, SucursalID)
        VALUES ('Deposito', GETDATE(), @Monto, @CuentaDestinoID, @SucursalID);

        -- Confirmar transacción
        COMMIT;
    END TRY
    BEGIN CATCH
        -- Revertir cambios en caso de error
        ROLLBACK;

        -- Opcional: manejar el error o lanzar una excepción
        -- Puedes capturar más detalles sobre el error aquí si lo necesitas
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

        -- Registrar la transacción
        INSERT INTO Transacciones (Tipo_Transaccion, FechaTransaccion, Monto, CuentaOrigenID, SucursalID)
        VALUES ('Retiro', GETDATE(), @Monto, @CuentaOrigenID, @SucursalID);

        -- Confirmar transacción
        COMMIT;
    END TRY
    BEGIN CATCH
        -- Revertir cambios en caso de error
        ROLLBACK;

        -- Opcional: manejar el error o lanzar una excepción
        -- Puedes capturar más detalles sobre el error aquí si lo necesitas
        THROW;
    END CATCH;
END;

EXEC sp_Realizar_Retiro
    @CuentaOrigenID = 6,
    @Monto = 500.00,
    @SucursalID = 1;

---------------------------------PROCEDIENTO TRANSACCION----------------------------------------------
CREATE PROCEDURE Realizar_Transferencia
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

        -- Depósito en la cuenta destino
        UPDATE Cuentas_Bancarias
        SET Saldo = Saldo + @Monto
        WHERE CuentaID = @CuentaDestinoID;

        -- Verificar que el depósito fue exitoso
        IF @@ROWCOUNT = 0
        BEGIN
            THROW 50005, 'Cuenta destino no encontrada.', 1;
        END

        -- Registrar la transacción
        INSERT INTO Transacciones (Tipo_Transaccion, FechaTransaccion, Monto, CuentaOrigenID, CuentaDestinoID, SucursalID)
        VALUES ('Transferencia', GETDATE(), @Monto, @CuentaOrigenID, @CuentaDestinoID, @SucursalID);

        -- Confirmar transacción
        COMMIT;
    END TRY
    BEGIN CATCH
        -- Revertir cambios en caso de error
        ROLLBACK;

        -- Opcional: manejar el error o lanzar una excepción
        -- Puedes capturar más detalles sobre el error aquí si lo necesitas
        THROW;
    END CATCH;
END;


EXEC Realizar_Transferencia
    @CuentaOrigenID = 6,
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
--1. Combinación de Tablas: Escribe una consulta que combine las tablas Clientes y
--Cuentas Bancarias para listar todos los clientes con sus respectivas cuentas bancarias.

SELECT c.ClienteID, c.Nombre, c.Direccion, c.Correo, c.Telefono, c.NumeroIdentificacion, o.Numero_Cuenta, o.Tipo_Cuenta, o.Saldo, o.Fecha_Apertura
FROM ClienteID AS c
INNER JOIN Cuentas_Bancarias AS o
ON c.ClienteID = o.ClienteID

Numero_Cuenta, Tipo_Cuenta, Saldo, Fecha_Apertura, ClienteID, SucursalID