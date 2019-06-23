/*------------------------------------------------------------------------
File        : periodeChargeLocative.p
Purpose     : tache charges locatives et prestations  
Author(s)   : GGA - 2017/12/18
Notes       : a partir de adb/tach/encmtchl.p
------------------------------------------------------------------------*/
{preprocesseur/type2contrat.i}
{preprocesseur/nature2contrat.i}
{preprocesseur/type2charge.i}
{preprocesseur/type2role.i}
{preprocesseur/type2tache.i}
{preprocesseur/type2compteur.i}
{preprocesseur/type2bien.i}

using parametre.syspr.syspr.
using parametre.syspg.syspg.
using parametre.pclie.parametrageHistoCG.

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

define variable goHistoCG as class parametrageHistoCG no-undo.
{mandat/include/clemi.i}
{adblib/include/perio.i}
{adblib/include/ctrat.i}
{adblib/include/cttac.i}
{tache/include/periodeChargeLocative.i}
{tache/include/relevePeriodeCharge.i}
{tache/include/imputationParticulierePeriodeCharge.i}
{tache/include/depenseCommunePeriodeChargLoc.i}
{application/include/combo.i}
{application/include/glbsepar.i}
{application/include/error.i}
{adb/include/majCleAlphaGerance.i}        // procedure majClger
{adbext/include/extdppre.i}

function numeroMandant returns int64 private(piNumeroContrat as int64, pcTypeContrat as character):
    /*------------------------------------------------------------------------------
    Purpose: recuperation mandant
    Notes  :
    ------------------------------------------------------------------------------*/
    define buffer intnt for intnt.

    find first intnt no-lock
        where intnt.tpcon = pcTypeContrat
          and intnt.nocon = piNumeroContrat
          and intnt.tpidt = {&TYPEROLE-mandant} no-error.
    if available intnt then return intnt.noidt.

    return 0.
end function.

function libelleCleChauffage return character private(piNumeroMandat as int64, pcCleChauffage as character):
    /*------------------------------------------------------------------------------
    Purpose: recherche libelle cle chauffage
    Notes  :
    ------------------------------------------------------------------------------*/
    define buffer clemi for clemi.

    for first clemi no-lock
        where clemi.noimm = 10000 + piNumeroMandat
          and clemi.nbtot > 0
          and clemi.tpcle <> "00001"
          and clemi.cdeta <> "S"
          and clemi.cdcle = pcCleChauffage:
        return clemi.lbcle.
    end.
    return "".
end function.

function validationCleChauffage return logical private(piNumeroMandat as int64, pcCleChauffage as character):
    /*------------------------------------------------------------------------------
    Purpose: recherche libelle cle chauffage
    Notes  :
    ------------------------------------------------------------------------------*/
    if not can-find(first clemi no-lock
                    where clemi.noimm = 10000 + piNumeroMandat
                      and clemi.nbtot > 0
                      and clemi.tpcle <> "00001"
                      and clemi.cdeta <> "S"
                      and clemi.cdcle = pcCleChauffage)
    then return false.
    return true.
end function.

procedure getPeriodeChargeLocativePrestation:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat as int64     no-undo.
    define input parameter pcTypeMandat   as character no-undo.
    define input parameter pcTypePeriode  as character no-undo.    
    define output parameter table for ttListePeriode.
   
    empty temp-table ttListePeriode.
    run lecturePeriode(piNumeroMandat, pcTypeMandat, pcTypePeriode). 

end procedure.

procedure lecturePeriode private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : 
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat as int64     no-undo.
    define input parameter pcTypeMandat   as character no-undo.
    define input parameter pcTypePeriode  as character no-undo.
   
    define variable vcListeTypePeriode as character no-undo.
    define variable vcTempo            as character no-undo. 
    
    define buffer perio   for perio.
    define buffer vbperio for perio.
    
    if pcTypePeriode = "ENCOURS"
    then vcListeTypePeriode = "00001,00002".
    else if pcTypePeriode = "HISTO"
         then vcListeTypePeriode = "00000,00003".
         else vcListeTypePeriode = "00000,00001,00002,00003". 

    for each perio no-lock
       where perio.tpctt = pcTypeMandat  
         and perio.nomdt = piNumeroMandat
         and perio.noper = 0
         and lookup(perio.cdtrt, vcListeTypePeriode) > 0:
        create ttListePeriode.
        assign 
            ttListePeriode.cTypeContrat       = pcTypeMandat
            ttListePeriode.iNumeroContrat     = piNumeroMandat
            ttListePeriode.iNumeroPeriode     = perio.noexo
            ttListePeriode.daDebut            = perio.dtdeb
            ttListePeriode.daFin              = perio.dtFin
            ttListePeriode.cTypeCharge        = perio.cdper
            ttListePeriode.cLibelleTypeCharge = outilTraduction:getLibelleParam("TPCHL", perio.cdper)            
            ttListePeriode.cCodeTraitement    = perio.cdtrt
            ttListePeriode.dtTimestamp        = datetime(perio.dtmsy, perio.hemsy)
            ttListePeriode.CRUD               = 'R'
            ttListePeriode.rRowid             = rowid(perio)
        .   
        if perio.cdtrt = "00000" and perio.lbdiv3 begins "man"
        then do:
            assign
                ttListePeriode.ltraitementManuel      = yes
                ttListePeriode.cLibelleCodeTraitement = outilTraduction:getLibelle(102629)
                vctempo                               = entry(1, perio.lbdiv3, "#")
            .
            if num-entries(vctempo, "@") >= 4 
            then ttListePeriode.cCommentaire = outilFormatage:fSubstGestion(outilTraduction:getLibelle(108382), substitute('&2&1&3', separ[1], entry(3, vctempo, "@"), entry(2, vctempo, "@"))). 
        end.
        else assign
            ttListePeriode.cLibelleCodeTraitement = outilTraduction:getLibelleParam("CDTRT", perio.cdtrt)
            ttListePeriode.ltraitementManuel      = no
        .
        if num-entries(perio.lbdiv) >= 1 then assign 
            ttListePeriode.cCleChauffage1        = entry(1, perio.lbdiv)
            ttListePeriode.cLibelleCleChauffage1 = libelleCleChauffage(piNumeroMandat, ttListePeriode.cCleChauffage1)
        .
        if num-entries(perio.lbdiv) >= 2 then assign 
            ttListePeriode.cCleChauffage2        = entry(2, perio.lbdiv)
            ttListePeriode.cLibelleCleChauffage2 = libelleCleChauffage(piNumeroMandat, ttListePeriode.cCleChauffage2)
        .
        if num-entries(perio.lbdiv) >= 3 then assign 
            ttListePeriode.cCleChauffage3        = entry(3, perio.lbdiv)
            ttListePeriode.cLibelleCleChauffage3 = libelleCleChauffage(piNumeroMandat, ttListePeriode.cCleChauffage3)
        .
        for each vbperio no-lock
            where vbperio.tpctt = pcTypeMandat  
              and vbperio.nomdt = piNumeroMandat
              and vbperio.noexo = perio.noexo
              and vbperio.noper > 0:
            if vbperio.noper = 1 then assign
                ttListePeriode.daChauffageDebut1 = vbperio.dtdeb
                ttListePeriode.daChauffageFin1   = vbperio.dtfin
            .
            if vbperio.noper = 2 then assign
                ttListePeriode.daChauffageDebut2 = vbperio.dtdeb
                ttListePeriode.daChauffageFin2   = vbperio.dtfin
            .
            if vbperio.noper = 3
            then assign
                ttListePeriode.daChauffageDebut3 = vbperio.dtdeb
                ttListePeriode.daChauffageFin3   = vbperio.dtfin
            .
        end.
    end.   

