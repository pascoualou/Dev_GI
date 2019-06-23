/*---------------------------------------------------------------------------
File      : ctsuprol.p
Purpose   : Contrôles avant suppression d'un role 
Author(s) : SY 09/01/2004   -  GGA 2018/02/27
Notes     : reprise adb/lib/ctsuprol.p

gga todo ATTENTION pour l'instant seulement teste pour role acheteur (depuis suppression mandat mutation)


01  13/04/2006  SY    0404/0305: adaptation pour les PURGES (compta)
02  27/04/2006  SY    0404/0305: ajout gestion membres du conseil et fournisseur compta ("FOU")
03  28/04/2006  SY    0404/0305: ajout gestion compagnie assurance et courtier
04  09/05/2006  SY    0404/0305: ajout Acheteur/Vendeur
05  04/02/2008  SY    1207/0232: Ajout fonction co-president
06  29/05/2009  SY    0509/0263: Ajout garant (00013)
07  12/11/2009  SY    1109/0054: Ajout role externe (00074) + lien bloc-note non bloquant
08  06/04/2010  SY    0410/0018: On ne peut pas supprimer un copro rattaché à un contrat Titre de copro (01004)
                                 Il faut passer par la suppression contrat (gesctt01.p)
09  08/04/2010  SY    Ajout mandataire (00014)
10  29/12/2010  SY    1210/0164: Ajout prospect (00070)
10  10/04/2012  PL    0312/0009: Ajout Dir. d'agence (00060)
11  05/10/2012  SY    1012/0038: Ajout Huissier (00015)
12  02/11/2017  SY    #5917    : Ajout Salarié Pégase (00150)
---------------------------------------------------------------------------*/
{preprocesseur/type2role.i}
{preprocesseur/type2contrat.i}
{preprocesseur/type2bien.i}
{preprocesseur/type2tache.i}

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{application/include/error.i}
{application/include/glbsepar.i}

define variable gcTypeRole       as character no-undo.
define variable giNumeroRole     as int64     no-undo.
define variable glAfficheMessage as logical   no-undo.
define variable gcTypeTrt        as character no-undo.
define variable gdaPurge         as date      no-undo.
define variable gcCodeRetour     as character no-undo.
define variable gcMessageErreur  as character no-undo.
define variable gcTypeContrat    as character no-undo.
define variable gcLibTypeRole    as character no-undo.

function affMessErr return logical private():
    /*------------------------------------------------------------------------------
    Purpose: affichage message d'erreur
    Notes  :   
    ------------------------------------------------------------------------------*/
    if gcTypeTrt <> "PURGE"
    and glAfficheMessage
    then mError:createError({&error}, gcMessageErreur).
end function.

function numeroImmeuble return integer private(pcTypeContrat as character, piNumeroContrat as int64):
    /*------------------------------------------------------------------------------
    Purpose: recherche immeuble
    Notes  :
    ------------------------------------------------------------------------------*/
    define buffer intnt for intnt.
    for first intnt no-lock
        where intnt.tpcon = pcTypeContrat
          and intnt.nocon = piNumeroContrat
          and intnt.tpidt = {&TYPEBIEN-immeuble}:
        return intnt.noidt.
    end.
    return 0.
end function.

procedure controleRole:
    /*------------------------------------------------------------------------------
    Purpose: 
    Notes  :   
    ------------------------------------------------------------------------------*/
    define input  parameter table for ttError.
    define input  parameter pcTypeRole       as character no-undo.
    define input  parameter piNumeroRole     as int64     no-undo.
    define input  parameter plAfficheMessage as logical   no-undo.
    define input  parameter pcTypeTrt        as character no-undo.
    define input  parameter pdaPurge         as date      no-undo.
    define output parameter pcCodeRetour     as character no-undo.
    define output parameter pcMessageErreur  as character no-undo.

    assign
        gcTypeRole       = pcTypeRole
        giNumeroRole     = piNumeroRole
        glAfficheMessage = plAfficheMessage
        gcTypeTrt        = pcTypeTrt
        gdaPurge         = pdaPurge
        gcCodeRetour     = "00"
    .

    case gcTypeRole:
        when {&TYPEROLE-coproprietaire} then run CtrSupCop.

        when {&TYPEROLE-mandant} or when {&TYPEROLE-coIndivisaire} then run ctrSupMan.

        when {&TYPEROLE-presidentConseilSyndical}   or when {&TYPEROLE-membreConseilSyndical}
     or when {&TYPEROLE-adjointConseilSyndical}     or when {&TYPEROLE-bienfaiteurConseilSyndical}
     or when {&TYPEROLE-respTravauxConseilSyndical} or when {&TYPEROLE-benevole}
     or when {&TYPEROLE-responsableSecurite}        or when {&TYPEROLE-responsableComptabilite}
     or when {&TYPEROLE-coPresident} then run ctrSupMembre.

        when {&TYPEROLE-notaire}     then run ctrSupNot.

        when {&TYPEROLE-compagnie}   then run ctrSupComp.

        when {&TYPEROLE-courtier}    then run ctrSupCourt.

        when {&TYPEROLE-vendeur}  or when {&TYPEROLE-acheteur}
     or when {&TYPEROLE-garant}   or when {&TYPEROLE-mandataire}
     or when {&TYPEROLE-prospect} or when {&TYPEROLE-Huissier} then run ctrSupRolGen.

        when {&TYPEROLE-00074}           then run ctrSupRolExt.

        when {&TYPEROLE-directeurAgence} then run CtrSupDir.    

        when {&TYPEROLE-00046}           then run ctrSupGrp.

        when {&TYPEROLE-salariePegase}   then run ctrSupRolSalPeg.

        when "FOU" then run CtrSupFou.

        otherwise do:
            assign
                //Type de role &1 non gere dans ctsuprol.p
                gcMessageErreur = outilFormatage:fSubst(outilTraduction:getLibelle(1000583), gcTypeRole)
                gcCodeRetour = "02"
            .
            affMessErr(). 
        end.
    end case.
    assign
        pcCodeRetour    = gcCodeRetour
        pcMessageErreur = gcMessageErreur
    .

