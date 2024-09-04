

CREATE TABLE #tmpDataDetails(
  BegDate                        DATE,
  EndDate                        DATE,
  BgbTicker                      VARCHAR(255),
  BegMarketCap                   FLOAT,
  EndMakertCap                   FLOAT,
  BegPrice                       FLOAT,
  EndPrice                       FLOAT,
  MtdPerf                        FLOAT,
  PortTag                        VARCHAR(255),
  TagLAStage                     VARCHAR(255),
  TagTherArea                    VARCHAR(255),
  UniSnapDate                    DATE)

DECLARE @BegDate AS DATE  = '04/30/2024'
DECLARE @EndDate AS DATE = '05/31/2024'
DECLARE @PortDate AS DATE = '06/03/2024'

INSERT INTO #tmpDataDetails(
       BegDate,
       EndDate,
       BgbTicker,
       PortTag,
       UniSnapDate)
SELECT @BegDate,
       @EndDate,
       apt.PositionId,
       apt.PositionStrategy,
       apt.AsOfDate
  FROM dbo.AmfPortTagging apt
 WHERE apt.AsOfDate = @PortDate
 GROUP BY apt.PositionId,
       apt.PositionStrategy,
       apt.AsOfDate

UPDATE tdd
   SET tdd.TagTherArea = apt.TagValue
  FROM #tmpDataDetails tdd
  JOIN dbo.AmfPortTagging apt
    ON apt.PositionId = tdd.BgbTicker
   AND apt.PositionStrategy = tdd.PortTag
   AND apt.TagReference = 'Therapeutic Area'
   AND apt.AsOfDate = @PortDate

UPDATE tdd
   SET tdd.TagLAStage = apt.TagValue
  FROM #tmpDataDetails tdd
  JOIN dbo.AmfPortTagging apt
    ON apt.PositionId = tdd.BgbTicker
   AND apt.PositionStrategy = tdd.PortTag
   AND apt.TagReference = 'Stage of Lead Asset'
   AND apt.AsOfDate = @PortDate

UPDATE tdd
   SET tdd.BegMarketCap = phx.Price
  FROM #tmpDataDetails tdd
  JOIN dbo.PriceHistory phx
    ON phx.PositionId = tdd.BgbTicker
   AND phx.TagMnemonic = 'CUR_MKT_CAP'
   AND phx.AsOfDate = tdd.BegDate

UPDATE tdd
   SET tdd.EndMakertCap = phx.Price
  FROM #tmpDataDetails tdd
  JOIN dbo.PriceHistory phx
    ON phx.PositionId = tdd.BgbTicker
   AND phx.TagMnemonic = 'CUR_MKT_CAP'
   AND phx.AsOfDate = tdd.EndDate

UPDATE tdd
   SET tdd.BegPrice = phx.Price
  FROM #tmpDataDetails tdd
  JOIN dbo.PriceHistory phx
    ON phx.PositionId = tdd.BgbTicker
   AND phx.TagMnemonic = 'PX_LAST'
   AND phx.AsOfDate = tdd.BegDate

UPDATE tdd
   SET tdd.EndPrice = phx.Price
  FROM #tmpDataDetails tdd
  JOIN dbo.PriceHistory phx
    ON phx.PositionId = tdd.BgbTicker
   AND phx.TagMnemonic = 'PX_LAST'
   AND phx.AsOfDate = tdd.EndDate

UPDATE tdd
   SET tdd.MtdPerf = CASE WHEN tdd.EndPrice IS NOT NULL AND tdd.BegPrice IS NOT NULL THEN (tdd.EndPrice - tdd.BegPrice)/tdd.BegPrice ELSE NULL END
  FROM #tmpDataDetails tdd
 

SELECT * 
  FROM #tmpDataDetails tdd
 WHERE tdd.PortTag = 'Alpha Long' 
   AND MtdPerf IS NOT NULL
 ORDER BY tdd.PortTag,
       tdd.BgbTicker,
       tdd.TagLAStage,
       tdd.TagTherArea







