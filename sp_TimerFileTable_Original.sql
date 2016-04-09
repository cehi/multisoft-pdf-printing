USE [MultiSoft]
GO

/****** Object:  StoredProcedure [dbo].[sp_TimerFileTable]    Script Date: 09/04/2016 8:21:11 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_TimerFileTable] AS
BEGIN
	DECLARE @ReturnCode BIT
    SET @ReturnCode = 0        
     
    BEGIN TRY    
                         
		--check if the temp exists. if it exists it means another instance of SP is running, raise an error and exit                           
		IF object_id('tempdb.dbo.##gsp_TimerFileTable') IS NOT NULL
		BEGIN
			SET @ReturnCode = 0 --global table already exists. not created
			RAISERROR ( 'Unable to acquire exclusive Lock on sp_TimerFileTable', 16, 1 )
			RETURN
		END
     
		--Create a temporary global table      
		CREATE TABLE ##gsp_TimerFileTable (id INT )
		SET @ReturnCode = 1 --global table created in this instance

		DECLARE @ST_ID As hierarchyid

		SELECT TOP 1 @ST_ID = MS.path_locator
		FROM MultisoftFile MS
		LEFT OUTER JOIN (
			SELECT sMFL.NAME
				,sMFL.file_stream
			FROM MultisoftFile_Last sMFL
			INNER JOIN (
				SELECT NAME
					,MAX(importdate) AS importdate
				FROM MultisoftFile_Last
				GROUP BY NAME
				) ssMFL ON sMFL.NAME = ssMFL.NAME
				AND sMFL.importdate = ssMFL.importdate
			) MSL ON MS.file_stream = MSL.file_stream
			AND MS.NAME = MSL.NAME
		--AND MS.last_access_time = MSL.last_access_time
		WHERE MSL.NAME IS NULL
		--SELECT @ST_ID

		DELETE FROM MultisoftFile_Last WHERE importdate < getdate()-10
 
		INSERT INTO MultisoftFile_Last 
		SELECT file_stream, name, last_write_time, last_access_time, GETDATE() FROM  [dbo].[MultiSoftFile]
		WHERE path_locator = @ST_ID

 		INSERT INTO ImportedFiles (
			[IF_Date]
			,[IF_Name]
			,[IF_Contents]
			,[IF_IsSecure]
			)
		SELECT GETDATE()
			,M.NAME
			,REPLACE(CAST(m.file_stream AS VARCHAR(MAX)), CHAR(13), '')
			,dbo.fn_IsSecure(M.NAME)
		FROM MultisoftFile M
		WHERE CAST(m.file_stream AS VARCHAR(MAX)) <> ''
		AND m.path_locator = @ST_ID
	   -- processing is completed. drop the temporary table
	    DROP TABLE ##gsp_TimerFileTable
     
    END TRY     
    BEGIN CATCH
         
        --if the sp fails for some other reason and the table is already created drop it
        IF object_id('tempdb.dbo.##gsp_TimerFileTable') IS NOT NULL AND @ReturnCode = 1
        BEGIN
            DROP TABLE ##sp_TimerFileTable
        END
     
        DECLARE @ErrMsg VARCHAR(4000)
        SELECT @ErrMsg = ERROR_MESSAGE()       
        RAISERROR(@ErrMsg, 15, 50)       
     
    END CATCH  

END

GO

