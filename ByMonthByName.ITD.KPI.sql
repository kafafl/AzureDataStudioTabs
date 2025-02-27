USE Operations
GO

  DECLARE @tResults AS TABLE(
    AsOfDate          DATE,
    StratName         VARCHAR(255),
    BbgTicker         VARCHAR(255),
    bModMap           INT,
    Quantity          BIGINT,
    fDeltaAdjMv       FLOAT,
    fOptDeltaAdjMv    FLOAT,
    fPrice            FLOAT,
    dMtdPnlUsd        NUMERIC(30, 2),
    dDelta1MtdPnlUsd  NUMERIC(30, 2),
    dOptMtdPnlUsd     NUMERIC(30, 2),
    dYtdPnlUsd        NUMERIC(30, 2),
    dDelta1YtdPnlUsd  NUMERIC(30, 2),
    dOptYtdPnlUsd     NUMERIC(30, 2),
    fYtdPnlOfNav      FLOAT)

  DECLARE @tMapMaster AS TABLE(
    BbgKey            VARCHAR(255),
    UnderlyOne        VARCHAR(255),
    UnderlyTwo        VARCHAR(255))

  DECLARE @tMonthEndDates AS TABLE(
    AsOfDate          DATE,
    bIsProcessed      BIT DEFAULT 0) 

  DECLARE @AsOfDate AS DATE


