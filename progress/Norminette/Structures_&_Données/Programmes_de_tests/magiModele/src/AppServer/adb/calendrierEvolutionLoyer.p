/*-----------------------------------------------------------------------------
File        : calendrierEvolutionLoyer.p
Purpose     : Librairie contenant les procedures liees a la gestion du calendrier d'evolution des loyers
Author(s)   : JC - 1999/05/07, Kantena - 2017/12/21
Notes       : reprise de adb/src/lib/l_calev.p
derniere revue: 2018/04/26 - phm: OK

01  11/09/2000  PL    Gestion Double affichage Euro/Devise.
02  17/12/2003  PL    Adaptation nouvelle gestion lib.
03  20/03/2006  SY    Gestion RAZ dates de fin et autres (Pb depuis nouvelle gestion Lib.)
04  14/06/2006  SY    suppression use-index ix_calev01
05  25/06/2010  SY    0610/0157 : Pb RAZ date de fin de palier
-----------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

define variable gdaCalendrier     as date      no-undo.
define variable gdaDebutPeriode   as date      no-undo.
define variable gdaFinPeriode     as date      no-undo.
define variable gdeMontantPeriode as decimal   no-undo.
define variable gcLbdiv           as character no-undo.
define variable glMajDateFin      as logical   no-undo initial true.

function assCalev returns logical(pcMode as character, buffer calev for calev):
    /*-------------------------------------------------------------------------
    Purpose : Assignation des champs de la Table CALEV
    Notes   :
    -------------------------------------------------------------------------*/
    calev.mtper = (if gdeMontantPeriode <> ? then gdeMontantPeriode else calev.mtper) no-error.
    if error-status:error then return false.

    assign
        calev.dtcal = (if gdaCalendrier   <> ? then gdaCalendrier else calev.dtcal)
        calev.dtdeb = (if gdaDebutPeriode <> ? then gdaDebutPeriode else calev.dtdeb)
        calev.dtfin = (if glMajDateFin then gdaFinPeriode else calev.dtfin)    /* sinon RAZ date impossible */
        calev.lbdiv = (if gcLbdiv <> ? then gcLbdiv else calev.lbdiv)
    NO-ERROR.
    if error-status:error then return false.

    /* Mise à Jour des Infos Systèmes. */
    if pcMode = 'C' then assign
        calev.dtcsy = today
        calev.hecsy = time
        calev.cdcsy = mToken:cUser
    NO-ERROR.
    else assign
        calev.dtmsy = today
        calev.hemsy = mtime
        calev.cdmsy = mToken:cUser
    NO-ERROR.
    if error-status:error then return false.

    return true.
end function.

procedure newCalev:
    /*-------------------------------------------------------------------------
    Purpose : creation d'un nouvel element dans la table calendrier d'evolution des loyers
    Notes   :
    -------------------------------------------------------------------------*/
    define input  parameter pcTypeContrat      as character no-undo.
    define input  parameter piNumeroContrat    as int64     no-undo.
    define input  parameter piNumeroCalendrier as integer   no-undo.
    define input  parameter piNumeroPeriode    as integer   no-undo.
    define input  parameter pdaCalendrier      as date      no-undo.
    define input  parameter pdaDebutPeriode    as date      no-undo.
    define input  parameter pdaFinPeriode      as date      no-undo.
    define input  parameter pdeMontantPeriode  as decimal   no-undo.
    define input  parameter pcLbdiv            as character no-undo.
    define output parameter plRetour           as logical   no-undo.

    define buffer calev for calev.

    /* Creation nouvel enregistrement de calev. */
    create calev NO-ERROR.
    /* Tester la Creation. */
    if not error-status:error then assign
        gdaCalendrier     = pdaCalendrier
        gdaDebutPeriode   = pdaDebutPeriode
        gdaFinPeriode     = pdaFinPeriode
        gdeMontantPeriode = pdeMontantPeriode
        gcLbdiv           = pcLbdiv
        calev.tpcon       = pcTypeContrat
        calev.nocon       = piNumeroContrat
        calev.nocal       = piNumeroCalendrier
        calev.noper       = piNumeroPeriode
    no-error.
    if not error-status:error
    then plRetour = assCalev('C', buffer calev).
    else plRetour = false.
end procedure.

procedure majCalev:
    /*-------------------------------------------------------------------------
    Purpose : Mise a Jour d'un Enregistrement de calev
    Notes   :
    -------------------------------------------------------------------------*/
    define input  parameter pcTypeContrat      as character no-undo.
    define input  parameter piNumeroContrat    as int64     no-undo.
    define input  parameter piNumeroCalendrier as integer   no-undo.
    define input  parameter piNumeroPeriode    as integer   no-undo.
    define input  parameter pdaCalendrier      as date      no-undo.
    define input  parameter pdaDebutPeriode    as date      no-undo.
    define input  parameter pdaFinPeriode      as date      no-undo.
    define input  parameter pdeMontantPeriode  as decimal   no-undo.
    define input  parameter pcLbdiv            as character no-undo.
    define output parameter plRetour           as logical   no-undo.
    define buffer calev for calev.

    assign
        gdaCalendrier     = pdaCalendrier
        gdaDebutPeriode   = pdaDebutPeriode
        gdaFinPeriode     = pdaFinPeriode
        gdeMontantPeriode = pdeMontantPeriode
        gcLbdiv           = pcLbdiv
    .
    for first calev exclusive-lock
        where calev.tpcon = pcTypeContrat
          and calev.nocon = piNumeroContrat
          and calev.nocal = piNumeroCalendrier
          and calev.noper = piNumeroPeriode:
        /* Assignation des champs de la Table calev. */
        plRetour = assCalev("U", buffer calev).
    end.
end procedure.

procedure supcalev:
    /*-------------------------------------------------------------------------
    Purpose : Supprime un enregistrement de calev
    Notes   :
    -------------------------------------------------------------------------*/
    define input  parameter pcTypeContrat      as character no-undo.
    define input  parameter piNumeroContrat    as int64     no-undo.
    define input  parameter piNumeroCalendrier as integer   no-undo.
    define input  parameter piNumeroPeriode    as integer   no-undo.
    define output parameter plRetour           as logical   no-undo.
    define buffer calev for calev.

    for first calev exclusive-lock
        where calev.tpcon = pcTypeContrat
          and calev.nocon = piNumeroContrat
          and calev.nocal = piNumeroCalendrier
          and calev.noper = piNumeroPeriode:
        delete calev no-error.
        plRetour = (error-status:error = false).
    end.
end procedure.
