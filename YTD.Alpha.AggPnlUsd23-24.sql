USE Operations
GO

  DECLARE @tResults AS TABLE(
    AsOfDate          DATE,
    StratName         VARCHAR(255),
    BbgTicker         VARCHAR(255),
    bModMap           INT,
    dYtdPnlUsd        NUMERIC(30, 2),
    dDelta1YtdPnlUsd  NUMERIC(30, 2),
    dOptYtdPnlUsd     NUMERIC(30, 2),
    fYtdPnlOfNav      FLOAT)

  DECLARE @tMapMaster AS TABLE(
    BbgKey            VARCHAR(255),
    UnderlyOne        VARCHAR(255),
    UnderlyTwo        VARCHAR(255))

  DECLARE @AsOfDate AS DATE = '12/31/2024'

  INSERT INTO @tResults(
         AsOfDate,
         StratName,
         BbgTicker,
         bModMap,
         dDelta1YtdPnlUsd,
         dOptYtdPnlUsd,
         dYtdPnlUsd,
         fYtdPnlOfNav)
  SELECT epd.AsOfDate,
         epd.StratName,
         CASE WHEN epd.UnderlyBBYellowKey = '' 
              THEN 
                CASE WHEN epd.BBYellowKey = '' 
                     THEN '|' + epd.InstDescr + '|' 
                     ELSE '|' + epd.BBYellowKey + '|'
                END
              ELSE epd.UnderlyBBYellowKey END AS BBYellowKey,
         CASE WHEN epd.UnderlyBBYellowKey = '' 
              THEN 
                CASE WHEN epd.BBYellowKey = '' 
                     THEN 3 
                     ELSE 2
                END
              ELSE 1 END AS bModMap,
         --epd.InstrType,
         SUM(CASE WHEN epd.InstrType IN ('Equity') THEN epd.YtdPnlUsd ELSE 0 END),
         SUM(CASE WHEN epd.InstrType IN ('Listed Option', 'Warrant', 'OTC Option') THEN epd.YtdPnlUsd ELSE 0 END) AS OptYtdPnlUsd, 
         SUM(epd.YtdPnlUsd) AS YtdPnlUsd,
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
                     THEN '|' + epd.InstDescr + '|' 
                     ELSE '|' + epd.BBYellowKey + '|'
                END
              ELSE epd.UnderlyBBYellowKey
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
   ORDER BY CASE WHEN epd.UnderlyBBYellowKey = '' 
              THEN 
                CASE WHEN epd.BBYellowKey = '' 
                     THEN 3 
                     ELSE 2
                END
              ELSE 1 END DESC,
              CASE WHEN epd.UnderlyBBYellowKey = '' 
              THEN 
                CASE WHEN epd.BBYellowKey = '' 
                     THEN '|' + epd.InstDescr + '|' 
                     ELSE '|' + epd.BBYellowKey + '|'
                END
              ELSE epd.UnderlyBBYellowKey
            END

/*  INSERTS TO MAP NAMES WITHOUT MARKET IDENTIFIERS  */
    INSERT INTO @tMapMaster(BbgKey, UnderlyOne, UnderlyTwo) SELECT   '|AMBRX BIOPHARMA ORD|', 'AMAM US Equity', ''
    INSERT INTO @tMapMaster(BbgKey, UnderlyOne, UnderlyTwo) SELECT   '|APPLIED MOLECULAR TRANSPORT ORD|', 'AMTI US Equity', ''
    INSERT INTO @tMapMaster(BbgKey, UnderlyOne, UnderlyTwo) SELECT   '|BELLICUM PHARMACEUTICALS ORD|', 'BLCM US Equity', ''
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


 /* 
     SELECT * FROM @tMapMaster
 */

UPDATE atr
  SET atr.BbgTicker = tmm.UnderlyOne
 FROM @tResults atr
 JOIN @tMapMaster tmm
   ON atr.BbgTicker = tmm.BbgKey

SELECT atr.AsOfDate,
       atr.StratName,
       atr.BbgTicker,
       SUM(atr.dDelta1YtdPnlUsd) AS Delta1YtdPnlUsd,
       SUM(atr.dOptYtdPnlUsd) AS dOptYtdPnlUsd,
       SUM(atr.dYtdPnlUsd) AS YtdPnlUsd,
       SUM(atr.fYtdPnlOfNav) AS YtdPnlOfNav 
  FROM @tResults atr
  GROUP BY atr.AsOfDate,
       atr.StratName,
       atr.BbgTicker
 ORDER BY atr.AsOfDate,
       atr.StratName,
       atr.BbgTicker






