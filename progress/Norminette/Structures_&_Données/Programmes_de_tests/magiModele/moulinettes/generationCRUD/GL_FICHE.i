/*------------------------------------------------------------------------
File        : GL_FICHE.i
Purpose     : Liste des fiches 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttGl_fiche
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcmp           as character  initial ? 
    field cdcsy           as character  initial ? 
    field cdmsy           as character  initial ? 
    field dtcsy           as date       initial ? 
    field dtmsy           as date       initial ? 
    field fgloy_impaye    as logical    initial ? 
    field fgvac_locative  as logical    initial ? 
    field hecsy           as integer    initial ? 
    field hemsy           as integer    initial ? 
    field loy_preco       as decimal    initial ?  decimals 2
    field nbphoto         as integer    initial ? 
    field nbpiece         as integer    initial ? 
    field noapp           as integer    initial ? 
    field nocon           as int64      initial ? 
    field noconloc        as int64      initial ? 
    field nofiche         as integer    initial ? 
    field nomodecreation  as integer    initial ? 
    field noworkflow      as integer    initial ? 
    field nozonealur      as integer    initial ? 
    field surfhab         as decimal    initial ?  decimals 2
    field texte_comm      as character  initial ? 
    field texte_gestion   as character  initial ? 
    field texte_loy_preco as character  initial ? 
    field titre_comm      as character  initial ? 
    field tpcon           as character  initial ? 
    field tpconloc        as character  initial ? 
    field typfiche        as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
