/*------------------------------------------------------------------------
File        : baseCalculRubrique.p
Purpose     :
Author(s)   : DM 2017/10/03
Notes       : à partir de adb/src/cabt/basecalc.p
------------------------------------------------------------------------*/
{preprocesseur/type2contrat.i}
{preprocesseur/type2tache.i}

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */
{application/include/glbsepar.i}
{tache/include/paramBaseRubrique.i}
{adblib/include/rubsel.i}

define temp-table ttCabinetRubrique no-undo
    field iCodeFamille      as integer    label "cdfam" initial ?
    field iCodeSousFamille  as integer    label "cdsfa" initial ?
    field iCodeRubrique     as integer    label "cdrub" initial ?
    field iCodeLibelle      as integer    label "cdlib" initial ?
    field cLibelleRubrique  as character  label "lbrub" initial ?
    field cCodeGenre        as character  label "cdgen" initial ?
.

procedure updateParamBaseRubrique:
    /*------------------------------------------------------------------------------
    Purpose: Mise à jour d'une base de calcul et des rubriques sélectionnées + creation base de calcul
    Notes  : service externe (beMandatGerance.cls)
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeTache as character no-undo.
    define input parameter table for ttBaseCalcul.
    define input parameter table for ttFamilleRubrique.
    define input parameter table for ttRubrique.

    define variable vhProcRubsel as handle    no-undo.
    define variable vcNxt-ixd01  as character no-undo.
    define variable viNxt-ixd01  as int64     no-undo.
    define variable vlMaj        as logical   no-undo.
    define variable vlSup        as logical   no-undo.
    define buffer honor  for honor.
    define buffer detail for detail.
    define buffer rubsel for rubsel.

    run adblib/l_rubsel_ext.p persistent set vhProcRubsel.
    run getTokenInstance in vhProcRubsel(mToken:JSessionId).

blocTrans:
    do transaction:
        for each ttBaseCalcul where lookup(ttBaseCalcul.CRUD, 'C,U,D') > 0:
            if ttBaseCalcul.CRUD = "D"
            then for first rubsel exclusive-lock
                where rubsel.tpmdt = ""
                  and rubsel.nomdt = 0
                  and rubsel.tpct2 = ""
                  and rubsel.noct2 = 0
                  and rubsel.tptac = pcTypeTache
                  and rubsel.ixd01 = ttBaseCalcul.cCodeBaseCalcul
                  and rubsel.tprub = ""
                  and rubsel.cdrub = ""
                  and rubsel.cdlib = "":
                if pcTypeTache = {&TYPETACHE-quittancementRubCalculees}
                then for first detail no-lock
                    where detail.cddet = {&TYPECONTRAT-bail}
                      and detail.tbchr[1] = ttBaseCalcul.cCodeBaseCalcul :
                    mError:createError({&error}, 1000322, string(detail.nodet)). /* Cette base de calcul est utilisée sur le bail n° &1. Suppression impossible. */
                    undo blocTrans, leave blocTrans.
                end.
                else for first honor no-lock
                    where honor.tphon = "13000"
                     and honor.bshon = ttBaseCalcul.cCodeBaseCalcul :
                    mError:createError({&error}, 1000322, string(honor.cdhon)). /* Cette base de calcul est utilisée dans le barème n° &1. Suppression impossible. */
                    undo blocTrans, leave blocTrans.
                end.
                empty temp-table ttRubsel.
                create ttRubsel.
                outils:copyValidField(buffer rubsel:handle, buffer ttRubsel:handle).
                run delRubSel in vhProcRubsel(buffer ttrubsel).
                vlSup = true.
            end.
            else do : /* U/C */
                /* controles */
                if ttBaseCalcul.cLibelleCourt = "" or ttBaseCalcul.cLibelleCourt = ? then do:
                    mError:createError({&error}, 1000324, (if ttBaseCalcul.CRUD = "C" then " " else ttBaseCalcul.cCodeBaseCalcul)). /* 1000324 Vous devez saisir le libellÃ© court de la base de calcul &1  */
                    undo blocTrans, leave blocTrans.
                end.
                if ttBaseCalcul.cLibelleLong = "" or ttBaseCalcul.cLibelleLong = ? then do:
                    mError:createError({&error}, 1000325, (if ttBaseCalcul.CRUD = "C" then " " else ttBaseCalcul.cCodeBaseCalcul)). /* 1000325 Vous devez saisir le libellé long de la base de calcul &1 */
                    undo blocTrans, leave blocTrans.
                end.
                if not can-find(first ttRubrique
                    where ttRubrique.cCodeBaseCalcul = ttBaseCalcul.cCodeBaseCalcul
                      and ttRubrique.lSelection) then do:
                    mError:createError({&error}, 1000326, (if ttBaseCalcul.CRUD = "C" then " " else ttBaseCalcul.cCodeBaseCalcul)). /* 1000326 Vous devez saisir au moins une rubrique pour la base de calcul */
                    undo blocTrans, leave blocTrans.
                end.
                /* maj / cre entete base de calcul */
                if ttBaseCalcul.CRUD = "C" then do:
                    assign
                        vcNxt-ixd01 = ""
                        viNxt-ixd01 = 0
                    .
                    for each rubsel no-lock    // todo   by .... descending. vcNxt-ixd01 = rubsel.ixd01. leave.
                        where rubsel.tpmdt = ""
                          and rubsel.nomdt = 0
                          and rubsel.tpct2 = ""
                          and rubsel.noct2 = 0
                          and rubsel.tptac = pcTypeTache
                          by rubsel.nomdt by rubsel.tpct2 by rubsel.noct2 by rubsel.tptac by rubsel.ixd01:
                        vcNxt-ixd01 = rubsel.ixd01.
                    end.
                    assign
                        viNxt-ixd01 = (if vcNxt-ixd01 > ""
                                       then int64(vcNxt-ixd01) + 1
                                       else if pcTypeTache = {&TYPETACHE-quittancementRubCalculees} then 50001 else 30001)
                    no-error.
                    if error-status:error then do:
                        mError:createError({&error}, 111623). /* Impossible de créer une nouvelle base de calcul (erreur Nxtrubsel) */
                        undo blocTrans, leave blocTrans.
                    end.
                end.
                else do: /* Update */
                    find first rubsel exclusive-lock
                        where rubsel.tpmdt = ""
                          and rubsel.nomdt = 0
                          and rubsel.tpct2 = ""
                          and rubsel.noct2 = 0
                          and rubsel.tptac = pcTypeTache
                          and rubsel.ixd01 = ttBaseCalcul.cCodeBaseCalcul
                          and rubsel.tprub = ""
                          and rubsel.cdrub = ""
                          and rubsel.cdlib = "" no-error.
                    if not available rubsel then do:
                        mError:createError({&error}, 1000215,  substitute("&1 &2", outilTraduction:getLibelle(705079), ttBaseCalcul.cCodeBaseCalcul)). /* 1000215 = &1 inexistante - 705079 = Base de Calcul */
                        undo blocTrans, leave blocTrans.
                    end.
                    viNxt-ixd01 = int64(ttBaseCalcul.cCodeBaseCalcul).
                end. /* update */

                empty temp-table ttRubsel.
                create ttRubsel.
                assign
                    ttRubsel.ixd01       = string(viNxt-ixd01,"99999") /* en modif cCodebaseCalcul a une valeur */
                    ttRubsel.tpmdt       = ""
                    ttRubsel.nomdt       = 0
                    ttRubsel.tpct2       = ""
                    ttRubsel.noct2       = 0
                    ttRubsel.tptac       = pcTypeTache
                    ttRubsel.tprub       = ""
                    ttRubsel.cdrub       = ""
                    ttRubsel.cdlib       = ""
                    ttRubsel.notri       = 0
                    ttRubsel.lbdiv       = substitute("&1&2&3", trim(string(ttBaseCalcul.cLibelleCourt, "x(30)")), separ[2], trim(string(ttBaseCalcul.cLibelleLong, "x(60)")))
                    ttRubsel.dtTimestamp = ttBaseCalcul.dtTimestamp
                    ttRubsel.CRUD        = ttBaseCalcul.CRUD
                    ttRubsel.rRowid      = ttBaseCalcul.rRowid
                .
                if ttBaseCalcul.CRUD = "C"
                then run newRubSel in vhProcRubsel(buffer ttRubsel).                /* Création nouvel enregistrement de rubsel */
                else run majRubSel in vhProcRubsel(buffer rubsel, buffer ttRubsel). /* Modification enregistrement de rubsel */
                vlMaj = true.

                /* maj / cre rubrique base de calcul */
                for each ttRubrique
                    where ttRubrique.cCodeBaseCalcul = ttBaseCalcul.cCodeBaseCalcul
                      and ttRubrique.CRUD = "U" :
                    find first rubsel no-lock
                        where rubsel.tpmdt = ""
                          and rubsel.nomdt = 0
                          and rubsel.tpct2 = ""
                          and rubsel.noct2 = 0
                          and rubsel.tptac = pcTypeTache
                          and rubsel.ixd01 = string(viNxt-ixd01, "99999")
                          and rubsel.tprub = (if pcTypeTache = {&TYPETACHE-quittancementRubCalculees} then "Q" else "H")
                          and rubsel.cdrub = string(ttRubrique.iCodeRubrique, "999")
                          and rubsel.cdlib = string(ttRubrique.iCodeLibelle, "99") no-error.
                    if available rubsel and not ttRubrique.lSelection then do:
                        empty temp-table ttRubsel.
                        create ttRubsel.
                        outils:copyValidField(buffer rubsel:handle, buffer ttRubsel:handle).
                        run delRubSel in vhProcRubsel(buffer ttrubsel).       /* suppression rubrique selectionné  */
                    end.
                    if not available rubsel and ttRubrique.lSelection then do:
                        empty temp-table ttRubsel.
                        create ttRubsel.
                        assign
                            ttRubsel.ixd01      = string(viNxt-ixd01, "99999")
                            ttRubsel.tpmdt       = ""
                            ttRubsel.nomdt       = 0
                            ttRubsel.tpct2       = ""
                            ttRubsel.noct2       = 0
                            ttRubsel.tptac       = pcTypeTache
                            ttRubsel.tprub       = (if pcTypeTache = {&TYPETACHE-quittancementRubCalculees} then "Q" else "H")
                            ttRubsel.cdrub       = string(ttRubrique.iCodeRubrique, "999")
                            ttRubsel.cdlib       = string(ttRubrique.iCodeLibelle, "99")
                            ttRubsel.dtTimestamp = ttRubrique.dtTimestamp
                            ttRubsel.CRUD        = ttRubrique.CRUD
                            ttRubsel.rRowid      = ttRubrique.rRowid
                        .
                        run newRubSel in vhProcRubsel(buffer ttRubsel).   /* creation rubrique selectionnée dans rubsel */
                    end.
                end.
            end.
            if mError:erreur() then undo blocTrans, leave blocTrans.
        end. /* for each */
        if vlMaj and not mError:erreur() then mError:createError({&info}, 1000254, " "). /* Mise à jour effectuée */
        if vlSup and not mError:erreur() then mError:createError({&info}, 103340).       /* Suppression effectuée */
    end. /* transaction */
    run destroy   in vhProcRubsel.
    error-status:error = false no-error.  // reset error-status
    return.                               // reset return-value
