IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[BasketShortUniverse]') AND type in (N'U'))
  EXEC dbo.DropTemporalTable @table = 'BasketShortUniverse'
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE TABLE dbo.BasketShortUniverse(
  [iId] [bigint]                   IDENTITY(1,1) NOT NULL PRIMARY KEY,
  [BbgTicker]                      VARCHAR(255) NOT NULL,	
  [SecName]                        VARCHAR(255) NOT NULL,
  [MarketCap]                      FLOAT NULL,
  [Price]                          FLOAT NULL,
  [PEValue]                        FLOAT NULL,	
  [TotalReturnYTD]                 FLOAT NULL,
  [RevenueT12M]                    FLOAT NULL,	
  [EPST12M]                        FLOAT NULL,
  [SysStartTime]                   DATETIME2 GENERATED ALWAYS AS ROW START NOT NULL,
  [SysEndTime]                     DATETIME2 GENERATED ALWAYS AS ROW END NOT NULL,
    PERIOD FOR SYSTEM_TIME ([SysStartTime], [SysEndTime])) ON [PRIMARY] WITH(SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.BasketShortUniverse_history))
GO


GRANT SELECT, UPDATE, INSERT, DELETE ON dbo.BasketShortUniverse TO PUBLIC
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO




ALTER PROCEDURE dbo.p_UpdateInsertRawBbgValues(
    @strBbgTicker          VARCHAR(255),
    @SecName               VARCHAR(255),
    @MktCap                FLOAT,
    @Price                 FLOAT,
    @PEValue               FLOAT,
    @TotRetYtd             FLOAT,
    @RevenueT12M           FLOAT,
    @EPS                   FLOAT)
 
 
 /*
  Author:   Lee Kafafian
  Crated:   05/16/2024
  Object:   p_UpdateInsertRawBbgValues
  Example:  EXEC dbo.p_UpdateInsertRawBbgValues @strBbgTicker = '02/19/2024', @SecName = 'ABCD US Equity', @MktCap = 1.00, @Price = 1, @TotRetYtd = 1, @RevenueT12M = 1, @EPS = 1
 */
  
 AS 
  BEGIN
    SET NOCOUNT ON

       SELECT @MktCap = CASE WHEN @MktCap = -99999 THEN NULL ELSE @MktCap END
       SELECT @Price = CASE WHEN @Price = -99999 THEN NULL ELSE @Price END
       SELECT @PEValue = CASE WHEN @PEValue = -99999 THEN NULL ELSE @PEValue END       
       SELECT @TotRetYtd = CASE WHEN @TotRetYtd = -99999 THEN NULL ELSE @TotRetYtd END
       SELECT @RevenueT12M = CASE WHEN @RevenueT12M = -99999 THEN NULL ELSE @RevenueT12M END
       SELECT @EPS = CASE WHEN @EPS = -99999 THEN NULL ELSE @EPS END

        INSERT INTO dbo.BasketShortUniverse(
               BbgTicker,
               SecName,
               MarketCap,
               Price,
               PEValue,
               TotalReturnYTD,
               RevenueT12M,
               EPST12M) 
        SELECT @strBbgTicker,
               @SecName,
               @MktCap,
               @Price,
               @PEValue,
               @TotRetYtd,
               @RevenueT12M,
               @EPS

    SET NOCOUNT OFF
  END
GO

GRANT EXECUTE ON dbo.p_UpdateInsertRawBbgValues TO PUBLIC
GO


EXEC dbo.p_UpdateInsertRawBbgValues @strBbgTicker = 'LLY US Equity', @SecName = 'ELI LILLY & CO', @MktCap = 725539494875.657, @Price = 757.700012207031, @PEValue = 72.8600769042969, @TotRetYtd = 30.2066613909197, @RevenueT12M = 35932100608, @EPS = 6.81000012531877





CREATE PROCEDURE dbo.p_ClearBasketShortUniverse
 
 /*
  Author:   Lee Kafafian
  Crated:   05/16/2024
  Object:   p_ClearBasketShortUniverse
  Example:  EXEC dbo.p_ClearBasketShortUniverse 
 */
  
 AS 

  BEGIN

    SET NOCOUNT ON
     
    DELETE bsu
      FROM dbo.BasketShortUniverse bsu

    SET NOCOUNT OFF

  END

GO

GRANT EXECUTE ON dbo.p_ClearBasketShortUniverse TO PUBLIC
GO