/*  INSERTS TO MAP NAMES WITHOUT MARKET IDENTIFIERS  */
    INSERT INTO @tMapMaster(BbgKey, UnderlyOne, UnderlyTwo) SELECT   '|AMBRX BIOPHARMA ORD|', 'AMAM US Equity', ''
    INSERT INTO @tMapMaster(BbgKey, UnderlyOne, UnderlyTwo) SELECT   '|APPLIED MOLECULAR TRANSPORT ORD|', 'AMTI US Equity', ''
    INSERT INTO @tMapMaster(BbgKey, UnderlyOne, UnderlyTwo) SELECT   '|BELLICUM PHARMACEUTICALS ORD|', 'BLCM US Equity', ''
    INSERT INTO @tMapMaster(BbgKey, UnderlyOne, UnderlyTwo) SELECT   '|BIOMX ORD - Private|', 'PHGE US Equity', ''
    INSERT INTO @tMapMaster(BbgKey, UnderlyOne, UnderlyTwo) SELECT   '|EQRX ORD|', 'EQRX US Equity', ''
    INSERT INTO @tMapMaster(BbgKey, UnderlyOne, UnderlyTwo) SELECT   '|GOSSAMER BIO ORD - Private|', 'GOSS US Equity', ''
    INSERT INTO @tMapMaster(BbgKey, UnderlyOne, UnderlyTwo) SELECT   '|GRACELL BIOTECHNOLOG ADR REP 5 ORD|', 'GRCL US Equity', ''
    INSERT INTO @tMapMaster(BbgKey, UnderlyOne, UnderlyTwo) SELECT   '|HORIZON THERAPEUTICS PUBLIC ORD|', 'HZNP US Equity', ''
    INSERT INTO @tMapMaster(BbgKey, UnderlyOne, UnderlyTwo) SELECT   '|IMMUNOGEN ORD|', 'IMGN US Equity', ''
    INSERT INTO @tMapMaster(BbgKey, UnderlyOne, UnderlyTwo) SELECT   '|IVERIC BIO ORD|', 'ISEE US Equity', ''
    INSERT INTO @tMapMaster(BbgKey, UnderlyOne, UnderlyTwo) SELECT   '|MIRATI THERAPEUTICS ORD|', 'MRTX US Equity', ''
    INSERT INTO @tMapMaster(BbgKey, UnderlyOne, UnderlyTwo) SELECT   '|MOLECULAR TEMPLATES - Private|', 'MTEM US Equity', ''
    INSERT INTO @tMapMaster(BbgKey, UnderlyOne, UnderlyTwo) SELECT   '|PARDES BIOSCIENCES ORD|', 'PRDS US Equity', ''
    INSERT INTO @tMapMaster(BbgKey, UnderlyOne, UnderlyTwo) SELECT   '|PNT Jan4 15.0 C|', 'PNT US Equity', ''
    INSERT INTO @tMapMaster(BbgKey, UnderlyOne, UnderlyTwo) SELECT   '|POINT BIOPHARMA GLOBAL ORD|', 'PNT US Equity', ''
    INSERT INTO @tMapMaster(BbgKey, UnderlyOne, UnderlyTwo) SELECT   '|PROMETHEUS BIOSCIENCES ORD|', 'RXDX US Equity', ''
    INSERT INTO @tMapMaster(BbgKey, UnderlyOne, UnderlyTwo) SELECT   '|RAIN ONCOLOGY ORD|', '2538060D US Equity', ''
    INSERT INTO @tMapMaster(BbgKey, UnderlyOne, UnderlyTwo) SELECT   '|RAYZEBIO ORD|', 'RYZB US Equity', ''
    INSERT INTO @tMapMaster(BbgKey, UnderlyOne, UnderlyTwo) SELECT   '|REATA PHARMACEUTICALS CL A ORD|', 'RETA US Equity', ''
    INSERT INTO @tMapMaster(BbgKey, UnderlyOne, UnderlyTwo) SELECT   '|SATELLOS BIOSCIENCE ORD Private|', 'MSCL CN Equity', ''
    INSERT INTO @tMapMaster(BbgKey, UnderlyOne, UnderlyTwo) SELECT   '|SEAGEN ORD|', 'SGEN US Equity', ''
    INSERT INTO @tMapMaster(BbgKey, UnderlyOne, UnderlyTwo) SELECT   '|TALARIS THERAPEUTICS ORD - Private|', 'TALS US Equity', 'TRML US Equity'
    INSERT INTO @tMapMaster(BbgKey, UnderlyOne, UnderlyTwo) SELECT   '|THESEUS PHARMACEUTICALS ORD|', 'THRX US Equity', ''
    INSERT INTO @tMapMaster(BbgKey, UnderlyOne, UnderlyTwo) SELECT   '|ZURA Private|', 'ZURA US Equity', ''
    INSERT INTO @tMapMaster(BbgKey, UnderlyOne, UnderlyTwo) SELECT   '|ISEE US 05/19/23 C30 Equity|', 'ISEE US Equity', ''
    INSERT INTO @tMapMaster(BbgKey, UnderlyOne, UnderlyTwo) SELECT   '|ISEE US 07/21/23 P33 Equity|', 'ISEE US Equity', ''
    INSERT INTO @tMapMaster(BbgKey, UnderlyOne, UnderlyTwo) SELECT   '|PNT US 01/19/24 P12.5 Equity|', 'PNT US Equity', ''
    INSERT INTO @tMapMaster(BbgKey, UnderlyOne, UnderlyTwo) SELECT   '|VRNA US Equity|', 'VRNA US Equity', ''
    INSERT INTO @tMapMaster(BbgKey, UnderlyOne, UnderlyTwo) SELECT   '|MORPHIC HOLDING ORD|', 'MORF US Equity', ''
    INSERT INTO @tMapMaster(BbgKey, UnderlyOne, UnderlyTwo) SELECT   '|ALPINE IMMUNE SCIENCES ORD|', 'ALPN US Equity', ''
    INSERT INTO @tMapMaster(BbgKey, UnderlyOne, UnderlyTwo) SELECT   '|CBAY Apr4 30.0 C|', 'CBAY US Equity', ''
    INSERT INTO @tMapMaster(BbgKey, UnderlyOne, UnderlyTwo) SELECT   '|Jade Biosciences Private|', 'JADE (AVTE)', ''
    INSERT INTO @tMapMaster(BbgKey, UnderlyOne, UnderlyTwo) SELECT   '|LEXEO THERAPEUTICS ORD - Private|', 'LXEO US Equity', ''
    INSERT INTO @tMapMaster(BbgKey, UnderlyOne, UnderlyTwo) SELECT   '|LONGBOARD PHARMACEUTICALS ORD|', 'LBPH US Equity', ''
    INSERT INTO @tMapMaster(BbgKey, UnderlyOne, UnderlyTwo) SELECT   '|ORKA Preferred As|', 'ORKA US Equity', ''
    INSERT INTO @tMapMaster(BbgKey, UnderlyOne, UnderlyTwo) SELECT   '|CERE US 01/19/24 P22.5 Equity|', 'CERE US Equity', ''
    INSERT INTO @tMapMaster(BbgKey, UnderlyOne, UnderlyTwo) SELECT   '|CERE US 01/19/24 P30 Equity|', 'CERE US Equity', ''
    INSERT INTO @tMapMaster(BbgKey, UnderlyOne, UnderlyTwo) SELECT   '|MOR US 07/19/24 P2.5 Equity|', 'MOR US Equity', ''
    INSERT INTO @tMapMaster(BbgKey, UnderlyOne, UnderlyTwo) SELECT   '|MOR US 07/19/24 P5 Equity|', 'MOR US Equity', ''
    INSERT INTO @tMapMaster(BbgKey, UnderlyOne, UnderlyTwo) SELECT   '|MOR US 07/19/24 P7.5 Equity|', 'MOR US Equity', ''
    INSERT INTO @tMapMaster(BbgKey, UnderlyOne, UnderlyTwo) SELECT   'ELYM US Equity', 'CLYM US Equity', ''
    


 /* 
     SELECT * FROM @tMapMaster
 */


