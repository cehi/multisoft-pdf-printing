USE [MultiSoft]
GO


/****** Object:  View [dbo].[vw_RemittanceAdviceLine]    Script Date: 18/04/2016 4:17:09 PM ******/
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


