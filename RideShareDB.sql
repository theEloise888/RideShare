
--USE MASTER;
--GO

--DROP DATABASE RideShare;
--GO



CREATE DATABASE RideShare;
GO

USE RideShare;
GO

-- Station
CREATE TABLE dbo.Stations (
    StationID   INT IDENTITY CONSTRAINT PK_Stations PRIMARY KEY,
    StationName NVARCHAR(25) NOT NULL,  
    Capacity    INT NOT NULL,

-- add check constraint to prevent negative numbers from being added to the Capacity column
CONSTRAINT CK_Stations CHECK (Capacity >=0),

--station records were frequently looked up by StationName, which can be used to uniquely identify records. 
--They would like these lookups optimized.
CONSTRAINT AK_Stations_StationName UNIQUE ( StationName )

);

-- Rider
CREATE TABLE dbo.Riders (
    RiderID     INT IDENTITY CONSTRAINT PK_Riders PRIMARY KEY,
    RiderSIN    CHAR(9) NOT NULL,    
    FirstName   NVARCHAR(25) NOT NULL,
    LastName    NVARCHAR(25) NOT NULL,
    DateOfBirth DATE NOT NULL,


CONSTRAINT CK_RIDERS CHECK (DateOfBirth <= GETDATE ()),
CONSTRAINT AK_Riders_RiderSIN UNIQUE ( RiderSIN )
);

-- Bike
CREATE TABLE dbo.Bikes (
    BikeID           INT IDENTITY CONSTRAINT PK_Bikes PRIMARY KEY,
    HomeStationID    INT NOT NULL CONSTRAINT FK_Bikes_Stations_Home REFERENCES dbo.Stations ( StationID ),
    CurrentStationID INT NOT NULL CONSTRAINT FK_Bikes_Stations_Current REFERENCES dbo.Stations ( StationID ),
    RiderID          INT NULL CONSTRAINT FK_Bikes_Riders REFERENCES dbo.Riders ( RiderID ),
    SerialNumber     NVARCHAR(25) NOT NULL,
    ModelName        NVARCHAR(25) NOT NULL,
    LastServiceDate  DATETIME NULL,
--Lookups on SerialNumber will need to be properly optimized and constrained.
	CONSTRAINT AK_Bikes_SerialNumber UNIQUE ( SerialNumber )
);


-- Account
CREATE TABLE dbo.Accounts (
    AccountID       INT IDENTITY CONSTRAINT PK_Accounts PRIMARY KEY,
    AccountNumber   CHAR(10) NOT NULL,
    CurrentBalance  MONEY NOT NULL DEFAULT 0,
    AccountOpenDate DATE NOT NULL CHECK (AccountOpenDate <= GETDATE ()),
    PrimaryRiderID  INT NOT NULL,
    CONSTRAINT FK_Accounts_Riders FOREIGN KEY ( PrimaryRiderID) REFERENCES dbo.Riders ( RiderID ),


);

ALTER TABLE Accounts ADD
CONSTRAINT AK_Accounts_AccountNumber UNIQUE ( AccountNumber )
go


ALTER TABLE Accounts 
 ADD CONSTRAINT DF_Accounts_AccountOpenDate
 DEFAULT GETDATE() for AccountOpenDate


CREATE INDEX IX_Accounts_PrimaryRiderID ON dbo.Accounts ( PrimaryRiderID );

-- Address
CREATE TABLE dbo.Addresses (
    AddressID INT IDENTITY CONSTRAINT PK_Addresses PRIMARY KEY,
    Street    NVARCHAR(250),
    City      NVARCHAR(250),
    Province  NVARCHAR(250),
    Postal    CHAR(6)

);
--The first query creates a sorted list of provinces and cities. 
CREATE INDEX IX_Cities_Province_City ON dbo.Addresses ( Province, City );

--The second query looks up records by province only. 
CREATE INDEX IX_Provinces ON dbo.Addresses ( Province );


--The last query looks up records by city only.
CREATE INDEX IX_Cities ON dbo.Addresses ( City );

--JUNCTIONS 

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


--constrain both ways 	

CREATE INDEX IX_RiderAccounts_RiderID ON dbo.RiderAccounts ( RiderID, AccountID );
CREATE INDEX IX_RiderAccounts_AccountID ON dbo.RiderAccounts ( AccountID, RiderID );
CREATE INDEX IX_RiderAddresses_RiderID ON dbo.RiderAddresses ( RiderID, AddressID );
CREATE INDEX IX_RiderAddresses_AddressID ON dbo.RiderAddresses ( AddressID, RiderID );    
