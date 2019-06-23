/*------------------------------------------------------------------------
File        : gl_histo_LOYER_CTRL.i
Purpose     : Historique appel webservice "contrôle du loyer" (actuellement "Yanport").
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttGl_histo_loyer_ctrl
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field adresse            as character  initial ? 
    field anneeconstruction  as character  initial ? 
    field cdcsy              as character  initial ? 
    field cdmsy              as character  initial ? 
    field Coderetour         as character  initial ? 
    field dtcsy              as date       initial ? 
    field dtmsy              as date       initial ? 
    field fgmeuble           as logical    initial ? 
    field hecsy              as integer    initial ? 
    field hemsy              as integer    initial ? 
    field horodatage_calcul  as datetime   initial ? 
    field loyer              as decimal    initial ?  decimals 2
    field loyerfiche_m2      as decimal    initial ?  decimals 2
    field loyermajore        as decimal    initial ?  decimals 2
    field loyermediant       as decimal    initial ?  decimals 2
    field loyerminore        as decimal    initial ?  decimals 2
    field messageretour      as character  initial ? 
    field nbpiece            as integer    initial ? 
    field nofiche            as integer    initial ? 
    field nohisto_loyer_ctrl as integer    initial ? 
    field status_calcul      as character  initial ? 
    field surface            as decimal    initial ?  decimals 2
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
