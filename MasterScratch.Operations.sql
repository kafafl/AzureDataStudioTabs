USE Operations
GO

EXEC dbo.p_GetSimplePort

DECLARE @AsOfDate AS DATE = CAST(GETDATE() AS DATE)

/*  BIOTECH UNIVERSE  */
    SELECT TOP 500 bmu.* 
      FROM dbo.BiotechMasterUniverse bmu
     WHERE bmu.AsOfDate = (SELECT TOP 1 bmx.AsOfDate AS AsOfDate FROM dbo.BiotechMasterUniverse bmx ORDER BY bmx.AsOfDate DESC) 
     ORDER BY bmu.SysStartTime DESC
    GO
  
    SELECT bmu.AsOfDate,
           COUNT(bmu.AsOfDate) AS CountDaily
      FROM dbo.BiotechMasterUniverse bmu
     GROUP BY bmu.AsOfDate
     ORDER BY bmu.AsOfDate DESC
    GO


/*  MARKET UNIVERSE  */
    SELECT TOP 500 mmu.* 
      FROM dbo.MarketMasterUniverse mmu
     WHERE mmu.AsOfDate = (SELECT TOP 1 mmx.AsOfDate AS AsOfDate FROM dbo.MarketMasterUniverse mmx ORDER BY mmx.AsOfDate DESC) 
     ORDER BY mmu.SysStartTime DESC
    GO
  
    SELECT mmu.AsOfDate,
           COUNT(mmu.AsOfDate) AS CountDaily,
           mmu.ParentEntity
      FROM dbo.MarketMasterUniverse mmu
     GROUP BY mmu.AsOfDate, mmu.ParentEntity
     ORDER BY mmu.AsOfDate DESC, mmu.ParentEntity
    GO



/* RISK ESTIMATION UNIVERSE FACTOR RETURNS  */
  SELECT TOP 500 reu.* 
    FROM dbo.RiskEstUniverse reu
   WHERE reu.AsOfDate = (SELECT TOP 1 rex.AsOfDate FROM dbo.RiskEstUniverse rex ORDER BY rex.AsOfDate DESC)
   ORDER BY reu.AssetId
  GO
  
  SELECT red.AsOfDate,
         red.JobReference,
         MAX(red.CreatedOn) AS UpdateOn,
         COUNT(red.AsOfDate) AS CountDaily
    FROM dbo.RiskEstUniverse red
   WHERE red.AsOfDate IN (SELECT TOP 5 rex.AsOfDate FROM dbo.RiskEstUniverse rex GROUP BY rex.AsOfDate ORDER BY rex.AsOfDate DESC)
   GROUP BY red.AsOfDate, red.JobReference
   ORDER BY red.AsOfDate DESC, MAX(red.CreatedOn) DESC
  GO


/*  BIOTECH 400 UNIVERSE FACTOR RETURNS  */
  SELECT * 
    FROM dbo.AmfBiotechFactorReturns bfr
   WHERE bfr.AsOfDate = (SELECT TOP 1 bfx.AsOfDate FROM dbo.AmfBiotechFactorReturns bfx ORDER BY bfx.AsOfDate DESC)
   ORDER BY bfr.AssetId

  SELECT red.AsOfDate,
         COUNT(red.AsOfDate) AS CountDaily
    FROM dbo.AmfBiotechFactorReturns red
   GROUP BY red.AsOfDate
   ORDER BY red.AsOfDate DESC
  GO

/*  AMF BASKET DETAILS FROM MSPB  */
  SELECT TOP 100 * 
    FROM dbo.MspbBasketDetails mbd 
   WHERE mbd.AsOfDate = (SELECT TOP 1 mbx.AsOfDate FROM dbo.MspbBasketDetails mbx ORDER BY mbx.AsOfDate DESC)
   ORDER BY mbd.AsOfDate DESC

  SELECT mbd.AsOfDate,
         COUNT(mbd.AsOfDate) AS CountDaily
    FROM dbo.MspbBasketDetails mbd 
   GROUP BY mbd.AsOfDate
   ORDER BY mbd.AsOfDate DESC
  GO


