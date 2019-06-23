/*-----------------------------------------------------------------------------
File        : tacheVacanceLocative.i
Purpose     : 
Author(s)   : npo  -  2018/03/19
Notes       : Bail - Tache Vacance Locative
derniere revue: 2018/05/24 - phm: OK
-----------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttTacheVacanceLocative
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
    field iNumeroVacanceLocative      as integer   initial ? label "cdreg"
    field iNumeroBaremeVacance        as integer   initial ? label "duree"
    field cTypeBaremeVacance          as character initial ?                    // utile pour relier les 2 tables 
    field daApplication               as date                label "dtreg"
    field iMoisQuittTraitementVacance as integer   initial ? label "mtreg" serialize-hidden
    field iMois1erTransfertVacance    as integer   initial ? label "utreg" serialize-hidden
    field lApplicationCalculVisible   as logical   initial ?                    // pour IHM parametre calcul a partir de la date d'application
    field lApplicationCalculActive    as logical   initial ?                    // pour IHM parametre calcul a partir de la date d'application
    field lBailResilie                as logical   initial ?                    // pour IHM pour boutons modif + suppr
    field dtTimestamp                 as datetime
    field CRUD                        as character
    field rRowid                      as rowid
.
define temp-table ttBaremeVacanceLocative no-undo
    field cTypeContrat       as character initial ? label "tpctt" serialize-hidden
    field iNumeroContrat     as integer   initial ? label "noctt" serialize-hidden
    field cTypeBareme        as character initial ? label "tpbar" serialize-hidden
    field iNumeroBareme      as integer   initial ? label "nobar"
    field dMontantCotisation as decimal   initial ? label "mtcot"
    field dTauxCotisation    as decimal   initial ? label "txcot"
    field dTauxHonoraire     as decimal   initial ? label "txhon"
    field dTauxResultant     as decimal   initial ? label "txres"
    // que 'VISU' pas de create ni update ni delete    
.