end procedure.

procedure setPeriodeChargeLocativePrestation:
    /*------------------------------------------------------------------------------
    Purpose: 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table for ttListePeriode.
    define input parameter table for ttError.

    define buffer ctrat for ctrat.

    find first ttListePeriode where lookup(ttListePeriode.CRUD, "C,U,D") > 0 no-error.
    if not available ttListePeriode then return.
 
    if not can-find(first ctrat no-lock
                    where ctrat.tpcon = ttListePeriode.cTypeContrat
                      and ctrat.nocon = ttListePeriode.iNumeroContrat)
    then do:
        mError:createError({&error}, 100057).
        return.
    end. 
    goHistoCG = new parametrageHistoCG(). 
    run verZonSai.
    delete object goHistoCG.
    if mError:erreur() then return.

    run majtbltch.
end procedure.

procedure verZonSai private:
    /*------------------------------------------------------------------------------
    Purpose: controle infos objet mandat avant maj
    Notes  : 
    ------------------------------------------------------------------------------*/
    define variable vdaFinMois      as date    no-undo.
    define variable vdaDebutCalcule as date    no-undo.
    define variable viNombreMaj     as integer no-undo.
    define variable voSyspr         as class syspr no-undo.

    define buffer perio   for perio.
    define buffer vbperio for perio.

    for each ttListePeriode where lookup(ttListePeriode.CRUD, "C,U,D") > 0: 
        viNombreMaj = viNombreMaj + 1.
        if viNombreMaj > 1
        then do:
            mError:createError({&error}, 1000534).             //Traitement de maj autorisé pour une seule période
            return.             
        end.
        find first perio no-lock
             where perio.tpctt = ttListePeriode.cTypeContrat  
               and perio.nomdt = ttListePeriode.iNumeroContrat
               and perio.noper = 0
               and perio.noexo = ttListePeriode.iNumeroPeriode no-error.
        if lookup(ttListePeriode.CRUD, "U,D") > 0 
        then do:    
            if not available perio
            then do:
                mError:createError({&error}, 1000526). //Modification ou suppression d'une période inexistante
                return.
            end.
            if ttListePeriode.CRUD = "U"
            then do:
                if lookup(perio.cdtrt, "00000,00003") > 0
                then do:
                    mError:createError({&error}, 1000527). //Modification d'une période traitée interdite
                    return.            
                end.
                //si passage en traitement manuel, initialisation de la zone cCommentaire avec date et utilisateur
                if ttListePeriode.lTraitementManuel
                then ttListePeriode.cCommentaire = substitute("MAN@&1@&2@&3#", mtoken:cUser, string(today, "99/99/9999"), string(time, "HH:MM:SS")).
            end.
            else if can-find(first vbperio no-lock
                             where vbperio.tpctt = ttListePeriode.cTypeContrat  
                               and vbperio.nomdt = ttListePeriode.iNumeroContrat
                               and vbperio.noper = 0
                               and vbperio.noexo > ttListePeriode.iNumeroPeriode)
            then do:
                mError:createError({&error}, 1000533, string(ttListePeriode.iNumeroPeriode)). //Suppression interdite, la période &1 n'est pas la dernière période
                return.
            end.
        end.
        else do:                                                    //ttListePeriode.CRUD = "C"
            if available perio
            then do:
                mError:createError({&error}, 1000528).    //Création d'une période déjà inexistante
                return. 
            end.
            //si passage en traitement manuel, initialisation de la zone cCommentaire avec date et utilisateur            
            if ttListePeriode.lTraitementManuel
            then ttListePeriode.cCommentaire = substitute("MAN@&1@&2@&3#", mtoken:cUser, string(today, "99/99/9999"), string(time, "HH:MM:SS")).   
        end.
        if ttListePeriode.CRUD = "C" then do:
            run ctrlCle(ttListePeriode.iNumeroContrat).
            if mError:erreur() then return.    
        end.
        if lookup(ttListePeriode.CRUD, "C,U") > 0
        then do:
            if ttListePeriode.daDebut = ? then do:
                mError:createError({&error}, 100418).  //la date d'acquisition du lot est obligatoire
                return.
            end.
            if day (ttListePeriode.daDebut) <> 1 then do:
                mError:createError({&error}, 1000529).  //La période doit commencer le 01 du mois
                return.
            end.
            if ttListePeriode.daFin = ? then do:
                mError:createError({&error}, 103862).  //la date de fin est obligatoire
                return.
            end.
            if ttListePeriode.daFin <= ttListePeriode.daDebut
            then do:
                mError:createError({&error}, 101796).  //La date de fin doit être postérieure à la date de début
                return.
            end.
            assign                                                         //calcul dernier jour du mois de la date de fin    
                vdaFinMois = add-interval(ttListePeriode.daFin, 1, "months")
                vdaFinMois = vdaFinMois - day(vdaFinMois) 
            .
            if ttListePeriode.daFin <> vdaFinMois
            then do:
                mError:createError({&error}, 1000530).   // La date de fin doit être le dernier jour du mois
                return.
            end.
            // recherche si periode precedente du meme type deja existante 
            if (ttListePeriode.cTypeCharge = {&TYPECHARGE-Chauffage}
                and can-find(first vbperio no-lock
                             where vbperio.tpctt = ttListePeriode.cTypeContrat  
                               and vbperio.nomdt = ttListePeriode.iNumeroContrat
                               and vbperio.noper = 0
                               and vbperio.noexo < ttListePeriode.iNumeroPeriode
                               and vbperio.cdper = {&TYPECHARGE-Chauffage}))
            or (ttListePeriode.cTypeCharge <> {&TYPECHARGE-Chauffage}
                and can-find(first vbperio no-lock
                             where vbperio.tpctt = ttListePeriode.cTypeContrat  
                               and vbperio.nomdt = ttListePeriode.iNumeroContrat
                               and vbperio.noper = 0
                               and vbperio.noexo < ttListePeriode.iNumeroPeriode
                               and vbperio.cdper <> {&TYPECHARGE-Chauffage}))
            then do:
                if ttListePeriode.CRUD = "U" then do:
                    if ttListePeriode.daDebut <> perio.dtdeb  
                    then do:
                        mError:createError({&error}, 1000535).  //Ce n'est pas la première période, modification date début interdite
                        return.
                    end.
                end.
                else do:
                    run calculDateDebut(buffer ttListePeriode, output vdaDebutCalcule).
                    if vdaDebutCalcule <> ttListePeriode.daDebut then do:
                        mError:createError({&error}, 1000535).  //Ce n'est pas la première période, modification date début interdite
                        return.
                    end.
                end.
            end.
            // recherche si periode suivante du meme type deja existante 
            if (ttListePeriode.cTypeCharge = {&TYPECHARGE-Chauffage}
                and can-find(first vbperio no-lock
                             where vbperio.tpctt = ttListePeriode.cTypeContrat  
                               and vbperio.nomdt = ttListePeriode.iNumeroContrat
                               and vbperio.noper = 0
                               and vbperio.noexo > ttListePeriode.iNumeroPeriode
                               and vbperio.cdper = {&TYPECHARGE-Chauffage}))
            or (ttListePeriode.cTypeCharge <> {&TYPECHARGE-Chauffage}
                and can-find(first vbperio no-lock
                             where vbperio.tpctt = ttListePeriode.cTypeContrat  
                               and vbperio.nomdt = ttListePeriode.iNumeroContrat
                               and vbperio.noper = 0
                               and vbperio.noexo > ttListePeriode.iNumeroPeriode
                               and vbperio.cdper <> {&TYPECHARGE-Chauffage}))
            then if ttListePeriode.CRUD = "U"
                and ttListePeriode.daFin <> perio.dtfin  
            then do:
                mError:createError({&error}, 1000536).      //Ce n'est pas la dernière période, modification date fin interdite
                return.
            end.
        
            if ttListePeriode.CRUD = "U"
            and ttListePeriode.cTypeCharge <> perio.cdper  
            then do:
                mError:createError({&error}, 1000537).         //modification du type de charge interdite
                return.
            end.
            voSyspr = new syspr().
            if voSyspr:isParamExist("TPCHL", ttListePeriode.cTypeCharge) = no     
            then do:
                mError:createError({&error}, 1000538).            //type de charge inexistant
                delete object voSyspr.
                return.
            end.
            delete object voSyspr.
        
            if ttListePeriode.cTypeCharge <> {&TYPECHARGE-Locatives}
            then do:
                if ttListePeriode.cCodeTraitement = "00001"
                and (ttListePeriode.cCleChauffage1 = ? or ttListePeriode.cCleChauffage1 = ?)
                then do:
                    mError:createError({&error}, 103857).  //Vous devez saisir au moins une clé de chauffe
                    return.
                end.
                if ttListePeriode.cCodeTraitement = "00001" or ttListePeriode.cCodeTraitement = "00003" 
                then do:
                    if ttListePeriode.cCleChauffage1 > ""
                    and ValidationCleChauffage (ttListePeriode.iNumeroContrat, ttListePeriode.cCleChauffage1) = no
                    then do:
                        mError:createError({&error}, 1000531).  //clé chauffage non valide
                        return. 
                    end.
                    if ttListePeriode.cCleChauffage2 > ""
                    and ValidationCleChauffage (ttListePeriode.iNumeroContrat, ttListePeriode.cCleChauffage2) = no
                    then do:
                        mError:createError({&error}, 1000531).  //clé chauffage non valide
                        return. 
                    end.
                    if ttListePeriode.cCleChauffage3 > ""
                    and ValidationCleChauffage (ttListePeriode.iNumeroContrat, ttListePeriode.cCleChauffage3) = no
                    then do:
                        mError:createError({&error}, 1000531).  //clé chauffage non valide
                        return. 
                    end.   
                    if ttListePeriode.cCleChauffage1 > ""
                    and (ttListePeriode.cCleChauffage1 = ttListePeriode.cCleChauffage2 or ttListePeriode.cCleChauffage1 = ttListePeriode.cCleChauffage3)
                    then do:  
                        mError:createError({&error}, 103881).  //Vous avez saisi plusieurs fois la même cle
                        return. 
                    end.  
                    if ttListePeriode.cCleChauffage2 > ""
                    and ttListePeriode.cCleChauffage2 = ttListePeriode.cCleChauffage3
                    then do:  
                        mError:createError({&error}, 103881).  //Vous avez saisi plusieurs fois la même cle
                        return. 
                    end.
                    if ttListePeriode.daChauffageDebut1 = ?
                    then do:
                         mError:createError({&error}, 105617).  //Vous devez saisir la periode de chauffe
                         return.
                    end.
                    if ttListePeriode.daChauffageFin1 <> ? and ttListePeriode.daChauffageFin1 <= ttListePeriode.daChauffageDebut1 
                    then do:
                         mError:createError({&error}, 101796).  //La date de fin doit être postérieure à la date de début
                         return.
                    end.
                    if ttListePeriode.daChauffageDebut1 < ttListePeriode.daDebut
                    or ttListePeriode.daChauffageDebut1 > ttListePeriode.daFin
                    then do:
                        mError:createErrorGestion({&error}, 103858, "1").  //La période de chauffe %1 doit être incluse dans la période de charges
                        return.
                    end.
                    if ttListePeriode.daChauffageDebut2 <> ? 
                    then do:
                        if ttListePeriode.daChauffageFin2 = ? 
                        then do:
                             mError:createErrorGestion({&error}, 103861, "2").  //La période de chauffe %1 est incomplète
                             return.
                        end.
                        if ttListePeriode.daChauffageFin2 <= ttListePeriode.daChauffageDebut2 
                        then do:
                             mError:createError({&error}, 101796).  //La date de fin doit être postérieure à la date de début
                             return.
                        end.
                        if ttListePeriode.daChauffageDebut2 < ttListePeriode.daDebut
                        or ttListePeriode.daChauffageDebut2 > ttListePeriode.daFin
                        then do:
                            mError:createErrorGestion({&error}, 103858, "2").  //La période de chauffe %1 doit être incluse dans la période de charges
                            return.
                        end.
                    end.
                    else if ttListePeriode.daChauffageFin2 <> ? 
                    then do:
                        mError:createErrorGestion({&error}, 103859, "2").  //Vous n'avez pas saisi la date de début de la période de chauffe %1
                        return.
                    end.
  
                    if ttListePeriode.daChauffageDebut3 <> ? 
                    then do:
                        if ttListePeriode.daChauffageFin3 = ? 
                        then do:
                             mError:createErrorGestion({&error}, 103861, "3").  //La période de chauffe %1 est incomplète
                             return.
                        end.
                        if ttListePeriode.daChauffageFin3 <= ttListePeriode.daChauffageDebut3 
                        then do:
                             mError:createError({&error}, 101796).  //La date de fin doit être postérieure à la date de début
                             return.
                        end.
                        if ttListePeriode.daChauffageDebut3 < ttListePeriode.daDebut
                        or ttListePeriode.daChauffageDebut3 > ttListePeriode.daFin
                        then do:
                            mError:createErrorGestion({&error}, 103858, "3").  //La période de chauffe %1 doit être incluse dans la période de charges
                            return.
                        end.
                    end.
                    else if ttListePeriode.daChauffageFin3 <> ? 
                    then do:
                        mError:createErrorGestion({&error}, 103859, "3").  //Vous n'avez pas saisi la date de début de la période de chauffe %1
                        return.
                    end.
                end.
            end.    
        end.

        if ttListePeriode.CRUD = "D" then do:   
            //Vérifier s'il a des charges locatives rattachées
            if can-find(first cexmlnana no-lock
                        where cexmlnana.soc-cd  = integer(mtoken:cRefGerance)
                          and cexmlnana.etab-cd = ttListePeriode.iNumeroContrat
                          and cexmlnana.noexo   = ttListePeriode.iNumeroPeriode)
            or can-find(first cecrlnana no-lock                                //Ajout le 05/04/2002 (vu avec OF)
                        where cecrlnana.soc-cd  = integer(mtoken:cRefGerance)
                          and cecrlnana.etab-cd = ttListePeriode.iNumeroContrat
                          and cecrlnana.noexo   = ttListePeriode.iNumeroPeriode)
            then do:
                if outils:questionnaire(1000532, table ttError by-reference) <= 2 //Attention : des écritures sont rattachées à la période que vous allez supprimer.%sSi vous répondez 'Oui', vous devrez réaffecter manuellement sur la bonne période. Pensez à les éditer préalablement !
                then return.
            end.
        end.
    end.
