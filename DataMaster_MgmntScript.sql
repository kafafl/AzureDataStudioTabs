USE Operations
GO


SELECT dmx.*
  FROM dbo.DateMaster dmx 
 WHERE dmx.AsOfDate = '01/09/2025'

/*  UPDATE IsMktHoliday to 1 FOR JAMES EARL CARTER MEMORIAL

UPDATE dmx
   SET dmx.IsMktHoliday = 1
  FROM dbo.DateMaster dmx 
 WHERE dmx.AsOfDate = '01/09/2025'

*/


