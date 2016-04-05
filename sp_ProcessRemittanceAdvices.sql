SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Chi Vu
-- Create date: 05/04/2016
-- Description:	Process Remittance Advices
-- =============================================
CREATE PROCEDURE [dbo].[sp_ProcessRemittanceAdvices] 
	-- Add the parameters for the stored procedure here
	@IL_IF_ID int
AS
BEGIN
	DECLARE @PL_ID AS int
	INSERT INTO ProcessLog (PL_Action, PL_SubAction, PL_StartTime, PL_IF_ID, PL_EntityValue) VALUES ('sp_ProcessRemittanceAdvices',NULL, getdate(), @IL_IF_ID, NULL)
	SELECT @PL_ID = SCOPE_IDENTITY()


	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	

	UPDATE ProcessLog SET PL_EndTime = GetDate() WHERE PL_ID = @PL_ID
END
GO
