/*-----------------------------------------------------------------------------
File        : calmehqt.p
Purpose     : Module de calcul de la rubrique de quittancement 111 pour l'application de la majoration m�haignerie
Author(s)   : SY - 2004/05/04, Kantena - 2017/12/15
Notes       : reprise de adb/srtc/quit/calmehqt.p
derniere revue: 2018/04/26 - phm: OK

01 23/04/1996  SP    Ajout calcul du nbre de rubriques de la quit.
02 09/05/1996  SP    Correction calcul du nombre de rubriques
03 09/05/1996  LG    Correction probleme "erreur saisie 0":chaine vcListeRubrique � blanc.
04 21/05/1996  SP    V�rification si la tache Majoration mehaignerie � �t� prise en charge
05 18/06/1996  LG    Calcul du montant total quittanc� par rapport � la p�riode de quittancement.
06 26/03/1998  LG    Modif calcul montant major�: * piCodePeriodeQuittancement et non diviser.
07 23/12/1998  SY    Gestion Fin MEHAIGNERIE
08 03/08/1999  AF    Mehaignerie sur 12 ans
09 19/10/1999  SY    AGF/ALLIANZ: Ajout Validation s�par�e des �chus => Nlle variable GlMoiMEc = 1er mois modifiable des �chus                         �
10 27/04/2001  SY    Fiche 1200/1353: Gauriau... Gestion du d�but de majoration meh � une date diff�rente
                     du 1er du mois avec pr�sentation calculs sur 2 rubriques
                         111.xx: palier de l'ann�e
                         114.xx: Avoir (ou rappel ?) chgt palier
11 04/06/2002  SY    Fiche 0502/1190: AGF Correction pb perte rub 111 dans le dernie mois de MEH:
                     on ne peut arreter la MEH que s'il n'y a pas de quittance en attente de validation avant le mois o� on cumule la 111 & la 101
12 30/08/2005  SY    0805/0142 Essai optimisation remplacement lectache par FIND (bof)
13 12/12/2006  SY    0905/0335: plusieurs libell�s autoris�s pour les rubriques loyer si param RUBML
                     ATTENTION: nouveaux param entr�e/sortie pour majlocrb.p
14 21/05/2007  SY    0507/0155: correction erreur trt fin meh suite modifs fiche 0905/0335
15 08/08/2007  SY    0905/0335: regroupement avec event/calmehqt.p => NOUVEAUX PARAMETRES ENTREE/SORTIE
16 16/12/2008  SY    TrtFinMeh: Gestion date de fin d'application rub loyer si pas de multi-libell� uniquement
17 21/09/2009  SY    0909/0115: TrtFinMeh - Proc. renouvellement gestion no libell� rubrique 101: 01 ou 15
-----------------------------------------------------------------------------*/
{preprocesseur/type2tache.i}
// rubrique loyer
&scoped-define NoRub101 101
// rubrique de quittancement
&scoped-define NoRub111 111
// rubrique Avoir/Rappel majoration
&scoped-define NoRub114 114

using parametre.pclie.parametrageRubriqueLibelleMultiple.
{oerealm/include/instanciateTokenOnModel.i} /* Doit �tre positionn�e juste apr�s using */

{bail/include/rubqt.i}    // attention, rubqt, pas prrub !!!???
{tache/include/tache.i}
{bail/include/equit.i &nomtable=ttqtt}
{bail/include/tmprub.i}

define input  parameter pcTypeBail                 as character no-undo.
define input  parameter piNumeroBail               as integer   no-undo.
define input  parameter piNumeroQuittance          as integer   no-undo.
define input  parameter pdaDebutPeriode            as date      no-undo.
define input  parameter pdaFinPeriode              as date      no-undo.
define input  parameter pdaDebutQuittancement      as date      no-undo.
define input  parameter pdaFinQuittancement        as date      no-undo.
define input  parameter piCodePeriodeQuittancement as integer   no-undo.
define input  parameter plRepercussion             as logical   no-undo.
define input  parameter poCollection               as class collection no-undo.
define input-output parameter table for ttQtt.
define input-output parameter table for ttRub.
define output parameter pcCodeRetour               as character no-undo initial "00".

