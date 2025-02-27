USE Operations
GO

  CREATE TABLE #tmpResultsOutput(
    AsOfDate          DATE,
    Strategy          VARCHAR(255),
    PositionName      VARCHAR(255),
    CcyOne            VARCHAR(255),
    InstrType         VARCHAR(255),
    MtdPnlUsd         NUMERIC(30, 2))

  CREATE TABLE #tmpMapMaster(
    BbgKey            VARCHAR(255),
    UnderlyOne        VARCHAR(255),
    UnderlyTwo        VARCHAR(255))

    INSERT INTO #tmpMapMaster(BbgKey, UnderlyOne, UnderlyTwo) SELECT   '|TALARIS THERAPEUTICS ORD - Private|', 'TALS US Equity', 'TRML US Equity'
    INSERT INTO #tmpMapMaster(BbgKey, UnderlyOne, UnderlyTwo) SELECT   '|SATELLOS BIOSCIENCE ORD Private|', 'MSCL CN Equity', ''
    INSERT INTO #tmpMapMaster(BbgKey, UnderlyOne, UnderlyTwo) SELECT   '|PROMIS NEUROSCIENCES INC - Private|', 'PMN US Equity', ''
    INSERT INTO #tmpMapMaster(BbgKey, UnderlyOne, UnderlyTwo) SELECT   '|Jade Biosciences Private|', 'JADE (AVTE)', ''
    INSERT INTO #tmpMapMaster(BbgKey, UnderlyOne, UnderlyTwo) SELECT   '|LEXEO THERAPEUTICS ORD - Private|', 'LXEO US Equity', ''
    INSERT INTO #tmpMapMaster(BbgKey, UnderlyOne, UnderlyTwo) SELECT   '|MOLECULAR TEMPLATES - Private|', 'MTEM US Equity', ''
    INSERT INTO #tmpMapMaster(BbgKey, UnderlyOne, UnderlyTwo) SELECT   '|MSA14568|', 'MSA14568', ''

    INSERT INTO #tmpResultsOutput(
           AsOfDate,
           Strategy,
           PositionName,
           CcyOne,
           InstrType,
           MtdPnlUsd)
    SELECT epd.AsOfDate,
           CASE WHEN epd.StratName = '' THEN 'Alpha Long' ELSE epd.StratName END AS Strategy,
           CASE WHEN epd.UnderlyBBYellowKey = '' THEN '|' + epd.InstDescr + '|' ELSE epd.UnderlyBBYellowKey END AS PositionName,
           epd.CcyOne,
           epd.InstrType,
           SUM(epd.MtdPnlUsd) AS MtdPnlUsd
      FROM dbo.EnfPositionDetails epd
     WHERE epd.AsOfDate = '12/31/2024'
       AND epd.MtdPnlUsd != 0
       AND epd.InstrType NOT IN ('FX Forward', 'Cash')
       AND epd.InstrType IN ('Equity')
     GROUP BY epd.AsOfDate,
           epd.StratName,
           CASE WHEN epd.UnderlyBBYellowKey = '' THEN '|' + epd.InstDescr + '|' ELSE epd.UnderlyBBYellowKey END,
           epd.CcyOne,
           epd.InstrType
     ORDER BY epd.AsOfDate,
           CASE WHEN epd.StratName = '' THEN 'Alpha Long' ELSE epd.StratName END,
           CASE WHEN epd.UnderlyBBYellowKey = '' THEN '|' + epd.InstDescr + '|' ELSE epd.UnderlyBBYellowKey END,
           epd.CcyOne
       
/*       
    SELECT * FROM #tmpResultsOutput WHERE CHARINDEX('|', PositionName) != 0
*/

    UPDATE tro
       SET tro.PositionName = tmx.UnderlyOne
       FROM #tmpResultsOutput tro
       JOIN #tmpMapMaster tmx
       ON tro.PositionName = tmx.BbgKey

    UPDATE tro
       SET tro.Strategy = 'Biotech Hedge'
      FROM #tmpResultsOutput tro
     WHERE tro.PositionName = 'XBI US Equity'

    UPDATE tro
       SET tro.Strategy = 'Alpha Long'
      FROM #tmpResultsOutput tro
     WHERE tro.Strategy = 'Alpha Short'
       AND tro.PositionName IN (SELECT trx.PositionName FROM #tmpResultsOutput trx WHERE trx.Strategy = 'Alpha Long')

    UPDATE tro
       SET tro.Strategy = 'Alpha Long'
      FROM #tmpResultsOutput tro
     WHERE tro.Strategy = 'Other'
       AND tro.PositionName IN (SELECT trx.PositionName FROM #tmpResultsOutput trx WHERE trx.Strategy = 'Alpha Long')

    UPDATE tro
       SET tro.Strategy = 'Alpha Short'
      FROM #tmpResultsOutput tro
     WHERE tro.Strategy = 'Other'
       AND tro.PositionName IN (SELECT trx.PositionName FROM #tmpResultsOutput trx WHERE trx.Strategy = 'Alpha Short')

    UPDATE tro
       SET tro.Strategy = 'Alpha Short'
      FROM #tmpResultsOutput tro
     WHERE tro.Strategy = 'Biotech Hedge'
       AND tro.PositionName IN (SELECT trx.PositionName FROM #tmpResultsOutput trx WHERE trx.Strategy = 'Alpha Short')
       
/*
    SELECT * FROM #tmpResultsOutput ORDER BY AsOfDate, Strategy, PositionName
*/

    SELECT AsOfDate,
           Strategy,
           PositionName,
           CcyOne AS Crncy,
           InstrType,
           SUM(MtdPnlUsd) AS MtdPnlUsd
      FROM #tmpResultsOutput tro
     GROUP BY AsOfDate,
           Strategy,
           PositionName,
           InstrType,
           CcyOne
     ORDER BY AsOfDate,
           Strategy,
           PositionName,
           InstrType,
           CcyOne

    SELECT AsOfDate,
           Strategy,
           PositionName,
           CcyOne AS Crncy,
           SUM(MtdPnlUsd) AS MtdPnlUsd
      FROM #tmpResultsOutput tro
     GROUP BY AsOfDate,
           Strategy,
           PositionName,
           CcyOne
     ORDER BY AsOfDate,
           Strategy,
           PositionName,
           CcyOne

    SELECT AsOfDate,
           PositionName,
           CcyOne AS Crncy,
           SUM(MtdPnlUsd) AS MtdPnlUsd
      FROM #tmpResultsOutput tro
     GROUP BY AsOfDate,
           PositionName,
           CcyOne
     ORDER BY AsOfDate,
           PositionName,
           CcyOne


