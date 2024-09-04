USE Operations
GO

EXEC dbo.p_GetPerformanceDetails @BegDate = '12/1/2023', @EndDate = '12/1/2023', @EntityName = 'AMF'
GO


SELECT TOP 100 * FROM dbo.PerformanceDetails pdx 
WHERE pdx.AsOfDate = '12/01/2023'
ORDER BY pdx.AsOfDate DESC, COALESCE(pdx.UpdatedOn, pdx.CreatedOn) DESC

SELECT TOP 100 * FROM dbo.FundAssetsDetails fax ORDER BY COALESCE(fax.UpdatedOn, fax.CreatedOn) DESC




SELECT px.AsOfDate, 
       px.TagMnemonic,
       COUNT(*) 
  FROM dbo.PriceHistory px
 WHERE px.AsOfDate BETWEEN '10/1/2023' AND '10/31/2023'
 GROUP BY px.AsOfDate,
       px.TagMnemonic
 ORDER BY px.AsOfDate,
       px.TagMnemonic

       


