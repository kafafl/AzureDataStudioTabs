USE Operations
GO


/*
SELECT * FROM dbo.DateMaster dmt
WHERE dmt.AsOfDate BETWEEN '08/01/2024' AND '10/16/2024'
AND dmt.IsWeekday = 1
ORDER BY dmt.AsOfDate


SELECT TOP 100 * FROM dbo.StatisticalBetaValues sbv 
WHERE sbv.BbgYellowKey = 'ZVRA US Equity'
--AND sbv.AsOfDate IN ('2024-10-03', '2024-10-14', '2024-10-25', '2024-10-28')
ORDER BY sbv.AsOfDate DESC


UPDATE sbv SET sbv.BmkBeta = 0.99 FROM dbo.StatisticalBetaValues sbv WHERE sbv.Iid IN (12987, 12919, 12791, 11746, 11604, 11178, 10951, 9971, 9835, 9279, 9208, 8936, 8659, 8586, 8522)


INSERT INTO dbo.StatisticalBetaValues(AsOfDate, PortfolioName, Ticker, BbgYellowKey, BmkBeta, CreatedBy, CreatedOn)
SELECT '2024-09-03', 'AMF', 'CLYM', 'CLYM US Equity', 1.3, SUSER_NAME(), GETDATE()


SELECT TOP 100 * FROM dbo.StatisticalBetaValues sbv 
WHERE sbv.BbgYellowKey = 'CLYM US Equity'
--AND sbv.AsOfDate IN ('2024-10-03', '2024-10-14', '2024-10-25', '2024-10-28')
ORDER BY sbv.AsOfDate DESC

INSERT INTO dbo.StatisticalBetaValues(AsOfDate, PortfolioName, Ticker, BbgYellowKey, BmkBeta, CreatedBy, CreatedOn)
SELECT '2024-10-01', 'AMF', 'CLYM', 'CLYM US Equity', 1.3, SUSER_NAME(), GETDATE()

INSERT INTO dbo.StatisticalBetaValues(AsOfDate, PortfolioName, Ticker, BbgYellowKey, BmkBeta, CreatedBy, CreatedOn)
SELECT '2024-10-02', 'AMF', 'CLYM', 'CLYM US Equity', 1.3, SUSER_NAME(), GETDATE()

UPDATE sbv SET sbv.Ticker = 'CLYM' FROM dbo.StatisticalBetaValues sbv WHERE sbv.Iid IN(  13058, 13057)



SELECT TOP 100 * FROM dbo.StatisticalBetaValues sbv 
WHERE sbv.BbgYellowKey = 'WVE US Equity'
--AND sbv.AsOfDate IN ('2024-10-03', '2024-10-14', '2024-10-25', '2024-10-28')
ORDER BY sbv.AsOfDate DESC

INSERT INTO dbo.StatisticalBetaValues(AsOfDate, PortfolioName, Ticker, BbgYellowKey, BmkBeta, CreatedBy, CreatedOn)
SELECT '2024-10-16', 'AMF', 'WVE', 'WVE US Equity', 1.58, SUSER_NAME(), GETDATE()



UPDATE sbv SET sbv.Ticker = 'CLYM' FROM dbo.StatisticalBetaValues sbv WHERE sbv.Iid IN(  13058, 13057)


SELECT TOP 100 * FROM dbo.StatisticalBetaValues sbv 
WHERE sbv.BbgYellowKey = 'RCKT US Equity'
--AND sbv.AsOfDate IN ('2024-10-03', '2024-10-14', '2024-10-25', '2024-10-28')
ORDER BY sbv.AsOfDate DESC

INSERT INTO dbo.StatisticalBetaValues(AsOfDate, PortfolioName, Ticker, BbgYellowKey, BmkBeta, CreatedBy, CreatedOn)
SELECT '2024-10-01', 'AMF', 'RCKT', 'RCKT US Equity', 1.83, SUSER_NAME(), GETDATE()

UPDATE sbv SET sbv.BmkBeta = 1.83 FROM dbo.StatisticalBetaValues sbv WHERE sbv.BbgYellowKey = 'RCKT US Equity' AND sbv.AsOfDate IN ('2024-10-03', '2024-10-14', '2024-10-25', '2024-10-28')

*/



  CREATE TABLE #tmpDates(
    AsOfDate         DATE,
    dtNote           VARCHAR(5000),
    bProcessed       BIT DEFAULT 0)

  CREATE TABLE #tmpPortfolio(
    AsOfDate         DATE,
    Strategy         VARCHAR(500),
    BbgTicker        VARCHAR(500),
    PosLong          FLOAT,
    PosNet           FLOAT,
    PosShort         FLOAT)

  CREATE TABLE #tmpResults(
    AsOfDate         DATE,
    Strategy         VARCHAR(500),
    BbgTicker        VARCHAR(500),
    Crncy            VARCHAR(5),
    Quantity         FLOAT,
    Price            FLOAT,
    PriceSource      VARCHAR(255),
    FxRate           FLOAT,
    PriceUsd         FLOAT,
    MarketValue      FLOAT,
    StatBeta         FLOAT,
    BetaAdjMktVal    FLOAT)

  CREATE TABLE #tmpResultsFinal(
    AsOfDate         DATE,
    Strategy         VARCHAR(500),
    BbgTicker        VARCHAR(500),
    Crncy            VARCHAR(5),
    Quantity         FLOAT,
    Price            FLOAT,
    PriceSource      VARCHAR(255),
    FxRate           FLOAT,
    PriceUsd         FLOAT,
    MarketValue      FLOAT,
    StatBeta         FLOAT,
    BetaAdjMktVal    FLOAT)