end procedure.

procedure getParamBaseCalcul private :
    /*------------------------------------------------------------------------------
    Purpose: Donne la liste des bases de calcul / familles / rubriques de quittanceement
    Notes  : service externe (beMandatGerance.cls)
    ------------------------------------------------------------------------------*/
    define input  parameter plFamille             as logical   no-undo. 
    define input  parameter pcTypeTrt             as character no-undo.
    define input  parameter pcTypeTache           as character no-undo.
    define input  parameter pcListeCodeBaseCalcul as character no-undo.
    
    define variable viI           as integer   no-undo.
    define variable vcWhereClause as character no-undo.
    define variable vcCodeBaseCalcul  as character no-undo.
    define variable vhBuffer      as handle    no-undo.
    define variable vhquery       as handle    no-undo.

    create buffer vhBuffer for table "rubsel".
    create query vhquery.
    vhquery:set-buffers(vhBuffer).
    if pcListeCodeBaseCalcul = "" or pcListeCodeBaseCalcul = ? then pcListeCodeBaseCalcul = " ". // Pour rentrer dans le do si valeur nulle ou vide
    do viI = 1 to num-entries(pcListeCodeBaseCalcul) :
        vcCodeBaseCalcul = trim(entry(viI, pcListeCodeBaseCalcul)).
        vcWhereClause =  substitute("where rubsel.tpmdt = ''
                                       and rubsel.nomdt = 0
                                       and rubsel.tpct2 = ''
                                       and rubsel.noct2 = 0
                                       and rubsel.tptac = '&1'
                                       and rubsel.tprub = ''
                                       and rubsel.cdrub = ''
                                       and rubsel.cdlib = ''"
                                     , pcTypeTache).
        if vcCodeBaseCalcul > "" then vcWhereClause = substitute("&1 and rubsel.ixd01 = '&2'", vcWhereClause, vcCodeBaseCalcul).
        vhquery:query-prepare(substitute('for each rubsel no-lock &1', vcWhereClause)).
        vhquery:query-open().
