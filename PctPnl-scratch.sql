USE Operations
GO



CREATE TABLE #tmpAlphaLongs(
    BBYellowKey              VARCHAR(255)
)

/**/
--INSERT INTO #tmpAlphaLongs (BBYellowKey) SELECT 'JANX US Equity'
--INSERT INTO #tmpAlphaLongs (BBYellowKey) SELECT 'CATX US Equity'
--INSERT INTO #tmpAlphaLongs (BBYellowKey) SELECT 'KROS US Equity'
--INSERT INTO #tmpAlphaLongs (BBYellowKey) SELECT 'DAWN US Equity'
--INSERT INTO #tmpAlphaLongs (BBYellowKey) SELECT 'ELEV US Equity'
--INSERT INTO #tmpAlphaLongs (BBYellowKey) SELECT 'LXEO US Equity'
--INSERT INTO #tmpAlphaLongs (BBYellowKey) SELECT 'RAPT US Equity'


CREATE TABLE #tmpValueHash(
    AsOfDate          DATE,
    PrevDate          DATE,
    CurrNAV           FLOAT,
    PrevNAV           FLOAT,
    CurrLMV           FLOAT,
    PrevLMV           FLOAT,
    CurrSMV           FLOAT,
    PrevSMV           FLOAT,
    Ticker            VARCHAR(50),
    SecName           VARCHAR(255),
    DeltaAdjMV        FLOAT,
    PrevDeltaAdjMv    FLOAT,
    DlyPnlUsd         FLOAT,
    PosPctOfNAV       FLOAT,
    DlyPnlHdgUsd      FLOAT,
    DeltaAdjMVHdg     FLOAT,    
    PctOfHdgPnlUsd    FLOAT,
    HedgedPnlUsd      FLOAT,
    PctReturn         FLOAT,
    bProcessed        BIT)


DECLARE @BegDate AS DATE = '01/01/2024'
DECLARE @EndDate AS DATE = '01/31/2024'

DECLARE @AsOfDate AS DATE = @BegDate

