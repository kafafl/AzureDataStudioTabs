SELECT TOP (1000) [iId]
      ,[AsOfDate]
      ,[PositionId]
      ,[PositionIdType]
      ,[PriceSource]
      ,[Price]
      ,[TagMnemonic]
      ,[CreatedBy]
      ,[CreatedOn]
      ,[UpdatedBy]
      ,[UpdatedOn]
  FROM [dbo].[PriceHistory]
  --WHERE TagMnemonic = 'DAY_TO_DAY_TOT_RETURN_GROSS_DVDS'
  ORDER BY CreatedOn DESC




  SELECT epd.UnderlyBBYellowKey 
    FROM dbo.EnfPositionDetails epd
   WHERE epd.AsOfDate BETWEEN '01/01/2024' AND '05/29/2024'
     AND epd.StratName IN ('Alpha Long')
     AND epd.InstrType IN ('Equity', 'Listed Option')
     AND epd.UnderlyBBYellowKey != ''
     AND epd.UnderlyBBYellowKey NOT IN ('ALPN US Equity', 'ZURA US Equity', 'ABIO US Equity', 'JANX US Equity', 'LYRA US Equity', 'ELYM US Equity', 'VINC US Equity', 'CYTK US Equity', 'DAWN US Equity')
     GROUP BY epd.UnderlyBBYellowKey
     HAVING SUM(epd.YtdPnlUsd) != 0
     ORDER BY epd.UnderlyBBYellowKey


SELECT * 
  FROM dbo.DateMaster dmx
 WHERE dmx.IsWeekday = 1 AND dmx.IsMktHoliday = 0
 AND dmx.AsOfDate BETWEEN '01/01/2024' AND '05/29/2024'
 ORDER BY dmx.AsOfDate


SELECT TOP 1000 * FROM dbo.PerformanceDetails pdx
ORDER BY pdx.CreatedOn DESC



