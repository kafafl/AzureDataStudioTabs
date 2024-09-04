

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[zRaw_RiskEstUniverse]') AND type in (N'U'))
DROP TABLE [dbo].[zRaw_RiskEstUniverse]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[zRaw_RiskEstUniverse](
	[Indent]                        VARCHAR(MAX) NULL,
    [Asset ID]                      VARCHAR(MAX) NULL,
    [Asset Name]                    VARCHAR(MAX) NULL,
    [factor]                        VARCHAR(MAX) NULL,
    [value]                         VARCHAR(MAX) NULL) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

GRANT SELECT, UPDATE, INSERT, DELETE TO PUBLIC
GO


/*


SELECT TOP 1000 * FROM dbo.zRaw_RiskEstUniverse

SELECT TOP 1000 * FROM dbo.RiskEstUniverse


*/


IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RiskEstUniverse]') AND type in (N'U'))
DROP TABLE [dbo].[RiskEstUniverse]
GO

CREATE TABLE [dbo].[RiskEstUniverse](
    IdxRow                         BIGINT IDENTITY(1, 1),
    AsOfDate                       DATE,
    AssetId                        VARCHAR(MAX),
    AssetName                      VARCHAR(MAX),
    FactorName                     VARCHAR(MAX),
    RetValue                       FLOAT,
    JobReference                   VARCHAR(255),
    CreatedBy                      VARCHAR(50)    CONSTRAINT DF_RiskEstUnivDetail_CreatedBy DEFAULT(SUSER_NAME()),
    CreatedOn                      DATETIME       CONSTRAINT DF_RiskEstUnivDetail_CreatedOn DEFAULT(GETDATE())
    ) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

GRANT SELECT, UPDATE, INSERT, DELETE TO PUBLIC
GO



SELECT TOP N PERCENT FROM TheTable ORDER BY TheScore DESC

SELECT TOP 10 PERCENT  RetValue FROM dbo.RiskEstUniverse reu
WHERE reu.FactorName = 'Investment Quality Exp'

/*
    RowNum = Row_Number() OVER(Order By OrderQty),
    Rnk = RANK() OVER(ORDER BY OrderQty),
    DenseRnk = DENSE_RANK() OVER(ORDER BY OrderQty),
    */

SELECT FactorName,
    NTile4  = NTILE(10) OVER(ORDER BY RetValue)
FROM dbo.RiskEstUniverse reu
WHERE reu.FactorName = 'Investment Quality Exp'


SELECT DISTINCT reu.FactorName,
    percentile_cont(0.9) within group (order by [RetValue]) over () AS [90%],
    percentile_cont(0.8) within group (order by [RetValue]) over () AS [80%],
    percentile_cont(0.7) within group (order by [RetValue]) over () AS [70%],
    percentile_cont(0.6) within group (order by [RetValue]) over () AS [60%],
    percentile_cont(0.5) within group (order by [RetValue]) over () AS [50%],
    percentile_cont(0.4) within group (order by [RetValue]) over () AS [40%],
    percentile_cont(0.3) within group (order by [RetValue]) over () AS [30%],
    percentile_cont(0.2) within group (order by [RetValue]) over () AS [20%],
    percentile_cont(0.1) within group (order by [RetValue]) over () AS [10%]
FROM dbo.RiskEstUniverse reu
WHERE reu.FactorName = 'Investment Quality Exp'


SELECT DISTINCT reu.FactorName 
  FROM dbo.RiskEstUniverse reu
 ORDER BY reu.FactorName

SELECT  * FROM dbo.RiskEstUniverse reu WHERE reu.JobReference = 'KuJYh7^7w25jh6hu)'
 ORDER BY reu.FactorName


UPDATE reu
   SET reu.JobReference = 'jdjeikdjfksosoersidfsidfhsd'
FROM dbo.RiskEstUniverse reu WHERE reu.JobReference = 'KuJYh7^7w25jh6hu)'


