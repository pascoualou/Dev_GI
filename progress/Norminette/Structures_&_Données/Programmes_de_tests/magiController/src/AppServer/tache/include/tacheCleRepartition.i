/*------------------------------------------------------------------------
File        : tacheCleRepartition.i
Purpose     : 
Author(s)   : DM 20180205
Notes       :
derniere revue: 2018/05/17 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttTacheCleRepartition
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field iNumeroContrat  as int64     initial ? label "nocon"
    field cTypeContrat    as character initial ? label "tpcon"
    field iNumeroImmeuble as integer   initial ?
    field lImmeubleCopro  as logical   initial ?
    field lUniteActive    as logical   initial ?

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
&if defined(nomTableDetailCle)   = 0 &then &scoped-define nomTableDetailCle ttDetailCle
&endif
&if defined(serialNameDetailCle) = 0 &then &scoped-define serialNameDetailCle {&nomTableDetailCle}
&endif
define temp-table {&nomTableDetailCle} no-undo serialize-name '{&serialNameDetailCle}'
    field cTypeContrat   as character label "tpcon"  
    field iNumeroContrat as int64     label "nocon" 
    field cCodeCle       as character label "CdCle" 
    field iNumeroLot     as integer   label "NoLot" 
    field cCodebatiment  as character label "CdBat" 
    field iNumeroBail    as integer   label "NoPro" 
    field cNomLocataire  as character label "LbPro" 
    field dTantieme      as decimal   label "NbPar"

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
