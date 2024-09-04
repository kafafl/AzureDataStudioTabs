USE Operations
GO



EXEC dbo.p_GetEnfPositionData


    DROP TABLE IF EXISTS #tmpResutlsOut
     CREATE TABLE #tmpResutlsOut(
      AsOfDate      DATE,
      Strategy      VARCHAR(255),
      SubStrat      VARCHAR(255),
      Ticker        VARCHAR(255),
      InstrName     VARCHAR(1000),
      YtdPnlUsd23   FLOAT,    
      YtdPnlUsd24   FLOAT,
      ItdPnlUsd     FLOAT)  

    DECLARE @YrEndDate AS DATE = '12/29/2023'
    DECLARE @AsOfDate AS DATE = '2/29/2024'

INSERT INTO #tmpResutlsOut(
       AsOfDate,
       Strategy,
       SubStrat,
       Ticker,
       YtdPnlUsd24,
       ItdPnlUsd)
SELECT epd.AsOfDate,
       epd.StratName,
       epd.BookName,
       CASE WHEN epd.InstrType = 'Equity' THEN epd.BBYellowKey WHEN epd.InstrType = 'Listed Options' THEN epd.UnderlyBBYellowKey END,
       SUM(epd.YtdPnlUsd),
       SUM(epd.ItdPnlUsd)       
  FROM dbo.EnfPositionDetails epd
 WHERE epd.AsOfDate = @AsOfDate
   AND epd.StratName IN ('Alpha Long', 'Alpha Short')
   AND LTRIM(RTRIM(CASE WHEN epd.InstrType = 'Equity' THEN epd.BBYellowKey WHEN epd.InstrType = 'Listed Options' THEN epd.UnderlyBBYellowKey END)) != ''
   AND epd.InstrType IN('Equity', 'Listed Options')
 GROUP BY epd.AsOfDate,
       epd.StratName,
       epd.BookName,
       CASE WHEN epd.InstrType = 'Equity' THEN epd.BBYellowKey WHEN epd.InstrType = 'Listed Options' THEN epd.UnderlyBBYellowKey END
 ORDER BY epd.AsOfDate,
       epd.StratName,
       epd.BookName,
       CASE WHEN epd.InstrType = 'Equity' THEN epd.BBYellowKey WHEN epd.InstrType = 'Listed Options' THEN epd.UnderlyBBYellowKey END


INSERT INTO #tmpResutlsOut(
       AsOfDate,
       Strategy,
       SubStrat,
       Ticker,
       YtdPnlUsd23)
SELECT epd.AsOfDate,
       epd.StratName,
       epd.BookName,
       CASE WHEN epd.InstrType = 'Equity' THEN epd.BBYellowKey WHEN epd.InstrType = 'Listed Options' THEN epd.UnderlyBBYellowKey END,
       SUM(epd.YtdPnlUsd) AS YtdPnlUsd       
  FROM dbo.EnfPositionDetails epd
 WHERE epd.AsOfDate = @YrEndDate
   AND epd.StratName IN ('Alpha Long', 'Alpha Short')
   AND LTRIM(RTRIM(CASE WHEN epd.InstrType = 'Equity' THEN epd.BBYellowKey WHEN epd.InstrType = 'Listed Options' THEN epd.UnderlyBBYellowKey END)) != ''
   AND epd.InstrType IN('Equity', 'Listed Options')
 GROUP BY epd.AsOfDate,
       epd.StratName,
       epd.BookName,
       CASE WHEN epd.InstrType = 'Equity' THEN epd.BBYellowKey WHEN epd.InstrType = 'Listed Options' THEN epd.UnderlyBBYellowKey END
 ORDER BY epd.AsOfDate,
       epd.StratName,
       epd.BookName,
       CASE WHEN epd.InstrType = 'Equity' THEN epd.BBYellowKey WHEN epd.InstrType = 'Listed Options' THEN epd.UnderlyBBYellowKey END



/*  STRIP OUT NON-PNL RECORDS  (does not appear to generate deletes) */
    DELETE trx
      FROM #tmpResutlsOut trx
     WHERE trx.YtdPnlUsd23 = 0
       AND trx.YtdPnlUsd24 = 0
       AND trx.ItdPnlUsd = 0
   

--DELETE tro FROM #tmpResutlsOut tro WHERE tro.Ticker != 'AGEN US Equity'







/* 
    SELECT @AsOfDate,
           trx.Strategy,
           trx.SubStrat,
           trx.Ticker,
           trx.YtdPnlUsd23,
           trx.YtdPnlUsd24,
           trx.ItdPnlUsd
      FROM #tmpResutlsOut trx
     WHERE trx.AsOfDate = @YrEndDate
       AND trx.Ticker NOT IN (SELECT tro.Ticker FROM #tmpResutlsOut tro WHERE tro.AsOfDate = @AsOfDate)

*/
SELECT * FROM #tmpResutlsOut