end procedure.

procedure CtrSupCop private:
    /*------------------------------------------------------------------------------
    Purpose: Procedures de controles avant la suppression d'un coproprietaire 
    Notes  :   
    ------------------------------------------------------------------------------*/
    define variable vcListeLot    as character no-undo.
    define variable vcListeReleve as character no-undo.
    define variable vcListeMandat as character no-undo.

    define buffer ctrat for ctrat.
    define buffer intnt for intnt.
    define buffer local for local.
    define buffer detip for detip.
    define buffer erldt for erldt.
    define buffer erlet for erlet.
     
    for each ctrat no-lock
        where ctrat.tpcon = {&TYPECONTRAT-titre2copro}
          and ctrat.tprol = gcTypeRole
          and ctrat.norol = giNumeroRole
      , each intnt no-lock
        where intnt.tpcon = ctrat.tpcon
          and intnt.nocon = ctrat.nocon
          and intnt.tpidt = {&TYPEBIEN-lot}
      , first local no-lock
        where local.noloc = intnt.noidt:  
        vcListeLot = substitute("&1, &2/&3", vcListeLot, local.noimm, local.nolot).
    end.
    if vcListeLot > "" then do:
        //Suppression copropriétaire impossible, le copropiétaire %1 est rattaché aux lots %2
        assign 
            gcMessageErreur = outilTraduction:getLibelle(110021) + "," +
                              outilFormatage:fSubstGestion(outilTraduction:getLibelle(108473), 
                                                           substitute('&2&1&3', separ[1], string(giNumeroRole,"99999"), substring(vcListeLot, 2, -1, 'character')))
            gcCodeRetour    = "01"
        .
        affMessErr(). 
        return.
    end.
    for first intnt no-lock
        where intnt.tpcon = {&TYPECONTRAT-DossierMutation} 
          and intnt.tpidt = {&TYPEROLE-vendeur}
          and intnt.noidt = giNumeroRole:
        //Suppression copropriétaire impossible, le copropriétaire %1 est vendeur dans le dossier mutation %2
        assign 
            gcMessageErreur = outilTraduction:getLibelle(110021) + "," +
                              outilFormatage:fSubstGestion(outilTraduction:getLibelle(108474), substitute('&2&1&3', separ[1], string(giNumeroRole,"99999"), intnt.nocon))
            gcCodeRetour    = "02"
        .
        affMessErr(). 
        return.
    end.
    for first intnt no-lock
        where intnt.tpcon = {&TYPECONTRAT-DossierMutation}
          and intnt.tpidt = {&TYPEROLE-acheteur}
          and intnt.noidt = giNumeroRole:
        //Suppression copropriétaire impossible, le copropriétaire %1 est acheteur dans le dossier mutation %2
        assign 
            gcMessageErreur = outilTraduction:getLibelle(110021) + "," +
                              outilFormatage:fSubstGestion(outilTraduction:getLibelle(108475), 
                                                           substitute('&2&1&3', separ[1], string(giNumeroRole,"99999"), intnt.nocon))
            gcCodeRetour    = "02"
        .
        affMessErr(). 
        return.
    end.
    for first intnt no-lock
        where intnt.tpcon = {&TYPECONTRAT-mutation}
          and intnt.tpidt = {&TYPEROLE-vendeur}
          and intnt.noidt = giNumeroRole:
        //Suppression copropriétaire impossible, Le copropriétaire %1 est Vendeur dans la mutation %2
        assign 
            gcMessageErreur = outilTraduction:getLibelle(110021) + "," +
                              outilFormatage:fSubstGestion(outilTraduction:getLibelle(108476), 
                                                           substitute('&2&1&3', separ[1], string(giNumeroRole,"99999"), intnt.nocon))
            gcCodeRetour    = "02"
        .
        affMessErr(). 
        return.
    end.
    for first intnt no-lock
        where intnt.tpcon = {&TYPECONTRAT-mutation}
          and intnt.tpidt = {&TYPEROLE-acheteur}
          and intnt.noidt = giNumeroRole:
        //Suppression copropriétaire impossible, Le copropriétaire %1 est Acheteur dans la mutation %2
        assign 
            gcMessageErreur = outilTraduction:getLibelle(110021) + "," +
                              outilFormatage:fSubstGestion(outilTraduction:getLibelle(108477), 
                                                           substitute('&2&1&3', separ[1], string(giNumeroRole,"99999"), intnt.nocon))
            gcCodeRetour    = "02"
        .
        affMessErr(). 
        return.
    end.
    //il ne doit pas être dans une IP ou un relevé d'eau 
    for each erldt no-lock
       where erldt.nocop = giNumeroRole
    , first erlet no-lock
      where erlet.norli = erldt.norli:
        vcListeReleve = vcListeReleve + ", " + outilTraduction:getLibelleParam("TPCPT", erlet.tpcpt) + " " + string(erlet.noimm) + "/" + string(erlet.norlv).    
    end.  
    if vcListeReleve > "" then do:
        //Suppression copropriétaire impossible, Le copropriétaire %1 est rattaché‚ aux relevés %2
        assign 
            gcMessageErreur = outilTraduction:getLibelle(110021) + "," +
                              outilFormatage:fSubstGestion(outilTraduction:getLibelle(108478), 
                                                           substitute('&2&1&3', separ[1], string(giNumeroRole,"99999"), substring(vcListeReleve, 2, -1, 'character')))
            gcCodeRetour    = "03"
        .
        affMessErr(). 
        return.
    end.
    for each detip no-lock
       where detip.nocop = giNumeroRole:
        vcListeReleve = substitute("&1, &2/&3", vcListeReleve, detip.noimm, string(detip.dtimp, "99/99/9999")).
    end.
    if vcListeReleve > "" then do:
        //Suppression copropriétaire impossible, Le copropriétaire %1 est rattaché aux imputations %2
        assign 
            gcMessageErreur = outilTraduction:getLibelle(110021) + "," +
                              outilFormatage:fSubstGestion(outilTraduction:getLibelle(108479), 
                                                           substitute('&2&1&3', separ[1], string(giNumeroRole,"99999"), substring(vcListeReleve, 2, -1, 'character')))
            gcCodeRetour    = "04"
        .
        affMessErr(). 
        return.
    end.
    //Controle en comptabilite
    run CtrCptaRol.
    if gcCodeRetour > "01" then return.

    // il ne doit pas y avoir de titre copro (même sans lot)
    for each ctrat no-lock
        where ctrat.tpcon = {&TYPECONTRAT-titre2copro}
          and ctrat.tprol = gcTypeRole
          and ctrat.norol = giNumeroRole:
        vcListeMandat = substitute("&1, &2", vcListeMandat, substring(string(ctrat.nocon, "9999999999"), 1, 5, "character")).
    end.    
    if vcListeMandat > "" then do:
        //Suppression copropriétaire impossible, Le copropriétaire %1 est rattaché au(x) mandat(s) de syndic %2
        assign 
            gcMessageErreur = outilTraduction:getLibelle(110021) + "," +
                              outilFormatage:fSubstgestion(outilTraduction:getLibelle(110875), 
                                                           substitute('&2&1&3', separ[1], string(giNumeroRole,"99999"), substring(vcListeMandat, 2)))
            gcCodeRetour    = "05"
        .
        affMessErr(). 
        return.
    end.

