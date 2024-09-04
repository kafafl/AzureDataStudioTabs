USE Operations
GO

/*

   DROP TABLE #tmpPositions
   GO

   DROP TABLE #tmpAttribution
   GO

   DROP TABLE #tmpAttribSource
   GO

   DROP TABLE #tmpStrategyMap
   GO

*/

    CREATE TABLE #tmpPositions(  
      [AsOfDate]             DATE          NOT NULL,
      [FundShortName]        VARCHAR (255) NOT NULL,
      [StratName]            VARCHAR (255) NULL,
      [BookName]             VARCHAR (255) NULL,
      [InstDescr]            VARCHAR (255) NOT NULL,
      [BBYellowKey]	         VARCHAR (255) NULL,
      [UnderlyBBYellowKey]   VARCHAR (255) NULL,
      [Account]	             VARCHAR (255) NOT NULL,
      [CcyOne]               VARCHAR (255) NULL,
      [CcyTwo]               VARCHAR (255) NULL,
      [InstrType]            VARCHAR (255) NULL,
      [Quantity]             FLOAT (53) NULL,
      [NetAvgCost]           FLOAT (53) NULL,
      [OverallCost]          FLOAT (53) NULL,
      [FairValue]	           FLOAT (53) NULL,
      [NetMarketValue]       FLOAT (53) NULL,
      [DlyPnlUsd]            FLOAT (53) NULL,
      [DlyPnlOfNav]          FLOAT (53) NULL,
      [MtdPnlUsd]	           FLOAT (53) NULL,
      [MtdPnlOfNav]          FLOAT (53) NULL,
      [YtdPnlUsd]            FLOAT (53) NULL,
      [YtdPnlOfNav]          FLOAT (53) NULL,
      [ItdPnlUsd]            FLOAT (53) NULL,      
      [Delta]                FLOAT (53),
      [DeltaAdjMV]           FLOAT (53),
      [DeltaExp]             FLOAT (53) NULL,
      [LongShort]            VARCHAR (255) NULL,
      [GrossExp]             FLOAT (53) NULL,
      [LongMV]               FLOAT (53) NULL,
      [ShortMV]              FLOAT (53) NULL,
      [GrExpOfGLNav]         FLOAT (53) NULL,
      [InstrTypeCode]        VARCHAR (255) NULL,
      [InstrTypeUnder]       VARCHAR (255) NULL,
      [PrevBusDayNMV]       FLOAT(53)     NULL)

    CREATE TABLE #tmpAttribution(
      [AsOfDate]             DATE          NOT NULL,
      [Strategy]             VARCHAR (255) NULL,
      [BBYellowKey]          VARCHAR (255) NULL,
      [Currency]             VARCHAR(8)    NULL,
      [TherapeuticTag]       VARCHAR(255)  NULL,
      [Quantity]             FLOAT (53)    NULL,
      [DtdPnlUsd]            FLOAT (53)    NULL,
      [ItdPnlUsd]            FLOAT (53)    NULL,
      [QuantityChng]         FLOAT(53)     NULL,
      [CurrPrice]            FLOAT,
      [CurrReturn]           FLOAT,
      [CurrFxRate]           FLOAT,
      [CurrMarketValue]      FLOAT(53)     NULL,      
      [PrevPriceDate]        DATE,
      [PrevQuantity]         FLOAT (53)    NULL,
      [PrevPrice]            FLOAT,
      [PrevFxRate]           FLOAT,           
      [PrevMarketValue]      FLOAT(53)     NULL,
      [PrevDtdPnlUsd]        FLOAT (53)    NULL,
      [PrevItdPnlUsd]        FLOAT (53)    NULL,
      [MtmDtdPnl]            FLOAT(53)     NULL,
      [HedgeName]            VARCHAR(255),
      [HedgeMarketValue]     FLOAT(53)     NULL,  
      [HedgePerformance]     FLOAT(53),
      [HedgeDtdPnl]          FLOAT(53)     NULL,
      [HedgedPnlUsd]         FLOAT(53)     NULL,
      [OptionDeltaMv]        FLOAT(53)     NULL,
      [IsOption]             BIT           NULL,
      )  
    
    CREATE TABLE #tmpAttribSource(
      [AsOfDate]             DATE          NOT NULL,
      [Strategy]             VARCHAR (255) NULL,
      [BBYellowKey]          VARCHAR (255) NULL,
      [Currency]             VARCHAR(8)    NULL,
      [TherapeuticTag]       VARCHAR(255)  NULL,
      [Quantity]             FLOAT (53)    NULL,
      [DtdPnlUsd]            FLOAT (53)    NULL,
      [ItdPnlUsd]            FLOAT (53)    NULL,
      [QuantityChng]         FLOAT(53)     NULL,
      [CurrPrice]            FLOAT,
      [CurrReturn]           FLOAT,
      [CurrFxRate]           FLOAT,
      [CurrMarketValue]      FLOAT(53)     NULL,      
      [PrevPriceDate]        DATE,
      [PrevQuantity]         FLOAT (53)    NULL,
      [PrevPrice]            FLOAT,
      [PrevFxRate]           FLOAT,           
      [PrevMarketValue]      FLOAT(53)     NULL,
      [MtmDtdPnl]            FLOAT(53)     NULL,
      [HedgeName]            VARCHAR(255),
      [HedgeMarketValue]     FLOAT(53)     NULL,  
      [HedgePerformance]     FLOAT(53),
      [HedgeDtdPnl]          FLOAT(53)     NULL,
      [HedgedPnlUsd]         FLOAT(53)     NULL,
      [OptionDeltaMv]        FLOAT(53)     NULL,
      [IsOption]             BIT           NULL)  

    CREATE TABLE #tmpStrategyMap(
      [BBYellowKey]         VARCHAR(255),
      [Strategy]            VARCHAR(255))


   DECLARE @dtBegDate AS DATE = '12/29/2022'    /* ALWAYS need prior business day for beginning quantities and marketvalues)  */
   DECLARE @dtEndDate AS DATE = '01/31/2024'
   DECLARE @dtCurDate AS DATE = @dtBegDate
   DECLARE @dtPrevDate AS DATE
   DECLARE @sHedgeName AS VARCHAR(255) = 'XBI US Equity'
   DECLARE @IncludeOptions AS BIT = 0
   DECLARE @HedgePnl AS BIT = 0

   
   WHILE (@dtCurDate <= @dtEndDate)
     BEGIN

  /* ONLY USE MARKET DATES */
    IF NOT EXISTS(SELECT 1 FROM dbo.DateMaster dmx WHERE dmx.AsOfDate = @dtCurDate AND dmx.IsWeekday = 1)
      BEGIN
        SELECT TOP 1 @dtCurDate = dmx.AsOfDate FROM dbo.DateMaster dmx WHERE dmx.AsOfDate > @dtCurDate AND dmx.IsWeekday = 1 ORDER BY dmx.AsOfDate ASC
      END
       
      SELECT TOP 1 @dtPrevDate = dmx.AsOfDate FROM dbo.DateMaster dmx WHERE dmx.AsOfDate < @dtCurDate AND dmx.IsWeekday = 1 ORDER BY dmx.AsOfDate DESC

     DELETE tpx 
       FROM #tmpPositions tpx

     DELETE tps
       FROM #tmpAttribSource tps
       
     INSERT INTO #tmpPositions(
            AsOfDate,
            FundShortName,
            StratName,
            BookName,
            InstDescr,
            BBYellowKey,
            UnderlyBBYellowKey,
            Account,
            InstrType,
            CcyOne,
            CcyTwo,
            Quantity,
            NetAvgCost,
            OverallCost,
            FairValue,
            NetMarketValue,
            DlyPnlUsd,
            DlyPnlOfNav,
            MtdPnlUsd,
            MtdPnlOfNav,
            YtdPnlUsd,
            YtdPnlOfNav,
            ItdPnlUsd,
            Delta,
            DeltaAdjMV,
            DeltaExp,
		        LongShort,
            LongMV,
            ShortMv,
            GrExpOfGLNav,
            InstrTypeCode,
            InstrTypeUnder,
            PrevBusDayNMV)
       EXEC dbo.p_GetEnfPositionData @AsOfDate = @dtCurDate, @ResultSet = 2
            
       /*   EXEC dbo.p_GetEnfPositionData @AsOfDate = '01/12/2024'  */

 /*  CLEAR BASE DATA TABLES  */
     DELETE tpx 
       FROM #tmpPositions tpx
      WHERE (tpx.StratName != 'Alpha Short' AND tpx.StratName != 'Alpha Long')   /* Olden days when this script didn't have ex-USD  OR tpx.CcyOne != 'USD'   */

 /*  Equities query for direct shares  */
     INSERT INTO #tmpAttribSource(
            AsOfDate,
            BBYellowKey,
            Currency,
            Quantity,
            DtdPnlUsd,
            ItdPnlUsd,
            PrevPriceDate)
     SELECT tpx.AsOfDate,
            tpx.BBYellowKey,
            tpx.CcyOne,
            SUM(COALESCE(tpx.Quantity, 0)),
            SUM(COALESCE(tpx.DlyPnlUsd, 0)),
            SUM(COALESCE(tpx.ItdPnlUsd, 0)),            
            @dtPrevDate
       FROM #tmpPositions tpx
      WHERE COALESCE(tpx.BBYellowKey, '') != ''
        AND tpx.InstrType = 'Equity'        
      GROUP BY tpx.AsOfDate,
            tpx.BBYellowKey,
            tpx.CcyOne

 /*  Options query to proxy shares  */
    IF @IncludeOptions = 1
      BEGIN
        INSERT INTO #tmpAttribSource(
               AsOfDate,
               BBYellowKey,
               Currency,
               Quantity,
               DtdPnlUsd,
               ItdPnlUsd,
               PrevPriceDate,
               OptionDeltaMv)
        SELECT tpx.AsOfDate,
               tpx.UnderlyBBYellowKey,
               tpx.CcyOne  ,
               ROUND(SUM(COALESCE(tpx.DeltaAdjMV, 0)/COALESCE(phx.Price, 0)), 0) AS Quantity,               
               SUM(COALESCE(tpx.DlyPnlUsd, 0)),
               SUM(COALESCE(tpx.ItdPnlUsd, 0)),  
               @dtPrevDate,
               SUM(tpx.DeltaAdjMV) AS DeltaAdjMv
          FROM #tmpPositions tpx 
          JOIN dbo.PriceHistory phx
            ON tpx.UnderlyBBYellowKey = phx.PositionId 
           AND tpx.AsOfDate = phx.AsOfDate  
         WHERE tpx.InstrType = 'Listed Option'
           AND tpx.StratName IN ('Alpha Long', 'Alhpha Short')
           AND phx.TagMnemonic = 'LAST_PRICE'
           AND phx.PositionIdType = 'Bloomberg Ticker'
         GROUP BY tpx.AsOfDate,
               tpx.CcyOne,
               tpx.UnderlyBBYellowKey
      END 

 /*  COLLAPSE EQUITY AND OPTION POSITIONS TO ONE */
     INSERT INTO #tmpAttribution(
            AsOfDate,
            BBYellowKey,
            Currency,
            PrevPriceDate,
            Quantity,
            DtdPnlUsd,
            ItdPnlUsd)
     SELECT tas.AsOfDate,
            tas.BBYellowKey,
            tas.Currency,
            PrevPriceDate,
            SUM(tas.Quantity),
            SUM(tas.DtdPnlUsd),
            SUM(tas.ItdPnlUsd)             
       FROM #tmpAttribSource tas
      GROUP BY tas.AsOfDate,
            tas.BBYellowKey,
            tas.Currency,
            PrevPriceDate 

