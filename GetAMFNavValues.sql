USE Operations
GO

ALTER PROCEDURE dbo.p_GetAMFNavValues(
    @EntityName VARCHAR(255) NULL = DEFAULT ,
    @AsOfDate   DATE NULL = DEFAULT )
 
 /*
  Author: Lee Kafafian
  Crated: 11/27/2023
  Object: p_GetAMFNavValues
  Example:  EXEC dbo.p_GetAMFNavValues @AsOfDate = '11/27/2023'
            EXEC dbo.p_GetAMFNavValues @AsOfDate = '11/22/2023', @EntityName = 'AMF NAV'
            EXEC dbo.p_GetAMFNavValues @AsOfDate = '12/11/2023'
 */
  
 AS 

   BEGIN

   SET NOCOUNT ON

    IF @EntityName IS NULL
      BEGIN
        SELECT @EntityName = 'AMF NAV'
      END

    IF @AsOfDate IS NULL
      BEGIN
        SELECT TOP 1 @AsOfDate = CAST(fad.AsOfDate AS DATE) FROM dbo.FundAssetsDetails fad WHERE fad.Entity = @EntityName  ORDER BY fad.AsOfDate DESC, COALESCE(fad.UpdatedOn, fad.CreatedOn) DESC
      END

/*  FUND ASSETS TEMP TABLE   */
    CREATE TABLE #tmpFundAssets(
      AsOfDate        DATE,
      EntityName      VARCHAR(500),
      ConstName       VARCHAR(500),
      NavValue        FLOAT,
      UpdatedOn       DATETIME)


     INSERT INTO #tmpFundAssets(
            AsOfDate,
            EntityName,
            NavValue,
            UpdatedOn)
     SELECT TOP 1 fad.AsOfDate,
            fad.Entity,
            fad.AssetValue,
            COALESCE(fad.UpdatedOn, fad.CreatedOn)
       FROM dbo.FundAssetsDetails fad 
      WHERE fad.AsOfDate <= @AsOfDate 
        AND fad.Entity = @EntityName
      ORDER BY fad.AsOfDate DESC,
            COALESCE(fad.UpdatedOn, fad.CreatedOn) DESC


     SELECT tfa.AsOfDate,
            tfa.EntityName,
            tfa.NavValue,
            tfa.UpdatedOn
       FROM #tmpFundAssets tfa 

   SET NOCOUNT OFF

   END
   GO

   GRANT EXECUTE ON dbo.p_GetAMFNavValues TO PUBLIC
   GO