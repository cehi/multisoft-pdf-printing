USE [MultiSoft]
GO

/****** Object:  Table [dbo].[tmpRAHDeliverTo]    Script Date: 08/04/2016 1:05:17 AM ******/
DROP TABLE [dbo].[tmpRAHDeliverTo]
GO

/****** Object:  Table [dbo].[tmpRAHDeliverTo]    Script Date: 08/04/2016 1:05:17 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[tmpRAHDeliverTo](
	[MyDeliver] [int] NULL,
	[IL_IF_ID] [int] NOT NULL,
	[IL_EntityID] [int] NOT NULL,
	[IL_EntityValue] [varchar](50) NULL,
	[DeliverTo] [varchar](38) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

