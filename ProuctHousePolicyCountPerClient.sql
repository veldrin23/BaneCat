/******************************
** File:   ProductCountPerClient.sql 
** Name:	Product Count per client
** Desc:	Script to count the numbe rof policies per client per product house
** Auth:	Louis Pienaar
** Date:	2014/06/13
**************************
*/
DECLARE @columns NVARCHAR(MAX)
	,@sql NVARCHAR(MAX);

SET @columns = N'';

SELECT @columns += N', p.' + QUOTENAME(x.producthousedesc)
FROM (
	SELECT p.producthousedesc
	FROM cedwsqlprod1.momdw1.dim.vwpolicy p
	WHERE p.ProductHouseDesc IS NOT NULL
	GROUP BY p.producthousedesc
	) AS x;

SET @sql = N'
SELECT ClientNo,' + STUFF(@columns, 1, 2, '') + '
FROM
(
	select c.ClientNo,p.producthousedesc from CEDWSQLPROD1.[MomDW1].dim.vwPolicy p 
	inner join CEDWSQLPROD1.[MomDW1].fact.vwClientCurrentCoverage ccc on ccc.PolicyKey = p.PolicyKey and ccc.ClientRoleKey=18 and p.InforceIndicator = ''INF''
	inner join CEDWSQLPROD1.[MomDW1].dim.vwClient c on c.ClientKey = ccc.ClientKey
	where ccc.currentdatekey = convert(int,convert(varchar(8),getdate(),112))
) AS j
PIVOT
(
  Count(producthousedesc) FOR producthousedesc IN (' + STUFF(REPLACE(@columns, ', p.[', ',['), 1, 1, '') + ')
) AS p;';

PRINT @sql;

EXEC sp_executesql @sql;