define variable gdaFinBail            as date     no-undo.
define variable giNombreJourQuittance as integer  no-undo.
define variable giNombreJourPeriode   as integer  no-undo.
define variable gdeMontantPeriode     as decimal  no-undo.
define variable gdeMontantQuittance   as decimal  no-undo.
define variable giNombreRubrique      as integer  no-undo.
define variable gdeMontantRubrique    as decimal  no-undo.
define variable giNumeroLibelle       as integer  no-undo.
define variable gdeMontant            as decimal  no-undo.
define variable ghProc                as handle   no-undo.
define variable ghProcRubqt           as handle   no-undo.
define variable ghProcTache           as handle   no-undo.
define variable ghRelationTache       as handle   no-undo.
define variable goRubriqueLibelleMultiple as class parametrageRubriqueLibelleMultiple no-undo.

run bail/quittancement/rubqt_crud.p persistent set ghProcRubqt.
run getTokenInstance in ghProcRubqt(mToken:JSessionId).
run tache/tache.p persistent set ghProcTache.
run getTokenInstance in ghProcTache(mToken:JSessionId).
run application/l_prgdat.p persistent set ghProc.
run getTokenInstance in ghProc(mToken:JSessionId).
run adblib/cttac_crud.p persistent set ghRelationTache.
run getTokenInstance in ghRelationTache(mToken:JSessionId).
goRubriqueLibelleMultiple = new parametrageRubriqueLibelleMultiple().

run calmehqtPrivate.

run destroy in ghProc.
run destroy in ghProcRubqt.
run destroy in ghProcTache.
run destroy in ghRelationTache.
delete object goRubriqueLibelleMultiple.

procedure calmehqtPrivate private:
    /*---------------------------------------------------------------------------
    Purpose :
    Notes   :
    ---------------------------------------------------------------------------*/
    define variable viDureeMajoration     as integer   no-undo.
    define variable viBoucle              as integer   no-undo.
    define variable vcListeMajoration     as character no-undo.
    define variable vdaDebutMajoration    as date      no-undo.
    define variable vdaFinMajoration      as date      no-undo.
    define variable vdaFinMehaignerie     as date      no-undo.
    define variable vdeMontantRubrique    as decimal   no-undo.
    define variable vdeTotalRubrique      as decimal   no-undo.
    define variable vdeTotalMajoration    as decimal   no-undo.
    define variable viCodeDureeMajoration as integer   no-undo.
    define variable vcListeRubrique       as character no-undo.
    define variable viNombreEncours       as integer   no-undo.
    define variable viNombreQuittance     as integer   no-undo.
    define variable viNumeroPremiere      as integer   no-undo.    /* No 1�re quittance en cours dans equit */
    define variable vitoto1               as integer   no-undo.    /* msqtt 1�re quittance en cours dans equit ?????? */
    define variable viNumeroLibelle       as integer   no-undo.

    define buffer equit for equit.
    define buffer tache for tache.
    define buffer cttac for cttac.
    /* Recherche si TOUTES les quittances charg�es */
    /* Parcours des quittances en cours du locataire */
    {&_proparse_ prolint-nowarn(use-index)}
    for each equit no-lock
        where equit.NoLoc = piNumeroBail
        and ((equit.cdter = "00001" and equit.msqtt >= poCollection:getInteger("GlMoiMdf"))
          or (equit.cdter = "00002" and equit.msqtt >= poCollection:getInteger("GlMoiMEc")))
        use-index ix_equit03:
        assign
            viNombreEncours  = viNombreEncours + 1
            viNumeroPremiere = (if viNumeroPremiere = 0 then equit.noqtt else viNumeroPremiere)
            vitoto1          = (if vitoto1 = 0 then equit.Msqtt else vitoto1)
        .
    end.
    /* Parcours des quittances Charg�es du locataire */
    for each ttQtt
        where ttQtt.NoLoc = piNumeroBail:
        viNombreQuittance = viNombreQuittance + 1.
    end.
    /* Suppression de tous les enreg concernant la quittance dans ttRub pour la rubrique 111
       Majoration loyer et la rubrique 114 Avoir/Rappel majoration */
    for each ttRub
        where ttRub.NoLoc = piNumeroBail
          and ttRub.NoQtt = piNumeroQuittance
          and (ttRub.NoRub = {&NoRub111} or ttRub.NoRub = {&NoRub114}):
        assign
            gdeMontantQuittance = gdeMontantQuittance + ttRub.vlmtq
            giNombreRubrique    = giNombreRubrique + 1
        .
        delete ttRub no-error.
    end.
    /* Mise a jour du total de la quittance d�duction du total des rubriques supprim�es */
    assign
        gdeMontantQuittance = - gdeMontantQuittance
        giNombreRubrique    = - giNombreRubrique
    .
    run majttQtt.
    
    /* V�rification PEC de la tache Majoration */
    find first cttac no-lock
        where cttac.tpcon = pcTypeBail
          and cttac.nocon = piNumeroBail
          and cttac.tptac = {&TYPETACHE-majorationMermaz} no-error.  /* Type t�che : majoration m�haignerie */
    if not available cttac then return.
    
    /* Tests des dates de d�but de quittance et quittancement et des dates de fin de quittance et de quittancement */
    if pdaDebutQuittancement < pdaDebutPeriode
    or pdaFinQuittancement > pdaFinPeriode
    or pdaFinPeriode < pdaDebutPeriode then do:
        pcCodeRetour = "01".
        return.
    end.
    
    assign
        giNombreJourPeriode   = pdaFinPeriode - pdaDebutPeriode + 1    /* Calcul de la dur�e de la p�riode de quittancement */
        giNombreJourQuittance = pdaFinQuittancement - pdaDebutQuittancement + 1    /* Calcul de la dur�e de la quittance date � date */
    .
    /* R�cup�ration des donn�es dans la table TACHE */
    find last tache no-lock
        where tache.tpcon = pcTypeBail
          and tache.nocon = piNumeroBail
          and tache.tptac = {&TYPETACHE-majorationMermaz} no-error.
    if available tache then do:
        assign
            vdaFinMehaignerie     = tache.dtfin      /* Date de fin de la majoration MEH */
            viCodeDureeMajoration = tache.duree
        .
        do viBoucle = 3 to num-entries(tache.lbdiv, '#'):
            vcListeMajoration = vcListeMajoration + '|' + entry(viBoucle, tache.lbdiv, '#').
        end.
        vcListeMajoration = trim(vcListeMajoration, '|').
    
        /* Gestion Fin de M�haignerie
         � ATTENTION: toute modif est � reporter dans isFinMeh.p */
        if (pdaDebutPeriode <= vdaFinMehaignerie and vdaFinMehaignerie < pdaFinPeriode)
        or vdaFinMehaignerie < pdaDebutPeriode then do:
            /* R�cup�ration du montant mensuel r�actualis� de l'ann�e en cours */
            gdeMontantPeriode = 0.
