/*------------------------------------------------------------------------
File        : chargementPeriodesMandat.p
Purpose     : Interface de chargement des périodes d'un Mandat de Gérance ou de Copropriété.
Author(s)   : SC - 1997/07/08, kantena - 27/07/2016
Notes       : pas utilisé ?
              pcCodeRetour
                  - 000: OK
                  - 001: Tâche 'Compte-Rendu de Gestion' introuvable pour Mandat
                  - 002: Code périodicité du Mandat introuvable
                  - 003: Paramétrage Périodicité Incomplet pour le Mandat
                  - 004: Aucun exercice défini pour le Mandat de Syndic
              pcListePeriodeRetour:
                  - NoPer@DtDeb@DtFin@FgTrt|NoPer@DtDeb@DtFin@FgTrt|... avec FgTrt = 0 pour non traitée et 1 pour période Traitée
                  - DtDeb@DtFin pour le cas d'un Mandat de Gérance.
01  16/07/1997  RT    Ajout Lien Mandat de Copro / Comptabilité.
02  25/07/1997  SC    Ajout d'un NO-LOCK pour le FOR EACH perio.
03  04/09/1997  RT    Ajout PrcAssIn2:  toutes les périodes et PrcAssInf: périodes non traitées/retirage
04  14/10/1997  SY    Gestion du nouveau code traitement '00000' des périodes ('historique'->non accessible)
05  22/04/1998  LG    Calcul de viNumeroJourFin: l'instruction DATE() doit toujours etre sous la forme (Month,Day,Year).
06  22/03/1999  LG    Modif. de la procedure de recherche de l'exo. en cours: si pas trouvé par rapport à la date, on prends le premier non traité.
07  22/04/2002  OF    0402/1115: pour pouvoir remonter a l'exo N-2 alors que la compta est sur l'exo N+1, + possibilite de remonter à l'exercice N-3
08  30/03/2005  AF    0205/0262: Plage mandat 9000
09  20/01/2006  SY    0305/0246: CRG specif MARNEZ
10  29/11/2007  OF    1107/0242 Pb dates pour CRG specif MARNEZ
------------------------------------------------------------------------*/
{preprocesseur/type2contrat.i}
{preprocesseur/type2tache.i}

