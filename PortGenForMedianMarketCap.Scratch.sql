USE Operations
GO


/* FOR MONTH END MARKET CAP */
  SELECT COALESCE(UnderlyBBYellowKey, BBYellowKey) AS Ticker 
    FROM dbo.EnfPositionDetails epd
   WHERE epd.AsOfDate = '10/31/2024'
     AND epd.StratName IN ('Alpha Long', 'Alpha Short')
     AND ROUND(epd.Quantity, 0) != 0
     AND epd.InstrType = 'Equity'
     AND LTRIM(RTRIM(COALESCE(UnderlyBBYellowKey, BBYellowKey))) != ''
     AND COALESCE(UnderlyBBYellowKey, BBYellowKey) NOT IN ('XBI US Equity')
   GROUP BY COALESCE(UnderlyBBYellowKey, BBYellowKey)
  HAVING ROUND(SUM(epd.Quantity), 0) != 0       
   ORDER BY COALESCE(UnderlyBBYellowKey, BBYellowKey)



/*

SELECT TOp 10000 * FROM dbo.EnfPositionDetails epd WHERE epd.BBYellowKey = 'LIAN US Equity' AND epd.Quantity != 0 ORDER BY epd.AsOfDate DESC

SELECT TOp 10000 * FROM dbo.EnfPositionDetails epd WHERE epd.BBYellowKey = 'ABIO US Equity' AND epd.Quantity != 0 ORDER BY epd.AsOfDate DESC


SELECT TOp 1 * FROM dbo.EnfPositionDetails epd WHERE epd.BBYellowKey = 'ABIO US Equity'




  SELECT epd.stratName,
         COALESCE(UnderlyBBYellowKey, BBYellowKey) AS Ticker 
    FROM dbo.EnfPositionDetails epd
   WHERE epd.AsOfDate = '07/31/2024'
     AND epd.StratName IN ('Alpha Long', 'Alpha Short')
     AND ROUND(epd.Quantity, 0) != 0
     AND epd.InstrType = 'Equity'
     AND LTRIM(RTRIM(COALESCE(UnderlyBBYellowKey, BBYellowKey))) != ''
     AND COALESCE(UnderlyBBYellowKey, BBYellowKey) NOT IN ('XBI US Equity')
   GROUP BY epd.stratName,
         COALESCE(UnderlyBBYellowKey, BBYellowKey)
  HAVING ROUND(SUM(epd.Quantity), 0) != 0       
   ORDER BY epd.stratName,COALESCE(UnderlyBBYellowKey, BBYellowKey)


  SELECT epd.InstDescr,
         LEFT(epd.BBYellowKey, CHARINDEX(' ', epd.BBYellowKey)) AS Lookup,
         epd.BBYellowKey,
         epd.stratName
          
    FROM dbo.EnfPositionDetails epd
   WHERE epd.AsOfDate = '06/28/2024'
   And Account = 'MS Cash'
   AND InstrType NOT IN ('Cash')
   AND epd.YtdPnlUsd != 0
   AND epd.BBYellowKey != ''
ORDER BY LEFT(epd.BBYellowKey, CHARINDEX(' ', epd.BBYellowKey)),
         epd.BBYellowKey,
         epd.stratName

SELECT * FROM dbo.EnfPositionDetails epd
WHERE epd.InstDescr LIKE ('%VIX%')
   AND epd.AsOfDate = '06/28/2024'
   --And Account = 'MS Cash'
   AND InstrType NOT IN ('Cash')
   --AND epd.YtdPnlUsd != 0


     --AND epd.StratName IN ('Alpha Long', 'Alpha Short')
     --AND ROUND(epd.Quantity, 0) != 0
     --AND epd.InstrType = 'Equity'
     --AND LTRIM(RTRIM(COALESCE(UnderlyBBYellowKey, BBYellowKey))) != ''
     --AND COALESCE(UnderlyBBYellowKey, BBYellowKey) NOT IN ('XBI US Equity')
   --GROUP BY epd.stratName,
         --COALESCE(UnderlyBBYellowKey, BBYellowKey)
  --HAVING ROUND(SUM(epd.Quantity), 0) != 0       
   --ORDER BY epd.stratName,COALESCE(UnderlyBBYellowKey, BBYellowKey)

  SELECT epd.stratName,
         COALESCE(UnderlyBBYellowKey, BBYellowKey) AS Ticker 
    FROM dbo.EnfPositionDetails epd
   WHERE epd.AsOfDate = '05/31/2024'
     AND epd.StratName IN ('Alpha Long', 'Alpha Short_XXX')
     AND ROUND(epd.Quantity, 0) != 0
     AND epd.InstrType = 'Equity'
     AND LTRIM(RTRIM(COALESCE(UnderlyBBYellowKey, BBYellowKey))) != ''
     AND COALESCE(UnderlyBBYellowKey, BBYellowKey) NOT IN ('XBI US Equity')
   GROUP BY epd.stratName,
         COALESCE(UnderlyBBYellowKey, BBYellowKey)
         HAVING ROUND(SUM(epd.Quantity), 0) != 0       
   ORDER BY epd.stratName,COALESCE(UnderlyBBYellowKey, BBYellowKey)

  SELECT epd.stratName,
         COALESCE(epd.UnderlyBBYellowKey, epd.BBYellowKey) AS Ticker,
         RTRIM(LEFT(COALESCE(epd.UnderlyBBYellowKey, epd.BBYellowKey), CHARINDEX(' ', COALESCE(epd.UnderlyBBYellowKey, epd.BBYellowKey))))  AS LookupTicker,
         SUM(ROUND(epd.Quantity, 0)) AS Quantity         
    FROM dbo.EnfPositionDetails epd
   WHERE epd.AsOfDate = '05/31/2024'
     AND epd.StratName IN ('Alpha Long', 'Alpha Short')
     AND ROUND(epd.Quantity, 0) != 0
     AND epd.InstrType IN ( 'Equity', 'Listed Option')
     AND LTRIM(RTRIM(COALESCE(epd.UnderlyBBYellowKey, epd.BBYellowKey))) != ''
     AND COALESCE(epd.UnderlyBBYellowKey, epd.BBYellowKey) NOT IN ('XBI US Equity')
   GROUP BY epd.stratName,
         COALESCE(UnderlyBBYellowKey, BBYellowKey)
         HAVING ROUND(SUM(epd.Quantity), 0) != 0       
   ORDER BY epd.stratName,COALESCE(epd.UnderlyBBYellowKey, epd.BBYellowKey)

  SELECT epd.stratName,
         COALESCE(epd.UnderlyBBYellowKey, epd.BBYellowKey) AS Ticker,
         RTRIM(LEFT(COALESCE(epd.UnderlyBBYellowKey, epd.BBYellowKey), CHARINDEX(' ', COALESCE(epd.UnderlyBBYellowKey, epd.BBYellowKey))))  AS LookupTicker,
         SUM(epd.YtdPnlUsd) AS YtdPnlUsd    
    FROM dbo.EnfPositionDetails epd
   WHERE epd.AsOfDate = '06/28/2024'
     AND epd.StratName IN ('Alpha Long', 'Alpha Short')
     AND ROUND(epd.YtdPnlUsd, 0) != 0
     AND epd.InstrType IN ( 'Equity', 'Listed Option')
     AND LTRIM(RTRIM(COALESCE(epd.UnderlyBBYellowKey, epd.BBYellowKey))) != ''
     AND COALESCE(epd.UnderlyBBYellowKey, epd.BBYellowKey) NOT IN ('XBI US Equity')
   GROUP BY epd.stratName,
         COALESCE(UnderlyBBYellowKey, BBYellowKey)
         HAVING ROUND(SUM(epd.YtdPnlUsd), 0) != 0       
   ORDER BY epd.stratName,COALESCE(epd.UnderlyBBYellowKey, epd.BBYellowKey)


SELECT * FROM dbo.EnfPositionDetails epd
WHERE epd.AsOfDate = '07/31/2024'
AND CHARINDEX('ZURA', epd.BBYellowKey) != 0


*/

