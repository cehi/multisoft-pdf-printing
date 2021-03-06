USE [MultiSoft]
GO
/****** Object:  View [dbo].[vw_DebtorStatementHeader]    Script Date: 21/04/2016 7:52:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_DebtorStatementHeader]
AS
SELECT        DSH_ID, DSH_EntityValue, DSH_IF_ID, DSH_EntityID, DSH_CU_ID, DSH_AccountNo, CONVERT(VARCHAR(8), DSH_StatementDate, 4) AS DSH_StatementDate, 
                         DSH_CustomerNameAddress, CONVERT(VARCHAR(20), DSH_AccountBalance, 1) AS DSH_AccountBalance, CONVERT(VARCHAR(20), DSH_3MonthsBalance, 1) 
                         AS DSH_3MonthsBalance, CONVERT(VARCHAR(20), DSH_2MonthsBalance, 1) AS DSH_2MonthsBalance, CONVERT(VARCHAR(20), DSH_1MonthBalance, 1) 
                         AS DSH_1MonthBalance, CONVERT(VARCHAR(20), DSH_CurrentBalance, 1) AS DSH_CurrentBalance, CONVERT(VARCHAR(20), DSH_UnallocatedCash, 1) 
                         AS DSH_UnallocatedCash
FROM            dbo.DebtorStatementHeader
WHERE        (DSH_IsSecure = 0)

GO
/****** Object:  View [dbo].[vw_DebtorStatementLine]    Script Date: 21/04/2016 7:52:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_DebtorStatementLine]
AS
SELECT        DSL_ID, DSL_DSH_ID, DSL_IF_ID, DSL_EntityID, CONVERT(VARCHAR(8), DSL_Date, 4) AS DSL_Date, DSL_References, DSL_IsBroughtForward, DSL_IsInfo, 
                         CONVERT(VARCHAR(20), DSL_TransactionValue, 1) AS DSL_TransactionValue, CONVERT(VARCHAR(20), DSL_PaymentAmount, 1) AS DSL_PaymentAmount
FROM            dbo.DebtorStatementLine

GO
/****** Object:  View [dbo].[vw_RemittanceAdviceHeader]    Script Date: 21/04/2016 7:52:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_RemittanceAdviceHeader]
AS
SELECT        RAH_ID, RAH_EntityValue, RAH_IF_ID, RAH_EntityID, RAH_CU_ID, RAH_SuppNo, RAH_SuppNameAddress, CONVERT(VARCHAR(20), RAH_TotalAmountPaid, 1) 
                         AS RAH_TotalAmountPaid, CONVERT(VARCHAR(8), RAH_PrintDate, 4) AS RAH_PrintDate
FROM            dbo.RemittanceAdviceHeader
WHERE        (RAH_IsSecure = 0)

GO
/****** Object:  View [dbo].[vw_RemittanceAdviceLine]    Script Date: 21/04/2016 7:52:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_RemittanceAdviceLine]
AS
SELECT        RAL_ID, RAL_RAH_ID, RAL_IF_ID, RAL_EntityID, CONVERT(VARCHAR(8), RAL_Date, 4) AS RAL_Date, RAL_TransactionTypeRef, RAL_OurRef, RAL_IsInfo, 
                         CONVERT(VARCHAR(20), RAL_TransactionValue, 1) AS RAL_TransactionValue, CONVERT(VARCHAR(20), RAL_PaymentAmount, 1) AS RAL_PaymentAmount
FROM            dbo.RemittanceAdviceLine

GO