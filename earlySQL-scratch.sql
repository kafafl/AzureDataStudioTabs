USE Operations
GO


EXEC dbo.p_GetBasketDetails @BasketName ='MSA1BIO Index'

EXEC dbo.p_GetSimplePort


SELECT * FROM dbo.MsgQueue msg ORDER BY msg.MsgInTs DESC


/*

SELECT TOP 200 *
  FROM dbo.BasketConstituents

SELECT TOP 100 * 
  FROM dbo.EnfPositionDetails epd
 WHERE epd.AsOfDate = '09/28/2023'

SELECT TOP 200 *
  FROM [dbo].[PerformanceDetails]


SELECT * FROM [dbo].[MsgQueue]


sp_help BasketConstituents


select permission_name, state, pr.name
from sys.database_permissions pe
join sys.database_principals pr on pe.grantee_principal_id = pr.principal_id
where pe.class = 1 
    and pe.major_id = object_id('BasketConstituents')
    and pe.minor_id = 0;


select permission_name, state, pr.name
from sys.database_permissions pe
join sys.database_principals pr on pe.grantee_principal_id = pr.principal_id
where pe.class = 1 
    and pe.major_id = object_id('MsgQueue')
    and pe.minor_id = 0;



GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.MsgQueue TO PUBLIC
GO






SELECT TOP 100 * FROM dbo.MsgQueue ORDER BY MsgInTs DESC




INSERT INTO dbo.MsgQueue(
       MsgValue,
       MsgPriority,
       MsgCatagory,
       bMsgSent,
       MsgInTs)
SELECT 'Basket: MSA1BIO Index has a constituent: IMVT UW Equity with greater than a 50% price move.  97.04%',
      '2',
      'Basket Monitor - Price Move',
      0,
      GETDATE()


      INSERT INTO dbo.MsgQueue(
       MsgValue,
       MsgPriority,
       MsgCatagory,
       bMsgSent,
       MsgInTs)
SELECT 'Basket: MSA14568 Index has a constituent: 4568 JP Equity that is held by Allostery.',
      '1',
      'Basket Monitor - in AMF portfolio',
      0,
      GETDATE()




      Basket: MSA14568 Index has a constituent: 4568 JP Equity that is held by Allostery.


*/


      SELECT TOP 10 * FROM dbo.BasketConstituents