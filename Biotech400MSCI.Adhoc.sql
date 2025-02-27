USE Operations
GO


DECLARE @AsOfDate AS DATE = '12/31/2024'

CREATE TABLE #tmpResults(
    AsOfDate      DATE,
    SecName       VARCHAR(500),
    Industry      VARCHAR(500),
    Sector        VARCHAR(500),
    Crncy         VARCHAR(5),
    BbgTicker     VARCHAR(500),
    IdTicker      VARCHAR(500),
    IdCusip       VARCHAR(500),
    IdSedol       VARCHAR(500),
    SlOfDate      DATE,
    Rebate        FLOAT,
    VlOfDate      DATE,
    MKT_30D_VOL   FLOAT,
    MKT_LAST_PX   FLOAT,
    AvgVol        FLOAT,
    bProcessed    BIT DEFAULT 0)

CREATE TABLE #tmpSLAvail( 
    AsOfDate        DATE, 
    BbgTicker       VARCHAR(500), 
    SecName         VARCHAR(500), 
    IdSedol         VARCHAR(500), 
    IdCusip         VARCHAR(500), 
    slIdentier      VARCHAR(500), 
    slIdType        VARCHAR(500), 
    AvailAmount     FLOAT, 
    SLRate          NUMERIC(30, 2), 
    SLRateType      VARCHAR(50), 
    UpdateDate      DATETIME) 


INSERT INTO #tmpResults(
       AsOfDate,
       SecName,
       Industry,
       Sector,
       Crncy,
       BbgTicker,
       IdTicker,
       IdCusip,
       IdSedol,
       MKT_LAST_PX)
SELECT bmu.AsOfDate,             
       bmu.SecName,
       bmu.GICS_industry,
       bmu.GICS_sector,
       bmu.Crncy,
       bmu.BbgTicker, 
       LTRIM(RTRIM(LEFT(bmu.BbgTicker, CHARINDEX(' ', bmu.BbgTicker)))) AS IdTICKER,
       bmu.IdCUSIP,
       bmu.IdSEDOL,
       bmu.Price
        --, bmu.* 
  FROM dbo.BiotechMasterUniverse bmu
 WHERE bmu.AsOfDate = @AsOfDate



/*  BEGIN STOCK LOAN AVAILABILITY CARVE OUT  */ 
/*  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  */ 
 
      INSERT INTO #tmpSLAvail( 
             AsOfDate, 
             BbgTicker, 
             SecName, 
             IdSedol, 
             IdCusip, 
             UpdateDate) 
      SELECT bmu.AsOfDate, 
             bmu.BbgTicker, 
             bmu.SecName, 
             RTRIM(LTRIM(bmu.IdSEDOL)), 
             RTRIM(LTRIM(bmu.IdCUSIP)), 
             MAX(bmu.SysStartTime) AS TsDataCapture 
        FROM dbo.BiotechMasterUniverse bmu 
       WHERE (bmu.IdSEDOL IS NOT NULL OR bmu.IdCUSIP IS NOT NULL) 
         AND bmu.AsOfDate = @AsOfDate 
       GROUP BY bmu.AsOfDate, 
             bmu.BbgTicker, 
             bmu.SecName,  
             bmu.IdSEDOL, 
             bmu.IdCUSIP 
      HAVING MAX(bmu.SysStartTime) = MAX(bmu.SysStartTime) 
       ORDER BY bmu.AsOfDate, 
             bmu.BbgTicker,  
             bmu.SecName, 
             bmu.IdSEDOL, 
             bmu.IdCUSIP 
 
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
 
 
      UPDATE rdc  
         SET rdc.Rebate = sbd.SLRate,    
             rdc.SlOfDate = sbd.AsOfDate, 
             rdc.bProcessed = 1 
        FROM #tmpResults rdc  
        JOIN #tmpSLAvail sbd   
          ON sbd.BbgTicker = rdc.BBgTicker 
 
/*  END STOCK LOAN AVAILABILITY CARVE OUT  */ 
/*  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  */ 



       UPDATE rdc 
          SET rdc.MKT_30D_VOL = amd.MdValue 
         FROM #tmpResults rdc  
         JOIN dbo.AmfMarketData amd 
           ON rdc.AsOfDate = amd.AsOfDate 
          AND rdc.BbgTicker = amd.PositionId 
        WHERE amd.DataSource = 'Bloomberg'  
          AND amd.TagMnemonic = 'VOLUME_AVG_30D' 

       UPDATE rdc 
          SET rdc.MKT_LAST_PX = amd.MdValue,
              rdc.VlOfDate = amd.AsOfDate
         FROM #tmpResults rdc  
         JOIN dbo.AmfMarketData amd 
           ON rdc.AsOfDate = amd.AsOfDate 
          AND rdc.BbgTicker = amd.PositionId 
        WHERE amd.DataSource = 'Bloomberg'  
          AND amd.TagMnemonic = 'LAST_PRICE' 

       UPDATE rdc
          SET rdc.AvgVol = rdc.MKT_30D_VOL * rdc.MKT_LAST_PX
         FROM #tmpResults rdc  


SELECT * FROM #tmpResults trs WHERE trs.Industry IN ('Pharmaceuticals', 'xBiotechnology') AND COALESCE(trs.Rebate, 0) >= 3.0 AND COALESCE(trs.AvgVol, 0) >= 750000 

SELECT * FROM #tmpResults trs WHERE trs.Industry IN ('Pharmaceuticals', 'Biotechnology') AND trs.Rebate IS NULL

SELECT * FROM #tmpResults trs WHERE trs.Industry IN ('Pharmaceuticals', 'Biotechnology') AND trs.AvgVol IS NULL