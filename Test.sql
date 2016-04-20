
-- Get filepath where filetable stored the files
--SELECT FileTableRootPath('MultiSoftFile') 


-- Import file: File -> split and insert lines -> populate (invoice, purchase order, remittance advice, unhandled)

--EXEC sp_TimerFileTable
--EXEC sp_TimerRemittanceAdvices



/* -- Enable xp_cmdShell
-- show advanced options
EXEC sp_configure 'show advanced options', 1
GO
RECONFIGURE
GO
-- enable xp_cmdshell
EXEC sp_configure 'xp_cmdshell', 1
GO
RECONFIGURE
GO
-- hide advanced options
EXEC sp_configure 'show advanced options', 0
GO
RECONFIGURE
GO
*/

-- Check results
--DELETE FROM MultisoftFile_Last where name = 
SELECT * FROM MultisoftFile_Last order by importdate DESC

select * from ImportedFiles where convert(char(10),IF_Date,112)=convert(char(10), getdate(),112)

select TOP 200 * from Processlog order by PL_StartTime DESC--where convert(char(10),PL_StartTime,112)=convert(char(10), getdate(),112)
select top 200 * from ReportGeneratedLog order by RG_DataExtracted DESC


select * from ImportedLines 
	where IL_IF_ID in (	select IF_ID 
						from ImportedFiles 
						where convert(char(10),IF_Date,112)=convert(char(10), getdate(),112)
						)
	and IL_EntityType IN ( 'Remittance Advice', 'Debtor Statement')
	ORDER BY IL_IF_ID, IL_PageID

select * from RemittanceAdviceHeader

select * from RemittanceAdviceLine

select * from DebtorStatementHeader

select * from DebtorStatementLine






