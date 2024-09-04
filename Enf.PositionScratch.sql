USE Operations
GO

/*  Man@ger22!  */


EXEC dbo.p_GetEnfPositionData @AsOfDate = '03/22/2024', @ResultSet = 1
GO


SELECT *
  FROM dbo.EnfPositionDetails epd
 WHERE 1 = 1
   AND epd.AsOfDate = '2024-03-20'

  -- AND epd.Account = 'Non-Trading'  
  -- AND epd.StratName = 'Alpha Short'
  -- AND epd.BBYellowKey = 'ALPN US Equity'
  -- AND COALESCE(epd.Quantity, 0) != 0

  --ORDER BY CreatedOn DESC
ORDER BY CASE WHEN epd.StratName = '' THEN 'zNONE' ELSE epd.StratName END , epd.BookName, epd.InstDescr, epd.BBYellowKey







SELECT TOP 10000 * FROM dbo.EnfPositionDetails epd
WHERE epd.AsOfDate = '12/12/2023'
AND epd.InstrType = 'Listed Option'
AND epd.Quantity != 0






SELECT CASE WHEN epd.StratName='' THEN 'OTHER' ELSE epd.StratName END AS Strategy,
       CASE WHEN epd.BookName='' THEN 'OTHER' ELSE epd.BookName END AS Book,
       SUM(epd.DlyPnlUsd) AS DtdPnl,
       SUM(epd.MtdPnlUsd) AS MtdPnl,
       SUM(epd.YtdPnlUsd) AS YtdPnl,
       SUM(CASE WHEN (CHARINDEX('FX ', epd.InstDescr) != 0 OR CHARINDEX('Settled Cash', epd.InstDescr) != 0) THEN 0 ELSE epd.NetMarketValue END) AS MarketValue,
       SUM(epd.DlyPnlOfNav) AS DtdPnl,
       SUM(epd.MtdPnlOfNav) AS MtdPnl,
       SUM(epd.YtdPnlOfNav) AS YtdPnl
  FROM dbo.EnfPositionDetails epd
 WHERE epd.AsOfDate = '09/29/2023'
 GROUP BY epd.StratName,
       epd.BookName
 ORDER BY CASE WHEN epd.StratName='' THEN 'zOTHER' ELSE epd.StratName END,
        CASE WHEN epd.BookName='' THEN 'OTHER' ELSE epd.BookName END


EXEC [dbo].[p_GetAMFNavValues] @AsOfDate = '04/10/2024'


SELECT epd.AsOfDate,
       COUNT(epd.AsOfDate) AS xCount,
       SUM(epd.DlyPnlUsd) AS DtdPnl,
       SUM(epd.MtdPnlUsd) AS MtdPnl,
       SUM(epd.YtdPnlUsd) AS YtdPnl,
       SUM(epd.DeltaAdjMV) AS DeltaAdjMV,
       SUM(epd.DeltaExp) AS DeltaExp,
       MAX(epd.CreatedOn) AS CreatedOn,
       MAX(epd.CreatedBy) AS CreatedBy,
       MAX(epd.UpdatedOn) AS UpdatedOn,
       MAX(epd.UpdatedBy) AS UpdatedBy,
       MAX(COALESCE(epd.UpdatedOn, CreatedOn)) AS LastTouch
  FROM dbo.EnfPositionDetails epd
 WHERE epd.AsOfDate >= '03/01/2024' 
 GROUP BY epd.AsOfDate
 ORDER BY epd.AsOfDate DESC,  
       MAX(COALESCE(epd.UpdatedOn, CreatedOn))



SELECT TOP 1
       epd.AsOfDate,
       epd.BBYellowKey,
       epd.Quantity
  FROM dbo.EnfPositionDetails epd
 WHERE 1 = 1
   AND CHARINDEX('FGEN US Equity', epd.BBYellowKey) != 0
   AND ROUND(epd.Quantity, 0) != 0
   AND epd.AsOfDate BETWEEN '03/19/2024' AND '03/25/2024'
 ORDER BY epd.AsOfDate




/*




 DELETE epd 
 FROM dbo.EnfPositionDetails epd

 WHERE epd.Quantity = 0
 AND epd.NetMarketValue = 0
 AND epd.DlyPnlUsd = 0
 AND epd.MtdPnlUsd = 0
 AND epd.YtdPnlUsd = 0
 AND epd.ItdPnlUsd = 0
 AND epd.DeltaAdjMV = 0
 AND epd.NetAvgCost = 0
 AND epd.OverallCost = 0






SELECT * 
 FROM dbo.EnfPositionDetails epd
 --WHERE epd.AsOfDate < '04/01/2024'
 
 WHERE epd.Quantity = 0
 AND epd.NetMarketValue = 0
 AND epd.DlyPnlUsd = 0
 AND epd.MtdPnlUsd = 0
 AND epd.YtdPnlUsd = 0
 AND epd.ItdPnlUsd = 0
 AND epd.DeltaAdjMV = 0
 AND epd.NetAvgCost = 0
 AND epd.OverallCost = 0

*/


SELECT TOP 100 * FROM dbo.EnfPositionDetails epd WHERE CHARINDEX('WARRANT', epd.BBYellowKey) != 0
