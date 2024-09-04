

CREATE USER [svcFAERS] WITH PASSWORD=N'yCPlnh9tI7/gKqaT+mizmnsjRSp1u+DQ/VALMVSSa1w=', DEFAULT_SCHEMA=[dbo]
GO
sys.sp_addrolemember @rolename = N'db_owner', @membername = N'svcOperations'
GO



SELECT TOP 10000 * 
  FROM dbo.DRUG23Q4 drg
  JOIN dbo.AmfDrugsOfInterest doi
    ON drg.drugname = doi.DrugName 

GO

SELECT TOP 10000 * FROM dbo.INDI23Q4 ind
GO

SELECT TOP 10000 * FROM dbo.OUTC23Q4
GO

SELECT TOP 100000 * FROM dbo.REAC23Q4 WHERE drug_rec_act IS NOT NULL
GO

SELECT TOP 10000 * FROM dbo.RPSR23Q4
GO

SELECT TOP 10000 * FROM dbo.THER23Q4 ORDER BY end_dt DESC
GO


--DELETE doi FROM dbo.AmfDrugsOfInterest doi 


SELECT doi.* FROM dbo.AmfDrugsOfInterest doi 

SELECT * FROM dbo.AmfDrugsOfInterest doi WHERE doi.DrugName IN ('LOSARTAN', 'METOPROLOL','JARDIANCE', 'LYRICA')



--DELETE doi FROM dbo.AmfDrugsOfInterest doi WHERE doi.DrugName IN ('LOSARTAN', 'METOPROLOL','JARDIANCE', 'LYRICA')

INSERT INTO dbo.AmfDrugsOfInterest(DrugName, DoiOwner, sUniqueKey) SELECT 'Wegovy', SUSER_NAME(), 'jalsdjaf8etuepa489th'
INSERT INTO dbo.AmfDrugsOfInterest(DrugName, DoiOwner, sUniqueKey) SELECT 'Zepbound', SUSER_NAME(), 'jalsdjaf8etuepa489th'
INSERT INTO dbo.AmfDrugsOfInterest(DrugName, DoiOwner, sUniqueKey) SELECT 'Mounjaro', SUSER_NAME(), 'jalsdjaf8etuepa489th'
INSERT INTO dbo.AmfDrugsOfInterest(DrugName, DoiOwner, sUniqueKey) SELECT 'Winrevair', SUSER_NAME(), 'jalsdjaf8etuepa489th'
INSERT INTO dbo.AmfDrugsOfInterest(DrugName, DoiOwner, sUniqueKey) SELECT 'Jeuveau', SUSER_NAME(), 'jalsdjaf8etuepa489th'
INSERT INTO dbo.AmfDrugsOfInterest(DrugName, DoiOwner, sUniqueKey) SELECT 'Fintepla', SUSER_NAME(), 'jalsdjaf8etuepa489th'
INSERT INTO dbo.AmfDrugsOfInterest(DrugName, DoiOwner, sUniqueKey) SELECT 'Syfovre', SUSER_NAME(), 'jalsdjaf8etuepa489th'
INSERT INTO dbo.AmfDrugsOfInterest(DrugName, DoiOwner, sUniqueKey) SELECT 'EPIDIOLEX', SUSER_NAME(), 'jalsdjaf8etuepa489th'





UPDATE doi
   SET doi.DrugName = UPPER(doi.DrugName)
  FROM dbo.AmfDrugsOfInterest doi 


sp_help AmfDrugsOfInterest






SELECT DISTINCT drg.drugname FROM dbo.DRUG23Q4 drg ORDER BY drg.drugname


DECLARE @AsOfDrug AS VARCHAR(255) = 'OZEMPIC'

SELECT TOP 100 drg.*
FROM dbo.DRUG23Q4 drg
 WHERE CHARINDEX(@AsOfDrug, drg.drugname) != 0

DECLARE @PrimId AS BIGINT = 2041091720

SELECT TOP 100 drg.*
FROM dbo.DRUG23Q4 drg
 WHERE drg.primaryid = @PrimId

SELECT TOP 100 drg.*
FROM dbo.INDI23Q4 drg
 WHERE drg.primaryid = @PrimId

 SELECT TOP 100 drg.*
FROM dbo.THER23Q4 drg
 WHERE drg.primaryid = @PrimId


SELECT TOP 100 drg.*, thr.*, rct.*
FROM dbo.DRUG23Q4 drg
JOIN dbo.THER23Q4 thr
  ON drg.primaryid = thr.primaryid
 AND drg.caseid = thr.caseid 
 JOIN dbo.REAC23Q4 rct
   ON drg.primaryid = rct.primaryid
 AND drg.caseid = rct.caseid  
 WHERE drg.primaryid = @PrimId




