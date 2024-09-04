SELECT epd.AsOfDate,
       epd.BBYellowKey,
       epd.UnderlyBBYellowKey,
       epd.InstDescr,
       epd.CcyOne AS Ccy,
       epd.StratName AS Strategy,
       epd.BookName,
       epd.InstrType,
       epd.Quantity,
       epd.FairValue AS Price,
       epd.GrExpOfGLNav,
       epd.LongShort,
       'Alpha' AS AlphaHedge,
       epd.DlyPnlUsd,
       NULL AS FxPnlUsd,
       NULL AS DlyPnlUnreal,
       NULL AS DlyPnlReal,
       epd.DlyPnlOfNav,
       NULL AS FxPnlUsdPct,
       NULL AS DlyUnrealPct,
       NULL AS DlyRealPct,
       epd.DeltaAdjMV
  FROM dbo.EnfPositionDetails epd
 WHERE epd.AsOfDate = '7/29/2024'
   AND (CHARINDEX('Alpha Long', epd.StratName) != 0 OR CHARINDEX('Alpha Short', epd.StratName) != 0 OR CHARINDEX('Hedge', epd.StratName) != 0)
   AND ROUND(COALESCE(epd.Quantity, 0), 0) != 0
   AND epd.InstrType = 'Equity'
   AND epd.Account = 'MS Cash'
   AND epd.BBYellowKey != ''
 ORDER BY  epd.StratName,
       epd.BookName