end procedure.

procedure majtbltch private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhPerio                       as handle    no-undo.
    define variable vhCtrat                       as handle    no-undo.
    define variable vhCttac                       as handle    no-undo.
    define variable vhSupchloc                    as handle    no-undo.
    define variable viNumeroPseudoCtratPrestation as int64     no-undo.
    define variable vcNaturePseudoCtratPrestation as character no-undo.
    define variable viNoDocSui                    as integer   no-undo.
    define variable viNoConSui                    as int64     no-undo.
    define variable vlReleveEauFroide             as logical   no-undo.
    define variable vlReleveEauChaude             as logical   no-undo.
    define variable vlReleveCalorifique           as logical   no-undo.
    define variable vcListeCle                    as character no-undo.
    define variable vlModifDateFin                as logical   no-undo.
    define variable vcCollectif                   as character no-undo.
    define variable vcCompte                      as character no-undo.
    define variable viRetour                      as integer   no-undo.
        
    define buffer perio   for perio. 
    define buffer tache   for tache. 
    define buffer sys_pg  for sys_pg. 
    define buffer bsys_pg for sys_pg. 
     
boucle-maj:    
    for first ttListePeriode where lookup(ttListePeriode.CRUD, "C,U") > 0:

        empty temp-table ttPerio.
        empty temp-table ttCtrat.
        empty temp-table ttCttac.
        
        for first tache no-lock
            where tache.tpcon = ttListePeriode.cTypeContrat
              and tache.nocon = ttListePeriode.iNumeroContrat
              and tache.tptac = {&TYPETACHE-chargesLocativesPrestations}
              and tache.notac = 1:
            assign
                vlReleveEauFroide   = (tache.cdreg = "1")
                vlReleveEauChaude   = (tache.ntreg = "1")
                vlReleveCalorifique = (tache.pdreg = "1")
            .
        end.
        
        if ttListePeriode.CRUD = "U"
        then for first perio no-lock
            where perio.tpctt = ttListePeriode.cTypeContrat  
              and perio.nomdt = ttListePeriode.iNumeroContrat
              and perio.noper = 0
              and perio.noexo = ttListePeriode.iNumeroPeriode
              and perio.dtfin > ttListePeriode.daFin:
            vlModifDateFin = yes.               
        end.  
        vcListeCle = "".     
        if ttListePeriode.cCleChauffage1 > "" then vcListeCle = ttListePeriode.cCleChauffage1.
        if ttListePeriode.cCleChauffage2 > "" then vcListeCle = vcListeCle + "," + ttListePeriode.cCleChauffage2.
        if ttListePeriode.cCleChauffage3 > "" then vcListeCle = vcListeCle + "," + ttListePeriode.cCleChauffage3.
        create ttPerio.
        assign
            ttPerio.tpctt       = ttListePeriode.cTypeContrat
            ttPerio.nomdt       = ttListePeriode.iNumeroContrat
            ttPerio.noexo       = ttListePeriode.iNumeroPeriode
            ttPerio.noper       = 0
            ttPerio.dtdeb       = ttListePeriode.daDebut
            ttPerio.dtfin       = ttListePeriode.daFin
            ttPerio.nbmoi       = 0
            ttPerio.cdper       = ttListePeriode.cTypeCharge
            ttPerio.cdtrt       = if ttListePeriode.lTraitementManuel then "00000" else ttListePeriode.cCodeTraitement
            ttPerio.lbdiv       = vcListeCle
            ttPerio.lbdiv3      = if ttListePeriode.cCommentaire > "" then ttListePeriode.cCommentaire else ? 
            ttPerio.dtTimestamp = ttListePeriode.dtTimestamp
            ttPerio.CRUD        = ttListePeriode.CRUD
            ttPerio.rRowid      = ttListePeriode.rrowid
        .
        
        //periode de chauffe
        for each perio no-lock
           where perio.tpctt = ttListePeriode.cTypeContrat  
             and perio.nomdt = ttListePeriode.iNumeroContrat
             and perio.noexo = ttListePeriode.iNumeroPeriode
             and perio.noper > 0:
            create ttPerio.
            assign
                ttPerio.dtTimestamp = datetime(perio.dtmsy, perio.hemsy)
                ttPerio.CRUD        = "D"
                ttPerio.rRowid      = rowid(perio)
            .
        end.
        if ttListePeriode.daChauffageDebut1 <> ?
        then do:
            create ttPerio.
            assign
                ttPerio.tpctt       = ttListePeriode.cTypeContrat 
                ttPerio.nomdt       = ttListePeriode.iNumeroContrat
                ttPerio.noexo       = ttListePeriode.iNumeroPeriode
                ttPerio.noper       = 1
                ttPerio.dtdeb       = ttListePeriode.daChauffageDebut1
                ttPerio.dtfin       = ttListePeriode.daChauffageFin1
                ttPerio.CRUD        = "C"
            .
        end. 
        if ttListePeriode.daChauffageDebut2 <> ?
        then do:
            create ttPerio.
            assign
                ttPerio.tpctt       = ttListePeriode.cTypeContrat 
                ttPerio.nomdt       = ttListePeriode.iNumeroContrat
                ttPerio.noexo       = ttListePeriode.iNumeroPeriode
                ttPerio.noper       = 2
                ttPerio.dtdeb       = ttListePeriode.daChauffageDebut2
                ttPerio.dtfin       = ttListePeriode.daChauffageFin2
                ttPerio.CRUD        = "C"
            .
        end.    
        if ttListePeriode.daChauffageDebut3 <> ?
        then do:
            create ttPerio.
            assign
                ttPerio.tpctt       = ttListePeriode.cTypeContrat 
                ttPerio.nomdt       = ttListePeriode.iNumeroContrat
                ttPerio.noexo       = ttListePeriode.iNumeroPeriode
                ttPerio.noper       = 3
                ttPerio.dtdeb       = ttListePeriode.daChauffageDebut3
                ttPerio.dtfin       = ttListePeriode.daChauffageFin3
                ttPerio.CRUD        = "C"
            .
        end.

        //Creation d'un pseudo-contrat Prestations
        assign
            viNumeroPseudoCtratPrestation = ttListePeriode.iNumeroContrat * 100 + ttListePeriode.iNumeroPeriode     //integer( string(piNumeroMandat,"99999") + STRING(piNumeroPeriode,"99") )  
            vcNaturePseudoCtratPrestation = if ttListePeriode.cTypeCharge = {&TYPECHARGE-Chauffage}
                                            then {&NATURECONTRAT-chargeChauffage} else {&NATURECONTRAT-chargeLocative}
        .
        if not can-find (first ctrat no-lock
                         where ctrat.tpcon = {&TYPECONTRAT-prestations}
                           and ctrat.nocon = viNumeroPseudoCtratPrestation) 
        then do:
            create ttCtrat.
            assign 
                ttCtrat.CRUD  = "C"
                ttCtrat.tpcon = {&TYPECONTRAT-prestations}
                ttCtrat.nocon = viNumeroPseudoCtratPrestation 
                ttctrat.dtdeb = ttListePeriode.daDebut
                ttctrat.dtfin = ttListePeriode.daFin
                ttctrat.ntcon = vcNaturePseudoCtratPrestation  
                ttctrat.tprol = {&TYPEROLE-mandant}  
                ttctrat.norol = numeroMandant(ttListePeriode.iNumeroContrat, ttListePeriode.cTypeContrat) 
            .
        end.
        /* Creation des Taches associees (Imputations particulieres...) */
        for each sys_pg no-lock
            where sys_pg.tppar = 'R_CTA'
              and sys_pg.zone1 = vcNaturePseudoCtratPrestation
               by sys_pg.zone2:
            find first bsys_pg no-lock                                   //Controler le type de tache
                 where bsys_pg.tppar = 'O_TAE'
                   and bsys_pg.cdpar = sys_pg.zone2 no-error.
            if not available bsys_pg then next.
            //Creation tache releves d'eau ... si coche dans parametrage tache
            if sys_pg.zone2 = {&TYPETACHE-eauFroideGerance} and vlReleveEauFroide
            then do:
                run GesCttac (ttListePeriode.iNumeroContrat, ttListePeriode.cTypeContrat, viNumeroPseudoCtratPrestation, sys_pg.zone2).
                if mError:erreur() then leave boucle-maj.
            end.
            if sys_pg.zone2 = {&TYPETACHE-eauChaudeGerance} and vlReleveEauChaude
            then do:
                run GesCttac (ttListePeriode.iNumeroContrat, ttListePeriode.cTypeContrat, viNumeroPseudoCtratPrestation, sys_pg.zone2).
                if mError:erreur() then leave boucle-maj.
            end.
            if sys_pg.zone2 = {&TYPETACHE-thermieGerance} and vlReleveCalorifique
            then do:
                run GesCttac (ttListePeriode.iNumeroContrat, ttListePeriode.cTypeContrat, viNumeroPseudoCtratPrestation, sys_pg.zone2).
                if mError:erreur() then leave boucle-maj.
            end.
            //ne prendre en compte que les taches de type 'C' (contrat) ou 'L' (liste) et les taches automatiques
            if entry(1, bsys_pg.zone9, '@') = 'C' 
            or entry(1, bsys_pg.zone9, '@') = 'L' 
            or entry(3, bsys_pg.zone9, '@') begins 'A' 
            then do:
                run GesCttac (ttListePeriode.iNumeroContrat, ttListePeriode.cTypeContrat, viNumeroPseudoCtratPrestation, sys_pg.zone2 ).
                if mError:erreur() then leave boucle-maj.
            end.
        end.
        
        run adblib/perio_CRUD.p persistent set vhPerio.
        run getTokenInstance in vhPerio(mToken:JSessionId).
        run setPerio in vhPerio(table ttPerio by-reference).
        if mError:erreur() then leave boucle-maj.
        
        for first ttCtrat:
            run adblib/ctrat_CRUD.p persistent set vhCtrat.
            run getTokenInstance in vhCtrat(mToken:JSessionId).
            run setCtrat in vhCtrat(table ttCtrat by-reference).
            if mError:erreur() then leave boucle-maj.
        end.
        
        if can-find(first ttCttac)
        then do: 
            run adblib/cttac_CRUD.p persistent set vhCttac.
            run getTokenInstance in vhCttac(mToken:JSessionId).
            run setCttac in vhCttac(table ttCttac by-reference).
            if mError:erreur() then leave boucle-maj.
        end.
        
        //RAZ rattachement ecritures si on raccourcit la periode (Vu avec Olivier Falcy)  
        if vlModifDateFin 
        then do:
            //Recherche du compte 4110
            for first ccptcol no-lock 
                where ccptcol.soc-cd = integer(mtoken:cRefGerance)
                  and ccptcol.tprole = 22
            , first csscpt no-lock 
              where csscpt.soc-cd   = ccptcol.soc-cd
                and csscpt.etab-cd  = ttListePeriode.iNumeroContrat
                and csscpt.coll-cle = ccptcol.coll-cle:
                assign         
                    vcCollectif = csscpt.sscoll-cle
                    vcCompte = csscpt.cpt-cd
                .
            end.      
            for each cexmlnana
                where cexmlnana.soc-cd     = integer(mtoken:cRefGerance)
                and   cexmlnana.etab-cd    = ttListePeriode.iNumeroContrat
                and   cexmlnana.sscoll-cle = vcCollectif
                and   cexmlnana.cpt-cd     = vcCompte
                and   cexmlnana.noexo      = ttListePeriode.iNumeroPeriode
                and   cexmlnana.datecr     > ttListePeriode.daFin:
                cexmlnana.noexo = 0.
            end.
            for each cecrlnana
                where cecrlnana.soc-cd     = integer(mtoken:cRefGerance)
                and   cecrlnana.etab-cd    = ttListePeriode.iNumeroContrat
                and   cecrlnana.sscoll-cle = vcCollectif
                and   cecrlnana.cpt-cd     = vcCompte
                and   cecrlnana.noexo      = ttListePeriode.iNumeroPeriode
                and   cecrlnana.datecr     > ttListePeriode.daFin:
                cecrlnana.noexo = 0.
            end.
        end.
    end.
 
    for first ttListePeriode where ttListePeriode.CRUD = "D":
        run adblib/supchloc.p persistent set vhSupchloc.
        run getTokenInstance in vhSupchloc(mToken:JSessionId).    
        run SupPeriodeCharge in vhSupchloc (ttListePeriode.iNumeroContrat, ttListePeriode.cTypeContrat, ttListePeriode.iNumeroPeriode).
        /*si question 1000532 existe avec reponse oui, c'est que au moment du controle on a determine qu'il fallait detacher 
        des ecritures (suite echange question reponse avec l'ihm) */
        if mError:reponseQuestion(1000532) = 3 
        then do:
            /*  Ajout SY le 11/03/2009 - 0309/0066 : dé-rattachement des écritures */
            for each cexmlnana exclusive-lock
               where cexmlnana.soc-cd  = integer(mtoken:cRefGerance)
                 and cexmlnana.etab-cd = ttListePeriode.iNumeroContrat
                 and cexmlnana.noexo   = ttListePeriode.iNumeroPeriode:
                cexmlnana.noexo = 0.
            end.        
            for each cecrlnana exclusive-lock
               where cecrlnana.soc-cd  = integer(mtoken:cRefGerance)
                 and cecrlnana.etab-cd = ttListePeriode.iNumeroContrat
                 and cecrlnana.noexo   = ttListePeriode.iNumeroPeriode:
                cecrlnana.noexo = 0.
            end.        
        end.    
    end.

    if valid-handle(vhPerio)    then run destroy in vhPerio.
    if valid-handle(vhCtrat)    then run destroy in vhCtrat.
    if valid-handle(vhCttac)    then run destroy in vhCttac.
    if valid-handle(vhSupchloc) then run destroy in vhSupchloc.

