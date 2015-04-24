CREATE TABLE [dbo].[Orders] (
    [Id]         INT             IDENTITY (1, 1) NOT NULL,
    [Product]    NVARCHAR (50)   NULL,
    [Price]      DECIMAL (18, 2) NOT NULL,
    [Quantity]   INT             NOT NULL,
    [Date]       DATETIME        NOT NULL,
    [CustomerId] INT             NOT NULL,
    CONSTRAINT [PK_dbo.Orders] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_dbo.Orders_dbo.Customers_CustomerId] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Customers] ([Id]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IX_CustomerId]
    ON [dbo].[Orders]([CustomerId] ASC);

