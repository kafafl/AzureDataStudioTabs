USE Operations
GO

CREATE TABLE dbo.AmfPortTagging(
  iId                      BIGINT IDENTITY (1, 1) NOT NULL,
  AsOfDate                 DATE,
  EntityTag                VARCHAR(255),
  PositionId               VARCHAR(255),
  PositionName             VARCHAR(255),
  PositionStrategy         VARCHAR(500),
  TagReference             VARCHAR(255),
  TagValue                 VARCHAR(255),
  CreatedBy                VARCHAR(50)    CONSTRAINT DF_AmfPortTagging_CreatedBy DEFAULT(SUSER_NAME()),
  CreatedOn                DATETIME       CONSTRAINT DF_AmfPortTagging_CreatedOn DEFAULT(GETDATE()))
GO


GRANT SELECT, UPDATE, INSERT, DELETE ON dbo.AmfPortTagging TO PUBLIC
GO




/*
DELETE 
FROM dbo.AmfPortTagging


UPDATE apt
   SET apt.TagReference = 'Therapeutic Area'
   FROM dbo.AmfPortTagging apt

*/


SELECT TagValue, COUNT(TagValue) AS TagCount FROM dbo.AmfPortTagging WHERE EntityTag != 'AMF' GROUP BY TagValue ORDER BY COUNT(TagValue) DESC


SELECT TagValue, COUNT(TagValue) AS TagCount FROM dbo.AmfPortTagging WHERE EntityTag = 'AMF' GROUP BY TagValue ORDER BY COUNT(TagValue) DESC



SELECT * FROM dbo.AmfPortTagging WHERE TagValue LIKE 'Cardio%'

/* Needs to be updated from the deprecated tag Cardiology  

SELECT * FROM dbo.AmfPortTagging WHERE TagValue LIKE 'Cardiology'

'CYTK US Equity'

*/



/*
ABOS US Equity -Neuro
ACHV US Equity -Neuropsych
ACRS US Equity -Derm/I&I
AGLE US Equity -Rare disease
ALPN US Equity -Derm/I&I
AVTE US Equity -Respiratory
TRML US Equity -Derm/I&I


ABVX FP Equity


*/

INSERT INTO dbo.AmfPortTagging( AsOfDate, EntityTag, PositionId, PositionName, PositionStrategy, TagReference, TagValue)
SELECT '10/16/2023', 'AMF', 'ABOS US Equity', 'ACUMEN PHARMACEUTICALS INC', 'Alpha Long - Core', 'Therapeutic Area', 'Neuropsych'
GO

INSERT INTO dbo.AmfPortTagging( AsOfDate, EntityTag, PositionId, PositionName, PositionStrategy, TagReference, TagValue)
SELECT '10/16/2023', 'AMF', 'ACHV US Equity', 'ACHIEVE LIFE SCIENCES INC', 'Alpha Long - Core', 'Therapeutic Area', 'Neuropsych'
GO

INSERT INTO dbo.AmfPortTagging( AsOfDate, EntityTag, PositionId, PositionName, PositionStrategy, TagReference, TagValue)
SELECT '10/16/2023', 'AMF', 'ACRS US Equity', 'ACLARIS THERAPEUTICS INC', 'Alpha Long - Core', 'Therapeutic Area', 'I&I/Derm'
GO

INSERT INTO dbo.AmfPortTagging( AsOfDate, EntityTag, PositionId, PositionName, PositionStrategy, TagReference, TagValue)
SELECT '10/16/2023', 'AMF', 'AGLE US Equity', 'AEGLEA BIOTHERAPEUTICS INC', 'Alpha Long - Core', 'Therapeutic Area', 'Rare disease'
GO

INSERT INTO dbo.AmfPortTagging( AsOfDate, EntityTag, PositionId, PositionName, PositionStrategy, TagReference, TagValue)
SELECT '10/16/2023', 'AMF', 'ALPN US Equity', 'ALPINE IMMUNE SCIENCES INC', 'Alpha Long - Core', 'Therapeutic Area', 'I&I/Derm'
GO

INSERT INTO dbo.AmfPortTagging( AsOfDate, EntityTag, PositionId, PositionName, PositionStrategy, TagReference, TagValue)
SELECT '10/16/2023', 'AMF', 'AVTE US Equity', 'AEROVATE THERAPEUTICS INC', 'Alpha Long - Core', 'Therapeutic Area', 'Respiratory disease'
GO

INSERT INTO dbo.AmfPortTagging( AsOfDate, EntityTag, PositionId, PositionName, PositionStrategy, TagReference, TagValue)
SELECT '10/16/2023', 'AMF', 'TRML US Equity', 'TOURMALINE BIO INC', 'Alpha Long - Core', 'Therapeutic Area', 'I&I/Derm'
GO

INSERT INTO dbo.AmfPortTagging( AsOfDate, EntityTag, PositionId, PositionName, PositionStrategy, TagReference, TagValue)
SELECT '10/16/2023', 'AMF', 'ABVX FP Equity', 'Abivax SA', 'Alpha Long - Core', 'Therapeutic Area', 'I&I/Derm'
GO

INSERT INTO dbo.AmfPortTagging( AsOfDate, EntityTag, PositionId, PositionName, PositionStrategy, TagReference, TagValue)
SELECT '10/16/2023', 'AMF', 'ABVX US Equity', 'Abivax SA', 'Alpha Long - Core', 'Therapeutic Area', 'I&I/Derm'
GO

/*
UPDATE amf
  SET amf.TagValue = 'Endocrinology'
  FROM dbo.AmfPortTagging amf
  WHERE amf.TagValue = 'Cardiometabolic'

UPDATE amf
  SET amf.TagValue = 'Ophthalmology'
  FROM dbo.AmfPortTagging amf
  WHERE amf.TagValue = 'Opthalmology'

  */