end procedure.

procedure GesCttac private:
    /*------------------------------------------------------------------------------
    Purpose: creation relation pseudo contrat / tache et mandat / tache
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat                as int64     no-undo.
    define input parameter pcTypeMandat                  as character no-undo.
    define input parameter piNumeroPseudoCtratPrestation as int64     no-undo.
    define input parameter pcTypeTache                   as character no-undo.

    //Generation de la relation contrat / tache
    if not can-find (first cttac no-lock 
                     where cttac.tpcon = {&TYPECONTRAT-prestations}
                       and cttac.nocon = piNumeroPseudoCtratPrestation
                       and cttac.tptac = pcTypeTache)
    then do:
        create ttCttac. 
        assign
            ttCttac.tpcon = {&TYPECONTRAT-prestations}
            ttCttac.nocon = piNumeroPseudoCtratPrestation
            ttCttac.tptac = pcTypeTache
            ttCttac.CRUD  = "C"
        .
    end.
    //Generation de la relation mandat / tache (sauf chg locatives en comptabilite)
    if pcTypeTache <> {&TYPETACHE-chargeLocativeEnComptabilite}
    and not can-find (first cttac no-lock 
                      where cttac.tpcon = pcTypeMandat
                        and cttac.nocon = piNumeroMandat
                        and cttac.tptac = pcTypeTache)
    then do:
        create ttCttac.
        assign
            ttCttac.tpcon = pcTypeMandat
            ttCttac.nocon = piNumeroMandat
            ttCttac.tptac = pcTypeTache
            ttCttac.CRUD  = "C"
        .
    end.

end procedure.

procedure initPeriodeChargeLocativePrestation:
    /*------------------------------------------------------------------------------
    Purpose: appel procedure creation periode charge locative pour retour des valeurs par defaut (pas encore de maj)
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat as integer   no-undo.
    define input parameter pcTypeMandat   as character no-undo.
    define output parameter table for ttListePeriode.

    define variable vdaDebutCalcule as date no-undo.

    define buffer perio for perio.
   
    empty temp-table ttListePeriode.

    goHistoCG = new parametrageHistoCG().
    run ctrlCle (piNumeroMandat).
    delete object goHistoCG. 
    if mError:erreur() = yes then return.    

    find last perio no-lock
        where perio.tpctt = pcTypeMandat  
          and perio.nomdt = piNumeroMandat
          and perio.noper = 0 no-error.
    create ttListePeriode.
    assign
        ttListePeriode.cTypeContrat           = pcTypeMandat
        ttListePeriode.iNumeroContrat         = piNumeroMandat    
        ttListePeriode.CRUD                   = 'C'
        ttListePeriode.cCodeTraitement        = "00001" 
        ttListePeriode.cLibelleCodeTraitement = outilTraduction:getLibelleParam("CDTRT", ttListePeriode.cCodeTraitement)
        ttListePeriode.ltraitementManuel      = no  
    .
    if available perio
    then assign
             ttListePeriode.iNumeroPeriode = perio.noexo + 1
             ttListePeriode.cTypeCharge    = (if perio.cdper = {&TYPECHARGE-Chauffage} then {&TYPECHARGE-Locatives}
                                                                                       else perio.cdper)
    .   
    else assign 
             ttListePeriode.iNumeroPeriode = 10
             ttListePeriode.cTypeCharge    = {&TYPECHARGE-Loc_Chauf}
    .
    ttListePeriode.cLibelleTypeCharge = outilTraduction:getLibelleParam("TPCHL", ttListePeriode.cTypeCharge).  
    
    run calculDateDebut(buffer ttListePeriode, output vdaDebutCalcule).
    assign 
        ttListePeriode.daDebut = vdaDebutCalcule
        ttListePeriode.daFin   = add-interval(ttListePeriode.daDebut, 1, "years") - 1
    . 
    
end procedure.

procedure initDatePeriodeChargeLocativePrestation:
    /*------------------------------------------------------------------------------
    Purpose: appel procedure calcul des dates periode charge locative en creation en fonction du type de charge
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input-output parameter table for ttListePeriode.

    define variable vdaDebutCalcule as date no-undo.

    for first ttListePeriode where ttListePeriode.CRUD = "C": 
        run calculDateDebut(buffer ttListePeriode, output vdaDebutCalcule).
        assign 
            ttListePeriode.daDebut = vdaDebutCalcule
            ttListePeriode.daFin   = add-interval(ttListePeriode.daDebut, 1, "years") - 1
        . 
    end.
    
end procedure.

procedure calculDateDebut private:
    /*------------------------------------------------------------------------------
    Purpose: calcul des dates periode charge locative en creation en fonction du type de charge
    Notes  : 
    ------------------------------------------------------------------------------*/
    define parameter buffer ttListePeriode for ttListePeriode.
    define output parameter pdaDebutCalcule as date no-undo.
    
    define variable voCollection           as class collection no-undo.   
    define variable vhProcTransfert        as handle           no-undo.
    define variable viPeriodeQuittancement as integer          no-undo.
    define variable viAnneeQuittancement   as integer          no-undo.
   
    define buffer perio for perio.

    if ttListePeriode.cTypeCharge = {&TYPECHARGE-Chauffage}
    then find last perio no-lock
             where perio.tpctt = ttListePeriode.cTypeContrat  
               and perio.nomdt = ttListePeriode.iNumeroContrat
               and perio.noper = 0 
               and perio.cdper = {&TYPECHARGE-Chauffage} no-error.
    else find last perio no-lock
             where perio.tpctt = ttListePeriode.cTypeContrat    
               and perio.nomdt = ttListePeriode.iNumeroContrat
               and perio.noper = 0 
               and perio.cdper <> {&TYPECHARGE-Chauffage} no-error.
    if available perio
    then pdaDebutCalcule = perio.dtfin + 1.
    else do:
        voCollection = new collection().
        run adblib/transfert/suiviTransfert_CRUD.p persistent set vhProcTransfert. 
        run getTokenInstance in vhProcTransfert(mToken:JSessionId).  
        run getInfoTransfert in vhProcTransfert ("QUIT", input-output voCollection).
        run destroy in vhProcTransfert.
        assign
            viPeriodeQuittancement = voCollection:getInteger("GlMoiQtt")
            viAnneeQuittancement   = truncate(viPeriodeQuittancement / 100, 0)
        .
        if ttListePeriode.cTypeCharge = {&TYPECHARGE-Chauffage}
        then pdaDebutCalcule = date(10, 01, viAnneeQuittancement).
        else pdaDebutCalcule = date(01, 01, viAnneeQuittancement).
    end.
    