-->  SHOULD BE A NEW STATE OF THE #tmpAttribution


/*   PRICE HISTORY FROM BLOOMBERG    */
     UPDATE taa
        SET taa.CurrPrice = phx.Price
       FROM #tmpAttribution taa
       JOIN dbo.PriceHistory phx
         ON taa.BBYellowKey = phx.PositionId
        AND taa.AsOfDate = phx.AsOfDate
        AND taa.AsOfDate = @dtCurDate
        AND phx.TagMnemonic = 'LAST_PRICE'

     UPDATE taa
        SET taa.CurrFxRate = phx.Price
       FROM #tmpAttribution taa
       JOIN dbo.PriceHistory phx
         ON CHARINDEX(taa.Currency, phx.PositionId) != 0
        AND taa.AsOfDate = phx.AsOfDate
        AND taa.AsOfDate = @dtCurDate
        AND phx.TagMnemonic = 'LAST_PRICE'
        AND CHARINDEX('Curncy', phx.PositionId) != 0

     UPDATE taa
        SET taa.CurrFxRate = 1.00
       FROM #tmpAttribution taa
      WHERE taa.AsOfDate = @dtCurDate
        AND taa.CurrFxRate IS NULL     

     UPDATE taa
        SET taa.CurrReturn = phx.Price
       FROM #tmpAttribution taa
       JOIN dbo.PriceHistory phx
         ON taa.BBYellowKey = phx.PositionId
        AND taa.AsOfDate = phx.AsOfDate
        AND taa.AsOfDate = @dtCurDate
        AND phx.TagMnemonic = 'DAY_TO_DAY_TOT_RETURN_GROSS_DVDS'

     UPDATE taa
        SET taa.PrevPrice = phz.Price
       FROM #tmpAttribution taa
       JOIN dbo.PriceHistory phz
         ON taa.BBYellowKey = phz.PositionId
        AND taa.AsOfDate = @dtCurDate
        AND taa.PrevPriceDate = phz.AsOfDate
        AND phz.AsOfDate = @dtPrevDate
        AND phz.TagMnemonic = 'LAST_PRICE'

     UPDATE taa
        SET taa.PrevFxRate = phz.Price
       FROM #tmpAttribution taa
       JOIN dbo.PriceHistory phz
         ON CHARINDEX(taa.Currency, phz.PositionId) != 0
        AND taa.AsOfDate = @dtCurDate
        AND taa.PrevPriceDate = phz.AsOfDate
        AND phz.AsOfDate = @dtPrevDate
        AND phz.TagMnemonic = 'LAST_PRICE'
        AND CHARINDEX('Curncy', phz.PositionId) != 0

     UPDATE taa
        SET taa.PrevFxRate = 1.00
       FROM #tmpAttribution taa
      WHERE taa.AsOfDate = @dtCurDate
        AND taa.PrevFxRate IS NULL        
        

