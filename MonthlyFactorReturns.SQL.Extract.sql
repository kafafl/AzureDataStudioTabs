USE Operations
GO

   SELECT baf.AsOfDate,
          baf.NumDate,
          baf.FactorName,
          baf.FactorValue 
     FROM dbo.BarraMonthlyFactorReturns baf
    WHERE 1 = 1
     /*                                                */
      AND  baf.NumDate BETWEEN '202401' AND '202412'
      AND baf.FactorName IN (
     /*   FACTORS OF INTEREST  */
         'EFMUSATRD_BETA', 
         'EFMUSATRD_BIOLIFE', 
         'EFMUSATRD_CARBONEFF', 
         'EFMUSATRD_CROWD', 
         'EFMUSATRD_DIVYILD', 
         'EFMUSATRD_EARNQLTY', 
         'EFMUSATRD_EARNVAR', 
         'EFMUSATRD_EARNYILD', 
         'EFMUSATRD_ESG', 
         'EFMUSATRD_GROWTH', 
         'EFMUSATRD_INDMOM', 
         'EFMUSATRD_INVSQLTY', 
         'EFMUSATRD_LEVERAGE', 
         'EFMUSATRD_LIQUIDTY', 
         'EFMUSATRD_LTREVRSL', 
         'EFMUSATRD_MIDCAP', 
         'EFMUSATRD_MLFAC', 
         'EFMUSATRD_MOMENTUM', 
         'EFMUSATRD_PROFIT', 
         'EFMUSATRD_RESVOL', 
         'EFMUSATRD_SEASON', 
         'EFMUSATRD_SENTMT', 
         'EFMUSATRD_SHORTINT', 
         'EFMUSATRD_SIZE', 
         'EFMUSATRD_STREVRSL', 
         'EFMUSATRD_VALUE')
    ORDER BY baf.AsOfDate,
          baf.FactorName