/*  BIOTECH 400 MARKET DATA  */
  SELECT TOP 100 * 
    FROM dbo.AmfMarketData amd 
   WHERE amd.AsOfDate = (SELECT TOP 1 amx.AsOfDate FROM dbo.AmfMarketData amx ORDER BY amx.AsOfDate DESC)
   ORDER BY amd.AsOfDate DESC

  SELECT amd.AsOfDate,
         COUNT(amd.AsOfDate) AS CountDaily
    FROM dbo.AmfMarketData amd 
   GROUP BY amd.AsOfDate
   ORDER BY amd.AsOfDate DESC
  GO

  SELECT amd.AsOfDate,
         amd.TagMnemonic,
         COUNT(amd.AsOfDate) AS CountDaily,
         MAX(COALESCE(amd.UpdatedOn, amd.CreatedOn)) AS UpdateTime
    FROM dbo.AmfMarketData amd 
   GROUP BY amd.AsOfDate,
         amd.TagMnemonic
   ORDER BY amd.AsOfDate DESC,
         --amd.TagMnemonic,
         MAX(COALESCE(amd.UpdatedOn, amd.CreatedOn)) DESC
  GO


/*  MSPB Availability DATA  */
  SELECT TOP 100 * 
    FROM dbo.MspbSLAvailability amd 
   WHERE amd.AsOfDate = (SELECT TOP 1 amx.AsOfDate FROM dbo.MspbSLAvailability amx ORDER BY amx.AsOfDate DESC)
   ORDER BY amd.AsOfDate DESC

SELECT sla.AsOfDate,
       COUNT(sla.AsOfDate) AS CountDaily 
  FROM dbo.MspbSLAvailability sla
 GROUP BY sla.AsOfDate 
 ORDER BY sla.AsOfDate DESC


/*  PERFORMANCE AND ASSET VALUE DATA  */
    SELECT phx.AsOfDate,
          phx.Entity,
          MAX(COALESCE(phx.UpdatedOn, phx.CreatedOn))
     FROM dbo.PerformanceDetails phx
    WHERE phx.AsOfDate = (SELECT MAX(phz.AsOfDate) FROM dbo.PerformanceDetails phz)
    GROUP BY phx.AsOfDate,
          phx.Entity
    ORDER BY MAX(COALESCE(phx.UpdatedOn, phx.CreatedOn)) DESC


   SELECT phx.AsOfDate,
          phx.Entity,
          phx.DailyReturn,
          COALESCE(phx.UpdatedOn, phx.CreatedOn) AS DataTimeStamp
     FROM dbo.PerformanceDetails phx
    WHERE phx.Entity IN ('AMF')
    ORDER BY phx.AsOfDate DESC, COALESCE(phx.UpdatedOn, phx.CreatedOn) DESC

   SELECT phx.AsOfDate,
          phx.Entity,
          phx.AssetValue,
          COALESCE(phx.UpdatedOn, phx.CreatedOn) AS DataTimeStamp
     FROM dbo.FundAssetsDetails phx
    WHERE phx.Entity IN ('AMF NAV')
    ORDER BY phx.AsOfDate DESC, COALESCE(phx.UpdatedOn, phx.CreatedOn) DESC


/*  ADMIN AND ENFUSION POSITION SNAPSHOT  */
    SELECT apd.AsOfDate,
          COUNT(apd.AsOfDate) AS xCount,
          MAX(COALESCE(apd.UpdatedOn, apd.CreatedOn)) AS UpdateInsertTs
     FROM dbo.AdminPositionDetails apd
    GROUP BY apd.AsOfDate
    ORDER BY apd.AsOfDate DESC, 
          MAX(COALESCE(apd.UpdatedOn, apd.CreatedOn)) DESC


    SELECT epd.AsOfDate,
          COUNT(epd.AsOfDate) AS xCount,
          MAX(COALESCE(epd.UpdatedOn, epd.CreatedOn)) AS UpdateInsertTs
     FROM dbo.EnfPositionDetails epd
    GROUP BY epd.AsOfDate
    ORDER BY epd.AsOfDate DESC, 
          MAX(COALESCE(epd.UpdatedOn, epd.CreatedOn)) DESC