boucleMajoration:
            do viBoucle = 1 to num-entries(vcListeMajoration, '|'):
                if date(entry(1, entry(viBoucle, vcListeMajoration, '|'), '@')) < vdaFinMehaignerie
                then gdeMontantPeriode = decimal(entry(3, entry(viBoucle, vcListeMajoration, '|'), '@')).
                else leave boucleMajoration.
            end.
            assign
                vdeTotalMajoration = gdeMontantPeriode * piCodePeriodeQuittancement
                gdeMontantRubrique = vdeTotalMajoration
            .
            /* Traitement fin seulement si on est sur la 1�re quittance en cours (attente valid ou non)
               ET TOUTES LES Quittances charg�es: Cumul de la rub 111 avec le loyer et supprimer la tache et les liens */
            if viNombreQuittance = viNombreEncours and piNumeroQuittance = viNumeroPremiere and poCollection:getInteger("GlMoiQtt") >= vitoto1
            then run trtFinMeh(output pcCodeRetour).
            else do:    /* Sinon, rub 111-01 en attendant que la quittance soit dans le mois de traitement */
                assign
                    giNumeroLibelle = 01
                    gdeMontant      = gdeMontantRubrique
                    vcListeRubrique = substitute("&1@&2@&3", string(giNumeroLibelle, "99"), string(gdeMontantPeriode, "->,>>>,>>9.99"), string(gdeMontantRubrique, "->,>>>,>>9.99"))
                .
                run majttRub({&NoRub111}, 01).
            end.
            return.  /* Traitement termin� */
        end.
        /* Traitement des p�riodes de majoration */
        do viBoucle = 1 to num-entries(vcListeMajoration, '|'):
            vdaDebutMajoration = date(entry(1, entry(viBoucle, vcListeMajoration, '|'), '@')).
            /* Calcul de la date de fin de la majoration */
            run cl2DatFin in ghProc(vdaDebutMajoration, 1, '00001', output vdaFinMajoration).
            assign
                vdaFinMajoration  = vdaFinMajoration - 1
                viDureeMajoration = vdaFinMajoration - vdaDebutMajoration + 1                              /* Dur�e de la majoration */
                gdeMontantPeriode = decimal(entry(3, entry(viBoucle, vcListeMajoration, '|'), '@')) /* R�cup�ration du montant mensuel r�actualis� */
            .
            /* Appel � la proc�dure de traitement */
            run trtPrMaj(vdaDebutMajoration, vdaFinMajoration, viDureeMajoration, gdeMontantPeriode, pdaDebutPeriode, pdaFinPeriode, output vdeMontantRubrique, output vdeTotalRubrique).
            /* Cas o� on a plusieurs majorations dans la quittance. */
            assign
                gdeMontantRubrique = gdeMontantRubrique + vdeMontantRubrique
                vdeTotalMajoration = vdeTotalMajoration + vdeTotalRubrique
            .
            /* R�cup�ration du code libell� pour pouvoir afficher le libell� des diff�rentes majorations(1�re ann�e, 2i�me, ...) */
            if vdeMontantRubrique <> 0 then do:
                case viCodeDureeMajoration:
                    when 3  then giNumeroLibelle = 02 + (viBoucle - 1).
                    when 6  then giNumeroLibelle = 05 + (viBoucle - 1).
                    when 8  then giNumeroLibelle = 11 + (viBoucle - 1).
                    when 12 then giNumeroLibelle = 19 + (viBoucle - 1).
                end case.
                vcListeRubrique = substitute("&1#&2@&3@&4", vcListeRubrique, string(giNumeroLibelle, "99"), string(gdeMontantPeriode, "->,>>>,>>9.99"), string(vdeMontantRubrique, "->,>>>,>>9.99")).
            end.
        end.

        if vcListeRubrique > "" then do:
            assign
                vcListeRubrique    = substring(vcListeRubrique, 2)   /* retirer le premier '#' */
                gdeMontantRubrique = round(gdeMontantRubrique, 2)       /* ne garder que 2 d�cimales */
                /* montant mensuel r�actualis� de l'ann�e en cours */
                gdeMontantPeriode  = decimal(entry(2, entry(num-entries(vcListeRubrique, '#'), vcListeRubrique, '#'), '@'))
                /* Mise � jour de ttRub (montant de l'annee) pour la derni�re entr�e de la chaine vcListeRubrique */
                viNumeroLibelle    = integer(entry(1, entry(num-entries(vcListeRubrique, '#'), vcListeRubrique, '#'), '@'))
            .
            if num-entries(vcListeRubrique, '#') > 1 or gdeMontantRubrique <> (gdeMontantPeriode * piCodePeriodeQuittancement) then do:
                gdeMontant = gdeMontantPeriode * piCodePeriodeQuittancement.
                run majttRub({&NoRub111}, viNumeroLibelle).
                /* Mise � jour de ttRub (Avoir changement annee) */
                gdeMontant = gdeMontantRubrique - (gdeMontantPeriode * piCodePeriodeQuittancement).
                run majttRub({&NoRub114}, if gdeMontant < 0 then 51 else 01).
            end.
            else do:
                gdeMontant = gdeMontantRubrique.
                run majttRub({&NoRub111}, viNumeroLibelle).
            end.
        end.
    end.
