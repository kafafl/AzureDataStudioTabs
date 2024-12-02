USE Operations
GO

  CREATE TABLE #tmpDates(
    AsOfDate         DATE,
    dtNote           VARCHAR(5000),
    bProcessed       BIT DEFAULT 0)


  CREATE TABLE #tmpDataBuild(
    AsOfDate         DATE,
    AsOfDatePrev     DATE,
    StratName        VARCHAR(500),
    BookBName        VARCHAR(500),
    BbgTicker        VARCHAR(500),
    InstrDescr       VARCHAR(500),
    InstrType        VARCHAR(500),
    pbAccount        VARCHAR(500),          
    Crncy            VARCHAR(500),
    Quantity         FLOAT,
    Price            FLOAT,
    NetMarketValue   FLOAT,
    NetMarketValPrev FLOAT,
    PriceSource      VARCHAR(500),
    FxRate           FLOAT,
    PriceUsd         FLOAT,
    DeltaAdjMV       FLOAT,
    DeltaAdjMVPrev   FLOAT,
    YtdPnlUsd        FLOAT,
    YtdPnlUsdPrev    FLOAT,
    DtdPnlUsd        FLOAT,
    GrExpOfGLNav     FLOAT,
    YtdPnlOfNav      FLOAT,
    YtdPnlOfNavPrev  FLOAT,
    DtdPnlOfNav      FLOAT)

    DECLARE @AsOfDate AS DATE
    DECLARE @BegDate AS DATE = '08/30/2024'
    DECLARE @EndDate AS DATE = '09/30/2024'
    DECLARE @PnlDate AS DATE

        INSERT INTO #tmpDates(
               AsOfDate)
        SELECT dmx.AsOfDate
          FROM dbo.DateMaster dmx
         WHERE dmx.AsOfDate BETWEEN @BegDate AND @EndDate
           AND dmx.IsWeekday = 1
           AND dmx.IsMktHoliday = 0


        WHILE EXISTS(SELECT TOP 1 tdd.AsOfDate FROM #tmpDates tdd WHERE tdd.bProcessed = 0)
            BEGIN

                 SELECT TOP 1 @AsOfDate = tdx.AsOfDate 
                   FROM #tmpDates tdx
                  WHERE tdx.bProcessed = 0 
                  ORDER BY tdx.AsOfDate

              /* Long Hand Enfusion Position Data  */
                 INSERT INTO #tmpDataBuild(
                        AsOfDate,
                        AsOfDatePrev,
                        StratName,
                        BookBName,
                        BbgTicker,
                        InstrDescr,
                        InstrType,
                        pbAccount,          
                        Crncy,
                        Quantity,
                        Price,
                        NetMarketValue,
                        NetMarketValPrev,
                        PriceSource,
                        FxRate,
                        PriceUsd,
                        DeltaAdjMV,
                        YtdPnlUsd,
                        YtdPnlUsdPrev,
                        DtdPnlUsd,
                        GrExpOfGLNav,
                        YtdPnlOfNav,
                        YtdPnlOfNavPrev,
                        DtdPnlOfNav)
                 SELECT epd.AsOfDate,
                        NULL AS AsOfDatePrev,
                        epd.StratName,
                        epd.BookName,
                        COALESCE(epd.UnderlyBBYellowKey, epd.BBYellowKey) AS BbgTicker,
                        epd.InstDescr, 
                        epd.InstrType,
                        epd.Account,
                        epd.CcyOne AS Crncy,
                        epd.Quantity,
                        epd.FairValue AS Price,
                        epd.NetMarketValue,
                        NULL,
                        'ENF' AS PriceSource,
                        NULL AS FxRate,
                        NULL AS PriceUsd,
                        epd.DeltaAdjMV,
                        epd.YtdPnlUsd,
                        NULL AS YtdPnlUsdPrev,
                        NULL AS DtdPnlUsd,
                        epd.GrExpOfGLNav,
                        epd.YtdPnlOfNav,
                        NULL AS YtdPnlOfNavPrev,
                        NULL AS DtdPnlOfNav
                   FROM dbo.EnfPositionDetails epd
                  WHERE epd.AsOfDate = @AsofDate
                    AND CHARINDEX('Alpha Long', epd.StratName) != 0
                    AND CHARINDEX('Settled Cash', epd.InstDescr) = 0
                    AND epd.NetMarketValue != 0
                  --AND epd.FairValue != 0
                  --AND CHARINDEX('ORUKA', epd.InstDescr) != 0
                  ORDER BY epd.AsOfDate,
                        epd.StratName,
                        COALESCE(epd.UnderlyBBYellowKey, epd.BBYellowKey) 

                 UPDATE tdb
                    SET tdb.BbgTicker = tdb.InstrDescr
                   FROM #tmpDataBuild tdb
                  WHERE tdb.BbgTicker = ''


            /*  SET FXRATE FOR FX  */
                 UPDATE tdb 
                    SET tdb.FxRate = amd.Price
                   FROM #tmpDataBuild tdb
                   JOIN dbo.PriceHistory amd 
                     ON tdb.AsOfDate = amd.AsOfDate 
                    AND tdb.Crncy + ' Curncy' = amd.PositionId   
                    AND amd.TagMnemonic = 'LAST_PRICE' 
                  WHERE tdb.AsOfDate = @AsOfDate
        
            /*  SET FX RATE FOR USD  */ 
                 UPDATE tdb 
                    SET tdb.FxRate = 1.00
                   FROM #tmpDataBuild tdb  
                  WHERE tdb.Crncy = 'USD'
                    AND tdb.FxRate IS NULL
                    AND tdb.AsOfDate = @AsOfDate

            /*  DOLLARIZE NON-USD PRICES  */
                 UPDATE tdb
                    SET tdb.PriceUsd = CASE WHEN tdb.Crncy = 'JPY' THEN tdb.Price / tdb.FxRate ELSE tdb.Price * tdb.FxRate END
                   FROM #tmpDataBuild tdb
                  WHERE tdb.AsOfDate = @AsOfDate

            SELECT TOP 1 @PnlDate = tdb.AsOfDate 
            FROM #tmpDataBuild tdb 
            WHERE tdb.AsOfDate < @AsofDate 
            ORDER BY tdb.AsOfDate DESC


              UPDATE tdb
                 SET tdb.AsOfDatePrev = tdz.AsOfDate,
                     tdb.YtdPnlUsdPrev = tdz.YtdPnlUsd,
                     tdb.YtdPnlOfNavPrev = tdz.YtdPnlOfNav,
                     tdb.NetMarketValPrev = tdz.NetMarketValue,
                     tdb.DeltaAdjMVPrev = tdz.DeltaAdjMV,
                     tdb.DtdPnlUsd = tdb.YtdPnlUsd - tdz.YtdPnlUsd,
                     tdb.DtdPnlOfNav = tdb.YtdPnlOfNav - tdz.YtdPnlOfNav
                FROM #tmpDataBuild tdb
                JOIN #tmpDataBuild tdz
                  ON tdb.BbgTicker = tdz.BbgTicker
                 AND tdb.StratName = tdz.StratName
                 AND tdb.BookBName = tdz.BookBName
                 AND tdb.InstrDescr = tdz.InstrDescr
                 AND tdb.InstrType = tdz.InstrType
               WHERE tdb.AsOfDate = @AsOfDate
                 AND tdz.AsOfDate = @PnlDate 



            /*  ROLL ON TO THE NEXT DAY  */
                UPDATE tdy 
                   SET tdy.bProcessed = 1 
                  FROM #tmpDates tdy 
                 WHERE tdy.AsOfDate = @AsOfDate

            END





            SELECT * 
            FROM #tmpDataBuild tdb
            WHERE tdb.AsOfDatePrev IS NOT NULL
