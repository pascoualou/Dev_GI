/*------------------------------------------------------------------------------
File        : delmdtge.p
Purpose     : Suppression d'un mandat de gérance 
Author(s)   : SG 06/03/2003   -  GGA 2018/02/09
Notes       : reprise du pgm adb/cont/delmdtge.p

| Historique des modifications                                                 |
|  Nø  |    Date    | Auteur |                  Objet                          |  
|---------------------------------------------------------------------------   |
| 0001 | 13/05/2003 |  PBP   | 0503/0102 remplacement de DelGeCpt.p inexistant |
|      |            |        | par delmdcpt.p pour supprimer le compte.        |
| 0002 | 21/05/2003 |  PBP   | 0503/0190 utilisation de lib\majseq.p pour la   |
|      |            |        | mise a jour des sequences.                      |
| 0003 | 14/10/2003 |  SY    | 0503/0102 correction : ctrat n'‚tait pas        |
|      |            |        | supprim‚ ni lotmd                               |
|      |            |        | + ajout suppression dans requetes               |
|      |            |        | (ltctt,ltdiv)                                   |
| 0004 | 29/12/2003 |  PL    | 1103/0031 Gestion trace de pec.                 |
|      |            |        | Affichage du type et numero de mandat dans      |
|      |            |        | tous les messages.                              |
|      |            |        | Ajout d'un mode de travail "muet" pour lancer   |
|      |            |        | la purge des pec plantées en batch.             |
| 0005 | 22/03/2005 |  SY    | 0305/0319: CREDIT LYONNAIS                      |
|      |            |        | Ajout controle si Bailleur existe               |
|      |            |        | suppression mandat location C.L. interdite      |
| 0006 | 04/07/2005 |  SY    | 0605/0373: ajout suppr lien banque (rlctt) !!   |
| 0007 | 17/10/2005 |  SY    | 0805/0057: ajout suppr bloc notes               |
| 0012 | 09/12/2005 |  SY    | 0305/0491 :ajout suppr alertes (gadet)          |
| 0013 | 15/12/2005 |  PL    | ajout suppression des purges correspondantes.   |
| 0014 | 27/02/2006 |  PL    | 0106/0512 gestion des commerciaux               |
| 0015 | 13/04/2006 |   SY   | 0404/0305 adaptation pour les PURGES (compta)   |
|      |            |        | + Ajout suppr Dossier Travaux et Inter.         |
| 0016 | 14/04/2006 |   SY   | 0404/0305 ajout tables ctrlb, detlc , etabl     | 
| 0017 | 05/09/2006 |   SY   | 0605/0248 ajout tables chglo                    | 
| 0018 | 01/02/2007 |   SY   | 0207/0008 : correction passage param pour       | 
|      |            |        | message 107621                                  |
|      |            |        | + ignorer bail spécial vacant dans controle     |
| 0019 | 15/10/2007 |   NP   | 1007/0022 Remplacement NoRefUse par NoRefGer    |
| 0020 | 24/10/2007 |   SY   | 0505/0076 : ajout nouvelle table honmd          |
|      |            |        | + honor                                         |
| 0021 | 09/11/2007 |   SY   | 1007/0022:DAUCHEZ séparation ref Copr/gérance   |
| 0022 | 07/04/2008 |   SY   | 0408/0033: Ajout suppr lien rlv eau - charges   |
| 0023 | 02/06/2010 |   SY   | 0706/0018 Mutation gérance/mandat provisoire    |
|      |            |        | ajout controle lien mutation en cours           |
|      |            |        | + suppression mutation gérance (Purges)         |
| 0024 | 21/07/2010 |   SY   | 0706/0018 Mutation gérance                      |
|      |            |        | ajout suppression tbent (correspondance bail)   |
| 0025 | 31/08/2010 |   SY   | 0810/0101 suppression mandat sous-location      |
|      |            |        | interdite si modèle ICADE (00003)               |
| 0026 | 18/02/2011 |   NP   | 0211/0123 gestion suppression aecha côté cpta   |
| 0027 | 19/06/2012 |   PL   | 0212/0155 Sous-location BNP                     |
| 0028 | 18/03/2013 |  SY    | 0313/0049 Adaptation pour GRL (table garlodt)   | 
| 0029 | 26/07/2013 |  SY    | 0511/0023 prélèvement SEPA nouvelles tables     |
|      |            |        | mandatSEPA et suimandatSEPA                     | 
| 0030 | 26/12/2013 |   SY   | 1213/0178 Amélioration gestion LOCK sur ltdiv   |
| 0031 | 12/02/2014 |   SY   | suppression EXCLUSIVE-LOCK sur pclie            |
|      |            |        | (essai suite fiche 0613/0206)                   |
| 0032 | 02/07/2014 |   SY   | 0114/0244 Paie Pegase                           | 
| 0033 | 10/03/2015 |   PL   | 1114/0282 PNO                                   |
| 0034 | 20/04/2015 |   SY   | 1214/0052 Compensation par lot                  |
| 0035 | 10/11/2017 |   SY   | #5949 MANPOWER - Apurement/purge                | 
------------------------------------------------------------------------------*/

{preprocesseur/type2contrat.i}
{preprocesseur/type2role.i}
{preprocesseur/type2bien.i}
{preprocesseur/type2tache.i}
{preprocesseur/nature2contrat.i}
{preprocesseur/type2budget.i}

using parametre.pclie.parametragePayePegase.
using parametre.pclie.parametrageFournisseurLoyer.

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{application/include/error.i}
{outils/include/lancementProgramme.i}
{compta/include/aparm.i}
{adb/cpta/delmdcpt.i}    // procédure suppressionMandatGerance
{application/include/glbsepar.i}
{tache/include/tache.i}
{adblib/include/ctrat.i}
{adblib/include/pclie.i}
{adblib/include/tbent.i}
{adblib/include/cumsa.i}
{adblib/include/intnt.i}
{adblib/include/ctctt.i}

define variable giNumeroMandat         as int64     no-undo.
define variable glMuet                 as logical   no-undo.
define variable gcTypeTrt              as character no-undo.
define variable giNumeroMandant        as int64     no-undo.    
define variable giRefGerance           as integer   no-undo. 
define variable ghProc                 as handle    no-undo.

function affichageMessage return logical private (pcMessage as character):
    /*------------------------------------------------------------------------------
    Purpose: 
    Notes  : 
    ------------------------------------------------------------------------------*/    
    define variable vcInfoMandat as character no-undo. 

    if not glMuet and not gcTypeTrt begins "PURGE"
    then do:
        vcInfoMandat = outilFormatage:fSubst(outilTraduction:getLibelle(1000665), string(giNumeroMandat)).
        mError:createError({&information}, substitute("&1&2", vcInfoMandat, pcMessage)).
    end.
    
end function.

procedure lanceDelmdtge:
    /*------------------------------------------------------------------------------
    Purpose: 
    Notes  : service externe 
    ------------------------------------------------------------------------------*/    
    define input parameter table for ttError.    
    define input parameter piNumeroMandat as int64     no-undo.
    define input parameter plMuet         as logical   no-undo.
    define input parameter pcTypeTrt      as character no-undo.
    define input-output parameter poCollectionHandlePgm as class collection no-undo.
 
    define variable vlAnocontrole as logical no-undo. 
 
    define buffer intnt for intnt.

mLogger:writeLog(0, substitute("delmdtge.p DelMdtGe mandat : &1 muet : &2 type trt : &3", piNumeroMandat, plMuet, pcTypeTrt)).
    assign
        giNumeroMandat = piNumeroMandat
        glMuet         = plMuet
        gcTypeTrt      = pcTypeTrt
        giRefGerance   = integer(mToken:cRefGerance)
    .   
    for first intnt no-lock
        where intnt.tpcon = {&TYPECONTRAT-mandat2Gerance}
          and intnt.nocon = giNumeroMandat
          and intnt.tpidt = {&TYPEROLE-mandant}:
        giNumeroMandant = intnt.noidt.
    end.
    if gcTypeTrt <> "PURGE" and gcTypeTrt <> "PURGE-MANPOWER" 
    then run CtrlDel (output vlAnocontrole).    
mLogger:writeLog(0, substitute("delmdtge.p DelMdtGe retour CtrlDel : &1", vlAnocontrole)).
    if vlAnocontrole then return.
    
    run DelMdtGe (input-output poCollectionHandlePgm).
                    
