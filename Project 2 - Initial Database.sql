/*
USE MASTER;
GO

DROP DATABASE RideShare;
GO
--*/

CREATE DATABASE RideShare;
GO

USE RideShare;
GO

-- Station
CREATE TABLE dbo.Stations (
    StationID   INT IDENTITY CONSTRAINT PK_Stations PRIMARY KEY,
    StationName NVARCHAR(25) NOT NULL,  
    Capacity    INT NOT NULL
);

-- Rider
CREATE TABLE dbo.Riders (
    RiderID     INT IDENTITY CONSTRAINT PK_Riders PRIMARY KEY,
    RiderSIN    CHAR(9) NOT NULL,    
    FirstName   NVARCHAR(25) NOT NULL,
    LastName    NVARCHAR(25) NOT NULL,
    DateOfBirth DATE NOT NULL
);

-- Bike
CREATE TABLE dbo.Bikes (
    BikeID           INT IDENTITY CONSTRAINT PK_Bikes PRIMARY KEY,
    HomeStationID    INT NOT NULL CONSTRAINT FK_Bikes_Stations_Home REFERENCES dbo.Stations ( StationID ),
    CurrentStationID INT NOT NULL CONSTRAINT FK_Bikes_Stations_Current REFERENCES dbo.Stations ( StationID ),
    RiderID          INT NULL CONSTRAINT FK_Bikes_Riders REFERENCES dbo.Riders ( RiderID ),
    SerialNumber     NVARCHAR(25) NOT NULL,
    ModelName        NVARCHAR(25) NOT NULL,
    LastServiceDate  DATETIME NULL
);

-- Account
CREATE TABLE dbo.Accounts (
    AccountID       INT IDENTITY CONSTRAINT PK_Accounts PRIMARY KEY,
    AccountNumber   CHAR(10) NOT NULL,
    CurrentBalance  MONEY NOT NULL,
    AccountOpenDate DATE NOT NULL,
    PrimaryRiderID  INT NOT NULL,
    CONSTRAINT FK_Accounts_Riders FOREIGN KEY ( PrimaryRiderID) REFERENCES dbo.Riders ( RiderID )
);

-- Address
CREATE TABLE dbo.Addresses (
    AddressID INT IDENTITY CONSTRAINT PK_Addresses PRIMARY KEY,
    Street    NVARCHAR(250),
    City      NVARCHAR(250),
    Province  NVARCHAR(250),
    Postal    CHAR(6)
);

-- RiderAccount
CREATE TABLE dbo.RiderAccounts (
    RiderAccountID INT IDENTITY,
    RiderID        INT NOT NULL,
    AccountID      INT NOT NULL,

    CONSTRAINT PK_RiderAccounts PRIMARY KEY ( RiderAccountID ),    
    CONSTRAINT FK_RiderAccounts_Riders FOREIGN KEY ( RiderID ) REFERENCES dbo.Riders ( RiderID ),
    CONSTRAINT FK_RiderAccounts_Accounts FOREIGN KEY ( AccountID ) REFERENCES dbo.Accounts ( AccountID )
);

-- RiderAddress
CREATE TABLE dbo.RiderAddresses (
    RiderAddressID INT IDENTITY,
    RiderID        INT NOT NULL,
    AddressID      INT NOT NULL,

    CONSTRAINT PK_RiderAddresses PRIMARY KEY ( RiderAddressID ),
    CONSTRAINT FK_RiderAddresses_Riders FOREIGN KEY ( RiderID ) REFERENCES dbo.Riders ( RiderID ),
    CONSTRAINT FK_RiderAddresses_Addresses FOREIGN KEY ( AddressID ) REFERENCES dbo.Addresses ( AddressID )
);
GO