DECLARE @AsOfDate AS DATE
DECLARE @BegDate AS DATE = '10/01/2024'
DECLARE @EndDate AS DATE = '11/29/2024'

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


/*   CLEAR CONTENTS OF DAILY TABLE  */
     DELETE tpx FROM #tmpPortfolio tpx

     INSERT INTO #tmpPortfolio(
            AsOfDate,
            Strategy,
            BbgTicker,
            PosLong,
            PosNet,
            PosShort)
       EXEC dbo.p_GetLongPortfolio @AsOfDate = @AsOfDate, @bIncludeOptions = 1


    /* SET THE BASIS OF THE PORTFOLIO */
       INSERT INTO #tmpResults(
              AsOfDate,
              Strategy,
              BbgTicker,
              Quantity)
       SELECT AsOfDate,
              Strategy,
              BbgTicker,
              PosLong
         FROM #tmpPortfolio tpp 

    /*  XXXXXXXXXXXXXXXXXXXXXXXXXXXX  */
    /*  PRICE WATERFALL BEGIN         */
    /*  XXXXXXXXXXXXXXXXXXXXXXXXXXXX  */

    /*  PRICE WATERFALL STEP 1 - MKT PRICES  */
        UPDATE rdc 
           SET rdc.Price = amd.MdValue,
               rdc.PriceSource = 'MKT'
          FROM #tmpResults rdc  
          JOIN dbo.AmfMarketData amd 
            ON rdc.AsOfDate = amd.AsOfDate 
           AND rdc.BbgTicker = amd.PositionId 
         WHERE amd.DataSource = 'Bloomberg'  
           AND amd.TagMnemonic = 'LAST_PRICE' 

    /*  PRICE WATERFALL STEP 2 - ENF PRICES  */
        UPDATE rdc 
           SET rdc.Price = amd.FairValue,
               rdc.PriceSource = 'ENF'
          FROM #tmpResults rdc  
          JOIN dbo.EnfPositionDetails amd 
            ON rdc.AsOfDate = amd.AsOfDate 
           AND rdc.BbgTicker = CASE WHEN amd.InstrType = 'Listed Option' THEN amd.UnderlyBBYellowKey ELSE CASE WHEN amd.BBYellowKey = '' THEN amd.UnderlyBBYellowKey  ELSE amd.BBYellowKey END END
         WHERE rdc.Price IS NULL
           AND amd.FairValue != 0
           AND amd.InstrType IN ('Equity')
           AND rdc.Price IS NULL

    /*  PRICE WATERFALL STEP 3 - MAN PRICES  */
        UPDATE rdc 
           SET rdc.Price = amd.Price,
               rdc.PriceSource = 'MAN'
          FROM #tmpResults rdc  
          JOIN dbo.PriceHistory amd 
            ON rdc.AsOfDate = amd.AsOfDate 
           AND rdc.BbgTicker = amd.PositionId 
           AND rdc.Price IS NULL

    /*  XXXXXXXXXXXXXXXXXXXXXXXXXXXX  */
    /*  PRICE WATERFALL END           */
    /*  XXXXXXXXXXXXXXXXXXXXXXXXXXXX  */

    /*  SET CURRENCY CODE  */
        UPDATE rdc 
           SET rdc.Crncy = amd.CcyOne
          FROM #tmpResults rdc  
          JOIN dbo.EnfPositionDetails amd 
            ON rdc.AsOfDate = amd.AsOfDate 
           AND rdc.BbgTicker = CASE WHEN amd.InstrType = 'Listed Option' THEN amd.UnderlyBBYellowKey ELSE CASE WHEN amd.BBYellowKey = '' THEN amd.UnderlyBBYellowKey  ELSE amd.BBYellowKey END END

    /*  SET FXRATE FOR FX  */
        UPDATE rdc 
            SET rdc.FxRate = amd.Price
          FROM #tmpResults rdc  
          JOIN dbo.PriceHistory amd 
            ON rdc.AsOfDate = amd.AsOfDate 
            AND rdc.Crncy + ' Curncy' = amd.PositionId   
            AND amd.TagMnemonic = 'LAST_PRICE' 
   
    /*  SET FX RATE FOR USD  */ 
        UPDATE rdc 
            SET rdc.FxRate = 1.00
          FROM #tmpResults rdc  
          WHERE rdc.Crncy = 'USD'
            AND rdc.FxRate IS NULL

    /*  DOLLARIZE NON-USD PRICES  */
        UPDATE rdc
            SET rdc.PriceUsd = CASE WHEN rdc.Crncy = 'JPY' THEN rdc.Price / rdc.FxRate ELSE rdc.Price * rdc.FxRate END
          FROM #tmpResults rdc

        UPDATE rdc
            SET rdc.PriceUsd = CASE WHEN rdc.Crncy = 'JPY' THEN rdc.Price / rdc.FxRate ELSE rdc.Price * rdc.FxRate END
          FROM #tmpResults rdc

    /*  SET MARKET VALUE USD  */
        UPDATE rdc 
            SET rdc.MarketValue = Quantity * PriceUsd
          FROM #tmpResults rdc

    /*  SET STAT BETA  */
        UPDATE rdc
          SET rdc.StatBeta = sbv.BmkBeta
          FROM #tmpResults rdc
          JOIN dbo.StatisticalBetaValues sbv
            ON rdc.AsOfDate = sbv.AsOfDate
          AND CHARINDEX(sbv.Ticker, rdc.BbgTicker) != 0 

    /*  NO BETA ADJUSTMENT FOR EX-US Longs */
        UPDATE rdc
           SET rdc.StatBeta = 1  /* we do not beta adjust ex-US */
          FROM #tmpResults rdc
          
          --JOIN dbo.MSCiCorrelations msci
            --ON rdc.AsOfDate = msci.AsOfDate
           --AND CHARINDEX(msci.BbgYellowKey, rdc.BbgTicker) != 0
         
         WHERE rdc.BbgTicker IN ('4503 JP Equity') 



    /*  SET BetaAdjMktVal  */
        UPDATE rdc 
            SET rdc.BetaAdjMktVal = MarketValue * StatBeta
          FROM #tmpResults rdc

    /*  FEED THE PERIOD TABLE  */
        INSERT INTO #tmpResultsFinal(
               AsOfDate,
               Strategy,
               BbgTicker,
               Crncy,
               Quantity,
               Price,
               PriceSource,
               FxRate,
               PriceUsd,
               MarketValue,
               StatBeta,
               BetaAdjMktVal)
        SELECT AsOfDate,
               Strategy,
               BbgTicker,
               Crncy,
               Quantity,
               Price,
               PriceSource,
               FxRate,
               PriceUsd,
               MarketValue,
               StatBeta,
               BetaAdjMktVal
          FROM #tmpResultsFinal


    /*  ROLL ON TO THE NEXT DAY  */
        UPDATE tdy 
          SET tdy.bProcessed = 1 
          FROM #tmpDates tdy 
        WHERE tdy.AsOfDate = @AsOfDate
      


    END

        SELECT AsOfDate,
               Strategy,
               BbgTicker,
               Crncy,
               Quantity,
               Price,
               PriceSource,
               FxRate,
               PriceUsd,
               MarketValue,
               StatBeta,
               BetaAdjMktVal
          FROM #tmpResults
          ORDER BY AsOfDate,
               Strategy,
               BbgTicker

