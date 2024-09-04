USE Operations
GO



SELECT TOP 1000 *
FROM dbo.EnfPositionDetails epx
WHERE epx.BBYellowKey IN (
SELECT DISTINCT epd.BBYellowKey FROM dbo.EnfPositionDetails epd WHERE epd.InstrType = 'Listed Option' AND epd.BBYellowKey IS NOT NULL
AND epd.UnderlyBBYellowKey NOT IN (SELECT DISTINCT phx.PositionId FROM  dbo.PriceHistory phx WHERE phx.TagMnemonic = 'LAST_PRICE'))
AND epx.InstrType = 'Listed Option'
ORDER BY epx.AsOfDate DESC

SELECT * FROM [dbo].[BarraMonthlyFactorReturns] bfr WHERE bfr.NumDate IN ('202401','202402','202403') ORDER BY bfr.AsOfDate ASC


SELECT TOp 10000 * FROM dbo.PerformanceDetails pdx WHERE pdx.Entity IN ('EFMUSATRD_BETA') ORDER BY COALESCE(pdx.UpdatedOn, pdx.CreatedOn) DESC


SELECT DISTINCT pdx.Entity FROM dbo.PerformanceDetails pdx ORDER BY pdx.Entity

SELECT bmf.AsOfDate, 
       bmf.NumDate, 
       bmf.FactorName,
       bmf.FactorValue
  FROM dbo.BarraMonthlyFactorReturns bmf
 WHERE bmf.AsOfDate > '09/30/2023'
 ORDER BY bmf.AsOfDate, bmf.NumDate, bmf.FactorName

SELECT DISTINCT fad.Entity FROM dbo.FundAssetsDetails fad


EXEC dbo.p_GetAMFNavValues @AsOfDate = '01/08/2024'


SELECT * FROM dbo.PerformanceDetails pdx
WHERE CHARINDEX('AMF RET CONTRIB LONG', pdx.Entity) != 0 OR CHARINDEX('Long ROC', pdx.Entity) != 0  OR CHARINDEX('LMV', pdx.Entity) != 0  
ORDER BY COALESCE(pdx.UpdatedOn, pdx.CreatedOn) DESC


SELECT TOP 100 * FROM dbo.PriceHistory phx WHERE CHARINDEX('MSA', phx.PositionId) != 0
ORDER BY phx.AsOfDate DESC


SELECT DISTINCT phx.PositionId FROM dbo.PriceHistory phx ORDER BY phx.PositionId


SELECT TOP 1000 * FROM dbo.EnfPositionDetails epd
WHERE epd.AsOfDate > '12/31/2023'
AND CHARINDEX('MSA1BIO Index', epd.BBYellowKey)!= 0

SELECT * FROM dbo.BarraMonthlyFactorReturns baf
WHERE baf.NumDate >= '202301'
ORDER BY baf.AsOfDate, baf.FactorName



SELECT epd.AsOfDate,
       epd.Account,
       epd.BookName,
       epd.StratName,
       epd.CcyOne,
       epd.InstDescr,
       epd.BBYellowKey,
       epd.Quantity,
       epd.NetMarketValue,
       epd.DlyPnlUsd,
       epd.MtdPnlUsd,
       epd.YtdPnlUsd
  FROM dbo.EnfPositionDetails epd
 WHERE epd.AsOfDate = '01/19/2024'
 ORDER BY  epd.AsOfDate,
       epd.Account,
       epd.BookName,
       epd.StratName,
       epd.CcyOne,
       epd.InstDescr,
       epd.BBYellowKey,
       epd.Quantity,
       epd.NetMarketValue,
       epd.DlyPnlUsd,
       epd.MtdPnlUsd,
       epd.YtdPnlUsd

SELECT COUNT(*)
FROM dbo.EnfPositionDetails epd
WHERE epd.AsOfDate = '01/22/2024'



SELECT * FROM dbo.AdminPositionDetails apd
WHERE apd.AsOfDate = '01/19/2024'
ORDER BY apd.SecName

SELECT * FROM dbo.AdminPositionDetails apd
WHERE apd.AsOfDate = '01/23/2024'
ORDER BY apd.SecName



EXEC dbo.p_GetAMFNavValues