/*   UPDATE CURRENT MARKET VALUE  FOR USD  */
     UPDATE taa
        SET taa.CurrMarketValue = COALESCE(taa.CurrPrice, 0) * COALESCE(taa.Quantity, 0)
       FROM #tmpAttribution taa
      WHERE taa.AsOfDate = @dtCurDate
        AND taa.Currency = 'USD'

/*   UPDATE CURRENT MARKET VALUE FOR JPY    */
     UPDATE taa
        SET taa.CurrMarketValue = (COALESCE(taa.CurrPrice, 0) / COALESCE(taa.CurrFxRate, 1)) * COALESCE(taa.Quantity, 0)
       FROM #tmpAttribution taa
      WHERE taa.AsOfDate = @dtCurDate
        AND taa.Currency IN ('JPY')

/*   UPDATE CURRENT MARKET VALUE FOR EUR, CAD, AUD  */
     UPDATE taa
        SET taa.CurrMarketValue = (COALESCE(taa.CurrPrice, 0) * COALESCE(taa.CurrFxRate, 0)) * COALESCE(taa.Quantity, 0)
       FROM #tmpAttribution taa
      WHERE taa.AsOfDate = @dtCurDate
        AND taa.Currency IN ('EUR', 'AUD', 'CAD')


/*   PREVIOUS QUANTITY AND QUANTITY CHANGE  */
     UPDATE taa
        SET taa.PrevQuantity = COALESCE(tah.Quantity, 0),
            taa.QuantityChng = COALESCE(taa.Quantity, 0) - COALESCE(tah.Quantity, 0),
            taa.PrevDtdPnlUsd = COALESCE(tah.DtdPnlUsd, 0),
            taa.PrevItdPnlUsd = COALESCE(tah.ItdPnlUsd, 0)
       FROM #tmpAttribution taa
       JOIN #tmpAttribution tah
         ON taa.BBYellowKey = tah.BBYellowKey
      WHERE taa.AsOfDate = @dtCurDate
        AND taa.PrevPriceDate = tah.AsOfDate
        AND tah.AsOfDate = @dtPrevDate


