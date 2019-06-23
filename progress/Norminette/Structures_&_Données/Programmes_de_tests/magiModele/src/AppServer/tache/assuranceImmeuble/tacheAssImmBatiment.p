/*------------------------------------------------------------------------
File        : tacheAssBatiment.p
Purpose     : Affectation des batiments pour une assurance
Author(s)   : GGA  -  2017/11/27
Notes       : a partir de adb/tach/prmobbat.p, prmasbat.p
              Cette tache est geree differement suite a la modernisation. Les informations sont maintenant liees
              a l'ecran objet de l'assurance (un ecran global qui regroupe objet, roles et batiments) et plus de gestion 
              du bouton suppression de la tache.
              Par defaut la tache sera maintenant creee si il existe des batiments sur l'immeuble. 
              En lecture on retourne la liste des batiments en renseignant l'info selection si la tache existe.
------------------------------------------------------------------------*/
{preprocesseur/type2tache.i}
{preprocesseur/type2contrat.i}
{preprocesseur/type2bien.i}

using parametre.pclie.parametrageDefautMandat.
{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{tache/include/tacheAssuranceImmeuble.i}
{tache/include/tache.i}
{adblib/include/cttac.i}

procedure getBatiment:
    /*------------------------------------------------------------------------------
    Purpose: lecture affectation batiment 
    Notes  : service externe
    @param piNumeroContrat       : numero d'assurance
    @param pcTypeContrat         : type de contrat d'assurance pour le moment developpé pour TYPECONTRAT-assuranceGerance (01039) 
    @param ttAttestationAssImm   : liste batiment pour gestion affectation
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroContrat as int64     no-undo.
    define input parameter pcTypeContrat   as character no-undo.
    define output parameter table for ttBatimentAssImm.

    define buffer tache for tache.
    define buffer ctctt for ctctt.
    define buffer intnt for intnt.
    define buffer batim for batim.
    
    empty temp-table ttBatimentAssImm.
    if not can-find(first ctrat no-lock
                    where ctrat.tpcon = pcTypeContrat
                      and ctrat.nocon = piNumeroContrat)
    then do:
        mError:createError({&error}, 100057).
        return.
    end.
    find last tache no-lock
        where tache.tpcon = pcTypeContrat
          and tache.nocon = piNumeroContrat
          and tache.tptac = {&TYPETACHE-affectationBatiment} no-error.
    for each ctctt no-lock
        where ctctt.tpct2 = pcTypeContrat
          and ctctt.noct2 = piNumeroContrat
      , each intnt no-lock
        where intnt.tpcon = ctctt.tpct1
          and intnt.nocon = ctctt.noct1
          and intnt.tpidt = {&TYPEBIEN-immeuble}
      , each batim no-lock
        where batim.noimm = intnt.noidt:
        create ttBatimentAssImm.
        assign
            ttBatimentAssImm.iNumeroContrat     = piNumeroContrat
            ttBatimentAssImm.cTypeContrat       = pcTypeContrat        
            ttBatimentAssImm.iNumeroBatiment    = batim.nobat
            ttBatimentAssImm.cCodeBatiment      = batim.cdbat
            ttBatimentAssImm.cNomBatiment       = batim.lbbat
            ttBatimentAssImm.cAdresseBatiment   = outilFormatage:formatageAdresse({&TYPEBIEN-batiment}, batim.nobat) 
            ttBatimentAssImm.lSelectionBatiment = no
            ttBatimentAssImm.CRUD               = 'R'
        .
        if available tache
        then assign
            ttBatimentAssImm.lSelectionBatiment = lookup(string(batim.nobat), tache.lbdiv) > 0
            ttBatimentAssImm.dtTimestamp        = datetime(tache.dtmsy, tache.hemsy)
            ttBatimentAssImm.rRowid             = rowid(tache)
        .
    end.

end procedure.

procedure setBatiment:
    /*------------------------------------------------------------------------------
    Purpose: maj affectation batiment 
    Notes  : service externe
    @param ttAttestationAssImm : liste batiment pour gestion affectation  
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroContrat as int64     no-undo.
    define input parameter pcTypeContrat   as character no-undo.    
    define input parameter table for ttBatimentAssImm.

    run majtbltch (piNumeroContrat, pcTypeContrat). 

end procedure.

procedure majtbltch private:
    /*------------------------------------------------------------------------------
    Purpose: maj tache batiment assurance immeuble
    Notes  : suite changement fonctionnement en modernisation, cette tache est toujours creee si il existe au moins un 
             batiment sur l'immeuble et supprimee si aucun batiment. 
             mise a jour systematique sans tenir compte du crud de la table ttBatimentAssImm.
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroContrat as int64     no-undo.
    define input parameter pcTypeContrat   as character no-undo.    
    
    define variable vlBatimentExiste as logical   no-undo.
    define variable vhTache          as handle    no-undo.
    define variable vhCttac          as handle    no-undo.
    define variable vcListeBatSel    as character no-undo. 

    define buffer tache for tache.
    define buffer cttac for cttac.
    define buffer ctctt for ctctt.
    define buffer intnt for intnt.
    define buffer batim for batim.

bouclBatExist:
    for each ctctt no-lock
        where ctctt.tpct2 = pcTypeContrat
          and ctctt.noct2 = piNumeroContrat
      , each intnt no-lock
        where intnt.tpcon = ctctt.tpct1
          and intnt.nocon = ctctt.noct1
          and intnt.tpidt = {&TYPEBIEN-immeuble}
      , each batim no-lock
        where batim.noimm = intnt.noidt:
        vlBatimentExiste = yes.
        leave bouclBatExist.
    end.
    if vlBatimentExiste then do:
        for each ttBatimentAssImm                  //constitution de la liste des batiments selectionnes  
           where ttBatimentAssImm.lSelection:
            vcListeBatSel = substitute('&1,&2', vcListeBatSel, string(ttBatimentAssImm.iNumeroBatiment)).
        end.
        vcListeBatSel = trim(vcListeBatSel, ',').
    end.
    find last tache no-lock
        where tache.tpcon = pcTypeContrat
          and tache.nocon = piNumeroContrat
          and tache.tptac = {&TYPETACHE-affectationBatiment} no-error.
    if vlBatimentExiste = no and not available tache then return.   //pas de batiment pour l'immeuble et tache inexistante, on ne fait rien

    empty temp-table ttTache.
    create ttTache.
    assign
        ttTache.tpcon = pcTypeContrat
        ttTache.nocon = piNumeroContrat
        ttTache.tptac = {&TYPETACHE-affectationBatiment}
        ttTache.lbdiv = vcListeBatSel 
    .   
    if available tache
    then assign
         ttTache.noita       = tache.noita
         ttTache.lbdiv       = vcListeBatSel 
         ttTache.notac       = tache.notac
         ttTache.CRUD        = string(vlBatimentExiste,"U/D")   //si pas de batiment pour l'immeuble on veut supprimer la tache
         ttTache.dtTimestamp = datetime(tache.dtmsy, tache.hemsy)             //on prend les infos de tache car ttBatimentAssImm n'existe pas si pas de batiment
         ttTache.rRowid      = rowid(tache)                                   //on prend les infos de tache car ttBatimentAssImm n'existe pas si pas de batiment
    .
    else assign
        ttTache.noita = 0
        ttTache.notac = 1
        ttTache.lbdiv = vcListeBatSel 
        ttTache.CRUD  = "C"
    .
    run tache/tache.p persistent set vhTache.
    run getTokenInstance in vhTache(mToken:JSessionId).
    run setTache in vhTache(table ttTache by-reference).
    run destroy in vhTache.  
    if mError:erreur() then return.

    empty temp-table ttCttac. 
    if can-find(last tache no-lock
                where tache.tpcon = pcTypeContrat
                  and tache.nocon = piNumeroContrat
                  and tache.tptac = {&TYPETACHE-affectationBatiment})
    then do:
        if not can-find(first cttac no-lock
                        where cttac.tpcon = pcTypeContrat
                          and cttac.nocon = piNumeroContrat
                          and cttac.tptac = {&TYPETACHE-affectationBatiment})
        then do:
            create ttCttac.
            assign
                ttCttac.tpcon = pcTypeContrat
                ttCttac.nocon = piNumeroContrat
                ttCttac.tptac = {&TYPETACHE-affectationBatiment}
                ttCttac.CRUD  = "C"
            .
        end. 
    end.
    else for first cttac no-lock
             where cttac.tpcon = pcTypeContrat
               and cttac.nocon = piNumeroContrat
               and cttac.tptac = {&TYPETACHE-affectationBatiment}:
        create ttCttac.
        assign
            ttCttac.tpcon       = cttac.tpcon
            ttCttac.nocon       = cttac.nocon
            ttCttac.tptac       = cttac.tptac
            ttCttac.CRUD        = "D"
            ttCttac.rRowid      = rowid(cttac)
            ttCttac.dtTimestamp = datetime(cttac.dtmsy, cttac.hemsy)
        .
    end.
    run adblib/cttac_CRUD.p persistent set vhCttac.
    run getTokenInstance in vhCttac(mToken:JSessionId).        
    run setCttac in vhCttac (table ttCttac by-reference).
    run destroy in vhCttac.            

end procedure.
