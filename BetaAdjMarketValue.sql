USE Operations
GO

/*

    Time for this to be a stored procedure 

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
    PosShort         FLOAT,
    Crncy            VARCHAR(12))

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

  CREATE TABLE #tmpStatBetas(
    AsOfDate         DATE,
    PortfolioName    VARCHAR(255),
    Ticker           VARCHAR(255),
    BbgYellowKey     VARCHAR(255),
    BmkBeta          FLOAT)


DECLARE @AsOfDate AS DATE
DECLARE @BegDate AS DATE = '12/01/2024'
DECLARE @EndDate AS DATE = '12/31/2024'

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
            PosShort,
            Crncy)
       EXEC dbo.p_GetLongPortfolio @AsOfDate = @AsOfDate, @bIncludeOptions = 1, @bRetCrncy = 1


    /* SET THE BASIS OF THE PORTFOLIO */
       INSERT INTO #tmpResults(
              AsOfDate,
              Strategy,
              BbgTicker,
              Quantity,
              Crncy)
       SELECT AsOfDate,
              Strategy,
              BbgTicker,
              PosLong,
              Crncy
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

    /*  PRICE WATERFALL STEP 1.5 - BIOTECH UNIVERSE PRICES  */
        UPDATE rdc 
           SET rdc.Price = bmu.Price,
               rdc.PriceSource = 'BMU'
          FROM #tmpResults rdc  
          JOIN dbo.BiotechMasterUniverse bmu 
            ON rdc.AsOfDate = bmu.AsOfDate 
           AND rdc.BbgTicker = bmu.BbgTicker
           AND rdc.Price IS NULL

    /*  PRICE WATERFALL STEP 1.5 - MARKET UNIVERSE PRICES  */          
        UPDATE rdc 
           SET rdc.Price = bmu.Price,
               rdc.PriceSource = 'MMU'
          FROM #tmpResults rdc  
          JOIN dbo.MarketMasterUniverse bmu 
            ON rdc.AsOfDate = bmu.AsOfDate 
           AND rdc.BbgTicker = bmu.BbgTicker
           AND rdc.Price IS NULL

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
           SET rdc.PriceUsd = CASE WHEN rdc.Crncy = 'JPY' OR rdc.Crncy = 'CAD' 
                                   THEN rdc.Price / rdc.FxRate 
                                   ELSE rdc.Price * rdc.FxRate 
                              END
          FROM #tmpResults rdc

    /*  SET MARKET VALUE USD  */
        UPDATE rdc 
           SET rdc.MarketValue = Quantity * PriceUsd
          FROM #tmpResults rdc

/*  >>>>>> >>>>>> +++++++ <<<<< <<<<<  */
/*  >>>>>> ALL ABOUT THE BETAS  <<<<<  */

      INSERT INTO #tmpStatBetas(
             AsOfDate,
             PortfolioName,
             Ticker,
             BbgYellowKey,
             BmkBeta)
      SELECT @AsOfDate,
             sbv.PortfolioName,
             sbv.Ticker,
             sbv.BbgYellowKey,
             AVG(COALESCE(sbv.BmkBeta, 1)) AS BmkBeta 
        FROM dbo.StatisticalBetaValues sbv
       WHERE sbv.AsOfDate BETWEEN DATEADD(D, -7, @AsOfDate) AND @AsOfDate
       GROUP BY sbv.PortfolioName,
             sbv.Ticker,
             sbv.BbgYellowKey
      
    /*  SET STAT BETA  */
        UPDATE rdc
           SET rdc.StatBeta = sbv.BmkBeta
          FROM #tmpResults rdc
          JOIN #tmpStatBetas sbv
            ON rdc.AsOfDate = sbv.AsOfDate
           AND sbv.BbgYellowKey = rdc.BbgTicker

    /*  NO BETA ADJUSTMENT FOR EX-US Longs */
        UPDATE rdc
           SET rdc.StatBeta = 1  /* we do not beta adjust ex-US */
          FROM #tmpResults rdc
         WHERE rdc.Crncy NOT IN ('USD', 'CAD') 

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






SELECT TOP 100 * FROM dbo.StatisticalBetaValues sbv WHERE sbv.BbgYellowKey = 'MSCL CN Equity' ORDER BY sbv.AsOfDate DESC

