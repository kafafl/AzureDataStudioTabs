USE Operations
GO

    SELECT TOP 10000 * FROM dbo.BiotechMasterUniverse bmu ORDER BY bmu.AsOfDate DESC, bmu.BbgTicker

    SELECT bmu.AsOfDate,
           count(bmu.AsOfDate) AS RecCount
      FROM dbo.BiotechMasterUniverse bmu
     GROUP BY bmu.AsOfDate
     ORDER BY bmu.AsOfDate



    EXEC dbo.p_GetAmfBiotechUniverse @LowQualityFilter = 1
    GO

    /*
    EXEC dbo.p_ClearBiotechMasterUniverse @AsOfDate = '06/04/2024', @Crncy = 'USD'
    EXEC dbo.p_ClearBiotechMasterUniverse @AsOfDate = '06/04/2024', @Crncy = 'CAD'
    */

 SELECT bfr.AsOfDate,
        bfr.JobReference,
        COUNT(bfr.AsOfDate) AS RecCount,
        MAX(bfr.CreatedOn) AS TsCreatedOn 
   FROM dbo.AmfBiotechFactorReturns bfr
  GROUP BY bfr.AsOfDate,
        bfr.JobReference
  ORDER BY bfr.AsOfDate,
        MAX(bfr.CreatedOn),
        bfr.JobReference


DECLARE @AsOfDate AS DATE
DECLARE @sGUID AS VARCHAR(255)

  SELECT TOP 1 @AsOfDate = abf.AsOfDate, @sGUID = abf.JobReference FROM dbo.AmfBiotechFactorReturns abf ORDER BY abf.AsOfDate DESC, abf.CreatedOn DESC
  
  EXEC dbo.p_GetAmfBiotechUniverse @AsOfDate= @AsOfDate, @LowQualityFilter = 1

  
  SELECT * 
    FROM dbo.AmfBiotechFactorReturns abf
   WHERE abf.AsOfDate = @AsOfDate
     AND abf.JobReference = @sGUID
   ORDER BY abf.AsOfDate,
         abf.AssetId
  GO



EXEC dbo.p_GetAlphaShortBasketOverlapData
GO
