SELECT DISTINCT A.name, B.[rows], A.modify_date --, C.*  --, C.last_user_scan  
FROM DB_ORF_REL.sys.objects A
	INNER JOIN DB_ORF_REL.sys.partitions B ON A.object_id = B.object_id
	--INNER JOIN DB_ORF_REL.sys.tables (NOLOCK) C ON A.object_id = C.object_id
WHERE A.[type] = 'U' AND B.[rows] > 0
ORDER BY B.[rows] DESC