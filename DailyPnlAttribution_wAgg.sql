USE Operations
GO

  CREATE TABLE #tmpDates(
    AsOfDate         DATE,
    dtNote           VARCHAR(5000),
    bProcessed       BIT DEFAULT 0)

    DECLARE @AsOfDate AS DATE
    DECLARE @BegDate AS DATE = '08/30/2024'
    DECLARE @EndDate AS DATE = '09/30/2024'

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
                SELECT epd.AsOfDate,
                       NULL AS AsOfDatePrev,
                       epd.StratName,
                       COALESCE(epd.UnderlyBBYellowKey, epd.BBYellowKey) AS BbgTicker,
                       epd.InstDescr, 
                       epd.InstrType,
                       epd.Account,
                       epd.CcyOne AS Crncy,
                       epd.Quantity,
                       epd.FairValue AS Price,
                       'ENF' AS PriceSource,
                       NULL AS FxRate,
                       NULL AS PriceUsd,
                       epd.DeltaAdjMV,
                       epd.Account,
                       epd.YtdPnlUsd,
                       NULL AS YtdPnlUsdPrev,
                       NULL AS DtdPnlUsd
                  FROM dbo.EnfPositionDetails epd
                 WHERE epd.AsOfDate = @AsofDate
                   AND CHARINDEX('Alpha Long', epd.StratName) != 0
                   AND CHARINDEX('Settled Cash', epd.InstDescr) = 0
                   AND epd.Quantity != 0
                   AND epd.FairValue != 0
                 --AND CHARINDEX('ORUKA', epd.InstDescr) != 0
                 ORDER BY epd.AsOfDate,
                       epd.StratName,
                       COALESCE(epd.UnderlyBBYellowKey, epd.BBYellowKey) 


            /*  ROLL ON TO THE NEXT DAY  */
                UPDATE tdy 
                   SET tdy.bProcessed = 1 
                  FROM #tmpDates tdy 
                 WHERE tdy.AsOfDate = @AsOfDate

            END