/*  INSERTS TO MONTH END DATES   */
INSERT INTO @tMonthEndDates (AsOfDate) SELECT '01/31/2023'
INSERT INTO @tMonthEndDates (AsOfDate) SELECT '02/28/2023'
INSERT INTO @tMonthEndDates (AsOfDate) SELECT '03/31/2023'
INSERT INTO @tMonthEndDates (AsOfDate) SELECT '04/28/2023'
INSERT INTO @tMonthEndDates (AsOfDate) SELECT '05/31/2023'
INSERT INTO @tMonthEndDates (AsOfDate) SELECT '06/30/2023'
INSERT INTO @tMonthEndDates (AsOfDate) SELECT '07/31/2023'
INSERT INTO @tMonthEndDates (AsOfDate) SELECT '08/31/2023'
INSERT INTO @tMonthEndDates (AsOfDate) SELECT '09/29/2023'
INSERT INTO @tMonthEndDates (AsOfDate) SELECT '10/31/2023'
INSERT INTO @tMonthEndDates (AsOfDate) SELECT '11/30/2023'
INSERT INTO @tMonthEndDates (AsOfDate) SELECT '12/29/2023'

INSERT INTO @tMonthEndDates (AsOfDate) SELECT '01/31/2024'
INSERT INTO @tMonthEndDates (AsOfDate) SELECT '02/29/2024'
INSERT INTO @tMonthEndDates (AsOfDate) SELECT '03/28/2024'
INSERT INTO @tMonthEndDates (AsOfDate) SELECT '04/30/2024'
INSERT INTO @tMonthEndDates (AsOfDate) SELECT '05/31/2024'
INSERT INTO @tMonthEndDates (AsOfDate) SELECT '06/28/2024'
INSERT INTO @tMonthEndDates (AsOfDate) SELECT '07/31/2024'
INSERT INTO @tMonthEndDates (AsOfDate) SELECT '08/30/2024'
INSERT INTO @tMonthEndDates (AsOfDate) SELECT '09/30/2024'
INSERT INTO @tMonthEndDates (AsOfDate) SELECT '10/31/2024'
INSERT INTO @tMonthEndDates (AsOfDate) SELECT '11/29/2024'
INSERT INTO @tMonthEndDates (AsOfDate) SELECT '12/31/2024'

