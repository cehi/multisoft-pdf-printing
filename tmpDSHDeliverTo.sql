USE [MultiSoft]
GO

/****** Object:  Table [dbo].[tmpDSHDeliverTo]    Script Date: 16/04/2016 11:01:33 PM ******/
DROP TABLE [dbo].[tmpDSHDeliverTo]
GO

/****** Object:  Table [dbo].[tmpDSHDeliverTo]    Script Date: 16/04/2016 11:01:33 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[tmpDSHDeliverTo](
	[MyDeliver] [int] NULL,
	[IL_IF_ID] [int] NOT NULL,
	[IL_EntityID] [int] NOT NULL,
	[IL_EntityValue] [varchar](50) NULL,
	[DeliverTo] [varchar](38) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

