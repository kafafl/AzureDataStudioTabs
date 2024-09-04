USE Operations
GO

ALTER PROCEDURE [dbo].[p_GetPerformanceByPeriod]( 
    @BegDate         DATE, 
    @EndDate         DATE, 
    @EntityName      VARCHAR(255), 
    @bAggHolidays    BIT = 1,
	@OutputWeekly    BIT = 0) 
 
/* 
  Author:   Lee Kafafian 
  Crated:   01/04/2024 
  Object:   p_GetPerformanceByPeriod 
  Example:  EXEC dbo.p_GetPerformanceByPeriod @BegDate = '01/05/2023', @EndDate = '12/31/2023', @EntityName = 'AMF' 
 */ 
   
  AS  
 
    BEGIN 
       
      CREATE TABLE #tmpDateDetail( 
        AsOfDate	      DATE NOT NULL, 
        IsWeekday	      BIT, 
        IsMktHoliday      BIT,
        bProcessed        BIT DEFAULT 0) 
 
      CREATE TABLE #tmpPerfReturnData( 
        AsOfDate          DATE NOT NULL, 
        Entity            VARCHAR(500), 
        DailyReturn       FLOAT, 
		DailyReturnNet    FLOAT, 
		DailyRetLogNet    FLOAT, 
        PeriodReturn      FLOAT, 
		PeriodReturnNet   FLOAT, 
        bProcessed        BIT DEFAULT 0)

      CREATE TABLE #tmpPerfDataPeriod( 
        BegDate           DATE NOT NULL,
        EndDate           DATE NOT NULL,
        Entity            VARCHAR(500), 
        PeriodReturn      FLOAT, 
		PeriodRetNet      FLOAT, 
        bProcessed        BIT DEFAULT 0)

       DECLARE @CurrWeekEnd AS DATE
       DECLARE @PrevWeekEnd AS DATE
       DECLARE @StartWeekDt AS DATE
       DECLARE @PeriodReturn AS FLOAT
       DECLARE @PeriodRetNet AS FLOAT
       DECLARE @bStartDate AS BIT = 0

        INSERT INTO #tmpDateDetail( 
               AsOfDate, 
               IsWeekday, 
               IsMktHoliday) 
        SELECT AsOfDate, 
               IsWeekday, 
               IsMktHoliday 
          FROM dbo.DateMaster dmx 
         WHERE dmx.AsOfDate BETWEEN @BegDate AND @EndDate 


    /*  LOGIC HERE FOR OTHER PERIODS BESIDES WTD  */
        DELETE tdd
          FROM #tmpDateDetail tdd
         WHERE DATEPART(dw, tdd.AsOfDate) != 6

        
         WHILE EXISTS(SELECT TOP 1 tdd.AsOfDate FROM #tmpDateDetail tdd WHERE tdd.bProcessed = 0 ORDER BY tdd.AsOfDate ASC)
           BEGIN      

             SELECT @bStartDate = 0
             DELETE trd FROM #tmpPerfReturnData trd
              
               IF @PrevWeekEnd IS NULL 
                 BEGIN
                   WHILE DATEPART(dw, @BegDate) = 7 OR DATEPART(dw, @BegDate) = 1 AND @BegDate != @CurrWeekEnd
                     BEGIN
                       SELECT @BegDate = DATEADD(DD, -1, @BegDate)
                     END                     
                    
                    SELECT @PrevWeekEnd = @BegDate
                    SELECT @bStartDate = 1
                    PRINT '>> ' + CAST(@PrevWeekEnd AS VARCHAR(255))

                END
              ELSE
                BEGIN
                  SELECT @PrevWeekEnd = @CurrWeekEnd
                END


              SELECT @StartWeekDt = @PrevWeekEnd

              IF @bStartDate = 0
                BEGIN
                  WHILE DATEPART(dw, @StartWeekDt) != 2
                    BEGIN
                      SELECT @StartWeekDt = DATEADD(DD, 1, @StartWeekDt)
                    END
                END
              ELSE
                BEGIN
                  SELECT @StartWeekDt = @StartWeekDt
                END           
               
              SELECT TOP 1  @CurrWeekEnd = tdd.AsOfDate FROM #tmpDateDetail tdd WHERE tdd.bProcessed = 0 ORDER BY tdd.AsOfDate ASC

              UPDATE tdd
                 SET tdd.bProcessed = 1
                FROM #tmpDateDetail tdd
               WHERE tdd.AsOfDate = @CurrWeekEnd


              SELECT @PeriodReturn = NULL
              SELECT @PeriodRetNet = NULL

              INSERT INTO #tmpPerfReturnData( 
                     AsOfDate, 
                     Entity, 
                     DailyReturn, 
		             DailyReturnNet,		              
                     PeriodReturn, 
		             PeriodReturnNet,
                     DailyRetLogNet)
                EXEC dbo.p_GetPerformanceDetails  @BegDate = @StartWeekDt, @EndDate = @CurrWeekEnd, @EntityName = @EntityName, @bAggHolidays = 1 

              SELECT TOP 1 @PeriodReturn = trd.PeriodReturn,
                     @PeriodRetNet = trd.PeriodReturnNet
                FROM #tmpPerfReturnData trd 
               ORDER BY trd.AsOfDate DESC

              INSERT INTO #tmpPerfDataPeriod(
                     BegDate,
                     EndDate,
                     Entity, 
                     PeriodReturn, 
		             PeriodRetNet)
              SELECT @StartWeekDt,
                     @CurrWeekEnd,
                     @EntityName,
                     @PeriodReturn,
                     @PeriodRetNet

             END


        SELECT pdp.BegDate,
               pdp.EndDate,
               pdp.Entity, 
               pdp.PeriodReturn, 
               pdp.PeriodRetNet 
          FROM #tmpPerfDataPeriod pdp 
         ORDER BY pdp.EndDate

    END 

GO

GRANT EXECUTE ON dbo.p_GetPerformanceByPeriod TO PUBLIC
GO