/*   UPDATE PREVIOUS MARKET VALUE FOR USD    */
     UPDATE taa
        SET taa.PrevMarketValue = COALESCE(taa.PrevPrice, 0) * COALESCE(taa.PrevQuantity, 0)
       FROM #tmpAttribution taa
      WHERE taa.AsOfDate = @dtCurDate 
        AND taa.Currency = 'USD'

/*   UPDATE PREIVIOUS MARKET VALUE FOR EUR and JPY    */
     UPDATE taa
        SET taa.PrevMarketValue = (COALESCE(taa.PrevPrice, 0) / COALESCE(taa.PrevFxRate, 1)) * COALESCE(taa.PrevQuantity, 0)
       FROM #tmpAttribution taa
      WHERE taa.AsOfDate = @dtCurDate
        AND taa.Currency IN ('EUR','JPY')

/*   UPDATE PREIVOUS MARKET VALUE FOR CAD, AUD  */
     UPDATE taa
        SET taa.PrevMarketValue = (COALESCE(taa.PrevPrice, 0) * COALESCE(taa.PrevFxRate, 0)) * COALESCE(taa.PrevQuantity, 0)
       FROM #tmpAttribution taa
      WHERE taa.AsOfDate = @dtCurDate
        AND taa.Currency IN ('AUD', 'CAD')



