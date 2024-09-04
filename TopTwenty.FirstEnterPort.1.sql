USE Operations
GO

/*
DROP TABLE #tmpTopTwentyPort
GO
DROP TABLE #tmpPosHist
GO
*/

CREATE TABLE #tmpTopTwentyPort(
  sTicker     VARCHAR(255),
  sName       VARCHAR(255),
  dtFirstPort DATE,
  fFirstQuant FLOAT,
  bReachZero  BIT DEFAULT 0,
  dtLastZero  DATE,
  sNotes      VARCHAR(500),
  bIsUsed     BIT DEFAULT 0)

CREATE TABLE #tmpPosHist(
  AsOfDate    DATE,
  sStratName  VARCHAR(255),
  sTicker     VARCHAR(255),
  Quantity    FLOAT)  



/*
INSERT INTO #tmpTopTwentyPort(sTicker, sName) SELECT '4568', 'DAIICHI SANKO ORD'
INSERT INTO #tmpTopTwentyPort(sTicker, sName) SELECT 'ABVX', 'ABIVAX SA ADR'
INSERT INTO #tmpTopTwentyPort(sTicker, sName) SELECT 'ALPN', 'ALPINE IMMUNE SCIENCES ORD'
INSERT INTO #tmpTopTwentyPort(sTicker, sName) SELECT 'ANAB', 'ANAPTYSBIO ORD'
INSERT INTO #tmpTopTwentyPort(sTicker, sName) SELECT 'APGE', 'APOGEE THERAPEUTICS ORD'
INSERT INTO #tmpTopTwentyPort(sTicker, sName) SELECT 'AVTE', 'AEROVATE THERAPEUTICS ORD'
INSERT INTO #tmpTopTwentyPort(sTicker, sName) SELECT 'CGEM', 'CULLINAN ONCOLOGY ORD'
INSERT INTO #tmpTopTwentyPort(sTicker, sName) SELECT 'CNTA', 'CENTESSA PHARMACEUTICALS ADR'
INSERT INTO #tmpTopTwentyPort(sTicker, sName) SELECT 'CRNX', 'CRINETICS PHARMACEUTICALS ORD'
INSERT INTO #tmpTopTwentyPort(sTicker, sName) SELECT 'CYTK', 'CYTOKINETICS ORD'
INSERT INTO #tmpTopTwentyPort(sTicker, sName) SELECT 'DNTH', 'DIANTHUS THERAPEUTICS ORD'
INSERT INTO #tmpTopTwentyPort(sTicker, sName) SELECT 'EOLS', 'EVOLUS ORD'
INSERT INTO #tmpTopTwentyPort(sTicker, sName) SELECT 'FULC', 'FULCRUM THERAPEUTICS ORD'
INSERT INTO #tmpTopTwentyPort(sTicker, sName) SELECT 'JSPR', 'JASPER THEREAPEUTICS ORD'
INSERT INTO #tmpTopTwentyPort(sTicker, sName) SELECT 'KROS', 'KEROS THEREAPEUTICS ORD'
INSERT INTO #tmpTopTwentyPort(sTicker, sName) SELECT 'LNTH', 'LANTHEUS HOLDINGS ORD'
INSERT INTO #tmpTopTwentyPort(sTicker, sName) SELECT 'TRML', 'TOURMALINE BIO ORD'
INSERT INTO #tmpTopTwentyPort(sTicker, sName) SELECT 'VKTX', 'VIKING THEREAPEUTIC ORD'
INSERT INTO #tmpTopTwentyPort(sTicker, sName) SELECT 'VRDN', 'VIRIDIAN THERAPEUTICS ORD'
INSERT INTO #tmpTopTwentyPort(sTicker, sName) SELECT 'XENE', 'XENON PHARMACEUTICALS ORD'
  USE TO LIMIT NUMBER OR RECORDS DURING TESTING  
*/

