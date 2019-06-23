/*------------------------------------------------------------------------
File        : listeCompte.i
Description :
Author(s)   : LGI/  -  2017/01/13
Notes       :
derniere revue: 2018/05/23 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttListeCompte
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field iNumeroSociete as integer
    field cRegroupement  as character
    field iTypeCompte    as integer
    field cCompte        as character
    field cLibelleCompte as character
index idxPrimaire is unique primary iNumeroSociete cRegroupement cCompte
.