end procedure.

procedure CtrSupMan private:
    /*------------------------------------------------------------------------------
    Purpose: Procedures de controles avant la suppression d'un Mandant 
    Notes  :   
    ------------------------------------------------------------------------------*/
    define buffer intnt for intnt.

    //Il ne doit pas y avoir de mandat associé
    for first intnt no-lock 
        where intnt.tpcon = {&TYPECONTRAT-mandat2Gerance}
          and intnt.tpidt = gcTypeRole
          and intnt.noidt = giNumeroRole:
        //Suppression mandant ou indivisaire impossible, Le mandant %1 est rattaché au mandat %2 
        assign 
            gcMessageErreur = outilTraduction:getLibelle(110022) + "," +
                              outilFormatage:fSubstGestion(outilTraduction:getLibelle(108480), 
                                                           substitute('&2&1&3', separ[1], string(giNumeroRole,"99999"), intnt.nocon))
            gcCodeRetour    = "01"
        .
        affMessErr(). 
        return.
    end.
    //Controle en comptabilite
    run CtrCptaRol.

end procedure.

procedure ctrSupMembre private:
    /*------------------------------------------------------------------------------
    Purpose: Procedure de controle utilisation membre du conseil
    Notes  :   
    ------------------------------------------------------------------------------*/
    define buffer taint for taint. 
    //il ne doit pas faire partie d'un conseil syndical
    for first taint no-lock 
        where taint.tpcon = {&TYPECONTRAT-mandat2Syndic}
          and taint.tpidt = gcTypeRole
          and taint.noidt = giNumeroRole:
        assign 
            gcLibTypeRole = outilTraduction:getLibelleProg("O_ROL", gcTypeRole)
            //suppression menbre du conseil impossible
            //Le %1 est rattaché au conseil syndical du mandat %2
            gcMessageErreur = outilTraduction:getLibelle(110024) + "," +
                              outilFormatage:fSubstGestion(outilTraduction:getLibelle(110025), 
                                                           substitute('&2&1&3', separ[1], gcLibTypeRole + " " + string(giNumeroRole, "99999"), taint.nocon))
            gcCodeRetour    = "01".
        .
        affMessErr(). 
    end.

