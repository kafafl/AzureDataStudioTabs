USE Operations
GO


/*  GET DATABASE LOGINS  */
    SELECT TOP 18 dbp.name,
           dbp.*
      FROM sys. database_principals dbp
     ORDER BY dbp.create_date 



/*  GET DATABASE LOGINS  */
    SELECT TOP 18 dek.*
      FROM sys. dm_database_encryption_keys dek
     ORDER BY dek.create_date 



