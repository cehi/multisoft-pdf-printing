USE [MultiSoft]
GO

/****** Object:  Table [dbo].[RemittanceAdviceLine]    Script Date: 06/04/2016 1:25:18 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[RemittanceAdviceLine](
	[RAL_ID] [int] NOT NULL,
	[RAL_RAH_ID] [int] NOT NULL,
	[RAL_IF_ID] [int] NOT NULL,
	[RAL_EntityID] [int] NOT NULL,
	[RAL_Date] [smalldatetime] NULL,
	[RAL_TransactionTypeRef] [varchar](50) NULL,
	[RAL_OurRef] [varchar](50) NULL,
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