EXEC [dbo].[p_GetAMFNavValues]

SELECT TOp 100 * FROM dbo.PriceHistory phx 
WHERE phx.AsOfDate = '01/03/2024'
AND phx.PositionId IN ('LNTH US Equity', 'PNT US Equity', 'CYTK US Equity')





 SELECT TOP 10
        enf.AsOfDate,
        enf.StratName,
        enf.InstrType,
        enf.UnderlyBBYellowKey,
        enf.DeltaAdjMV
   FROM dbo.EnfPositionDetails enf
  WHERE enf.AsOfDate = '01/03/2024'  
    AND enf.InstrType = 'Listed Option'
    AND enf.DeltaAdjMV ! = 0
    AND enf.StratName IN ('Alpha Long', 'Alhpha Short')

 SELECT TOP 10
        enf.AsOfDate,
        enf.StratName,
        enf.UnderlyBBYellowKey,
        phx.*,
        enf.DeltaAdjMV
   FROM dbo.EnfPositionDetails enf 
   JOIN dbo.PriceHistory phx
     ON enf.UnderlyBBYellowKey = phx.PositionId 
    AND enf.AsOfDate = phx.AsOfDate  
  WHERE enf.AsOfDate = '01/03/2024'  
    AND enf.InstrType = 'Listed Option'
    AND enf.DeltaAdjMV ! = 0
    AND enf.StratName IN ('Alpha Long', 'Alhpha Short')
    AND phx.TagMnemonic = 'LAST_PRICE'
    AND phx.PositionIdType = 'Bloomberg Ticker'


 SELECT enf.AsOfDate,
        enf.StratName,
        enf.UnderlyBBYellowKey,
        ROUND(SUM(COALESCE(enf.DeltaAdjMV, 0)/COALESCE(phx.Price, 0)), 0) AS Quantity,
        SUM(enf.DeltaAdjMV) AS DeltaAdjMv,
        MAX(phx.Price) AS MktPrice
   FROM dbo.EnfPositionDetails enf 
   JOIN dbo.PriceHistory phx
     ON enf.UnderlyBBYellowKey = phx.PositionId 
    AND enf.AsOfDate = phx.AsOfDate  
  WHERE enf.AsOfDate = '01/03/2024'  
    AND enf.InstrType = 'Listed Option'
    AND enf.DeltaAdjMV ! = 0
    AND enf.StratName IN ('Alpha Long', 'Alhpha Short')
    AND phx.TagMnemonic = 'LAST_PRICE'
    AND phx.PositionIdType = 'Bloomberg Ticker'
  GROUP BY enf.AsOfDate,
        enf.StratName,
        enf.UnderlyBBYellowKey
 HAVING SUM(enf.DeltaAdjMV) != 0


SELECT * FROM dbo.PriceHistory phx
WHERE phx.AsOfDate > '01/25/2024'
ORDER BY phx.AsOfDate DESC


EXEC [dbo].[p_GetMSCiBetas]


EXEC dbo.p_ClearMSCiBetas @AsOfDate = '02/06/2024'


SELECT * 
FROM dbo.EnfPositionDetails epd
 WHERE epd.AsOfDate = '02/09/2024'
ORDER BY  epd.BBYellowKey 

EXEC dbo.p_ClearAsOfPositions @AsOfDate = '02/09/2024'


SELECT TOP 100 * FROM dbo.PerformanceDetails pdx
WHERE pdx.AsOfDate > '12/31/2023'
AND pdx.Entity = 'AMF'
ORDER BY pdx.AsOfDate



SELECT TOP 100 * FROM dbo.StatisticalBetaValues
ORDER BY BbgYellowKey


USE Operations
GO

EXEC dbo.p_UpdateInsertStatBetaValues @AsOfDate = '02/19/2024', @BBYellowKey = 'ABCD US Equity', @BetaValue = 1.00

DECLARE @BBBKEY VARCHAR(255) = 'ABCD US'
SELECT CHARINDEX(' ', @BBBKEY)
SELECT SUBSTRING(@BBBKEY, 1, CHARINDEX(' ', @BBBKEY))
GO



