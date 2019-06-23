/*------------------------------------------------------------------------
File        : tacheLoiDefiscalisationIRF.p
Purpose     : tache loi defiscalisation IRF 
Author(s)   : GGA - 2018/01/11
Notes       : a partir de adb/tach/prmobirf.p, adb/tach/prmmtbes.p
derniere revue: 2018/04/09 - phm.
------------------------------------------------------------------------*/
{preprocesseur/type2tache.i}
{preprocesseur/type2contrat.i}
{preprocesseur/type2role.i}
{preprocesseur/type2bien.i}

using parametre.syspr.syspr.

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{application/include/glbsepar.i}
{adblib/include/etxdt.i}
{tache/include/tacheLoiDefiscalisationIRF.i}
{application/include/combo.i}
{adb/include/ttPerissolBesson.i}
{application/include/error.i}

function contratConstruction return int64 private(piNumeroImmeuble as integer):
    /*------------------------------------------------------------------------------
    Purpose: recherche contrat construction immeuble
    Notes  : 
    ------------------------------------------------------------------------------*/
    define buffer intnt for intnt.
    for first intnt no-lock
        where intnt.tpcon = {&TYPECONTRAT-construction}
          and intnt.nocon = piNumeroImmeuble
          and intnt.tpidt = {&TYPEBIEN-immeuble}:
        return intnt.noidt.
    end.
    return ?.
end function.

function numeroImmeuble return int64 private(piNumeroMandat as int64, pcTypeMandat as character):
    /*------------------------------------------------------------------------------
    Purpose: recherche immeuble du mandat
    Notes  : 
    ------------------------------------------------------------------------------*/
    define buffer intnt for intnt.
    for first intnt no-lock
        where intnt.tpcon = pcTypeMandat
          and intnt.nocon = piNumeroMandat
          and intnt.tpidt = {&TYPEBIEN-immeuble}:
        return intnt.noidt.
    end.
    mError:createErrorGestion({&error}, 106470, string(piNumeroMandat)). //immeuble non trouve pour mandat %1
    return 0.
end function.

function numeroInterneLot return int64 private(piNumeroLot as int64, piNumeroImmeuble as int64):
    /*------------------------------------------------------------------------------
    Purpose: recherche contrat construction immeuble
    Notes  : 
    ------------------------------------------------------------------------------*/
    define buffer local for local.
    for first local no-lock
        where local.noimm = piNumeroImmeuble
          and local.nolot = piNumeroLot:
        return local.noloc.
    end.
    mError:createError({&error}, "lot inexistant dans immeuble"). //lot inexistant dans immeuble   
    return 0.
end function.