/* 



SELECT * FROM dbo.PriceHistory phx
WHERE phx.AsOfDate = '03/28/2024'




SELECT DISTINCT apt.PositionId 
FROM dbo.AmfPortTagging apt
WHERE apt.AsOfDate = '06/03/2024'
AND apt.PositionStrategy = 'Alpha Long'

SELECT DISTINCT apt.PositionId 
FROM dbo.AmfPortTagging apt
WHERE apt.AsOfDate = '06/03/2024'
AND apt.PositionStrategy = 'Alpha Short'

SELECT DISTINCT apt.PositionId 
FROM dbo.AmfPortTagging apt
WHERE apt.AsOfDate = '06/03/2024'
AND apt.PositionStrategy = 'MSA1BIO'



SELECT * FROM #tmpDataDetails tdd
WHERE tdd.BegMarketCap IS NULL 
OR tdd.EndMakertCap IS NULL
  
ORDER BY tdd.PortTag,
     tdd.BgbTicker,
     tdd.TagLAStage,
     tdd.TagTherArea




SELECT TOP 10000 * FROM dbo.PriceHistory phx 
WHERE CHARINDEX('VERU', phx.PositionId) != 0
AND phx.TagMnemonic = 'CUR_MKT_CAP'
ORDER BY phx.CreatedOn DESC



UPDATE phx
  SET phx.PositionId = 'PHGE US Equity'
FROM dbo.PriceHistory phx 
WHERE CHARINDEX('PHGE', phx.PositionId) != 0
AND phx.TagMnemonic = 'CUR_MKT_CAP'
AND phx.iId IN (105449, 103884)

SELECT *
FROM dbo.PriceHistory phx 
WHERE CHARINDEX('PHGE', phx.PositionId) != 0
AND phx.TagMnemonic = 'CUR_MKT_CAP'
AND phx.iId IN (105449, 103884)




SELECT * FROM dbo.AmfPortTagging apt
WHERE apt.AsOfDate = '06/03/2024'
AND apt.PositionId = 'MRUS Equity'


UPDATE apt
SET apt.TagValue = 'OPHTHALMOLOGY'
FROM  dbo.AmfPortTagging apt
WHERE apt.AsOfDate = '06/03/2024'
AND apt.iId = 2949

SELECT TOP 10 * FROM dbo.AmfPortTagging apt WHERE apt.TagValue = 'OPHTHALMOLOGY' ORDER BY apt.AsOfDate DESC



SET ANSI_NULLS ON

SELECT TOP 100 * FROM dbo.MspbBasketDetails mbd ORDER BY mbd.AsOfDate DESC

SELECT mbd.AsOfDate,
       mbd.BasketTicker,
       mbd.CompTicker,
       mbd.CompName,
       mbd.PctWeight,
       mbd.CompExpShares,
       mbd.CompPrice,
       mbd.CompExpNotional,
       phx.DailyReturn

  FROM dbo.MspbBasketDetails mbd
  JOIN dbo.PerformanceDetails phx
    ON mbd.AsOfDate = phx.AsOfDate
   AND CHARINDEX(mbd.CompTicker, phx.Entity) != 0
 --WHERE mbd.CompTicker IN ('NVAX US')
 WHERE mbd.CompTicker IN ('SMMT US')
 --WHERE mbd.CompTicker IN ('MRNA US')
ORDER BY mbd.AsOfDate 











EXEC dbo.p_UpdateInsertBiotechMasterUniveres @AsOfDate = '06/03/2024', @strBbgTicker = 'IRBS US Equity', @SecName = 'IR Biosciences Holdings Inc', @MktCap = 1708.2963, @EntVal = 9586603.2963, @Price = 9.99999997475243E-07, @PrevPrice = 9.99999997475243E-07, @PEValue = -99999, @TotRetYtd = 0, @RevenueT12M = 0, @EPS = 30.6122462484351



EXEC dbo.p_ClearBiotechMasterUniverse @AsOfDate = '06/03/2024'
GO




SELECT * 
  FROM dbo.BiotechMasterUniverse bmu
  JOIN dbo.AmfPortTagging apt
    ON bmu.BbgTicker = apt.PositionId
   AND bmu.AsOfDate = apt.AsOfDate
 WHERE bmu.AsOfDate = '06/03/2024'
   AND apt.TagReference = 'Therapeutic Area'





SELECT * 
  FROM dbo.AmfPortTagging apt
 WHERE apt.AsOfDate = '06/03/2024'
   AND apt.TagReference = 'Therapeutic Area'



*/