WHILE EXISTS(SELECT TOP 1 med.AsOfdate FROM @tMonthEndDates med WHERE med.bIsProcessed = 0)
  BEGIN

  SELECT TOP 1 @AsOfDate = med.AsOfDate FROM @tMonthEndDates med WHERE med.bIsProcessed = 0 ORDER BY med.AsOfDate ASC
  PRINT @AsOfDate

  INSERT INTO @tResults(
         AsOfDate,
         StratName,
         BbgTicker,
         bModMap,
         Quantity,
         fDeltaAdjMv,
         fOptDeltaAdjMv,
         fPrice,
         dDelta1MtdPnlUsd,
         dOptMtdPnlUsd,
         dMtdPnlUsd,
         dDelta1YtdPnlUsd,
         dOptYtdPnlUsd,
         dYtdPnlUsd,
         fYtdPnlOfNav)
  SELECT epd.AsOfDate,
         epd.StratName,
         CASE WHEN epd.UnderlyBBYellowKey = '' 
              THEN 
                CASE WHEN epd.BBYellowKey = '' 
                     THEN '|' + RTRIM(LTRIM(epd.InstDescr)) + '|' 
                     ELSE '|' + RTRIM(LTRIM(epd.BBYellowKey)) + '|'
                END
              ELSE RTRIM(LTRIM(epd.UnderlyBBYellowKey)) END AS BBYellowKey,
         CASE WHEN epd.UnderlyBBYellowKey = '' 
              THEN 
                CASE WHEN epd.BBYellowKey = '' 
                     THEN 3 
                     ELSE 2
                END
              ELSE 1 END AS bModMap,
         --epd.InstrType,
         SUM(CASE WHEN epd.InstrType IN ('Equity') THEN epd.Quantity END),
         SUM(epd.DeltaAdjMV),
         SUM(CASE WHEN epd.InstrType IN ('Listed Option', 'Warrant', 'OTC Option') THEN epd.DeltaAdjMV ELSE 0 END),
         MAX(CASE WHEN epd.InstrType IN ('Equity') THEN epd.FairValue END),
         SUM(CASE WHEN epd.InstrType IN ('Equity') THEN epd.MtdPnlUsd ELSE 0 END),
         SUM(CASE WHEN epd.InstrType IN ('Listed Option', 'Warrant', 'OTC Option') THEN epd.MtdPnlUsd ELSE 0 END) , 
         SUM(epd.MtdPnlUsd),
         SUM(CASE WHEN epd.InstrType IN ('Equity') THEN epd.YtdPnlUsd ELSE 0 END),
         SUM(CASE WHEN epd.InstrType IN ('Listed Option', 'Warrant', 'OTC Option') THEN epd.YtdPnlUsd ELSE 0 END), 
         SUM(epd.YtdPnlUsd),
         SUM(epd.YtdPnlOfNav) AS YtdPnlOfNav
    FROM dbo.EnfPositionDetails epd
   WHERE epd.AsOfDate = @AsOfDate
     AND CHARINDEX('Alpha', epd.StratName) != 0
     AND epd.InstrType NOT IN ('Cash')
     AND epd.YtdPnlUsd != 0
   GROUP BY epd.AsOfDate,
         epd.StratName,
         CASE WHEN epd.UnderlyBBYellowKey = '' 
              THEN 
                CASE WHEN epd.BBYellowKey = '' 
                     THEN '|' + RTRIM(LTRIM(epd.InstDescr)) + '|' 
                     ELSE '|' + RTRIM(LTRIM(epd.BBYellowKey)) + '|'
                END
              ELSE RTRIM(LTRIM(epd.UnderlyBBYellowKey))
         END,
         CASE WHEN epd.UnderlyBBYellowKey = '' 
              THEN 
                CASE WHEN epd.BBYellowKey = '' 
                     THEN 3 
                     ELSE 2
                END
              ELSE 1 
         END
        -- epd.InstrType