procedure getLoiDefiscalisationIRF:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe (beMandatGerance.cls)
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat as int64     no-undo.
    define input parameter pcTypeMandat   as character no-undo.
    define output parameter table for ttListeLotLoiDefiscalisationIRF.
    define output parameter table for ttDetailLotLoiDefiscalisationIRF.
  
    define variable viNumeroImmeuble as int64 no-undo.
    define variable viNumeroContratConstruction as int64 no-undo.

    define buffer etxdt for etxdt.
    define buffer local for local.
  
    empty temp-table ttListeLotLoiDefiscalisationIRF.
    empty temp-table ttDetailLotLoiDefiscalisationIRF.
    run ctrlMicroFoncier (piNumeroMandat, pcTypeMandat).
    if mError:erreur() = yes then return.   
    viNumeroImmeuble = numeroImmeuble (piNumeroMandat, pcTypeMandat).
    if mError:erreur() = yes then return.   
    viNumeroContratConstruction = contratConstruction (viNumeroImmeuble).
    for each etxdt no-lock
       where etxdt.notrx = piNumeroMandat
         and etxdt.tpapp = "00000"
    , first local no-lock
      where local.noloc = etxdt.nolot:
        create ttListeLotLoiDefiscalisationIRF.
        assign   
            ttListeLotLoiDefiscalisationIRF.iNumeroContrat       = etxdt.notrx 
            ttListeLotLoiDefiscalisationIRF.iNumeroLot           = local.nolot
            ttListeLotLoiDefiscalisationIRF.daDebut              = if num-entries(etxdt.lbdiv2,"@") >= 1 then date(entry(1, etxdt.lbdiv2, "@")) else ?
            ttListeLotLoiDefiscalisationIRF.daVente              = if num-entries(etxdt.lbdiv2,"@") >= 2 then date(entry(2, etxdt.lbdiv2, "@")) else ?
            ttListeLotLoiDefiscalisationIRF.daFinApplication     = if num-entries(etxdt.lbdiv2,"@") >= 3 then date(entry(3, etxdt.lbdiv2, "@")) else ?
            ttListeLotLoiDefiscalisationIRF.daAchat              = if num-entries(etxdt.lbdiv2,"@") >= 4 then date(entry(4, etxdt.lbdiv2, "@")) else ?
            ttListeLotLoiDefiscalisationIRF.daAchevement         = if num-entries(etxdt.lbdiv2,"@") >= 5 then date(entry(5, etxdt.lbdiv2, "@")) else ?
            ttListeLotLoiDefiscalisationIRF.daFinTravaux         = if num-entries(etxdt.lbdiv2,"@") >= 6 then date(entry(6, etxdt.lbdiv2, "@")) else ?
            ttListeLotLoiDefiscalisationIRF.cLoi                 = etxdt.lbdiv3
            ttListeLotLoiDefiscalisationIRF.cLibelleLoi          = outilTraduction:getLibelleParam ("CDLOI", etxdt.lbdiv3)
            ttListeLotLoiDefiscalisationIRF.cNatureLot           = local.ntlot
            ttListeLotLoiDefiscalisationIRF.cLibelleNatureLot    = outilTraduction:getLibelleParam ("NTLOT", local.ntlot)
            ttListeLotLoiDefiscalisationIRF.iDuree               = etxdt.vltan
            ttListeLotLoiDefiscalisationIRF.iDureeSupplementaire = etxdt.txsou  
            ttListeLotLoiDefiscalisationIRF.dMontantAchat        = etxdt.mtlot
            ttListeLotLoiDefiscalisationIRF.dMontantTravaux      = etxdt.ttlot
            ttListeLotLoiDefiscalisationIRF.dtTimestamp          = datetime(etxdt.dtmsy, etxdt.hemsy)
            ttListeLotLoiDefiscalisationIRF.CRUD                 = 'R'
            ttListeLotLoiDefiscalisationIRF.rRowid               = rowid(etxdt)            
        .
    end.
    for each etxdt no-lock
        where etxdt.notrx = piNumeroMandat
        and etxdt.tpapp <> "00000"
    , first local no-lock
      where local.noloc = etxdt.nolot:        
        create ttDetailLotLoiDefiscalisationIRF.
        assign    
            ttDetailLotLoiDefiscalisationIRF.iNumeroContrat    = etxdt.notrx                         
            ttDetailLotLoiDefiscalisationIRF.iNumeroLot        = local.nolot
            ttDetailLotLoiDefiscalisationIRF.iNumeroAppel      = etxdt.noapp
            ttDetailLotLoiDefiscalisationIRF.NoTmp             = etxdt.noapp
            ttDetailLotLoiDefiscalisationIRF.cTypeFrais        = etxdt.tpapp
            ttDetailLotLoiDefiscalisationIRF.daDateFrais       = date(entry(1, etxdt.lbdiv2, "@"))
            ttDetailLotLoiDefiscalisationIRF.cLibelleFrais     = etxdt.lbdiv
            ttDetailLotLoiDefiscalisationIRF.cLibelleTypeFrais = outilTraduction:getLibelleParam ("CDTRX", etxdt.tpapp)
            ttDetailLotLoiDefiscalisationIRF.dMontantFrais     = etxdt.mtlot
            ttDetailLotLoiDefiscalisationIRF.dtTimestamp       = datetime(etxdt.dtmsy, etxdt.hemsy)
            ttDetailLotLoiDefiscalisationIRF.CRUD              = 'R'
            ttDetailLotLoiDefiscalisationIRF.rRowid            = rowid(etxdt)                            
        .
    end.
    for first ttListeLotLoiDefiscalisationIRF
        where lookup(ttListeLotLoiDefiscalisationIRF.cLoi, "00004,00007") > 0:
          mError:createError({&information}, 1000438).        //Attention les lois de finance 'SCI' et 'Robien Social' ne sont plus valides
    end.                            
         
