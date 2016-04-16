USE [MultiSoft]
GO

ALTER TABLE [dbo].[DebtorStatementLineHistory] DROP CONSTRAINT [DF_DebtorStatementLineHistory_DSLH_IsInfo]
GO

ALTER TABLE [dbo].[DebtorStatementLineHistory] DROP CONSTRAINT [DF_DebtorStatementLineHistory_DSLH_IsBroughtForward]
GO

/****** Object:  Table [dbo].[DebtorStatementLineHistory]    Script Date: 16/04/2016 11:00:39 PM ******/
DROP TABLE [dbo].[DebtorStatementLineHistory]
GO

/****** Object:  Table [dbo].[DebtorStatementLineHistory]    Script Date: 16/04/2016 11:00:39 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[DebtorStatementLineHistory](
	[DSLH_ID] [int] IDENTITY(1,1) NOT NULL,
	[DSLH_DSL_ID] [int] NOT NULL,
	[DSLH_DSH_ID] [int] NOT NULL,
	[DSLH_IF_ID] [int] NOT NULL,
	[DSLH_EntityID] [int] NOT NULL,
	[DSLH_Date] [smalldatetime] NULL,
	[DSLH_References] [varchar](50) NULL,
	[DSLH_IsBroughtForward] [bit] NULL,
	[DSLH_IsInfo] [bit] NULL,
	[DSLH_TransactionValue] [money] NULL,
	[DSLH_PaymentAmount] [money] NULL,
 CONSTRAINT [PK_DebtorStatementLineHistory] PRIMARY KEY CLUSTERED 
(
	[DSLH_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[DebtorStatementLineHistory] ADD  CONSTRAINT [DF_DebtorStatementLineHistory_DSLH_IsBroughtForward]  DEFAULT ((0)) FOR [DSLH_IsBroughtForward]
GO

ALTER TABLE [dbo].[DebtorStatementLineHistory] ADD  CONSTRAINT [DF_DebtorStatementLineHistory_DSLH_IsInfo]  DEFAULT ((0)) FOR [DSLH_IsInfo]
GO