end procedure.
    
procedure CtrCptaRol private:
    /*------------------------------------------------------------------------------
    Purpose: Procedure de controle des ecriture du role en compta
    Notes  :   
    ------------------------------------------------------------------------------*/
    define variable viTpRolCpt      as integer   no-undo.
    define variable vcCdScpRol      as character no-undo.
    define variable vcLibDebMessage as character no-undo.

    define buffer ccptcol for ccptcol.
    define buffer csscpt  for csscpt.

    case gcTypeRole:
        when {&TYPEROLE-mandant} or when {&TYPEROLE-coIndivisaire} then assign
            viTpRolCpt = 16
            vcLibDebMessage = outilTraduction:getLibelle(110022)  //Suppression mandant ou indivisaire impossible
        .
        when {&TYPEROLE-coproprietaire} then assign
            viTpRolCpt = 8
            vcLibDebMessage = outilTraduction:getLibelle(110021)  //suppression coproprietaire impossible
        .
    end case.
    vcCdScpRol = string(giNumeroRole, "99999").

    /*--> Recherche le compte individuel en comptabilite */
    for first ccptcol no-lock
        where ccptcol.soc-cd = integer(mToken:cRefPrincipale)
          and ccptcol.tprole = viTpRolCpt:
        for each csscpt no-lock
            where csscpt.soc-cd   = ccptcol.soc-cd
              and csscpt.coll-cle = ccptcol.coll-cle
              and csscpt.cpt-cd   = vcCdScpRol:  
            if can-find(first cecrln no-lock
                        where cecrln.soc-cd     = csscpt.soc-cd
                          and cecrln.etab-cd    = csscpt.etab-cd
                          and cecrln.sscoll-cle = csscpt.sscoll-cle
                          and cecrln.cpt-cd     = vcCdScpRol)
            then do:
                /* Il existe des écriture en comptabilité (cecrln) */
                assign 
                    gcMessageErreur = vcLibDebMessage + "," + outilTraduction:getLibelle(107475)
                    gcCodeRetour    = "10"
                .
                affMessErr(). 
                return.
            end.
            if can-find(first cextln no-lock
                        where cextln.soc-cd     = csscpt.soc-cd
                          and cextln.etab-cd    = csscpt.etab-cd
                          and cextln.sscoll-cle = csscpt.sscoll-cle
                          and cextln.cpt-cd     = vcCdScpRol)
            then do:
                /* Il existe des écriture en comptabilité (cextln) */
                assign 
                    gcMessageErreur = vcLibDebMessage + "," + outilTraduction:getLibelle(107476)
                    gcCodeRetour    = "10"
                .
                affMessErr(). 
                return.
            end.
            if can-find(first cexmln no-lock
                        where cexmln.soc-cd     = csscpt.soc-cd
                          and cexmln.etab-cd    = csscpt.etab-cd
                          and cexmln.sscoll-cle = csscpt.sscoll-cle
                          and cexmln.cpt-cd     = vcCdScpRol)
            then do:
                /* Il existe des écriture en comptabilité (cextln) */
                assign 
                    gcMessageErreur = vcLibDebMessage + "," + outilTraduction:getLibelle(107477)
                    gcCodeRetour    = "10"
                .
                affMessErr(). 
                return.
            end.
        end.
    end.

end procedure.

