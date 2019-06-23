/*------------------------------------------------------------------------
File        : role.i
Purpose     : 
Author(s)   : KANTENA - 2017/01/25
Notes       :
derniere revue: 2018/05/24 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttRole
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field iNumeroFiche       as integer   initial ?
    field iNumeroIdentifiant as int64     initial ? label 'noita'
    field iNumeroRole        as int64     initial ? label 'norol'
    field cCodeTypeRole      as character initial ? label 'tprol'
    field cLibelleTypeRole   as character initial ?
    field cCodeTypeRoleFiche as character initial ? label 'tprol Fiche'
    field iNumeroTiers       as int64     initial ? label 'notie'
    field cLibelleRecherche  as character initial ? label 'lbrech'
    field cCodeExterne       as character initial ? label 'cdext'
    field cInfoCommercial    as character initial ? label 'lbdiv'
    field iNumeroOrdre       as integer   initial ?

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
