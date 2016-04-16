USE [MultiSoft]
GO

/****** Object:  StoredProcedure [dbo].[sp_ProcessRemittanceAdvices]    Script Date: 16/04/2016 7:59:08 PM ******/
DROP PROCEDURE [dbo].[sp_ProcessRemittanceAdvices]
GO

/****** Object:  StoredProcedure [dbo].[sp_ProcessRemittanceAdvices]    Script Date: 16/04/2016 7:59:08 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		Chi Vu
-- Create date: 06/04/2016
-- Description:	Process Remittance Advices
-- =============================================
CREATE PROCEDURE [dbo].[sp_ProcessRemittanceAdvices] 
	-- Add the parameters for the stored procedure here
	@IL_IF_ID int
AS
BEGIN
	DECLARE @PL_ID AS int
	DECLARE @PL_ID1 AS int
	DECLARE @PL_ID2 AS int
	DECLARE @PL_ID2a AS int
	DECLARE @PL_ID2b AS int
	DECLARE @PL_ID2c AS int
	DECLARE @PL_ID2d AS int
	DECLARE @PL_ID3 AS int

	INSERT INTO ProcessLog (PL_Action, PL_SubAction, PL_StartTime, PL_IF_ID, PL_EntityValue) VALUES ('sp_ProcessRemittanceAdvices',NULL, getdate(), @IL_IF_ID, NULL)
	SELECT @PL_ID = SCOPE_IDENTITY()


	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Clean up tables
	IF OBJECT_ID('dbo.tmpRAHDeliverTo', 'U') IS NOT NULL
		DROP TABLE dbo.tmpRAHDeliverTo
	IF OBJECT_ID('dbo.tmpRemittanceAdviceLines', 'U') IS NOT NULL
		DROP TABLE dbo.tmpRemittanceAdviceLines
	IF OBJECT_ID('dbo.tmpRAHNewDuplicates', 'U') IS NOT NULL
		DROP TABLE dbo.tmpRAHNewDuplicates

	INSERT INTO ProcessLog (PL_Action, PL_SubAction, PL_StartTime, PL_IF_ID, PL_EntityValue) VALUES ('sp_ProcessRemittanceAdvices','PRA.Move Duplicates To History', getdate(), @IL_IF_ID, NULL)
	SELECT @PL_ID1 = SCOPE_IDENTITY()
	
	SELECT DISTINCT RAH_ID
	INTO tmpRAHNewDuplicates
	FROM ImportedLines IL
	INNER JOIN RemittanceAdviceHeader RAH 
		ON IL.IL_EntityValue = RAH.RAH_EntityValue
	WHERE IL_IF_ID = @IL_IF_ID

	-- Move any Duplicates to History
	INSERT INTO RemittanceAdviceLineHistory (
		RALH_RAL_ID
		,RALH_RAH_ID
		,RALH_IF_ID
		,RALH_EntityID
		,RALH_Date
		,RALH_TransactionTypeRef
		,RALH_OurRef
		,RALH_IsInfo		
		,RALH_TransactionValue
		,RALH_PaymentAmount		
		)
	SELECT RAL_ID
		,RAL_RAH_ID
		,RAL_IF_ID
		,RAL_EntityID
		,RAL_Date
		,RAL_TransactionTypeRef
		,RAL_OurRef
		,RAL_IsInfo		
		,RAL_TransactionValue
		,RAL_PaymentAmount
	FROM RemittanceAdviceLine
	WHERE RAL_RAH_ID IN (SELECT RAH_ID FROM tmpRAHNewDuplicates)

	DELETE FROM RemittanceAdviceLine
	WHERE RAL_RAH_ID IN (SELECT RAH_ID FROM tmpRAHNewDuplicates)

	INSERT INTO RemittanceAdviceHeaderHistory (
		RAHH_RAH_ID
		,RAHH_EntityValue
		,RAHH_IF_ID
		,RAHH_EntityID
		,RAHH_IsSecure
		,RAHH_SuppNo
		,RAHH_SuppNameAddress
		,RAHH_TotalAmountPaid
		,RAHH_PrintDate
		)
	SELECT RAH_ID
		,RAH_EntityValue
		,RAH_IF_ID
		,RAH_EntityID
		,RAH_IsSecure
		,RAH_SuppNo
		,RAH_SuppNameAddress
		,RAH_TotalAmountPaid
		,RAH_PrintDate
	FROM RemittanceAdviceHeader
	WHERE RAH_ID IN (SELECT RAH_ID FROM tmpRAHNewDuplicates)

	UPDATE ReportGeneratedLog
	SET RG_Replaced = 1
	FROM ReportGeneratedLog R
	INNER JOIN (SELECT RAH_IF_ID
				,RAH_EntityID
				FROM RemittanceAdviceHeader
				WHERE RAH_ID in (SELECT RAH_ID FROM tmpRAHNewDuplicates)) H
	  ON R.RG_IF_ID = H.RAH_IF_ID
	 AND R.RG_EntityID = H.RAH_EntityID

	DELETE FROM RemittanceAdviceHeader
	WHERE RAH_ID IN (SELECT RAH_ID FROM tmpRAHNewDuplicates)

	UPDATE ProcessLog SET PL_EndTime = GetDate() WHERE PL_ID = @PL_ID1

	INSERT INTO ProcessLog (PL_Action, PL_SubAction, PL_StartTime, PL_IF_ID, PL_EntityValue) VALUES ('sp_ProcessRemittanceAdvices','PRA.Update Header', getdate(), @IL_IF_ID, NULL)
	SELECT @PL_ID2 = SCOPE_IDENTITY()

	--Insert RemittanceAdvice Stub
	INSERT INTO RemittanceAdviceHeader (
		 RAH_EntityValue
		,RAH_IF_ID
		,RAH_EntityID
		,RAH_IsSecure
		)
	SELECT DISTINCT IL_EntityValue
		,IL_IF_ID
		,IL_EntityID
		,IL_IsSecure		
	FROM ImportedLines
	WHERE IL_IF_ID = @IL_IF_ID
		AND IL_EntityType = 'Remittance Advice'
	ORDER BY IL_EntityValue

	UPDATE ProcessLog SET PL_EndTime = GetDate() WHERE PL_ID = @PL_ID2


	INSERT INTO ProcessLog (PL_Action, PL_SubAction, PL_StartTime, PL_IF_ID, PL_EntityValue) VALUES ('sp_ProcessRemittanceAdvices','PRA.Update Header.SuppNo-PrintDate', getdate(), @IL_IF_ID, NULL)
	SELECT @PL_ID2a = SCOPE_IDENTITY()

	--Update SuppNo and PrintDate
	UPDATE RAH
	SET RAH_SuppNo = SuppNo	  
	FROM RemittanceAdviceHeader RAH
	INNER JOIN (SELECT IL_IF_ID, IL_EntityID, IL_EntityValue
					,LTRIM(RTRIM(SUBSTRING(IL_Contents,50,8))) AS SuppNo
					
				FROM Importedlines
				WHERE 1 = 1
				  AND IL_PageLineID = 14
				  AND IL_IF_ID = @IL_IF_ID
				  AND IL_EntityType = 'Remittance Advice'
			   ) AS U
	  ON RAH.RAH_IF_ID = U.IL_IF_ID
	 AND RAH.RAH_EntityID = U.IL_EntityID

	UPDATE RAH
	SET RAH_PrintDate = PrintDate	  
	FROM RemittanceAdviceHeader RAH
	INNER JOIN (SELECT IL_IF_ID, IL_EntityID, IL_EntityValue
					,CONVERT(date,SUBSTRING(IL_Contents,2,8), 4) AS PrintDate
				FROM Importedlines
				WHERE 1 = 1
				  AND IL_PageLineID = 19
				  AND IL_IF_ID = @IL_IF_ID
				  AND IL_EntityType = 'Remittance Advice'
			   ) AS U
	  ON RAH.RAH_IF_ID = U.IL_IF_ID
	 AND RAH.RAH_EntityID = U.IL_EntityID
	 	 
	UPDATE ProcessLog SET PL_EndTime = GetDate() WHERE PL_ID = @PL_ID2a

	INSERT INTO ProcessLog (PL_Action, PL_SubAction, PL_StartTime, PL_IF_ID, PL_EntityValue) VALUES ('sp_ProcessRemittanceAdvices','PRA.Update Header.Currency', getdate(), @IL_IF_ID, NULL)
	SELECT @PL_ID2b = SCOPE_IDENTITY()

	--Update Currency
	UPDATE RemittanceAdviceHeader
	SET RAH_CU_ID = CASE 
						WHEN LEFT(RAH_SuppNo, 3) = 'ZZU' THEN 'USD'
						ELSE 'AUD'
					END
	WHERE RAH_IF_ID = @IL_IF_ID 

	UPDATE ProcessLog SET PL_EndTime = GetDate() WHERE PL_ID = @PL_ID2b

	INSERT INTO ProcessLog (PL_Action, PL_SubAction, PL_StartTime, PL_IF_ID, PL_EntityValue) VALUES ('sp_ProcessRemittanceAdvices','PRA.Update Header.Total Amount', getdate(), @IL_IF_ID, NULL)
	SELECT @PL_ID2c = SCOPE_IDENTITY()

	--Update TotalAmountPaid
	UPDATE RAH
	SET  RAH_TotalAmountPaid = TotalPaid		
	FROM RemittanceAdviceHeader RAH
	INNER JOIN (
				SELECT IL_IF_ID
					,IL_EntityID
					,IL_EntityValue
					,CAST(dbo.fn_HandleNegatives(SUBSTRING(IL_Contents, 50, 12)) AS money) AS TotalPaid				
				FROM Importedlines
				WHERE 1 = 1
					AND IL_IF_ID = @IL_IF_ID
					AND IL_PageLineID = 64 -- Total on this line.
					AND IL_EntityType = 'Remittance Advice'
					AND IL_Contents LIKE (' Payment by%') -- Exclude pages with no total
					
				) AS U 
		 ON RAH.RAH_IF_ID = U.IL_IF_ID
		AND RAH.RAH_EntityID = U.IL_EntityID

	UPDATE ProcessLog SET PL_EndTime = GetDate() WHERE PL_ID = @PL_ID2c

	INSERT INTO ProcessLog (PL_Action, PL_SubAction, PL_StartTime, PL_IF_ID, PL_EntityValue) VALUES ('sp_ProcessRemittanceAdvices','PRA.Update Header.SuppNameAddress', getdate(), @IL_IF_ID, NULL)
	SELECT @PL_ID2d = SCOPE_IDENTITY()

--	--Get SuppNameAddress = DeliverTo addresses
	SELECT Min(IL_ID)  AS MyDeliver
		,IL_IF_ID
		,IL_EntityID
		,IL_EntityValue
		,RTRIM(SUBSTRING(IL_Contents, 12, 38)) AS DeliverTo
		INTO tmpRAHDeliverTo
	FROM Importedlines
	WHERE LTRIM(RTRIM(SUBSTRING(IL_Contents, 12, 38))) <> ''
	  AND IL_ID IN (SELECT IL_ID AS DeliverTo
					FROM Importedlines
					WHERE IL_PageLineID >= 14
						AND IL_PageLineID <= 18
						AND IL_IF_ID = @IL_IF_ID 
						AND IL_EntityType = 'Remittance Advice'
					)
	GROUP BY IL_IF_ID
		,IL_EntityID
		,IL_EntityValue
		,SUBSTRING(IL_Contents, 12, 38)
	ORDER BY Min(IL_ID)
	
	
	UPDATE RAH
	SET RAH_SuppNameAddress = CASE 
						WHEN ASCII(RIGHT(U.DeliverTo, 1)) = 10 THEN LEFT(U.DeliverTo, Len(U.DeliverTo) - 1)
						ELSE U.DeliverTo
					 END
	FROM RemittanceAdviceHeader RAH
	INNER JOIN (
		SELECT Main.IL_IF_ID
			,Main.IL_EntityID
			,LTRIM(RTRIM(Main.DeliverTo)) AS DeliverTo
		FROM (
			SELECT DISTINCT ST2.IL_IF_ID
				,ST2.IL_EntityID
				,(
					SELECT ST1.DeliverTo + CHAR(10) AS [text()]
					FROM tmpRAHDeliverTo ST1
					WHERE ST1.IL_IF_ID = ST2.IL_IF_ID
						AND ST1.IL_EntityID = ST2.IL_EntityID
					ORDER BY ST1.MyDeliver
					FOR XML PATH('')
					) DeliverTo
			FROM dbo.tmpRAHDeliverTo ST2
			) Main
		) AS U ON RAH.RAH_IF_ID = U.IL_IF_ID
		AND RAH.RAH_EntityID = U.IL_EntityID

	UPDATE ProcessLog SET PL_EndTime = GetDate() WHERE PL_ID = @PL_ID2d

	
	INSERT INTO ProcessLog (PL_Action, PL_SubAction, PL_StartTime, PL_IF_ID, PL_EntityValue) VALUES ('sp_ProcessRemittanceAdvices','PRA.Update Lines', getdate(), @IL_IF_ID, NULL)
	SELECT @PL_ID3 = SCOPE_IDENTITY()

	--Insert New Data into RAL table
	SELECT IL.IL_ID  
			,IL.IL_IF_ID
			,IL.IL_EntityID
			,IL.IL_EntityValue
			,CONVERT(date,SUBSTRING(IL_Contents,2,8), 4) AS RAL_Date
			,LTRIM(RTRIM(SUBSTRING(IL.IL_Contents,10,16))) AS RAL_TransactionTypeRef
			,LTRIM(RTRIM(SUBSTRING(IL.IL_Contents,26,12))) AS RAL_OurRef
			,0 AS RAL_IsInfo
			,dbo.fn_HandleNegatives(SUBSTRING(IL.IL_Contents,38,12)) AS RAL_TransactionValue			
			,dbo.fn_HandleNegatives(SUBSTRING(IL.IL_Contents,50,12)) AS RAL_PaymentAmount
			--,IL_Contents
			INTO tmpRemittanceAdviceLines
		FROM Importedlines IL		
		WHERE 1 = 1
		  AND LTRIM(RTRIM(IL.IL_Contents)) <> ''
		  --AND SUBSTRING(IL.IL_Contents,52,9) <> 'Continued'
		  AND LEFT(IL.IL_Contents, 85) <> SPACE(85)
		  AND IL.IL_ID IN (SELECT IL_ID
					FROM Importedlines
					WHERE IL_PageLineID >= 22
						AND IL_PageLineID <= 60
						AND IL_IF_ID = @IL_IF_ID 
						AND IL_EntityType = 'Remittance Advice'
						)
		ORDER BY IL.IL_ID
		
	INSERT INTO [dbo].[RemittanceAdviceLine] (
		RAL_RAH_ID
		,RAL_IF_ID
		,RAL_EntityID
		,RAL_Date
		,RAL_TransactionTypeRef
		,RAL_OurRef
		,RAL_IsInfo
		,RAL_TransactionValue
		,RAL_PaymentAmount)
	SELECT RAH_ID
		,RAH_IF_ID
		,RAH_EntityID
		,RAL_Date
		,RAL_TransactionTypeRef
		,RAL_OurRef
		,RAL_IsInfo		
		,CASE WHEN ISNUMERIC(RAL_TransactionValue) = 0 THEN NULL ELSE RAL_TransactionValue END 
		,CASE WHEN ISNUMERIC(RAL_PaymentAmount) = 0 THEN NULL ELSE RAL_PaymentAmount END 		 
	FROM RemittanceAdviceHeader RAH
	INNER JOIN tmpRemittanceAdviceLines RAL ON RAH_IF_ID = IL_IF_ID
		AND RAH_EntityID = IL_EntityID
	ORDER BY RAH_ID, IL_ID

	UPDATE ProcessLog SET PL_EndTime = GetDate() WHERE PL_ID = @PL_ID3

		
	--Update Report Generated Log
	UPDATE ReportGeneratedLog
	SET RG_DataExtracted = GETDATE()
	FROM ReportGeneratedLog RG 
	INNER JOIN RemittanceAdviceHeader RAH
		 ON RG.RG_IF_ID = RAH.RAH_IF_ID
		AND RG.RG_EntityID = RAH.RAH_EntityID
	WHERE RG_DataExtracted IS NULL
	--	AND RAH.RAH_IF_ID = 5
		AND RAH.RAH_IF_ID = @IL_IF_ID

	UPDATE ProcessLog SET PL_EndTime = GetDate() WHERE PL_ID = @PL_ID
END


GO