procedure CtrSupFou private:
    /*------------------------------------------------------------------------------
    Purpose: Procedure de controle utilisation compte fournisseur de compta
    Notes  :   
    ------------------------------------------------------------------------------*/
    define variable vlContratEntretien as logical no-undo.
    define variable viNumeroDossier    as integer no-undo.
    define variable viNumeroContrat    as integer no-undo.

    define buffer intnt for intnt. 
    define buffer ctrat for ctrat. 
    define buffer doset for doset.
    define buffer trdos for trdos.
    define buffer devis for devis.
    define buffer dtdev for dtdev.
    define buffer inter for inter.
    define buffer factu for factu.
    define buffer dtfac for dtfac.
    define buffer ordse for ordse.
    define buffer dtord for dtord.
    define buffer tache for tache.

    // Il ne doit pas être rattaché à un contrat d'entretien PURGE: actif ou résilié apres la date de PURGE
    if gcTypeTrt <> "PURGE"
    then for first intnt no-lock
        where intnt.tpcon = {&TYPECONTRAT-fournisseur}
          and intnt.tpidt = gcTypeRole
          and intnt.noidt = giNumeroRole:
        assign
            vlContratEntretien = yes
            viNumeroDossier    = intnt.nocon
        .
    end.
    else for each intnt no-lock
        where intnt.tpcon = {&TYPECONTRAT-fournisseur}
          and intnt.tpidt = gcTypeRole
          and intnt.noidt = giNumeroRole
      , first ctrat no-lock
        where ctrat.tpcon = intnt.tpcon
          and ctrat.nocon = intnt.nocon
          and (ctrat.dtree = ? or ctrat.dtree > gdaPurge):
        assign
            vlContratEntretien = yes
            viNumeroDossier    = intnt.nocon
        .
        leave.
    end.
    if vlContratEntretien then do:
        //Suppression fournisseur impossible */
        //Le fournisseur comptable %1 est rattaché au contrat d'entretien %2
        assign
            gcMessageErreur = outilTraduction:getLibelle(110026) + "," +
                              outilFormatage:fSubstGestion(outilTraduction:getLibelle(110027), 
                                                           substitute('&2&1&3', separ[1], string(giNumeroRole,"99999"), viNumeroDossier))
            gcCodeRetour    = "02"
        .
        affMessErr(). 
        return.
    end.
    // Il ne doit pas être rattaché à un Dossier travaux PURGE : actif ou résilié apres la date de PURGE
    if gcTypeTrt <> "PURGE"
    then for first doset no-lock
        where doset.nofou = giNumeroRole:
        assign
            vlContratEntretien = yes
            viNumeroDossier    = doset.nodos
            viNumeroContrat    = doset.nocon
        .
    end.
    else for each doset no-lock
        where doset.nofou = giNumeroRole    
      , first trdos no-lock
        where trdos.tpcon = doset.tpcon
          and trdos.nocon = doset.nocon
          and trdos.nodos = doset.nodos
          and (trdos.dtree = ? or trdos.dtree > gdaPurge):
        assign
            vlContratEntretien = yes
            viNumeroDossier    = doset.nodos
            viNumeroContrat    = doset.nocon
        .
        leave.
    end.
    if vlContratEntretien then do:
        //Suppression fournisseur impossible */
        //Le fournisseur comptable %1 est rattaché au Dossier travaux %2 du mandat %3
        assign
            gcMessageErreur = outilTraduction:getLibelle(110026) + "," +
                              outilFormatage:fSubstGestion(outilTraduction:getLibelle(110028), 
                                                           substitute('&2&1&3&1&4', separ[1], string(giNumeroRole,"99999"), viNumeroDossier, viNumeroContrat))
            gcCodeRetour    = "03"
        .
        affMessErr(). 
        return.
    end.
    //Il ne doit pas être rattaché à un Devis
blocDevis:
    for each devis no-lock
        where devis.nofou = giNumeroRole
      , first dtdev no-lock
        where dtdev.nodev = devis.nodev
      , first inter no-lock
        where inter.noint = dtdev.noint:
        assign  
            vlContratEntretien = yes
            viNumeroContrat    = inter.NoCon
            viNumeroDossier    = inter.noint
        . 
        leave blocDevis.
    end.
    if vlContratEntretien then do:
        //Suppression fournisseur impossible */
        //Le fournisseur comptable %1 est rattaché à l'intervention no %2 du mandat %3 (%4)
        assign
            gcMessageErreur = outilTraduction:getLibelle(110026) + "," +
                              outilFormatage:fSubstGestion(outilTraduction:getLibelle(110029), substitute('&2&1&3&1&4&1&5', separ[1], string(giNumeroRole,"99999"), viNumeroDossier, viNumeroContrat, "devis"))
            gcCodeRetour    = "04"
        .
        affMessErr(). 
        return.
    end.
    // Il ne doit pas être rattaché à une facture
blocFacture:
    for each factu no-lock
        where factu.nofou = giNumeroRole
      , first dtfac no-lock
        where dtfac.nofac = factu.nofac
      , first inter no-lock
        where inter.noint = dtfac.noint:
        assign
            vlContratEntretien = yes
            viNumeroContrat    = inter.NoCon
            viNumeroDossier    = inter.noint
        . 
        leave blocFacture.
    end.
    if vlContratEntretien then do:
        //Suppression fournisseur impossible */
        //Le fournisseur comptable %1 est rattaché à l'intervention no %2 du mandat %3 (%4)
        assign
            gcMessageErreur = outilTraduction:getLibelle(110026) + "," +
                              outilFormatage:fSubstGestion(outilTraduction:getLibelle(110029), 
                                                           substitute('&2&1&3&1&4&1&5', separ[1], string(giNumeroRole,"99999"), viNumeroDossier, viNumeroContrat, "facture"))
            gcCodeRetour    = "05"
        .
        affMessErr(). 
        return.
    end.
    // il ne doit pas être rattaché à un ordre de service
