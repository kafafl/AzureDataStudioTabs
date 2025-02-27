USE Operations
GO

/*  QUBE REQUEST  */
CREATE TABLE #tmpOutput(
    AsOfDate                   DATE,
    BBG                        VARCHAR(255),
    RIC                        VARCHAR(255),
    SEDOL                      VARCHAR(255),
    ISIN                       VARCHAR(255),
    CUSIP                      VARCHAR(255),
    [Custom Identifier]        VARCHAR(255),
    [Instrument Type]          VARCHAR(255),
    [Listing Country]          VARCHAR(255),
    [Listing Sector]           VARCHAR(255),
    [Shares/Qty]               FLOAT,
    [Notional Value]           FLOAT,
    [Net Market Value]         FLOAT,
    Delta                      FLOAT,
    [Delta Adj Net Exp]        FLOAT,
    [Portfolio Total AUM/NAV]  FLOAT,
    [Reporting Currency Code]  VARCHAR(255),
    [InstDescr]                VARCHAR(255),
    UnderlyingBbg              VARCHAR(255))

CREATE TABLE #tmpDates(
    AsOfDate                   DATE)



INSERT INTO #tmpDates (AsOfDate) SELECT '01/31/2023'
INSERT INTO #tmpDates (AsOfDate) SELECT '02/28/2023'
INSERT INTO #tmpDates (AsOfDate) SELECT '03/31/2023'
INSERT INTO #tmpDates (AsOfDate) SELECT '04/28/2023'
INSERT INTO #tmpDates (AsOfDate) SELECT '05/31/2023'
INSERT INTO #tmpDates (AsOfDate) SELECT '06/30/2023'
INSERT INTO #tmpDates (AsOfDate) SELECT '07/31/2023'
INSERT INTO #tmpDates (AsOfDate) SELECT '08/31/2023'
INSERT INTO #tmpDates (AsOfDate) SELECT '09/29/2023'
INSERT INTO #tmpDates (AsOfDate) SELECT '10/31/2023'
INSERT INTO #tmpDates (AsOfDate) SELECT '11/30/2023'
INSERT INTO #tmpDates (AsOfDate) SELECT '12/29/2023'

INSERT INTO #tmpDates (AsOfDate) SELECT '01/31/2024'
INSERT INTO #tmpDates (AsOfDate) SELECT '02/29/2024'
INSERT INTO #tmpDates (AsOfDate) SELECT '03/28/2024'
INSERT INTO #tmpDates (AsOfDate) SELECT '04/30/2024'
INSERT INTO #tmpDates (AsOfDate) SELECT '05/31/2024'
INSERT INTO #tmpDates (AsOfDate) SELECT '06/28/2024'
INSERT INTO #tmpDates (AsOfDate) SELECT '07/31/2024'
INSERT INTO #tmpDates (AsOfDate) SELECT '08/30/2024'
INSERT INTO #tmpDates (AsOfDate) SELECT '09/30/2024'
INSERT INTO #tmpDates (AsOfDate) SELECT '10/31/2024'
INSERT INTO #tmpDates (AsOfDate) SELECT '11/29/2024'
INSERT INTO #tmpDates (AsOfDate) SELECT '12/31/2024'

INSERT INTO #tmpDates (AsOfDate) SELECT '1/31/2025'

--DECLARE @BegDate AS DATE = '09/30/2024'
--DECLARE @EndDate AS DATE = '09/30/2024'

INSERT INTO #tmpOutput(
       AsOfDate,
       BBG,
       RIC,
       SEDOL,
       ISIN,
       CUSIP,
       [Custom Identifier],
       [Instrument Type],
       [Listing Country],
       [Listing Sector],
       [Shares/Qty],
       [Notional Value],
       [Net Market Value],
       Delta,
       [Delta Adj Net Exp],
       [Portfolio Total AUM/NAV],
       [Reporting Currency Code],
       [InstDescr],
       UnderlyingBbg)
