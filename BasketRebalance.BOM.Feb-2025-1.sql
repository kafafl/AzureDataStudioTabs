USE Operations
GO

/*
SELECT CAST(UpdateDate AS DATE) AS AsOfDate, BasketName, ConstName, AVG(BasketWght) AS BasketWght 
  FROM dbo.BasketConstituents bkt
 WHERE (CAST(bkt.UpdateDate AS DATE) >= '10/30/2023' AND CAST(bkt.UpdateDate AS DATE) <= '10/30/2023')
   AND bkt.BasketName = 'MSA1BIO Index'
 GROUP BY CAST(UpdateDate AS DATE), BasketName, ConstName
 ORDER BY ASOfDate, bkt.ConstName

SELECT * 
  FROM dbo.MspbBasketDetails 
 WHERE AsOfDate BETWEEN '03/31/2024' AND '03/31/2024'
 AND BasketTicker = 'MSA1BIOH'
*/

CREATE TABLE #tmpBasketDetails(
  AsOfDate           DATE,
  BasketTicker       VARCHAR(255),
  BbgTicker          VARCHAR(255),
  PctWeight          FLOAT,
  MktCap             FLOAT,
  LastPrice          FLOAT,
  MdPrice            FLOAT,
  AvgVol30D          FLOAT,
  AvgVol90D          FLOAT,
  AvgVol180D         FLOAT,
  AvgVol30D$         FLOAT,
  AvgVol90D$         FLOAT,
  AvgVol180D$        FLOAT,
  msSecName          VARCHAR(500),
  msIdentifier       VARCHAR(500),
  SLRate             NUMERIC(30, 2),  
  SLType             VARCHAR(255),  
  SLAvail            FLOAT, 
  SLDate             DATE,
  bMappedAvail       BIT DEFAULT 0,
  SLSedol            VARCHAR(255),
  SLCusip            VARCHAR(255),
  SLCins             VARCHAR(255),  
  TheraAreaTag       VARCHAR(255),
  GICS_industry      VARCHAR(255),
  bInLongPort        BIT DEFAULT 0,
  bInShortPort       BIT DEFAULT 0,
  bHasMaEvent        BIT DEFAULT 0,
  MaEventDetail      VARCHAR(255),
  MaEventDateTime    DATETIME)


CREATE TABLE #PortView(
  AsOfDate           DATE,
  Strategy           VARCHAR(500),
  BbgTicker          VARCHAR(500),
  PosLong            NUMERIC(30, 2),
  PosNet             NUMERIC(30, 2),
  PosShort           NUMERIC(30, 2))

CREATE TABLE #tmpSLAvail( 
  AsOfDate        DATE, 
  BbgTicker       VARCHAR(500), 
  SecName         VARCHAR(500), 
  IdSedol         VARCHAR(500), 
  IdCusip         VARCHAR(500), 
  IdCins          VARCHAR(500),
  slIdentier      VARCHAR(500), 
  slIdType        VARCHAR(500), 
  AvailAmount     FLOAT, 
  SLRate          NUMERIC(30, 2), 
  SLRateType      VARCHAR(50), 
  UpdateDate      DATETIME) 

  DECLARE @AsOfDate AS DATE = '02/04/2025'


INSERT INTO #PortView(
       AsOfDate,
       Strategy,
       BbgTicker,
       PosLong,
       PosNet,
       PosShort)
  EXEC dbo.p_GetLongPortfolio @AsOfDate = @AsOfDate