DECLARE @PrimId AS BIGINT = 2041091720

SELECT * 
  FROM dbo.DRUG23Q4 drg 
  JOIN dbo.INDI23Q4 ind
    ON drg.primaryid = ind.primaryid
   AND drg.caseid = ind.caseid
   AND drg.drug_seq = ind.indi_drug_seq
  JOIN dbo.THER23Q4 thr
    ON drg.primaryid = thr.primaryid
   AND drg.caseid = thr.caseid
   AND drg.drug_seq = thr.dsg_drug_seq
  FULL OUTER JOIN dbo.REAC23Q4 rct
    ON drg.primaryid = rct.primaryid
  FULL OUTER JOIN dbo.OUTC23Q4 otc
    ON drg.primaryid = otc.primaryid
  FULL OUTER JOIN dbo.RPSR23Q4 rpt
    ON drg.primaryid = rpt.primaryid
 WHERE drg.primaryid = @PrimId




SELECT * FROM dbo.REAC23Q4 rct WHERE rct.primaryid = @PrimId
GO

DECLARE @PrimId AS BIGINT = 2041091720

SELECT TOP 1000
       *
  FROM dbo.DRUG23Q4 drg
  JOIN dbo.DEMO23Q4 dmo
    ON drg.primaryid = dmo.primaryid
  JOIN dbo.THER23Q4 thr
    ON drg.primaryid = thr.primaryid
   AND drg.drug_seq = thr.dsg_drug_seq
  JOIN dbo.INDI23Q4 ind
    ON drg.primaryid = ind.primaryid
   AND drg.drug_seq = ind.indi_drug_seq
  JOIN dbo.REAC23Q4 rct
    ON drg.primaryid = rct.primaryid

 WHERE drg.primaryid = @PrimId  







/*


JOIN dbo.THER23Q4 thr
  ON drg.primaryid = thr.primaryid
  and drg.caseid = thr.caseid
  and drg.drug_seq = thr.dsg_drug_seq


*/




DECLARE @PrimId AS BIGINT = 2041091720
SELECT TOP 100 * FROM dbo.vw_DEMO dmo WHERE dmo.primaryid = @PrimId
SELECT TOP 100 * FROM dbo.vw_DRUG drg WHERE drg.primaryid = @PrimId
SELECT TOP 100 * FROM dbo.vw_REAC rea WHERE rea.primaryid = @PrimId
SELECT TOP 100 * FROM dbo.vw_OUTC otc WHERE otc.primaryid = @PrimId
SELECT TOP 100 * FROM dbo.vw_RPSR rpt WHERE rpt.primaryid = @PrimId
SELECT TOP 100 * FROM dbo.vw_THER thr WHERE thr.primaryid = @PrimId
SELECT TOP 100 * FROM dbo.vw_INDI ind WHERE ind.primaryid = @PrimId




DECLARE @DrgSearch AS VARCHAR(255) = '*'
SELECT DISTINCT drg.drugname 
  FROM dbo.vw_DRUG drg
 WHERE CHARINDEX(@DrgSearch, drg.drugname) != 0 AND drg.role_cod IN ('PS','SS')
 ORDER BY drg.drugname


SELECT drg.drugname,
       COUNT(*) AS ReportedCases
  FROM dbo.vw_DRUG drg
  JOIN dbo.AmfDrugsOfInterest doi
    ON drg.drugname = doi.DrugName 
   AND drg.role_cod IN ('PS','SS')
 GROUP BY drg.drugname
 ORDER BY drg.drugname



DECLARE @DrgSelected AS VARCHAR(255) = 'LOSARTAN'
SELECT dmo.primaryid,
       dmo.caseid,
       dmo.rept_dt,
       dmo.caseversion,
       dmo.rept_cod,
       dmo.mfr_sndr,
       dmo.age,
       dmo.age_cod,
       dmo.sex,
       dmo.wt,
       dmo.wt_cod,
       dmo.occp_cod,
       dmo.reporter_country,
       dmo.occr_country       
  FROM dbo.vw_DEMO dmo
 WHERE dmo.primaryid IN (SELECT DISTINCT drg.primaryid 
                           FROM dbo.vw_DRUG drg
                          WHERE drg.drugname = @DrgSelected
                            AND drg.role_cod IN ('PS','SS'))
 ORDER BY dmo.rept_dt DESC