end procedure.

procedure calDatExp private:
    /*---------------------------------------------------------------------------
    Purpose :
    Notes   :
    ---------------------------------------------------------------------------*/
    define output parameter pcRetour as character no-undo initial "00".
    define variable viNombreMois as integer  no-undo.
    define buffer ctrat for ctrat.

    find first ctrat no-lock
        where ctrat.TpCon = pcTypeBail
          and ctrat.NoCon = piNumeroBail no-error.
    if not available ctrat then do:
        mError:createError({&error}, 104132, string(piNumeroBail)).
        pcRetour = "01".
        return.
    end.
    gdaFinBail = ctrat.dtfin.
    /* Si renouvellement pas encore fait: allonger la date de fin application
       sinon MajLocRb.p supprime les rubriques sur les quittances futures */
    if gdaFinBail <= pdaFinPeriode then assign
        viNombreMois = if ctrat.cddur = '00001' then 12 * ctrat.nbdur else ctrat.nbdur
        gdaFinBail   = add-interval(gdaFinBail, viNombreMois, "months")    /* Calculer la prochaine Date d'Expiration */
        gdaFinBail   = date(month(gdaFinBail), 28, year(gdaFinBail)) + 4
        gdaFinBail   = gdaFinBail - day(gdaFinBail)                        /* A FIN DE MOIS */
    .
