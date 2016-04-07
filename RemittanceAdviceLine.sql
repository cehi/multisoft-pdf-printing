USE [MultiSoft]
GO

ALTER TABLE [dbo].[RemittanceAdviceLine] DROP CONSTRAINT [DF_RemittanceAdviceLine_RAL_IsInfo]
GO

/****** Object:  Table [dbo].[RemittanceAdviceLine]    Script Date: 08/04/2016 1:04:07 AM ******/
DROP TABLE [dbo].[RemittanceAdviceLine]
GO

/****** Object:  Table [dbo].[RemittanceAdviceLine]    Script Date: 08/04/2016 1:04:07 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[RemittanceAdviceLine](
	[RAL_ID] [int] IDENTITY(1,1) NOT NULL,
	[RAL_RAH_ID] [int] NOT NULL,
	[RAL_IF_ID] [int] NOT NULL,
	[RAL_EntityID] [int] NOT NULL,
	[RAL_Date] [smalldatetime] NULL,
	[RAL_TransactionTypeRef] [varchar](50) NULL,
	[RAL_OurRef] [varchar](50) NULL,
	[RAL_IsInfo] [bit] NULL,
	[RAL_TransactionValue] [money] NULL,
	[RAL_PaymentAmount] [money] NULL,
 CONSTRAINT [PK_RemittanceAdviceLine] PRIMARY KEY CLUSTERED 
(
	[RAL_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[RemittanceAdviceLine] ADD  CONSTRAINT [DF_RemittanceAdviceLine_RAL_IsInfo]  DEFAULT ((0)) FOR [RAL_IsInfo]
GO

