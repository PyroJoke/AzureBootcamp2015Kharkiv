﻿CREATE TABLE [dbo].[GabKharkivRaffle]
(
	[Id] INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	[Name] NVARCHAR(255) NOT NULL,
	[Email] NVARCHAR(255) NOT NULL,
	[TShirtSize] nchar(2) NOT NULL
)
