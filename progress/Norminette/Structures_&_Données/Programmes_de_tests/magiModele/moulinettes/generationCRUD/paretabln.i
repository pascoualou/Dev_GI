/*------------------------------------------------------------------------
File        : paretabln.i
Purpose     : Fichier Parametres (Compteur / Mois)
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttParetabln
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field annee   as integer    initial ? 
    field enreg   as integer    initial ? 
    field etab-cd as integer    initial ? 
    field mois    as integer    initial ? 
    field order   as integer    initial ? 
    field soc-cd  as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
