CREATE TABLE [dbo].[Customers] (
    [Id]        INT             IDENTITY (1, 1) NOT NULL,
    [FirstName] NVARCHAR (50)   NULL,
    [LastName]  NVARCHAR (50)   NULL,
    [Email]     NVARCHAR (100)  NULL,
    [Address]   NVARCHAR (1000) NULL,
    [City]      NVARCHAR (50)   NULL,
    [StateId]   INT             NOT NULL,
    [Zip]       INT             NOT NULL,
    [Gender]    INT             NOT NULL,
    CONSTRAINT [PK_dbo.Customers] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_dbo.Customers_dbo.States_StateId] FOREIGN KEY ([StateId]) REFERENCES [dbo].[States] ([Id]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IX_StateId]
    ON [dbo].[Customers]([StateId] ASC);