end procedure.

procedure CtrlDel private:
    /*------------------------------------------------------------------------------
    Purpose: Controle de la suppression d'un Mandat 
    Notes  : 
    ------------------------------------------------------------------------------*/
    define output parameter plAnocontrole as logical no-undo init no. 
    
    define variable viNumeroImmeuble           as int64     no-undo.    
    define variable viMandatLocation           as int64     no-undo.
    define variable viNombreMandatSousLocation as integer   no-undo.
    define variable vcLbBaiFlo                 as character no-undo.
    define variable vcTypeContratSalarie       as character no-undo.    
    define variable vlGestFournisseurLoyer     as logical   no-undo.
    define variable vcCodeModele               as character no-undo.
 
    define variable voPayePegase       as class parametragePayePegase       no-undo.
    define variable voFournisseurLoyer as class parametrageFournisseurLoyer no-undo.
   
    define buffer ctrat   for ctrat. 
    define buffer ctctt   for ctctt.
    define buffer vbctrat for ctrat. 
    define buffer intnt   for intnt.
    define buffer vbintnt for intnt.
    
    /*== Recherche du Mandat ==*/
    find first ctrat no-lock
         where ctrat.tpcon = {&TYPECONTRAT-mandat2Gerance}
           and ctrat.nocon = giNumeroMandat no-error.
    if not available ctrat   
    then do:
        affichageMessage (outilTraduction:getLibelle(353)).
        plAnocontrole = yes.
        return.
    end.
    /*== Recherche des éléments comptabilisés ==*/
    if can-find(first cecrln no-lock
                where cecrln.soc-cd  = giRefGerance
                  and cecrln.etab-cd = giNumeroMandat)
    then do:
        affichageMessage (outilTraduction:getLibelle(107475)).
        plAnocontrole = yes.
        return.
    end.
    if can-find(first cextln no-lock
                where cextln.soc-cd  = giRefGerance
                  and cextln.etab-cd = giNumeroMandat)
    then do:
        affichageMessage (outilTraduction:getLibelle(107476)).
        plAnocontrole = yes.
        return.
    end.
    if can-find(first pregln no-lock
                where pregln.soc-cd  = giRefGerance
                  and pregln.etab-cd = giNumeroMandat)
    then do:
        affichageMessage (outilTraduction:getLibelle(107618)).
        plAnocontrole = yes.
        return.
    end.
    if can-find(first cexmln no-lock
                where cexmln.soc-cd  = giRefGerance
                  and cexmln.etab-cd = giNumeroMandat)
    then do:
        affichageMessage (outilTraduction:getLibelle(107477)).
        plAnocontrole = yes.
        return.
    end.
    if can-find(first ifdhono no-lock
                where ifdhono.soc-cd  = giRefGerance
                  and ifdhono.etab-cd = giNumeroMandat)
    then do:
        affichageMessage (outilTraduction:getLibelle(107619)).
        plAnocontrole = yes.
        return.
    end.                                    
    if can-find(first aecha no-lock
                where aecha.soc-cd      = giRefGerance
                  and aecha.etab-cd     = giNumeroMandat
                  and not aecha.num-ref begins "Suppression par")
    then do:
        affichageMessage (outilTraduction:getLibelle(107620)).
        plAnocontrole = yes.
        return.
    end.                                    
    /*== S'il existe au moins un bail sur ce mandat, ne rien faire ==*/
    for each ctctt no-lock
       where ctctt.tpct1 = {&TYPECONTRAT-mandat2Gerance}
         and ctctt.noct1 = giNumeroMandat
         and ctctt.tpct2 = {&TYPECONTRAT-bail}
    , first vbctrat no-lock
      where vbctrat.tpcon = ctctt.tpct2
        and vbctrat.nocon = ctctt.noct2
        and vbctrat.ntcon <> {&NATURECONTRAT-specialVacant}:       /* ignorer bail special vacant */
        affichageMessage (outilFormatage:fSubstGestion(outilTraduction:getLibelle(107621), substitute('&2&1&3', separ[1], giNumeroMandat, vbctrat.nocon))).
        plAnocontrole = yes.
        return.
    end.
    /*== S'il existe au moins un salarié sur ce mandat, ne rien faire ==*/      
    voPayePegase = new parametragePayePegase().
    vcTypeContratSalarie = (if voPayePegase:iNiveauPaiePegase >= 8 then {&TYPECONTRAT-SalariePegase} else {&TYPECONTRAT-Salarie}).
    delete object voPayePegase.
    for each ctctt no-lock
       where ctctt.tpct1 = {&TYPECONTRAT-mandat2Gerance}
         and ctctt.noct1 = giNumeroMandat
         and ctctt.tpct2 = vcTypeContratSalarie
    , first vbctrat no-lock
      where vbctrat.tpcon = ctctt.tpct2
        and vbctrat.nocon = ctctt.noct2:
        /*Le mandat %1 a au moins un employé d'immeuble.*/
        affichageMessage (outilFormatage:fSubstGestion(outilTraduction:getLibelle(107622), substitute('&2&1', separ[1], giNumeroMandat))).
        plAnocontrole = yes.
        return.
    end.
    if can-find(first trfev no-lock
                where trfev.nomdt = giNumeroMandat)
    then do:
        /* Vous avez effectué des traitement sur ce mandat */
        affichageMessage (outilTraduction:getLibelle(107623)).
        plAnocontrole = yes.
        return.
    end.            
    /* Ajout SY le 02/06/2010 */
    for each vbctrat no-lock
       where vbctrat.tpcon     = {&TYPECONTRAT-mutationGerance}
         and vbctrat.nomdt-ach = giNumeroMandat
         and vbctrat.fgprov    = yes
    , first ctctt no-lock
      where ctctt.tpct1 = {&TYPECONTRAT-mandat2Gerance}
        and ctctt.tpct2 = vbctrat.tpcon
        and ctctt.noct2 = vbctrat.nocon:
        /* Le mandat %1 est le mandat de l'acheteur pour la mutation de gérance  no %2 du mandat %3.*/
        affichageMessage (outilFormatage:fSubstGestion(outilTraduction:getLibelle(110879), 
                                                       substitute('&2&1&3&1&4', separ[1], giNumeroMandat, substring(string(vbctrat.nocon, "999999999"), 6, 4, 'character'), ctctt.noct1))).
        plAnocontrole = yes.
        return.
    end.
    voFournisseurLoyer = new parametrageFournisseurLoyer().
    assign
        vlGestFournisseurLoyer = voFournisseurLoyer:isGesFournisseurLoyer()
        vcCodeModele = voFournisseurLoyer:getCodeModele()
    .
    delete object voFournisseurLoyer no-error.
    /*--> Si Gestion des fournisseurs de loyer Crédit lyonnais : controler si bailleur rattaché à l'immeuble  */
    /*    S'il n'y a pas d'autre mandat sous-locatation : suppression interdite tant qu'il y a un Bailleur    */
    /*    Sinon non bloquant                                                                                  */       
    if vlGestFournisseurLoyer and vcCodeModele = "00002" 
    then do:
        if ctrat.ntcon = {&NATURECONTRAT-mandatLocation}
        then do:
            /* suppression mandat location interdite */
            affichageMessage (outilTraduction:getLibelle(109538)).
            plAnocontrole = yes.
            return.
        end.
        if ctrat.ntcon = {&NATURECONTRAT-mandatSousLocation}
        then viNombreMandatSousLocation = 1.
        for first intnt no-lock
            where intnt.tpcon = {&TYPECONTRAT-mandat2Gerance}
              and intnt.nocon = giNumeroMandat
              and intnt.tpidt = {&TYPEBIEN-immeuble}:
            viNumeroImmeuble = intnt.noidt.
            for each vbintnt no-lock
                where vbintnt.tpidt = intnt.tpidt
                  and vbintnt.noidt = intnt.noidt
                  and vbintnt.tpcon = {&TYPECONTRAT-mandat2Gerance}
                  and vbintnt.nocon <> giNumeroMandat
            , first vbctrat no-lock
              where vbctrat.tpcon = vbintnt.tpcon
                and vbctrat.nocon = vbintnt.nocon:
                if vbctrat.ntcon = {&NATURECONTRAT-mandatLocation}
                then viMandatLocation = vbctrat.nocon.
                else 
                if vbctrat.ntcon = {&NATURECONTRAT-mandatSousLocation}
                then viNombreMandatSousLocation = viNombreMandatSousLocation + 1.
            end.
            /* recherche bail fournisseur loyer */
            vcLbBaiFlo = "".
            for each ctctt no-lock
               where ctctt.tpct1 = {&TYPECONTRAT-mandat2Gerance}
                 and ctctt.noct1 = viMandatLocation
                 and ctctt.tpct2 = {&TYPECONTRAT-bail}
            , first vbctrat no-lock
              where vbctrat.tpcon = ctctt.tpct2
                and vbctrat.nocon = ctctt.noct2:
                vcLbBaiFlo = string(vbctrat.nocon) + " - " + vbctrat.lbnom.
                leave.
            end.
            if vcLbBaiFlo <> "" 
            then do:
                if viNombreMandatSousLocation = 1 
                then do:
                    affichageMessage (outilFormatage:fSubstGestion(outilTraduction:getLibelle(109536), substitute('&2&1&3', separ[1], vcLbBaiFlo, viNumeroImmeuble))).
                    plAnocontrole = yes.
                    return.
                end.
                else affichageMessage (outilFormatage:fSubstGestion(outilTraduction:getLibelle(109537), substitute('&2&1&3', separ[1], vcLbBaiFlo, viNumeroImmeuble))).
            end.

        end.    
    end.
    /* Ajout SY le 31/08/2010 */
    /*--> Si Gestion des fournisseurs de loyer ICADE   */
    /*    suppression interdite mandat sous-locatation    */                                                                       
    if vlGestFournisseurLoyer and (vcCodeModele = "00003" or vcCodeModele = "00004") 
    then do:
        if ctrat.ntcon = {&NATURECONTRAT-mandatSousLocation} or ctrat.ntcon = {&NATURECONTRAT-mandatSousLocationDelegue}
        then do:
            //Mandat sous-location géré en automatique par l'application : suppression interdite
            affichageMessage (outilTraduction:getLibelle(1000666)).
            plAnocontrole = yes.
            return.
        end.    
    end.                    