blocOS:
    for each ordse no-lock
        where ordse.nofou = giNumeroRole
      , first dtord no-lock
        where dtord.noord = ordse.noord
      , first inter no-lock
        where inter.noint = dtord.noint:
        assign
            vlContratEntretien = yes
            viNumeroContrat    = inter.NoCon
            viNumeroDossier    = inter.noint
        . 
        leave blocOS.
    end.
    if vlContratEntretien then do:
        //Suppression fournisseur impossible */
        //Le fournisseur comptable %1 est rattaché à l'intervention no %2 du mandat %3 (%4)
        assign
            gcMessageErreur = outilTraduction:getLibelle(110026) + "," +
                              outilFormatage:fSubstGestion(outilTraduction:getLibelle(110029), 
                                                           substitute('&2&1&3&1&4&1&5', separ[1], string(giNumeroRole,"99999"), viNumeroDossier, viNumeroContrat, "ordre de service"))
            gcCodeRetour    = "05"
        .
        affMessErr(). 
        return.
    end.
    //Il ne doit pas être rattaché à entretien asc immeuble
    for first tache no-lock
        where tache.tpcon = {&TYPECONTRAT-construction} 
          and tache.tptac >= {&TYPEtache-ascenseurs}
          and tache.tptac <= {&TYPEtache-ctlTechniqueAscenseur}
          and integer(tache.tpfin) = giNumeroRole:
        //Suppression fournisseur impossible */
        //Le fournisseur comptable %1 est utilisé dans l'entretien des ascenceurs de l'immeuble %2
        assign
            gcMessageErreur = outilTraduction:getLibelle(110026) + "," +
                              outilFormatage:fSubstGestion(outilTraduction:getLibelle(110033), 
                                                           substitute('&2&1&3', separ[1], string(giNumeroRole,"99999"), numeroImmeuble(tache.tpcon, tache.nocon)))
            gcCodeRetour    = "01"
        .
        affMessErr(). 
        return.
    end.
    //Il ne doit pas être rattaché à dommage ouvrage imm
    for first tache no-lock
        where tache.tpcon = {&TYPECONTRAT-construction}
          and tache.tptac = {&TYPEtache-dommageOuvrage}
          and integer(tache.pdges) = giNumeroRole:
        //Suppression fournisseur impossible */
        //Le fournisseur comptable %1 est utilisé dans un dommage ouvrage de l'immeuble %2
        assign
            gcMessageErreur = outilTraduction:getLibelle(110026) + "," +
                              outilFormatage:fSubstGestion(outilTraduction:getLibelle(110034), 
                                                           substitute('&2&1&3', separ[1], string(giNumeroRole,"99999"), numeroImmeuble(tache.tpcon, tache.nocon)))
            gcCodeRetour    = "01"
        .
        affMessErr(). 
        return.
    end.
    //Il ne doit pas être rattaché à un BIP immeuble
    for first tache no-lock
        where tache.tpcon = {&TYPECONTRAT-construction}
          and tache.tptac = {&TYPEtache-cleMagnetiqueEntete}
          and integer(tache.pdges) = giNumeroRole:
        //Suppression fournisseur impossible */
        //Le fournisseur comptable %1 est fournisseur des cartes magnétiques de l'immeuble %2
        assign
            gcMessageErreur = outilTraduction:getLibelle(110026) + "," +
                              outilFormatage:fSubstGestion(outilTraduction:getLibelle(110035), 
                                                           substitute('&2&1&3', separ[1], string(giNumeroRole,"99999"), numeroImmeuble(tache.tpcon, tache.nocon)))
            gcCodeRetour    = "01"
        .
        affMessErr(). 
        return.
    end.

end procedure.

