USE Operations
GO

SELECT mmu.AsOfDate,
       mmu.ParentEntity,
       mmu.BbgTicker,
       mmu.SecName,
       mmu.GICS_industry,
       mmu.Crncy,
       mmu.MarketCap,
       CASE WHEN mmu.MarketCap BETWEEN 0 AND 250000000 THEN 'Under $250 mn'
            WHEN mmu.MarketCap BETWEEN 250000001 AND 500000000 THEN '$250-$500 mn'
            WHEN mmu.MarketCap BETWEEN 500000001 AND 1000000000 THEN '$500mn to $1 bn'
            WHEN mmu.MarketCap BETWEEN 1000000001 AND 5000000000 THEN '$1bn to $5bn'
            ELSE '$5bn+' END AS MrktCapBuckets,
       mmu.Price,
       mmu.TotalReturnYTD,
       1 AS dbRow,
              CASE WHEN mmu.MarketCap BETWEEN 0 AND 250000000 THEN 1
            WHEN mmu.MarketCap BETWEEN 250000001 AND 500000000 THEN 2
            WHEN mmu.MarketCap BETWEEN 500000001 AND 1000000000 THEN 3
            WHEN mmu.MarketCap BETWEEN 1000000001 AND 5000000000 THEN 4
            ELSE 5 END AS MrktCapSort
  FROM dbo.MarketMasterUniverse mmu
 WHERE mmu.AsOfDate = '12/5/2024'
   AND mmu.ParentEntity = 'RGUSHSBT'
 ORDER BY mmu.MarketCap DESC


/*
SELECT * FROM dbo.EnfPositionDetails epd
WHERE epd.AsOfDate = '12/5/2024'
AND epd.Quantity != 0
*/



USE Operations
GO

SELECT mmu.AsOfDate,
       mmu.ParentEntity,
       mmu.BbgTicker,
       mmu.SecName,
       mmu.GICS_industry,
       mmu.Crncy,
       mmu.MarketCap,
       CASE WHEN mmu.MarketCap BETWEEN 0 AND 250000000 THEN 'Under $250mn'
            WHEN mmu.MarketCap BETWEEN 250000001 AND 500000000 THEN '$250-$500mn'
            WHEN mmu.MarketCap BETWEEN 500000001 AND 1000000000 THEN '$500mn to $1bn'
            WHEN mmu.MarketCap BETWEEN 1000000001 AND 5000000000 THEN '$1bn to $5bn'
            ELSE '$5bn+' END AS MrktCapBuckets,
       mmu.Price,
       mmu.TotalReturnYTD,
       1 AS dbRow,
              CASE WHEN mmu.MarketCap BETWEEN 0 AND 250000000 THEN 1
            WHEN mmu.MarketCap BETWEEN 250000001 AND 500000000 THEN 2
            WHEN mmu.MarketCap BETWEEN 500000001 AND 1000000000 THEN 3
            WHEN mmu.MarketCap BETWEEN 1000000001 AND 5000000000 THEN 4
            ELSE 5 END AS MrktCapSort
  FROM dbo.MarketMasterUniverse mmu
 WHERE mmu.AsOfDate = '11/29/2024'
   AND mmu.ParentEntity = 'RGUSHSBT'
 ORDER BY mmu.MarketCap DESC

 SELECT DISTINCT mmu.AsOfDate FROM dbo.MarketMasterUniverse mmu
 WHERE mmu.ParentEntity = 'RGUSHSBT'
  ORDER BY mmu.AsOfDate 