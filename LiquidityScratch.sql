USE Operations
GO

  CREATE TABLE #tmpBasketLiquidity(
    AsOfDate               DATE,
    BasketName             VARCHAR(255),
    CompName               VARCHAR(255),
    Shares                 FLOAT,
    AvgVolume30d           FLOAT,
    ADV30Day               FLOAT,
    bUpdated               BIT NOT NULL DEFAULT 0)


  DECLARE @AsOfDate AS DATE = '06/26/2024'
  DECLARE @MktDate AS DATE

    INSERT INTO #tmpBasketLiquidity(
           AsOfDate,
           BasketName,
           CompName,
           Shares)
    SELECT msb.AsOfDate,
           msb.BasketTicker,
           msb.CompBbg,
           msb.CompExpShares 
      FROM dbo.MspbBasketDetails msb
     WHERE msb.AsOfDate = @AsOfDate

    UPDATE tbl
       SET tbl.CompName = REPLACE(tbl.CompName,' UN',' US')
      FROM #tmpBasketLiquidity tbl 
     WHERE CHARINDEX(' UN', tbl.CompName) != 0

    UPDATE tbl
       SET tbl.CompName = REPLACE(tbl.CompName,' UA',' US')
      FROM #tmpBasketLiquidity tbl 
     WHERE CHARINDEX(' UA', tbl.CompName) != 0

    UPDATE tbl
       SET tbl.AvgVolume30d = mkd.MdValue,
           tbl.ADV30Day = CASE WHEN mkd.MdValue IS NOT NULL THEN tbl.Shares / mkd.MdValue ELSE NULL END,
           tbl.bUpdated = 1
      FROM #tmpBasketLiquidity tbl
      JOIN dbo.AmfMarketData mkd
        ON mkd.AsOfDate = tbl.AsOfDate
       AND CHARINDEX(tbl.CompName, mkd.PositionId) != 0
     WHERE mkd.DataSource = 'Bloomberg'
       AND mkd.PositionIdType  = 'BloombergTicker'
       AND mkd.TagMnemonic = 'VOLUME_AVG_10D'


    SELECT TOP 5
           tbl.AsOfDate,
           tbl.BasketName AS Basket,
           tbl.CompName AS Ticker,
           tbl.Shares,
           tbl.AvgVolume30d,
           tbl.ADV30Day 
      FROM #tmpBasketLiquidity tbl
     WHERE tbl.ADV30Day IS NOT NULL
     ORDER BY tbl.ADV30Day ASC

    SELECT tbl.AsOfDate,
           tbl.BasketName AS Basket,
           tbl.CompName AS Ticker,
           tbl.Shares,
           tbl.AvgVolume30d,
           tbl.ADV30Day 
      FROM #tmpBasketLiquidity tbl
     WHERE tbl.ADV30Day IS NULL
     ORDER BY tbl.ADV30Day ASC