end procedure.

procedure trtPrMaj private:
    /*---------------------------------------------------------------------------
    Purpose : Procedure qui traite les p�riodes de majoration
    Notes   :
    ---------------------------------------------------------------------------*/
    define input parameter  pdaDebutMajoration     as date     no-undo.
    define input parameter  pdaFinMajoration       as date     no-undo.
    define input parameter  piNombreJourMajoration as integer  no-undo.
    define input parameter  pdeMontantPeriode      as decimal  no-undo.
    define input parameter  pdaDebutPriode         as date     no-undo.
    define input parameter  pdaFinPriode           as date     no-undo.
    define output parameter pdeMontantRubrique     as decimal  no-undo.
    define output parameter pdeMontantMajoration   as decimal  no-undo.

    define variable viDureeContrat    as integer no-undo.
    define variable viDureeMajoration as integer no-undo.

    /* Calcul du montant quittanc� concernant la p�riode. (partie gauche de clasqt01) */
    if (pdaDebutMajoration < pdaDebutQuittancement) and (pdaFinMajoration > pdaFinQuittancement)
    then viDureeContrat = giNombreJourQuittance.
    else if (pdaDebutMajoration >= pdaDebutQuittancement) and (pdaDebutMajoration <= pdaFinQuittancement)
         and (pdaFinMajoration >= pdaFinQuittancement)
         then viDureeContrat = (pdaFinQuittancement - pdaDebutMajoration) + 1.
         else if (pdaFinMajoration >= pdaDebutQuittancement) and (pdaFinMajoration <= pdaFinQuittancement)
              and (pdaDebutMajoration <= pdaDebutQuittancement)
              then viDureeContrat = (pdaFinMajoration - pdaDebutQuittancement) + 1.
              else if (pdaDebutMajoration >= pdaDebutQuittancement) and (pdaFinMajoration <= pdaFinQuittancement)
                   then viDureeContrat = piNombreJourMajoration.
    /* Montant quittanc� */
    pdeMontantRubrique = (viDureeContrat / giNombreJourPeriode) * (pdeMontantPeriode * piCodePeriodeQuittancement).
    /* Calcul du montant total quittanc� concernant la p�riode.(partie droite de clasqt01) */
    if (pdaDebutMajoration < pdaDebutPriode) and (pdaFinMajoration > pdaDebutPriode)
    then viDureeMajoration = giNombreJourQuittance.
    else if (pdaDebutMajoration >= pdaDebutPriode) and (pdaDebutMajoration <= pdaFinPeriode)
         and (pdaFinMajoration >= pdaFinPriode)
         then viDureeMajoration = (pdaFinPriode - pdaDebutMajoration) + 1.
         else if (pdaFinMajoration >= pdaDebutPriode) and (pdaFinMajoration <= pdaFinPriode)
              and (pdaDebutMajoration <= pdaDebutPriode)
              then viDureeMajoration = (pdaFinMajoration - pdaDebutPriode) + 1.
              else if (pdaDebutMajoration >= pdaDebutPriode) and (pdaFinMajoration <= pdaFinPriode)
                   then viDureeMajoration = piNombreJourMajoration.
    /* Montant total quittanc� */
    pdeMontantMajoration = (viDureeMajoration / giNombreJourPeriode) * (gdeMontantPeriode * piCodePeriodeQuittancement).

end procedure.

procedure majttQtt private:
    /*---------------------------------------------------------------------------
    Purpose : Procedure qui met � jour le montant quittance pour la rubrique dans ttQtt
    Notes   : pas de for first, le scope de ttQtt est global.
    ---------------------------------------------------------------------------*/
    for first ttQtt
        where ttQtt.NoLoc = piNumeroBail
          and ttQtt.NoQtt = piNumeroQuittance:
        assign
            ttQtt.MtQtt = ttQtt.MtQtt + gdeMontantQuittance
            ttQtt.NbRub = ttQtt.NbRub + giNombreRubrique
            ttQtt.CdMaj = 1
        .
    end.
end procedure.

