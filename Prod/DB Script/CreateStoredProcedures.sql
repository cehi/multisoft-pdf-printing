USE [MultiSoft]
GO
/****** Object:  StoredProcedure [dbo].[sp_ProcessDebtorStatements]    Script Date: 21/04/2016 7:55:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
	DECLARE @PL_ID2e AS int
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
		DSLH_DSL_ID
		,DSLH_DSH_ID
		,DSLH_IF_ID
		,DSLH_EntityID
		,DSLH_Date
		,DSLH_References
		,DSLH_IsBroughtForward
		,DSLH_IsInfo		
		,DSLH_TransactionValue
		,DSLH_PaymentAmount		
		)
	SELECT DSL_ID
		,DSL_DSH_ID
		,DSL_IF_ID
		,DSL_EntityID
		,DSL_Date
		,DSL_References
		,DSL_IsBroughtForward
		,DSL_IsInfo		
		,DSL_TransactionValue
		,DSL_PaymentAmount
	FROM DebtorStatementLine
	WHERE DSL_DSH_ID IN (SELECT DSH_ID FROM tmpDSHNewDuplicates)

	DELETE FROM DebtorStatementLine
	WHERE DSL_DSH_ID IN (SELECT DSH_ID FROM tmpDSHNewDuplicates)

	INSERT INTO DebtorStatementHeaderHistory (
		DSHH_DSH_ID
		,DSHH_EntityValue
		,DSHH_IF_ID
		,DSHH_EntityID
		,DSHH_IsSecure
		,DSHH_CU_ID
		,DSHH_AccountNo
		,DSHH_StatementDate
		,DSHH_CustomerNameAddress
		,DSHH_AccountBalance
		,DSHH_3MonthsBalance
		,DSHH_2MonthsBalance
		,DSHH_1MonthBalance
		,DSHH_CurrentBalance
		,DSHH_UnallocatedCash
		)
	SELECT DSH_ID
		,DSH_EntityValue
		,DSH_IF_ID
		,DSH_EntityID
		,DSH_IsSecure
		,DSH_CU_ID
		,DSH_AccountNo
		,DSH_StatementDate
		,DSH_CustomerNameAddress
		,DSH_AccountBalance
		,DSH_3MonthsBalance
		,DSH_2MonthsBalance
		,DSH_1MonthBalance
		,DSH_CurrentBalance
		,DSH_UnallocatedCash
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

	INSERT INTO ProcessLog (PL_Action, PL_SubAction, PL_StartTime, PL_IF_ID, PL_EntityValue) VALUES ('sp_ProcessDebtorStatements','PDS.UpdateHeader', getdate(), @IL_IF_ID, NULL)
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
		AND IL_EntityType = 'Debtor Statement'
	ORDER BY IL_EntityValue

	UPDATE ProcessLog SET PL_EndTime = GetDate() WHERE PL_ID = @PL_ID2


	INSERT INTO ProcessLog (PL_Action, PL_SubAction, PL_StartTime, PL_IF_ID, PL_EntityValue) VALUES ('sp_ProcessDebtorStatements','PDS.UpdateHeader.SuppNo-PrintDate', getdate(), @IL_IF_ID, NULL)
	SELECT @PL_ID2a = SCOPE_IDENTITY()

	--Update AccountNo and StatementDate
	UPDATE DSH
	SET DSH_AccountNo = AccNo	  
	FROM DebtorStatementHeader DSH
	INNER JOIN (SELECT IL_IF_ID, IL_EntityID, IL_EntityValue
					,LTRIM(RTRIM(SUBSTRING(IL_Contents,50,8))) AS AccNo
					
				FROM Importedlines
				WHERE 1 = 1
				  AND IL_PageLineID = 14
				  AND IL_IF_ID = @IL_IF_ID
				  AND IL_EntityType = 'Debtor Statement'
			   ) AS U
	  ON DSH.DSH_IF_ID = U.IL_IF_ID
	 AND DSH.DSH_EntityID = U.IL_EntityID

	UPDATE DSH
	SET DSH_StatementDate = StatementDate	  
	FROM DebtorStatementHeader DSH
	INNER JOIN (SELECT IL_IF_ID, IL_EntityID, IL_EntityValue
					,CONVERT(date,SUBSTRING(IL_Contents,2,8), 4) AS StatementDate
				FROM Importedlines
				WHERE 1 = 1
				  AND IL_PageLineID = 19
				  AND IL_IF_ID = @IL_IF_ID
				  AND IL_EntityType = 'Debtor Statement'
			   ) AS U
	  ON DSH.DSH_IF_ID = U.IL_IF_ID
	 AND DSH.DSH_EntityID = U.IL_EntityID
	 	 
	UPDATE ProcessLog SET PL_EndTime = GetDate() WHERE PL_ID = @PL_ID2a

	INSERT INTO ProcessLog (PL_Action, PL_SubAction, PL_StartTime, PL_IF_ID, PL_EntityValue) VALUES ('sp_ProcessDebtorStatements','PDS.UpdateHeader.Currency', getdate(), @IL_IF_ID, NULL)
	SELECT @PL_ID2b = SCOPE_IDENTITY()

	--Update Currency
	UPDATE DebtorStatementHeader
	SET DSH_CU_ID = CASE 
						WHEN LEFT(DSH_AccountNo, 3) = 'ZZU' THEN 'USD'
						ELSE 'AUD'
					END
	WHERE DSH_IF_ID = @IL_IF_ID 

	UPDATE ProcessLog SET PL_EndTime = GetDate() WHERE PL_ID = @PL_ID2b

	INSERT INTO ProcessLog (PL_Action, PL_SubAction, PL_StartTime, PL_IF_ID, PL_EntityValue) VALUES ('sp_ProcessDebtorStatements','PDS.UpdateHeader.AmountDue', getdate(), @IL_IF_ID, NULL)
	SELECT @PL_ID2c = SCOPE_IDENTITY()

	--Update Account Balance
	UPDATE DSH
	SET  DSH_AccountBalance = AmountDue		
	FROM DebtorStatementHeader DSH
	INNER JOIN (
				SELECT IL.IL_IF_ID
					,IL.IL_EntityID
					,IL.IL_EntityValue
					,CAST(dbo.fn_HandleNegatives(SUBSTRING(IL.IL_Contents, 50, 12)) AS money) AS AmountDue				
				FROM Importedlines IL
					--INNER JOIN ImportedLines B
					--ON		IL.IL_IF_ID = B.Il_IF_ID
					--	AND IL.IL_PageID = B.IL_PageID					
				WHERE 1 = 1
					AND IL.IL_IF_ID = @IL_IF_ID
					--AND B.IL_PageLineID = 53  
					--AND B.IL_Contents LIKE ('%AMOUNT DUE%') -- Exclude pages with no total

					AND IL.IL_PageLineID = 55 -- Amount due on this line
					AND LTRIM(RTRIM(IL.IL_Contents)) <> '' -- -- Exclude pages with no total
					AND IL.IL_EntityType = 'Debtor Statement'
										
				) AS U 
		 ON DSH.DSH_IF_ID = U.IL_IF_ID
		AND DSH.DSH_EntityID = U.IL_EntityID

	UPDATE ProcessLog SET PL_EndTime = GetDate() WHERE PL_ID = @PL_ID2c

	INSERT INTO ProcessLog (PL_Action, PL_SubAction, PL_StartTime, PL_IF_ID, PL_EntityValue) VALUES ('sp_ProcessDebtorStatements','PDS.UpdateHeader.OverdueAccounts', getdate(), @IL_IF_ID, NULL)
	SELECT @PL_ID2d = SCOPE_IDENTITY()

	--Update Overdue Accounts
	UPDATE DSH
	SET  DSH_3MonthsBalance = [3MBalance]
		,DSH_2MonthsBalance = [2MBalance]
		,DSH_1MonthBalance = [1MBalance]
		,DSH_CurrentBalance = CurrentBalance
		,DSH_UnallocatedCash = UnallocatedAmount
	FROM DebtorStatementHeader DSH
	INNER JOIN (
				SELECT IL.IL_IF_ID
					,IL.IL_EntityID
					,IL.IL_EntityValue
					,CAST(dbo.fn_HandleNegatives(SUBSTRING(IL.IL_Contents, 1, 12)) AS money) AS [3MBalance]	
					,CAST(dbo.fn_HandleNegatives(SUBSTRING(IL.IL_Contents, 13, 12)) AS money) AS [2MBalance]				
					,CAST(dbo.fn_HandleNegatives(SUBSTRING(IL.IL_Contents, 25, 12)) AS money) AS [1MBalance]				
					,CAST(dbo.fn_HandleNegatives(SUBSTRING(IL.IL_Contents, 37, 12)) AS money) AS CurrentBalance				
					,CAST(dbo.fn_HandleNegatives(SUBSTRING(IL.IL_Contents, 49, 12)) AS money) AS UnallocatedAmount						
				FROM Importedlines IL
					--INNER JOIN ImportedLines B
					--ON		IL.IL_IF_ID = B.Il_IF_ID
					--	AND IL.IL_PageID = B.IL_PageID					
				WHERE 1 = 1
					AND IL.IL_IF_ID = @IL_IF_ID
					--AND B.IL_PageLineID = 53  
					--AND B.IL_Contents LIKE ('%AMOUNT DUE%') -- Exclude pages with no total	

					AND IL.IL_PageLineID = 64 -- Overdue amounts on this line									
					AND LTRIM(RTRIM(IL.IL_Contents)) <> '' --  Exclude pages with no total
					AND IL.IL_EntityType = 'Debtor Statement'
				) AS U 
		 ON DSH.DSH_IF_ID = U.IL_IF_ID
		AND DSH.DSH_EntityID = U.IL_EntityID

	UPDATE ProcessLog SET PL_EndTime = GetDate() WHERE PL_ID = @PL_ID2d


	INSERT INTO ProcessLog (PL_Action, PL_SubAction, PL_StartTime, PL_IF_ID, PL_EntityValue) VALUES ('sp_ProcessDebtorStatements','PDS.UpdateHeader.CustomerNameAddress', getdate(), @IL_IF_ID, NULL)
	SELECT @PL_ID2e = SCOPE_IDENTITY()

--	--Get CustomerNameAddress = DeliverTo addresses
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
						AND IL_EntityType = 'Debtor Statement'
					)
	GROUP BY IL_IF_ID
		,IL_EntityID
		,IL_EntityValue
		,SUBSTRING(IL_Contents, 12, 38)
	ORDER BY Min(IL_ID)
	
	
	UPDATE DSH
	SET DSH_CustomerNameAddress = CASE 
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

	UPDATE ProcessLog SET PL_EndTime = GetDate() WHERE PL_ID = @PL_ID2e

	
	INSERT INTO ProcessLog (PL_Action, PL_SubAction, PL_StartTime, PL_IF_ID, PL_EntityValue) VALUES ('sp_ProcessDebtorStatements','PDS.UpdateLines', getdate(), @IL_IF_ID, NULL)
	SELECT @PL_ID3 = SCOPE_IDENTITY()

	--Insert New Data into RAL table
	SELECT IL.IL_ID  
			,IL.IL_IF_ID
			,IL.IL_EntityID
			,IL.IL_EntityValue
			,CONVERT(date,SUBSTRING(IL.IL_Contents,2,8), 4) AS DSL_Date
			,LTRIM(RTRIM(SUBSTRING(IL.IL_Contents,10,28))) AS DSL_References
			,LTRIM(RTRIM(SUBSTRING(IL.IL_Contents,26,12))) AS DSL_OurRef
			,CASE 
				WHEN LEFT(LTRIM(IL.IL_Contents),15) = 'Brought Forward' THEN 1
				ELSE 0
			 END AS DSL_IsBroughtForward
			,0 AS DSL_IsInfo
			,dbo.fn_HandleNegatives(SUBSTRING(IL.IL_Contents,38,12)) AS DSL_TransactionValue			
			,dbo.fn_HandleNegatives(SUBSTRING(IL.IL_Contents,50,12)) AS DSL_PaymentAmount
			
			INTO tmpDebtorStatementLines
		FROM Importedlines IL		
		WHERE 1 = 1
		  AND LTRIM(RTRIM(IL.IL_Contents)) <> ''
		  AND LTRIM(RTRIM(IL.IL_Contents)) <> '----------'
		  AND LTRIM(RTRIM(IL.IL_Contents)) <> '=========='		  
		  AND LEFT(IL.IL_Contents, 85) <> SPACE(85)
		  AND IL.IL_ID IN (SELECT IL_ID
					FROM Importedlines
					WHERE IL_PageLineID >= 22
						AND IL_PageLineID <= 50
						AND IL_IF_ID = @IL_IF_ID 
						AND IL_EntityType = 'Debtor Statement'
						)
		ORDER BY IL.IL_ID
		
	INSERT INTO [dbo].[DebtorStatementLine] (
		DSL_DSH_ID
		,DSL_IF_ID
		,DSL_EntityID
		,DSL_Date
		,DSL_References
		,DSL_IsBroughtForward
		,DSL_IsInfo
		,DSL_TransactionValue
		,DSL_PaymentAmount)
	SELECT DSH_ID
		,DSH_IF_ID
		,DSH_EntityID
		,CASE WHEN DSL_Date = '1900-01-01' THEN NULL ELSE DSL_Date END
		,DSL_References
		,DSL_IsBroughtForward
		,DSL_IsInfo		
		,CASE WHEN ISNUMERIC(DSL_TransactionValue) = 0 THEN NULL ELSE DSL_TransactionValue END 
		,CASE WHEN ISNUMERIC(DSL_PaymentAmount) = 0 THEN NULL ELSE DSL_PaymentAmount END 		 
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


GO
/****** Object:  StoredProcedure [dbo].[sp_ProcessRemittanceAdvices]    Script Date: 21/04/2016 7:55:52 PM ******/
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
		,RAHH_CU_ID
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
		,RAH_CU_ID
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

	--Insert New Data into RAL table: 38 lines/page
	SELECT IL.IL_ID  
			,IL.IL_IF_ID
			,IL.IL_EntityID
			,IL.IL_EntityValue
			,CONVERT(date,SUBSTRING(IL.IL_Contents,2,8), 4) AS RAL_Date
			,LTRIM(RTRIM(SUBSTRING(IL.IL_Contents,10,16))) AS RAL_TransactionTypeRef
			,LTRIM(RTRIM(SUBSTRING(IL.IL_Contents,26,12))) AS RAL_OurRef
			,0 AS RAL_IsInfo
			,dbo.fn_HandleNegatives(SUBSTRING(IL.IL_Contents,38,12)) AS RAL_TransactionValue			
			,dbo.fn_HandleNegatives(SUBSTRING(IL.IL_Contents,50,12)) AS RAL_PaymentAmount
			
			INTO tmpRemittanceAdviceLines
		FROM Importedlines IL		
		WHERE 1 = 1
		  AND LTRIM(RTRIM(IL.IL_Contents)) <> ''
		  --AND SUBSTRING(IL.IL_Contents,52,9) <> 'Continued'
		  AND LEFT(IL.IL_Contents, 85) <> SPACE(85)
		  AND IL.IL_ID IN (SELECT IL_ID
					FROM Importedlines
					WHERE IL_PageLineID >= 22
						AND IL_PageLineID <= 59
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
		,CASE WHEN RAL_Date = '1900-01-01' THEN NULL ELSE RAL_Date END
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
/****** Object:  StoredProcedure [dbo].[sp_TimerDebtorStatements]    Script Date: 21/04/2016 7:55:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_TimerDebtorStatements] AS
BEGIN
	
    DECLARE @ReturnCode BIT
    SET @ReturnCode = 0        
     
    BEGIN TRY    
                         
		--check if the temp exists. if it exists it means another instance of SP is running, raise an error and exit                           
		IF object_id('tempdb.dbo.##gsp_TimerDebtorStatements') IS NOT NULL
		BEGIN
			SET @ReturnCode = 0 --global table already exists. not created
			RAISERROR ( 'Unable to acquire exclusive Lock on sp_TimerDebtorStatements', 16, 1 )
			RETURN
		END
     
		--Create a temporary global table      
		CREATE TABLE ##gsp_TimerDebtorStatements (id INT )
		SET @ReturnCode = 1 --global table created in this instance
	    
		--Create PDFs
		DECLARE @FALocal as varchar(255)
		DECLARE @FADest as varchar(255)
		

		SELECT @FALocal = CF_Value FROM ConfigValues WHERE CF_Item = 'Folder_DebtorStatements_Local'
		SELECT @FADest = CF_Value FROM ConfigValues WHERE CF_Item = 'Folder_DebtorStatements_Destination'
		
		
		DECLARE myDSCursor CURSOR
		READ_ONLY
		FOR	SELECT TOP 5 DSH.DSH_EntityValue AS PON				
				,    'Debtor Statement '
					 + DSH.DSH_EntityValue 					 
					 + '.pdf' AS FileName
				,@FALocal AS LocalPath
				,@FADest AS Path				
				,RG.RG_IF_ID
				,RG.RG_EntityID
				,RG.RG_IF_Date
				,CASE 
					WHEN RG.RG_ID = LOB.LastOfBatch THEN 1
					ELSE 0
				END AS LastOfbatch
			FROM ReportGeneratedLog RG 
			INNER JOIN DebtorStatementHeader DSH
					ON RG.RG_IF_ID = DSH.DSH_IF_ID
				AND RG.RG_EntityID = DSH.DSH_EntityID
			LEFT OUTER JOIN 
				(SELECT RG_IF_ID
					,Max(RG_ID) AS LastOfBatch
				FROM ReportGeneratedLog
				WHERE 1 = 1
				  AND RG_PDFGenerated IS NULL
				  AND RG_Replaced = 0
				GROUP BY RG_IF_ID) AS LOB
				ON RG.RG_IF_ID = LOB.RG_IF_ID 
			WHERE 1 = 1
				AND RG_PDFGenerated IS NULL
				AND RG.RG_EntityType = 'Debtor Statement'
				AND RG.RG_IsSecure = 0
			ORDER BY RG.RG_ID, RG.RG_EntityID, RG.RG_DataExtracted

		DECLARE @PON AS varchar(255)
		DECLARE @Filename AS varchar(255)
		DECLARE @LocalPath as varchar(255)
		DECLARE @Path as varchar(255)		
		DECLARE @IF_ID as int
		DECLARE @EntityID as int
		DECLARE @pDate as datetime
		DECLARE @LastOfBatch as bit
		
		OPEN myDSCursor

		FETCH NEXT FROM myDSCursor INTO @PON, @FileName, @LocalPath, @Path, @IF_ID, @EntityID, @pDate, @LastOfBatch
		WHILE (@@fetch_status <> -1)
		BEGIN
			IF (@@fetch_status <> -2)
			BEGIN
				--PRINT @PON + @FileName + @Path
				EXEC dbo.sp_WritePDF @PON, @FileName, @LocalPath, @Path, 'GenerateDSPDF.rss'
				
				--BEGIN TRANSACTION URGL
				UPDATE ReportGeneratedLog
				SET RG_PDFGenerated = GetDate()
				,RG_PDFFileName = @FileName
				WHERE RG_IF_ID = @IF_ID 
				  AND RG_EntityID = @EntityID
				--WAITFOR DELAY '00:00:01';

				--IF @LastOfBatch = 1
				--BEGIN
					--EXEC dbo.sp_CreateBatchEnd @Path, @pDate, @IF_ID
					--EXEC dbo.sp_CreateBatchPDF @FALocal, @FADest, @IF_ID, @pDate, 0
										
				--END
			END
			FETCH NEXT FROM myDSCursor INTO @PON, @FileName, @LocalPath, @Path, @IF_ID, @EntityID, @pDate, @LastOfBatch
		END

		CLOSE myDSCursor
		DEALLOCATE myDSCursor

	   -- processing is completed. drop the temporary table
	    DROP TABLE ##gsp_TimerDebtorStatements
     
    END TRY     
    BEGIN CATCH
         
        --if the sp fails for some other reason and the table is already created drop it
        IF object_id('tempdb.dbo.##gsp_TimerDebtorStatements') IS NOT NULL AND @ReturnCode = 1
        BEGIN
            DROP TABLE ##gsp_TimerDebtorStatements
        END
     
        DECLARE @ErrMsg VARCHAR(4000)
        SELECT @ErrMsg = ERROR_MESSAGE()       
        RAISERROR(@ErrMsg, 15, 50)       
     
    END CATCH         

END

GO
/****** Object:  StoredProcedure [dbo].[sp_TimerRemittanceAdvices]    Script Date: 21/04/2016 7:55:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_TimerRemittanceAdvices] AS
BEGIN
	
    DECLARE @ReturnCode BIT
    SET @ReturnCode = 0        
     
    BEGIN TRY    
                         
		--check if the temp exists. if it exists it means another instance of SP is running, raise an error and exit                           
		IF object_id('tempdb.dbo.##gsp_TimerRemittanceAdvices') IS NOT NULL
		BEGIN
			SET @ReturnCode = 0 --global table already exists. not created
			RAISERROR ( 'Unable to acquire exclusive Lock on sp_TimerRemittanceAdvices', 16, 1 )
			RETURN
		END
     
		--Create a temporary global table      
		CREATE TABLE ##gsp_TimerRemittanceAdvices (id INT )
		SET @ReturnCode = 1 --global table created in this instance
	    
		--Create PDFs
		DECLARE @FALocal as varchar(255)
		DECLARE @FADest as varchar(255)
		

		SELECT @FALocal = CF_Value FROM ConfigValues WHERE CF_Item = 'Folder_RemittanceAdvices_Local'
		SELECT @FADest = CF_Value FROM ConfigValues WHERE CF_Item = 'Folder_RemittanceAdvices_Destination'
		
		
		DECLARE myRACursor CURSOR
		READ_ONLY
		FOR	SELECT TOP 5 RAH.RAH_EntityValue AS PON				
				,    'Remittance Advice '
					 + RAH.RAH_EntityValue 					 
					 + '.pdf' AS FileName
				,@FALocal AS LocalPath
				,@FADest AS Path				
				,RG.RG_IF_ID
				,RG.RG_EntityID
				,RG.RG_IF_Date
				,CASE 
					WHEN RG.RG_ID = LOB.LastOfBatch THEN 1
					ELSE 0
				END AS LastOfbatch
			FROM ReportGeneratedLog RG 
			INNER JOIN RemittanceAdviceHeader RAH
					ON RG.RG_IF_ID = RAH.RAH_IF_ID
				AND RG.RG_EntityID = RAH.RAH_EntityID
			LEFT OUTER JOIN 
				(SELECT RG_IF_ID
					,Max(RG_ID) AS LastOfBatch
				FROM ReportGeneratedLog
				WHERE 1 = 1
				  AND RG_PDFGenerated IS NULL
				  AND RG_Replaced = 0
				GROUP BY RG_IF_ID) AS LOB
				ON RG.RG_IF_ID = LOB.RG_IF_ID 
			WHERE 1 = 1
				AND RG_PDFGenerated IS NULL
				AND RG.RG_EntityType = 'Remittance Advice'
				AND RG.RG_IsSecure = 0
			ORDER BY RG.RG_ID, RG.RG_EntityID, RG.RG_DataExtracted

		DECLARE @PON AS varchar(255)
		DECLARE @Filename AS varchar(255)
		DECLARE @LocalPath as varchar(255)
		DECLARE @Path as varchar(255)		
		DECLARE @IF_ID as int
		DECLARE @EntityID as int
		DECLARE @pDate as datetime
		DECLARE @LastOfBatch as bit
		
		OPEN myRACursor

		FETCH NEXT FROM myRACursor INTO @PON, @FileName, @LocalPath, @Path, @IF_ID, @EntityID, @pDate, @LastOfBatch
		WHILE (@@fetch_status <> -1)
		BEGIN
			IF (@@fetch_status <> -2)
			BEGIN
				--PRINT @PON + @FileName + @Path
				EXEC dbo.sp_WritePDF @PON, @FileName, @LocalPath, @Path, 'GenerateRAPDF.rss'
				
				--BEGIN TRANSACTION URGL
				UPDATE ReportGeneratedLog
				SET RG_PDFGenerated = GetDate()
				,RG_PDFFileName = @FileName
				WHERE RG_IF_ID = @IF_ID 
				  AND RG_EntityID = @EntityID
				--WAITFOR DELAY '00:00:01';

				--IF @LastOfBatch = 1
				--BEGIN
					--EXEC dbo.sp_CreateBatchEnd @Path, @pDate, @IF_ID
					--EXEC dbo.sp_CreateBatchPDF @FALocal, @FADest, @IF_ID, @pDate, 0
										
				--END
			END
			FETCH NEXT FROM myRACursor INTO @PON, @FileName, @LocalPath, @Path, @IF_ID, @EntityID, @pDate, @LastOfBatch
		END

		CLOSE myRACursor
		DEALLOCATE myRACursor

	   -- processing is completed. drop the temporary table
	    DROP TABLE ##gsp_TimerRemittanceAdvices
     
    END TRY     
    BEGIN CATCH
         
        --if the sp fails for some other reason and the table is already created drop it
        IF object_id('tempdb.dbo.##gsp_TimerRemittanceAdvices') IS NOT NULL AND @ReturnCode = 1
        BEGIN
            DROP TABLE ##gsp_TimerRemittanceAdvices
        END
     
        DECLARE @ErrMsg VARCHAR(4000)
        SELECT @ErrMsg = ERROR_MESSAGE()       
        RAISERROR(@ErrMsg, 15, 50)       
     
    END CATCH         

END

GO

/****** Object:  StoredProcedure [dbo].[sp_TimerActivatedDebtorStatements]    Script Date: 21/04/2016 7:55:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[sp_TimerActivatedDebtorStatements] AS
begin
	declare @mt sysname, @h uniqueidentifier;
	--begin transaction TAPO;
		receive top (1)
			@mt = message_type_name
			, @h = conversation_handle
			from TimersDebtorStatement;

		if @@rowcount = 0
		begin
			--commit transaction TAPO;
			return;
		end

		if @mt in (N'http://schemas.microsoft.com/SQL/ServiceBroker/Error'
			, N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog')
		begin
			end conversation @h;
		end
		else if @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/DialogTimer'
		begin
			exec dbo.sp_TimerDebtorStatements
			-- set a new timer after 5s
			-- Can take many seconds to run this SP, but SP wont do work again if already running. Check SP
			begin conversation timer (@h) timeout = 5;
		end
	--commit transaction TAPO;
end



GO
/****** Object:  StoredProcedure [dbo].[sp_TimerActivatedRemittanceAdvices]    Script Date: 21/04/2016 7:55:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[sp_TimerActivatedRemittanceAdvices] AS
begin
	declare @mt sysname, @h uniqueidentifier;
	--begin transaction TAPO;
		receive top (1)
			@mt = message_type_name
			, @h = conversation_handle
			from TimersRemittanceAdvice;

		if @@rowcount = 0
		begin
			--commit transaction TAPO;
			return;
		end

		if @mt in (N'http://schemas.microsoft.com/SQL/ServiceBroker/Error'
			, N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog')
		begin
			end conversation @h;
		end
		else if @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/DialogTimer'
		begin
			exec dbo.sp_TimerRemittanceAdvices
			-- set a new timer after 5s
			-- Can take many seconds to run this SP, but SP wont do work again if already running. Check SP
			begin conversation timer (@h) timeout = 5;
		end
	--commit transaction TAPO;
end



GO
