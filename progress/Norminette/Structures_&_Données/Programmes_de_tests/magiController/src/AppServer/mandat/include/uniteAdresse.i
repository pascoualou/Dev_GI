/*------------------------------------------------------------------------
File        : uniteAdresse.i
Purpose     :
Author(s)   : KANTENA - 2016/08/11
Notes       :
Derniere revue: 2018/05/23 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttAdresseUnite 
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field iNumeroContrat      as integer   initial ?
    field itypebranche        as integer   initial ?
    field cTypeIdentifiant    as character initial ?
    field cCodeNumeroBis      as character initial ? label 'cdadr'
    field cLibelleNumeroBis   as character initial ?
    field cCodeTypeAdresse    as character initial ? label 'tpadr'
    field cLibelleTypeAdresse as character initial ?
    field cCodePays           as character initial ?
    field cLibellePays        as character initial ?
    field cNumeroVoie         as character initial ?
    field cComplementVoie     as character initial ?
    field iNumeroAdresse      as integer   initial ?
    field cNatureVoie         as character initial ?
    field cLibelleNatureVoie  as character initial ?
    field cLibelleVoie        as character initial ?
    field cComplementAdresse  as character initial ?
    field cCodePostal         as character initial ?
    field cville              as character initial ?
    field cLibelle            as character initial ?

    field dtTimestampAdres    as datetime  initial ?
    field dtTimestampLadrs    as datetime  initial ?
    field CRUD                as character initial ?
    field rRowid              as rowid 
.