WHILE @AsOfDate <= @EndDate
  BEGIN
    IF EXISTS(SELECT 1 FROM dbo.DateMaster dtm WHERE dtm.AsOfDate = @AsOfDate AND dtm.IsWeekday = 1 AND dtm.IsMktHoliday = 0)
      BEGIN
      
        INSERT INTO #tmpValueHash(
               AsOfDate)
        SELECT @AsOfDate

        UPDATE tvh
           SET tvh.PrevDate = dtm.PrevDate
           FROM #tmpValueHash tvh
           JOIN (SELECT @AsOfDate AS AsOfDate, 
                        dtm.AsOfDate AS PrevDate 
                   FROM dbo.DateMaster dtm             
                  WHERE dtm.AsOfDate  = (SELECT TOP 1 dtx.AsOfDate FROM dbo.DateMaster dtx WHERE dtx.AsOfDate < @AsOfDate AND dtx.IsWeekday = 1 AND dtx.IsMktHoliday = 0 ORDER BY dtx.AsOfDate DESC)
                    AND dtm.IsWeekday = 1 AND dtm.IsMktHoliday = 0) dtm
             ON dtm.AsOfDate = tvh.AsOfDate
             
     /*  NAV  */               
         UPDATE tvh
            SET tvh.CurrNAV = fad.AssetValue
           FROM #tmpValueHash tvh
           JOIN dbo.FundAssetsDetails fad
             ON tvh.AsOfDate = fad.AsOfDate
          WHERE fad.Entity = 'AMF NAV' 

         UPDATE tvh
            SET tvh.PrevNAV = fad.AssetValue
           FROM #tmpValueHash tvh
           JOIN dbo.FundAssetsDetails fad
             ON tvh.PrevDate = fad.AsOfDate
          WHERE fad.Entity = 'AMF NAV'  

     /*  LMV  */ 
         UPDATE tvh
            SET tvh.CurrLMV = fad.AssetValue
           FROM #tmpValueHash tvh
           JOIN dbo.FundAssetsDetails fad
             ON tvh.AsOfDate = fad.AsOfDate
          WHERE fad.Entity = 'AMF LONG MARKET VALUE'

         UPDATE tvh
            SET tvh.PrevLMV = fad.AssetValue
           FROM #tmpValueHash tvh
           JOIN dbo.FundAssetsDetails fad
             ON tvh.PrevDate = fad.AsOfDate
          WHERE fad.Entity = 'AMF LONG MARKET VALUE'

     /*  SMV  */ 
         UPDATE tvh
            SET tvh.CurrSMV = fad.AssetValue
           FROM #tmpValueHash tvh
           JOIN dbo.FundAssetsDetails fad
             ON tvh.AsOfDate = fad.AsOfDate
          WHERE fad.Entity = 'AMF SHORT MARKET VALUE'

         UPDATE tvh
            SET tvh.PrevSMV = fad.AssetValue
           FROM #tmpValueHash tvh
           JOIN dbo.FundAssetsDetails fad
             ON tvh.PrevDate = fad.AsOfDate
          WHERE fad.Entity = 'AMF SHORT MARKET VALUE'

         UPDATE tvh
            SET tvh.Ticker = epd.BBYellowKey,
                tvh.SecName = epd.InstDescr,
                tvh.DeltaAdjMV = epd.DeltaAdjMV,
                tvh.DlyPnlUsd = epd.DlyPnlUsd
           FROM #tmpValueHash tvh
           JOIN dbo.EnfPositionDetails epd
             ON tvh.AsOfDate = epd.AsOfDate
           JOIN #tmpAlphaLongs tal
             ON tal.BBYellowKey = epd.BBYellowKey
          WHERE epd.StratName = 'Alpha Long'

         UPDATE tvh
            SET tvh.PrevDeltaAdjMv = epd.DeltaAdjMV
           FROM #tmpValueHash tvh
           JOIN dbo.EnfPositionDetails epd
             ON tvh.PrevDate = epd.AsOfDate
           JOIN #tmpAlphaLongs tal
             ON tal.BBYellowKey = epd.BBYellowKey
          WHERE epd.StratName = 'Alpha Long'  

         UPDATE tvh
            SET tvh.DlyPnlHdgUsd = sag.DlyPnlUsd,
                tvh.DeltaAdjMVHdg = sag.DeltaAdjMV
           FROM #tmpValueHash tvh
           JOIN (SELECT epd.AsOfDate,
                        'Short and Hedge Aggregate' AS Position,
                        'SAH-AGG' AS BBYellowKey,
                        SUM(epd.DeltaAdjMV) AS DeltaAdjMV,
                        SUM(epd.DlyPnlUsd) AS DlyPnlUsd
                   FROM dbo.EnfPositionDetails epd
                  WHERE epd.AsOfDate = @AsOfDate
                    AND epd.StratName IN ('Biotech Hedge', 'Equity Hedge')
                    AND epd.InstrTypeUnder IN ('Equity', 'Index')
                    AND epd.DlyPnlUsd != 0
                  GROUP BY epd.AsOfDate) sag
             ON tvh.AsOfDate = sag.AsOfDate

      END
    SELECT @AsOfDate = DATEADD(DAY, 1, @AsOfDate)
  END


  UPDATE tvh
     SET tvh.PosPctOfNAV = tvh.DeltaAdjMV / tvh.CurrNAV
    FROM #tmpValueHash tvh

  UPDATE tvh
     SET tvh.PctOfHdgPnlUsd = tvh.DlyPnlHdgUsd * tvh.PosPctOfNAV
    FROM #tmpValueHash tvh

  UPDATE tvh
     SET tvh.HedgedPnlUsd = tvh.DlyPnlUsd + tvh.PctOfHdgPnlUsd
    FROM #tmpValueHash tvh

  UPDATE tvh
     SET tvh.PctReturn = tvh.HedgedPnlUsd / tvh.CurrNAV
    FROM #tmpValueHash tvh

SELECT * FROM #tmpValueHash
RETURN






/*




/*
        UPDATE tvh
           SET tvh.PrevDate = fad.AsOfDate
          FROM #tmpValueHash tvh
          JOIN [dbo].[FundAssetsDetails] fad
            ON tvh.AsOfDate = fad.AsOfDate
         WHERE fad.Entity = 'AMF NAV'
           AND fad.AsOfDate <= @AsOfDate
         ORDER BY fad.AsOfDate ASC

        SELECT TOP 2 fad.AsOfDate,
               fad.AssetValue,
               fad.Entity
          FROM [dbo].[FundAssetsDetails] fad
         WHERE fad.Entity = 'AMF NAV'
           AND fad.AsOfDate <= @AsOfDate
         ORDER BY fad.AsOfDate ASC

       SELECT @AsOfDate AS _AsOf
*/


SELECT TOP 2 fad.AsOfDate,
       fad.AssetValue,
       fad.Entity
  FROM [dbo].[FundAssetsDetails] fad
 WHERE fad.Entity = 'AMF LONG MARKET VALUE'
   AND fad.AsOfDate <= @AsOfDate
 ORDER BY fad.AsOfDate DESC,
       fad.CreatedOn DESC

