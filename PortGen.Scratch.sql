USE Operations
GO

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



 SELECT epd.stratName,
        COALESCE(UnderlyBBYellowKey, BBYellowKey) AS Ticker 
  FROM dbo.EnfPositionDetails epd
 WHERE epd.AsOfDate = '04/30/2024'
   AND epd.StratName IN ('Alpha Long', 'Alpha Short_XXX')
   AND ROUND(epd.Quantity, 0) != 0
   AND epd.InstrType = 'Equity'
   AND LTRIM(RTRIM(COALESCE(UnderlyBBYellowKey, BBYellowKey))) != ''
   AND COALESCE(UnderlyBBYellowKey, BBYellowKey) NOT IN ('XBI US Equity')
 GROUP BY epd.stratName,
       COALESCE(UnderlyBBYellowKey, BBYellowKey)
       HAVING ROUND(SUM(epd.Quantity), 0) != 0       
 ORDER BY epd.stratName,COALESCE(UnderlyBBYellowKey, BBYellowKey)











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


