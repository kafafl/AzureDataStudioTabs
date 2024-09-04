
USE Operations
GO

EXEC dbo.p_GetProfLossByPosition @AsOfDate = '4/30/2024', @iTopNCount = 20, @iRst = 2, @iHierarchy = 1





--SELECT (CAST(118516 AS FLOAT) / CAST(715908 AS FLOAT)) * (CAST(-715908 AS FLOAT))

DECLARE @AsOfDate AS DATE = '05/13/2024'

SELECT TOP 1000
       epd.AsOfDate,
       epd.FundShortName,
       epd.StratName,
       epd.BookName,
       epd.BBYellowKey,
       epd.UnderlyBBYellowKey,
       epd.Quantity,
       epd.InstrType,
       epd.CcyOne,
       epd.CcyTwo,
       epd.FairValue,
       epd.NetMarketValue,
       epd.DeltaAdjMV,
       epd.LongShort,
       epd.LongMV,
       epd.ShortMV,
       epd.Delta AS OptDelta,
       epd.DeltaAdjMV / epd.NetMarketValue AS Delta,
       epd.DlyPnlUsd,
       epd.MtdPnlUsd,
       epd.YtdPnlUsd,
       epd.ItdPnlUsd
  FROM dbo.EnfPositionDetails epd
 WHERE epd.AsOfDate = @AsOfDate
   AND (epd.StratName != '' AND epd.BookName != '' AND epd.BBYellowKey != '')
   AND epd.Quantity != 0
 ORDER BY epd.AsOfDate,
       epd.FundShortName,
       epd.StratName,
       epd.BookName,
       epd.BBYellowKey




EXEC dbo.p_GetSimplePort

EXEC dbo.p_GetBasketDetails @BasketName = 'MSA1BIO Index'
EXEC dbo.p_GetBasketDetails @BasketName = 'MSA1BIOH Index'