DECLARE @sTicker AS VARCHAR(50)
DECLARE @cQuantity AS FLOAT = 0
DECLARE @BegDate AS DATE = '01/01/2023'
DECLARE @EndDate AS DATE = '04/30/2024'
DECLARE @ActvDate AS DATE
DECLARE @sNotes AS VARCHAR(MAX)
DECLARE @cQuantLast AS FLOAT
DECLARE @dDateLast AS DATE
DECLARE @dtLastZero AS DATE

  WHILE EXISTS(SELECT 1 FROM #tmpTopTwentyPort ttp WHERE ttp.bIsUsed = 0)
    BEGIN

      SELECT TOP 1 @sTicker = ttp.sTicker FROM #tmpTopTwentyPort ttp WHERE ttp.bIsUsed = 0 ORDER BY ttp.sTicker

      SELECT @ActvDate = @BegDate
      DELETE tph FROM #tmpPosHist tph

      INSERT INTO #tmpPosHist(
             AsOfDate,
             sStratName,
             sTicker,
             Quantity)
      SELECT epd.AsOfDate,
             epd.StratName,
             @sTicker,
             SUM(epd.Quantity) AS Quantity 
        FROM dbo.EnfPositionDetails epd
        JOIN dbo.DateMaster dtm
          ON epd.AsOfDate = dtm.AsOfDate
       WHERE epd.AsOfDate BETWEEN @BegDate AND @EndDate
         AND CHARINDEX(@sTicker, epd.BBYellowKey) != 0
         AND CHARINDEX('Alpha Long', epd.BookName) != 0
         AND epd.InstrType = 'Equity'
         AND dtm.IsWeekday = 1
       GROUP BY epd.AsOfDate,
             epd.StratName
        ORDER BY epd.AsOfDate ASC

        SELECT TOP 1 @ActvDate = tph.AsOfDate FROM #tmpPosHist tph WHERE ROUND(tph.Quantity, 0) = 0 ORDER BY tph.AsOfDate DESC

        SELECT TOP 1
               @dDateLast = tph.AsOfDate,
               @cQuantLast = tph.Quantity
          FROM #tmpPosHist tph
         WHERE tph.AsOfDate > @ActvDate AND tph.AsOfDate < @EndDate
           AND tph.sTicker = @sTicker
           AND ROUND(tph.Quantity, 0) != 0
          ORDER BY tph.AsOfDate ASC

/**/
        IF (DATEDIFF(dd, @BegDate, @ActvDate) > 1)
          BEGIN
            SELECT TOP 1 @dtLastZero = epd.AsOfDate FROM dbo.EnfPositionDetails epd WHERE epd.AsOfDate < @dDateLast ORDER BY epd.AsOfDate DESC
          END 
        ELSE
          BEGIN
            SELECT @dtLastZero = NULL
          END

        UPDATE ttp
           SET ttp.dtFirstPort = @dDateLast,
               ttp.fFirstQuant = @cQuantLast,
               ttp.bReachZero = CASE WHEN @ActvDate = @BegDate THEN 0 ELSE 1 END,
               ttp.dtLastZero = @dtLastZero
          FROM #tmpTopTwentyPort ttp
         WHERE ttp.sTicker = @sTicker
         
        UPDATE ttp
           SET ttp.bIsUsed = 1
          FROM #tmpTopTwentyPort ttp 
         WHERE ttp.sTicker = @sTicker 
           AND ttp.bIsUsed = 0 

    END


SELECT * FROM #tmpTopTwentyPort



--SELECT TOP 1 epd.AsOfDate FROM dbo.EnfPositionDetails epd WHERE epd.AsOfDate < @ActvDate ORDER BY epd.AsOfDate DESC




/*
SELECT TOP 1000 epd.AsOfDate, epd.BookName, epd.StratName, epd.BBYellowKey, epd.Quantity, epd.InstrType 

FROM dbo.EnfPositionDetails epd 

WHERE CHARINDEX('APGE', epd.BBYellowKey) != 0 

AND epd.InstrType = 'Equity'    

AND epd.AsOfDate BETWEEN '01/01/2023' AND '02/29/2024'  

ORDER BY epd.AsOfDate DESC
*/