using parametre.pclie.parametrageEditionCRG.
using parametre.syspg.syspg.
{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

define input  parameter piNumeroMandat       as integer   no-undo.
define input  parameter piDateComptable      as integer   no-undo.  // sous la forme SSAAMM
define input  parameter pcCodeOption         as character no-undo.  // 'T': Toutes les périodes du Mandat, 'N': Toutes les périodes NON TRAITEES du Mandat.
define output parameter pcCodeRetour         as character no-undo initial "000".
define output parameter pcListePeriodeRetour as character no-undo.

function fgSyndic return logical(piMandat as integer):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par ????
    ------------------------------------------------------------------------------*/
    return can-find(first aprof no-lock
                    where aprof.profil-cd = 91
                      and aprof.mandatdeb <= piMandat
                      and aprof.mandatfin >= piMandat).
end function.

run chargementPeriodesPrivate.

procedure chargementPeriodesPrivate private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service. Le traitement est différent suivant qu'il s'agit de Gérance ou de Copropriété.
    ------------------------------------------------------------------------------*/
    define variable viNombreMoisPeriode  as integer   no-undo.
    define variable viPremierMoisPeriode as integer   no-undo.
    define variable viNumeroPeriodeCal   as integer   no-undo.
    define variable viAnneeComptable     as integer   no-undo.
    define variable viMoisComptable      as integer   no-undo.
    define variable viDateMoisComptable  as integer   no-undo.
    define variable viDateDebutPeriode   as integer   no-undo.
    define variable viDateFinPeriode     as integer   no-undo.
    define variable viMoisDebut          as integer   no-undo.
    define variable viAnneeDebut         as integer   no-undo.
    define variable viNumeroJourFin      as integer   no-undo.
    define variable viNumeroMoisFin      as integer   no-undo.
    define variable viNumeroMoisSuivant  as integer   no-undo.
    define variable viAnneeFin           as integer   no-undo.
    define variable vdaMoisComptable     as date      no-undo.
    define variable viNumeroExercice     as integer   no-undo.
    define variable viNumeroExercice-1   as integer   no-undo.
    define variable viNumeroExercice-2   as integer   no-undo.
    define variable viNumeroExercice-3   as integer   no-undo.  /**Ajout OF le 22/04/2002**/
    define variable vdaDebut             as date      no-undo.
    define variable vdaFin               as date      no-undo.
    define variable vlCRGDecale          as logical   no-undo.
    define variable voEditionCRG as class parametrageEditionCRG no-undo.
    define variable voSyspg      as class syspg                 no-undo.

    define buffer tache for tache.

    if not fgSyndic(piNumeroMandat) then do:
        /* Paramètre client pour traitement partiel CRG Trimestre Decalé */
        assign
            voEditionCRG = new parametrageEditionCRG()
            voSyspg      = new syspg()
            vlCRGDecale  = voEditionCRG:isTrimesDecalePartielFinAnnee()
        .
        delete object voEditionCRG.
        /* Rechercher la Périodicité du Mandat dans la Tâche 'Compte Rendu de Gestion'. */
        find last tache no-lock
            where tache.tptac = {&TYPETACHE-compteRenduGestion}
              and tache.tpcon = {&TYPECONTRAT-mandat2Gerance}
              and tache.nocon = piNumeroMandat no-error.
        if not available tache then do:
            pcCodeRetour = "001".    /* Pas de Compte-Rendu de Gestion pour ce Mandat. */
            return.
        end.
        /* Récupération dans sys_pg de la Périodicité. */
        voSyspg:reloadUnique("O_PRD", tache.pdges).
        if not voSyspg:isDbParameter then do:
            delete object voEditionCRG.
            pcCodeRetour = "002".     /* Code périodicité inexistant dans Paramètres */ 
            return.
        end.
        /* Récupération des infos sur la Périodicité. */
        assign
            viNombreMoisPeriode  = integer(voSyspg:zone6)
            viPremierMoisPeriode = integer(voSyspg:zone7)
        .
        delete object voSyspg.
        /* Récupération Nb de Mois et 1er Mois Période. */
        if viNombreMoisPeriode = 0 or viPremierMoisPeriode = 0 then do:
            pcCodeRetour = "003".    /* Paramétrage Périodicité incomplet. */
            return.
        end.
        /* Initialiser les Variables de Bornes pour commencer à rechercher à quelle période correspond le Mois Comptable passé en paramètre. */
        assign
            viAnneeComptable    = truncate(piDateComptable / 100, 0)
            viMoisComptable     = piDateComptable modulo 100
            viNumeroPeriodeCal  = viNombreMoisPeriode - 1
            viDateMoisComptable = viAnneeComptable * 12 + viMoisComptable
            viDateDebutPeriode  = (viAnneeComptable - 1) * 12 + viPremierMoisPeriode 
            viDateFinPeriode    = viDateDebutPeriode + viNumeroPeriodeCal 
        .
        do while viDateMoisComptable < viDateDebutPeriode or viDateMoisComptable > viDateFinPeriode:
            assign
                viDateDebutPeriode = viDateDebutPeriode + viNombreMoisPeriode
                viDateFinPeriode   = viDateDebutPeriode + viNumeroPeriodeCal
            .
        end.
        /* Conversion Nb mois -> Date */
        assign 
            viMoisDebut     = viDateDebutPeriode modulo 12
            viAnneeDebut    = truncate(viDateDebutPeriode / 12, 0)
            viNumeroMoisFin = viDateFinPeriode modulo 12
            viAnneeFin      = truncate(viDateFinPeriode / 12, 0)
        .
        if viMoisDebut = 0 then assign
            viMoisDebut  = 12
            viAnneeDebut = viAnneeDebut - 1
        .
        if viNumeroMoisFin = 0 then assign
            viNumeroMoisFin     = 12
            viAnneeFin          = viAnneeFin - 1        
            viNumeroMoisSuivant = 01
        .
        else viNumeroMoisSuivant = viNumeroMoisFin + 1.
        /* Détermination du Jour de Fin de la période. */
        assign
            viNumeroJourFin = day(date(viNumeroMoisSuivant, 01, viAnneeFin) - 1)
            vdaDebut        = date(viMoisDebut, 01, viAnneeDebut)
            vdaFin          = date(viNumeroMoisFin, viNumeroJourFin, viAnneeFin)
        .
        /** Ajout SY le 20/01/2006 : CRG SPE MARNEZ */
        /* <Trimestriels décalés partiels en fin d'année> */
       if (tache.pdges = "20011" or tache.pdges = "20012") 
       and (viMoisComptable = 11 or viMoisComptable = 12 or viMoisComptable = 01) 
       and vlCRGDecale then do:
            if viMoisComptable = 11 and tache.pdges = "20011"
            then assign
                vdaDebut = date(11, 01, viAnneeComptable)
                vdaFin   = date(12, 31, viAnneeComptable)
            .
            else if viMoisComptable = 12
                 then if tache.pdges = "20011"
                      then assign
                          vdaDebut = date(11, 01, viAnneeComptable)
                          vdaFin   = date(12, 31, viAnneeComptable)
                      .
                      else assign
                          vdaDebut = date(12, 01, viAnneeComptable)
                          vdaFin   = date(12, 31, viAnneeComptable)
                      .
                 else if tache.pdges = "20011"
                      then assign    /* viMoisComptable = 01 */
                          vdaDebut = date(01, 01,viAnneeComptable)
                          vdaFin   = date(01, 31,viAnneeComptable)
                      .
                      else assign
                          vdaDebut = date(01, 01, viAnneeComptable)
                          vdaFin   = date(03, 01, viAnneeComptable) - 1        /* fin février */
                      .
        end.
        assign
            viMoisDebut          = month(vdaDebut)
            viAnneeDebut         = year(vdaDebut)
            viNumeroMoisFin      = month(vdaFin)
            viAnneeFin           = year(vdaFin)
            viNumeroJourFin      = day(vdaFin)
            pcListePeriodeRetour = substitute("01&1&2@&3&4&5",
                                   string(viMoisDebut, "99"), string(viAnneeDebut, "9999"),  
                                   string(viNumeroJourFin, "99"), string(viNumeroMoisFin, "99"), string(viAnneeFin, "9999")) 
        . 
    end.
    else do:    /* Traitement MADAT DE COPROPRIETE */
        /* Retravail mois comptable: SSAAMM => JJ/MM/SSAA */
        assign 
            pcListePeriodeRetour = ""
            viAnneeComptable     = truncate(piDateComptable / 100, 0)
            viMoisComptable      = piDateComptable modulo 100
            vdaMoisComptable     = date(viMoisComptable,1,viAnneeComptable)
        .
        /* Recherche exercice correspondant mois cptable */
        run prcPerEnc(vdaMoisComptable, output viNumeroExercice, output viNumeroExercice-1, output viNumeroExercice-2, output viNumeroExercice-3).
        /* Traitement des périodes */
        if viNumeroExercice <> 0 then case pcCodeOption:
            when "T" then do:     /* Toutes les périodes (exo N-3, N-2, N-1, N */
                /* Mise en forme des infos pour la compta N-3 */
                if viNumeroExercice-3 <> 0 then run prcAssIn2(viNumeroExercice-3).
                /* Mise en forme des infos pour la compta N-2 */
                if viNumeroExercice-2 <> 0 then run prcAssIn2(viNumeroExercice-2).
                /* Mise en forme des infos pour la compta N-1 */
                if viNumeroExercice-1 <> 0 then run prcAssIn2(viNumeroExercice-1).
                /* Mise en forme des infos pour la compta N */
                run prcAssIn2(viNumeroExercice).
            end.
            /* Toutes les périodes non traitées (exo N) */
            when "N" then run prcAssInf(viNumeroExercice).    /* Mise en forme des infos pour la compta */
        end case.
        else pcCodeRetour = "004".
    end.
end procedure.

procedure prcAssInf:
    /*----------------------------------------------------------------------------
    Purpose: Procedure de mise en forme des infos pour la comptabilité
    Notes:   Option "N" : toutes les périodes autres que traitées.
    ----------------------------------------------------------------------------*/
    define input parameter piNumeroExercice as integer  no-undo.
    define buffer perio for perio.

    for each perio no-lock
        where perio.tpctt = {&TYPECONTRAT-mandat2Syndic}
          and perio.nomdt = piNumeroMandat
          and perio.noexo = piNumeroExercice
          and perio.noper > 0
          and (perio.cdtrt = "00001" or perio.cdtrt = "00002")
        by perio.noper:
        pcListePeriodeRetour = substitute("&1&2@&3@&4@&5|", pcListePeriodeRetour, perio.noper, perio.dtdeb, perio.dtfin, perio.cdtrt).
    end.
    pcListePeriodeRetour = trim(pcListePeriodeRetour, "|").
end procedure.

procedure prcAssIn2:
    /*----------------------------------------------------------------------------
    Purpose: Procedure de mise en forme des infos pour la comptabilité
    Notes: Option "T": toutes les périodes
    ----------------------------------------------------------------------------*/
    define input parameter piNumeroExercice as integer  no-undo.
    define buffer perio for perio.

    for each perio no-lock
        where perio.tpctt = {&TYPECONTRAT-mandat2Syndic}
          and perio.nomdt = piNumeroMandat
          and perio.noexo = piNumeroExercice
          and perio.noper > 0
          and perio.cdtrt <> "00000"         /* pas les périodes "antérieures" */
        by perio.noper:
        pcListePeriodeRetour = substitute("&1&2@&3@&4@&5|", pcListePeriodeRetour, perio.noper, perio.dtdeb, perio.dtfin, perio.cdtrt).
    end.
    pcListePeriodeRetour = trim(pcListePeriodeRetour, "|").
end procedure.

procedure prcPerEnc:
    /*----------------------------------------------------------------------------
    Purpose: permet de se positionner sur l'exercice en-cours selon le mois comptable.
    Notes:
    ----------------------------------------------------------------------------*/
    define input  parameter pdaMoisComptable as date no-undo.
    define output parameter piExercice       as integer no-undo.
    define output parameter piExercice-1     as integer no-undo.
    define output parameter piExercice-2     as integer no-undo.
    define output parameter piExercice-3     as integer no-undo.
    define buffer perio for perio.

    /* Recherche de l'exercice donné */
    find first perio no-lock
        where perio.tpctt = {&TYPECONTRAT-mandat2Syndic}
          and perio.nomdt =  piNumeroMandat
          and perio.dtdeb <= pdaMoisComptable
          and perio.dtfin >= pdaMoisComptable
          and perio.noper =  0 no-error.
    if not available perio
    then find last perio no-lock
        where perio.tpctt = {&TYPECONTRAT-mandat2Syndic}
          and perio.nomdt = piNumeroMandat
          and perio.cdtrt = "00001" no-error.
    if available perio then DO:
        piExercice = perio.noexo.
        /* Recherche de l'exercice N-1 */
        for first perio no-lock
            where perio.tpctt = {&TYPECONTRAT-mandat2Syndic}
              and perio.nomdt = piNumeroMandat
              and perio.noper = 0
              and perio.noexo = piExercice - 1:
            piExercice-1 = perio.noexo.
        end.
        /* Recherche de l'exercice N-2 */
        for first perio no-lock
            where perio.tpctt = {&TYPECONTRAT-mandat2Syndic}
              and perio.nomdt = piNumeroMandat
              and perio.noper = 0
              and perio.noexo = piExercice - 2:
            piExercice-2 = perio.noexo.
        end.
        /* Recherche de l'exercice N-3 */
        for first perio no-lock
            where perio.tpctt = {&TYPECONTRAT-mandat2Syndic}
              and perio.nomdt = piNumeroMandat
              and perio.noper = 0
              and perio.noexo = piExercice - 3:
            piExercice-3 = perio.noexo.
        end.
    end.
end procedure.