boucle:
        repeat:
            vhquery:get-next().
            if vhquery:query-off-end then leave boucle.
            run  crettBaseCalcul (pcTypeTache,
                                  vhBuffer::ixd01, 
                                  entry(1, vhBuffer::lbdiv, separ[2]), 
                                  if num-entries(vhBuffer::lbdiv, separ[2]) >= 2 then entry(2, vhBuffer::lbdiv, separ[2]) else "", 
                                  "R",
                                  datetime(vhBuffer::dtmsy, vhBuffer::hemsy),
                                  vhBuffer:rowid).
            if plFamille then do :                                   
                run chgttFamilleRubriqueRub(pcTypeTache, vhBuffer::ixd01). /* chargement liste des Familles + sous-familles et Table des rubriques */    
                run setttFamilleRubrique(vhBuffer::ixd01).                 /* Mise à jour flag selection des Familles + sous-familles utilisées */
            end.                
        end.
    end.
end.

procedure getParamBaseRubrique :
    /*------------------------------------------------------------------------------
    Purpose: Donne la liste des bases de calcul / familles / rubriques de quittanceement
    Notes  : service externe (beMandatGerance.cls)
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeTrt             as character no-undo.
    define input  parameter pcTypeTache           as character no-undo.
    define input  parameter pcListeCodeBaseCalcul as character no-undo.
    define output parameter table for ttBaseCalcul.
    define output parameter table for ttFamilleRubrique.
    define output parameter table for ttRubrique.
    
    define variable viI           as integer   no-undo.
    define variable vcWhereClause as character no-undo.
    define variable vcCodeBaseCalcul  as character no-undo.
    define variable vhBuffer      as handle    no-undo.
    define variable vhquery       as handle    no-undo.
    
    empty temp-table ttBaseCalcul.    
    empty temp-table ttFamilleRubrique.
    empty temp-table ttRubrique.
    
   run chgttCabinetRubrique(pcTypeTache).
    
    case pcTypeTrt :
        when "INITIALISATION" then do :
            run  crettBaseCalcul (pcTypeTache,
                                  "", 
                                  "", 
                                  "", 
                                  "R",
                                  ?,
                                  ?).
            run chgttFamilleRubriqueRub(pcTypeTache, ""). /* chargement liste des Familles + sous-familles et Table des rubriques */    
            run setttFamilleRubrique("").                 /* Mise à jour flag selection des Familles + sous-familles utilisées */
        end.
        otherwise run getParamBaseCalcul(true, pcTypeTrt, pcTypeTache, pcListeCodeBaseCalcul).
    end case.        
