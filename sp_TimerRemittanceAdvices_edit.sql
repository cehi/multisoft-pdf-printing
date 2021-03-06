USE [MultiSoft]
GO
/****** Object:  StoredProcedure [dbo].[sp_TimerRemittanceAdvices]    Script Date: 19/04/2016 9:54:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_TimerRemittanceAdvices] AS
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