procedure trtFinMeh private:
    /*---------------------------------------------------------------------------
    Purpose : Procedure qui effectue le traitement de fin de Majoration M�haignerie (TOUTES LES QUITTANCES DOIVENT ETRE CHARGEES)
    Notes   :
        - Cumul montant loyer et majoration finale dans rub loyer 101 (si inexistante: la cr�er)
        - Supprimer la tache m�haignerie et le lien
         Pb Proc�dures de renouvellement: lors de la phase Cong�s, tant que les n�gociations sont en cours et que le locataire
         n'est pas sorti il ne doit plus y avoir de rubrique Loyer (101.01) mais une "indemnit� d'occupation" (101.15)
    ---------------------------------------------------------------------------*/
    define output parameter pcRetour as character no-undo initial "00".

    define variable vdaDebutRubrique as date      no-undo.
    define variable vdaFinRubrique   as date      no-undo.
    define variable vdaDebutAppel    as date      no-undo.
    define variable vdaFinAppel      as date      no-undo.
    define variable vcLibelle        as character no-undo.
    define buffer vbttrub for ttRub.
    define buffer rubqt   for rubqt.

    if gdeMontantRubrique = 0 then return.

    /* Recherche date d'expiration (Fin THEORIQUE) */
    run calDatExp(output pcRetour).
    if pcRetour = "01" then return.

    /* Calcul dates d'application */
    assign
        vdaDebutRubrique = pdaDebutPeriode
        vdaFinRubrique   = gdaFinBail
        /* Verification existence de la rubrique Loyer */
        giNumeroLibelle  = 01
    .
    /* Modif Sy le 21/09/2009: recherche si cumul fin MEH sur rub loyer ou indemnit� occupation */
    find first ttRub
        where ttRub.noloc = piNumeroBail
          and ttRub.noqtt = piNumeroQuittance
          and ttRub.norub = {&NoRub101}
          and ttRub.nolib = 15 no-error.
    if available ttRub then giNumeroLibelle = 15.
    /* Positionnement sur la Rubrique 101.01 ou .15 */
    find first rubqt no-lock
        where rubqt.cdrub = {&NoRub101}
          and rubqt.cdlib = giNumeroLibelle no-error.
    if not available rubQt then do:
        mError:createError({&error}, 104126, "{&NoRub101}").
        pcRetour = "01".
        return.
    end.
    find first ttRub
        where ttRub.noloc = piNumeroBail
          and ttRub.noqtt = piNumeroQuittance
          and ttRub.norub = {&NoRub101}
          and ttRub.nolib = giNumeroLibelle no-error.
    if not available ttRub then do:
        /* Cr�ation rubrique loyer */
        create ttRub.
        assign
            vdaDebutAppel = vdaDebutRubrique
            ttRub.NoLoc = piNumeroBail
            ttRub.NoQtt = piNumeroQuittance
            ttRub.NoRub = {&NoRub101}
            ttRub.NoLib = giNumeroLibelle
            ttRub.LbRub = outilTraduction:getLibelle(rubqt.nome1)
            ttRub.CdFam = rubqt.cdfam
            ttRub.CdSfa = rubqt.cdsfa
            ttRub.CdGen = rubqt.CdGen
            ttRub.CdSig = rubqt.CdSig
            ttRub.CdDet = "0"
            ttRub.VlQte = 0
            ttRub.VlPun = 0
            ttRub.MtTot = gdeMontantRubrique
            ttRub.VlMtq = gdeMontantRubrique
            ttRub.DtDap = vdaDebutRubrique
            ttRub.DtFap = vdaFinRubrique
            ttRub.NoLig = 0
            giNombreRubrique = 1
        .
        if available ttQtt
        then assign
            vdaFinAppel = ttQtt.dtfpr   /* date de fin quittance corrig�e */
            ttRub.CdPro = ttQtt.cdquo   /* cdpro */
            ttRub.VlNum = ttQtt.Nbnum   /* nbnum */
            ttRub.VlDen = ttQtt.Nbden   /* nbden */
        .
    end.
    else assign
        vdaDebutAppel    = ttRub.DtDap
        vdaFinAppel      = ttRub.DtFap
        giNumeroLibelle  = ttRub.nolib
        /* Modification rubrique Loyer */
        ttRub.MtTot      = ttRub.mttot + gdeMontantRubrique
        ttRub.VlMtq      = ttRub.Vlmtq + gdeMontantRubrique
        ttRub.DtFap      = vdaFinRubrique
        giNombreRubrique = 0
    .
    /* Modification du montant de la quittance et nb rub dans ttQtt */
    gdeMontantQuittance = gdeMontantRubrique.
    run MajttQtt.
    /* Verification existence de la rubrique avec un autre libell� dans les quittances futures */
    /* Modification SY le 16/12/2008: si pas de multi-libell� uniquement */
    if not goRubriqueLibelleMultiple:isLibelleMultiple()
    then for first vbttrub
        where vbttrub.noloc = piNumeroBail
          and vbttrub.noqtt <> piNumeroQuittance
          and vbttrub.norub = {&NoRub101}
          and vbttrub.nolib <> giNumeroLibelle:
        ttRub.dtfap = vbttrub.dtdap - 1. /* Ajustement date de fin d'application */
    end.
    if plRepercussion then do:
        /* Lancement du module de r�percussion sur les quittances futures */
        run bail/quittancement/majlocrb.p(
            piNumeroBail,
            piNumeroQuittance,
            {&NoRub101},
            giNumeroLibelle,
            vdaDebutAppel,
            vdaFinAppel,
            input-output vcLibelle,
            input-output table ttQtt,
            input-output table ttRub,
            output pcRetour
        ).
        run supTblTch(output pcRetour).  /* Suppression de la t�che MEH */
    end.
