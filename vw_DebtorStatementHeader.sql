USE [MultiSoft]
GO


/****** Object:  View [dbo].[vw_DebtorStatementHeader]    Script Date: 18/04/2016 4:16:08 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vw_DebtorStatementHeader]
AS
SELECT        DSH_ID, DSH_EntityValue, DSH_IF_ID, DSH_EntityID, DSH_CU_ID, DSH_AccountNo, CONVERT(VARCHAR(8), DSH_StatementDate, 4) AS Expr1, 
                         DSH_CustomerNameAddress, CONVERT(VARCHAR(20), DSH_AccountBalance, 1) AS DSH_AccountBalance, CONVERT(VARCHAR(20), DSH_3MonthsBalance, 1) 
                         AS DSH_3MonthsBalance, CONVERT(VARCHAR(20), DSH_2MonthsBalance, 1) AS DSH_2MonthsBalance, CONVERT(VARCHAR(20), DSH_1MonthBalance, 1) 
                         AS DSH_1MonthBalance, CONVERT(VARCHAR(20), DSH_CurrentBalance, 1) AS DSH_CurrentBalance, CONVERT(VARCHAR(20), DSH_UnallocatedCash, 1) 
                         AS DSH_UnallocatedCash
FROM            dbo.DebtorStatementHeader

GO