procedure CtrSupComp private:
    /*------------------------------------------------------------------------------
    Purpose: Procedure de controle avant suppression d'une compagnie d'assurance 
    Notes  :   
    ------------------------------------------------------------------------------*/        
    define buffer intnt for intnt. 
    define buffer tache for tache.

    for first intnt no-lock 
        where intnt.tpidt = gcTypeRole
          and intnt.noidt = giNumeroRole
          and intnt.tpcon <> {&TYPECONTRAT-blocNote}:
        assign 
            gcTypeContrat   = outilTraduction:getLibelleProg("O_CLC", intnt.tpcon)
            //Suppression compagnie assurance impossible
            //La compagnie %1 est rattaché au contrat %2
            gcMessageErreur = outilTraduction:getLibelle(110036) + "," +
                              outilFormatage:fSubstGestion(outilTraduction:getLibelle(110038), substitute('&2&1&3', separ[1], string(giNumeroRole,"99999"), gcTypeContrat + " " + string(intnt.nocon)))
            gcCodeRetour    = "01"
        .
        affMessErr(). 
        return.
    end.

    //Il ne doit pas etre dans un dommage ouvrage
    for first tache no-lock
        where tache.tpcon = {&TYPECONTRAT-construction}
          and tache.tptac = {&TYPETACHE-dommageOuvrage}
          and integer(tache.ntges) = giNumeroRole:
        //Suppression compagnie assurance impossible
        //La compagnie %1 est utilisé dans un dommage ouvrage de l'immeuble %2
        assign
            gcMessageErreur = outilTraduction:getLibelle(110036) + "," +
                              outilFormatage:fSubstGestion(outilTraduction:getLibelle(110037), 
                                                           substitute('&2&1&3', separ[1], string(giNumeroRole,"99999"), numeroImmeuble(tache.tpcon, tache.nocon)))
            gcCodeRetour    = "01"
        .
        affMessErr(). 
        return.
    end.     

end procedure.

procedure ctrSupCourt private:
    /*------------------------------------------------------------------------------
    Purpose: Procedure de controle avant suppression d'un courtier
    Notes  :   
    ------------------------------------------------------------------------------*/
    define buffer intnt for intnt. 
    define buffer tache for tache.

    for first intnt no-lock 
         where intnt.tpidt = gcTypeRole
           and intnt.noidt = giNumeroRole
           and intnt.tpcon <> {&TYPECONTRAT-blocNote}:
        assign 
            gcTypeContrat   = outilTraduction:getLibelleProg("O_CLC", intnt.tpcon)
            //Suppression courtier impossible
            //Le courtier %1 est rattaché au contrat %2
            gcMessageErreur = outilTraduction:getLibelle(110039) + "," +
                              outilFormatage:fSubstGestion(outilTraduction:getLibelle(110040), substitute('&2&1&3', separ[1], string(giNumeroRole,"99999"), gcTypeContrat + " " + string(intnt.nocon)))
            gcCodeRetour    = "01"
        .
        affMessErr(). 
        return.
    end.
    //Il ne doit pas etre dans un dommage ouvrage
    for first tache no-lock
        where tache.tpcon          = {&TYPECONTRAT-construction}
          and tache.tptac          = {&TYPETACHE-dommageOuvrage}
          and integer(tache.tpges) = giNumeroRole:
        //Suppression courtier impossible
        //Le courtier %1 est utilisé dans un dommage ouvrage de l'immeuble %2
        assign
            gcMessageErreur = outilTraduction:getLibelle(110039) + "," +
                              outilFormatage:fSubstGestion(outilTraduction:getLibelle(110041), 
                                                           substitute('&2&1&3', separ[1], string(giNumeroRole,"99999"), numeroImmeuble(tache.tpcon, tache.nocon)))
            gcCodeRetour    = "01"
        .
        affMessErr(). 
        return.
    end.

end procedure.
    
procedure CtrSupNot private:
    /*------------------------------------------------------------------------------
    Purpose: 
    Notes  :   
    ------------------------------------------------------------------------------*/
    define buffer intnt for intnt. 
    define buffer tache for tache.

    for first intnt no-lock 
        where intnt.tpidt = gcTypeRole
          and intnt.noidt = giNumeroRole
          and intnt.tpcon <> {&TYPECONTRAT-blocNote}:
        assign 
            gcTypeContrat   = outilTraduction:getLibelleProg("O_CLC", intnt.tpcon)
            //Suppression notaire impossible
            //Le notaire %1 est rattaché au contrat %2
            gcMessageErreur = outilTraduction:getLibelle(110030) + "," +
                              outilFormatage:fSubstGestion(outilTraduction:getLibelle(110031), 
                                                           substitute('&2&1&3', separ[1], string(giNumeroRole,"99999"), gcTypeContrat + " " + string(intnt.nocon)))
            gcCodeRetour    = "01"
        .
        affMessErr(). 
        return.
    end.
    //Il ne doit pas etre dans un reglement de copro
    for first tache no-lock
        where tache.tpcon          = {&TYPECONTRAT-construction}
          and tache.tptac          = {&TYPETACHE-reglement2copro}
          and integer(tache.tpges) = giNumeroRole:
        //Suppression notaire impossible
        //Le notaire %1 est utilisé dans le règlement de copropriété de l'immeuble %2
        assign
            gcMessageErreur = outilTraduction:getLibelle(110030) + "," +
                              outilFormatage:fSubstGestion(outilTraduction:getLibelle(110032), 
                                                           substitute('&2&1&3', separ[1], string(giNumeroRole,"99999"), numeroImmeuble(tache.tpcon, tache.nocon)))
            gcCodeRetour    = "01"
        .
        affMessErr(). 
        return.
    end.

end procedure.

