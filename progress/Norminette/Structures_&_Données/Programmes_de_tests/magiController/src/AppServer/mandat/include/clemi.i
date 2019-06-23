/*------------------------------------------------------------------------
File        : clemi.i
Purpose     : table clé des millièmes
Author(s)   : KANTENA - 2016/08/02
Notes       :
Derniere revue: 2018/04/10 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttClemi 
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cTypeContrat         as character initial ? label "tpcon"
    field iNumeroContrat       as int64     initial ? label "nocon"
    field iNumeroImmeuble      as integer   initial ? label "noimm"
    field cCodeCle             as character initial ? label "cdcle"
    field dTotal               as decimal   initial ? label "nbtot"
    field dEcart               as decimal             label "nbeca"
    field cCodebatiment        as character initial ? label "cdbat"
    field cNatureCle           as character initial ? label "tpcle"
    field cLibelleCle          as character initial ? label "lbcle"
    field iNumeroOrdre         as integer   initial ? label "noord"
    field cCodeEtat            as character initial ? label "cdeta"
    field cCodeDevise          as character initial ? label "cddev" 
    field clbdiv               as character initial ? label "lbdiv"
    field clbdiv2              as character initial ? label "lbdiv2"
    field clbdiv3              as character initial ? label "lbdiv3"
    field iNumeroRepartition   as integer   initial ? label "norep"   
    field daDebutRepartition   as date                label "dtdeb"
    field daFinRepartition     as date                label "dtfin"
    field cCodeArchivage       as character initial ? label "cdarc"
    field iNumeroExercice      as integer             label "noexo"
    field dTantiemeAutreMandat as decimal   initial ?
    field dTantiemeImmeuble    as decimal   initial ?
    field lControle            as logical   initial ?
    field cdcsy                as character initial ? label "cdcsy"
    field cdmsy                as character initial ? label "cdmsy"
    field dtTimestamp          as datetime
    field CRUD                 as character
    field rRowid               as rowid
    .
