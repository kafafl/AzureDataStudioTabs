USE Operations
GO

SELECT * 
FROM dbo.MSCiCorrelations msci
 WHERE msci.AsOfDate = '04/10/2024'
 ORDER BY msci.BbgYellowKey

SELECT * 
FROM dbo.MSCiCorrelations msci
 WHERE msci.AsOfDate = '01/30/24'
 ORDER BY msci.BbgYellowKey


EXEC dbo.p_ClearMSCiBetas @AsOfDate = '01/24/25'


SELECT TOP 100 * FROM dbo.BasketConstituents bcs

/*
DELETE msci
FROM dbo.MSCiCorrelations msci
 WHERE msci.AsOfDate >= '01/24/2024'
*/



 /*

DELETE msci
FROM dbo.MSCiCorrelations msci
 WHERE msci.AsOfDate = '10/26/2023'

 */


/*

EXEC [dbo].[p_ClearMSCiBetas] @AsOfDate = '4/8/2024'

*/

 SELECT msci.AsOfDate,
        COUNT(msci.AsOfDate) AS xCount 
   FROM dbo.MSCiCorrelations msci
  GROUP BY msci.AsOfDate
  ORDER BY msci.AsOfDate DESC

EXEC [dbo].[p_GetAMFNavValues]


SELECT TOP 1 CAST(fad.AsOfDate AS DATE) FROM dbo.FundAssetsDetails fad WHERE fad.Entity = 'AMF NAV'  ORDER BY fad.AsOfDate DESC, COALESCE(fad.UpdatedOn, fad.CreatedOn) DESC