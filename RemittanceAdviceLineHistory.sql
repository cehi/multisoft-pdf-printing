USE [MultiSoft]
GO

ALTER TABLE [dbo].[RemittanceAdviceLineHistory] DROP CONSTRAINT [DF_RemittanceAdviceLineHistory_RALH_IsInfo]
GO

/****** Object:  Table [dbo].[RemittanceAdviceLineHistory]    Script Date: 08/04/2016 1:04:27 AM ******/
DROP TABLE [dbo].[RemittanceAdviceLineHistory]
GO

/****** Object:  Table [dbo].[RemittanceAdviceLineHistory]    Script Date: 08/04/2016 1:04:27 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[RemittanceAdviceLineHistory](
	[RALH_ID] [int] IDENTITY(1,1) NOT NULL,
	[RALH_RAL_ID] [int] NOT NULL,
	[RALH_RAH_ID] [int] NOT NULL,
	[RALH_IF_ID] [int] NOT NULL,
	[RALH_EntityID] [int] NOT NULL,
	[RALH_Date] [smalldatetime] NULL,
	[RALH_TransactionTypeRef] [varchar](50) NULL,
	[RALH_OurRef] [varchar](50) NULL,
	[RALH_IsInfo] [bit] NULL,
	[RALH_TransactionValue] [money] NULL,
	[RALH_PaymentAmount] [money] NULL,
 CONSTRAINT [PK_RemittanceAdviceLineHistory] PRIMARY KEY CLUSTERED 
(
	[RALH_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[RemittanceAdviceLineHistory] ADD  CONSTRAINT [DF_RemittanceAdviceLineHistory_RALH_IsInfo]  DEFAULT ((0)) FOR [RALH_IsInfo]
GO

