/*------------------------------------------------------------------------
File        : chntcon3.i
Purpose     : Changement de nature de contrat - Contrôle avant comptabilisation
Author(s)   : GGA - 17/09/21
Notes       : reprise cadb/gestion/chntcon3.p
******************* FORMATAGE DE LA CHAINE cDiv-IN **********************
appel à partir de changement de la nature  de contrat : pcCodeTraitement = ""      + ""             + ""
appel à partir de la resiliation avec OD de solde     : pcCodeTraitement = "RESOD" + pdaResiliation + pdaOdFinMandat
**************************************************************************
//gga todo dans pgm issu de l'appli si pcCodeTraitement <> "RESOD" on ne recupere pas les 2 dates et pourtant on trouve un test sur daResiliation si pcCodeTraitement <> "RESOD"

    piErrOut = 0.  Pas d'erreur
               2.  Société compta absente
               3.  Mandat de garantie locative inexistant
               4.  Prelevements locataires en attente de traitement
               5.  Acomptes propriétaires en attente de traitement
               6.  ERREUR de paramètres passés à la procédure
               7.  Il reste des factures locataires sur le mandat
               8.  Il reste des factures diverses non-éditées
               9.  Il reste des honoraires de copropriété non facturés
              10.  Il reste des paiements en cours
              11.  une OD - ODFM existe deja
              12.  il reste au moins une ligne extra comptable
              13.  paramétrage inexistant
              14.  compte de solde copro inexistant ou paramétrage incorrect
              15.  La date de l’OD doit être sur le mois du gestionnaire comptable en cours
              16.  Compte 4900 96000 ou 4900 96500 inexistant
              17.  il existe des lignes comptables postérieures à la date de résiliation
              18.  Reglements proprietaires en attente de traitement
              19.  Remboursements coproprietaires en attente de traitement
              20.  Garanties speciales en attente de traitement
              21.  Paiements divers en attente de traitement
              26.  Une ODFE existe sur l'exercice, resiliation par ODFM impossible
              /* >= 50 : NON BLOQUANT */
              50.  Mandat de garantie locative n'a pas de banque globale (Non bloquant)

01  21/03/2002  PS    1201/1717: adaptation du controle à la resiliation avec od (code "RESOD") + ajout du controle sur facture locataire
02  10/04/2002  PS    0402/0982: ajout du controle de la présence des comptes 4900 96000 et 4900 96500
03  21/10/2002  PS    1002/0207: ajout du controle sur les ecritures posterieures a la resiliation
04  01/08/2003  OF    0703/0431: Ajout erreurs 18 à 21
05  24/11/2004  DM    0804/0095: Gestion erreur pour acompte tva
06  14/12/2005  JR    1205/0233: 4900 --> 4790
07  12/03/2007  DM    1106/0114: Pas d'ODFM si ODFE sur l'exercice
08  19/09/2008  DM    0608/0065: Mandat 5 chiffres
09  22/12/2010  SY    1106/0114: l'erreur 51 est NON BLOQUANTE. Pas d'ODFM si ODFE sur l'exercice est bloquant => erreur 51 remplacée par 26 (c.f. adb/src/lib/CtrConvm.p)
10  06/05/2011  PL    0411/0155: Pb raz tmp-cron
11  11/02/2014  OF    0214/0065: ne plus bloquer si ODRT extra-cpta
12  07/10/2014  SY    0714/0255: ajout utilisation cbap.fgval pour future conservation des cbap
13  20/10/2014  OF    1015/0081: Ne pas bloquer s'il y a des cbap obsolètes
-----------------------------------------------------------------------------*/