end procedure.

procedure setLoiDefiscalisationIRF:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe (beMandatGerance.cls)
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeMandat as character no-undo.
    define input parameter table for ttListeLotLoiDefiscalisationIRF.
    define input parameter table for ttDetailLotLoiDefiscalisationIRF.
    define input parameter table for ttError.
 
    define variable viNumeroMandat as int64 no-undo.  
    define variable viNumeroImmeuble as int64 no-undo.
    define variable viNumeroContratConstruction as int64 no-undo.

    find first ttListeLotLoiDefiscalisationIRF where lookup(ttListeLotLoiDefiscalisationIRF.CRUD, "C,U,D") > 0 no-error.
    find first ttDetailLotLoiDefiscalisationIRF where lookup(ttDetailLotLoiDefiscalisationIRF.CRUD, "C,U,D") > 0 no-error.
    if not available ttListeLotLoiDefiscalisationIRF
    and not available ttDetailLotLoiDefiscalisationIRF
    then return.
    if available ttListeLotLoiDefiscalisationIRF
    then viNumeroMandat = ttListeLotLoiDefiscalisationIRF.iNumerocontrat.
    else viNumeroMandat = ttDetailLotLoiDefiscalisationIRF.iNumerocontrat.   
 
    run ctrlMicroFoncier (viNumeroMandat, pcTypeMandat).
    if mError:erreur() = yes then return.   
    viNumeroImmeuble = numeroImmeuble (viNumeroMandat, pcTypeMandat).
    if mError:erreur() = yes then return.   
    viNumeroContratConstruction = contratConstruction (viNumeroImmeuble).
    run ctrlSaisie (pcTypeMandat, viNumeroImmeuble).
    if mError:erreur() = yes then return.   
    if can-find (first ttEtxdt) then run majLoi (viNumeroMandat).
   
end procedure.

procedure ctrlMicroFoncier private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : 
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat as int64     no-undo.
    define input parameter pcTypeMandat   as character no-undo.

    define variable vlMicroFoncier as logical no-undo.

    define buffer ctrat for ctrat. 
    define buffer tache for tache. 

    find first ctrat no-lock
         where ctrat.tpcon = pcTypeMandat
           and ctrat.nocon = piNumeroMandat no-error.
    if not available ctrat       
    then do:
        mError:createError({&error}, 100057).
        return.
    end.
    find last tache no-lock
        where tache.tpcon = pcTypeMandat
          and tache.nocon = piNumeroMandat
          and tache.tptac = {&TYPETACHE-ImpotRevenusFonciers} no-error.
    if not available tache
    then do:
        mError:createError({&error}, 1000437).             //la tache 'Impot Revenu Foncier' n'existe pas
        return.
    end.
    if tache.pdreg = "00001"                               //micro foncier = oui
    then vlMicroFoncier = yes.
    else do:    
        boucleRechercheMandatMicroFoncier:                 //boucle sur autre mandat du mandant pour voir si un mandat avec micro foncier  
        for each intnt no-lock  
           where intnt.tpcon = {&TYPECONTRAT-mandat2Gerance}
             and intnt.nocon <> piNumeroMandat
             and intnt.tpidt = {&TYPEROLE-mandant}
             and intnt.noidt = ctrat.norol
        , last tache no-lock
          where tache.tpcon = intnt.tpcon
            and tache.nocon = intnt.nocon
            and tache.tptac = {&TYPETACHE-ImpotRevenusFonciers}:
            if tache.pdreg = "00001"                               //micro foncier = oui
            then do:
                vlMicroFoncier = yes.
                leave boucleRechercheMandatMicroFoncier.
            end. 
        end.
    end.
    if vlMicroFoncier = yes 
    then do:
        mError:createError({&error}, 109084).
        return.
    end.
        