end procedure.
    
procedure DelMdtGe private:
    /*------------------------------------------------------------------------------
    Purpose: Suppression du Mandat 
    Notes  : 
    ------------------------------------------------------------------------------*/    
    define input-output parameter poCollectionHandlePgm as class collection no-undo.
 
    define variable vcRetourCtrl  as character no-undo.
    define variable vcMessageCtrl as character no-undo.
 
    define buffer vbctrat for ctrat. 
    define buffer vbintnt for intnt.
    define buffer ctctt   for ctctt.
    define buffer tbent   for tbent.
    define buffer cumsa   for cumsa.
    define buffer intnt   for intnt.
    define buffer tache   for tache.
    define buffer trdos   for trdos.
    define buffer inter   for inter.
    define buffer ctrat   for ctrat.
    define buffer entip   for entip.
    define buffer detip   for detip.
    define buffer erlet   for erlet.
    define buffer erldt   for erldt.

mLogger:writeLog(0, "delmdtge.p DelMdtGe").
    find first ctrat no-lock
         where ctrat.tpcon = {&TYPECONTRAT-mandat2Gerance}
           and ctrat.nocon = giNumeroMandat.
    if glMuet = no and not gcTypeTrt begins "PURGE"
    and outils:questionnaire(107720, table ttError by-reference) <= 2 
    then return.
    if gcTypeTrt <> "PURGE" 
    then do:
        run suppressionMandatGerance(giRefGerance, giNumeroMandat, input-output poCollectionHandlePgm).
        if mError:erreur() then return.
    end.
    
    /* pré-baux */
    for each ctctt no-lock
       where ctctt.tpct1 = {&TYPECONTRAT-mandat2Gerance}
         and ctctt.noct1 = giNumeroMandat
         and ctctt.tpct2 = {&TYPECONTRAT-preBail}:  
        ghProc = lancementPgm ("bail/delbai00.p", poCollectionHandlePgm).
        run SupPreBail in ghProc(ctctt.tpct2, ctctt.noct2, giNumeroMandat, yes, input-output poCollectionHandlePgm).
        if mError:erreur() then return.
    end.
    
    /* Baux */
    for each ctctt no-lock
       where ctctt.tpct1 = {&TYPECONTRAT-mandat2Gerance}
         and ctctt.noct1 = giNumeroMandat
         and ctctt.tpct2 = {&TYPECONTRAT-bail}:
        ghProc = lancementPgm ("bail/delbail.p", poCollectionHandlePgm).
        run lanceDelBail in ghProc(table ttError, ctctt.tpct2, ctctt.noct2, no, gcTypeTrt, input-output poCollectionHandlePgm).
        if mError:erreur() then return.
    end.
    
    /* assurance */
    for each ctctt no-lock
       where ctctt.tpct1 = {&TYPECONTRAT-mandat2Gerance}
         and ctctt.noct1 = giNumeroMandat
         and ctctt.tpct2 = {&TYPECONTRAT-assuranceGerance}:    
        ghProc = lancementPgm ("mandat/suppressionContratAssurance.p", poCollectionHandlePgm).
        run SupAssurance in ghProc(table ttError, giNumeroMandat, {&TYPECONTRAT-mandat2Gerance}, gcTypeTrt, input-output poCollectionHandlePgm).
        if mError:erreur() then return.
    end.
    
    /* Ajout Sy le 02/06/2010 : mutations de gérance */
    for each ctctt no-lock
       where ctctt.tpct1 = {&TYPECONTRAT-mandat2Gerance}
         and ctctt.noct1 = giNumeroMandat
         and ctctt.tpct2 = {&TYPECONTRAT-mutationGerance}:
        ghProc = lancementPgm ("adblib/delmut01.p", poCollectionHandlePgm).
        run DelCttMutGer in ghProc(ctctt.noct2, input-output poCollectionHandlePgm).
        if mError:erreur() then return.
    end.   
         
    /* mutations de gérance : correspondance ancien bail / nouveau bail (tbent) */
    empty temp-table ttTbent.
    for each tbent no-lock
       where tbent.cdent >= "MUTAG" + string(giNumeroMandat, "99999") + "0000" 
         and tbent.cdent <= "MUTAG" + string(giNumeroMandat, "99999") + "9999":
        create ttTbent.
        assign
            ttTbent.cdent       = tbent.cdent
            ttTbent.iden1       = tbent.iden1
            ttTbent.iden2       = tbent.iden2
            ttTbent.CRUD        = "D"
            ttTbent.dtTimestamp = datetime(tbent.dtmsy, tbent.hemsy) 
            ttTbent.rRowid      = rowid(tbent) 
        .                        
    end.  
    if can-find(first ttTbent)
    then do:
        ghProc = lancementPgm ("adblib/tbent_CRUD.p", poCollectionHandlePgm).
        run setTbent in ghProc(table ttTbent by-reference).
        if mError:erreur() then return.
    end.  
    
    /* salaries */
    for each ctctt no-lock
       where ctctt.tpct1 = {&TYPECONTRAT-mandat2Gerance}
         and ctctt.noct1 = giNumeroMandat
         and ctctt.tpct2 = {&TYPECONTRAT-Salarie}:
        ghProc = lancementPgm ("adblib/delsalarie.p", poCollectionHandlePgm).
        run DelCttSal in ghProc({&TYPEROLE-salarie}, ctctt.noct2, ctctt.tpct2, ctctt.noct1, ctctt.tpct1, gcTypeTrt, no, input-output poCollectionHandlePgm).
        if mError:erreur() then return.
    end.
    
    /* historiques de paie des salariés anciennement épurés */
    empty temp-table ttCumsa. 
    for each cumsa no-lock
       where cumsa.tpmdt = {&TYPECONTRAT-mandat2Gerance}
         and cumsa.nomdt = giNumeroMandat:
        create ttCumsa.
        assign
            ttCumsa.antrt       = cumsa.antrt
            ttCumsa.tpmdt       = cumsa.tpmdt
            ttCumsa.nomdt       = cumsa.nomdt
            ttCumsa.tprol       = cumsa.tprol
            ttCumsa.norol       = cumsa.norol
            ttCumsa.nomod       = cumsa.nomod
            ttCumsa.CRUD        = "D"
            ttCumsa.dtTimestamp = datetime(cumsa.dtmsy, cumsa.hemsy) 
            ttCumsa.rRowid      = rowid(cumsa) 
         .
    end. 
    if can-find(first ttCumsa) then do:
        ghProc = lancementPgm ("adblib/cumsa_CRUD.p", poCollectionHandlePgm).
        run setCumsa in ghProc(table ttCumsa by-reference).
        if mError:erreur() then return.
    end.

    /* conges payes des salariés anciennement épurés */
    if can-find(first conge no-lock
                where conge.tprol = {&TYPEROLE-salarie}
                  and conge.norol >= integer(string(giNumeroMandat, "9999") + "01")
                  and conge.norol <= integer(string(giNumeroMandat, "9999") + "99"))
    then do: 
        ghProc = lancementPgm ("adblib/conge_CRUD.p", poCollectionHandlePgm).
        run deleteCongeSurRole in ghProc({&TYPEROLE-salarie}, integer(string(giNumeroMandat, "9999") + "01"), integer(string(giNumeroMandat, "9999") + "99")).
        if mError:erreur() then return.    
    end. 
    
    /* jours maladie des salariés anciennement épurés */
    if can-find(first malad no-lock
                where malad.tprol = {&TYPEROLE-salarie}
                  and malad.norol >= integer(string(giNumeroMandat, "9999") + "01")
                  and malad.norol <= integer(string(giNumeroMandat, "9999") + "99"))
    then do:
        ghProc = lancementPgm ("adblib/malad_CRUD.p", poCollectionHandlePgm).
        run deleteMaladSurRole in ghProc({&TYPEROLE-salarie}, integer(string(giNumeroMandat, "9999") + "01"), integer(string(giNumeroMandat, "9999") + "99")).
        if mError:erreur() then return.    
    end. 
    
    /* histo paie des salariés anciennement épurés */
    if can-find(first apaie no-lock
                where apaie.tprol = {&TYPEROLE-salarie}
                  and apaie.norol >= integer(string(giNumeroMandat, "9999") + "01")
                  and apaie.norol <= integer(string(giNumeroMandat, "9999") + "99"))
    then do:  
        ghProc = lancementPgm ("adblib/apaie_CRUD.p", poCollectionHandlePgm).
        run deleteApaieSurRole in ghProc({&TYPEROLE-salarie}, integer(string(giNumeroMandat, "9999") + "01"), integer(string(giNumeroMandat, "9999") + "99")).
        if mError:erreur() then return.    
    end.  
    
    /* salaries Pégase */
    for each ctctt no-lock
       where ctctt.tpct1 = {&TYPECONTRAT-mandat2Gerance}
         and ctctt.noct1 = giNumeroMandat
         and ctctt.tpct2 = {&TYPECONTRAT-SalariePegase}:
        ghProc = lancementPgm ("adblib/delsalarie.p", poCollectionHandlePgm).
        run DelCttSal in ghProc({&TYPEROLE-salariePegase}, ctctt.noct2, ctctt.tpct2, ctctt.noct1, ctctt.tpct1, gcTypeTrt, no, input-output poCollectionHandlePgm).
        if mError:erreur() then return.
    end.
    
    /* Ajout SY le 26/07/2013 : SEPA */
    if can-find(first mandatSepa no-lock
                where mandatSepa.tpmandat = {&TYPECONTRAT-sepa}
                  and mandatSepa.tpcon    = {&TYPECONTRAT-mandat2Gerance} 
                  and mandatSepa.nocon    = giNumeroMandat)
    then do:        
        ghProc = lancementPgm ("adblib/mandatSEPA_CRUD.p", poCollectionHandlePgm).
        run deleteMandatSepaSurContrat in ghProc({&TYPECONTRAT-sepa}, {&TYPECONTRAT-mandat2Gerance}, giNumeroMandat).
        if mError:erreur() then return.
    end.
        
    /* gestionnaire */
    empty temp-table ttCtctt.
    for each ctctt no-lock
       where ctctt.tpct1 = {&TYPECONTRAT-serviceGestion}
         and ctctt.tpct2 = {&TYPECONTRAT-mandat2Gerance}
         and ctctt.noct2 = giNumeroMandat:
        create ttCtctt.
        assign
            ttCtctt.tpct1       = ctctt.tpct1
            ttCtctt.noct1       = ctctt.noct1
            ttCtctt.tpct2       = ctctt.tpct1
            ttCtctt.noct2       = ctctt.noct2
            ttCtctt.CRUD        = "D"
            ttCtctt.dtTimestamp = datetime(ctctt.dtmsy, ctctt.hemsy)
            ttCtctt.rRowid      = rowid(ctctt)
        .
    end.
    if can-find(first ttCtctt)
    then do:
        ghProc = lancementPgm("adblib/ctctt_CRUD.p", poCollectionHandlePgm).
        run setCtctt in ghProc(table ttCtctt by-reference).
        if mError:erreur() then return.
    end.

    /*== Suppression Mandat-UL utilisé pour les commerciaux. ==*/
    ghProc = lancementPgm ("adblib/ctctt_CRUD.p", poCollectionHandlePgm).
    run deleteContratCommerciaux in ghProc({&TYPECONTRAT-mandat2Gerance}, giNumeroMandat).
    if mError:erreur() then return.

    if can-find(first cthis no-lock
                where cthis.tpcon = {&TYPECONTRAT-mandat2Gerance}
                  and cthis.nocon = giNumeroMandat)
    then do:
        ghProc = lancementPgm ("adblib/cthis_CRUD.p", poCollectionHandlePgm).
        run deleteCthisSurContrat in ghProc({&TYPECONTRAT-mandat2Gerance}, giNumeroMandat).
        if mError:erreur() then return.
    end.
    
    /* lien contrat - mandant - bénéficiaire  */
    if can-find(first ctrlb no-lock   
                where ctrlb.tpctt = {&TYPECONTRAT-mandat2Gerance}
                  and ctrlb.noctt = giNumeroMandat)
    then do:                 
        ghProc = lancementPgm ("adblib/ctrlb_CRUD.p", poCollectionHandlePgm).
        run deleteCtrlbSurContratMaitre in ghProc({&TYPECONTRAT-mandat2Gerance}, giNumeroMandat).
        if mError:erreur() then return.
    end.
    
    /* offres de location */ 
    if can-find(first offlc no-lock  
                where offlc.tpcon = {&TYPECONTRAT-mandat2Gerance}
                  and offlc.nocon = giNumeroMandat)
    then do:
        ghProc = lancementPgm ("adblib/offlc_CRUD.p", poCollectionHandlePgm).
        run deleteOfflcSurContrat in ghProc({&TYPECONTRAT-mandat2Gerance}, giNumeroMandat).
        if mError:erreur() then return.
    end.

    if can-find(first detlc no-lock  
                where detlc.tpcon = {&TYPECONTRAT-mandat2Gerance}
                  and detlc.nocon = giNumeroMandat)
    then do:      
        ghProc = lancementPgm ("adblib/detlc_CRUD.p", poCollectionHandlePgm).
        run deleteDetlcSurContrat in ghProc({&TYPECONTRAT-mandat2Gerance}, giNumeroMandat).
        if mError:erreur() then return.
    end.
   
    /* budgets locatifs */
    if can-find(first budle no-lock
                where budle.tpbud = {&TYPEBUDGET-01058}
                  and budle.nomdt = giNumeroMandat)
    then do:
        ghProc = lancementPgm ("adblib/budle_crud.p", poCollectionHandlePgm).
        run deleteBudleSurTypeEtMandat in ghProc({&TYPEBUDGET-01058}, giNumeroMandat).
        if mError:erreur() then return.
    end.
    
    /*== Suppression des clés du mandat de gérance ==*/
    if can-find(first clemi no-lock 
                where clemi.noimm = 10000 + giNumeroMandat)
    then do:   
        ghProc = lancementPgm ("adblib/clemi_crud.p", poCollectionHandlePgm).
        run deleteClemitEtLienSurImmeuble in ghProc(10000 + giNumeroMandat, {&TYPECONTRAT-mandat2Gerance}, giNumeroMandat).
        if mError:erreur() then return.
    end. 
 
    /*== Suppression des liens mandat/Lots d'abord ==*/
    empty temp-table ttCtrat.
    empty temp-table ttIntnt.
    for each intnt no-lock
       where intnt.tpcon = {&TYPECONTRAT-mandat2Gerance}
         and intnt.nocon = giNumeroMandat
         and intnt.tpidt = {&TYPEBIEN-lot}:
        /*== Recherche du No d'Acte de propriété. ==*/
        for first vbintnt no-lock 
            where vbintnt.tpidt = intnt.tpidt
              and vbintnt.noidt = intnt.noidt
              and vbintnt.tpcon = {&TYPECONTRAT-acte2propriete}:
            for first vbctrat no-lock 
                where vbctrat.tpcon = vbintnt.tpcon
                  and vbctrat.nocon = vbintnt.nocon:
                /*== Mise à blanc de l'Acte : le lot est remis à l'immeuble. */      
                create ttCtrat.
                assign
                    ttCtrat.tpcon       = vbctrat.tpcon 
                    ttCtrat.nocon       = vbctrat.nocon
                    ttCtrat.CRUD        = "D"
                    ttCtrat.dtTimestamp = datetime(vbctrat.dtmsy, vbctrat.hemsy)
                    ttCtrat.rRowid      = rowid(vbctrat)
                    ttCtrat.TpRol       = ""
                    ttCtrat.NoRol       = 0
                    ttCtrat.LbNom       = ""
                    ttCtrat.LNom2       = ""
                .
            end. 
        end.
        /*== Penser à détacher le lot du Mandat ==*/
        create ttIntnt.
        assign
            ttIntnt.tpidt       = intnt.tpidt
            ttIntnt.noidt       = intnt.noidt
            ttIntnt.tpcon       = intnt.tpcon
            ttIntnt.nocon       = intnt.nocon
            ttIntnt.nbnum       = intnt.nbnum
            ttIntnt.idpre       = intnt.idpre
            ttIntnt.idsui       = intnt.idsui
            ttIntnt.rRowid      = rowid(intnt)
            ttIntnt.dtTimestamp = datetime(intnt.dtmsy, intnt.hemsy) 
            ttIntnt.CRUD        = 'D'
        .
    end.
    if can-find(first ttCtrat) then do:
        ghProc = lancementPgm ("adblib/ctrat_CRUD.p", poCollectionHandlePgm).
        run setCtrat in ghProc(table ttCtrat by-reference).
        if mError:erreur() then return.
    end.
    if can-find(first ttIntnt) then do:
        ghProc = lancementPgm ("adblib/intnt_CRUD.p", poCollectionHandlePgm).
        run setIntnt in ghProc(table ttIntnt by-reference).
        if mError:erreur() then return.
    end.
    
    /*== On supprime les liens intnt du mandat ==*/
    empty temp-table ttIntnt. 
    for each intnt no-lock
       where intnt.tpcon = {&TYPECONTRAT-mandat2Gerance}
         and intnt.nocon = giNumeroMandat:
        create ttIntnt.
        assign
            ttIntnt.tpidt       = intnt.tpidt
            ttIntnt.noidt       = intnt.noidt
            ttIntnt.tpcon       = intnt.tpcon
            ttIntnt.nocon       = intnt.nocon
            ttIntnt.nbnum       = intnt.nbnum
            ttIntnt.idpre       = intnt.idpre
            ttIntnt.idsui       = intnt.idsui
            ttIntnt.rRowid      = rowid(intnt)
            ttIntnt.dtTimestamp = datetime(intnt.dtmsy, intnt.hemsy) 
            ttIntnt.CRUD        = 'D'
        .
    end.
    if can-find(first ttIntnt) 
    then do:        
        ghProc = lancementPgm ("adblib/intnt_CRUD.p", poCollectionHandlePgm).
        run setIntnt in ghProc(table ttIntnt by-reference).
        if mError:erreur() then return.
  
        /* PURGE : supprimer Mandant et Indivisaires si plus utilisés */  
        if gcTypeTrt begins "PURGE"
        then for each ttIntnt
                where ttIntnt.tpidt = "00022" or ttIntnt.tpidt = "00016":
            ghProc = lancementPgm("adblib/ctsuprol.p", poCollectionHandlePgm).
            run controleRole in ghProc(table ttError by-reference, ttIntnt.tpid, ttIntnt.noidt, no, gcTypeTrt, ?, output vcRetourCtrl, output vcMessageCtrl).
            if vcRetourCtrl = "00"
            then do:
                ghProc = lancementPgm("adblib/suprol01.p", poCollectionHandlePgm).
                run suppressionRole in ghProc(ttIntnt.tpid, ttIntnt.noidt, gcTypeTrt, input-output poCollectionHandlePgm).
                if mError:erreur() then return.
            end.
        end.
    end.
    
    /** 04/07/2005 : suppression lien banque **/
    if can-find(first rlctt no-lock
                where rlctt.tpct1 = {&TYPECONTRAT-mandat2Gerance}
                  and rlctt.noct1 = giNumeroMandat)
    then do:                         
        ghProc = lancementPgm ("adblib/rlctt_CRUD.p", poCollectionHandlePgm).
        run deleteRlcttSurContratMaitre in ghProc({&TYPECONTRAT-mandat2Gerance}, giNumeroMandat).
        if mError:erreur() then return.
    end.
    
    /*== Suppression de toutes les Tâches du Mandat. ==*/
    if can-find(first tache no-lock 
                where tache.tpcon = {&TYPECONTRAT-mandat2Gerance} 
                  and tache.nocon = giNumeroMandat)
    then do:            
        ghProc = lancementPgm ("tache/tache.p", poCollectionHandlePgm).
        run deleteTacheSurContrat in ghProc({&TYPECONTRAT-mandat2Gerance}, giNumeroMandat).
        if mError:erreur() then return.
    end.

    if can-find(first cttac no-lock 
                where cttac.tpcon = {&TYPECONTRAT-mandat2Gerance} 
                  and cttac.nocon = giNumeroMandat)
    then do:                
        ghProc = lancementPgm("adblib/cttac_CRUD.p", poCollectionHandlePgm).
        run deleteCttacSurContrat in ghProc({&TYPECONTRAT-mandat2Gerance}, giNumeroMandat).
        if mError:erreur() then return.
    end.
    
    /* les travaux immeuble (tache 04259) */
    empty temp-table ttTache.    
    for each tache no-lock
       where tache.tptac = {&TYPETACHE-travauxXXXX3}
         and tache.tpfin = {&TYPECONTRAT-mandat2Gerance}
         and tache.duree = giNumeroMandat:
        create ttTache.
        assign
            ttTache.tpcon       = tache.tpcon
            ttTache.nocon       = tache.nocon
            ttTache.tptac       = tache.tptac
            ttTache.notac       = tache.notac
            ttTache.CRUD        = "D"
            ttTache.dtTimestamp = datetime(tache.dtmsy, tache.hemsy) 
            ttTache.rRowid      = rowid(tache) 
        .
    end.
    if can-find(first ttTache) then do:
        ghProc = lancementPgm("tache/tache.p", poCollectionHandlePgm).
        run setTache in ghProc(table ttTache by-reference).
        if mError:erreur() then return.
    end.
    
    /*== Suppression du Lien Contrat/Contrat (Mandat/?). ==*/
    if can-find(first ctctt no-lock
                where ctctt.tpct1 = {&TYPECONTRAT-mandat2Gerance}
                  and ctctt.noct1 = giNumeroMandat)
    then do:        
        ghProc = lancementPgm ("adblib/ctctt_CRUD.p", poCollectionHandlePgm).
        run deleteCtcttSurContratPrincipal in ghProc({&TYPECONTRAT-mandat2Gerance}, giNumeroMandat).
        if mError:erreur() then return.
    end.
    
    /*== Suppression du Lien Contrat/Contrat (?/Mandat). ==*/
    if can-find(first ctctt no-lock
                where ctctt.tpct2 = {&TYPECONTRAT-mandat2Gerance}
                  and ctctt.noct2 = giNumeroMandat)
    then do:            
        ghProc = lancementPgm ("adblib/ctctt_CRUD.p", poCollectionHandlePgm).
        run deleteCtcttSurContratSecondaire in ghProc({&TYPECONTRAT-mandat2Gerance}, giNumeroMandat).
        if mError:erreur() then return.
    end.
    
    /*== Gestion des Unites de Location ==*/
    if can-find(first unite no-lock
                where unite.nomdt = giNumeroMandat)
    then do:    
        ghProc = lancementPgm ("adblib/unite_CRUD.p", poCollectionHandlePgm).
        run deleteUniteEtLienSurMandat in ghProc(giNumeroMandat).
        if mError:erreur() then return.
    end.

    if can-find(first vacan no-lock  
                where vacan.nomdt = giNumeroMandat)
    then do: 
        ghProc = lancementPgm ("adblib/vacan_CRUD.p", poCollectionHandlePgm).
        run deleteVacanSurMandat in ghProc(giNumeroMandat).
        if mError:erreur() then return.
    end.
    
    /* Ajout SY le 24/10/2007 */
    if can-find(first honmd no-lock
                where honmd.tpcon = {&TYPECONTRAT-mandat2Gerance}
                  and honmd.nocon = giNumeroMandat)
    then do:
        ghProc = lancementPgm ("adblib/honmd_CRUD.p", poCollectionHandlePgm).
        run deleteHonmdSurContrat in ghProc({&TYPECONTRAT-mandat2Gerance}, giNumeroMandat).
        if mError:erreur() then return.
    end.  
      
    if can-find(first honor no-lock
                where honor.tpcon = {&TYPECONTRAT-mandat2Gerance}
                  and honor.nocon = giNumeroMandat)
    then do:
        ghProc = lancementPgm ("adblib/honor_CRUD.p", poCollectionHandlePgm).
        run deleteHonorSurContrat in ghProc({&TYPECONTRAT-mandat2Gerance}, giNumeroMandat).
        if mError:erreur() then return.
    end.  
     
    if can-find(first synge no-lock
                where synge.tpct2 = {&TYPECONTRAT-mandat2Gerance}
                  and synge.noct2 = giNumeroMandat)
    then do:
        ghProc = lancementPgm ("adblib/synge_CRUD.p", poCollectionHandlePgm).
        run deleteSyngeSurContrat2 in ghProc({&TYPECONTRAT-mandat2Gerance}, giNumeroMandat).
        if mError:erreur() then return.
    end.  
    
    /* Ajout sy le 09/12/2005 : détail alerte */ 
    if can-find(first gadet no-lock
                where gadet.tpctt = {&TYPECONTRAT-mandat2Gerance}
                  and gadet.noctt = decimal(giNumeroMandat))
    then do:
        ghProc = lancementPgm ("adblib/gadet_CRUD.p", poCollectionHandlePgm).
        run deleteGadetSurContrat in ghProc({&TYPECONTRAT-mandat2Gerance}, decimal(giNumeroMandat)).
        if mError:erreur() then return.
    end.  

    if can-find(first budle no-lock
                where budle.nomdt = giNumeroMandat)
    then do:
        ghProc = lancementPgm ("adblib/budle_crud.p", poCollectionHandlePgm).
        run deleteBudleSurMandat in ghProc(giNumeroMandat).
        if mError:erreur() then return.
    end.
    
    /* Ajout Sy le 18/03/2013 */
    if can-find(first garlodt no-lock   
                where garlodt.tpmdt = {&TYPECONTRAT-mandat2Gerance}  
                  and garlodt.nomdt = giNumeroMandat)
    then do:    
        ghProc = lancementPgm ("adblib/garlodt_CRUD.p", poCollectionHandlePgm).
        run deleteGarlodtSurMandat in ghProc({&TYPECONTRAT-mandat2Gerance} , giNumeroMandat).
        if mError:erreur() then return.
    end.  
        
    if gcTypeTrt <> "PURGE" 
    then do:
        /* On supprime la taxe sur bureau, si le mandant a un seul mandat avec la taxe on peut tout supprimer */
        if not can-find(first txbdt no-lock  
                        where txbdt.noman = giNumeroMandant
                          and txbdt.nomdt <> giNumeroMandat)
        then do:
            ghProc = lancementPgm ("adblib/txbdt_CRUD.p", poCollectionHandlePgm).
            run deleteTxbdtSurMandantMandat in ghProc(giNumeroMandant, giNumeroMandat).
            if mError:erreur() then return.
        end.
    end.
    else do:
        ghProc = lancementPgm ("adblib/txbdt_CRUD.p", poCollectionHandlePgm).
        run deleteTxbdtSurMandat in ghProc(giNumeroMandant, giNumeroMandat).
        if mError:erreur() then return.
    end.     
       
    if can-find(first abur1 no-lock
                where abur1.nomdt = giNumeroMandat)
    then do:
        ghProc = lancementPgm ("adblib/abur1_CRUD.p", poCollectionHandlePgm).
        run deleteAbur1tSurMandat in ghProc(giNumeroMandat).
        if mError:erreur() then return.
    end.  
   
    if can-find(first abur2 no-lock
                where abur2.nomdt = giNumeroMandat)
    then do:
        ghProc = lancementPgm ("adblib/abur2_CRUD.p", poCollectionHandlePgm).
        run deleteAbur2tSurMandat in ghProc(giNumeroMandat).
        if mError:erreur() then return.
    end.  
    
    /*== Suppression du paramétrage des acomptes propriétaires ==*/
    if can-find(first lotmd no-lock
                where lotmd.tpcon = {&TYPECONTRAT-mandat2Gerance}
                  and lotmd.nocon = giNumeroMandat)
    then do:
        ghProc = lancementPgm ("adblib/lotmd_CRUD.p", poCollectionHandlePgm).
        run deleteLotmdSurContrat in ghProc({&TYPECONTRAT-mandat2Gerance}, giNumeroMandat).
        if mError:erreur() then return.
    end.  
    
