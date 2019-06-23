/*------------------------------------------------------------------------
File        : tacheEclatEnc.i
Purpose     : 
Author(s)   : DM 20180129
Notes       :
derniere revue: 2018/05/17 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttTacheEclatEnc
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field iNumeroContrat as int64     initial ? label "nocon"

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
&if defined(nomTableFam)   = 0 &then &scoped-define nomTableFam ttFamilleRubriqueQuitt
&endif
&if defined(serialNameFam) = 0 &then &scoped-define serialNameFam {&nomTableFam}
&endif
define temp-table {&nomTableFam} no-undo serialize-name '{&serialNameFam}'
    field iNumeroContrat  as int64     initial ? label "etab-cd"
    field iOrdre          as integer   initial ? label "ordnum"
    field iCodeFamille    as integer   initial ? label "cdfam"
    field cLibelleFamille as character initial ? 

/*  field dtTimestamp as datetime  pas de champs cdmsy hemsy dans afamqtord */
    field CRUD   as character
    field rRowid as rowid

.
&if defined(nomTableSsFam)   = 0 &then &scoped-define nomTableSsFam ttSousFamilleRubriqueQuitt
&endif
&if defined(serialNameSsFam) = 0 &then &scoped-define serialNameSsFam {&nomTableSsFam}
&endif
define temp-table {&nomTableSsFam} no-undo serialize-name '{&serialNameSsFam}'
    field iNumeroContrat      as int64     initial ? label "etab-cd"
    field iOrdre              as integer   initial ? label "ordnum"
    field iCodeFamille        as integer   initial ? label "cdfam"
    field iCodeSousFamille    as integer   initial ? label "cdsfa"  
    field cLibelleSousFamille as character initial ?

/*  field dtTimestamp as datetime  pas de champs cdmsy hemsy dans afamqtord */
    field CRUD   as character
    field rRowid as rowid
.
