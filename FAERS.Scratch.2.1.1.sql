USE FAERS
GO


CREATE TABLE dbo.AmfDrugsOfInterest(
    DrugName          VARCHAR(255),
    DoiOwner          VARCHAR(255),
    sUniqueKey        VARCHAR(255)
)

DECLARE @sKey AS VARCHAR(255) = 'jalsdjaf8etuepa489th'

INSERT INTO dbo.AmfDrugsOfInterest(DrugName, DoiOwner, sUniqueKey) SELECT 'LOSARTAN', USER_NAME(), @sKey
INSERT INTO dbo.AmfDrugsOfInterest(DrugName, DoiOwner, sUniqueKey) SELECT 'OZEMPIC', USER_NAME(), @sKey
INSERT INTO dbo.AmfDrugsOfInterest(DrugName, DoiOwner, sUniqueKey) SELECT 'METOPROLOL', USER_NAME(), @sKey
INSERT INTO dbo.AmfDrugsOfInterest(DrugName, DoiOwner, sUniqueKey) SELECT 'JARDIANCE', USER_NAME(), @sKey
INSERT INTO dbo.AmfDrugsOfInterest(DrugName, DoiOwner, sUniqueKey) SELECT 'LYRICA', USER_NAME(), @sKey
GO

SELECT * FROM dbo.AmfDrugsOfInterest
