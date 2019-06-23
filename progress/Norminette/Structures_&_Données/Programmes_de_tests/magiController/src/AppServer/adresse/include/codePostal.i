/*------------------------------------------------------------------------
File        : codePostal.i
Purpose     : 
Author(s)   : KANTENA  2017/05/23
Notes       :
derniere revue: 2018/05/22 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCodePostal
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cCodePostal      as character initial ? label 'cdpos'  // Code postal
    field cLibelleVille    as character initial ? label 'lbvil'  // Libelle de la ville
    field cCodeDepartement as character initial ? label 'cddep'  // Code département       
    field cLibelleDivers   as character initial ? label 'lbdiv'  // Libellé divers 
    field cLibelleDivers2  as character initial ? label 'lbdiv2' // Libellé divers 2
    field cLibelleDivers3  as character initial ? label 'lbdiv3' // Libellé divers 3

    field CRUD        as character
    field dtTimestamp as datetime
    field rRowid      as rowid
.
