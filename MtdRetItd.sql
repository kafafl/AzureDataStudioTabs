USE Operations
GO

  DECLARE @tMapMaster AS TABLE(
    BbgKey            VARCHAR(255),
    UnderlyOne        VARCHAR(255),
    UnderlyTwo        VARCHAR(255))

  DECLARE @tMonthEndDates AS TABLE(
    BegDate           DATE,
    EndDate           DATE,
    bIsProcessed      BIT DEFAULT 0)

  DECLARE @tEntity AS TABLE(
    Entity            VARCHAR(255),
    bIsProcessed      BIT DEFAULT 0)

  DECLARE @tResultsProc AS TABLE(
    AsOfDate          DATE,
    Entity            VARCHAR(255),
    DailyReturn       FLOAT,
    DailyReturnNet    FLOAT,
    PeriodReturn      FLOAT,
    PeriodReturnNet   FLOAT,
    DailyRetLogNet    FLOAT)

  DECLARE @iBegDate AS DATE
  DECLARE @iEndDate AS DATE
  DECLARE @iEntity AS VARCHAR(255)
  

  
/*  INSERTS TO MONTH END DATES   */
INSERT INTO @tMonthEndDates (BegDate, EndDate) SELECT '1/1/2023', '01/31/2023'
INSERT INTO @tMonthEndDates (BegDate, EndDate) SELECT '2/1/2023', '02/28/2023'
INSERT INTO @tMonthEndDates (BegDate, EndDate) SELECT '3/1/2023', '03/31/2023'
INSERT INTO @tMonthEndDates (BegDate, EndDate) SELECT '4/1/2023', '04/28/2023'
INSERT INTO @tMonthEndDates (BegDate, EndDate) SELECT '5/1/2023', '05/31/2023'
INSERT INTO @tMonthEndDates (BegDate, EndDate) SELECT '6/1/2023', '06/30/2023'
INSERT INTO @tMonthEndDates (BegDate, EndDate) SELECT '7/1/2023', '07/31/2023'

INSERT INTO @tMonthEndDates (BegDate, EndDate) SELECT '8/1/2023', '08/31/2023'
INSERT INTO @tMonthEndDates (BegDate, EndDate) SELECT '9/1/2023', '09/29/2023'
INSERT INTO @tMonthEndDates (BegDate, EndDate) SELECT '10/1/2023', '10/31/2023'
INSERT INTO @tMonthEndDates (BegDate, EndDate) SELECT '11/1/2023', '11/30/2023'
INSERT INTO @tMonthEndDates (BegDate, EndDate) SELECT '12/1/2023', '12/29/2023'

INSERT INTO @tMonthEndDates (BegDate, EndDate) SELECT '1/1/2024', '01/31/2024'
INSERT INTO @tMonthEndDates (BegDate, EndDate) SELECT '2/1/2024', '02/29/2024'
INSERT INTO @tMonthEndDates (BegDate, EndDate) SELECT '3/1/2024', '03/28/2024'
INSERT INTO @tMonthEndDates (BegDate, EndDate) SELECT '4/1/2024', '04/30/2024'
INSERT INTO @tMonthEndDates (BegDate, EndDate) SELECT '5/1/2024', '05/31/2024'
INSERT INTO @tMonthEndDates (BegDate, EndDate) SELECT '6/1/2024', '06/28/2024'
INSERT INTO @tMonthEndDates (BegDate, EndDate) SELECT '7/1/2024', '07/31/2024'
INSERT INTO @tMonthEndDates (BegDate, EndDate) SELECT '8/1/2024', '08/30/2024'
INSERT INTO @tMonthEndDates (BegDate, EndDate) SELECT '9/1/2024', '09/30/2024'
INSERT INTO @tMonthEndDates (BegDate, EndDate) SELECT '10/1/2024', '10/31/2024'
INSERT INTO @tMonthEndDates (BegDate, EndDate) SELECT '11/1/2024', '11/29/2024'
INSERT INTO @tMonthEndDates (BegDate, EndDate) SELECT '12/1/2024', '12/31/2024'
INSERT INTO @tMonthEndDates (BegDate, EndDate) SELECT '1/1/2025', '1/31/2025'


INSERT INTO @tEntity (Entity) SELECT 'AMF'
INSERT INTO @tEntity (Entity) SELECT 'XBI US Equity'
INSERT INTO @tEntity (Entity) SELECT 'NBI Index'
INSERT INTO @tEntity (Entity) SELECT 'RGUSHSBT Index'

/*
SELECT TOP 1000 * FROM @tMonthEndDates med ORDER BY med.BegDate
*/

WHILE EXISTS(SELECT 1 FROM @tMonthEndDates tmd WHERE tmd.bIsProcessed = 0)
  BEGIN
    
    UPDATE tee SET tee.bIsProcessed = 0 FROM @tEntity tee

    SELECT TOP 1 @iBegDate = tmd.BegDate, @iEndDate = tmd.EndDate FROM @tMonthEndDates tmd WHERE tmd.bIsProcessed = 0 ORDER BY tmd.EndDate ASC

      WHILE EXISTS(SELECT 1 FROM @tEntity tee WHERE tee.bIsProcessed = 0)
        BEGIN
          
          SELECT TOP 1 @iEntity = tee.Entity FROM @tEntity tee WHERE tee.bIsProcessed = 0 ORDER BY tee.Entity ASC

          INSERT INTO @tResultsProc(
                 AsOfDate,
                 Entity,
                 DailyReturn,
                 DailyReturnNet,
                 PeriodReturn,
                 PeriodReturnNet,
                 DailyRetLogNet)       
            EXEC dbo.p_GetPerformanceDetails @BegDate = @iBegDate, @EndDate = @iEndDate, @EntityName = @iEntity, @bAggHolidays = 1

          UPDATE tee
             SET tee.bIsProcessed = 1
            FROM @tEntity tee
           WHERE tee.Entity = @iEntity

        END 

          UPDATE tmd
             SET tmd.bIsProcessed = 1
            FROM @tMonthEndDates tmd
           WHERE tmd.BegDate = @iBegDate 
             AND tmd.EndDate = @iEndDate

  END




/*  SELECT OUT RESULTS  */
    SELECT trp.AsOfDate,
           trp.Entity,
           trp.PeriodReturnNet,
           tmd.BegDate,
           tmd.EndDate
      FROM @tResultsProc trp
      JOIN @tMonthEndDates tmd
        ON trp.AsOfDate = tmd.EndDate
     ORDER BY trp.AsofDate 