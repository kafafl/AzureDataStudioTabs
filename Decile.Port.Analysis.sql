USE Operations
GO
 
CREATE TABLE #tmpOutput(
    BegDate    DATE,
    EndDate    DATE,
    Ticker     VARCHAR(255),
    MarketValue  FLOAT,
    MtdPnlUsd    FLOAT)
 
DECLARE @BegDate AS DATE = '01/01/2024'
DECLARE @EndDate AS DATE = '01/31/2024'
 
SELECT TOP 1 @BegDate = epd.AsOfDate FROM dbo.EnfPositionDetails epd
WHERE epd.AsOfDate <= @BegDate ORDER BY epd.AsOfDate DESC
 
SELECT TOP 1 @EndDate = epd.AsOfDate FROM dbo.EnfPositionDetails epd
WHERE epd.AsOfDate <= @EndDate ORDER BY epd.AsOfDate DESC
 
 
 INSERT INTO #tmpOutput(
        BegDate,
        EndDate,
        Ticker,
        MarketValue)
 SELECT @BegDate,
        @EndDate,
        epx.Ticker,
        AVG(epx.MV) AS MV
   FROM (SELECT epd.AsOfDate,
                COALESCE(UnderlyBBYellowKey, BBYellowKey) AS Ticker,
                SUM(COALESCE(epd.NetMarketValue, 0)) AS MV
           FROM dbo.EnfPositionDetails epd
          WHERE epd.AsOfDate BETWEEN @BegDate AND @EndDate
            AND epd.StratName IN ('Alpha Long', 'Alpha Shortxxx')
            AND epd.InstrType IN('Equity', 'Listed Option')
            AND LTRIM(RTRIM(COALESCE(UnderlyBBYellowKey, BBYellowKey))) != ''
            AND COALESCE(UnderlyBBYellowKey, BBYellowKey) NOT IN ('XBI US Equity')
          GROUP BY epd.AsOfDate,
                COALESCE(UnderlyBBYellowKey, BBYellowKey)
         HAVING ROUND(AVG(epd.Quantity), 0) != 0) epx
  GROUP BY epx.Ticker
  ORDER BY epx.Ticker
  
  SELECT *
    FROM #tmpOutput
    ORDER BY Ticker





/*  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  */
/*  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  */
/*  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  */

CREATE TABLE #tmpOutputBsk(
    BegDate    DATE,
    EndDate    DATE,
    Ticker     VARCHAR(255),
    Wght       FLOAT)
 
DECLARE @BegDate AS DATE = '03/01/2024'
DECLARE @EndDate AS DATE = '03/31/2024'
 
SELECT TOP 1 @BegDate = epd.AsOfDate FROM dbo.MspbBasketDetails epd
WHERE epd.AsOfDate <= @BegDate ORDER BY epd.AsOfDate DESC
 
SELECT TOP 1 @EndDate = epd.AsOfDate FROM dbo.MspbBasketDetails epd
WHERE epd.AsOfDate <= @EndDate ORDER BY epd.AsOfDate DESC
 
 
 INSERT INTO #tmpOutputBsk(
        BegDate,
        EndDate,
        Ticker,
        Wght)
 SELECT @BegDate,
        @EndDate,
        epx.Ticker,
        AVG(epx.Wght) AS MV
   FROM (SELECT epd.AsOfDate,
                epd.CompBbg + ' Equity' AS Ticker,
                SUM(COALESCE(epd.PctWeight , 0))/100 AS Wght
           FROM dbo.MspbBasketDetails epd
          WHERE epd.AsOfDate BETWEEN @BegDate AND @EndDate
            AND epd.BasketTicker = 'MSA1BIOH'
          GROUP BY epd.AsOfDate,
                epd.CompBbg) epx
  GROUP BY epx.Ticker
  ORDER BY epx.Ticker
  
  SELECT *
    FROM #tmpOutputBsk
    ORDER BY Ticker

    SELECT epd.BasketTicker,
           AVG(epd.ExpNotional)
      FROM dbo.MspbBasketDetails epd
     WHERE epd.AsOfDate BETWEEN @BegDate AND @EndDate
       AND epd.BasketTicker = 'MSA1BIOH'
     GROUP BY epd.BasketTicker


/*  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  */
/*  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  */
/*  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  */






CREATE TABLE #tmpOutputBsk(
    BegDate    DATE,
    EndDate    DATE,
    Ticker     VARCHAR(255),
    Wght       FLOAT)
 
DECLARE @BegDate AS DATE = '02/28/2024'
DECLARE @EndDate AS DATE = '02/28/2024'
 
SELECT TOP 1 @BegDate = epd.AsOfDate FROM dbo.MspbBasketDetails epd
WHERE epd.AsOfDate <= @BegDate ORDER BY epd.AsOfDate DESC
 
SELECT TOP 1 @EndDate = epd.AsOfDate FROM dbo.MspbBasketDetails epd
WHERE epd.AsOfDate <= @EndDate ORDER BY epd.AsOfDate DESC
 
 /*
SELECT DISTINCT CAST(UpdateDate AS DATE) AS AsOfDate FROM dbo.BasketConstituents WHERE UpdateDate BETWEEN '01/01/2024' AND '02/29/2024'
*/


 INSERT INTO #tmpOutputBsk(
        BegDate,
        EndDate,
        Ticker,
        Wght)
 SELECT @BegDate,
        @EndDate,
        epx.Ticker,
        AVG(epx.Wght) AS MV
   FROM (SELECT CAST(epd.UpdateDate AS DATE) AS AsOfDate,
                epd.ConstName AS Ticker,
                SUM(COALESCE(epd.BasketWght , 0))/100 AS Wght
           FROM dbo.BasketConstituents epd
          WHERE CAST(epd.UpdateDate AS DATE) BETWEEN @BegDate AND @EndDate
            AND epd.BasketName = 'MSA1BIO Index'
          GROUP BY CAST(epd.UpdateDate AS DATE),
                epd.ConstName) epx
  GROUP BY epx.Ticker
  ORDER BY epx.Ticker
  
  SELECT *
    FROM #tmpOutputBsk
    ORDER BY Ticker

    SELECT epd.UnderlyBBYellowKey,
           AVG(epd.DeltaAdjMV)
      FROM dbo.EnfPositionDetails epd
     WHERE epd.AsOfDate BETWEEN @BegDate AND @EndDate
       AND CHARINDEX('MSA1BIO', epd.UnderlyBBYellowKey) != 0 
     GROUP BY epd.UnderlyBBYellowKey