RETURN





/* Long Hand Enfusion Position Data  */
   SELECT epd.AsOfDate,
          epd.StratName,
          COALESCE(epd.UnderlyBBYellowKey, epd.BBYellowKey) AS BbgTicker,
          epd.InstDescr, 
          epd.InstrType,
          epd.CcyOne AS Crncy,
          epd.Quantity,
          epd.FairValue AS Price,
          'ENF' AS PriceSource,
          'NA' AS FxRate,
          epd.FairValue AS PriceUsd,
          epd.DeltaAdjMV,
          sbv.BmkBeta AS StatBeta,
          epd.DeltaAdjMV * sbv.BmkBeta  AS BetaAdjMktVal , epd.Account
     FROM dbo.EnfPositionDetails epd
     LEFT JOIN dbo.StatisticalBetaValues sbv
       ON epd.AsOfDate = sbv.AsOfDate
      AND CHARINDEX(sbv.Ticker, COALESCE(epd.UnderlyBBYellowKey, epd.BBYellowKey)) != 0
    WHERE epd.AsOfDate = '10/18/2024'
      AND epd.StratName = 'Alpha Long'
      AND CHARINDEX('Settled Cash', epd.InstDescr) = 0
      AND epd.Quantity != 0
      AND epd.FairValue != 0
    --AND CHARINDEX('ORUKA', epd.InstDescr) != 0
    ORDER BY epd.AsOfDate,
          epd.StratName,
          COALESCE(epd.UnderlyBBYellowKey, epd.BBYellowKey) 