end procedure.


procedure getBaseCalcul :
    /*------------------------------------------------------------------------------
    Purpose: Donne la liste des bases de calcul 
    Notes  : appelé par  (baremehonoraire.p)
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeTrt             as character no-undo.
    define input  parameter pcTypeTache           as character no-undo.
    define input  parameter pcListeCodeBaseCalcul as character no-undo.
    define output parameter table for ttBaseCalcul.
    
    empty temp-table ttBaseCalcul.    
    
    run getParamBaseCalcul(false, pcTypeTrt, pcTypeTache, pcListeCodeBaseCalcul).
        
end procedure.


procedure crettBaseCalcul private :
    /*------------------------------------------------------------------------------
    Purpose: creation ttBaseDeCalcul
    Notes  : appelé aussi depuis baremeHonoraireCabinet.p
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeTache      as character no-undo.
    define input parameter pcCodeBaseCalcul as character no-undo.
    define input parameter pcLibelleCourt   as character no-undo.
    define input parameter pcLibelleLong    as character no-undo.
    define input parameter pcCRUD           as character no-undo.
    define input parameter pdtTimeStamp     as datetime  no-undo.
    define input parameter prRowid          as rowid     no-undo.
    
    create ttBaseCalcul.
    assign
    ttBaseCalcul.cCodeBaseCalcul = pcCodeBaseCalcul
    ttBaseCalcul.cLibelleCourt   = pcLibelleCourt
    ttBaseCalcul.CRUD            = "R"
    ttBaseCalcul.cLibelleLong    = pcLibelleLong
    ttBaseCalcul.dtTimestamp     = pdtTimeStamp
    ttBaseCalcul.rRowid          = prRowid
    ttBaseCalcul.cTypeBase       = "CLIENT"
    ttBaseCalcul.cTypeHonoraire  = "13000"
    .
end procedure.

procedure chgttFamilleRubriqueRub private: 
    /*------------------------------------------------------------------------------
    Purpose: Procedure de chargement de la liste des Familles + sous-familles autorisées + Rubriques
    Notes  : code issu de adb/src/basecalq.p
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeTache      as character no-undo.
    define input parameter pcCodeBaseCalcul as character no-undo.
    
    define variable vcLibelleFamille        as character   no-undo.
    
    define buffer famqt  for famqt.
    define buffer rubsel for rubsel.
    
    for each famqt no-lock 
            where   famqt.cdfam >= 01 and famqt.cdfam < (if pcTypeTache = {&TYPETACHE-quittancementRubCalculees} then 4 /* Loyer , Charges , Divers */ else 8)  
            break by famqt.cdfam by famqt.cdsfa:
            if first-of (famqt.cdsfa) 
            then assign vcLibelleFamille = substitute("&1 - &2", string(famqt.cdfam,"99"), outilTraduction:getLibelle(famqt.nome1)).
            if last-of (famqt.cdsfa) and famqt.cdsfa > 0 then do: 
                create ttFamilleRubrique.
                assign
                ttFamilleRubrique.cCodeBaseCalcul       = pcCodeBaseCalcul
                ttFamilleRubrique.iCodeFamille          = famqt.cdfam
                ttFamilleRubrique.cLibelleFamille       = vcLibelleFamille
                ttFamilleRubrique.iCodeSousFamille      = famqt.cdsfa
                ttFamilleRubrique.cLibelleSousFamille   = substitute("&1 - &2", string(famqt.cdsfa,"99"), outilTraduction:getLibelle(famqt.nome1))
                .
            end.
    end.   
        
    /* Rubriques */
    for each ttCabinetRubrique:
        create ttRubrique.
        outils:copyValidField(buffer ttCabinetRubrique:handle, buffer ttRubrique:handle).
        assign ttRubrique.cCodeBaseCalcul = pcCodeBaseCalcul
               ttRubrique.lSelection    = false
               ttRubrique.CRUD          = "R"
               ttRubrique.dtTimestamp   = ? 
               ttRubrique.rRowid        = ?
        .
        for first rubsel no-lock 
                where rubsel.tpmdt = ""
                and   rubsel.nomdt = 0
                and   rubsel.tpct2 = ""
                and   rubsel.noct2 = 0
                and   rubsel.tptac = pcTypeTache 
                and   rubsel.ixd01 = pcCodeBaseCalcul
                and   rubsel.tprub = (if pcTypeTache = {&TYPETACHE-quittancementRubCalculees} then "Q" else "H")
                and   rubsel.cdrub = string(ttCabinetRubrique.iCodeRubrique,"999")
                and   rubsel.cdlib = string(ttCabinetRubrique.iCodeLibelle,"99") :
            assign
                ttRubrique.dtTimestamp = datetime(rubsel.dtmsy, rubsel.hemsy)
                ttRubrique.lSelection  = true
                ttRubrique.rRowid      = rowid(rubsel)
            .
        end.
    end.
