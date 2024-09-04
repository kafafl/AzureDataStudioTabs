USE Operations
GO

SELECT TOP 1000 * FROM dbo.MsgQueue msg ORDER BY msg.MsgInTs DESC