SELECT RAND() AS SomeNum, GETDATE() AS SomeTime




/*  BELOW IS HOW WE GOT TO THE ABOVE 


SELECT --epd.StratName,
       --epd.BookName,
       --epd.InstDescr,
       COALESCE(UnderlyBBYellowKey, BBYellowKey) AS Ticker,
       SUM(epd.Quantity) AS Shares
  FROM dbo.EnfPositionDetails epd
 WHERE epd.AsOfDate = '04/30/2024'
   AND epd.StratName IN ('Alpha Long', 'Alpha Short')

   AND LTRIM(RTRIM(COALESCE(UnderlyBBYellowKey, BBYellowKey))) != ''
   AND epd.InstrType = 'Equity'
 GROUP BY --epd.StratName,
       --epd.BookName,
       --epd.InstDescr,
       COALESCE(UnderlyBBYellowKey, BBYellowKey)
HAVING ROUND(SUM(epd.Quantity), 0) != 0
 ORDER BY --epd.StratName,
       --epd.BookName,
       --epd.InstDescr,
       COALESCE(UnderlyBBYellowKey, BBYellowKey)


SELECT TOP 100 * FROM dbo.PriceHistory phx 
WHERE phx.TagMnemonic = 'DAY_TO_DAY_TOT_RETURN_GROSS_DVDS'
ORDER BY phx.UpdatedOn DESC


SELECT COALESCE(UnderlyBBYellowKey, BBYellowKey) AS Name,
       SUM(epd.Quantity) AS ActualShares
  FROM dbo.EnfPositionDetails epd
 WHERE epd.AsOfDate = '04/30/2024'
   --AND epd.StratName IN ('Alpha Long', 'Alpha Shortx')
   AND ROUND(epd.Quantity, 0) != 0
   AND CHARINDEX('Curncy', COALESCE(UnderlyBBYellowKey, BBYellowKey)) = 0
   AND LTRIM(RTRIM(COALESCE(UnderlyBBYellowKey, BBYellowKey))) != ''
   AND epd.InstrType = 'Equity'
   GROUP BY COALESCE(UnderlyBBYellowKey, BBYellowKey)
 ORDER BY COALESCE(UnderlyBBYellowKey, BBYellowKey)


SELECT *
  FROM dbo.EnfPositionDetails epd
 WHERE epd.AsOfDate = '03/14/2024'
   --AND epd.StratName IN ('Alpha Long', 'Alpha Shortx')
   --AND ROUND(epd.Quantity, 0) != 0
   --AND CHARINDEX('PHGE', epd.UnderlyBBYellowKey) != 0
   AND CHARINDEX('Warrant', epd.InstDescr) != 0
   --AND CHARINDEX('Curncy', COALESCE(UnderlyBBYellowKey, BBYellowKey)) = 0


SELECT --epd.StratName,
       --epd.BookName,
       --epd.InstDescr,
       COALESCE(UnderlyBBYellowKey, BBYellowKey) AS Ticker,
       SUM(epd.Quantity) AS Shares
  FROM dbo.EnfPositionDetails epd
 WHERE epd.AsOfDate = '04/30/2024'
   AND epd.StratName IN ('Alpha Long', 'Alpha Short')

   AND LTRIM(RTRIM(COALESCE(UnderlyBBYellowKey, BBYellowKey))) != ''
   AND epd.InstrType = 'Equity'
 GROUP BY --epd.StratName,
       --epd.BookName,
       --epd.InstDescr,
       COALESCE(UnderlyBBYellowKey, BBYellowKey)
HAVING ROUND(SUM(epd.Quantity), 0) != 0
 ORDER BY --epd.StratName,
       --epd.BookName,
       --epd.InstDescr,
       COALESCE(UnderlyBBYellowKey, BBYellowKey)


*/