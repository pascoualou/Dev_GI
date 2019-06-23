/*-----------------------------------------------------------------------------
File        : tacheProtectionJuridique.i
Purpose     : 
Author(s)   : SPo  -  04/19/2018
Notes       : Bail - Tache Protection juridique
derniere revue: 2018/04/24 - phm: OK
-----------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttTacheProtectionJuridique
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field iNumeroTache                as int64     initial ? label "noita"
    field cTypeContrat                as character initial ? label "tpcon"
    field iNumeroContrat              as int64     initial ? label "nocon"
    field cTypeTache                  as character initial ? label "tptac"
    field iChronoTache                as integer   initial ? label "notac"
    field daActivation                as date                label "dtdeb"
    field cNumeroProtectionJuridique  as character initial ? label "cdreg"
    field cTypeBareme                 as character initial ?                // utile pour la liste des barèmes COM ou HAB
    field iNumeroBareme               as integer   initial ? label "duree"
    field dtTimestamp                 as datetime
    field CRUD                        as character
    field rRowid                      as rowid
.
