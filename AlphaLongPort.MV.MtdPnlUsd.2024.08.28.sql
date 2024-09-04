USE Operations
GO

CREATE TABLE #tmpOutput(
    BegDate    DATE,
    EndDate    DATE,
    Ticker     VARCHAR(255),
    MarketValue  FLOAT,
    MtdPnlUsd    FLOAT)

DECLARE @BegDate AS DATE = '06/30/2024'
DECLARE @EndDate AS DATE = '07/31/2024'

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
            AND epd.StratName IN ('Alpha Long', 'Alpha ShortXXX')
            AND epd.InstrType IN('Equity', 'Listed Option')
            AND LTRIM(RTRIM(COALESCE(UnderlyBBYellowKey, BBYellowKey))) != ''
            AND COALESCE(UnderlyBBYellowKey, BBYellowKey) NOT IN ('XBI US Equity')
          GROUP BY epd.AsOfDate,
                COALESCE(UnderlyBBYellowKey, BBYellowKey)
         HAVING ROUND(AVG(epd.Quantity), 0) != 0) epx
  GROUP BY epx.Ticker
  ORDER BY epx.Ticker

  UPDATE tox
     SET tox.MtdPnlUsd = epx.MtdPnlUsd
    FROM #tmpOutput tox
    JOIN (SELECT epd.AsOfDate, COALESCE(epd.UnderlyBBYellowKey, epd.BBYellowKey) AS Ticker, SUM(COALESCE(epd.MtdPnlUsd, 0)) AS MtdPnlUsd FROM dbo.EnfPositionDetails epd WHERE epd.AsOfDate = @EndDate GROUP BY epd.AsOfDate, COALESCE(epd.UnderlyBBYellowKey, epd.BBYellowKey)) epx
      ON tox.EndDate = epx.AsOfDate
     AND tox.Ticker = epx.Ticker    


  SELECT * 
    FROM #tmpOutput
    ORDER BY Ticker