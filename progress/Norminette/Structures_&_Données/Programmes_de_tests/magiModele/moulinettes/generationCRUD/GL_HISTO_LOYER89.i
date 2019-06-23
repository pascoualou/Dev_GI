/*------------------------------------------------------------------------
File        : GL_HISTO_LOYER89.i
Purpose     : Historique de l'aide à la saisie du calcul du loyer loi 89
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttGl_histo_loyer89
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field ancienloyer        as decimal    initial ?  decimals 2
    field cdcsy              as character  initial ? 
    field cdmsy              as character  initial ? 
    field cheminement        as character  initial ? 
    field dtcsy              as date       initial ? 
    field dtmsy              as date       initial ? 
    field hecsy              as integer    initial ? 
    field hemsy              as integer    initial ? 
    field loyeractualise     as decimal    initial ?  decimals 2
    field loyerquartier      as decimal    initial ?  decimals 2
    field loyerrevise        as decimal    initial ?  decimals 2
    field loyertravaux       as decimal    initial ?  decimals 2
    field montanttravaux_ttc as decimal    initial ?  decimals 2
    field nodetailfinance    as integer    initial ? 
    field nofiche            as integer    initial ? 
    field nohisto_loyer89    as integer    initial ? 
    field noperio            as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
