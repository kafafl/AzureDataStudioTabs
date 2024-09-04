USE Operations
GO

/*

DROP TABLE #tmpXReturns
GO
DROP TABLE #tmpYReturns
GO
DROP TABLE #tmpSampleValues
GO
DROP TABLE #tmpOutput
GO
DROP TABLE #tmpDateRanges
GO
DROP TABLE #Results
GO

*/


CREATE TABLE #tmpDateRanges(
    dtBegDate      DATE,
    dtEndDate      DATE,
    GroupId        INT,
    GroupTag       VARCHAR(255),
    bProcessed     BIT DEFAULT 0)

CREATE TABLE #tmpXReturns(
    AsOfDate       DATE,
    Entity         VARCHAR(255),
    DailyRtrn      FLOAT)

CREATE TABLE #tmpYReturns(
    AsOfDate       DATE,
    Entity         VARCHAR(255),
    DailyRtrn      FLOAT)

CREATE TABLE #tmpSampleValues(
    AsOfDate       DATE,
    GroupId        INT,
    xEntity        VARCHAR(255),    
    yEntity        VARCHAR(255),
    xVal           FLOAT,
    yVal           FLOAT)

CREATE TABLE #tmpOutput(
    GroupId        INT,
    xEntity        VARCHAR(255),
    yEntity        VARCHAR(255),
    correl         FLOAT,
    xStDev         FLOAT,
    yStDev         FLOAT,
    SampleSize     INT)    


CREATE TABLE #Results(
    GroupId        INT,
    GroupTag       VARCHAR(255),
    PeriodEndDate  DATE,
    TopDownExp FLOAT,
    xEntity        VARCHAR(255),
    yEntity        VARCHAR(255),
    correl         FLOAT,
    xStDev         FLOAT,
    yStDev         FLOAT,
    SampleSize     INT)


INSERT INTO #tmpDateRanges(dtBegDate, dtEndDate, GroupId, GroupTag) SELECT '01/01/2023', '01/31/2023', 1, 'Jan-23'
INSERT INTO #tmpDateRanges(dtBegDate, dtEndDate, GroupId, GroupTag) SELECT '02/01/2023', '02/28/2023', 2, 'Feb-23'
INSERT INTO #tmpDateRanges(dtBegDate, dtEndDate, GroupId, GroupTag) SELECT '03/01/2023', '03/31/2023', 3, 'Mar-23'
INSERT INTO #tmpDateRanges(dtBegDate, dtEndDate, GroupId, GroupTag) SELECT '04/01/2023', '04/30/2023', 4, 'Apr-23'
INSERT INTO #tmpDateRanges(dtBegDate, dtEndDate, GroupId, GroupTag) SELECT '05/01/2023', '05/31/2023', 5, 'May-23'
INSERT INTO #tmpDateRanges(dtBegDate, dtEndDate, GroupId, GroupTag) SELECT '06/01/2023', '06/30/2023', 6, 'Jun-23'
INSERT INTO #tmpDateRanges(dtBegDate, dtEndDate, GroupId, GroupTag) SELECT '07/01/2023', '07/31/2023', 7, 'Jul-23'
INSERT INTO #tmpDateRanges(dtBegDate, dtEndDate, GroupId, GroupTag) SELECT '08/01/2023', '08/31/2023', 8, 'Aug-23'
INSERT INTO #tmpDateRanges(dtBegDate, dtEndDate, GroupId, GroupTag) SELECT '09/01/2023', '09/30/2023', 9, 'Sep-23'
INSERT INTO #tmpDateRanges(dtBegDate, dtEndDate, GroupId, GroupTag) SELECT '10/01/2023', '10/31/2023', 10, 'Oct-23'
INSERT INTO #tmpDateRanges(dtBegDate, dtEndDate, GroupId, GroupTag) SELECT '11/01/2023', '11/30/2023', 11, 'Nov-23'
INSERT INTO #tmpDateRanges(dtBegDate, dtEndDate, GroupId, GroupTag) SELECT '12/01/2023', '12/31/2023', 12, 'Dec-23'
INSERT INTO #tmpDateRanges(dtBegDate, dtEndDate, GroupId, GroupTag) SELECT '01/01/2024', '01/31/2024', 13, 'Jan-24'
INSERT INTO #tmpDateRanges(dtBegDate, dtEndDate, GroupId, GroupTag) SELECT '02/01/2024', '02/29/2024', 14, 'Feb-24'
INSERT INTO #tmpDateRanges(dtBegDate, dtEndDate, GroupId, GroupTag) SELECT '03/01/2024', '03/31/2024', 15, 'Mar-24'

/*
INSERT INTO #tmpDateRanges(dtBegDate, dtEndDate, GroupId, GroupTag) SELECT '03/01/2024', '03/31/2024', 15, 'Mar-24'
*/

DECLARE @BegDate AS DATE
DECLARE @EndDate AS DATE
DECLARE @GroupId AS INT
DECLARE @GroupTag AS VARCHAR(255)

DECLARE @EntityX AS VARCHAR(255) = 'AMF LMV'
DECLARE @EntityY AS VARCHAR(255) = 'XBI US Equity'


