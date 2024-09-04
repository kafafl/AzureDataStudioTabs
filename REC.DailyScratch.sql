USE Operations
GO


SELECT * 
  FROM dbo.AdminPositionDetails apd
  WHERE apd.AsOfDate >= '11/01/2023'
  AND CHARINDEX('NLT', apd.BbgCode) != 0
 ORDER BY apd.AsOfDate, apd.SecName


SELECT apd.AsOfDate,
       apd.TopLevelTag,
       apd.Strategy,
       apd.HedgeCore,
       apd.LS_Exposure,
       COUNT(apd.AsOfDate) AS xCount,
       SUM(apd.MktValueGross) AS MktValueGross,
       SUM(apd.Quantity * apd.Price * apd.Delta) AS MktValueUsd,
       SUM(apd.DtdPnlUsd) AS DtdPnlUsd,
       SUM(apd.MtdPnlUsd) AS MtdPnlUsd,
       SUM(apd.YtdPnlUsd) AS YtdPnlUsd
  FROM dbo.AdminPositionDetails apd
 WHERE apd.AsOfDate = '10/11/2023'
 GROUP BY apd.AsOfDate,
       apd.TopLevelTag,
       apd.Strategy,
       apd.HedgeCore,
       apd.LS_Exposure
 ORDER BY apd.AsOfDate,
       apd.TopLevelTag,
       apd.Strategy,
       apd.HedgeCore,
       apd.LS_Exposure




SELECT TOp 100 *  FROM dbo.AdminPositionDetails apd WHERE CHARINDEX('GOSSAMER BIO', apd.SecName) != 0 ORDER BY apd.AsOfDate DESC




SELECT apd.AsOfDate,
       COUNT(apd.AsOfDate) AS xCount,
       SUM(apd.DtdPnlUsd) AS DtdPnlUsd,
       SUM(apd.MtdPnlUsd) AS MtdPnlUsd,
       SUM(apd.YtdPnlUsd) AS YtdPnlUsd,
       MAX(apd.CreatedOn) AS CreateDate
  FROM dbo.AdminPositionDetails apd
 GROUP BY apd.AsOfDate
 ORDER BY apd.AsOfDate








EXEC dbo.p_RunDailyPositionRec @AsOfDate = '11/16/2023'
GO












/*

DELETE apd 
  FROM dbo.AdminPositionDetails apd
  WHERE apd.AsOfDate = '01/16/2024'


*/

SELECT * FROM dbo.AdminPositionDetails apd
WHERE apd.AsOfDate = '01/16/2024'

SELECT TOP 100 * FROM dbo.FundAssetsDetails fad
WHERE fad.AsOfDate >= '01/18/2024'
ORDER BY COALESCE(fad.UpdatedOn, fad.CreatedOn) DESC

SELECT TOP 100 * FROM dbo.PerformanceDetails fad
WHERE fad.AsOfDate >= '01/18/2024'
ORDER BY COALESCE(fad.UpdatedOn, fad.CreatedOn) DESC

SELECT TOP 100 * FROM dbo.FundAssetsDetails fad
WHERE fad.AsOfDate = '12/29/2023'
ORDER BY COALESCE(fad.UpdatedOn, fad.CreatedOn) DESC

SELECT TOP 100 * FROM dbo.PerformanceDetails fad
WHERE fad.AsOfDate = '12/29/2023'
ORDER BY COALESCE(fad.UpdatedOn, fad.CreatedOn) DESC

SELECT DISTINCT fad.Entity
 FROM dbo.FundAssetsDetails fad
WHERE fad.AsOfDate = '01/19/2024'
ORDER BY fad.Entity


SELECT * FROM dbo.FundAssetsDetails fad
WHERE fad.AsOfDate <= '01/19/2024'
ORDER BY fad.AsOfDate
