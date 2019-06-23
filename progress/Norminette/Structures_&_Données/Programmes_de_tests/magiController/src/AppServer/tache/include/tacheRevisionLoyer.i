/*------------------------------------------------------------------------
File        : tacheRevisionLoyer.i
Purpose     : table tache Révision Loyer
Author(s)   : npo - 2017/11/29
Notes       :
derniere revue: 2018/05/24 - phm: OK
  ----------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttTacheRevisionLoyer
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field iChronoTache                    as int64     initial ? label "noita"
    field cTypeContrat                    as character initial ? label "tpcon"
    field iNumeroContrat                  as int64     initial ? label "nocon"
    field cTypeTache                      as character initial ? label "tptac"
    field iNumeroTache                    as integer   initial ? label "notac"
    field daDebutPeriodeRevision          as date                label "dtdeb"
    field daProchaineRevision             as date                label "dtfin"
    field daFinBail                       as date                label "dtfin"
    field iPeriodiciteIndexation          as integer   initial ? label "duree"
    field cCodeUnitePerioIndexation       as character initial ? label "pdreg"
    field cLibelleUnitePerioIndexation    as character initial ?
    field cCodeMotifFin                   as character initial ? label "tpfin"
    field cCodeIndexationAlaBaisse        as character initial ?               /* partie de lbdiv*/
    field cLibelleIndexationAlaBaisse     as character initial ?
    field cPourcentageVariation           as character initial ?               /* partie de lbdiv*/
    field cCodeNombrePeriodeIndiceDeBase  as character initial ? label "ntges"
    field cCodeTypeIndiceDeBase           as character initial ? label "tpges"
    field cCodeAnneeIndiceDeBase          as character initial ? label "pdges"
    field cLibelleIndiceDeBase            as character initial ?
    field cCodeNombrePeriodeIndiceCourant as character initial ? label "ntreg"
    field cCodeTypeIndiceCourant          as character initial ? label "dcreg"
    field cLibelleTypeIndiceCourant       as character initial ?                /* combo: CMBINDICEREVISION */
    field cCodeAnneeIndiceCourant         as character initial ? label "cdreg"
    field cLibelleIndiceCourant           as character initial ?                /* combo: CMBPERIOINDICEREVISION */
    field cLibelleNextIndiceNonParu       as character initial ?
    field daDateReelleTraitementRevision  as date                label "dtreg"
    field dMontantLoyerEncours            as decimal   initial ? label "mtreg"
    field cCodeEtatRevision               as character initial ? label "utreg"      /* 0: revision effectuee, 1: locataire revisable non revise */
    field cCodeFlagIndexationManuelle     as character initial ? label "tphon"      /* no/yes */
    field cCodeFlagIndexationAutomatique  as character initial ? label "tphon"      /* no/yes */
    field cLibelleMotifRevisionManuelle   as character initial ? label "lbmotif"
    field lRevisionConventionnelle        as logical   initial ? label "fgidxconv"
    field cLibelleRevConventionnelle      as character initial ?
    field cCodeModeCalcul                 as character initial ? label "cdhon"      /* 00000: pas de calcul, 00001: calendrier, 00002: echelle mobile */
    field cLibelleModeCalcul              as character initial ?
    field cListeHistoriqueIndices         as character initial ? label "lbdiv"
    field cMoisQuittContratRevise         as character initial ? label "lbdiv2"     /* msqtt ex : 201712 */
    field cCodeAction                     as character initial ?     /*cdact*/
    field cTypeRoleDemandeur              as character initial ?     /*tprol*/
    field iNumeroRoleDemandeur            as int64     initial ?     /*norol*/

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
&if defined(nomTableHistorique)   = 0 &then &scoped-define nomTableHistorique ttHistoriqueRevisionLoyer
&endif
&if defined(serialNameHistorique) = 0 &then &scoped-define serialNameHistorique {&nomTableHistorique}
&endif
define temp-table {&nomTableHistorique} no-undo serialize-name '{&serialNameHistorique}'
    field cTypeContrat                 as character initial ?
    field iNumeroContrat               as int64     initial ?
    field iNumeroTache                 as int64     initial ?   // tache.noita
    field iNumeroTraitementRevision    as integer   initial ?   // inotrtrev
    field iNumeroTraitementRevisiontmp as integer   initial ?   // inotrtrevtmp
    field iNumeroTraitement            as integer   initial ?   // notrt
    field iNumeroTraitementTemp        as integer   initial ?   // notrttmp
    field cCodeTraitement              as character initial ?   // cdtrt
    field daDateReference              as date                  // dtdeb
    field daDateAction                 as date                  // dtfin
    field dMontantAnnuel               as decimal   initial ?   // mtloyann
    field cLibelleLoyer                as character initial ?   // libloyer
    field lLoyerReference              as logical   initial ?   // fgloyref
    field dMontantMensuel              as decimal   initial ?   // mtloymensuel
    field iPeriodeQuittancement        as integer   initial ?   // msqtt
    field iMoisQuittancement           as integer   initial ?
    field iAnneeQuittancement          as integer   initial ?
    field cCodeNatureTraitement        as character initial ?   // cdnat
    field cLibelleNatureTraitement     as character initial ?   // lbnat
    field cLibelletraitement           as character initial ?   // lbtrt
    field motcletraitement             as character initial ?   // motcletrt
    field cCodeAction                  as character initial ?   // cdact
    field cLibelleAction               as character initial ?   // lbact
    field cTypeRoleDemandeur           as character initial ?   // tprol
    field iNumeroRoleDemandeur         as int64     initial ?   // norol
    field lLigneSaisissable            as logical   initial ?   // fgmanuel
    field lActionSuivante              as logical   initial ?
    field iCodeIndiceRevision          as integer   initial ?   // cdirv
    field iAnneeIndice                 as integer   initial ?   // anirv
    field iNumeroPeriodAnnee           as integer   initial ?   // noirv
    field cLibelleTypeIndice           as character initial ?   // lbirv
    field cLibelleIndice               as character initial ?   // lbper
    field dValeurIndice                as decimal   initial ?   // vlirv
    field cValeurIndice                as character initial ?   // affvlirv
    field cTauxRevision                as character initial ?   // afftxrev
    field cLibelleCommentaires         as character initial ?   // lbcom
    field lTraitementHistorise         as logical   initial ?   // fghis
    field daTermineLe                  as date                  // dthis
    field cHistorisePar                as character initial ?   // usrhis
    field cMotifFin                    as character initial ?   // tphis

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
index ix_tt_revtrt02 daDateReference iNumeroTraitementRevisiontmp
index ix_tt_revtrt04 cCodeTraitement iNumeroTraitementTemp cCodeAction
.
&if defined(nomTableAction)   = 0 &then &scoped-define nomTableAction ttActionTraitement
&endif
&if defined(serialNameAction) = 0 &then &scoped-define serialNameAction {&nomTableAction}
&endif
define temp-table {&nomTableAction} no-undo serialize-name '{&serialNameAction}'
    field cCodeTraitement    as character initial ?   // cdpar
    field cLibelleTraitement as character initial ?   // lbpar
.
