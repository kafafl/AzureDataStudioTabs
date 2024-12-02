USE Operations
GO

 SELECT epd.AsOfDate,
        epd.FundShortName,
        epd.StratName,
        epd.InstDescr,
        epd.UnderlyBBYellowKey,
        epd.CcyOne,
        epd.InstrType,
        epd.FairValue AS BegPrice,
        '' AS EndPrice,
        '' AS PxDelta,
        '' AS PctRet,
        epd.NetMarketValue,
        epd.DeltaAdjMV,
        CASE WHEN epd.Delta = 0 THEN 1 ELSE epd.Delta END AS Delta,
        epd.MtdPnlUsd,
        epd.YtdPnlUsd
   FROM dbo.EnfPositionDetails epd
  WHERE epd.AsOfDate = '09/30/2024'
    AND epd.InstrType = 'Warrant'
  ORDER BY epd.AsOfDate, epd.UnderlyBBYellowKey, epd.InstDescr


