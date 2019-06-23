/*------------------------------------------------------------------------
File        : ifdscsai.i
Purpose     : Entete des scenarios de factures diverses
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIfdscsai
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field adrfac-cd   as integer    initial ? 
    field cpt-cd      as character  initial ? 
    field dadeclan    as date       initial ? 
    field daech       as date       initial ? 
    field dev-cd      as character  initial ? 
    field etab-cd     as integer    initial ? 
    field etab-dest   as integer    initial ? 
    field fperiod     as character  initial ? 
    field lib         as character  initial ? 
    field lib-ecr     as character  initial ? 
    field libass-cd   as integer    initial ? 
    field profil-cd   as integer    initial ? 
    field regl-cd     as integer    initial ? 
    field rep-cle     as character  initial ? 
    field scen-cle    as character  initial ? 
    field soc-cd      as integer    initial ? 
    field soc-dest    as integer    initial ? 
    field sscoll-cle  as character  initial ? 
    field txescpt     as integer    initial ? 
    field txremex     as integer    initial ? 
    field typefac-cle as character  initial ? 
    field typenat-cd  as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