end procedure.

procedure chgttCabinetRubrique private:
    /*------------------------------------------------------------------------------
    Purpose: creation ttCabinetRubrique - Liste des rubrique quittancement
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeTache as character no-undo.

    define buffer rubqt for rubqt.
    define buffer prrub for prrub.

    empty temp-table ttCabinetRubrique.

    for each rubqt no-lock    // todo  whole index !!!!!!!!!!!!!!
        where rubqt.cdfam < (if pcTypeTache = {&TYPETACHE-Honoraires} then 8 else 4)
          and rubqt.cdLib > 0
      , first prrub no-lock
        where prrub.cdrub = rubqt.cdrub
          and prrub.cdlib = rubqt.cdlib
          and prrub.noloc = 0
          and prrub.cdaff = "00001":
        create ttCabinetRubrique.
        outils:copyValidLabeledField(buffer rubqt:handle, buffer ttCabinetRubrique:handle).
        outils:copyValidLabeledField(buffer prrub:handle, buffer ttCabinetRubrique:handle).
        if ttCabinetRubrique.cLibelleRubrique = "" then ttCabinetRubrique.cLibelleRubrique = outilTraduction:getLibelle(rubqt.nome1).
    end.            
end procedure.

procedure setttFamilleRubrique private:
    /*------------------------------------------------------------------------------
    Purpose: Mise à jour de ttFamilleRubrique.lSelection
    Notes  : 
    ------------------------------------------------------------------------------*/
    define input parameter pcCodeBaseCalcul as character no-undo.
    
    for each ttFamilleRubrique where ttFamilleRubrique.cCodeBaseCalcul = pcCodeBaseCalcul:
        ttFamilleRubrique.lSelection = false.
    end.
    /* Initialisation des familles sous-familles sélectionnées */
    for each ttRubrique 
        where ttRubrique.cCodeBaseCalcul = pcCodeBaseCalcul 
        and   ttRubrique.lSelection
        , first ttFamilleRubrique
        where ttFamilleRubrique.cCodeBaseCalcul = pcCodeBaseCalcul
        and   ttFamilleRubrique.iCodeFamille = ttRubrique.iCodeFamille  
        and   ttFamilleRubrique.iCodeSousFamille = ttRubrique.iCodeSousFamille
        break by ttRubrique.lSelection by ttRubrique.iCodeFamille by ttRubrique.iCodeSousFamille:
        if first-of (ttRubrique.iCodeSousFamille) then do:
            ttFamilleRubrique.lSelection = true.
        end.
    end.  
end procedure.   


