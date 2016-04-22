USE [MultiSoft]
GO

/****** Object:  BrokerService [TimersRemittanceAdvice]    Script Date: 21/04/2016 9:18:21 PM ******/
CREATE SERVICE [TimersRemittanceAdvice]  ON QUEUE [dbo].[TimersRemittanceAdvice] ([DEFAULT])
GO

