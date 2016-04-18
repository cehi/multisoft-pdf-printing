USE [MultiSoft]
GO

/****** Object:  View [dbo].[vw_DebtorStatementLine]    Script Date: 18/04/2016 4:16:28 PM ******/
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