/*   REMOVE RECORDS THAT DONT MAKE SENSE  
     DELETE taa
       FROM #tmpAttribution taa
      WHERE taa.AsOfDate = @dtCurDate
        AND (COALESCE(taa.Quantity, 0) = 0 AND COALESCE(taa.PrevQuantity, 0) = 0 AND COALESCE(taa.DtdPnlUsd, 0) = 0 AND COALESCE(taa.CurrMarketValue, 0) = 0)
*/


/*   SET HEDGE VALUES XBI US Equity   */
     UPDATE taa
        SET taa.HedgeName = @sHedgeName,
            taa.HedgeMarketValue = COALESCE(taa.PrevMarketValue, 0) * -1
       FROM #tmpAttribution taa
      WHERE taa.AsOfDate = @dtCurDate 


/*   UPDATED P&L CALCULATION - UPDATED TO DIFF BETWEEEN YTD P&Ls  xxxx --> MOST SIMPLE FIRST   
     COULD BE A PARAMETER FOR P&L METHODOLOGY      */

     UPDATE taa
        SET taa.MtmDtdPnl = COALESCE(taa.ItdPnlUsd, 0) - COALESCE(taa.PrevItdPnlUsd, 0)
       FROM #tmpAttribution taa
      WHERE taa.AsOfDate = @dtCurDate 



     UPDATE taa
        SET taa.HedgePerformance = pds.DailyReturn
       FROM #tmpAttribution taa
       JOIN dbo.PerformanceDetails pds
         ON taa.HedgeName = pds.Entity
        AND taa.AsOfDate = pds.AsOfDate 
      WHERE taa.AsOfDate = @dtCurDate 

     UPDATE taa
        SET taa.HedgeDtdPnl = COALESCE(taa.HedgeMarketValue, 0) * COALESCE(taa.HedgePerformance, 0)
       FROM #tmpAttribution taa
      WHERE taa.AsOfDate = @dtCurDate 

    IF @HedgePnl = 1
      BEGIN
        UPDATE taa
           SET taa.HedgedPnlUsd = COALESCE(taa.MtmDtdPnl, 0) + COALESCE(taa.HedgeDtdPnl, 0)
          FROM #tmpAttribution taa
         WHERE taa.AsOfDate = @dtCurDate
      END
    ELSE
      BEGIN
        UPDATE taa
           SET taa.HedgedPnlUsd = COALESCE(taa.MtmDtdPnl, 0)
          FROM #tmpAttribution taa
         WHERE taa.AsOfDate = @dtCurDate
      END


     UPDATE taa
        SET taa.TherapeuticTag  = amx.TagValue
        FROM #tmpAttribution taa
        JOIN (SELECT amf.PositionId, COALESCE(amf.TagValue,'N/A') AS TagValue FROM dbo.AmfPortTagging amf GROUP BY amf.PositionId, amf.TagValue HAVING MAX(amf.AsOfDate) = MAX(amf.AsOfDate)) amx
          ON taa.BBYellowKey = amx.PositionId


     SELECT @dtCurDate = DATEADD(d, 1, @dtCurDate)

    END