SELECT TOP 2 fad.AsOfDate,
       fad.AssetValue,
       fad.Entity
  FROM [dbo].[FundAssetsDetails] fad
 WHERE fad.Entity = 'AMF SHORT MARKET VALUE'
   AND fad.AsOfDate <= @AsOfDate
 ORDER BY fad.AsOfDate DESC,
       fad.CreatedOn DESC

SELECT epd.AsOfDate,
       epd.Quantity,
       epd.InstDescr,
       epd.BBYellowKey,
       epd.DeltaAdjMV,
       epd.DlyPnlUsd
  FROM dbo.EnfPositionDetails epd
  WHERE epd.AsOfDate = '01/05/2024'
    AND epd.Quantity > 0
    AND epd.StratName = 'Alpha Long'
    AND epd.InstrType = 'Equity'
    AND epd.BBYellowKey != ''
ORDER BY epd.InstDescr

SELECT epd.AsOfDate,
       'Short and Hedge Aggregate' AS Position,
       'SAH-AGG' AS BBYellowKey,
       SUM(epd.DeltaAdjMV) AS DeltaAdjMV,
       SUM(epd.DlyPnlUsd) AS DlyPnlUsd
  FROM dbo.EnfPositionDetails epd
  WHERE epd.AsOfDate = '05/15/2024'
    AND epd.StratName IN ('Biotech Hedge', 'Equity Hedge')
    AND epd.InstrTypeUnder IN ('Equity', 'Index')
  GROUP BY epd.AsOfDate



SELECT epd.AsOfDate,
       'Short and Hedge Aggregate' AS Position,
       epd.BBYellowKey,
       epd.DeltaAdjMV,
       epd.DlyPnlUsd
  FROM dbo.EnfPositionDetails epd
  WHERE epd.AsOfDate = '05/15/2024'
    AND epd.StratName IN ('Biotech Hedge', 'Equity Hedge')
    AND epd.InstrTypeUnder IN ('Equity', 'Index')








SELECT TOP 1000
       epd.*
  FROM dbo.EnfPositionDetails epd
  WHERE epd.AsOfDate = '01/05/2024' -- @AsOfDate
    --AND epd.Quantity > 0
    AND epd.StratName IN ('Biotech Hedge', 'Equity Hedge')
    --AND epd.InstrType = 'Equity'
    AND epd.InstrTypeUnder IN ('Equity', 'Index')






    AND  epd.BBYellowKey IN (SELECT BBYellowKey FROM #tmpAlphaLongs)





SELECT TOP 1000 * 
  FROM [dbo].[FundAssetsDetails] fad
ORDER BY fad.AsOfDate DESC,
      fad.CreatedOn DESC


SELECT TOP 1000 * 
  FROM [dbo].[FundAssetsDetails] fad
 WHERE fad.Entity = 'AMF NAV'
 ORDER BY fad.AsOfDate DESC,
       fad.CreatedOn DESC






SELECT *   FROM dbo.EnfPositionDetails epd
  WHERE epd.AsOfDate = '01/29/2024'

    --AND epd.CreatedOn > '02/20/2024'

    AND epd.CreatedOn < '02/20/2024'
ORDER BY epd.CreatedOn, epd.InstDescr


DELETE epd   FROM dbo.EnfPositionDetails epd
  WHERE epd.AsOfDate = '01/29/2024'

    AND epd.CreatedOn > '02/20/2024'

    --AND epd.CreatedOn < '02/20/2024'
ORDER BY epd.CreatedOn, epd.InstDescr


SELECT epd.AsOfDate,
       epd.CreatedOn,
       epd.Quantity,
       epd.InstDescr,
       epd.BBYellowKey,
       epd.DeltaAdjMV,
       epd.DlyPnlUsd
  FROM dbo.EnfPositionDetails epd
  WHERE epd.AsOfDate = '01/29/2024'
    AND epd.Quantity > 0
    AND epd.StratName = 'Alpha Long'
    AND epd.InstrType = 'Equity'
    AND epd.BBYellowKey != ''
ORDER BY epd.CreatedOn, epd.InstDescr






SELECT epd.AsOfDate,
       epd.StratName,
       epd.BookName,
       epd.InstDescr,
       epd.CcyOne,
       epd.InstrType,
       epd.BBYellowKey,
       epd.Quantity,
       epd.DeltaAdjMV,
       epd.DlyPnlUsd,
       epd.LongMV,
       epd.ShortMV
  FROM dbo.EnfPositionDetails epd
  WHERE epd.AsOfDate = '05/15/2024'
    AND epd.StratName IN ('Biotech Hedge', 'Equity Hedge')
    AND epd.InstrTypeUnder IN ('Equity', 'Index')
    AND epd.DlyPnlUsd != 0







     


SELECT * FROM dbo.FundAssetsDetails fad
WHERE fad.AsOfDate = '01/31/2024'



  */