select top 500 * from ImportedLines where IL_EntityType ='Invoice' 
--and Il_contents NOT LIKE '%Richmond%'

select count(*) from InvoiceHeader



select * from tmpSerialNumbers --order by MyInvoice

SELECT ST1.InvoiceTo + CHAR(10) AS [text()]
					FROM tmpINHInvoiceTo ST1
					ORDER BY ST1.MyInvoice
					FOR XML PATH('')

SELECT INH_ID, IL_ID, IL_IF_ID, IL_EntityID, IL_EntityValue, LTRIM(RTRIM(IL_Contents)) AS SerialNumber
	
	FROM Importedlines IL
	INNER JOIN InvoiceHeader INH
	 ON IL_IF_ID = INH_IF_ID
	AND IL_EntityID = INH_EntityID
	WHERE   Substring(IL_Contents, 22, 2) = '  '
		AND substring(Il_contents, 24, 1) <> ' '
		AND Il_contents NOT LIKE '%Richmond%'
		AND Il_contents NOT LIKE '%PERTH   WA%'
		AND LTRIM(RTRIM(IL_Contents)) <> '.' 
		AND LTRIM(RTRIM(IL_Contents)) <> '..' 
		AND IL_EntityType = 'Invoice'
		AND IL_IF_ID = 2949 and IL_EntityID=3

select Il_contents from importedlines where il_if_id=2949 and  IL_EntityID=3

select * from ImportedLines where IL_EntityType ='Remittance Advice'


