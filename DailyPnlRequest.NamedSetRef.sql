USE Operations
GO

  DECLARE @tMapMaster AS TABLE(
    BbgKey            VARCHAR(255),
    UnderlyOne        VARCHAR(255),
    UnderlyTwo        VARCHAR(255),
    bProcessed        BIT DEFAULT 0)

  DECLARE @tResults AS TABLE(
    AsOfDate          DATE,
    BbgTicker         VARCHAR(255),
    BbgUnderly        VARCHAR(255),
    dDtdPnlUsd        NUMERIC(30, 2),
    dYtdPnlUsd        NUMERIC(30, 2),
    Price             FLOAT,
    DeltaAdjMv        FLOAT)

  DECLARE @tResultsDetail AS TABLE(
    AsOfDate          DATE,
    StratName         VARCHAR(255),
    BbgTicker         VARCHAR(255),
    BbgUnderly        VARCHAR(255),
    dDtdPnlUsd        NUMERIC(30, 2),
    dYtdPnlUsd        NUMERIC(30, 2),
    CcyOne            VARCHAR(255),
    Price             FLOAT,
    DeltaAdjMv        FLOAT)

  DECLARE @tDates AS TABLE(
    AsOfDate          DATE,
    bProcessed        BIT DEFAULT 0)

  DECLARE @BbgKey AS VARCHAR(255)
  DECLARE @UnderlyOne AS VARCHAR(255)
  DECLARE @UnderlyTwo AS VARCHAR(255)
  

/*  CREATE A TICKER MAP  */
INSERT INTO @tMapMaster(BbgKey, UnderlyOne, UnderlyTwo) SELECT 'ABVX', 'ABVX','ABVX'
INSERT INTO @tMapMaster(BbgKey, UnderlyOne, UnderlyTwo) SELECT 'ACRS', 'ACRS','ACRS'
INSERT INTO @tMapMaster(BbgKey, UnderlyOne, UnderlyTwo) SELECT 'ALPN', 'ALPN','ALPN'
INSERT INTO @tMapMaster(BbgKey, UnderlyOne, UnderlyTwo) SELECT 'CLYM', 'CLYM','ELYM'
INSERT INTO @tMapMaster(BbgKey, UnderlyOne, UnderlyTwo) SELECT 'OLMA', 'OLMA','OLMA'
INSERT INTO @tMapMaster(BbgKey, UnderlyOne, UnderlyTwo) SELECT 'VKTX', 'VKTX','VKTX'
INSERT INTO @tMapMaster(BbgKey, UnderlyOne, UnderlyTwo) SELECT 'CYTK', 'CYTK','CYTK'
INSERT INTO @tMapMaster(BbgKey, UnderlyOne, UnderlyTwo) SELECT 'KALV', 'KALV','KALV'
INSERT INTO @tMapMaster(BbgKey, UnderlyOne, UnderlyTwo) SELECT 'OTLK', 'OTLK','OTLK'

    INSERT INTO @tDates(AsOfDate) 
    SELECT dmx.AsOfDate 
      FROM dbo.DateMaster dmx 
     WHERE dmx.AsOfDate 
   BETWEEN '1/1/2023' AND '12/31/2024' AND dmx.IsWeekday = 1  AND dmx.IsMktHoliday = 0  /**/

/*
   SELECT * FROM @tDates atd ORDER BY atd.AsOfDate
   RETURN
*/

