USE Operations
GO

IF EXISTS (SELECT * FROM #tmpRawDataCombined)
  DROP TABLE #tmpRawDataCombined
GO

  CREATE TABLE #tmpRawDataCombined(
    AsOfDate                DATE,
    BbgTicker               VARCHAR(255) NOT NULL,
    MsTicker                VARCHAR(255) NULL,
    SecName                 VARCHAR(500) NOT NULL DEFAULT 'NA',
    SecNameMs               VARCHAR(500) NULL,
    MsCountry               VARCHAR(12) NULL,    
    MrktCap                 FLOAT NULL,
    BbgPrice                FLOAT NULL,
    MsPrice                 FLOAT NULL,
    PxDiff                  FLOAT NULL,
    MsAvail                 FLOAT,
    SLRate                  FLOAT,
    SLType                  VARCHAR(15) NULL,
    bUnmapped               BIT DEFAULT 1,
    bNoMktCap               BIT DEFAULT 0,
    bNonRebate              BIT DEFAULT 0)

  DECLARE @AsOfDate AS DATE = CAST(GETDATE() AS DATE)


      INSERT INTO #tmpRawDataCombined(
             AsOfDate,
             BbgTicker,
             SecName,
             MrktCap,
             BbgPrice)
      SELECT @AsOfDate,
             bsu.BbgTicker,
             bsu.SecName,
             bsu.MarketCap,
             bsu.Price
        FROM dbo.BasketShortUniverse bsu

      UPDATE rdc
         SET rdc.MsTicker = sbd.MspbTicker,
             rdc.SecNameMs = sbd.SecName,
             rdc.MsCountry = sbd.Country,
             rdc.SLRate = sbd.Rate,
             rdc.SLType = sbd.RateType,
             rdc.MsPrice = sbd.ClsPrice,
             rdc.PxDiff = ROUND(rdc.BbgPrice - sbd.ClsPrice, 2),
             rdc.MsAvail = CASE WHEN sbd.vAvailability = 'LIMITED' THEN NULL ELSE sbd.vAvailability END,
             rdc.bUnmapped = 0
        FROM #tmpRawDataCombined rdc
        JOIN dbo.BasketShortBorrowData sbd 
          ON sbd.MspbTicker = LEFT(rdc.BBgTicker, CHARINDEX(' ', rdc.BbgTicker))
         AND CASE WHEN sbd.Country = 'USA' THEN 'US' WHEN sbd.Country = 'CAN' THEN 'CN' ELSE 'N/A' END = RTRIM(LTRIM(SUBSTRING(rdc.BbgTicker, CHARINDEX(' ', rdc.BbgTicker), CHARINDEX(' ', rdc.BbgTicker, CHARINDEX(' ', rdc.BbgTicker)) - 1)))


      SELECT rdc.AsOfDate,
             rdc.BbgTicker,
             rdc.MsTicker,
             rdc.SecName,
             rdc.SecNameMs,
             rdc.MsCountry,
             rdc.MrktCap,
             rdc.BbgPrice,
             rdc.MsPrice,
             rdc.PxDiff,
             COALESCE(rdc.MsPrice, rdc.BbgPrice) AS BestPrice,
             rdc.MsAvail,
             rdc.SLRate,
             rdc.SLType,
             '' AS AvgVolume,
             rdc.bUnmapped,
             rdc.bNoMktCap,
             rdc.bNonRebate    
        FROM #tmpRawDataCombined rdc
        ORDER BY rdc.AsOfDate,
             rdc.BbgTicker,
             rdc.MsTicker,
             rdc.SecName




/* 


SELECT * FROM dbo.BasketShortUniverse bsu




SELECT LEFT(sbd.MspbTicker, LEN(SUBSTRING(sbd.MspbTicker, 0, LEN(sbd.MspbTicker) - CHARINDEX(' ', sbd.MspbTicker))) + 1), 
       LEN(SUBSTRING(sbd.MspbTicker, 0, LEN(sbd.MspbTicker) - CHARINDEX(' ', sbd.MspbTicker))) + 1,



* FROM dbo.BasketShortBorrowData sbd ORDER BY sbd.Rate DESC


SELECT * FROM dbo.BasketShortUniverse_history bsu

 
    PROCESS STEPS FOR BASKET SHORT UNIVERSE
    
     
    * Load Bloomberg Raw data into table
      - VBA loader





*/
