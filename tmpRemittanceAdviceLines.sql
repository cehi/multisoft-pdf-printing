USE [MultiSoft]
GO

/****** Object:  Table [dbo].[tmpRemittanceAdviceLines]    Script Date: 08/04/2016 1:06:20 AM ******/
DROP TABLE [dbo].[tmpRemittanceAdviceLines]
GO

/****** Object:  Table [dbo].[tmpRemittanceAdviceLines]    Script Date: 08/04/2016 1:06:20 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[tmpRemittanceAdviceLines](
	[IL_ID] [int] NOT NULL,
	[IL_IF_ID] [int] NOT NULL,
	[IL_EntityID] [int] NULL,
	[IL_EntityValue] [int] NULL,
	[RAL_Date] [smalldatetime] NULL,
	[RAL_TransactionTypeRef] [varchar](50) NULL,
	[RAL_OurRef] [varchar](50) NULL,
	[RAL_IsInfo] [bit] NULL,
	[RAL_TransactionValue] [varchar](50) NULL,
	[RAL_PaymentAmount] [varchar](50) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