end procedure.

procedure comboPeriodeChargeLocativePrestation:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat as int64     no-undo.
    define input parameter pcTypeMandat   as character no-undo.

    define output parameter table for ttCombo.
 
    goHistoCG = new parametrageHistoCG().
     
    run chargeCombo(piNumeroMandat).

    delete object goHistoCG.

end procedure.

procedure chargeCombo private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat as int64 no-undo.

    define variable voSyspr as class syspr no-undo.
    define variable voSyspg as class syspg no-undo.
    define buffer clemi for clemi.

    empty temp-table ttCombo.

    voSyspr = new syspr().
    voSyspr:getComboParametre("TPCHL", "TYPEDECHARGE", output table ttCombo by-reference).

    voSyspg = new syspg().
    for each clemi no-lock
       where clemi.noimm = 10000 + piNumeroMandat
         and clemi.nbtot > 0
         and clemi.tpcle <> "00001"
         and clemi.cdeta <> "S":
        voSyspg:creationttCombo("CLE-CHAUFFAGE", clemi.cdcle, clemi.lbcle, output table ttCombo by-reference).
    end.

    delete object voSyspr.
    delete object voSyspg.

end procedure.

procedure ctrlCle private:
    /*------------------------------------------------------------------------------
    Purpose: controle des cles
             extrait de procedure encmtchl.p/ChgObjGes
    Notes  :  
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat as int64 no-undo.

    define variable vlCleDefautExiste as logical no-undo.
    define variable vhProcclemi       as handle  no-undo.
    define buffer clemi for clemi.

    if not can-find(first clemi no-lock
                    where clemi.noimm = 10000 + piNumeroMandat
                      and clemi.cdeta = "V")
    then do :
        empty temp-table ttClemi.
        run adblib/clemi_CRUD.p persistent set vhProcclemi.
        run getTokenInstance in vhProcclemi(mToken:JSessionId).
        run majClger(piNumeroMandat). // creation de ttClemi
        run setclemi in vhProcclemi (table ttclemi by-reference).
        run destroy in vhProcclemi.                
    end.        

boucleRechercheCleAvecMillieme:
    for each clemi no-lock
       where clemi.noimm = 10000 + piNumeroMandat
         and clemi.nbtot > 0
         and clemi.cdeta = "V":             
        vlCleDefautExiste = yes.
        leave boucleRechercheCleAvecMillieme.
    end.
    if vlCleDefautExiste = no
    then do:
        mError:createError({&error}, 103923). //Vous devez saisir au moins une clé de répartition avec millièmes
    end.

end procedure.

procedure getDepensePeriode:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat  as int64     no-undo.
    define input parameter pcTypeMandat    as character no-undo.
    define input parameter piNumeroPeriode as integer   no-undo.
    define output parameter table for ttDepenseCommunePeriode.
 
    define buffer perio for perio.
   
    define variable vcParametreEdition as character no-undo.
    define variable voCollection as class collection no-undo.

    empty temp-table ttDepenseCommunePeriode. 

    for first perio no-lock
        where perio.tpctt = pcTypeMandat  
          and perio.nomdt = piNumeroMandat
          and perio.noper = 0
          and perio.noexo = piNumeroPeriode:
        // Constitution de la chaine d'extration
        vcParametreEdition = substitute ("&1|&2|&3|&4|G|NO|NO|PERIODE||||||||||||||||||EXC|NO", perio.nomdt, perio.noexo, perio.dtdeb, perio.dtfin).
        voCollection = new collection().
        voCollection:set("cRefPrincipale", mToken:cRefPrincipale).
        voCollection:set("iCodeLangueSession", mToken:iCodeLangueSession).
        voCollection:set('cJSessionId', mToken:JSessionId).
        empty temp-table ttImpression.
        empty temp-table ttExport.
        
        run adbext/extdppre.p (input-output vcParametreEdition, 
                               yes,                                        //depense cumule 
                               voCollection,
                               input-output table ttExport by-reference,
                               input-output table ttImpression by-reference).                               
        for each ttExport:
            create ttDepenseCommunePeriode.
            assign
                ttDepenseCommunePeriode.cTypeContrat     = pcTypeMandat
                ttDepenseCommunePeriode.iNumeroContrat   = piNumeroMandat
                ttDepenseCommunePeriode.iNumeroPeriode   = perio.noexo
                ttDepenseCommunePeriode.cCle             = ttExport.cCle
                ttDepenseCommunePeriode.daDocument       = ttExport.daEcr
                ttDepenseCommunePeriode.cLibelleEcriture = ttExport.cLibEcr[1] + " " + ttExport.cLibEcr[2]
                ttDepenseCommunePeriode.dMontantTTC      = ttExport.dMt
            . 
        end. 
    end. 

end procedure.

procedure getRelevePeriode:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat  as int64     no-undo.
    define input parameter pcTypeMandat    as character no-undo.
    define input parameter piNumeroPeriode as integer   no-undo.
    define input parameter pcTypeReleve    as character no-undo.
    define output parameter table for ttRelevePeriode.
 
    define buffer perio for perio.
    define buffer lprtb for lprtb.
    define buffer erlet for erlet.
 
    empty temp-table ttRelevePeriode.  
   
    for first perio no-lock
        where perio.tpctt = pcTypeMandat  
          and perio.nomdt = piNumeroMandat
          and perio.noper = 0
          and perio.noexo = piNumeroPeriode:
        for each lprtb no-lock
           where lprtb.tpcon = perio.tpctt
             and lprtb.nocon = perio.nomdt
             and lprtb.noexe = perio.noexo
             and lprtb.noper = 0
             and lprtb.tpcpt = pcTypeReleve,                
        first erlet no-lock
        where erlet.noimm = lprtb.nocon + 10000
          and erlet.tpcpt = lprtb.tpcpt
          and erlet.norlv = lprtb.norlv
          and erlet.tpcpt = lprtb.tpcpt:
            create ttRelevePeriode.
            assign 
                ttRelevePeriode.cTypeContrat          = pcTypeMandat
                ttRelevePeriode.iNumeroContrat        = piNumeroMandat
                ttRelevePeriode.iNumeroPeriode        = perio.noexo
                ttRelevePeriode.cTypeReleve           = pcTypeReleve
                ttRelevePeriode.cLibelleTypeReleve    = ""
                ttRelevePeriode.iNumeroReleve         = lprtb.norlv
                ttRelevePeriode.daReleve              = erlet.dtrlv
                ttRelevePeriode.dConsommation         = erlet.totco
                ttRelevePeriode.dMontantTTC           = erlet.totrl
                ttRelevePeriode.dMontantRecuperation1 = - erlet.totrc
                ttRelevePeriode.dMontantRecuperation2 = - erlet.toter
            .                                        
        end.
    end. 

end procedure.

procedure getImputationParticulierePeriode:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat  as int64     no-undo.
    define input parameter pcTypeMandat    as character no-undo.
    define input parameter piNumeroPeriode as integer   no-undo.
    define output parameter table for ttImputationParticulierePeriode.
  
    define buffer perio for perio.
    define buffer lprtb for lprtb.
    define buffer entip for entip.
  
    empty temp-table ttImputationParticulierePeriode.  
   
    for first perio no-lock
        where perio.tpctt = pcTypeMandat  
          and perio.nomdt = piNumeroMandat
          and perio.noper = 0
          and perio.noexo = piNumeroPeriode:
        for each lprtb no-lock
           where lprtb.tpcon = perio.tpctt
             and lprtb.nocon = perio.nomdt
             and lprtb.noexe = perio.noexo
             and lprtb.noper = 0
             and lprtb.tpcpt = {&TYPETACHE-ImputParticuliereGerance}                
        , first entip no-lock
          where entip.nocon = lprtb.nocon
            and entip.noimm = lprtb.noimm
            and entip.dtimp = outils:convertionDate("yyyymmdd", string(lprtb.norlv)):
            create ttImputationParticulierePeriode.
            assign 
                ttImputationParticulierePeriode.cTypeContrat         = pcTypeMandat
                ttImputationParticulierePeriode.iNumeroContrat       = piNumeroMandat
                ttImputationParticulierePeriode.iNumeroPeriode       = perio.noexo
                ttImputationParticulierePeriode.daReleve             = entip.dtimp
                ttImputationParticulierePeriode.dMontantTTC          = entip.mtttc
                ttImputationParticulierePeriode.dMontantRecuperation = - (if entip.mtttr <> 0 then entip.mtttr else decimal(entry(2, entip.lbrec, separ[1]))) 
            .                                        
        end.
    end. 

end procedure.


