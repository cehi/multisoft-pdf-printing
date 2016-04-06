
SELECT S1.IL_ID, S1.IF_ID, S1.pageID, s1.pagelineid, s3.EntityValue, s1.IL_Content, s3.rankid
				
FROM SimpleTest S1
 left join
(select s2.il_id,s2.pageid,s2.if_id, s2.lineid, s2.pagelineid,
CAST(s2.if_id as varchar(50)) + '.' + Substring(s4.Il_content,1,6) AS EntityValue, s2.IL_content,
row_number() over (PARTITION BY S2.IF_ID 
ORDER BY s2.IL_content, s2.pageid) As rankid
from simpletest s2
inner join simpletest s4 on s2.pageid=s4.pageid and s2.if_id=s4.if_id --and s2.lineid=s4.lineid 
where s4.pagelineid=2 and ((s2.PageLineID=64 and s2.il_content like 'Payment%') )--or (s2.PageLineID=61 and s2.il_content like 'Continue%') )
 ) s3
  on s1.IF_ID=s3.if_id and s1.pageid=s3.pageid 
  where (s1.PageLineID=64 and s1.il_content like 'Payment%') or (s1.PageLineID=61 and s1.il_content like 'Continue%') 
  order by s1.il_id

select * from SimpleTest


		UPDATE IL
		SET IL.EntityID = B.EntityID
		FROM SimpleTest IL
		INNER JOIN (
			SELECT IF_ID
				,ROW_NUMBER() OVER (
					PARTITION BY IF_ID ORDER BY PageID
					) AS EntityID
				,PageID
			FROM SimpleTest
			WHERE  
				IL_Content LIKE 'Payment%'
				AND PageLineID = 64
				
			) AS B ON IL.IF_ID = B.IF_ID
			AND IL.PageID = B.PageID

			UPDATE IL
		SET IL.EntityID = B.PrevID + 1
		FROM SimpleTest IL
		INNER JOIN (
			SELECT S.IF_ID, S.PageID, MAX(F.EntityID) AS PrevID				
			FROM SimpleTest S
			INNER JOIN (
				SELECT DISTINCT IF_ID
					,PageID, EntityID
				FROM SimpleTest
				WHERE --IL_EntityValue = 'Remittance Advice'
					EntityID IS NOT NULL
					--AND IL_IF_ID = @IL_IF_ID
				) AS  F
				ON S.IF_ID = F.IF_ID
			WHERE  S.IL_Content = 'Continue'
				AND S.PageLineID = 61
				AND S.EntityID IS NULL
				AND S.PageID > F.PageID
				GROUP BY S.IF_ID, S.PageID
			) AS B ON IL.IF_ID = B.IF_ID
			AND IL.PageID = B.PageID
			--AND IL.IL_IF_ID = @IL_IF_ID

			UPDATE IL
		SET 
			IL.IL_EntityValue = B.IL_EntityValue
		FROM Importedlines IL
		INNER JOIN (
				SELECT S.IL_IF_ID, S.IL_PageID, S.IL_EntityType,
					LTRIM(RTRIM(SUBSTRING(S.IL_Contents,50,8))) + '.' + SUBSTRING(D.IL_Contents,2,8)
					AS IL_EntityValue
				FROM Importedlines S
					INNER JOIN Importedlines D
					ON S.IL_IF_ID = D.IL_IF_ID
						AND S.IL_PageID = D.IL_PageID						
					WHERE S.IL_EntityType = 'Remittance Advice'
						AND S.IL_PageLineID=14
						AND D.IL_PageLineID=19		
			) B 
			ON IL.IL_IF_ID = B.IL_IF_ID
				AND IL.IL_PageID = B.IL_PageID
		WHERE IL.IL_EntityType = 'Remittance Advice'
		 

			select * from SimpleTest

			UPDATE IL
		SET 
			IL.SuppNo = B.IL_EntityValue
		FROM SimpleTest IL
		INNER JOIN (
				SELECT S.IF_ID, S.PageID, 
					LTRIM(RTRIM(SUBSTRING(S.IL_Content,1,3))) + '.' + SUBSTRING(D.IL_Content,1,8)
					AS IL_EntityValue
				FROM SimpleTest S
					INNER JOIN SimpleTest D
					ON S.IF_ID = D.IF_ID
						AND S.PageID = D.PageID						
					WHERE S.PageLineID=2
						AND D.PageLineID=64 		
			) B 
			ON IL.IF_ID = B.IF_ID
				AND IL.PageID = B.PageID
		
