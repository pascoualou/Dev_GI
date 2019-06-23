/*------------------------------------------------------------------------
File        : documentGidemat.i
Purpose     : 
Author(s)   : LGI/  -  2017/01/13 
Notes       :
derniere revue: 2018/05/24 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttDocumentGidemat
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field iIdentifiantGidemat as int64     initial ?
    field cLibellecompte      as character initial ?
    field cDateDocument       as character initial ?
    field cTypeDocument       as character initial ?
    field cNumeroTraitement   as character initial ?
    field cLibelleTraitement  as character initial ?
    field cNumeroMandat       as character initial ?
    field cNumeroCompte       as character initial ?
    field cNumeroImmeuble     as character initial ?
    field cDestinataire       as character initial ?
    field cTypeMime           as character initial ?
    field cExtension          as character initial ?
    field cContenuFichier     as clob      initial ?
index idx1 iIdentifiantGidemat
.
