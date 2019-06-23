/*------------------------------------------------------------------------
File        : moyenCommunication.i
Purpose     : 
Author(s)   : KANTENA  -  2016/10/27
Notes       :
derniere revue: 2018/05/17 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttMoyenCommunication
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cJointure          as character initial ?
    field cTypeIdentifiant   as character initial ? label 'tpidt'
    field iNumeroIdentifiant as integer   initial ? label 'noidt'
    field iOrdre             as integer   initial ? label 'nopos'
    field cValeur            as character initial ? label 'notel'
    field cCodeType          as character initial ? label 'tptel'
    field cLibelleType       as character initial ?
    field cCodeMoyen         as character initial ? label 'cdtel'
    field cLibelleMoyen      as character initial ?
    field iCodeSociete       as integer   initial ? label 'soc-cd'
    field cCodeFournisseur   as character initial ? label 'four-cle'
    field iTypeAdresse       as integer   initial ? label 'libadr-cd'
    field iNumeroAdresse     as integer   initial ? label 'adr-cd'
    field iNumeroContact     as integer   initial ? label 'numero'

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
index ix_Moyen is primary cJointure iOrdre.