SELECT dmo.primaryid,
       dmo.caseid,
       dmo.rept_dt,
       dmo.caseversion,
       dmo.rept_cod,
       dmo.mfr_sndr,
       dmo.age,
       dmo.age_cod,
       dmo.sex,
       dmo.wt,
       dmo.wt_cod,
       dmo.occp_cod,
       dmo.reporter_country,
       dmo.occr_country       
  FROM dbo.vw_DEMO dmo
 WHERE dmo.primaryid IN (SELECT DISTINCT drg.primaryid 
                           FROM dbo.vw_DRUG drg
                           JOIN dbo.AmfDrugsOfInterest doi
                             ON drg.drugname = doi.DrugName 
                            AND drg.role_cod IN ('PS','SS'))
 ORDER BY dmo.rept_dt DESC




DECLARE @DrgSelected AS VARCHAR(255) = 'LOSARTAN'
SELECT COUNT(dmo.primaryid) AS TotalCases,
       SUM(CASE WHEN COALESCE(dmo.sex, '') = 'M' THEN 1 END) AS #M,
       SUM(CASE WHEN COALESCE(dmo.sex, '') = 'F' THEN 1 END) AS #F,
       SUM(CASE WHEN COALESCE(dmo.sex, '') = '' THEN 1 END) AS #Unkn     
  FROM dbo.vw_DEMO dmo
 WHERE dmo.primaryid IN (SELECT DISTINCT drg.primaryid 
                           FROM dbo.vw_DRUG drg
                          WHERE drg.drugname = @DrgSelected
                            AND drg.role_cod IN ('PS','SS'))



SELECT COUNT(dmo.primaryid) AS TotalCases,
       SUM(CASE WHEN COALESCE(dmo.sex, '') = 'M' THEN 1 END) AS #M,
       SUM(CASE WHEN COALESCE(dmo.sex, '') = 'F' THEN 1 END) AS #F,
       SUM(CASE WHEN COALESCE(dmo.sex, '') = '' THEN 1 END) AS #Unkn     
  FROM dbo.vw_DEMO dmo
 WHERE dmo.primaryid IN (SELECT DISTINCT drg.primaryid 
                           FROM dbo.vw_DRUG drg
                           JOIN dbo.AmfDrugsOfInterest doi
                             ON drg.drugname = doi.DrugName 
                            AND drg.role_cod IN ('PS','SS'))



DECLARE @DrgSelected AS VARCHAR(255) = 'LOSARTAN'
SELECT dmo.primaryid,
       CASE WHEN dmo.age IS NULL THEN 'Unkn' ELSE dmo.age END AS Age,
       dmo.age_cod AS AgeCode
  FROM dbo.vw_DEMO dmo
 WHERE dmo.primaryid IN (SELECT DISTINCT drg.primaryid 
                           FROM dbo.vw_DRUG drg
                          WHERE drg.drugname = @DrgSelected
                            AND drg.role_cod IN ('PS','SS'))
 ORDER BY dmo.rept_dt DESC


SELECT dmo.primaryid,
       dmo.rept_dt,
       dmo.mfr_sndr,
       CASE WHEN dmo.age IS NULL THEN 'Unkn' ELSE dmo.age END AS Age,
       dmo.age_cod AS AgeCode
  FROM dbo.vw_DEMO dmo
 WHERE dmo.primaryid IN (SELECT DISTINCT drg.primaryid 
                           FROM dbo.vw_DRUG drg
                           JOIN dbo.AmfDrugsOfInterest doi
                             ON drg.drugname = doi.DrugName 
                            AND drg.role_cod IN ('PS','SS'))
 ORDER BY dmo.mfr_sndr





 SELECT drg.drugname, COUNT(drg.primaryid) AS xCount FROM dbo.vw_DRUG drg WHERE CHARINDEX('LYR', drg.drugname) != 0 GROUP BY drg.drugname ORDER BY drg.drugname

 SELECT * FROM dbo.DRUG23Q4 drg WHERE CHARINDEX('LYR', drg.drugname) != 0 ORDER BY drg.drugname


 SELECT * FROM dbo.DRUG23Q4 drg WHERE CHARINDEX('LYR', drg.prod_ai) != 0 ORDER BY drg.drugname


INSERT INTO dbo.AmfDrugsOfInterest(DrugName, DoiOwner, sUniqueKey) SELECT 'Syfovre', SUSER_NAME(), 'jalsdjaf8etuepa489th'
INSERT INTO dbo.AmfDrugsOfInterest(DrugName, DoiOwner, sUniqueKey) SELECT 'EPIDIOLEX', SUSER_NAME(), 'jalsdjaf8etuepa489th'
INSERT INTO dbo.AmfDrugsOfInterest(DrugName, DoiOwner, sUniqueKey) SELECT 'UPLINZA', SUSER_NAME(), 'jalsdjaf8etuepa489th'

SELECT * FROM dbo.AmfDrugsOfInterest doi ORDER BY doi.DrugName



UPDATE doi
   SET doi.DrugName = UPPER(doi.DrugName)
  FROM dbo.AmfDrugsOfInterest doi 