procedure CtrSupRolExt private:
    /*------------------------------------------------------------------------------
    Purpose: 
    Notes  :   
    ------------------------------------------------------------------------------*/
    define buffer vbEvent for event.
     
    run CtrSupRolGen.
    if gcCodeRetour = "01" then return.

        /* Vérification présence évènement lié à un immeuble */
    if gcTypeTrt <> "PURGE"
    then for last vbEvent no-lock
        where vbEvent.tprol = gcTypeRole 
          and vbEvent.norol = giNumeroRole 
          and vbEvent.noimm <> 0:
        assign
            //Le role externe &1 est associé à un/des évènement(s) (ex: immeuble &2 - &3) 
            gcMessageErreur = outilFormatage:fSubst(outilTraduction:getLibelle(1000587), 
                                                       substitute('&2&1&3&1&4', separ[1], string(giNumeroRole, "99999"), vbEvent.noimm, vbEvent.lbobj))
            gcCodeRetour    = "50"
        .
        affMessErr(). 
        //Role externe utilisé dans les évènements &1 . Voulez-vous quand même le supprimer ? 
        if glAfficheMessage
        and outils:questionnaire(1000588, gcMessageErreur, table ttError by-reference) < 2
        then do:
            gcCodeRetour = "50".
            return.
        end.
    end.
    
end procedure.

procedure ctrSupRolSalPeg private:
    /*------------------------------------------------------------------------------
    Purpose: 
    Notes  :   
    ------------------------------------------------------------------------------*/
    //Aucun contrôle avant suppression, à vous de vérifier. Voulez-vous quand même supprimer ce salarié Pégase ?
    if gcTypeTrt <> "PURGE" and glAfficheMessage
    and outils:questionnaire(1000588, table ttError by-reference) < 2
    then gcCodeRetour = "150".

end procedure.

procedure CtrSupRolGen private:
    /*------------------------------------------------------------------------------
    Purpose: Procedure de controle avant suppr role générique (Ach/Vend...) 
    Notes  :   
    ------------------------------------------------------------------------------*/
    define buffer intnt for intnt.

    for first intnt no-lock 
        where intnt.tpidt = gcTypeRole
          and intnt.noidt = giNumeroRole
          and intnt.tpcon <> {&TYPECONTRAT-blocNote}:
        assign 
            gcTypeContrat   = outilTraduction:getLibelleProg("O_CLC", intnt.tpcon)
            gcLibTypeRole   = outilTraduction:getLibelleProg("O_ROL", gcTypeRole)
            //suppression impossible
            //Le role %1 est rattaché au contrat %2
            gcMessageErreur = outilTraduction:getLibelle(104432) + "," +
                              outilFormatage:fSubstGestion(outilTraduction:getLibelle(110045), 
                                                           substitute('&2 &3&1&4 &5', separ[1], gcLibTypeRole, string(giNumeroRole, "99999"), gcTypeContrat, intnt.nocon))
        .
        affMessErr(). 
    end.

end procedure.

procedure ctrSupDir private:
    /*------------------------------------------------------------------------------
    Purpose: 
    Notes  :   
    ------------------------------------------------------------------------------*/
    define buffer intnt for intnt.

    for first intnt no-lock 
        where intnt.tpidt = gcTypeRole
          and intnt.noidt = giNumeroRole
          and intnt.tpcon <> {&TYPECONTRAT-blocNote}:
        assign 
            gcTypeContrat = outilTraduction:getLibelleProg("O_CLC", intnt.tpcon)
            //suppression impossible
            //Le Directeur d'agence %1 est rattaché au contrat %2
            gcMessageErreur = outilTraduction:getLibelle(104432) + "," +
                              outilFormatage:fSubstGestion(outilTraduction:getLibelle(1000586), 
                                                           substitute('&2&1&3', separ[1], string(giNumeroRole, "99999"), gcTypeContrat + " " + string(intnt.nocon)))
            gcCodeRetour = "01".
        .
        affMessErr(). 
    end.

end procedure.

procedure CtrSupGrp private:
    /*------------------------------------------------------------------------------
    Purpose: 
    Notes  :   
    ------------------------------------------------------------------------------*/
    define buffer intnt for intnt.

    for first intnt no-lock 
        where intnt.tpidt = gcTypeRole
          and intnt.noidt = giNumeroRole
          and intnt.tpcon <> {&TYPECONTRAT-blocNote}:
        assign 
            gcTypeContrat   = outilTraduction:getLibelleProg("O_CLC", intnt.tpcon)
            //suppression impossible
            //Le Groupe %1 est rattaché au contrat %2
            gcMessageErreur = outilTraduction:getLibelle(104432) + "," +
                              outilFormatage:fSubstGestion(outilTraduction:getLibelle(1000585), 
                                                           substitute('&2&1&3 &4', separ[1], string(giNumeroRole, "99999"), gcTypeContrat, intnt.nocon))
            gcCodeRetour    = "01".
        .
        affMessErr(). 
    end.

end procedure.
