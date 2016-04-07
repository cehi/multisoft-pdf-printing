USE [MultiSoft]
GO

/****** Object:  Table [dbo].[RemittanceAdviceHeaderHistory]    Script Date: 08/04/2016 1:03:45 AM ******/
DROP TABLE [dbo].[RemittanceAdviceHeaderHistory]
GO

/****** Object:  Table [dbo].[RemittanceAdviceHeaderHistory]    Script Date: 08/04/2016 1:03:45 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[RemittanceAdviceHeaderHistory](
	[RAHH_ID] [int] IDENTITY(1,1) NOT NULL,
	[RAHH_RAH_ID] [int] NOT NULL,
	[RAHH_EntityValue] [varchar](50) NOT NULL,
	[RAHH_IF_ID] [int] NOT NULL,
	[RAHH_EntityID] [int] NOT NULL,
	[RAHH_IsSecure] [bit] NOT NULL,
	[RAHH_CU_ID] [char](3) NULL,
	[RAHH_SuppNo] [varchar](50) NULL,
	[RAHH_SuppNameAddress] [varchar](1000) NULL,
	[RAHH_TotalAmountPaid] [money] NULL,
	[RAHH_PrintDate] [smalldatetime] NULL,
 CONSTRAINT [PK_RemittanceAdviceHeaderHistory] PRIMARY KEY CLUSTERED 
(
	[RAHH_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

