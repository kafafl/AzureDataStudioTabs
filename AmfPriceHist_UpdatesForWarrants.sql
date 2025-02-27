
/*

DECLARE @AsOfDate AS DATE = '12/16/2024'
DECLARE @SecOtherDetail AS VARCHAR(500) = 'December mid-month est.'


INSERT INTO dbo.AmfPriceHistory(
       PxDate,
       SecNameDescr,
       SecIdEnf,
       AmfPx,
       SecBbgYellowKey,
       SecOtherDetail)  SELECT @AsOfDate, 'GOSSAMER BIO ORD - Warrant', '181955436', 0.5003,'GOSS US Equity',@SecOtherDetail
INSERT INTO dbo.AmfPriceHistory(
       PxDate,
       SecNameDescr,
       SecIdEnf,
       AmfPx,
       SecBbgYellowKey,
       SecOtherDetail)  SELECT @AsOfDate, 'ELEVATION ONCOLOGY ORD - Warrant', '180191199', 0.4399,'ELEV US Equity',@SecOtherDetail
INSERT INTO dbo.AmfPriceHistory(
       PxDate,
       SecNameDescr,
       SecIdEnf,
       AmfPx,
       SecBbgYellowKey,
       SecOtherDetail)  SELECT @AsOfDate, 'MOLECULAR TEMPLATES INC - Warrant', '181668567', 0.2278,'MTEM US Equity',@SecOtherDetail
INSERT INTO dbo.AmfPriceHistory(
       PxDate,
       SecNameDescr,
       SecIdEnf,
       AmfPx,
       SecBbgYellowKey,
       SecOtherDetail)  SELECT @AsOfDate, 'BIOMX ORD - Warrant', '195892592', 0.2550,'PHGE US Equity',@SecOtherDetail
INSERT INTO dbo.AmfPriceHistory(
       PxDate,
       SecNameDescr,
       SecIdEnf,
       AmfPx,
       SecBbgYellowKey,
       SecOtherDetail)  SELECT @AsOfDate, 'PROMIS NEUROSCIENCE TRANCHE A - Warrant', '203894219', 0.2744,'PMN US Equity',@SecOtherDetail
INSERT INTO dbo.AmfPriceHistory(
       PxDate,
       SecNameDescr,
       SecIdEnf,
       AmfPx,
       SecBbgYellowKey,
       SecOtherDetail)  SELECT @AsOfDate, 'PROMIS NEUROSCIENCE TRANCHE B - Warrant', '203894220', 0.4236,'PMN US Equity',@SecOtherDetail
INSERT INTO dbo.AmfPriceHistory(
       PxDate,
       SecNameDescr,
       SecIdEnf,
       AmfPx,
       SecBbgYellowKey,
       SecOtherDetail)  SELECT @AsOfDate, 'PROMIS NEUROSCIENCE TRANCHE C - Warrant', '203894221', 0.5307,'PMN US Equity',@SecOtherDetail


       SELECT TOP 100 * FROM dbo.AmfPriceHistory aph
       WHERE aph.PxDate IN (SELECT TOP 2 apx.PxDate FROM dbo.AmfPriceHistory apx GROUP BY apx.PxDate ORDER BY apx.PxDate DESC)
       ORDER BY aph.PxDate DESC, aph.SecNameDescr






       SELECT TOp 100 * FROM dbo.AmfPrivateSecDetails ORDER BY SysStartTime DESC
       SELECT TOp 100 * FROM dbo.AmfSecurityPriceDetails ORDER BY SysStartTime DESC

       SELECT TOP 10 * FROM dbo.AmfPriceHistory aph ORDER BY aph.SysStartTime DESC
       
       


*/



INSERT INTO dbo.AmfPriceHistory(
       PxDate,
       SecNameDescr,
       SecIdEnf,
       AmfPx,
       SecBbgYellowKey,
       SecOtherDetail) 
   SELECT '12/31/2024', 'GOSSAMER BIO ORD - Warrant', '181955436', 0.528980315068493, 'GOSS US Equity', 'December month-end est.'

	INSERT INTO dbo.AmfPriceHistory(
       PxDate,
       SecNameDescr,
       SecIdEnf,
       AmfPx,
       SecBbgYellowKey,
       SecOtherDetail) 
   SELECT '12/31/2024', 'ELEVATION ONCOLOGY ORD - Warrant', '180191199', 0.384160547945205, 'ELEV US Equity', 'December month-end est.'

	INSERT INTO dbo.AmfPriceHistory(
       PxDate,
       SecNameDescr,
       SecIdEnf,
       AmfPx,
       SecBbgYellowKey,
       SecOtherDetail) 
   SELECT '12/31/2024', 'MOLECULAR TEMPLATES INC - Warrant', '181668567', 0.0281296438356164, 'MTEM US Equity', 'December month-end est.'

	INSERT INTO dbo.AmfPriceHistory(
       PxDate,
       SecNameDescr,
       SecIdEnf,
       AmfPx,
       SecBbgYellowKey,
       SecOtherDetail) 
   SELECT '12/31/2024', 'BIOMX ORD - Warrant', '195892592', 0.282273904109589, 'PHGE US Equtity', 'December month-end est.'

	INSERT INTO dbo.AmfPriceHistory(
       PxDate,
       SecNameDescr,
       SecIdEnf,
       AmfPx,
       SecBbgYellowKey,
       SecOtherDetail) 
   SELECT '12/31/2024', 'PROMIS NEUROSCIENCE TRANCHE A - Warrant', '203894219', 0.451851849315068, 'PMN US Equity', 'December month-end est.'

	INSERT INTO dbo.AmfPriceHistory(
       PxDate,
       SecNameDescr,
       SecIdEnf,
       AmfPx,
       SecBbgYellowKey,
       SecOtherDetail) 
   SELECT '12/31/2024', 'PROMIS NEUROSCIENCE TRANCHE B - Warrant', '203894220', 0.431012876712329, 'PMN US Equity', 'December month-end est.'

	INSERT INTO dbo.AmfPriceHistory(
       PxDate,
       SecNameDescr,
       SecIdEnf,
       AmfPx,
       SecBbgYellowKey,
       SecOtherDetail) 
   SELECT '12/31/2024', 'PROMIS NEUROSCIENCE TRANCHE C - Warrant', '203894221', 0.543603123287671, 'PMN US Equity', 'December month-end est.'

   





