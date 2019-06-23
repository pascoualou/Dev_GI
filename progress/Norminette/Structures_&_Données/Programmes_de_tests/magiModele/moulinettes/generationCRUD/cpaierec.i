/*------------------------------------------------------------------------
File        : cpaierec.i
Purpose     : Recapitulative de Paiement
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCpaierec
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field adr          as character  initial ? 
    field bic          as character  initial ? 
    field bqjou-cd     as character  initial ? 
    field bque         as character  initial ? 
    field bque-nom     as character  initial ? 
    field cdficvir     as character  initial ? 
    field chrono       as integer    initial ? 
    field coll-cle     as character  initial ? 
    field cours        as decimal    initial ?  decimals 8
    field cp           as character  initial ? 
    field cpt          as character  initial ? 
    field cpt-cd       as character  initial ? 
    field daech        as date       initial ? 
    field dapaie       as date       initial ? 
    field dernnum      as integer    initial ? 
    field dev-cd       as character  initial ? 
    field email        as character  initial ? 
    field etab-cd      as integer    initial ? 
    field four-cle     as character  initial ? 
    field gest-cle     as character  initial ? 
    field guichet      as character  initial ? 
    field iban         as character  initial ? 
    field lib-vir      as character  initial ? 
    field libpaie-cd   as integer    initial ? 
    field mandat-cd    as integer    initial ? 
    field mt           as decimal    initial ?  decimals 2
    field mt-EURO      as decimal    initial ?  decimals 2
    field nom          as character  initial ? 
    field nom-fich     as character  initial ? 
    field num-int      as integer    initial ? 
    field piece-compta as integer    initial ? 
    field ref-num      as character  initial ? 
    field regl-cd      as integer    initial ? 
    field rib          as character  initial ? 
    field soc-cd       as integer    initial ? 
    field ville        as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
