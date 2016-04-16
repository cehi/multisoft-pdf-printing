USE [MultiSoft]
GO

/****** Object:  Table [dbo].[DebtorStatementHeader]    Script Date: 16/04/2016 10:59:22 PM ******/
DROP TABLE [dbo].[DebtorStatementHeader]
GO

/****** Object:  Table [dbo].[DebtorStatementHeader]    Script Date: 16/04/2016 10:59:22 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[DebtorStatementHeader](
	[DSH_ID] [int] IDENTITY(1,1) NOT NULL,
	[DSH_EntityValue] [varchar](50) NOT NULL,
	[DSH_IF_ID] [int] NOT NULL,
	[DSH_EntityID] [int] NOT NULL,
	[DSH_IsSecure] [bit] NOT NULL,
	[DSH_CU_ID] [char](3) NULL,
	[DSH_AccountNo] [varchar](50) NULL,
	[DSH_StatementDate] [smalldatetime] NULL,
	[DSH_CustomerNameAddress] [varchar](1000) NULL,
	[DSH_AccountBalance] [money] NULL,
	[DSH_3MonthsBalance] [money] NULL,
	[DSH_2MonthsBalance] [money] NULL,
	[DSH_1MonthBalance] [money] NULL,
	[DSH_CurrentBalance] [money] NULL,
	[DSH_UnallocatedCash] [money] NULL,
 CONSTRAINT [PK_DebtorStatementHeader] PRIMARY KEY CLUSTERED 
(
	[DSH_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