SELECT epd.AsOfDate,
       CASE WHEN epd.InstrType IN ('OTC Option') THEN epd.InstDescr WHEN epd.InstDescr = 'MSA14568' THEN 'MSA14568 Index' ELSE epd.BBYellowKey END AS BBG,
       NULL AS RIC,
       NULL AS SEDOL,
       NULL AS ISIN,
       NULL AS CUSIP,
       NULL AS [Custom Identifier],
       epd.InstrType AS [Instrument Type],
       NULL AS [Listing Country],
       NULL AS [Listing Sector],
       epd.Quantity AS [Shares/Qty],
       NULL AS [Notional Value],
       epd.NetMarketValue,
       epd.Delta,
       epd.DeltaAdjMV,
       NULL AS [AUM],
       epd.CcyOne,
       epd.InstDescr,
       CASE WHEN epd.InstDescr = 'MSA14568' THEN 'MSA14568 Index' ELSE epd.UnderlyBBYellowKey END AS BBG
  FROM dbo.EnfPositionDetails epd
 WHERE epd.AsOfDate IN (SELECT dt.AsOfDate FROM #tmpDates dt)
   AND (ROUND(COALESCE(epd.Quantity, 0), 0) != 0 AND ROUND(COALESCE(epd.NetMarketValue, 0), 0) != 0)
   AND epd.Account NOT IN ('Non-Trading')
   AND epd.InstrType NOT IN ('Cash', 'FX Forward')
 ORDER BY CASE WHEN epd.BBYellowKey = '' THEN 'zzz_' + epd.InstDescr ELSE ''END, 
       epd.Account,
       epd.InstrType,
       epd.InstDescr
 
 UPDATE toc
    SET toc.UnderlyingBbg = 'ABVX US Equity'
   FROM #tmpOutput toc
  WHERE toc.UnderlyingBbg = 'ABVX FP Equity'

 UPDATE toc
    SET toc.[Listing Sector] = bmu.GICS_sector,
        toc.SEDOL = bmu.IdSEDOL,
        toc.CUSIP = bmu.IdCUSIP
   FROM #tmpOutput toc
   JOIN dbo.BiotechMasterUniverse bmu
     ON bmu.AsOfDate = toc.AsOfDate
    AND bmu.BbgTicker = toc.UnderlyingBbg

 UPDATE toc
    SET toc.[Listing Sector] = bmu.GICS_sector,
        toc.SEDOL = bmu.IdSEDOL,
        toc.CUSIP = bmu.IdCUSIP
   FROM #tmpOutput toc
   JOIN dbo.MarketMasterUniverse bmu
     ON bmu.AsOfDate = toc.AsOfDate
    AND bmu.BbgTicker = toc.UnderlyingBbg

  UPDATE toc
    SET toc.BBG = toc.UnderlyingBbg
   FROM #tmpOutput toc
  WHERE toc.[Instrument Type] = 'Warrant'
    AND COALESCE(toc.UnderlyingBbg, '') != ''

 UPDATE toc
    SET toc.[Custom Identifier] = toc.InstDescr
   FROM #tmpOutput toc
  WHERE COALESCE(toc.BBG, '') = ''
    AND (CHARINDEX('Private', toc.InstDescr) != 0 OR CHARINDEX('Preferred', toc.InstDescr) != 0)

 UPDATE toc
    SET toc.BBG = epx.BBYellowKey
   FROM #tmpOutput toc
   JOIN (SELECT DISTINCT epd.InstDescr, epd.BBYellowKey FROM dbo.EnfPositionDetails epd WHERE epd.AsOfDate IN (SELECT AsOfDate FROM #tmpDates)) epx
     ON toc.InstDescr = epx.InstDescr
  WHERE COALESCE(toc.BBG, '') = ''
    AND (CHARINDEX('Private', toc.InstDescr) != 0 OR CHARINDEX('Preferred', toc.InstDescr) != 0)


/*  BACKFILL PRE-DATABASE DAILY VALUES  */
 UPDATE toc
    SET toc.[Listing Sector] = bmx.GICS_sector,
        toc.SEDOL = bmx.IdSEDOL,
        toc.CUSIP = bmx.IdCUSIP
   FROM #tmpOutput toc
   JOIN (SELECT distinct bmu.BbgTicker, bmu.GICs_sector, bmu.IdSEDOL, bmu.IdCUSIP FROM dbo.BiotechMasterUniverse bmu) bmx
     ON bmx.BbgTicker = toc.UnderlyingBbg
  WHERE COALESCE(toc.[Listing Sector], '') = ''
    AND COALESCE(toc.SEDOL, '') = ''
    AND COALESCE(toc.CUSIP, '') = ''

 UPDATE toc
    SET toc.[Listing Sector] = bmx.GICS_sector,
        toc.SEDOL = bmx.IdSEDOL,
        toc.CUSIP = bmx.IdCUSIP
   FROM #tmpOutput toc
   JOIN (SELECT distinct bmu.BbgTicker, bmu.GICs_sector, bmu.IdSEDOL, bmu.IdCUSIP FROM dbo.MarketMasterUniverse bmu) bmx
     ON bmx.BbgTicker = toc.UnderlyingBbg
  WHERE COALESCE(toc.[Listing Sector], '') = ''
    AND COALESCE(toc.SEDOL, '') = ''
    AND COALESCE(toc.CUSIP, '') = ''


 UPDATE toc
    SET toc.[Portfolio Total AUM/NAV] = fad.AssetValue
   FROM #tmpOutput toc
   JOIN dbo.FundAssetsDetails fad
     ON toc.AsOfDate = fad.AsOfDate
  WHERE fad.Entity = 'AMF NAV'

 UPDATE toc
    SET toc.[Custom Identifier] = toc.InstDescr
   FROM #tmpOutput toc
  WHERE COALESCE(toc.BBG, '') = '' AND COALESCE(toc.[Custom Identifier], '') = ''

            
      SELECT * 
        FROM #tmpOutput toc 
       WHERE (COALESCE(toc.BBG, '') != '' OR COALESCE(toc.[Custom Identifier], '') != '')
       ORDER BY toc.AsOfDate, toc.InstDescr
            
            
RETURN

/*   XXXXXXXXXXXXXXXX   */
/*   EXTRACT THE DATA   */
/*   XXXXXXXXXXXXXXXX   */

        SELECT * 
        FROM #tmpOutput toc 
        WHERE (COALESCE(toc.BBG, '') != '' OR COALESCE(toc.[Custom Identifier], '') != '')
        ORDER BY toc.AsOfDate, toc.InstDescr

        SELECT * FROM #tmpOutput toc WHERE toc.BBG != '' ORDER BY toc.AsOfDate, toc.InstDescr

        SELECT * FROM #tmpOutput toc 
        WHERE toc.BBG = '' 
        AND  toc.[Custom Identifier]  = '' 
        ORDER BY toc.AsOfDate, toc.InstDescr


SELECT DISTINCT toc.AsOfDate FROM #tmpOutput toc ORDER BY toc.AsOfDate

