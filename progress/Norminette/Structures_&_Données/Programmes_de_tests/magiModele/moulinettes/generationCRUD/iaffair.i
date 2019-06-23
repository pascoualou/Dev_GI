/*------------------------------------------------------------------------
File        : iaffair.i
Purpose     : Gestion des affaires
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIaffair
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field affair-num   as decimal    initial ?  decimals 0
    field ana4-cd      as character  initial ? 
    field cde-num      as integer    initial ? 
    field cli-cle      as character  initial ? 
    field consign-cle  as character  initial ? 
    field dadebaff     as date       initial ? 
    field dadermaj     as date       initial ? 
    field dafermaff    as date       initial ? 
    field dafinaff     as date       initial ? 
    field daordre      as date       initial ? 
    field dasoldaff    as date       initial ? 
    field designaffair as character  initial ? 
    field edaff-num    as character  initial ? 
    field etab-cd      as integer    initial ? 
    field fam-cd       as integer    initial ? 
    field harrivee     as integer    initial ? 
    field hdepart      as integer    initial ? 
    field levage-cle   as character  initial ? 
    field levage-cle2  as character  initial ? 
    field libana       as character  initial ? 
    field mt           as decimal    initial ?  decimals 2
    field mt-EURO      as decimal    initial ?  decimals 2
    field period       as character  initial ? 
    field sfam-cd      as integer    initial ? 
    field soc-cd       as integer    initial ? 
    field ssfam-cd     as integer    initial ? 
    field stataff      as character  initial ? 
    field type         as logical    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
