CREATE TABLE [dbo].[States] (
    [Id]           INT           IDENTITY (1, 1) NOT NULL,
    [Abbreviation] NVARCHAR (2)  NULL,
    [Name]         NVARCHAR (25) NULL,
    CONSTRAINT [PK_dbo.States] PRIMARY KEY CLUSTERED ([Id] ASC)
);

