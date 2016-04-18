USE [MultiSoft]
GO


/****** Object:  View [dbo].[vw_RemittanceAdviceHeader]    Script Date: 18/04/2016 4:16:51 PM ******/
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
