

DECLARE @AsOfDate AS DATE = '07/31/2024'

DECLARE @BegDate AS DATE = '01/01/2023'
DECLARE @EndDate AS DATE = '07/31/2024'


/*

*/

CREATE TABLE #tmpOutput(
    AsOfDate            DATE,
    BBYellowKey         VARCHAR(255),
    UnderlyBBYellowKey  VARCHAR(255),
    InstDescr           VARCHAR(255),
    Ccy                 VARCHAR(255),
    Strategy            VARCHAR(255),
    SubStrategy         VARCHAR(255),
    InstrType           VARCHAR(255),
    Quantity            FLOAT,
    Price               FLOAT,
    FxRate              FLOAT,
    ExpOfNav            FLOAT,
    LongShort           VARCHAR(255),
    IsHedge             BIT NOT NULL DEFAULT 0,
    DlyPnlUsd           FLOAT,
    FxPnlUsd            FLOAT,
    DlyPnlUnreal        FLOAT,
    DlyPnlReal          FLOAT,
    DlyPnlOfNav         FLOAT,
    FxPnlPct            FLOAT,
    DlyUnrealPct        FLOAT,
    DlyRealPct          FLOAT,
    DeltaAdjMV          FLOAT,
    DeltaAdjMvPrev      FLOAT,
    PrevAsOfDate        DATE,
    MarketValue         FLOAT,
    Nav                 FLOAT)

CREATE TABLE #tmpFxRates(
    AsOfDate            DATE,
    Ccy                 VARCHAR(255),
    FxRate              FLOAT)

INSERT INTO #tmpOutput(
       AsOfDate,
       BBYellowKey,
       UnderlyBBYellowKey,
       InstDescr,
       Ccy,
       Strategy,
       SubStrategy,
       InstrType,
       Quantity,
       Price,
       FxRate,
       ExpOfNav,
       LongShort,
       IsHedge,
       DlyPnlUsd,
       FxPnlUsd,
       DlyPnlUnreal,
       DlyPnlReal,
       DlyPnlOfNav,
       FxPnlPct,
       DlyUnrealPct,
       DlyRealPct,
       DeltaAdjMV,
       DeltaAdjMvPrev,
       PrevAsOfDate,
       MarketValue)
SELECT apd.AsOfDate,
       apd.BbgCode,
       apd.IssuerSymbol,
       apd.SecName,
       apd.CcyCode AS Ccy,
       apd.Strategy AS Strategy,
       apd.TopLevelTag,
       NULL,
       apd.Quantity,
       apd.Price AS Price,
       NULL,
       NULL,
       apd.LS_Exposure,
       CASE WHEN CHARINDEX('Hedge', apd.HedgeCore) != 0 THEN 1 ELSE 0 END,
       apd.DtdPnlUsd,
       NULL AS FxPnlUsd,
       NULL AS DlyPnlUnreal,
       NULL AS DlyPnlReal,
       NULL, --apd.DlyPnlOfNav,
       NULL AS FxPnlUsdPct,
       NULL AS DlyUnrealPct,
       NULL AS DlyRealPct,
       apd.DeltaExpGross,
       NULL,
       NULL,
       apd.MktValueGross
  FROM dbo.AdminPositionDetails apd
 WHERE apd.AsOfDate BETWEEN @BegDate AND @EndDate
   AND ROUND(COALESCE(apd.Quantity, 0), 0) != 0
   AND apd.BbgCode != '' AND apd.BbgCode != 'N/A'
 ORDER BY apd.AsOfDate,
       apd.Strategy,
       apd.TopLevelTag
GO



INSERT INTO #tmpFxRates(
       AsOfDate,
       Ccy,
       FxRate)
SELECT phx.AsOfDate, 
       CASE WHEN phx.PositionId = 'JPY Curncy' THEN 'JPY'
            WHEN phx.PositionId = 'EUR Curncy' THEN 'EUR'
            WHEN phx.PositionId = 'CAD Curncy' THEN 'CAD'
            WHEN phx.PositionId = 'AUD Curncy' THEN 'AUD'
       END AS Ccy,
       phx.Price AS FxRate
  FROM dbo.PriceHistory phx  
 WHERE phx.TagMnemonic = 'LAST_PRICE' 
   AND phx.PositionId IN ('JPY Curncy', 'EUR Curncy', 'CAD Curncy', 'AUD Curncy') 
 ORDER BY phx.AsOfDate DESC, 2

UPDATE tox
   SET tox.FxRate = trx.FxRate
  FROM #tmpOutput tox
  JOIN #tmpFxRates trx
    ON tox.AsOfDate = trx.AsOfDate
   AND tox.Ccy = trx.Ccy

UPDATE tox
   SET tox.FxRate = 1.00
  FROM #tmpOutput tox
 WHERE tox.Ccy = 'USD'
   AND tox.FxRate IS NULL


UPDATE tox
   SET tox.Nav = fad.AssetValue
  FROM #tmpOutput tox
  JOIN dbo.FundAssetsDetails fad
    ON tox.AsOfDate = fad.AsOfDate
 WHERE fad.Entity = 'AMF NAV'

UPDATE tox
   SET tox.ExpOfNav = CASE WHEN COALESCE(tox.MarketValue, 0) != 0 AND COALESCE(tox.Nav, 0) != 0 THEN  COALESCE(tox.MarketValue, 0) /COALESCE(tox.Nav, 0) ELSE 0 END
  FROM #tmpOutput tox
 

SELECT * 
  FROM #tmpOutput
  ORDER BY 1, 6, 7, 2
GO



/*
       SELECT * 
       FROM dbo.EnfPositionDetails epd
       WHERE epd.AsOfDate = '07/30/2024'


       SELECT TOP 10000 * FROM dbo.DateMaster dbx


  FROM dbo.EnfPositionDetails epd
  --JOIN dbo.DateMaster dbx
    --ON epd.AsOfDate = dbx.AsOfDate
 WHERE epd.AsOfDate BETWEEN @BegDate AND @EndDate
   --AND dbx.IsMktHoliday = 0 AND dbx.IsWeekday = 1
   AND (CHARINDEX('Alpha Long', epd.StratName) != 0 OR CHARINDEX('Alpha Short', epd.StratName) != 0 OR CHARINDEX('Hedge', epd.StratName) != 0)
   AND ROUND(COALESCE(epd.Quantity, 0), 0) != 0
   AND epd.InstrType IN ('Equity', 'Index', 'Future')
   --AND epd.Account = 'MS Cash'
   AND epd.BBYellowKey != ''
 ORDER BY epd.AsOfDate,
       epd.StratName,
       epd.BookName





*/