DECLARE @Ticker AS VARCHAR(255) = 'CYTK US'
DECLARE @AsOfDate AS DATE = '02/22/2024'
DECLARE @InstrType AS VARCHAR(255) = 'EQUITY'

SELECT TOp 10 * FROM dbo.EnfPositionDetails epd
WHERE epd.AsOfDate = @AsOfDate
AND CHARINDEX(@Ticker, epd.BBYellowKey) != 0
AND epd.InstrType = @InstrType


SELECT TOp 10 * FROM dbo.AdminPositionDetails epd
WHERE epd.AsOfDate = @AsOfDate
AND CHARINDEX(@Ticker, epd.BbgCode) != 0
AND epd.AssetClass = @InstrType


SELECT epd.InstDescr AS InstrumentId, 
       SUM(epd.Quantity) AS Quantity 
  FROM [dbo].[EnfPositionDetails] epd 
 WHERE epd.AsOfDate = (SELECT TOP 1 epx.AsOfDate 
                         FROM [dbo].[EnfPositionDetails] epx 
                        ORDER BY epx.AsOfDate DESC) 
   AND CHARINDEX('MSA1', epd.InstDescr) != 0 
 GROUP BY epd.InstDescr 
 ORDER BY epd.InstDescr

SELECT TOP 100 * FROM dbo.AdminPositionDetails apd
WHERE apd.AsOfDate = '03/01/2024' 
AND apd.SecName LIKE 'Accrued Capital Contribution%'



SELECT * FROM dbo.EnfPositionDetails epd WHERE epd.AsOfDate =  (SELECT TOP 1 epx.AsOfDate 
                         FROM [dbo].[EnfPositionDetails] epx WHERE epx.AsOfDate = '03/01/2024'
                        ORDER BY epx.AsOfDate DESC) 
--AND CHARINDEX('MSA1BIO', epd.BBYellowKey) != 0
 AND 
                        ORDER BY epd.InstDescr



SELECT TOP 100 * 
  FROM dbo.BasketConstituents bks
 ORDER BY bks.UpdateDate DESC


EXEC dbo.p_GetBasketDetails @BasketName = 'MSA1BIO Index'

EXEC dbo.p_GetBasketDetails @BasketName = 'MSA1BIOH Index'

EXEC dbo.p_GetBasketDetails @BasketName = 'MSA14568 Index'


/*

DELETE bks FROM BasketConstituents bks WHERE bks.ConstName LIKE '#N/A Requesting Data... Equity'

*/



SELECT TOP 10 epd.AsOfDate 
  FROM dbo.EnfPositionDetails epd
  JOIN dbo.AdminPositionDetails apd
    ON apd.AsOfDate = epd.AsOfDate
  JOIN dbo.DateMaster dmx
    ON dmx.AsOfDate = epd.AsOfDate
 WHERE dmx.IsWeekday = 1
 GROUP BY epd.AsOfDate
 ORDER BY epd.AsOfDate DESC 


EXEC dbo.p_RunDailyPositionRec @AsOfDate = '2/28/2024', @RstOutput = 1

EXEC dbo.p_RunDailyPositionRec @AsOfDate = '03/01/2024', @RstOutput = 2


SELECT * FROM dbo.AdminPositionDetails apd
WHERE apd.AsOfDate = '03/04/2024'


/*

DELETE apd
FROM dbo.AdminPositionDetails apd
WHERE apd.AsOfDate = '03/04/2024'

*/



SELECT sbv.AsOfDate, COUNT(*)
  FROM dbo.StatisticalBetaValues sbv
 GROUP BY sbv.AsOfDate 
 ORDER BY sbv.AsOfDate DESC



SELECT SUM(epd.DeltaExp) 
 FROM dbo.EnfPositionDetails epd
WHERE epd.AsOfDate = '03/13/2024'
--AND epd.Quantity != 0
ORDER BY COALESCE(epd.UpdatedOn, epd.CreatedOn) DESC



SELECT  * FROM dbo.EnfPositionDetails epd WHERE epd.AsOfDate = '04/12/2024' ORDER BY ABS(epd.Quantity)
GO











EXEC dbo.p_GetSimplePort

EXEC dbo.p_GetEnfPositionData @EquitiesOnly = 1


















