USE [MultiSoft]
GO

/****** Object:  ServiceQueue [TimersRemittanceAdvice]    Script Date: 21/04/2016 9:17:14 PM ******/
CREATE QUEUE [dbo].[TimersRemittanceAdvice] WITH STATUS = ON , RETENTION = OFF , ACTIVATION (  STATUS = ON , PROCEDURE_NAME = [dbo].[sp_TimerActivatedRemittanceAdvices] , MAX_QUEUE_READERS = 1 , EXECUTE AS OWNER  ), POISON_MESSAGE_HANDLING (STATUS = ON)  ON [PRIMARY] 
GO