WHILE EXISTS(SELECT 1 FROM #tmpDateRanges tdr WHERE tdr.bProcessed = 0)
  BEGIN

    DELETE xrt FROM #tmpXReturns xrt
    DELETE yrt FROM #tmpYReturns yrt
    --DELETE spv FROM #tmpSampleValues spv
    DELETE tox FROM #tmpOutput tox

      SELECT TOP 1 @BegDate = tdr.dtBegDate, 
             @EndDate = tdr.dtEndDate,
             @GroupId = tdr.GroupId,
             @GroupTag = tdr.GroupTag
        FROM #tmpDateRanges tdr
       WHERE tdr.bProcessed = 0 
       ORDER BY tdr.GroupId

       PRINT @GroupTag

      INSERT INTO #tmpXReturns(
             AsOfDate,
             Entity,
             DailyRtrn)
      SELECT pdx.AsOfDate,
             pdx.Entity,
             pdx.DailyReturn
        FROM dbo.PerformanceDetails pdx
       WHERE pdx.AsOfDate BETWEEN @BegDate AND @EndDate
         AND pdx.Entity = @EntityX
       ORDER BY pdx.AsOfDate

      INSERT INTO #tmpYReturns(
             AsOfDate,
             Entity,
             DailyRtrn)
      SELECT pdx.AsOfDate,
             pdx.Entity,
             pdx.DailyReturn
        FROM dbo.PerformanceDetails pdx
       WHERE pdx.AsOfDate BETWEEN @BegDate AND @EndDate
         AND pdx.Entity = @EntityY
       ORDER BY pdx.AsOfDate

        INSERT INTO #tmpSampleValues(
               AsOfDate,
               GroupId,
               xEntity,
               yEntity,
               xVal,
               yVal)
        SELECT COALESCE(xrt.AsOfDate, yrt.AsOfDate),
               @GroupId,
               COALESCE(xrt.Entity, @EntityX) AS xEntity,
               COALESCE(yrt.Entity, @EntityY) AS yEntity,
               COALESCE(xrt.DailyRtrn, 0) AS xVal,
               COALESCE(yrt.DailyRtrn, 0) AS yVal 
          FROM #tmpXReturns xrt 
          FULL OUTER JOIN #tmpYReturns yrt 
            ON xrt.AsOfDate = yrt.AsOfDate  
         ORDER BY yrt.AsOfDate



         ;WITH DataAvgStd
             AS (SELECT GroupID,
                        STDEV(xVal) OVER(PARTITION by GroupID) AS xStDev,
                        STDEV(yVal) OVER(PARTITION by GroupID) AS yStDev,
                        COUNT(*) OVER(PARTITION by GroupID) AS SampleSize,
                        MAX(xEntity) OVER(PARTITION by GroupID) AS xEntity,
                        MAX(yEntity) OVER(PARTITION by GroupID) AS yEntity,
                        (xVal - AVG(xVal) OVER(PARTITION by GroupID)) * ( yVal - AVG(yVal) OVER(PARTITION BY GroupID)) AS ExpectedValue
                   FROM #tmpSampleValues s WHERE s.GroupId = @GroupId)  

        INSERT INTO #tmpOutput(
               correl,
               xStDev,
               yStDev,
               GroupId,
               xEntity,
               yEntity,
               SampleSize)
        SELECT SUM(das.ExpectedValue) OVER(PARTITION BY das.GroupID) / (das.SampleSize - 1 ) / (das.xStDev * das.yStDev) AS Correlation,
               das.xStDev,
               das.yStDev,
               das.GroupId,
               das.xEntity,
               das.yEntity,
               das.SampleSize
          FROM DataAvgStd das
         WHERE das.GroupId = @GroupId

        INSERT INTO #Results(
               GroupId,
               GroupTag,
               PeriodEndDate,
               TopDownExp,       
               xEntity,
               yEntity,
               correl,
               xStDev,
               yStDev,
               SampleSize)
        SELECT TOP 1
               tox.GroupId,
               @GroupTag,
               @EndDate,
               ((tox.correl * tox.xStDev) / tox.yStDev),
               tox.xEntity,
               tox.yEntity,
               tox.correl,
               tox.xStDev,
               tox.yStDev,
               tox.SampleSize
          FROM #tmpOutput tox
        WHERE tox.GroupId = @GroupId

        UPDATE tdr
           SET tdr.bProcessed = 1 
          FROM #tmpDateRanges tdr
         WHERE tdr.bProcessed = 0
           AND tdr.GroupId = @GroupId
           AND tdr.GroupTag = @GroupTag
  END 



SELECT * FROM #Results rsx ORDER BY rsx.PeriodEndDate

      /*  */
      SELECT tsv.AsOfDate,
             tsv.GroupId,
             tdr.GroupTag,
             tsv.xEntity,
             tsv.yEntity,
             tsv.xVal,
             tsv.yVal 
        FROM #tmpSampleValues tsv
        JOIN #tmpDateRanges tdr
          ON tsv.GroupId = tdr.GroupId
        ORDER BY tsv.AsOfDate





GO
RETURN










/*
SELECT * FROM DataAvgStd

SELECT distinct GroupID,
       SUM(ExpectedValue) over(partition by GroupID) / (SampleSize - 1 ) / ( XStdev * YSTDev ) AS Correlation
FROM DataAvgStd;

SELECT distinct GroupID,
       SUM(XStdev) over(partition by GroupID) / (SampleSize - 1 ) / ( XStdev * YSTDev ) AS Correlation
FROM DataAvgStd;


       MAX(das.xStDev) AS xStDev,
       MAX(das.yStDev) AS yStDev,

*/
