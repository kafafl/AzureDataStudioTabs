USE Operations
GO


DECLARE @AsOfDate AS DATE = '01/31/2024'

-- SCRATCH
SELECT epd.AsOfDate,
       CASE WHEN epd.StratName != '' THEN epd.StratName ELSE 'zGeneral' END,
       CASE WHEN epd.BookName != '' THEN epd.BookName ELSE 'zGeneral' END,
       epd.Account,
       epd.BBYellowKey,
       epd.UnderlyBBYellowKey,
       CASE WHEN epd.BBYellowKey = '' AND epd.UnderlyBBYellowKey != '' THEN epd.UnderlyBBYellowKey
            WHEN epd.BBYellowKey != '' AND epd.UnderlyBBYellowKey = '' THEN SUBSTRING(epd.BBYellowKey, 1, CHARINDEX(' ', epd.BBYellowKey))
            WHEN epd.UnderlyBBYellowKey != epd.BBYellowKey THEN epd.UnderlyBBYellowKey
            WHEN epd.UnderlyBBYellowKey = '' AND epd.BBYellowKey = '' THEN epd.Account
            ELSE epd.UnderlyBBYellowKey
       END AS Modulator,
       epd.YtdPnlUsd,
       epd.ItdPnlUsd
FROM dbo.EnfPositionDetails epd
WHERE epd.AsOfDate = @AsOfDate
ORDER BY 7, 1,2,3,4,6




-- BY Strategy by Book
SELECT epd.AsOfDate,
       CASE WHEN epd.StratName != '' THEN epd.StratName ELSE 'zGeneral' END,
       CASE WHEN epd.BookName != '' THEN epd.BookName ELSE 'zGeneral' END,
       CASE WHEN epd.BBYellowKey = '' AND epd.UnderlyBBYellowKey != '' THEN epd.UnderlyBBYellowKey
            WHEN epd.BBYellowKey != '' AND epd.UnderlyBBYellowKey = '' THEN SUBSTRING(epd.BBYellowKey, 1, CHARINDEX(' ', epd.BBYellowKey))
            WHEN epd.UnderlyBBYellowKey != epd.BBYellowKey THEN epd.UnderlyBBYellowKey
            WHEN epd.UnderlyBBYellowKey = '' AND epd.BBYellowKey = '' THEN 'zzz_' + epd.Account
            ELSE epd.UnderlyBBYellowKey
       END AS Modulator,
       SUM(epd.YtdPnlUsd) AS YtdPnlUsd
  FROM dbo.EnfPositionDetails epd
 WHERE epd.AsOfDate = @AsOfDate
 GROUP BY epd.AsOfDate,
       CASE WHEN epd.StratName != '' THEN epd.StratName ELSE 'zGeneral' END,
       CASE WHEN epd.BookName != '' THEN epd.BookName ELSE 'zGeneral' END,
       CASE WHEN epd.BBYellowKey = '' AND epd.UnderlyBBYellowKey != '' THEN epd.UnderlyBBYellowKey
            WHEN epd.BBYellowKey != '' AND epd.UnderlyBBYellowKey = '' THEN SUBSTRING(epd.BBYellowKey, 1, CHARINDEX(' ', epd.BBYellowKey))
            WHEN epd.UnderlyBBYellowKey != epd.BBYellowKey THEN epd.UnderlyBBYellowKey
            WHEN epd.UnderlyBBYellowKey = '' AND epd.BBYellowKey = '' THEN 'zzz_' + epd.Account
            ELSE epd.UnderlyBBYellowKey
       END
   HAVING SUM(epd.YtdPnlUsd) != 0
 ORDER BY epd.AsOfDate,
       CASE WHEN epd.StratName != '' THEN epd.StratName ELSE 'zGeneral' END,
       CASE WHEN epd.BookName != '' THEN epd.BookName ELSE 'zGeneral' END,
       CASE WHEN epd.BBYellowKey = '' AND epd.UnderlyBBYellowKey != '' THEN epd.UnderlyBBYellowKey
            WHEN epd.BBYellowKey != '' AND epd.UnderlyBBYellowKey = '' THEN SUBSTRING(epd.BBYellowKey, 1, CHARINDEX(' ', epd.BBYellowKey))
            WHEN epd.UnderlyBBYellowKey != epd.BBYellowKey THEN epd.UnderlyBBYellowKey
            WHEN epd.UnderlyBBYellowKey = '' AND epd.BBYellowKey = '' THEN 'zzz_' + epd.Account
            ELSE epd.UnderlyBBYellowKey
       END

       
