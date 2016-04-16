USE [MultiSoft]
GO

ALTER TABLE [dbo].[DebtorStatementLine] DROP CONSTRAINT [DF_DebtorStatementLine_DSL_IsInfo]
GO

ALTER TABLE [dbo].[DebtorStatementLine] DROP CONSTRAINT [DF_DebtorStatementLine_DSL_IsBroughtForward]
GO

/****** Object:  Table [dbo].[DebtorStatementLine]    Script Date: 16/04/2016 11:00:20 PM ******/
DROP TABLE [dbo].[DebtorStatementLine]
GO

/****** Object:  Table [dbo].[DebtorStatementLine]    Script Date: 16/04/2016 11:00:20 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[DebtorStatementLine](
	[DSL_ID] [int] IDENTITY(1,1) NOT NULL,
	[DSL_DSH_ID] [int] NOT NULL,
	[DSL_IF_ID] [int] NOT NULL,
	[DSL_EntityID] [int] NOT NULL,
	[DSL_Date] [smalldatetime] NULL,
	[DSL_References] [varchar](50) NULL,
	[DSL_IsBroughtForward] [bit] NULL,
	[DSL_IsInfo] [bit] NULL,
	[DSL_TransactionValue] [money] NULL,
	[DSL_PaymentAmount] [money] NULL,
 CONSTRAINT [PK_DebtorStatementLine] PRIMARY KEY CLUSTERED 
(
	[DSL_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[DebtorStatementLine] ADD  CONSTRAINT [DF_DebtorStatementLine_DSL_IsBroughtForward]  DEFAULT ((0)) FOR [DSL_IsBroughtForward]
GO

ALTER TABLE [dbo].[DebtorStatementLine] ADD  CONSTRAINT [DF_DebtorStatementLine_DSL_IsInfo]  DEFAULT ((0)) FOR [DSL_IsInfo]
GO

