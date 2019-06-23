/*------------------------------------------------------------------------
File        : iparam.i
Purpose     : Renseigenements concernant le produit installe.
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIparam
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdate                  as date       initial ? 
    field compta                 as logical    initial ? 
    field cserie                 as character  initial ? 
    field cversion               as character  initial ? 
    field dadermaj               as date       initial ? 
    field dafinjour              as date       initial ? 
    field fg-euro                as logical    initial ? 
    field fg-menu                as logical    initial ? 
    field fg-mode-imp            as logical    initial ? 
    field gdate                  as date       initial ? 
    field gescom                 as logical    initial ? 
    field gpao                   as logical    initial ? 
    field gserie                 as character  initial ? 
    field gversion               as character  initial ? 
    field idate                  as date       initial ? 
    field install-facturation    as logical    initial ? 
    field install-immo           as logical    initial ? 
    field install-niveau-relance as logical    initial ? 
    field install-port           as logical    initial ? 
    field install-rappro         as logical    initial ? 
    field install-tva            as logical    initial ? 
    field install-valo           as logical    initial ? 
    field iserie                 as character  initial ? 
    field iversion               as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