/*  CREATE A STRATEGY MAP BASED ON LATEST STRATEGY  */
    INSERT INTO #tmpStrategyMap(
           BBYellowKey,
           Strategy)
    SELECT epd.BBYellowKey,
           CASE WHEN SUM(epd.Quantity) > 0 THEN 'Alpha Long' ELSE 'Alpha Short' END
      FROM dbo.EnfPositionDetails epd
     WHERE epd.AsOfDate BETWEEN @dtBegDate AND @dtEndDate
       AND ROUND(epd.Quantity, 0) != 0
       AND epd.InstrType = 'Equity'
       AND COALESCE(epd.BBYellowKey, '') != ''
       AND epd.BBYellowKey IN (SELECT DISTINCT taa.BBYellowKey FROM #tmpAttribution taa)
     GROUP BY epd.BBYellowKey
     ORDER BY epd.BBYellowKey,
           MAX(epd.StratName )

    INSERT INTO #tmpStrategyMap(
           BBYellowKey,
           Strategy)
    SELECT COALESCE(epd.UnderlyBBYellowKey, ''),
           CASE WHEN SUM(epd.Quantity) > 0 THEN 'Alpha Long' ELSE 'Alpha Short' END
      FROM dbo.EnfPositionDetails epd
     WHERE epd.AsOfDate BETWEEN @dtBegDate AND @dtEndDate
       AND ROUND(epd.Quantity, 0) != 0
       AND epd.InstrType = 'Listed Option'
       AND COALESCE(epd.UnderlyBBYellowKey, '') != ''
       AND COALESCE(epd.UnderlyBBYellowKey, '') IN (SELECT DISTINCT taa.BBYellowKey FROM #tmpAttribution taa)
     GROUP BY COALESCE(epd.UnderlyBBYellowKey, '')
     ORDER BY COALESCE(epd.UnderlyBBYellowKey, ''),
           MAX(epd.StratName)

/*
    UPDATE tsm
       SET tsm.BBYellowKey = 'TALS US Equity' 
      FROM #tmpStrategyMap tsm
     WHERE tsm.BBYellowKey = 'TRML US Equity'
*/

    UPDATE taa
       SET taa.Strategy = tsm.Strategy
      FROM #tmpAttribution taa 
      JOIN #tmpStrategyMap tsm
        ON taa.BBYellowKey = tsm.BBYellowKey

     DELETE taa
       FROM #tmpAttribution taa
      WHERE taa.PrevItdPnlUsd IS NULL 
         OR COALESCE(taa.HedgedPnlUsd, 0) = 0

    SELECT taa.AsOfDate,
           taa.BBYellowKey,
           taa.Strategy,           
           COALESCE(taa.TherapeuticTag, '_REQ?') AS TherapeuticTag,
           COALESCE(taa.Quantity, 0) AS CurrQuantity,
           COALESCE(taa.QuantityChng, 0) AS QuantityChng,
           COALESCE(taa.CurrPrice, 0) AS CurrPrice,
           COALESCE(taa.CurrFxRate, '')  AS CurrFx,
           COALESCE(taa.CurrReturn, 0) AS CurrReturn,
           COALESCE(taa.CurrMarketValue, 0) AS CurrMktValUsd,
           COALESCE(taa.PrevPriceDate, '') AS PriceDate,
           COALESCE(taa.PrevQuantity, 0) AS PrevQuantity,
           COALESCE(taa.PrevPrice, 0) AS PrevPrice,
           COALESCE(taa.PrevFxRate, '') AS PrevFx,
           COALESCE(taa.PrevMarketValue, 0) as PrevMktValUsd,
           COALESCE(taa.MtmDtdPnl, 0) AS MtmDtdPnl,
           taa.HedgeName,
           taa.ItdPnlUsd,
           taa.DtdPnlUsd,
           taa.PrevItdPnlUsd,
           taa.HedgedPnlUsd AS ITDPnl
      FROM #tmpAttribution taa 
     WHERE taa.AsOfDate > @dtBegDate   /* ALWAYS need prior business day for beginning quantities and marketvalues)  */
       AND taa.AsOfDate <= @dtEndDate
    -- AND (COALESCE(taa.Quantity, 0) != 0 AND COALESCE(taa.PrevQuantity, 0) != 0)     
    -- AND taa.BBYellowKey = 'AVTX US Equity'
     ORDER BY taa.AsOfDate,     
           taa.Strategy,
           taa.BBYellowKey,
           COALESCE(taa.TherapeuticTag, '_REQ?')

    --SELECT * FROM #tmpPositions 

GO



/*

SELECT TOP 10 * FROM dbo.AmfPortTagging amf
WHERE amf.PositionId LIKE '%ALPN%'


UPDATE amf
  SET amf.TagValue = 'I&I/Derm'
FROM dbo.AmfPortTagging amf
WHERE amf.TagValue = 'Derm/I&I'



SELECT  CASE WHEN TagValue = '' THEN 'N/A' ELSE TagValue END AS TagValue, COUNT(TagValue) FROM dbo.AmfPortTagging amf GROUP BY TagValue  ORDER BY TagValue


SELECT * FROM dbo.AmfPortTagging amf
WHERE TagValue lIKE '%I&I%'


Derm/I&I
I&I/Derm



SELECT amf.*
*/