WHILE EXISTS(SELECT 1 FROM @tMapMaster tmm WHERE tmm.bProcessed = 0)
  BEGIN

     SELECT TOP 1 @BbgKey = tmm.BbgKey,
            @UnderlyOne = tmm.UnderlyOne,
            @UnderlyTwo = tmm.UnderlyTwo
       FROM @tMapMaster tmm 
      WHERE tmm.bProcessed = 0 
      ORDER BY tmm.BbgKey

      INSERT INTO @tResults(
             AsOfDate,
             BbgTicker,
             BbgUnderly,
             Price,
             DeltaAdjMv,
             dDtdPnlUsd,
             dYtdPnlUsd)
      SELECT epd.AsOfDate,
             epd.UnderlyBBYellowKey,
             epd.UnderlyBBYellowKey,
             MAX(epd.FairValue),
             SUM(epd.DeltaAdjMV),
             SUM(epd.DlyPnlUsd),
             SUM(epd.YtdPnlUsd) 
        FROM dbo.EnfPositionDetails epd
        JOIN @tDates atd
          ON epd.AsOfDate = atd.AsOfDate
       WHERE epd.AsOfDate IN (SELECT atx.AsOfDate FROM @tDates atx) 
         AND COALESCE(epd.BBYellowKey, '') != ''
         AND (CHARINDEX(@BbgKey, epd.UnderlyBBYellowKey) != 0
              OR CHARINDEX(@UnderlyOne, epd.UnderlyBBYellowKey) != 0
              OR CHARINDEX(@UnderlyTwo, epd.UnderlyBBYellowKey) != 0)
         AND COALESCE(epd.YtdPnlUsd, 0) != 0
       GROUP BY epd.AsOfDate,
             epd.UnderlyBBYellowKey,
             epd.UnderlyBBYellowKey
       ORDER BY epd.AsOfDate, epd.UnderlyBBYellowKey


      INSERT INTO @tResultsDetail(
             AsOfDate,
             StratName,
             BbgTicker,
             BbgUnderly,
             CcyOne,
             Price,
             DeltaAdjMv,
             dDtdPnlUsd,
             dYtdPnlUsd)
      SELECT epd.AsOfDate,
             epd.StratName,
             epd.BBYellowKey,
             epd.UnderlyBBYellowKey,
             epd.CcyOne,
             epd.FairValue,
             epd.DeltaAdjMV,
             epd.DlyPnlUsd,
             epd.YtdPnlUsd 
        FROM dbo.EnfPositionDetails epd
        JOIN @tDates atd
          ON epd.AsOfDate = atd.AsOfDate
       WHERE epd.AsOfDate IN (SELECT atx.AsOfDate FROM @tDates atx) 
         AND COALESCE(epd.BBYellowKey, '') != ''
         AND (CHARINDEX(@BbgKey, epd.UnderlyBBYellowKey) != 0
              OR CHARINDEX(@UnderlyOne, epd.UnderlyBBYellowKey) != 0
              OR CHARINDEX(@UnderlyTwo, epd.UnderlyBBYellowKey) != 0)
         AND COALESCE(epd.YtdPnlUsd, 0) != 0
       ORDER BY epd.AsOfDate

    UPDATE tmm SET tmm.bProcessed = 1 FROM @tMapMaster tmm WHERE (CHARINDEX(@BbgKey, tmm.BbgKey) != 0 OR CHARINDEX(@UnderlyOne, tmm.UnderlyOne) != 0 OR CHARINDEX(@UnderlyTwo, tmm.UnderlyTwo) != 0)   

  END


UPDATE trx SET trx.BbgTicker = 'ABVX US Equity',  trx.BbgUnderly = 'ABVX US Equity' FROM @tResults trx WHERE (CHARINDEX('ABVX', trx.BbgTicker) != 0 OR CHARINDEX('ABVX', trx.BbgUnderly) != 0)
UPDATE trx SET trx.BbgTicker = 'CLYM US Equity',  trx.BbgUnderly = 'CLYM US Equity' FROM @tResults trx WHERE (CHARINDEX('ELYM', trx.BbgTicker) != 0 OR CHARINDEX('ELYM', trx.BbgUnderly) != 0)

UPDATE trx SET trx.BbgUnderly = 'CLYM US Equity' FROM @tResultsDetail trx WHERE (CHARINDEX('ELYM', trx.BbgTicker) != 0 OR CHARINDEX('ELYM', trx.BbgUnderly) != 0)

SELECT * FROM @tResults trx ORDER BY trx.AsOfDate, trx.BbgTicker
SELECT * FROM @tResultsDetail trx ORDER BY trx.AsOfDate, trx.BbgTicker



  