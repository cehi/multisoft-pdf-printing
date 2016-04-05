USE [MultiSoft]
GO

/****** Object:  Table [dbo].[RemittanceAdviceHeader]    Script Date: 06/04/2016 1:24:58 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[RemittanceAdviceHeader](
	[RAH_ID] [int] NOT NULL,
	[RAH_IF_ID] [int] NOT NULL,
	[RAH_EntityID] [int] NOT NULL,
	[RAH_IsSecure] [bit] NOT NULL,
	[RAH_SuppNo] [varchar](50) NULL,
	[RAH_SuppAddress] [varchar](1000) NULL,
	[RAH_TotalAmountPaid] [money] NULL,
	[RAH_PrintDate] [smalldatetime] NULL,
 CONSTRAINT [PK_RemittanceAdviceHeader] PRIMARY KEY CLUSTERED 
(
	[RAH_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

