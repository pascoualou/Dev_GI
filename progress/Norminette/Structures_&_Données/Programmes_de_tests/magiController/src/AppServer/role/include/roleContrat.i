/*------------------------------------------------------------------------
File        : roleContrat.i
Purpose     : 
Author(s)   : KANTENA - 2017/01/25
Notes       : rôle contratImmeuble
derniere revue: 2018/05/24 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttRoleContrat
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field iNumeroContrat   as int64       // nocon
    field cTypeContrat     as character   // tpcon
    field iNumeroRole      as integer
    field cCodeTypeRole    as character
    field cLibelleTypeRole as character
    field lbrech           as character  initial ? // Provient de roleMandat de GED 
    field soc-cd           as integer    initial ? // Provient de roleMandat de GED

    field dtTimestamp      as datetime
    field CRUD             as character
    field rRowid           as rowid
    index primaire cCodeTypeRole iNumeroRole
    index wordIndex is word-index lbrech                    // utilisé par query dynamique dans role.p
.