SELECT * FROM #tmpResutlsOut WHERE AsOfDate = '2024-02-29'

SELECT * FROM #tmpResutlsOut WHERE AsOfDate = '2023-12-29'

SELECT * FROM #tmpResutlsOut WHERE YtdPnlUsd23 = 0 AND YtdPnlUsd24 = 0 AND ItdPnlUsd = 0
RETURN







/*  JUST 2023 YTD P&L  (does not appear to generate inserts)   */   
    INSERT INTO #tmpResutlsOut(
           AsOfDate,
           Strategy,
           SubStrat,
           Ticker,       
           YtdPnlUsd23,
           YtdPnlUsd24,
           ItdPnlUsd)
    SELECT @AsOfDate,
           trx.Strategy,
           trx.SubStrat,
           trx.Ticker,
           trx.YtdPnlUsd23,
           trx.YtdPnlUsd24,
           trx.ItdPnlUsd
      FROM #tmpResutlsOut trx
     WHERE trx.AsOfDate = @YrEndDate
       AND trx.Ticker NOT IN (SELECT tro.Ticker FROM #tmpResutlsOut tro WHERE tro.AsOfDate = @AsOfDate)

    DELETE trx
      FROM #tmpResutlsOut trx
     WHERE trx.AsOfDate = @YrEndDate
       AND trx.Ticker NOT IN (SELECT tro.Ticker FROM #tmpResutlsOut tro WHERE tro.AsOfDate = @AsOfDate)

    UPDATE tro
       SET tro.YtdPnlUsd23 = trx.YtdPnlUsd23
      FROM #tmpResutlsOut tro
      JOIN #tmpResutlsOut trx
        ON tro.Ticker = trx.Ticker
       AND tro.Strategy = trx.Strategy
       AND tro.SubStrat = trx.SubStrat 
     WHERE tro.AsOfDate = @AsOfDate
       AND trx.AsOfDate = @YrEndDate

    UPDATE tro
       SET tro.InstrName = epd.InstDescr
      FROM #tmpResutlsOut tro
      JOIN dbo.EnfPositionDetails epd
        ON (tro.Ticker = epd.BBYellowKey OR tro.Ticker = epd.UnderlyBBYellowKey)
       AND tro.AsOfDate = epd.AsOfDate
     WHERE tro.AsOfDate = @AsOfDate
       AND LTRIM(RTRIM(CASE WHEN epd.InstrType = 'Equity' THEN epd.BBYellowKey WHEN epd.InstrType = 'Listed Options' THEN epd.UnderlyBBYellowKey END)) != ''
       AND epd.InstrType IN('Equity', 'Listed Options')
  
    DELETE tro
      FROM #tmpResutlsOut tro
     WHERE tro.AsOfDate = @YrEndDate
  



    SELECT tro.AsOfDate,
           tro.Strategy,
           tro.Ticker,
           tro.InstrName,
           SUM(tro.YtdPnlUsd23) AS YtdPnlUsd23,
           SUM(tro.YtdPnlUsd24) AS YtdPnlUsd24,
           SUM(tro.ItdPnlUsd) AS ItdPnlUsd
      FROM #tmpResutlsOut tro
     WHERE tro.AsOfDate = @AsOfDate
     GROUP BY tro.AsOfDate,
           tro.Strategy,
           tro.Ticker,
           tro.InstrName
     ORDER BY tro.AsOfDate,
           tro.Strategy,
           tro.Ticker,
           tro.InstrName

RETURN

  






/* LEGACY CODING  */
  SELECT tro.AsOfDate,
         tro.Strategy,
         tro.Ticker,
         tro.InstrName,
         SUM(YtdPnlUsd23) AS YtdPnlUsd23,
         SUM(YtdPnlUsd24) AS YtdPnlUsd24,
         SUM(ItdPnlUsd) AS ItdPnlUsd
    FROM #tmpResutlsOut tro
   WHERE tro.AsOfDate = @AsOfDate
   GROUP BY tro.AsOfDate,
         tro.Strategy,
         tro.Ticker,
         tro.InstrName
   ORDER BY tro.AsOfDate,
         tro.Strategy,
         tro.Ticker,
         tro.InstrName


    SELECT tro.AsOfDate,
        tro.Ticker,
        tro.InstrName,
        SUM(YtdPnlUsd23) AS YtdPnlUsd23,
        SUM(YtdPnlUsd24) AS YtdPnlUsd24,
        SUM(ItdPnlUsd) AS ItdPnlUsd
 FROM  #tmpResutlsOut tro
 WHERE tro.AsOfDate = @AsOfDate
  GROUP BY tro.AsOfDate,
        tro.Ticker,
        tro.InstrName
        ORDER BY tro.AsOfDate,
        tro.Ticker,
        tro.InstrName