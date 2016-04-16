USE [MultiSoft]
GO

/****** Object:  Table [dbo].[tmpDebtorStatementLines]    Script Date: 16/04/2016 11:02:46 PM ******/
DROP TABLE [dbo].[tmpDebtorStatementLines]
GO

/****** Object:  Table [dbo].[tmpDebtorStatementLines]    Script Date: 16/04/2016 11:02:46 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[tmpDebtorStatementLines](
	[IL_ID] [int] NOT NULL,
	[IL_IF_ID] [int] NOT NULL,
	[IL_EntityID] [int] NULL,
	[IL_EntityValue] [int] NULL,
	[DSL_Date] [smalldatetime] NULL,
	[DSL_References] [varchar](50) NULL,
	[DSL_IsBroughtForward] [bit] NULL,
	[DSL_IsInfo] [bit] NULL,
	[DSL_TransactionValue] [varchar](50) NULL,
	[DSL_PaymentAmount] [varchar](50) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