INSERT INTO #PortView(
       AsOfDate,
       Strategy,
       BbgTicker,
       PosLong,
       PosNet,
       PosShort)
  EXEC dbo.p_GetShortPortfolio @AsOfDate = @AsOfDate

 INSERT INTO #tmpBasketDetails(
        AsOfDate,
        BasketTicker,
        BbgTicker,
        PctWeight)
 SELECT ASOfDate,
        BasketTicker,
        CompBbg + ' Equity' AS BbgTicker,
        PctWeight 
   FROM dbo.MspbBasketDetails 
  WHERE AsOfDate = @AsOfDate
    AND BasketTicker = 'MSA1BIOH'    -- 'MSA16458'
  ORDER BY PctWeight DESC, CompBbg, AsOfDate

 UPDATE tbd
    SET tbd.BbgTicker = REPLACE(tbd.BbgTicker, 'UA Equity', 'US Equity')
   FROM #tmpBasketDetails tbd

 UPDATE tbd
    SET tbd.BbgTicker = REPLACE(tbd.BbgTicker, 'UN Equity', 'US Equity')
   FROM #tmpBasketDetails tbd

 UPDATE tbd
    SET tbd.BbgTicker = 'BHC CN Equity'
    FROM #tmpBasketDetails tbd
    WHERE CHARINDEX('BHC', tbd.BbgTicker) != 0

 UPDATE tbd
    SET tbd.MktCap = bmu.MarketCap,
        tbd.LastPrice = bmu.PrevPrice,
        tbd.GICS_industry = bmu.GICS_industry
   FROM #tmpBasketDetails tbd
   JOIN dbo.BiotechMasterUniverse bmu
     ON tbd.AsOfDate = bmu.AsOfDate
    AND tbd.BbgTicker = bmu.BbgTicker

 UPDATE tbd
    SET tbd.AvgVol30D = amd.MdValue
   FROM #tmpBasketDetails tbd
   JOIN dbo.AmfMarketData amd
     ON tbd.AsOfDate = amd.AsOfDate
    AND tbd.BbgTicker = amd.PositionId
    AND amd.TagMnemonic = 'VOLUME_AVG_30D'

 UPDATE tbd
    SET tbd.AvgVol90D = amd.MdValue
   FROM #tmpBasketDetails tbd
   JOIN dbo.AmfMarketData amd
     ON tbd.AsOfDate = amd.AsOfDate
    AND tbd.BbgTicker = amd.PositionId
    AND amd.TagMnemonic = 'VOLUME_AVG_3M'

 UPDATE tbd
    SET tbd.AvgVol180D = amd.MdValue
   FROM #tmpBasketDetails tbd
   JOIN dbo.AmfMarketData amd
     ON tbd.AsOfDate = amd.AsOfDate
    AND tbd.BbgTicker = amd.PositionId
    AND amd.TagMnemonic = 'VOLUME_AVG_6M'      

 UPDATE tbd
    SET tbd.MdPrice = amd.MdValue
   FROM #tmpBasketDetails tbd
   JOIN dbo.AmfMarketData amd
     ON tbd.AsOfDate = amd.AsOfDate
    AND tbd.BbgTicker = amd.PositionId
    AND amd.TagMnemonic = 'LAST_PRICE'    
    

 UPDATE tbd
    SET tbd.AvgVol30D$ = tbd.MdPrice * tbd.AvgVol30D,
        tbd.AvgVol90D$ = tbd.MdPrice * tbd.AvgVol90D,
        tbd.AvgVol180D$ = tbd.MdPrice * tbd.AvgVol180D
   FROM #tmpBasketDetails tbd


  UPDATE tbd
     SET tbd.TheraAreaTag = vta.TagValue
    FROM #tmpBasketDetails tbd
    JOIN dbo.vw_TherapeuticAreaTags vta
      ON vta.PositionId = tbd.BbgTicker
   WHERE vta.TagReference = 'Therapeutic Area'

  UPDATE tbd
     SET tbd.bHasMaEvent = 1,
         tbd.MaEventDetail = msx.MsgValue,
         tbd.MaEventDateTime = msx.MsgInTs
    FROM #tmpBasketDetails tbd
    JOIN (SELECT * 
            FROM dbo.MsgQueue msg
           WHERE CHARINDEX('Basket Monitor - M&A', MsgCatagory) != 0
             AND msg.MsgInTs > '10/23/2024') msx
      ON CHARINDEX(tbd.BbgTicker, msx.MsgValue) != 0


  UPDATE tbd
     SET tbd.bInLongPort = 1
    FROM #tmpBasketDetails tbd
    JOIN #PortView pvx
      ON tbd.AsOfDate = pvx.AsOfDate
     AND tbd.BbgTicker = pvx.BbgTicker
   WHERE pvx.Strategy = 'Alpha Long'

  UPDATE tbd
     SET tbd.bInShortPort = 1
    FROM #tmpBasketDetails tbd
    JOIN #PortView pvx
      ON tbd.AsOfDate = pvx.AsOfDate
     AND tbd.BbgTicker = pvx.BbgTicker
   WHERE pvx.Strategy = 'Alpha Short'

 --SELECT DISTINCT amd.TagMnemonic FROM dbo.AmfMarketData amd ORDER BY amd.TagMnemonic


