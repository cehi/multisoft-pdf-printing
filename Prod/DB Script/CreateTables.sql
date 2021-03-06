USE [MultiSoft]
GO
/****** Object:  Table [dbo].[DebtorStatementHeader]    Script Date: 21/04/2016 7:51:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DebtorStatementHeader](
	[DSH_ID] [int] IDENTITY(1,1) NOT NULL,
	[DSH_EntityValue] [varchar](50) NOT NULL,
	[DSH_IF_ID] [int] NOT NULL,
	[DSH_EntityID] [int] NOT NULL,
	[DSH_IsSecure] [bit] NOT NULL,
	[DSH_CU_ID] [char](3) NULL,
	[DSH_AccountNo] [varchar](50) NULL,
	[DSH_StatementDate] [smalldatetime] NULL,
	[DSH_CustomerNameAddress] [varchar](1000) NULL,
	[DSH_AccountBalance] [money] NULL,
	[DSH_3MonthsBalance] [money] NULL,
	[DSH_2MonthsBalance] [money] NULL,
	[DSH_1MonthBalance] [money] NULL,
	[DSH_CurrentBalance] [money] NULL,
	[DSH_UnallocatedCash] [money] NULL,
 CONSTRAINT [PK_DebtorStatementHeader] PRIMARY KEY CLUSTERED 
(
	[DSH_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DebtorStatementHeaderHistory]    Script Date: 21/04/2016 7:51:02 PM ******/
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
/****** Object:  Table [dbo].[DebtorStatementLine]    Script Date: 21/04/2016 7:51:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DebtorStatementLine](
	[DSL_ID] [int] IDENTITY(1,1) NOT NULL,
	[DSL_DSH_ID] [int] NOT NULL,
	[DSL_IF_ID] [int] NOT NULL,
	[DSL_EntityID] [int] NOT NULL,
	[DSL_Date] [smalldatetime] NULL,
	[DSL_References] [varchar](50) NULL,
	[DSL_IsBroughtForward] [bit] NULL CONSTRAINT [DF_DebtorStatementLine_DSL_IsBroughtForward]  DEFAULT ((0)),
	[DSL_IsInfo] [bit] NULL CONSTRAINT [DF_DebtorStatementLine_DSL_IsInfo]  DEFAULT ((0)),
	[DSL_TransactionValue] [money] NULL,
	[DSL_PaymentAmount] [money] NULL,
 CONSTRAINT [PK_DebtorStatementLine] PRIMARY KEY CLUSTERED 
(
	[DSL_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DebtorStatementLineHistory]    Script Date: 21/04/2016 7:51:02 PM ******/
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
	[DSLH_IsBroughtForward] [bit] NULL CONSTRAINT [DF_DebtorStatementLineHistory_DSLH_IsBroughtForward]  DEFAULT ((0)),
	[DSLH_IsInfo] [bit] NULL CONSTRAINT [DF_DebtorStatementLineHistory_DSLH_IsInfo]  DEFAULT ((0)),
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
/****** Object:  Table [dbo].[RemittanceAdviceHeader]    Script Date: 21/04/2016 7:51:02 PM ******/
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
/****** Object:  Table [dbo].[RemittanceAdviceHeaderHistory]    Script Date: 21/04/2016 7:51:02 PM ******/
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
/****** Object:  Table [dbo].[RemittanceAdviceLine]    Script Date: 21/04/2016 7:51:02 PM ******/
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
	[RAL_IsInfo] [bit] NULL CONSTRAINT [DF_RemittanceAdviceLine_RAL_IsInfo]  DEFAULT ((0)),
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
/****** Object:  Table [dbo].[RemittanceAdviceLineHistory]    Script Date: 21/04/2016 7:51:02 PM ******/
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
	[RALH_IsInfo] [bit] NULL CONSTRAINT [DF_RemittanceAdviceLineHistory_RALH_IsInfo]  DEFAULT ((0)),
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
/****** Object:  Table [dbo].[tmpDebtorStatementLines]    Script Date: 21/04/2016 7:51:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tmpDebtorStatementLines](
	[IL_ID] [int] IDENTITY(1,1) NOT NULL,
	[IL_IF_ID] [int] NOT NULL,
	[IL_EntityID] [int] NULL,
	[IL_EntityValue] [varchar](50) NULL,
	[DSL_Date] [date] NULL,
	[DSL_References] [varchar](28) NULL,
	[DSL_OurRef] [varchar](12) NULL,
	[DSL_IsBroughtForward] [int] NOT NULL,
	[DSL_IsInfo] [int] NOT NULL,
	[DSL_TransactionValue] [varchar](50) NULL,
	[DSL_PaymentAmount] [varchar](50) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tmpDSHDeliverTo]    Script Date: 21/04/2016 7:51:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tmpDSHDeliverTo](
	[MyDeliver] [int] NULL,
	[IL_IF_ID] [int] NOT NULL,
	[IL_EntityID] [int] NULL,
	[IL_EntityValue] [varchar](50) NULL,
	[DeliverTo] [varchar](38) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tmpDSHNewDuplicates]    Script Date: 21/04/2016 7:51:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tmpDSHNewDuplicates](
	[DSH_ID] [int] NOT NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tmpRAHDeliverTo]    Script Date: 21/04/2016 7:51:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tmpRAHDeliverTo](
	[MyDeliver] [int] NULL,
	[IL_IF_ID] [int] NOT NULL,
	[IL_EntityID] [int] NULL,
	[IL_EntityValue] [varchar](50) NULL,
	[DeliverTo] [varchar](38) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tmpRAHNewDuplicates]    Script Date: 21/04/2016 7:51:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tmpRAHNewDuplicates](
	[RAH_ID] [int] NOT NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tmpRemittanceAdviceLines]    Script Date: 21/04/2016 7:51:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tmpRemittanceAdviceLines](
	[IL_ID] [int] IDENTITY(1,1) NOT NULL,
	[IL_IF_ID] [int] NOT NULL,
	[IL_EntityID] [int] NULL,
	[IL_EntityValue] [varchar](50) NULL,
	[RAL_Date] [date] NULL,
	[RAL_TransactionTypeRef] [varchar](16) NULL,
	[RAL_OurRef] [varchar](12) NULL,
	[RAL_IsInfo] [int] NOT NULL,
	[RAL_TransactionValue] [varchar](50) NULL,
	[RAL_PaymentAmount] [varchar](50) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