end procedure.

procedure supTblTch private:
    /*---------------------------------------------------------------------------
    Purpose : Procedure qui Supprime une tache
    Notes   :
    ---------------------------------------------------------------------------*/
    define output parameter pcRetour as character no-undo initial "00".

MAJTABLE:
    do transaction:
        /* Utilisation L_Cttac pour Suppression. */
        run suppressionCttac in ghRelationTache(pcTypeBail, piNumeroBail, {&TYPETACHE-majorationMermaz}).
        if mError:erreur() then do:
            pcRetour = '01'.
            undo MajTable, leave MajTable.
        end.
        /* recuperation du numero interne de la tache en cours */
        empty temp-table ttTache.
        run getTache in ghProcTache(pcTypeBail, piNumeroBail, {&TYPETACHE-majorationMermaz}, table ttTache by-reference).
        find first ttTache no-error.
        if not available ttTache then do: 
            mError:createError({&error}, 100351).
            pcRetour = '01'.
            undo MAJTABLE, leave MAJTABLE.
        end.
        ttTache.crud = "D".
        run setTache in ghProcTache(table ttTache by-reference).
        if mError:erreur() then do:
            pcRetour = '01'.
            undo MajTable, leave MajTable.
        end.
    end.
end procedure.

procedure majttRub private:
    /*---------------------------------------------------------------------------
    Purpose : Procedure de cr�ation/Modification d'une rubrique
    Notes   : R�cup�ration des infos dans RUBQT pour la derni�re entr�e de la chaine vcListeRubrique
    ---------------------------------------------------------------------------*/
    define input  parameter piNumeroRubrique as integer no-undo.
    define input  parameter piNumeroLibelle  as integer no-undo.

    empty temp-table ttRubqt.
    run readRubqt in ghProcRubqt(piNumeroRubrique, piNumeroLibelle, table ttRubqt by-reference).
    for first ttRubqt:
        create ttRub.
        assign
            ttRub.NoLoc = piNumeroBail
            ttRub.NoQtt = piNumeroQuittance
            ttRub.CdFam = ttrubqt.cdFam
            ttRub.CdSfa = ttrubqt.cdsFa
            ttRub.NoRub = piNumeroRubrique
            ttRub.NoLib = piNumeroLibelle
            ttRub.LbRub = outilTraduction:getLibelle(ttrubqt.cdlib)
            ttRub.CdGen = ttrubqt.cdgen
            ttRub.CdSig = ttrubqt.cdsig
            ttRub.CdDet = "0"
            ttRub.VlQte = 0
            ttRub.VlPun = 0
            ttRub.MtTot = gdeMontant  /* vdeTotalMajoration*/
            ttRub.CdPro = 0
            ttRub.VlNum = 0
            ttRub.VlDen = 0
            ttRub.VlMtq = gdeMontant
            ttRub.DtDap = pdaDebutQuittancement
            ttRub.DtFap = pdaFinQuittancement
            ttRub.NoLig = 0
            /* Modification du montant de la quittance. Dans ttQtt.mtqtt */
            gdeMontantQuittance = gdeMontantRubrique
            giNombreRubrique = 1
        .
        run MajttQtt.
    end.
end procedure.
