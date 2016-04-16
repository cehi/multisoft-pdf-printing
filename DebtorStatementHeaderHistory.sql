USE [MultiSoft]
GO

/****** Object:  Table [dbo].[DebtorStatementHeaderHistory]    Script Date: 16/04/2016 10:59:51 PM ******/
DROP TABLE [dbo].[DebtorStatementHeaderHistory]
GO

/****** Object:  Table [dbo].[DebtorStatementHeaderHistory]    Script Date: 16/04/2016 10:59:51 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[DebtorStatementHeaderHistory](
	[DSHH_ID] [int] IDENTITY(1,1) NOT NULL,
	[DSHH_DSH_ID] [int] NOT NULL,
	[DSHH_EntityValue] [varchar](50) NOT NULL,
	[DSHH_IF_ID] [int] NOT NULL,
	[DSHH_EntityID] [int] NOT NULL,
	[DSHH_IsSecure] [bit] NOT NULL,
	[DSHH_CU_ID] [char](3) NULL,
	[DSHH_AccountNo] [varchar](50) NULL,
	[DSHH_StatementDate] [smalldatetime] NULL,
	[DSHH_CustomerNameAddress] [varchar](1000) NULL,
	[DSHH_AccountBalance] [money] NULL,
	[DSHH_3MonthsBalance] [money] NULL,
	[DSHH_2MonthsBalance] [money] NULL,
	[DSHH_1MonthBalance] [money] NULL,
	[DSHH_CurrentBalance] [money] NULL,
	[DSHH_UnallocatedCash] [money] NULL,
 CONSTRAINT [PK_DebtorStatementHeaderHistory] PRIMARY KEY CLUSTERED 
(
	[DSHH_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