/*  SOME ADDITIONAL LOGIC HERE FOR UPDATE STATEMENTS */
    PRINT @AsOfDate 

    UPDATE atr
       SET atr.BbgTicker = tmm.UnderlyOne
      FROM @tResults atr
      JOIN @tMapMaster tmm
        ON atr.BbgTicker = tmm.BbgKey

    UPDATE atr
       SET atr.fPrice = NULL
      FROM @tResults atr
     WHERE atr.dDelta1MtdPnlUsd != 0
       AND atr.fPrice = 0

    UPDATE atr
       SET atr.fPrice = amd.MdValue
      FROM @tResults atr
      JOIN dbo.AmfMarketData amd 
        ON atr.AsOfDate = amd.AsOfDate 
       AND atr.BbgTicker = amd.PositionId 
     WHERE amd.DataSource = 'Bloomberg'  
       AND amd.TagMnemonic = 'LAST_PRICE'
       AND atr.fPrice IS NULL

    UPDATE atr
       SET atr.fPrice = bmu.Price
      FROM @tResults atr
      JOIN dbo.BiotechMasterUniverse bmu  
        ON atr.AsOfDate = bmu.AsOfDate 
       AND atr.BbgTicker = bmu.BbgTicker
       AND atr.fPrice IS NULL

    UPDATE atr
       SET atr.fPrice = bmu.Price
      FROM @tResults atr
      JOIN dbo.MarketMasterUniverse bmu  
        ON atr.AsOfDate = bmu.AsOfDate 
       AND atr.BbgTicker = bmu.BbgTicker
       AND atr.fPrice IS NULL

    UPDATE atr
       SET atr.fPrice = phx.Price
      FROM @tResults atr
      JOIN dbo.PriceHistory phx
        ON atr.BbgTicker = phx.PositionId
     WHERE phx.PositionIdType = 'Bloomberg Ticker'
       AND phx.TagMnemonic = 'LAST_PRICE'
       AND phx.PriceSource = 'Bloomberg'
       AND atr.fPrice IS NULL

/*    */
    UPDATE atr
       SET atr.Quantity = COALESCE(atr.Quantity, 0) + COALESCE((atr.fOptDeltaAdjMv / atr.fPrice), 0)
      FROM @tResults atr
     WHERE atr.fOptDeltaAdjMv != 0 AND atr.fPrice != 0

    UPDATE atr
       SET atr.Quantity = 0
      FROM @tResults atr
     WHERE atr.Quantity IS NULL
       AND atr.fDeltaAdjMv = 0 
       AND atr.fOptDeltaAdjMV = 0

    UPDATE tem
       SET tem.bIsProcessed = 1
      FROM @tMonthEndDates tem
     WHERE tem.AsOfDate = @AsOfDate

END


PRINT 'PRE SELECT OUTPUT'

SELECT atr.AsOfDate,
       atr.BbgTicker,
       SUM(atr.Quantity) AS Quantity,
       SUM(atr.fDeltaAdjMv) AS DeltaAdjMV,
       SUM(atr.fOptDeltaAdjMv) AS OptDeltaAdjMV,
       MAX(atr.fPrice) AS Price,
       SUM(atr.dDelta1MtdPnlUsd) AS Delta1MtdPnlUsd,
       SUM(atr.dOptMtdPnlUsd) AS dOptMtdPnlUsd,
       SUM(atr.dMtdPnlUsd) AS MtdPnlUsd,
       SUM(atr.dDelta1YtdPnlUsd) AS Delta1YtdPnlUsd,
       SUM(atr.dOptYtdPnlUsd) AS dOptYtdPnlUsd,
       SUM(atr.dYtdPnlUsd) AS YtdPnlUsd,
       SUM(atr.fYtdPnlOfNav) AS YtdPnlOfNav 
  FROM @tResults atr
  GROUP BY atr.AsOfDate,
       atr.BbgTicker
 ORDER BY atr.AsOfDate,
       atr.BbgTicker



/* */
SELECT TOP 10 atr.BbgTicker,
       SUM(dYtdPnlUsd)       
  FROM @tResults atr
  WHERE atr.AsOfDate IN ('12/29/2023', '12/31/2024')
  GROUP BY atr.BbgTicker
  ORDER BY SUM(dYtdPnlUsd) DESC

SELECT TOP 10 atr.BbgTicker,
       SUM(dYtdPnlUsd)       
  FROM @tResults atr
  WHERE atr.AsOfDate IN ('12/29/2023', '12/31/2024')
  GROUP BY atr.BbgTicker
  ORDER BY SUM(dYtdPnlUsd) ASC