-- By Strategy
SELECT epd.AsOfDate,
       CASE WHEN epd.StratName != '' THEN epd.StratName ELSE 'zGeneral' END,
       CASE WHEN epd.BBYellowKey = '' AND epd.UnderlyBBYellowKey != '' THEN epd.UnderlyBBYellowKey
            WHEN epd.BBYellowKey != '' AND epd.UnderlyBBYellowKey = '' THEN SUBSTRING(epd.BBYellowKey, 1, CHARINDEX(' ', epd.BBYellowKey))
            WHEN epd.UnderlyBBYellowKey != epd.BBYellowKey THEN epd.UnderlyBBYellowKey
            WHEN epd.UnderlyBBYellowKey = '' AND epd.BBYellowKey = '' THEN 'zzz_' + epd.Account
            ELSE epd.UnderlyBBYellowKey
       END AS Modulator,
       SUM(epd.YtdPnlUsd) AS YtdPnlUsd
  FROM dbo.EnfPositionDetails epd
 WHERE epd.AsOfDate = @AsOfDate
 GROUP BY epd.AsOfDate,
       CASE WHEN epd.StratName != '' THEN epd.StratName ELSE 'zGeneral' END,
       CASE WHEN epd.BBYellowKey = '' AND epd.UnderlyBBYellowKey != '' THEN epd.UnderlyBBYellowKey
            WHEN epd.BBYellowKey != '' AND epd.UnderlyBBYellowKey = '' THEN SUBSTRING(epd.BBYellowKey, 1, CHARINDEX(' ', epd.BBYellowKey))
            WHEN epd.UnderlyBBYellowKey != epd.BBYellowKey THEN epd.UnderlyBBYellowKey
            WHEN epd.UnderlyBBYellowKey = '' AND epd.BBYellowKey = '' THEN 'zzz_' + epd.Account
            ELSE epd.UnderlyBBYellowKey
       END
   HAVING SUM(epd.YtdPnlUsd) != 0
 ORDER BY epd.AsOfDate,
       CASE WHEN epd.StratName != '' THEN epd.StratName ELSE 'zGeneral' END,
       CASE WHEN epd.BBYellowKey = '' AND epd.UnderlyBBYellowKey != '' THEN epd.UnderlyBBYellowKey
            WHEN epd.BBYellowKey != '' AND epd.UnderlyBBYellowKey = '' THEN SUBSTRING(epd.BBYellowKey, 1, CHARINDEX(' ', epd.BBYellowKey))
            WHEN epd.UnderlyBBYellowKey != epd.BBYellowKey THEN epd.UnderlyBBYellowKey
            WHEN epd.UnderlyBBYellowKey = '' AND epd.BBYellowKey = '' THEN 'zzz_' + epd.Account
            ELSE epd.UnderlyBBYellowKey
       END       


-- by Name
SELECT epd.AsOfDate,
       CASE WHEN epd.BBYellowKey = '' AND epd.UnderlyBBYellowKey != '' THEN epd.UnderlyBBYellowKey
            WHEN epd.BBYellowKey != '' AND epd.UnderlyBBYellowKey = '' THEN SUBSTRING(epd.BBYellowKey, 1, CHARINDEX(' ', epd.BBYellowKey))
            WHEN epd.UnderlyBBYellowKey != epd.BBYellowKey THEN epd.UnderlyBBYellowKey
            WHEN epd.UnderlyBBYellowKey = '' AND epd.BBYellowKey = '' THEN 'zzz_' + epd.Account
            ELSE epd.UnderlyBBYellowKey
       END AS Modulator,
       SUM(epd.YtdPnlUsd) AS YtdPnlUsd
  FROM dbo.EnfPositionDetails epd
 WHERE epd.AsOfDate = @AsOfDate
 GROUP BY epd.AsOfDate,
       CASE WHEN epd.BBYellowKey = '' AND epd.UnderlyBBYellowKey != '' THEN epd.UnderlyBBYellowKey
            WHEN epd.BBYellowKey != '' AND epd.UnderlyBBYellowKey = '' THEN SUBSTRING(epd.BBYellowKey, 1, CHARINDEX(' ', epd.BBYellowKey))
            WHEN epd.UnderlyBBYellowKey != epd.BBYellowKey THEN epd.UnderlyBBYellowKey
            WHEN epd.UnderlyBBYellowKey = '' AND epd.BBYellowKey = '' THEN 'zzz_' + epd.Account
            ELSE epd.UnderlyBBYellowKey
       END
   HAVING SUM(epd.YtdPnlUsd) != 0
 ORDER BY epd.AsOfDate,
       CASE WHEN epd.BBYellowKey = '' AND epd.UnderlyBBYellowKey != '' THEN epd.UnderlyBBYellowKey
            WHEN epd.BBYellowKey != '' AND epd.UnderlyBBYellowKey = '' THEN SUBSTRING(epd.BBYellowKey, 1, CHARINDEX(' ', epd.BBYellowKey))
            WHEN epd.UnderlyBBYellowKey != epd.BBYellowKey THEN epd.UnderlyBBYellowKey
            WHEN epd.UnderlyBBYellowKey = '' AND epd.BBYellowKey = '' THEN 'zzz_' + epd.Account
            ELSE epd.UnderlyBBYellowKey
       END   