/*  BEGIN STOCK LOAN AVAILABILITY CARVE OUT  */ 
/*  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  */ 
 
      INSERT INTO #tmpSLAvail( 
             AsOfDate, 
             BbgTicker, 
             SecName, 
             IdSedol, 
             IdCusip, 
             IdCins,
             UpdateDate) 
      SELECT bmu.AsOfDate, 
             bmu.BbgTicker, 
             bmu.SecName, 
             RTRIM(LTRIM(bmu.IdSEDOL)), 
             RTRIM(LTRIM(bmu.IdCUSIP)),
             RTRIM(LTRIM(bmu.idCINS)),
             MAX(bmu.SysStartTime) AS TsDataCapture 
        FROM dbo.BiotechMasterUniverse bmu 
       WHERE (bmu.IdSEDOL IS NOT NULL OR bmu.IdCUSIP IS NOT NULL OR bmu.idCINS IS NOT NULL) 
         AND bmu.AsOfDate = @AsOfDate 
       GROUP BY bmu.AsOfDate, 
             bmu.BbgTicker, 
             bmu.SecName,  
             bmu.IdSEDOL, 
             bmu.IdCUSIP,
             bmu.IdCINS 
      HAVING MAX(bmu.SysStartTime) = MAX(bmu.SysStartTime) 
       ORDER BY bmu.AsOfDate, 
             bmu.BbgTicker,  
             bmu.SecName, 
             bmu.IdSEDOL, 
             bmu.IdCUSIP,
             bmu.IdCINS
 
      UPDATE sla 
         SET sla.AvailAmount = msa.AvailAmount, 
             sla.SLRate = msa.SLRate, 
             sla.SLRateType = msa.SLRateType, 
             sla.slIdentier = msa.Identifier, 
             sla.slIdType = 'SEDOL' 
        FROM #tmpSLAvail sla 
        JOIN dbo.MspbSLAvailability msa 
          ON sla.AsOfDate = msa.AsOfDate 
         AND sla.IdSedol = msa.Identifier 
       WHERE sla.slIdentier IS NULL  
          
      UPDATE sla 
         SET sla.AvailAmount = msa.AvailAmount, 
             sla.SLRate = msa.SLRate, 
             sla.SLRateType = msa.SLRateType, 
             sla.slIdentier = msa.Identifier, 
             sla.slIdType = 'CUSIP' 
        FROM #tmpSLAvail sla 
        JOIN dbo.MspbSLAvailability msa 
          ON sla.AsOfDate = msa.AsOfDate 
         AND sla.IdCusip = msa.Identifier 
       WHERE sla.slIdentier IS NULL  
 
      UPDATE sla 
         SET sla.AvailAmount = msa.AvailAmount, 
             sla.SLRate = msa.SLRate, 
             sla.SLRateType = msa.SLRateType, 
             sla.slIdentier = msa.Identifier, 
             sla.slIdType = 'CINS' 
        FROM #tmpSLAvail sla 
        JOIN dbo.MspbSLAvailability msa 
          ON sla.AsOfDate = msa.AsOfDate 
         AND sla.IdCins = msa.Identifier 
       WHERE sla.slIdentier IS NULL  

      UPDATE tbd  
         SET tbd.msSecName = sbd.SecName,
             tbd.msIdentifier = sbd.slIdentier,
             tbd.SLSedol = sbd.IdSedol,
             tbd.SLCusip = sbd.IdCUSIP,
             tbd.SLCins = sbd.IdCINS,            
             tbd.SLRate = sbd.SLRate,  
             tbd.SLType = CASE WHEN sbd.SLRateType = 'R' THEN 'Rebate' WHEN sbd.SLRateType = 'F' THEN 'Fee' END,  
             tbd.SLAvail = sbd.AvailAmount, 
             tbd.SLDate = sbd.AsOfDate, 
             tbd.bMappedAvail = 1 
        FROM #tmpBasketDetails tbd  
        JOIN #tmpSLAvail sbd   
          ON sbd.BbgTicker = tbd.BBgTicker 
       WHERE sbd.SLRate IS NOT NULL
 
/*  END STOCK LOAN AVAILABILITY CARVE OUT  */ 
/*  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  */ 


 SELECT *  
   FROM #tmpBasketDetails tbd
  ORDER BY tbd.PctWeight DESC

RETURN





