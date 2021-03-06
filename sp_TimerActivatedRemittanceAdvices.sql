USE [MultiSoft]
GO

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


