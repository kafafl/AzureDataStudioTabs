USE Operations
GO

DECLARE @AsOfDate AS DATE = '06/25/2024'

EXEC dbo.p_GetAmfBiotechUniverse @AsOfDate = @AsOfDate, @LowQualityFilter = 1

EXEC dbo.p_GetLongPortfolio @AsOfDate = @AsOfDate

EXEC dbo.p_GetShortPortfolio @AsOfDate = @AsOfDate

SELECT SUM(epd.GrExpOfGLNav) 
FROM dbo.EnfPositionDetails epd
WHERE epd.AsOfDate = '04/01/2024'

SELECT * 
FROM dbo.EnfPositionDetails epd
WHERE epd.AsOfDate = '01/01/2024'
AND epd.UnderlyBBYellowKey = '4568 JP Equity'


SELECT * FROM dbo.AdminPositionDetails apd
WHERE apd.AsOfDate = '07/08/2024'


EXEC dbo.p_GetPerformanceDetails @BegDate = '4/1/2024', @EndDate = '7/8/2024', @EntityName = 'AMF', @bAggHolidays = 1
GO

DECLARE @AsOfDate AS DATE = '07/10/2024'

EXEC dbo.p_GetAMFNavValues

SELECT TOp 10000 * FROM [dbo].[BiotechMasterUniverse]

EXEC dbo.p_GetEnfPositionData
EXEC dbo.p_GetProfLossByPosition @AsOfDate = '6/28/2024', @StrtDate = '5/31/2024',  @iTopNCount = 300, @iRst = 5, @iHierarchy = 3, @iOrder = 1
EXEC dbo.p_GetProfLossByPosition @AsOfDate = '6/28/2024', @StrtDate = '5/31/2024',  @iTopNCount = 300, @iRst = 5, @iHierarchy = 3, @iOrder = 1
EXEC dbo.p_GetProfLossByPosition @AsOfDate = '6/28/2024', @StrtDate = '5/31/2024',  @iTopNCount = 300, @iRst = 5, @iHierarchy = 3, @iOrder = 2


        SELECT msg.Iid,
              msg.MsgCatagory,
              RTRIM(LTRIM(REPLACE(SUBSTRING(msg.MsgCatagory, CHARINDEX('-', msg.MsgCatagory), LEN(msg.MsgCatagory)),'-', ''))) AS BasketAlert,
              RTRIM(LTRIM(REPLACE(SUBSTRING(msg.MsgValue, CHARINDEX('Basket:', msg.MsgValue), CHARINDEX('Index', msg.MsgValue) - 1), 'Basket:', ''))) AS BasketName,
              msg.MsgValue,
              msg.MsgPriority,
              msg.MsgInTs
          FROM dbo.MsgQueue msg
         WHERE msg.MsgInTs BETWEEN '07/30/2024' AND '7/31/2024'
          AND RTRIM(LTRIM(REPLACE(SUBSTRING(msg.MsgValue, CHARINDEX('Basket:', msg.MsgValue), CHARINDEX('Index', msg.MsgValue) - 1), 'Basket:', ''))) = 'MSA14568'
          AND CHARINDEX('Basket Monitor', msg.MsgCatagory) != 0



SELECT * FROM dbo.AdminPositionDetails apd
WHERE apd.AsOfDate = '7/29/2024'




