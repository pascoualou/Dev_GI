/*------------------------------------------------------------------------
File        : listeNumeroContratDispo.i
Purpose     : table de la liste des numeros de contrat disponible (pour un type de contrat)
Author(s)   : GGA - 2017/08/24
Notes       : todo a revoir au moemnt du dev angular sur la creation de contrat 
Derniere revue: 2018/04/10 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttListeNumeroContratDispo 
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field iNumero      as int64     initial ?
    field cPlageNumero as character initial ?
.