end procedure.

procedure ctrlSaisie private:
    /*------------------------------------------------------------------------------
    Purpose: a partir de adb/tach/prmmtbes.p procedure ValTbTmp 
    Notes  : 
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeMandat as character no-undo.
    define input parameter piNumeroImmeuble as int64 no-undo.
    
    define variable vcLstScellier as character no-undo init "00013,00014,00015,00016,00017,00018".
    define variable viNumeroInterneLot as int64 no-undo.

    empty temp-table ttEtxdt. 
    for each ttListeLotLoiDefiscalisationIRF
       where lookup(ttListeLotLoiDefiscalisationIRF.CRUD, "C,U,D") > 0:
        viNumeroInterneLot = numeroInterneLot (ttListeLotLoiDefiscalisationIRF.iNumeroLot, piNumeroImmeuble).
        if mError:erreur() = yes then return.
        if ttListeLotLoiDefiscalisationIRF.cLoi <> "00005"                 //Date d'Achat obligatoire sauf pour Lienemann
        and ttListeLotLoiDefiscalisationIRF.daDebutApplication = ?
        then do:
            mError:createError({&error}, 1000695).                 //Date d'Achat obligatoire sauf pour Lienemann
            return.    
        end.         
        if ttListeLotLoiDefiscalisationIRF.cLoi = "00010"                  //Prix d'Achat obligatoire pour loi Robien Recentré et Recentré ZRR
        and (ttListeLotLoiDefiscalisationIRF.dMontantAchat = 0 or ttListeLotLoiDefiscalisationIRF.dMontantAchat = ?) 
        then do:
            mError:createError({&error}, 1000696).               //Prix d'Achat obligatoire pour loi Robien Recentré et Recentré ZRR
            return.    
        end.         
        if lookup(ttListeLotLoiDefiscalisationIRF.cLoi, vcLstScellier) > 0
        and year(ttListeLotLoiDefiscalisationIRF.daAchat) < 2009 
        then do:
            mError:createError({&information}, 1000439). //L'année d'achat étant antérieure à 2009, aucune réduction d'impôt ne s'appliquera sur ce lot
        end.   
        //date de vente > date debut application, remise a blanc date vente
        if ttListeLotLoiDefiscalisationIRF.daVente > ttListeLotLoiDefiscalisationIRF.daDebutApplication
        then ttListeLotLoiDefiscalisationIRF.daVente = ?.          
        create ttEtxdt.
        assign 
            ttEtxdt.notrx       = ttListeLotLoiDefiscalisationIRF.iNumeroContrat
            ttEtxdt.tpapp       = "00000"
            ttEtxdt.noapp       = 0
            ttEtxdt.nolot       = viNumeroInterneLot
            ttEtxdt.norol       = 0
            ttEtxdt.lbdiv3      = ttListeLotLoiDefiscalisationIRF.cLoi 
            ttEtxdt.vltan       = ttListeLotLoiDefiscalisationIRF.iDuree                
            ttEtxdt.txsou       = ttListeLotLoiDefiscalisationIRF.iDureeSupplementaire    
            ttEtxdt.mtlot       = ttListeLotLoiDefiscalisationIRF.dMontantAchat         
            ttEtxdt.ttlot       = ttListeLotLoiDefiscalisationIRF.dMontantTravaux       
            ttEtxdt.lbdiv2      = substitute("&1@&2@&3@&4@&5@&6", 
                                      if ttListeLotLoiDefiscalisationIRF.daDebut          = ? then "" else string(ttListeLotLoiDefiscalisationIRF.daDebut,"99/99/9999"),
                                      if ttListeLotLoiDefiscalisationIRF.daVente          = ? then "" else string(ttListeLotLoiDefiscalisationIRF.daVente,"99/99/9999"),
                                      if ttListeLotLoiDefiscalisationIRF.daFinApplication = ? then "" else string(ttListeLotLoiDefiscalisationIRF.daFinApplication,"99/99/9999"),
                                      if ttListeLotLoiDefiscalisationIRF.daAchat          = ? then "" else string(ttListeLotLoiDefiscalisationIRF.daAchat,"99/99/9999"),
                                      if ttListeLotLoiDefiscalisationIRF.daAchevement     = ? then "" else string(ttListeLotLoiDefiscalisationIRF.daAchevement,"99/99/9999"),
                                      if ttListeLotLoiDefiscalisationIRF.daFinTravaux     = ? then "" else string(ttListeLotLoiDefiscalisationIRF.daFinTravaux,"99/99/9999"))
            ttEtxdt.CRUD        = ttListeLotLoiDefiscalisationIRF.CRUD 
            ttEtxdt.dtTimestamp = ttListeLotLoiDefiscalisationIRF.dtTimestamp
            ttEtxdt.rRowid      = ttListeLotLoiDefiscalisationIRF.rRowid
        .
    end.
    for each ttDetailLotLoiDefiscalisationIRF
       where lookup(ttDetailLotLoiDefiscalisationIRF.CRUD, "C,U,D") > 0:
        viNumeroInterneLot = numeroInterneLot (ttDetailLotLoiDefiscalisationIRF.iNumeroLot, piNumeroImmeuble).
        if ttDetailLotLoiDefiscalisationIRF.cTypeFrais = ?
        then do:
            mError:createError({&error}, 1000697).        //type de frais obligatoire  
            return.
        end.
        if ttDetailLotLoiDefiscalisationIRF.dMontantFrais = 0 or ttDetailLotLoiDefiscalisationIRF.dMontantFrais = ? 
        then do:
            mError:createError({&error}, 1000698).          //montant frais obligatoire
            return.
        end.
        if ttDetailLotLoiDefiscalisationIRF.daDateFrais = ? 
        then do:
            mError:createError({&error}, 1000699).      //date frais obligatoire            
            return.
        end.
        create ttEtxdt.
        assign 
            ttEtxdt.notrx       = ttDetailLotLoiDefiscalisationIRF.iNumeroContrat
            ttEtxdt.tpapp       = ttDetailLotLoiDefiscalisationIRF.cTypeFrais
            ttEtxdt.noapp       = ttDetailLotLoiDefiscalisationIRF.iNumeroAppel
            ttEtxdt.nolot       = viNumeroInterneLot
            ttEtxdt.norol       = 0
            ttEtxdt.mtlot       = ttDetailLotLoiDefiscalisationIRF.dMontantFrais
            ttEtxdt.lbdiv       = ttDetailLotLoiDefiscalisationIRF.cLibelleFrais  
            ttEtxdt.lbdiv2      = string(ttDetailLotLoiDefiscalisationIRF.daDateFrais) 
            ttEtxdt.CRUD        = ttDetailLotLoiDefiscalisationIRF.CRUD 
            ttEtxdt.dtTimestamp = ttDetailLotLoiDefiscalisationIRF.dtTimestamp
            ttEtxdt.rRowid      = ttDetailLotLoiDefiscalisationIRF.rRowid
        .        
    end.
    
end procedure.

procedure majLoi private:
    /*------------------------------------------------------------------------------
    Purpose: a partir de adb/tach/prmmtbes.p procedure ValTableau
    Notes  : 
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat as int64 no-undo.  
    
    define variable vhEtxdt               as handle  no-undo.
    define variable vhExttbbes            as handle  no-undo.
    define variable vdTotalAmmortissement as decimal no-undo.
    define variable viMoisFinIrf          as integer no-undo.
 
    run adblib/etxdt_CRUD.p persistent set vhEtxdt.
    run getTokenInstance in vhEtxdt(mToken:JSessionId).        
    run setEtxdt in vhEtxdt (table ttEtxdt by-reference).
    run destroy in vhEtxdt.    
    if mError:erreur() = yes then return.         

//gga todo voir sylvie pour l'importance de la question car les montants ne sont pluis mis a jour mais seulement cexmlnana.doss-num
//si important voir comment faire si plusieurs code loi (dans ce cas il faut une question par code loi) et le positionner le code plutot dans la procedure de controle 
    /*--> On vérifie si le montant de l'amortissement est différent que la préparation comptable pour IRF */
    run adb/exttbbes.p persistent set vhExttbbes.
    run getTokenInstance in vhExttbbes(mToken:JSessionId).        
    run getTabPerissolBesson in vhExttbbes (piNumeroMandat, piNumeroMandat, year(today), year(today), output table ttPerissolBesson by-reference).
    run destroy in vhExttbbes.   
    find first aparm no-lock
         where aparm.tppar = "IRF"
           and aparm.cdpar = "DATEFIN" no-error.
    viMoisFinIrf = if available aparm then aparm.zone1 else 5.
    for each ttPerissolBesson
    break by ttPerissolBesson.cCdLoi:
        if first-of(ttPerissolBesson.cCdLoi)
        then vdTotalAmmortissement = 0.      
        vdTotalAmmortissement = vdTotalAmmortissement + ttPerissolBesson.dMtDec.
        if last-of(ttPerissolBesson.cCdLoi)
        then do:
            for first cexmlnana exclusive-lock
                where cexmlnana.soc-cd = integer(mToken:cRefGerance)
                  and cexmlnana.etab-cd = piNumeroMandat
                  and cexmlnana.ana1-cd = "100"
                  and cexmlnana.ana2-cd = "781"
                  and cexmlnana.dacompta >= date(01,01,if month(today) <= viMoisFinIrf then year(today) - 1 else year(today))
                  and cexmlnana.dacompta <= date(12,31,if month(today) <= viMoisFinIrf then year(today) - 1 else year(today))
                  and cexmlnana.report-cd = integer(ttPerissolBesson.cCdLoi) 
                  and cexmlnana.mt <> 0:
                /*--> Total Loi Besson / Perrissol */
                if vdTotalAmmortissement <> cexmlnana.mt 
                then do:
                    //Le montant de l'amortissement de la loi &1 est différent de celui de votre Etat Préparatoire IRF &2 ==> &3. Souhaitez-vous mettre à jour ce montant ?                    
                    if outils:questionnaire (1000700, 
                                             substitute('&2&1&3&1&4', 
                                                        separ[1], 
                                                        outilTraduction:getLibelleParam ("CDLOI", ttPerissolBesson.cCdLoi), 
                                                        cexmlnana.mt, 
                                                        vdTotalAmmortissement),
                                             table ttError by-reference) = 3
                    then cexmlnana.doss-num = "".   
                end.
            end.
        end.
    end.        

