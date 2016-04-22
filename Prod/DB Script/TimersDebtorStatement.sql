USE [MultiSoft]
GO

/****** Object:  ServiceQueue [TimersDebtorStatement]    Script Date: 21/04/2016 9:17:31 PM ******/
CREATE QUEUE [dbo].[TimersDebtorStatement] WITH STATUS = ON , RETENTION = OFF , ACTIVATION (  STATUS = ON , PROCEDURE_NAME = [dbo].[sp_TimerActivatedDebtorStatements] , MAX_QUEUE_READERS = 1 , EXECUTE AS OWNER  ), POISON_MESSAGE_HANDLING (STATUS = ON)  ON [PRIMARY] 
GO

