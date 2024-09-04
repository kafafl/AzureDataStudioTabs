USE Operations
GO

DECLARE @AsOfDate AS DATE = '03/01/2023'
DECLARE @NAV AS FLOAT

SELECT TOP 1 @NAV = fad.AssetValue 
  FROM dbo.FundAssetsDetails fad
 WHERE fad.AsOfDate = @AsOfDate
   AND fad.Entity = 'AMF NAV'


/*  */

IF EXISTS(SELECT 1 FROM #tmpPaperPort)
  BEGIN
    DROP TABLE #tmpPaperPort
  END



CREATE TABLE #tmpPaperPort(
  sTicker     VARCHAR(255),
  sName       VARCHAR(255),
  bIsUsed     BIT DEFAULT 0)

INSERT INTO #tmpPaperPort(sTicker, sName) SELECT 'ALPN', 'Alpine'
INSERT INTO #tmpPaperPort(sTicker, sName) SELECT 'RYTM', 'Rhythm'
INSERT INTO #tmpPaperPort(sTicker, sName) SELECT 'MLTX', 'Moonlake'
INSERT INTO #tmpPaperPort(sTicker, sName) SELECT 'SVRA', 'Savara'
INSERT INTO #tmpPaperPort(sTicker, sName) SELECT 'ACLX', 'Arcellx'
INSERT INTO #tmpPaperPort(sTicker, sName) SELECT 'URGN', 'Urogen'
INSERT INTO #tmpPaperPort(sTicker, sName) SELECT 'KALV', 'Kalvista'
INSERT INTO #tmpPaperPort(sTicker, sName) SELECT 'TVTX', 'Travere'
INSERT INTO #tmpPaperPort(sTicker, sName) SELECT '4568', 'Daiichi'
INSERT INTO #tmpPaperPort(sTicker, sName) SELECT 'CRBU', 'Caribou'
INSERT INTO #tmpPaperPort(sTicker, sName) SELECT 'RNA', 'Avidity'
INSERT INTO #tmpPaperPort(sTicker, sName) SELECT 'ANAB', 'Anaptys'
INSERT INTO #tmpPaperPort(sTicker, sName) SELECT 'PLRX', 'Pliant'
INSERT INTO #tmpPaperPort(sTicker, sName) SELECT 'RAPT', 'Rapt'
INSERT INTO #tmpPaperPort(sTicker, sName) SELECT 'PYXS', 'Pyxis'
INSERT INTO #tmpPaperPort(sTicker, sName) SELECT 'SDGR', 'Schrodinger'
INSERT INTO #tmpPaperPort(sTicker, sName) SELECT 'EXAI', 'Exscientia'
INSERT INTO #tmpPaperPort(sTicker, sName) SELECT 'NKTR', 'Nektar'
INSERT INTO #tmpPaperPort(sTicker, sName) SELECT 'RLMD', 'Relmada'
INSERT INTO #tmpPaperPort(sTicker, sName) SELECT 'RLYB', 'Rallybio'
INSERT INTO #tmpPaperPort(sTicker, sName) SELECT 'EBS', 'Emergent'
INSERT INTO #tmpPaperPort(sTicker, sName) SELECT 'ACRS', 'Aclaris'
INSERT INTO #tmpPaperPort(sTicker, sName) SELECT 'KPTI', 'Karyopharm'
INSERT INTO #tmpPaperPort(sTicker, sName) SELECT 'ERAS', 'Erasca'
INSERT INTO #tmpPaperPort(sTicker, sName) SELECT 'ARQT', 'Arcutis'


--SELECT * FROM #tmpPaperPort


UPDATE tpp
   SET tpp.bIsUsed = 1
  FROM #tmpPaperPort tpp
  JOIN dbo.EnfPositionDetails epd
    ON CHARINDEX(tpp.sTicker, epd.BBYellowKey) != 0
 WHERE epd.AsOfDate = @AsOfDate
   AND epd.Quantity != 0


SELECT epd.AsOfDate,
       epd.BBYellowKey,
       epd.InstDescr,
       epd.Quantity,
       epd.DeltaAdjMV,
       epd.DeltaExp,
       epd.DeltaAdjMV/@NAV As '%ofNAV',
       @NAV as NetAssetValue
  FROM dbo.EnfPositionDetails epd
  JOIN #tmpPaperPort tpp
    ON CHARINDEX(tpp.sTicker, epd.BBYellowKey) != 0
 WHERE epd.AsOfDate = @AsOfDate
   AND epd.Quantity != 0
 UNION
SELECT @AsOfDate AS AsOfDate,
       tpp.sTicker,
       tpp.sName,
       0,
       0,
       0,
       0,
       @NAV
  FROM #tmpPaperPort tpp
 WHERE tpp.bIsUsed = 0
 ORDER BY epd.InstDescr
        














/*

DECLARE @AsOfDate AS DATE = '02/15/2023'

SELECT fad.AsOfDate,
       fad.AssetValue
 FROM dbo.FundAssetsDetails fad
 WHERE fad.AsOfDate BETWEEN @AsOfDate AND DATEADD(d, 60, @AsOfDate) 
 ORDER BY fad.AsOfDate


 SELECT TOP 100 *  FROM dbo.FundAssetsDetails fad ORDER BY fad.AsOfDate DESC

*/