end procedure.

procedure initComboLoiDefiscalisationIRF:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcCodeLoi as character no-undo.
    define output parameter table for ttCombo.

    define variable voSyspr as class syspr no-undo.
 
    empty temp-table ttCombo.
    voSyspr = new syspr().    
    if pcCodeLoi <> ? 
    then do:
        if lookup(pcCodeLoi, "00010,00011,00002,00006,00008,00009,00023,00024") > 0
        then do:
            voSyspr:creationttCombo("DUREE", "9", "", output table ttCombo by-reference).
            if lookup(pcCodeLoi, "00002,00006,00008,00009,00023,00024") > 0
            then do:    
                voSyspr:creationttCombo("DUREE", "12", "", output table ttCombo by-reference).
                voSyspr:creationttCombo("DUREE", "15", "", output table ttCombo by-reference).
            end.
        end.
    end.
    else do:
        voSyspr:getComboParametre("CDLOI", "LOI", output table ttCombo by-reference).
        voSyspr:getComboParametre("CDTRX", "TYPEFRAIS", output table ttCombo by-reference).
        for first ttCombo
            where ttCombo.cNomCombo = "TYPEFRAIS"
              and ttCombo.cCode     = "00000":
            delete ttCombo.
        end.
    end.
    delete object voSyspr.
    
end procedure.
