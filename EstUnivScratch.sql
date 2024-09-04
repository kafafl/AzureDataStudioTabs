USE Operations
GO

SELECT reu.AsOfDate,
       reu.JobReference,
       COUNT(*) AS RowCounts,
       MAX(reu.CreatedOn) AS CreatedOn,
       MAX(reu.CreatedBy) AS CreatedBy
  FROM dbo.RiskEstUniverse reu
 GROUP BY reu.AsOfDate,
       reu.JobReference 
 ORDER BY reu.AsOfDate DESC,
       MAX(reu.CreatedOn) DESC 


SELECT TOP 100 * 
FROM dbo.RiskEstUniverse reu

SELECT TOP 100 * 
FROM dbo.RiskEstUniverse reu
ORDER BY reu.AsOfDate DESC, reu.CreatedOn DESC

SELECT TOP 100 * 
FROM dbo.zRaw_RiskEstUniverse zrr




/*

DECLARE @JobRef AS VARCHAR(MAX) = 'jdjeikdjfksosoersidfsidfhsd'

DELETE reu FROM dbo.RiskEstUniverse reu WHERE reu.JobReference = @JobRef

SELECT * FROM dbo.RiskEstUniverse reu WHERE reu.JobReference = @JobRef
GO



DECLARE @AsOfDate AS DATE = '05/09/2024'

 SELECT TOP 1 reu.JobReference FROM dbo.RiskEstUniverse reu WHERE AsOfDate = @AsOfDate ORDER BY reu.CreatedOn DESC

DECLARE @AsOfDate AS DATE = '05/09/2024'
SELECT DISTINCT reu.AssetName FROM dbo.RiskEstUniverse reu WHERE AsOfDate = @AsOfDate


EXEC dbo.p_GetEstUnivDecileMatrix @AsOfDate = '05/09/2024'

EXEC dbo.p_GetEstUnivDecileMatrix @AsOfDate = '05/08/2024'


EXEC dbo.p_ProcessRawEstUnivData @AsOfDate = '05/08/2024', @JobReference = 'dkfjfuUJehdyjrhtyrfj'
*/


SELECT enf.AsOfDate,
       enf.BBYellowKey,
       enf.UnderlyBBYellowKey,
       enf.DeltaAdjMV,
       enf.FairValue,
       enf.* 

FROM dbo.EnfPositionDetails enf
WHERE enf.AsOfDate >= '05/09/2024'
AND  enf.BBYellowKey LIKE 'MSA1%'
ORDER BY enf.BBYellowKey,
enf.AsOfDate DESC






