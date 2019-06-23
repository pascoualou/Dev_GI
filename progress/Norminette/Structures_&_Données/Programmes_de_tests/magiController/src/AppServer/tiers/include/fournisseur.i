/*------------------------------------------------------------------------
File        : fournisseur.i
Purpose     :
Author(s)   : kantena - 2016/09/12 
Notes       :
derniere revue: 2018/05/24 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttFournisseur 
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cCodeFournisseur    as character initial ?
    field iCodeSociete        as integer   initial ?
    field iCodeRaisonSociale  as integer   initial ?
    field cLibelle            as character initial ?  // nom prenom fournisseur
    field cAdresse            as character initial ? extent 3 
    field cCoordonnees        as character initial ?
    field cDomaineActivite    as character initial ?
    field cCodePostal         as character initial ?
    field cVille              as character initial ?
    field lActif              as logical   initial ?
    field lReference          as logical   initial ?
    field lActradis           as logical   initial ?
    field lBlocageDuplication as logical   initial ?
    field iCodeReglement      as integer   initial ?

    field CRUD        as character
    field dtTimestamp as datetime
    index idxfour is unique primary cCodeFournisseur iCodeSociete.
