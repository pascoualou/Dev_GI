/*------------------------------------------------------------------------
File        : paretab.i
Purpose     : Fichier Parametres Etablissement (Transfert vers G.I.)
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttParetab
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cpt-eap    as character  initial ? 
    field cpt-enc    as character  initial ? 
    field dadertrans as date       initial ? 
    field etab-cd    as integer    initial ? 
    field floppy-cle as character  initial ? 
    field reference  as character  initial ? 
    field soc-cd     as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