/*gga    
    /* Ajout SY le 13/04/2006 :  Suppression des Dossiers travaux et interventions */       
    for each trdos no-lock
       where trdos.tpcon = {&TYPECONTRAT-mandat2Gerance}
         and trdos.nocon = giNumeroMandat:
        ghProc = lancementPgm ("travaux/dossierTravaux/dossierTravaux.p", poCollectionHandlePgm).
        run appelSuppressionDossierTravaux in ghProc(trdos.tpcon, trdos.nocon, trdos.nodos, input-output poCollectionHandlePgm).
        if mError:erreur() then return.
    end.    
    
    for each inter no-lock
        where inter.tpcon = {&TYPECONTRAT-mandat2Gerance}
          and inter.nocon = giNumeroMandat:
        ghProc = lancementPgm ("adblib/supinter.p", poCollectionHandlePgm).
        run SupInter in ghProc(inter.tpcon, inter.nocon, inter.noint, input-output poCollectionHandlePgm).
        if mError:erreur() then return.
    end.                                        
gga*/

    /* Ajout SY le 13/04/2006 : Charges locatives, relevés d'eau, Imputations particulières  */
    if can-find(first perio no-lock
                where perio.tpctt = {&TYPECONTRAT-mandat2Gerance}  
                  and perio.nomdt = giNumeroMandat
                  and perio.noper = 0)
    then do:
        ghProc = lancementPgm ("adblib/perio_CRUD.p", poCollectionHandlePgm).
        run deletePeriodeCharge in ghProc({&TYPECONTRAT-mandat2Gerance}, giNumeroMandat, 0).
        if mError:erreur() then return.
    end.
    
    /* Ajout SY le 17/10/2005 : suppression bloc-notes */
    if ctrat.noblc > 0 
    then do:
        ghProc = lancementPgm ("note/notes_CRUD.p", poCollectionHandlePgm).
        run deleteNotesSurNoblc in ghProc(ctrat.noblc).
        if mError:erreur() then return.
    end.
    
    /** **/
    for each entip exclusive-lock
       where entip.nocon = giNumeroMandat:
        for each detip exclusive-lock
           where detip.nocon = entip.nocon
             and detip.dtimp = entip.dtimp:
            delete detip.
        end.
        delete entip.
    end.
    
    for each erlet exclusive-lock         
       where erlet.noimm = 10000 + giNumeroMandat:
        for each erldt exclusive-lock
           where erldt.norli = erlet.norli:
            delete erldt.
        end.                    
        delete erlet.
    end.
    
    /* Ajout SY le 07/04/2008 - fiche 0408/0033 : supprimer lien relevé d'eau - périodes de charges */
    if can-find(first lprtb no-lock
                where lprtb.tpcon = {&TYPECONTRAT-mandat2Gerance}
                  and lprtb.nocon = giNumeroMandat)
    then do:
        ghProc = lancementPgm ("adblib/lprtb_CRUD.p", poCollectionHandlePgm).
        run deleteLptrbSurContrat in ghProc({&TYPECONTRAT-mandat2Gerance}, giNumeroMandat).
        if mError:erreur() then return.
    end.  
    
    /* Ajout SY le 14/04/2006 : provisions quittancées */
    if can-find(first eprov no-lock
                where eprov.tpctt = {&TYPECONTRAT-mandat2Gerance}
                  and eprov.nomdt = giNumeroMandat)
    then do:
        ghProc = lancementPgm ("adblib/eprov_CRUD.p", poCollectionHandlePgm).
        run deleteEprovSurMandat in ghProc({&TYPECONTRAT-mandat2Gerance}, giNumeroMandat).
        if mError:erreur() then return.
    end.  
     
    /* regularisation des provisions */
    if can-find(first regul no-lock  
                where regul.nomdt = giNumeroMandat)
    then do:
        ghProc = lancementPgm ("adblib/regul_CRUD.p", poCollectionHandlePgm).
        run deleteRegulSurMandat in ghProc(giNumeroMandat).
        if mError:erreur() then return.
    end.  
    
    if can-find(first solps no-lock
                where solps.tpctt = {&TYPECONTRAT-mandat2Gerance} 
                  and solps.nomdt = giNumeroMandat)
    then do:
        ghProc = lancementPgm ("adblib/solps_CRUD.p", poCollectionHandlePgm).
        run deleteSolpsSurMandat in ghProc({&TYPECONTRAT-mandat2Gerance}, giNumeroMandat).
        if mError:erreur() then return.
    end.  
         
    /* Ajout sy le 05/09/2006 : détail charges locatives */
    if can-find(first chglo no-lock
                where chglo.tpmdt = {&TYPECONTRAT-mandat2Gerance}
                  and chglo.nomdt = giNumeroMandat)
    then do:
        ghProc = lancementPgm ("adblib/chglo_CRUD.p", poCollectionHandlePgm).
        run deleteChgloSurMandat in ghProc({&TYPECONTRAT-mandat2Gerance}, giNumeroMandat).
        if mError:erreur() then return.
    end.
     
    /* Ajout SY le 13/04/2006 : accords de reglement  */
    if can-find(first acreg no-lock
                where acreg.tpmdt = {&TYPECONTRAT-mandat2Gerance}
                  and acreg.nomdt = giNumeroMandat)
    then do:
        ghProc = lancementPgm ("adblib/acreg_CRUD.p", poCollectionHandlePgm).
        run deleteAcregSurMandat in ghProc({&TYPECONTRAT-mandat2Gerance}, giNumeroMandat).
        if mError:erreur() then return.
    end.
    
    /* Ajout SY le 13/04/2006 : charges locatives : association rub-cle  */
    if can-find(first assrc no-lock
                where assrc.nomdt = giNumeroMandat)
    then do:
        ghProc = lancementPgm ("adblib/assrc_CRUD.p", poCollectionHandlePgm).
        run deleteAssrcSurMandat in ghProc(giNumeroMandat).
        if mError:erreur() then return.
    end.
    
    /* PAIE : etabl ... A VOIR : Article pour Site Central ...*/
    if can-find(first etabl no-lock
                where etabl.tpcon = {&TYPECONTRAT-mandat2Gerance}
                  and etabl.nocon = giNumeroMandat)
    then do:
        ghProc = lancementPgm ("adblib/etabl_CRUD.p", poCollectionHandlePgm).
        run deleteEtablSurContrat in ghProc({&TYPECONTRAT-mandat2Gerance}, giNumeroMandat).
        if mError:erreur() then return.
    end.
    
    /* Credit Lyonnais : avantages en nature */
    if can-find(first avnad no-lock
                where avnad.nomdt = giNumeroMandat)
    then do:
        ghProc = lancementPgm ("adblib/avnad_CRUD.p", poCollectionHandlePgm).
        run deleteAvnadSurMandat in ghProc(giNumeroMandat).
        if mError:erreur() then return.
    end.
    
    /* IRF */   
    if can-find(first etxdt no-lock
                where etxdt.notrx = giNumeroMandat)
    then do:
        ghProc = lancementPgm ("adblib/etxdt_CRUD.p", poCollectionHandlePgm).
        run deleteEtxdtSurContratTravaux in ghProc(giNumeroMandat).
        if mError:erreur() then return.
    end.
     
    /* acomptes */
    if can-find(first aecha no-lock
                where aecha.soc-cd = giRefGerance
                  and aecha.etab-cd = giNumeroMandat)
    then do:
        ghProc = lancementPgm ("adblib/aecha_CRUD.p", poCollectionHandlePgm).
        run deleteAechaSurMandat in ghProc(giRefGerance, giNumeroMandat).
        if mError:erreur() then return.
    end.
    
    if can-find(first acpte no-lock
                where acpte.tpcon = {&TYPECONTRAT-mandat2Gerance}
                  and acpte.nocon = giNumeroMandat)
    then do:
        ghProc = lancementPgm ("adblib/acpte_CRUD.p", poCollectionHandlePgm).
        run deleteAcpteSurContrat in ghProc({&TYPECONTRAT-mandat2Gerance}, giNumeroMandat).
        if mError:erreur() then return.
    end.
         
    /* Honoraires */
    if can-find(first ifdhono no-lock
                where ifdhono.soc-cd  = giRefGerance
                  and ifdhono.etab-cd = giNumeroMandat)
    then do:
        ghProc = lancementPgm ("adblib/ifdhono_CRUD.p", poCollectionHandlePgm).
        run deleteIfdhonoSurEtablissement in ghProc(giRefGerance, giNumeroMandat).
        if mError:erreur() then return.
    end.
     
    if can-find(first qipay no-lock 
                where qipay.tpmdt = {&TYPECONTRAT-mandat2Gerance}
                  and qipay.nomdt = giNumeroMandat)
    then do:
        ghProc = lancementPgm ("adblib/qipay_CRUD.p", poCollectionHandlePgm).
        run deleteQipaySurMandat in ghProc({&TYPECONTRAT-mandat2Gerance}, giNumeroMandat).
        if mError:erreur() then return.
    end.
    
    if can-find(first ratlo no-lock
                where ratlo.tpmdt = {&TYPECONTRAT-mandat2Gerance}
                  and ratlo.nomdt = giNumeroMandat)
    then do:
        ghProc = lancementPgm ("adblib/ratlo_CRUD.p", poCollectionHandlePgm).
        run deleteRatloSurMandat in ghProc({&TYPECONTRAT-mandat2Gerance}, giNumeroMandat).
        if mError:erreur() then return.
    end.
    
    /* SY 1214/0052 */
    if can-find(first compenslot no-lock
                where compenslot.tpct2 = {&TYPECONTRAT-mandat2Gerance}
                  and compenslot.noct2 = giNumeroMandat)
    then do:
        ghProc = lancementPgm ("adblib/compenslot_CRUD.p", poCollectionHandlePgm).
        run deleteCompenslotSurContrat2 in ghProc({&TYPECONTRAT-mandat2Gerance}, giNumeroMandat).
        if mError:erreur() then return.
    end.
          
    /* Transferts */
    if can-find(first trfpm no-lock
                where trfpm.nomdt = giNumeroMandat)
    then do:
        ghProc = lancementPgm ("adblib/trfpm_CRUD.p", poCollectionHandlePgm).
        run deleteTrfpmSurMandat in ghProc(giNumeroMandat).
        if mError:erreur() then return.
    end.
     
    if can-find(first trfev no-lock
                where trfev.nomdt = giNumeroMandat)
    then do:
        ghProc = lancementPgm ("adblib/trfev_CRUD.p", poCollectionHandlePgm).
        run deleteTrfevSurMandat in ghProc(giNumeroMandat).
        if mError:erreur() then return.
    end.
    
    if can-find(first trftx no-lock
                where trftx.nomdt = giNumeroMandat)
    then do:
        ghProc = lancementPgm ("adblib/trftx_CRUD.p", poCollectionHandlePgm).
        run deleteTrftxSurMandat in ghProc(giNumeroMandat).
        if mError:erreur() then return.
    end.
    
    if can-find(first txqtt no-lock
                where txqtt.nomdt = giNumeroMandat)
    then do:
        ghProc = lancementPgm ("adblib/txqtt_CRUD.p", poCollectionHandlePgm).
        run deleteTxqttSurMandat in ghProc(giNumeroMandat).
        if mError:erreur() then return.
    end.
    
    /* Ajout SY le 13/04/2006 : toutes les tables même plus utilisées */
    if can-find(first abail no-lock
                where abail.nomdt = giNumeroMandat)
    then do:
        ghProc = lancementPgm ("adblib/abail_CRUD.p", poCollectionHandlePgm).
        run deleteAbailSurMandat in ghProc(giNumeroMandat).
        if mError:erreur() then return.
    end.
    
    if can-find(first ebail no-lock
                where ebail.nomdt = giNumeroMandat)
    then do:
        ghProc = lancementPgm ("adblib/ebail_CRUD.p", poCollectionHandlePgm).
        run deleteEbailSurMandat in ghProc(giNumeroMandat).
        if mError:erreur() then return.
    end.
    
    if can-find(first adas2 no-lock
                where adas2.nomdt = giNumeroMandat)
    then do:
        ghProc = lancementPgm ("adblib/adas2_CRUD.p", poCollectionHandlePgm).
        run deleteAdas2SurMandat in ghProc(giNumeroMandat).
        if mError:erreur() then return.
    end.
    
    if can-find(first adpga no-lock
                where adpga.nomdt = giNumeroMandat)
    then do:
        ghProc = lancementPgm ("adblib/adpga_CRUD.p", poCollectionHandlePgm).
        run deleteAdpgaSurMandat in ghProc(giNumeroMandat).
        if mError:erreur() then return.
    end.
    
    if can-find(first ahon2 no-lock
                where ahon2.nomdt = giNumeroMandat)
    then do:
        ghProc = lancementPgm ("adblib/ahon2_CRUD.p", poCollectionHandlePgm).
        run deleteAhon2SurMandat in ghProc(giNumeroMandat).
        if mError:erreur() then return.
    end.
    
    if can-find(first ahono no-lock
                where ahono.nomdt = giNumeroMandat)
    then do:
        ghProc = lancementPgm ("adblib/ahono_CRUD.p", poCollectionHandlePgm).
        run deleteAhonoSurMandat in ghProc(giNumeroMandat).
        if mError:erreur() then return.
    end.
    
    if can-find(first airf2 no-lock
                where airf2.nomdt = giNumeroMandat)
    then do:
        ghProc = lancementPgm ("adblib/airf2_CRUD.p", poCollectionHandlePgm).
        run deleteAirf2SurMandat in ghProc(giNumeroMandat).
        if mError:erreur() then return.
    end.
    
    if can-find(first aisf2 no-lock
                where aisf2.nomdt = giNumeroMandat)
    then do:
        ghProc = lancementPgm ("adblib/aisf2_CRUD.p", poCollectionHandlePgm).
        run deleteAisf2SurMandat in ghProc(giNumeroMandat).
        if mError:erreur() then return.
    end.

    if can-find(first prest no-lock
                where prest.nomdt = giNumeroMandat)
    then do:
        ghProc = lancementPgm ("adblib/prest_CRUD.p", poCollectionHandlePgm).
        run deletePrestSurMandat in ghProc(giNumeroMandat).
        if mError:erreur() then return.
    end.    
    
    /*--> Delete des quittances */    
    if can-find(first equit no-lock
                where equit.nomdt = giNumeroMandat)
    then do:
        ghProc = lancementPgm ("bail/quittancement/equit_CRUD.p", poCollectionHandlePgm).
        run deleteEquitSurMandat in ghProc(giNumeroMandat).
        if mError:erreur() then return.
    end. 
    
    /*--> Delete des factures d'entree locataire : GESTION */
    if can-find(first aquit no-lock
                where aquit.nomdt = giNumeroMandat)
    then do:
        ghProc = lancementPgm ("adblib/aquit_CRUD.p", poCollectionHandlePgm).
        run deleteAquitSurMandat in ghProc(giNumeroMandat).
        if mError:erreur() then return.
    end.

    /* 14/10/2003 : suppression du contrat */
    empty temp-table ttCtrat.
    create ttCtrat.
    assign
        ttCtrat.tpcon       = ctrat.tpcon 
        ttCtrat.nocon       = ctrat.nocon
        ttCtrat.CRUD        = "D"
        ttCtrat.dtTimestamp = datetime(ctrat.dtmsy, ctrat.hemsy)
        ttCtrat.rRowid      = rowid(ctrat)
        ghProc              = lancementPgm ("adblib/ctrat_CRUD.p", poCollectionHandlePgm)
    .
    run setCtrat in ghProc(table ttCtrat by-reference).
    if mError:erreur() then return.
    
    /*== Mise à jour des sequences ==*/
    ghProc = lancementPgm ("adblib/majseq.p", poCollectionHandlePgm).
    run lanceMajseq in ghProc.
    if mError:erreur() then return.
    
    /* Suppression d'une éventuelle trace dans les purges de pec erronées */
    for each pclie no-lock
       where pclie.tppar = "PECEC"
         and pclie.zon01 = {&TYPECONTRAT-mandat2Gerance}
         and pclie.int01 = giNumeroMandat
         and pclie.fgact = string(true):
        create ttPclie.
        assign
            ttPclie.tppar       = pclie.tppar
            ttPclie.zon01       = pclie.zon01
            ttPclie.dtTimestamp = datetime(pclie.dtmsy, pclie.hemsy) 
            ttPclie.rRowid      = rowid(pclie) 
        .     
        if gcTypeTrt begins "PURGE"                       /* SY 10/11/2017 */
        then assign
                 ttPclie.CRUD  = "D"
        .
        else assign
                 ttPclie.CRUD  = "U"
                 ttPclie.fgact = string(false)
        .        
    end.
    /* suppression mémoire dernier mandat */
    for each pclie no-lock
       where pclie.tppar          = "MEMID"
         and pclie.zon02          = {&TYPECONTRAT-mandat2Gerance}
         and integer(pclie.zon03) = giNumeroMandat:
        delete pclie.
        create ttPclie.
        assign
            ttPclie.tppar       = pclie.tppar
            ttPclie.zon01       = pclie.zon01
            ttPclie.CRUD        = "D"
            ttPclie.dtTimestamp = datetime(pclie.dtmsy, pclie.hemsy) 
            ttPclie.rRowid      = rowid(pclie) 
        .     
    end.
    for each pclie no-lock
       where pclie.tppar = "MEMID"
         and pclie.zon02 = "00022"
         and integer(pclie.zon03) = giNumeroMandat:
        create ttPclie.
        assign
            ttPclie.tppar       = pclie.tppar
            ttPclie.zon01       = pclie.zon01
            ttPclie.CRUD        = "D"
            ttPclie.dtTimestamp = datetime(pclie.dtmsy, pclie.hemsy) 
            ttPclie.rRowid      = rowid(pclie) 
        .     
    end.
    if can-find(first ttPclie) then do:
        ghProc = lancementPgm ("adblib/pclie_CRUD.p", poCollectionHandlePgm).
        run setPclie in ghProc(table ttPclie by-reference).
        if mError:erreur() then return.
    end.

    /* renou, rev , entrée ...*/    
    if can-find(first afair no-lock
                where afair.nomdt = giNumeroMandat)
    then do:
        ghProc = lancementPgm ("adblib/afair_CRUD.p", poCollectionHandlePgm).
        run deleteAfairSurMandat in ghProc(giNumeroMandat).
        if mError:erreur() then return.
    end.
    
    /*--> Evenementiel */
    ghProc = lancementPgm ("evenementiel/supEvenementiel.p", poCollectionHandlePgm).
    run SupEvenementiel in ghProc({&TYPECONTRAT-mandat2Gerance}, giNumeroMandat, input-output poCollectionHandlePgm).
    if mError:erreur() then return.
    
    /* PNO */   
    if can-find (first aspno no-lock  
                 where aspno.tpcon = {&TYPECONTRAT-mandat2Gerance}
                   and aspno.nocon = giNumeroMandat)
    then do:
        ghProc = lancementPgm ("adblib/aspno_CRUD.p", poCollectionHandlePgm).
        run deleteAspnoSurContrat in ghProc({&TYPECONTRAT-mandat2Gerance}, giNumeroMandat).
        if mError:erreur() then return.
    end.
    
end procedure.
