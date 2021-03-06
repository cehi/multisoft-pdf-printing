USE [MultiSoft]
GO
/****** Object:  StoredProcedure [dbo].[sp_ConversationStartDS]    Script Date: 21/04/2016 11:52:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_ConversationStartDS] AS
BEGIN
-- seed a conversation to start activating
	declare @h uniqueidentifier;
	begin dialog conversation @h
		from service [TimersDebtorStatement]
		to service N'TimersDebtorStatement', N'current database'
		with encryption = off;
	begin conversation timer (@h) timeout = 1;
	INSERT INTO tmpConversations
	SELECT @h AS UN_ID
		,getdate() AS UN_CreateTime
		,NULL
		,'DebtorStatement' AS UN_Type
END 


GO
/****** Object:  StoredProcedure [dbo].[sp_ConversationStartRA]    Script Date: 21/04/2016 11:52:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_ConversationStartRA] AS
BEGIN
-- seed a conversation to start activating
	declare @h uniqueidentifier;
	begin dialog conversation @h
		from service [TimersRemittanceAdvice]
		to service N'TimersRemittanceAdvice', N'current database'
		with encryption = off;
	begin conversation timer (@h) timeout = 1;
	INSERT INTO tmpConversations
	SELECT @h AS UN_ID
		,getdate() AS UN_CreateTime
		,NULL
		,'RemittanceAdvice' AS UN_Type
END 


GO
/****** Object:  StoredProcedure [dbo].[sp_ConversationStopDS]    Script Date: 21/04/2016 11:52:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_ConversationStopDS] AS
BEGIN
	--Stop Last Conversation
	declare @h uniqueidentifier;

	SELECT TOP 1 @h = UN_ID
	FROM tmpConversations
	WHERE UN_Type = 'DebtorStatement'
	ORDER BY UN_CreateTime DESC

	--SET @h = 'DAD1D922-8F94-E511-80D1-0050568F845B'

	-- end the conversation, will stop activating
	end conversation @h;
	
	UPDATE tmpConversations
	SET UN_EndTime = GETDATE()
	WHERE UN_Type = 'DebtorStatement'
	  AND UN_ID = @h

END


GO
/****** Object:  StoredProcedure [dbo].[sp_ConversationStopRA]    Script Date: 21/04/2016 11:52:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_ConversationStopRA] AS
BEGIN
	--Stop Last Conversation
	declare @h uniqueidentifier;

	SELECT TOP 1 @h = UN_ID
	FROM tmpConversations
	WHERE UN_Type = 'RemittanceAdvice'
	ORDER BY UN_CreateTime DESC

	--SET @h = 'DAD1D922-8F94-E511-80D1-0050568F845B'

	-- end the conversation, will stop activating
	end conversation @h;
	
	UPDATE tmpConversations
	SET UN_EndTime = GETDATE()
	WHERE UN_Type = 'RemittanceAdvice'
	  AND UN_ID = @h

END


GO
