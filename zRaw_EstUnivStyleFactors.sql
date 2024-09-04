
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[zRaw_EstUnivStyleFactors]') AND type in (N'U'))
DROP TABLE [dbo].[zRaw_EstUnivStyleFactors]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[zRaw_EstUnivStyleFactors](
	iRow                            VARCHAR(MAX) NULL,
    [Asset ID                       VARCHAR(MAX) NULL,
    [Asset Name]                    VARCHAR(MAX) NULL,
    Factor01                        VARCHAR(MAX) NULL,
    Factor02                        VARCHAR(MAX) NULL,
    Factor03                        VARCHAR(MAX) NULL,
    Factor04                        VARCHAR(MAX) NULL,
    Factor05                        VARCHAR(MAX) NULL,
    Factor06                        VARCHAR(MAX) NULL,
    Factor07                        VARCHAR(MAX) NULL,
    Factor08                        VARCHAR(MAX) NULL,
    Factor09                        VARCHAR(MAX) NULL,
    Factor10                        VARCHAR(MAX) NULL,
    Factor11                        VARCHAR(MAX) NULL,
    Factor12                        VARCHAR(MAX) NULL,
    Factor13                        VARCHAR(MAX) NULL,
    Factor14                        VARCHAR(MAX) NULL,
    Factor15                        VARCHAR(MAX) NULL,
    Factor16                        VARCHAR(MAX) NULL,
    Factor17                        VARCHAR(MAX) NULL,
    Factor18                        VARCHAR(MAX) NULL,
    Factor19                        VARCHAR(MAX) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

GRANT SELECT, UPDATE, INSERT, DELETE TO PUBLIC
GO


/*


SELECT * FROM dbo.zRaw_EstUnivStyleFactors



*/






