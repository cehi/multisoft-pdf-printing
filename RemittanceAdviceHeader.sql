USE [MultiSoft]
GO

/****** Object:  Table [dbo].[RemittanceAdviceHeader]    Script Date: 08/04/2016 1:03:05 AM ******/
DROP TABLE [dbo].[RemittanceAdviceHeader]
GO

/****** Object:  Table [dbo].[RemittanceAdviceHeader]    Script Date: 08/04/2016 1:03:05 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[RemittanceAdviceHeader](
	[RAH_ID] [int] IDENTITY(1,1) NOT NULL,
	[RAH_EntityValue] [varchar](50) NOT NULL,
	[RAH_IF_ID] [int] NOT NULL,
	[RAH_EntityID] [int] NOT NULL,
	[RAH_IsSecure] [bit] NOT NULL,
	[RAH_CU_ID] [char](3) NULL,
	[RAH_SuppNo] [varchar](50) NULL,
	[RAH_SuppNameAddress] [varchar](1000) NULL,
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

