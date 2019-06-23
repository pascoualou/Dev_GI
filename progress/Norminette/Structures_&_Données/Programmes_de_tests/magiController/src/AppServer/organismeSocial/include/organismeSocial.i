/*------------------------------------------------------------------------
File        : organismeSocial.i
Purpose     : table liste des organismes sociaux
Author(s)   : GGA  -  2017/08/10
Notes       : 
derniere revue: 2018/05/23 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttOrganismeSocial
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'    
    field cCodeCentre        as character initial ? label "ident"
    field cLibelleCentre     as character initial ? label "LbNom" 
    field cAdresseCentre     as character initial ? label "adres"
    field cComplementAdresse as character initial ? label "cpadr"
    field cCodePostal        as character initial ? label "cdpos"
    field cVille             as character initial ? label "lbvil"
    field cLibelleAdresse    as character initial ? label 'libAd'
    field cTelephone         as character initial ? label "Notel"

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