procedure chntcon3Controle:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe (ctrconvm.p)
    ------------------------------------------------------------------------------*/
    define input parameter  piCodeSociete       as integer   no-undo.
    define input parameter  piCodeEtablissement as integer   no-undo.
    define input parameter  pcCodeTraitement    as character no-undo.
    define input parameter  pdaResiliation      as date      no-undo.
    define input parameter  pdaOdFinMandat      as date      no-undo.
    define output parameter piErrOut            as integer   no-undo.

    define variable vcDebutCompte as character no-undo.
    define buffer ietab    for ietab.
    define buffer cbap     for cbap.
    define buffer ifdparam for ifdparam.
    define buffer agest    for agest.
    define buffer aparm    for aparm.
    define buffer ccpt     for ccpt.
    define buffer cecrsai  for cecrsai.

    if pcCodeTraitement = "RESOD" and (pdaResiliation = ? or pdaOdFinMandat = ?)
    then do:
        piErrOut = 6.
        mError:createErrorGestion({&error}, 000381, "chntcon3.p"). /* Erreur de paramètres passés au programme %1 */
        return.
    end.
    if not can-find(first isoc no-lock where isoc.soc-cd = piCodeSociete)
    then do:
        piErrOut = 2.
        mError:createError({&error}, 105729). /* Societe comptable inexistante */
        return.
    end.
    find first ietab no-lock
         where ietab.soc-cd  = piCodeSociete
           and ietab.etab-cd = piCodeEtablissement no-error.
    if not available ietab
    then do:
        piErrOut = 3.
        mError:createError({&error}, 000369). /* Mandat de garantie locative inexistant en comptabilite (ietab)*/
        return.
    end.
    if can-find(first cpreln no-lock
                where cpreln.soc-cd   = piCodeSociete
                  and cpreln.etab-cd  = piCodeEtablissement
                  and cpreln.fg-valid = false)
    then do:
        piErrOut = 4. /* Prelevements en attente de traitement */
        mError:createError({&error}, if piCodeEtablissement = integer(mtoken:cRefGerance)
                                     then 000374   /* Prelevements locataires en attente de traitement */
                                     else 000386). /* Prelevements coproprietaires en attente de traitement */
        return.
    end.

    if pcCodeTraitement = "RESOD"
    then find first cbap no-lock
        where cbap.soc-cd  = piCodeSociete
          and cbap.etab-cd = piCodeEtablissement
          and not cbap.fgval no-error.            /* 0714/0255 les cbap ne seront plus supprimés */
    else find first cbap no-lock
        where cbap.soc-cd     = piCodeSociete
          and cbap.etab-cd    = piCodeEtablissement
          and cbap.sscoll-cle = "P"
          and not cbap.fgval no-error.            /* 0714/0255 les cbap ne seront plus supprimés */
    /**Modif OF le 20/10/15 - Pour éviter que des enregistrements obsolètes bloquent la création des ODFM**/
    if available cbap and cbap.daech >= ietab.dadebex1
    then do:
        if cbap.type-reg = 1 then do:
            piErrOut = 18.
            mError:createError({&error}, 108104). /* Reglements proprietaires en attente de traitement */
        end.
        else if cbap.type-reg = 2 or cbap.type-reg = 9 then do:
            piErrOut = 5.
            mError:createError({&error}, 000375). /* Acomptes proprietaires en attente de traitement */
        end.
        else if cbap.type-reg = 3 then do:
            piErrOut = 19.
            mError:createError({&error}, 108105). /* Remboursements coproprietaires en attente de traitement */
        end.
        else if cbap.type-reg = 5 then do:
            piErrOut = 20.
            mError:createError({&error}, 108106). /* Garanties speciales en attente de traitement */
        end.
        else do:
            piErrOut = 21.
            mError:createError({&error}, 108107). /* Paiements divers en attente de traitement */
        end.
        return.
    end.

    if ietab.profil-cd = 21
    and can-find (first iftsai no-lock
                  where iftsai.soc-cd    = piCodeSociete
                    and iftsai.etab-cd   = piCodeEtablissement
                    and iftsai.fg-edifac = false)
    then do:
        piErrOut = 7.
        mError:createError({&error}, 000376). /* Il reste des factures locataire sur le mandat   */
        return.
    end.

    for first ifdparam no-lock
        where ifdparam.soc-dest = piCodeSociete:
        if can-find(first ifdsai no-lock
                    where ifdsai.soc-cd       = ifdparam.soc-cd
                      and ifdsai.fg-edifac    = false
                      and ifdsai.typefac-cle <> "1"
                      and ifdsai.soc-dest     = piCodeSociete
                      and ifdsai.etab-dest    = piCodeEtablissement
                      and ifdsai.fg-cpta-adb  = false)
        then do:
            piErrOut = 8.
            mError:createError({&error}, 000377). /* Il reste des factures diverses non-éditées   */
            return.
        end.
    end.

    if pcCodeTraitement <> "RESOD"
    then do:
        if not can-find(first aetabln no-lock
                        where aetabln.soc-cd    = piCodeSociete
                          and aetabln.etab-cd   = piCodeEtablissement
                          and aetabln.mandat-cd <> piCodeEtablissement)
        then do:
            piErrOut = 50.
            mError:createError({&information}, 106644). /* Le mandat de sous-location %1 n'a pas de banque globale (non bloquant) */
            return.
        end.
        {&_proparse_ prolint-nowarn(wholeIndex)}
        vcDebutCompte = if not can-find(first abascule no-lock) then "4900" else "4790".
        if not can-find(first ccpt no-lock
                        where ccpt.soc-cd   = piCodeSociete
                          and ccpt.coll-cle = ""
                          and ccpt.cpt-cd   = vcDebutCompte + "96000")     // TODO   c'est quoi cette constante
        or not can-find(first ccpt no-lock
                        where ccpt.soc-cd   = piCodeSociete
                          and ccpt.coll-cle = ""
                          and ccpt.cpt-cd   = vcDebutCompte + "96500")     // TODO   c'est quoi cette constante
        then do:
            piErrOut = 16.
            mError:createError({&error}, 000387). /* Compte solde P 4900 96000 et/ou 4900 96500 inexistant */
            return.
        end.
        if can-find(first cecrln no-lock
                    where cecrln.soc-cd   = piCodeSociete
                      and cecrln.etab-cd  = piCodeEtablissement
                      and cecrln.dacompta > pdaResiliation)
        then do :
            piErrOut = 17.
            mError:createError({&error}, 107439). /* Il existe une ecriture comptable de date comptable supérieur à la date de résiliation */
            return.
        end.
    end.
    else do:
        find first agest no-lock
             where agest.soc-cd   = piCodeSociete
               and agest.gest-cle = ietab.gest-cle no-error.
        if not available agest or agest.dafin < pdaOdFinMandat or agest.dadeb > pdaOdFinMandat
        then do:
            piErrOut = 15.
            mError:createError({&error}, 000385). /* La date de l'OD doit etre sur le mois du gestionnaire comptable en cours... */
            return.
        end.
        if can-find(first ifdhono no-lock
                    where ifdhono.soc-cd    = piCodeSociete
                      and ifdhono.etab-cd   = piCodeEtablissement
                      and ifdhono.fg-compta = false)
        then do:
           piErrOut = 9.
           mError:createError({&error}, 000378). /* Il reste des Honoraires de copropriété non facturés */
           return.
        end.
        if can-find(first cpaiepar no-lock
                    where cpaiepar.soc-cd  = piCodeSociete
                      and cpaiepar.etab-cd = piCodeEtablissement
                      and cpaiepar.paie    = true)
        then do:
            piErrOut = 10.
            mError:createError({&error}, 000379). /* Il reste des paiements en cours...              */
            return.
        end.
        if ietab.profil-cd = 91
        then do:
            find first aparm no-lock
                 where aparm.tppar = "RESOD"
                   and aparm.cdpar = "CPT" no-error.
            if not available aparm
            then do:
                piErrOut = 13.
                mError:createError({&error}, 000383). /* Nouveau compte 4999 non parametré */
                return.
            end.
            find first ccpt no-lock
                 where ccpt.soc-cd   = piCodeSociete
                   and ccpt.coll-cle = ""
                   and ccpt.cpt-cd   = aparm.zone2 no-error.
            if not available ccpt
            then do:
                piErrOut = 14.
                mError:createError({&error}, 000384). /* Compte de solde copro inexistant ou paramétrage incorrect.  */
                return.
            end.
            if (piCodeEtablissement <= 9999
                and can-find(first cecrln no-lock
                             where cecrln.soc-cd     = piCodeSociete
                               and cecrln.etab-cd    = piCodeEtablissement
                               and cecrln.sscoll-cle = ""
                               and cecrln.cpt-cd     = ccpt.cpt-cd
                               and cecrln.ref-num    = "SFM" + string(piCodeEtablissement, "9999")
                               and cecrln.type-cle   = "ODFM"))
            or can-find(first cecrln no-lock
                        where cecrln.soc-cd     = piCodeSociete
                          and cecrln.etab-cd    = piCodeEtablissement
                          and cecrln.sscoll-cle = ""
                          and cecrln.cpt-cd     = ccpt.cpt-cd
                          and cecrln.ref-num    = "SFM" + string(piCodeEtablissement, "99999")
                          and cecrln.type-cle   = "ODFM")
            then do:
                piErrOut = 11.
                mError:createError({&error}, 000380). /* Une OD - ODFM existe déjà                       */
                return.
            end.
        end.
        if can-find(first cextln no-lock
                    where cextln.soc-cd       = piCodeSociete
                      and cextln.etab-cd      = piCodeEtablissement
                      and not cextln.type-cle begins "ODRT")
        then do:
            piErrOut = 12.
            mError:createError({&error}, 000382). /* Il reste au moins une ligne extra-comptables (PPEC...   */
            return.
        end.

        for first ietab no-lock
            where ietab.soc-cd  = piCodeSociete
              and ietab.etab-cd = piCodeEtablissement
          , first cecrsai no-lock
            where cecrsai.soc-cd   = piCodeSociete
              and cecrsai.etab-cd  = piCodeEtablissement
              and cecrsai.jou-cd   = "ODFE"
              and cecrsai.type-cle = "ODFE"
              and cecrsai.dacompta >= (if ietab.exercice then ietab.dadebex2 else ietab.dadebex1)
              and cecrsai.dacompta <= (if ietab.exercice then ietab.dafinex2 else ietab.dafinex1)
              and cecrsai.usrid    <> "CLOTURE":
            piErrOut = 26.
            mError:createError({&error}, 132). /* Une ODFE existe sur l'exercice, résiliation par ODFM impossible */
            return.
        end.
    end.
    piErrOut = 0.

end procedure.
