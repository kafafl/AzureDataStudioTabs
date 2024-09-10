USE Operations
GO

SELECT * 
  FROM dbo.PerformanceDetails pdx
 ORDER BY COALESCE(pdx.UpdatedOn, pdx.CreatedOn) DESC




EXEC dbo.p_GetPerformanceDetails @BegDate = '01/05/2024', @EndDate = '08/30/2024', @EntityName = 'SPXT Index', @bAggHolidays = 1


SELECT * 
  FROM dbo.PerformanceDetails pdx
  WHERE CHARINDEX('RGUSHSBT Index', pdx.Entity) != 0
 ORDER BY pdx.AsOfDate DESC, COALESCE(pdx.UpdatedOn, pdx.CreatedOn) DESC



SELECT TOP 100 * FROM dbo.AdminPositionDetails apd
WHERE apd.AsOfDate = '03/28/2024'



USE Operations
GO


SELECT mbd.AsOfDate,
       mbd.PortfolioName,
       mbd.BasketTicker,
       mbd.CompTicker,
       mbd.PctWeight, 
       mbd.CompBbg + ' Equity' AS BbgTicker
  FROM dbo.MspbBasketDetails mbd
 WHERE mbd.AsOfDate = '08/30/2024'
   AND mbd.BasketTicker  = 'MSA1BIOH'
 ORDER BY mbd.CompBbg



SELECT epd.DeltaAdjMV,
       epd.*
  FROM dbo.EnfPositionDetails epd
 WHERE CHARINDEX('SMMT', epd.UnderlyBBYellowKey) != 0
   AND epd.AsOfDate = '09/05/2024'




   SELECT msp.AsOfDate,
          msp.PortfolioID,
          msp.BasketTicker,
          msp.CompTicker,
          msp.CompName,
          msp.PctWeight,
          msp.CompDefShares,
          msp.CompExpShares,
          CompPrice AS Price,
          CompSedol AS SEDOL 
     FROM dbo.MspbBasketDetails msp
    WHERE msp.CompTicker = 'SMMT US'
    ORDER BY msp.AsOfDate DESC

