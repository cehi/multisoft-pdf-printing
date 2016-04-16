USE [MultiSoft]
GO


-- =============================================
-- Author:		Chi Vu
-- Create date: 16/04/2016
-- Description:	Process Debtor Statement
-- =============================================
CREATE PROCEDURE [dbo].[sp_ProcessDebtorStatements] 
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

	INSERT INTO ProcessLog (PL_Action, PL_SubAction, PL_StartTime, PL_IF_ID, PL_EntityValue) VALUES ('sp_ProcessDebtorStatements',NULL, getdate(), @IL_IF_ID, NULL)
	SELECT @PL_ID = SCOPE_IDENTITY()


	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Clean up tables
	IF OBJECT_ID('dbo.tmpDSHDeliverTo', 'U') IS NOT NULL
		DROP TABLE dbo.tmpDSHDeliverTo
	IF OBJECT_ID('dbo.tmpDebtorStatementLines', 'U') IS NOT NULL
		DROP TABLE dbo.tmpDebtorStatementLines
	IF OBJECT_ID('dbo.tmpDSHNewDuplicates', 'U') IS NOT NULL
		DROP TABLE dbo.tmpDSHNewDuplicates

	INSERT INTO ProcessLog (PL_Action, PL_SubAction, PL_StartTime, PL_IF_ID, PL_EntityValue) VALUES ('sp_ProcessDebtorStatements','PRA.Move Duplicates To History', getdate(), @IL_IF_ID, NULL)
	SELECT @PL_ID1 = SCOPE_IDENTITY()
	
	SELECT DISTINCT DSH_ID
	INTO tmpDSHNewDuplicates
	FROM ImportedLines IL
	INNER JOIN DebtorStatementHeader DSH 
		ON IL.IL_EntityValue = DSH.DSH_EntityValue
	WHERE IL_IF_ID = @IL_IF_ID

	-- Move any Duplicates to History
	INSERT INTO DebtorStatementLineHistory (
		DSLH_RAL_ID
		,DSLH_DSH_ID
		,DSLH_IF_ID
		,DSLH_EntityID
		,DSLH_Date
		,DSLH_References
		,DSLH_OurRef
		,DSLH_IsInfo		
		,DSLH_TransactionValue
		,DSLH_PaymentAmount		
		)
	SELECT RAL_ID
		,RAL_DSH_ID
		,RAL_IF_ID
		,RAL_EntityID
		,RAL_Date
		,RAL_TransactionTypeRef
		,RAL_OurRef
		,RAL_IsInfo		
		,RAL_TransactionValue
		,RAL_PaymentAmount
	FROM DebtorStatementLine
	WHERE RAL_DSH_ID IN (SELECT DSH_ID FROM tmpDSHNewDuplicates)

	DELETE FROM DebtorStatementLine
	WHERE RAL_DSH_ID IN (SELECT DSH_ID FROM tmpDSHNewDuplicates)

	INSERT INTO DebtorStatementHeaderHistory (
		DSHH_DSH_ID
		,DSHH_EntityValue
		,DSHH_IF_ID
		,DSHH_EntityID
		,DSHH_IsSecure
		,DSHH_SuppNo
		,DSHH_SuppNameAddress
		,DSHH_TotalAmountPaid
		,DSHH_PrintDate
		)
	SELECT DSH_ID
		,DSH_EntityValue
		,DSH_IF_ID
		,DSH_EntityID
		,DSH_IsSecure
		,DSH_SuppNo
		,DSH_SuppNameAddress
		,DSH_TotalAmountPaid
		,DSH_PrintDate
	FROM DebtorStatementHeader
	WHERE DSH_ID IN (SELECT DSH_ID FROM tmpDSHNewDuplicates)

	UPDATE ReportGeneratedLog
	SET RG_Replaced = 1
	FROM ReportGeneratedLog R
	INNER JOIN (SELECT DSH_IF_ID
				,DSH_EntityID
				FROM DebtorStatementHeader
				WHERE DSH_ID in (SELECT DSH_ID FROM tmpDSHNewDuplicates)) H
	  ON R.RG_IF_ID = H.DSH_IF_ID
	 AND R.RG_EntityID = H.DSH_EntityID

	DELETE FROM DebtorStatementHeader
	WHERE DSH_ID IN (SELECT DSH_ID FROM tmpDSHNewDuplicates)

	UPDATE ProcessLog SET PL_EndTime = GetDate() WHERE PL_ID = @PL_ID1

	INSERT INTO ProcessLog (PL_Action, PL_SubAction, PL_StartTime, PL_IF_ID, PL_EntityValue) VALUES ('sp_ProcessDebtorStatements','PRA.Update Header', getdate(), @IL_IF_ID, NULL)
	SELECT @PL_ID2 = SCOPE_IDENTITY()

	--Insert DebtorStatement Stub
	INSERT INTO DebtorStatementHeader (
		 DSH_EntityValue
		,DSH_IF_ID
		,DSH_EntityID
		,DSH_IsSecure
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


	INSERT INTO ProcessLog (PL_Action, PL_SubAction, PL_StartTime, PL_IF_ID, PL_EntityValue) VALUES ('sp_ProcessDebtorStatements','PRA.Update Header.SuppNo-PrintDate', getdate(), @IL_IF_ID, NULL)
	SELECT @PL_ID2a = SCOPE_IDENTITY()

	--Update SuppNo and PrintDate
	UPDATE DSH
	SET DSH_SuppNo = SuppNo	  
	FROM DebtorStatementHeader DSH
	INNER JOIN (SELECT IL_IF_ID, IL_EntityID, IL_EntityValue
					,LTRIM(RTRIM(SUBSTRING(IL_Contents,50,8))) AS SuppNo
					
				FROM Importedlines
				WHERE 1 = 1
				  AND IL_PageLineID = 14
				  AND IL_IF_ID = @IL_IF_ID
				  AND IL_EntityType = 'Remittance Advice'
			   ) AS U
	  ON DSH.DSH_IF_ID = U.IL_IF_ID
	 AND DSH.DSH_EntityID = U.IL_EntityID

	UPDATE DSH
	SET DSH_PrintDate = PrintDate	  
	FROM DebtorStatementHeader DSH
	INNER JOIN (SELECT IL_IF_ID, IL_EntityID, IL_EntityValue
					,CONVERT(date,SUBSTRING(IL_Contents,2,8), 4) AS PrintDate
				FROM Importedlines
				WHERE 1 = 1
				  AND IL_PageLineID = 19
				  AND IL_IF_ID = @IL_IF_ID
				  AND IL_EntityType = 'Remittance Advice'
			   ) AS U
	  ON DSH.DSH_IF_ID = U.IL_IF_ID
	 AND DSH.DSH_EntityID = U.IL_EntityID
	 	 
	UPDATE ProcessLog SET PL_EndTime = GetDate() WHERE PL_ID = @PL_ID2a

	INSERT INTO ProcessLog (PL_Action, PL_SubAction, PL_StartTime, PL_IF_ID, PL_EntityValue) VALUES ('sp_ProcessDebtorStatements','PRA.Update Header.Currency', getdate(), @IL_IF_ID, NULL)
	SELECT @PL_ID2b = SCOPE_IDENTITY()

	--Update Currency
	UPDATE DebtorStatementHeader
	SET DSH_CU_ID = CASE 
						WHEN LEFT(DSH_SuppNo, 3) = 'ZZU' THEN 'USD'
						ELSE 'AUD'
					END
	WHERE DSH_IF_ID = @IL_IF_ID 

	UPDATE ProcessLog SET PL_EndTime = GetDate() WHERE PL_ID = @PL_ID2b

	INSERT INTO ProcessLog (PL_Action, PL_SubAction, PL_StartTime, PL_IF_ID, PL_EntityValue) VALUES ('sp_ProcessDebtorStatements','PRA.Update Header.Total Amount', getdate(), @IL_IF_ID, NULL)
	SELECT @PL_ID2c = SCOPE_IDENTITY()

	--Update TotalAmountPaid
	UPDATE DSH
	SET  DSH_TotalAmountPaid = TotalPaid		
	FROM DebtorStatementHeader DSH
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
		 ON DSH.DSH_IF_ID = U.IL_IF_ID
		AND DSH.DSH_EntityID = U.IL_EntityID

	UPDATE ProcessLog SET PL_EndTime = GetDate() WHERE PL_ID = @PL_ID2c

	INSERT INTO ProcessLog (PL_Action, PL_SubAction, PL_StartTime, PL_IF_ID, PL_EntityValue) VALUES ('sp_ProcessDebtorStatements','PRA.Update Header.SuppNameAddress', getdate(), @IL_IF_ID, NULL)
	SELECT @PL_ID2d = SCOPE_IDENTITY()

--	--Get SuppNameAddress = DeliverTo addresses
	SELECT Min(IL_ID)  AS MyDeliver
		,IL_IF_ID
		,IL_EntityID
		,IL_EntityValue
		,RTRIM(SUBSTRING(IL_Contents, 12, 38)) AS DeliverTo
		INTO tmpDSHDeliverTo
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
	
	
	UPDATE DSH
	SET DSH_SuppNameAddress = CASE 
						WHEN ASCII(RIGHT(U.DeliverTo, 1)) = 10 THEN LEFT(U.DeliverTo, Len(U.DeliverTo) - 1)
						ELSE U.DeliverTo
					 END
	FROM DebtorStatementHeader DSH
	INNER JOIN (
		SELECT Main.IL_IF_ID
			,Main.IL_EntityID
			,LTRIM(RTRIM(Main.DeliverTo)) AS DeliverTo
		FROM (
			SELECT DISTINCT ST2.IL_IF_ID
				,ST2.IL_EntityID
				,(
					SELECT ST1.DeliverTo + CHAR(10) AS [text()]
					FROM tmpDSHDeliverTo ST1
					WHERE ST1.IL_IF_ID = ST2.IL_IF_ID
						AND ST1.IL_EntityID = ST2.IL_EntityID
					ORDER BY ST1.MyDeliver
					FOR XML PATH('')
					) DeliverTo
			FROM dbo.tmpDSHDeliverTo ST2
			) Main
		) AS U ON DSH.DSH_IF_ID = U.IL_IF_ID
		AND DSH.DSH_EntityID = U.IL_EntityID

	UPDATE ProcessLog SET PL_EndTime = GetDate() WHERE PL_ID = @PL_ID2d

	
	INSERT INTO ProcessLog (PL_Action, PL_SubAction, PL_StartTime, PL_IF_ID, PL_EntityValue) VALUES ('sp_ProcessDebtorStatements','PRA.Update Lines', getdate(), @IL_IF_ID, NULL)
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
			INTO tmpDebtorStatementLines
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
		
	INSERT INTO [dbo].[DebtorStatementLine] (
		RAL_DSH_ID
		,RAL_IF_ID
		,RAL_EntityID
		,RAL_Date
		,RAL_TransactionTypeRef
		,RAL_OurRef
		,RAL_IsInfo
		,RAL_TransactionValue
		,RAL_PaymentAmount)
	SELECT DSH_ID
		,DSH_IF_ID
		,DSH_EntityID
		,RAL_Date
		,RAL_TransactionTypeRef
		,RAL_OurRef
		,RAL_IsInfo		
		,CASE WHEN ISNUMERIC(RAL_TransactionValue) = 0 THEN NULL ELSE RAL_TransactionValue END 
		,CASE WHEN ISNUMERIC(RAL_PaymentAmount) = 0 THEN NULL ELSE RAL_PaymentAmount END 		 
	FROM DebtorStatementHeader DSH
	INNER JOIN tmpDebtorStatementLines RAL ON DSH_IF_ID = IL_IF_ID
		AND DSH_EntityID = IL_EntityID
	ORDER BY DSH_ID, IL_ID

	UPDATE ProcessLog SET PL_EndTime = GetDate() WHERE PL_ID = @PL_ID3

		
	--Update Report Generated Log
	UPDATE ReportGeneratedLog
	SET RG_DataExtracted = GETDATE()
	FROM ReportGeneratedLog RG 
	INNER JOIN DebtorStatementHeader DSH
		 ON RG.RG_IF_ID = DSH.DSH_IF_ID
		AND RG.RG_EntityID = DSH.DSH_EntityID
	WHERE RG_DataExtracted IS NULL
	--	AND DSH.DSH_IF_ID = 5
		AND DSH.DSH_IF_ID = @IL_IF_ID

	UPDATE ProcessLog SET PL_EndTime = GetDate() WHERE PL_ID = @PL_ID
END

