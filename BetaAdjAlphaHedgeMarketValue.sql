USE Operations
GO


/*
SELECT * FROM dbo.DateMaster dmt
WHERE dmt.AsOfDate BETWEEN '08/01/2024' AND '10/16/2024'
AND dmt.IsWeekday = 1
ORDER BY dmt.AsOfDate

 SELECT TOP 100 * FROM dbo.MSCICorrelations msci
 WHERE CHARINDEX('MSA14568', msci.Ticker) != 0

 WHERE msci.BbgYellowKey IN ('MSA14568 Index', 'MSA1BIOH Index')

INSERT INTO dbo.StatisticalBetaValues(AsOfDate, PortfolioName, Ticker, BbgYellowKey, BmkBeta, CreatedBy, CreatedOn)
SELECT '2024-09-30', 'AMF', 'ZIM', 'ZIM US Equity', 0.78, SUSER_NAME(), GETDATE()

SELECT TOP 100 * 
  FROM dbo.StatisticalBetaValues sbv 
 WHERE sbv.BbgYellowKey IN ('MSA14568 Index', 'xMSA1BIOH Index', 'xIWM US Equity', 'xSPY US Equity', 'xXBI US Equity')
 AND sbv.AsOfDate BETWEEN '08/30/2024' AND '10/22/2024'
 ORDER BY sbv.AsOfDate

UPDATE sbv 
   SET sbv.BmkBeta = 1.00 
  FROM dbo.StatisticalBetaValues sbv 
 WHERE sbv.AsOfDate BETWEEN '08/30/2024' AND '10/14/2024'
   AND sbv.BbgYellowKey = 'XBI US Equity'

UPDATE sbv 
   SET sbv.BmkBeta = 0.75 
  FROM dbo.StatisticalBetaValues sbv 
 WHERE sbv.AsOfDate = '10/14/2024' 
   AND sbv.BbgYellowKey = 'IWM US Equity'

UPDATE sbv SET sbv.BmkBeta = 0.15 FROM dbo.StatisticalBetaValues sbv WHERE sbv.AsOfDate = '10/14/2024' AND sbv.BbgYellowKey = 'MSA14568 Index'

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
DECLARE @BegDate AS DATE = '09/01/2024'
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


/*   CLEAR CONTENTS OF DAILY TABLE  */
     DELETE tpx FROM #tmpPortfolio tpx

     INSERT INTO #tmpPortfolio(
            AsOfDate,
            Strategy,
            BbgTicker,
            PosLong,
            PosNet,
            PosShort)
       EXEC dbo.p_GetHedgePortfolio @AsOfDate = @AsOfDate, @bIncludeOptions = 1


    /* SET THE BASIS OF THE PORTFOLIO */
       INSERT INTO #tmpResults(
              AsOfDate,
              Strategy,
              BbgTicker,
              Quantity)
       SELECT AsOfDate,
              Strategy,
              BbgTicker,
              CASE WHEN COALESCE(tpp.PosShort, 0) = 0 THEN tpp.PosLong ELSE tpp. PosShort END
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
           AND amd.InstrType IN ('Equity', 'Index', 'Future')
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

    /*  SET CURRENCY CODE  */
        UPDATE rdc 
           SET rdc.Crncy = 'JPY'
          FROM #tmpResults rdc  
         WHERE rdc.BbgTicker = 'MSA14568 Index' 

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
          --WHERE Quantity != 0
          ORDER BY AsOfDate,
               Strategy,
               BbgTicker

RETURN












