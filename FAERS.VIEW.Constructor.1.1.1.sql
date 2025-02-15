USE FAERS
GO

/*  DRUG VIEW vw_DRUG        */
CREATE VIEW dbo.vw_DRUG AS 
SELECT * FROM dbo.DRUG23Q4
GO

SELECT TOP 1000 * FROM dbo.vw_DRUG
GO

/*  DEMOGRAPHIC VIEW vw_DEMO  */
CREATE VIEW dbo.vw_DEMO AS 
SELECT * FROM dbo.DEMO23Q4
GO

SELECT TOP 1000 * FROM dbo.vw_DEMO
GO

/*  INDICATION VIEW vw_INDI   */
CREATE VIEW dbo.vw_INDI AS 
SELECT * FROM dbo.INDI23Q4
GO

SELECT TOP 1000 * FROM dbo.vw_INDI
GO

/*  REACTION VIEW vw_REAC   */
CREATE VIEW dbo.vw_REAC AS 
SELECT * FROM dbo.REAC23Q4
GO

SELECT TOP 1000 * FROM dbo.vw_REAC
GO

/*  OUTOCOME VIEW vw_OUTC   */
CREATE VIEW dbo.vw_OUTC AS 
SELECT * FROM dbo.OUTC23Q4
GO

SELECT TOP 1000 * FROM dbo.vw_OUTC
GO


/*  OUTOCOME VIEW vw_RPSR   */
CREATE VIEW dbo.vw_RPSR AS 
SELECT * FROM dbo.RPSR23Q4
GO

SELECT TOP 1000 * FROM dbo.vw_RPSR
GO

/*  OUTOCOME VIEW vw_THER   */
CREATE VIEW dbo.vw_THER AS 
SELECT * FROM dbo.THER23Q4
GO

SELECT TOP 1000 * FROM dbo.vw_THER
GO
