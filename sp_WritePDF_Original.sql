USE [MultiSoft]
GO

/****** Object:  StoredProcedure [dbo].[sp_WritePDF]    Script Date: 19/04/2016 5:18:38 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_WritePDF] 
	 @PON varchar(50) -- no 'P_' in front
	,@Filename varchar(255)
	,@LocalPath varchar(255)
	,@Path varchar(255)
	,@RSS varchar(255)
--WITH EXECUTE AS 'SCCS-MSD\svcReports'
WITH EXECUTE AS 'SCCS\zSVC_SQLServerRS'
AS
BEGIN
	DECLARE @PL_ID AS int
	INSERT INTO ProcessLog (PL_Action, PL_SubAction, PL_StartTime, PL_IF_ID, PL_EntityValue) VALUES ('sp_WritePDF','RenderPDF', getdate(), NULL, @PON)
	SELECT @PL_ID = SCOPE_IDENTITY()

	--DECLARE @Filename AS varchar(50)
	--DECLARE @Path as varchar(255)
	DECLARE @CmdPath as varchar(2000)
	DECLARE @cmd AS VARCHAR(8000)
	DECLARE @retVal INT
	DECLARE @output TABLE (
		ix INT identity PRIMARY KEY
		,txt VARCHAR(max)
		)

	DECLARE @GsExe as varchar(255)
	DECLARE @FRSSScripts as varchar(255)

	SELECT @GsExe = CF_Value FROM ConfigValues WHERE CF_Item = 'Exe_GhostScript'
	SELECT @FRSSScripts = CF_Value FROM ConfigValues WHERE CF_Item = 'Folder_RSS_Scripts'
	--PRINT @GsExe
	--PRINT @FRSSScripts

	--SET @CmdPath = 'MD "' + @Path + '"'
	--EXEC xp_cmdshell @CmdPath;
    
	SET @CmdPath = 'MD "' + @LocalPath + '"'

	EXEC xp_cmdshell @CmdPath;


	IF @Filename Like '%Unhandled Report%'
		SET @Cmd = 'rs.exe -i "' + @FRSSScripts + @RSS + '" -s http://localhost/reportserver -e Exec2005 -v vPON="' + @PON + '" -v vFileName="' + @Path + @FileName + '"'
	ELSE
		SET @Cmd = 'rs.exe -i "' + @FRSSScripts + @RSS + '" -s http://localhost/reportserver -e Exec2005 -v vPON="' + @PON + '" -v vFileName="' + @LocalPath + @FileName + '"'


	EXEC xp_cmdshell @Cmd;
	UPDATE ProcessLog SET PL_EndTime = GetDate() WHERE PL_ID = @PL_ID
	
	IF @Filename not Like '%Unhandled Report%'
	BEGIN 
		INSERT INTO ProcessLog (PL_Action, PL_SubAction, PL_StartTime, PL_IF_ID, PL_EntityValue) VALUES ('sp_WritePDF','ShrinkPDF', getdate(), NULL, @PON)
		SELECT @PL_ID = SCOPE_IDENTITY()

		SET @cmd = '"' + @GsExe + '" -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/prepress -dNOPAUSE -dQUIET -dBATCH -sOutputFile="' + @Path + @FileName + '" "' + @LocalPath + @FileName + '"'
		SET @cmd = 'CMD /S /C " ' + @cmd + ' " '

		INSERT INTO @output (txt)
		EXEC @retVal = xp_cmdshell @cmd

		INSERT @output (txt)
		SELECT '(Exit Code: ' + cast(@retVal AS VARCHAR(10)) + ')'

		SELECT *
		FROM @output
		
		UPDATE ProcessLog SET PL_EndTime = GetDate() WHERE PL_ID = @PL_ID
	END
END

GO

