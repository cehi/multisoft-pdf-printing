USE [MultiSoft]
GO

/****** Object:  StoredProcedure [dbo].[sp_ImportedLines_Update]    Script Date: 08/04/2016 12:43:58 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		Martin Wain
-- Create date: 17/11/2015
-- Description:	
-- =============================================
ALTER PROCEDURE [dbo].[sp_ImportedLines_Update] 
	-- Add the parameters for the stored procedure here
	@IL_IF_ID int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @PL_ID AS int
	DECLARE @PL_ID1 AS int
	DECLARE @PL_ID1a AS int
	DECLARE @PL_ID1b AS int
	DECLARE @PL_ID1c AS int
	DECLARE @PL_ID1d AS int
	DECLARE @PL_ID2 AS int
	DECLARE @PL_ID3 AS int
	DECLARE @PL_ID4 AS int
	DECLARE @PL_ID5 AS int
	DECLARE @PL_ID6 AS int
	DECLARE @PL_ID7 AS int
	DECLARE @NoOfInvoices AS int
	DECLARE @NoOfPurchaseOrders AS int
	DECLARE @NoOfUnhandled AS int

	INSERT INTO ProcessLog (PL_Action, PL_SubAction, PL_StartTime, PL_IF_ID, PL_EntityValue) VALUES ('sp_ImportedLines_Update',NULL, getdate(), @IL_IF_ID, NULL)
	SELECT @PL_ID = SCOPE_IDENTITY()

	DECLARE @BadFile as bit

	SET @BadFile = 0

    -- Insert statements for procedure here

	--Update Page Numbers
	UPDATE ImportedLines 
	SET IL_PageID = 1+(IL_LineID-1)/66 -- Assumes 66 Line page.
	WHERE IL_PageID is NULL
	  AND IL_IF_ID = @IL_IF_ID

	--Update Page Line Numbers
	UPDATE IL
	SET IL_PageLineID = U.PageLine
	FROM ImportedLines IL
	INNER JOIN (
		SELECT IL_ID
			,ROW_NUMBER() OVER (PARTITION BY IL_IF_ID,IL_PageID ORDER BY IL_ID) AS PageLine
		FROM ImportedLines
		WHERE 1 = 1  
		  AND IL_IF_ID = @IL_IF_ID
		) U ON IL.IL_ID = U.IL_ID

	--Delete Hangover Pages
	DELETE
	FROM ImportedLines
	WHERE IL_IF_ID = @IL_IF_ID
	  AND IL_PageID IN (
			SELECT IL_PageID
			FROM ImportedLines
			WHERE IL_IF_ID = @IL_IF_ID
			GROUP BY IL_PageID
			HAVING COUNT(*) < 2
			)

	--Check for bad file.
	IF EXISTS (SELECT IL_PageID, COUNT(*)FROM ImportedLines WHERE IL_IF_ID = @IL_IF_ID GROUP BY IL_PageID HAVING COUNT(*) <> 66)
	BEGIN
		EXEC sp_ReportGeneratedLog_BadFile @IL_IF_ID
		RETURN
	END

	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	--Updates Entity Details for Invoices
	INSERT INTO ProcessLog (PL_Action, PL_SubAction, PL_StartTime, PL_IF_ID, PL_EntityValue) VALUES ('sp_ImportedLines_Update','Invoices', getdate(), @IL_IF_ID, NULL)
	SELECT @PL_ID1 = SCOPE_IDENTITY()

	UPDATE Importedlines
	SET IL_EntityType = 'Invoice'
		--,IL_EntityValue = REPLACE(LTRIM(RTRIM(SUBSTRING(IL_Contents,88,9))),'  ',' ') --allows 9 digit Inv No - Current is 8 digit)
		,IL_EntityValue = LTRIM(RTRIM(SUBSTRING(IL_Contents,88,9))) --allows 9 digit Inv No - Current is 8 digit)
		,IL_IsTaxInvoice = CASE
								WHEN IL_Contents LIKE '%TAX INVOICE%' THEN 1
								ELSE 0
						   END 
	FROM Importedlines
	WHERE (Il_contents LIKE '%Invoice     J%' OR Il_contents LIKE '%Credit Note C%')
		AND IL_EntityID IS NULL
		AND Il_PageLineID = 5
		AND IL_IF_ID = @IL_IF_ID
	SELECT @NoOfInvoices = @@ROWCOUNT

	UPDATE ProcessLog SET PL_EndTime = GetDate() WHERE PL_ID = @PL_ID1

	IF @NoOfInvoices > 0
	BEGIN
	

		INSERT INTO ProcessLog (PL_Action, PL_SubAction, PL_StartTime, PL_IF_ID, PL_EntityValue) VALUES ('sp_ImportedLines_Update','InvoicesA', getdate(), @IL_IF_ID, NULL)
		SELECT @PL_ID1a = SCOPE_IDENTITY()

		UPDATE IL
		SET  IL.IL_EntityType = B.IL_EntityType
			,IL.IL_EntityValue = B.IL_EntityValue
			,IL.IL_IsTaxInvoice = B.IL_IsTaxInvoice
		FROM Importedlines IL
		INNER JOIN Importedlines B 
			ON IL.IL_IF_ID = B.IL_IF_ID
		   AND IL.IL_PageID = B.IL_PageID
		WHERE b.IL_EntityType = 'Invoice'
		AND IL.IL_IF_ID = @IL_IF_ID

		UPDATE ProcessLog SET PL_EndTime = GetDate() WHERE PL_ID = @PL_ID1a

		INSERT INTO ProcessLog (PL_Action, PL_SubAction, PL_StartTime, PL_IF_ID, PL_EntityValue) VALUES ('sp_ImportedLines_Update','InvoicesB', getdate(), @IL_IF_ID, NULL)
		SELECT @PL_ID1b = SCOPE_IDENTITY()

		UPDATE IL
		SET IL.IL_EntityID = B.IL_EntityID
		FROM ImportedLines IL
		INNER JOIN (
			SELECT IL_IF_ID
				,ROW_NUMBER() OVER (
					PARTITION BY IL_IF_ID ORDER BY IL_EntityValue
					) AS IL_EntityID
				,IL_EntityValue
			FROM (
				SELECT DISTINCT IL_IF_ID
					,IL_EntityValue
				FROM ImportedLines
				WHERE IL_EntityValue IS NOT NULL
				AND IL_EntityID IS NULL
				) AS SUB
			) AS B ON IL.IL_IF_ID = B.IL_IF_ID
			AND IL.IL_EntityValue = B.IL_EntityValue
			AND IL.IL_IF_ID = @IL_IF_ID


		UPDATE ProcessLog SET PL_EndTime = GetDate() WHERE PL_ID = @PL_ID1b
	
		INSERT INTO ProcessLog (PL_Action, PL_SubAction, PL_StartTime, PL_IF_ID, PL_EntityValue) VALUES ('sp_ImportedLines_Update','InvoicesC', getdate(), @IL_IF_ID, NULL)
		SELECT @PL_ID1c = SCOPE_IDENTITY()

		UPDATE Importedlines
		SET IL_IsCopy = CASE
							WHEN IL_Contents = 'COPY' THEN 1
							ELSE 0
						END 
		WHERE IL_PageLineID = 2
		  AND IL_EntityType = 'Invoice'
		  AND IL_IF_ID = @IL_IF_ID

		UPDATE ProcessLog SET PL_EndTime = GetDate() WHERE PL_ID = @PL_ID1c

		INSERT INTO ProcessLog (PL_Action, PL_SubAction, PL_StartTime, PL_IF_ID, PL_EntityValue) VALUES ('sp_ImportedLines_Update','InvoicesD', getdate(), @IL_IF_ID, NULL)
		SELECT @PL_ID1d = SCOPE_IDENTITY()

		UPDATE IL
		SET IL.IL_IsCopy = B.IL_IsCopy
		FROM Importedlines IL
		INNER JOIN Importedlines B 
			ON IL.IL_IF_ID = B.IL_IF_ID
		   AND IL.IL_EntityID = B.IL_EntityID
		WHERE b.IL_EntityType = 'Invoice'
		  AND b.IL_IsCopy = 1
		  AND IL.IL_IF_ID = @IL_IF_ID
	
		UPDATE ProcessLog SET PL_EndTime = GetDate() WHERE PL_ID = @PL_ID1d

	END

	----~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	----Updates Entity Details for Credit Notes
	--UPDATE Importedlines
	--SET IL_EntityType = 'Credit Note'
	--	,IL_EntityValue = REPLACE(LTRIM(RTRIM(SUBSTRING(IL_Contents,88,9))),'  ',' ')
	--	,IL_IsTaxInvoice = CASE
	--							WHEN IL_Contents LIKE '%TAX INVOICE%' THEN 1
	--							ELSE 0
	--					   END 
	----Select *, LTRIM(RTRIM(SUBSTRING(IL_Contents,88,9)))
	--FROM Importedlines
	--WHERE Il_contents LIKE '%Credit Note C%'
	--	AND IL_EntityID IS NULL
	--	AND IL_IF_ID = @IL_IF_ID

	--UPDATE IL
	--SET 
	--	IL.IL_EntityType = B.IL_EntityType
	--	,IL.IL_EntityValue = B.IL_EntityValue
	--	,IL.IL_IsTaxInvoice = B.IL_IsTaxInvoice
	--FROM Importedlines IL
	--INNER JOIN Importedlines B 
	--	ON IL.IL_IF_ID = B.IL_IF_ID
	--   AND IL.IL_PageID = B.IL_PageID
	--WHERE b.IL_EntityType = 'Credit Note'
 --     AND IL.IL_IF_ID = @IL_IF_ID

	--UPDATE IL
	--SET IL.IL_EntityID = B.IL_EntityID 
	--FROM ImportedLines IL
	--INNER JOIN 
	--(SELECT IL_IF_ID
	--	,ROW_NUMBER() OVER (PARTITION BY IL_IF_ID ORDER BY IL_EntityValue) AS IL_EntityID
	--	,IL_EntityValue
	--FROM (SELECT DISTINCT IL_IF_ID ,IL_EntityValue FROM ImportedLines WHERE IL_EntityValue IS NOT NULL AND IL_EntityID IS NULL) AS SUB ) AS B
	--	ON IL.IL_IF_ID = B.IL_IF_ID
	--   AND IL.IL_EntityValue = B.IL_EntityValue
	--   AND IL.IL_IF_ID = @IL_IF_ID

	--	UPDATE Importedlines
	--SET IL_IsCopy = CASE
	--					WHEN IL_Contents = 'COPY' THEN 1
	--					ELSE 0
	--				END 
	--WHERE IL_PageLineID = 2
	--  AND IL_EntityType = 'Credit Note'
	--  AND IL_IF_ID = @IL_IF_ID

	--UPDATE IL
	--SET IL.IL_IsCopy = B.IL_IsCopy
	--FROM Importedlines IL
	--INNER JOIN Importedlines B 
	--	ON IL.IL_IF_ID = B.IL_IF_ID
	--   AND IL.IL_EntityID = B.IL_EntityID
	--WHERE b.IL_EntityType = 'Credit Note'
	--  AND b.IL_IsCopy = 1
	--  AND IL.IL_IF_ID = @IL_IF_ID



	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	--Updates Entity Details for Purchase Orders
	INSERT INTO ProcessLog (PL_Action, PL_SubAction, PL_StartTime, PL_IF_ID, PL_EntityValue) VALUES ('sp_ImportedLines_Update','PurchaseOrders', getdate(), @IL_IF_ID, NULL)
	SELECT @PL_ID2 = SCOPE_IDENTITY()

	UPDATE Importedlines
	SET IL_EntityType = 'Purchase Order'
		,IL_EntityValue = LTRIM(RTRIM(SUBSTRING(IL_Contents,84,9))) --allows 9 digit Inv No - Current is 8 digit)
		,IL_IsTaxInvoice = CASE
								WHEN IL_Contents LIKE '%TAX INVOICE%' THEN 1
								ELSE 0
						   END 
	FROM Importedlines
	WHERE Il_contents LIKE '%                Southern Cross Computer                                            P%'
		AND IL_EntityID IS NULL
		AND Il_PageLineID = 4
		AND IL_IF_ID = @IL_IF_ID
	SELECT @NoOfPurchaseOrders = @@ROWCOUNT

	IF @NoOfPurchaseOrders > 0
	BEGIN

		UPDATE IL
		SET 
			IL.IL_EntityType = B.IL_EntityType
			,IL.IL_EntityValue = B.IL_EntityValue
			,IL.IL_IsTaxInvoice = B.IL_IsTaxInvoice
		FROM Importedlines IL
		INNER JOIN Importedlines B 
			ON IL.IL_IF_ID = B.IL_IF_ID
		   AND IL.IL_PageID = B.IL_PageID
		WHERE b.IL_EntityType = 'Purchase Order'
		  AND IL.IL_IF_ID = @IL_IF_ID

		UPDATE IL
		SET IL.IL_EntityID = B.IL_EntityID
		FROM ImportedLines IL
		INNER JOIN (
			SELECT IL_IF_ID
				,ROW_NUMBER() OVER (
					PARTITION BY IL_IF_ID ORDER BY IL_EntityValue
					) AS IL_EntityID
				,IL_EntityValue
			FROM (
				SELECT DISTINCT IL_IF_ID
					,IL_EntityValue
				FROM ImportedLines
				WHERE IL_EntityValue IS NOT NULL
				AND IL_EntityID IS NULL
				) AS SUB
			) AS B ON IL.IL_IF_ID = B.IL_IF_ID
			AND IL.IL_EntityValue = B.IL_EntityValue
			AND IL.IL_IF_ID = @IL_IF_ID

	END

	UPDATE ProcessLog SET PL_EndTime = GetDate() WHERE PL_ID = @PL_ID2

	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	--Updates Entity Details for Un Handled Items
	INSERT INTO ProcessLog (PL_Action, PL_SubAction, PL_StartTime, PL_IF_ID, PL_EntityValue) VALUES ('sp_ImportedLines_Update','Unhandled', getdate(), @IL_IF_ID, NULL)
	SELECT @PL_ID3 = SCOPE_IDENTITY()

	UPDATE Importedlines
	SET IL_EntityID = -1
		,IL_EntityType = '<Not Handled>'
		,IL_EntityValue = 'IF_ID = ' + CAST(@IL_IF_ID AS varchar(20))
	FROM Importedlines
	WHERE IL_EntityID IS NULL
		AND IL_IF_ID = @IL_IF_ID
	SELECT @NoOfUnhandled = @@ROWCOUNT

	IF @NoOfUnhandled > 0
	BEGIN
	
		--Update Entity Page Numbers
		UPDATE IL
		SET IL_EntityPageID = U.EntityPageID
		FROM ImportedLines IL
		INNER JOIN (
				SELECT IL_IF_ID
				,IL_PageID
				,IL_EntityID
				,ROW_NUMBER() OVER (Partition By IL_IF_ID,IL_EntityID ORDER BY IL_PAGEID) AS EntityPageID
				FROM ImportedLines
				WHERE IL_IF_ID = @IL_IF_ID
				  AND IL_PageLineID = 1
			) U ON IL.IL_IF_ID = U.IL_IF_ID
			   AND IL.IL_PageID = U.IL_PageID
			   AND IL.IL_EntityID = U.IL_EntityID
	
	END
	
	UPDATE ProcessLog SET PL_EndTime = GetDate() WHERE PL_ID = @PL_ID3

	--Check for Smushed file

	INSERT INTO dbo.ReportGeneratedLog
		(RG_IF_ID
		,RG_IF_Date
		,RG_EntityID
		,RG_EntityType
		,RG_EntityValue
		,RG_IsSecure)
	SELECT DISTINCT IF_ID
		,IF_Date
		,IL_EntityID
		,IL_EntityType
		,IL_EntityValue
		,IF_IsSecure
	FROM ImportedFiles I
	INNER JOIN ImportedLines IL 
		ON I.IF_ID = IL.IL_IF_ID
	WHERE I.IF_ID = @IL_IF_ID
	ORDER BY IL_EntityValue

	--Populate Invoice Tables
	IF EXISTS (Select * from ImportedLines where IL_EntityType = 'Invoice' AND IL_IsSecure = 0 AND IL_IF_ID = @IL_IF_ID) 
		BEGIN 
			EXEC sp_ProcessInvoices @IL_IF_ID
		END 
	
	--Populate Credit Note Tables
	IF EXISTS (Select * from ImportedLines where IL_EntityType = 'Credit Note' AND IL_IsSecure = 0 AND IL_IF_ID = @IL_IF_ID) 
		BEGIN 
			EXEC sp_ProcessCreditNotes @IL_IF_ID
		END 

	--Populate Purchase Order Tables
	IF EXISTS (Select * from ImportedLines where IL_EntityType = 'Purchase order' AND IL_IsSecure = 0 AND IL_IF_ID = @IL_IF_ID) 
		BEGIN 

			EXEC sp_ProcessPurchaseOrders @IL_IF_ID
		END 
	
	UPDATE ProcessLog SET PL_EndTime = GetDate() WHERE PL_ID = @PL_ID

END



GO

