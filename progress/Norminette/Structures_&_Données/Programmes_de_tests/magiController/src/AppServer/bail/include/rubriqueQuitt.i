/*------------------------------------------------------------------------
File        : rubriqueQuitt.i
Purpose     : 
Author(s)   : SPo 20/01/2017
Notes       :
derniere revue: 2018/04/23 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttRubriqueQuitt 
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field iCodeRubrique     as integer   label "cdRub"
    field iNumeroLibelle    as integer   label "nome1"
    field iCodeLibelle      as integer   label "cdLib"
    field cLibelleRubrique  as character label "lbRub"
    field cLibelleCabinet   as character label "lbCab"
    field iCodeFamille      as integer   label "cdFam"
    field iCodeSousFamille  as integer   label "cdSfa"
    field cCodeGenre        as character label "cdGen"
    field lAffiche          as logical   label "cdAff" // affiché ou non
    field cCodeSigne        as character label "cdsig" // code signe : +/-
    field cCodeIRF          as character label "cdIrf"
    field iNumeroLocataire  as int64     label "noloc"
    field iMoisTraitementGI as int64     label "msQtt"
    field lModifiable       as logical
    field lSelection        as logical   initial ?
    field cLibelleGenre     as character initial ?
    field cLibelleSigne     as character initial ?
    field cLibelleRevision  as character initial ?

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
