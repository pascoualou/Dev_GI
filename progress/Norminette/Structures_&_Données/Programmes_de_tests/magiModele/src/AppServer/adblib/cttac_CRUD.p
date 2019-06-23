/*------------------------------------------------------------------------
File        : cttac_CRUD.p
Purpose     : maj des relations contrat - tache
Author(s)   : GGA  -  2017/07/31
Notes       : pour l'instant seulement reprise de procedure creation et suppression
------------------------------------------------------------------------*/
{preprocesseur/nature2contrat.i}
{preprocesseur/type2adresse.i}
{preprocesseur/type2bien.i}
{preprocesseur/type2contrat.i}
{preprocesseur/type2role.i}
{preprocesseur/type2tache.i}
using parametre.pclie.parametrageFournisseurLoyer.
using parametre.pclie.parametrageBudgetLocatif.
using parametre.pclie.parametrageReleveGerance.

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

/* {adblib/include/cttac.i}*/
/* {application/include/error.i}*/
{adblib/include/cdpaycab.i}
define variable ghttCttac as handle no-undo.      // le handle de la temp table à mettre à jour

function getIndexField returns logical private(phBuffer as handle, output phTpcon as handle, output phNocon as handle, output phTptac as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des 3 champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tpcon/nocon/tptac, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when "tpcon" then phTpcon = phBuffer:buffer-field(vi).
            when "nocon" then phNocon = phBuffer:buffer-field(vi).
            when "tptac" then phTptac = phBuffer:buffer-field(vi).
        end case.
    end.
end function.

procedure crudCttac private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : 
    ------------------------------------------------------------------------------*/
    run deleteCttac.
    run updateCttac.
    run createCttac.
end procedure.

procedure setCttac:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe - A appeler avec by-reference.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCttac.
    ghttCttac = phttCttac.
    run crudCttac.
    delete object phttCttac.
end procedure.

procedure readCttac:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table cttac
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeContrat   as character no-undo.
    define input parameter piNumeroContrat as int64     no-undo.
    define input parameter pcTypeTache     as character no-undo.
    define input parameter table-handle vhttCttac.

    define variable vhttBuffer as handle no-undo.
    define buffer cttac for cttac.
    {&_proparse_ prolint-nowarn(noeffect)}
    integer(pcTypeTache) no-error.
    if error-status:error then do:
        mError:createError({&error}, error-status:get-message(1)).
        error-status:error = false no-error.
        return.
    end.
    if length(pcTypeTache, 'character') < 5 then pcTypeTache = string(integer(pcTypeTache), '99999').

    vhttBuffer = vhttCttac:default-buffer-handle.
    for first cttac no-lock
        where cttac.tpCon = pcTypeContrat
          and cttac.nocon = piNumeroContrat
          and cttac.tptac = pcTypeTache:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cttac:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object vhttcttac no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCttac:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table cttac correspondants au critère 
    Notes  : service utilisé par genoffqt.p?
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeContrat   as character no-undo.
    define input parameter piNumeroContrat as int64     no-undo.
    define input parameter table-handle phttCttac.

    define variable vhttBuffer as handle  no-undo.
    define buffer cttac for cttac.

    vhttBuffer = phttCttac:default-buffer-handle.
    if piNumeroContrat = ? or piNumeroContrat = 0
    then for each cttac no-lock
        where cttac.tpCon = pcTypeContrat:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cttac:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each cttac no-lock
        where cttac.tpCon = pcTypeContrat
          and cttac.nocon = piNumeroContrat:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cttac:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCttac no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCttac private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhTptac    as handle  no-undo.
    define buffer cttac for cttac.

    create query vhttquery.
    vhttBuffer = ghttCttac:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCttac:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon, output vhTptac).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cttac exclusive-lock
                 where rowid(cttac) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cttac:handle, 'tpcon/nocon/tptac: ', substitute("&1/&2/&3", vhTpcon:buffer-value(), vhNocon:buffer-value(), vhTptac:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer cttac:handle, vhttBuffer, 'U', mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCttac private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer cttac for cttac.

    create query vhttquery.
    vhttBuffer = ghttCttac:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCttac:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create cttac.
            if not outils:copyValidField(buffer cttac:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCttac private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhTptac    as handle  no-undo.
    define buffer cttac for cttac.

    create query vhttquery.
    vhttBuffer = ghttCttac:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCttac:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon, output vhTptac).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cttac exclusive-lock
                where rowid(cttac) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cttac:handle, 'tpcon/nocon/tptac: ', substitute("&1/&2/&3", vhTpcon:buffer-value(), vhNocon:buffer-value(), vhTptac:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete cttac no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure suppressionCttac:
    /*-----------------------------------------------------------------------------
    Purpose : Suppression d'un Enregistrement de cttac à partir de la clé.
    notes   : Anciennement SupCttac
    -----------------------------------------------------------------------------*/
    define input parameter pcTypeContrat   as character no-undo.
    define input parameter piNumeroContrat as int64     no-undo.
    define input parameter pcTypeTache     as character no-undo.
    define buffer cttac for cttac.

blocTrans:
    do transaction:
        find first cttac exclusive-lock
            where cttac.tpcon = pcTypeContrat
                and cttac.nocon = piNumeroContrat
                and cttac.tptac = pcTypeTache no-wait no-error.
        if not available cttac    // enregistrement déjà supprimé (par un autre utilisateur?)
        then mError:createError({&error},
                                if locked cttac then 211652 else 211651,
                                substitute("cttac: &1/&2/&3", pcTypeContrat, piNumeroContrat, pcTypeTache)).
        else do:
            delete cttac no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    assign error-status:error = false no-error.    // reset error-status
    return.

end procedure.

procedure GenTacLie:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes: service ?
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeContrat   as character no-undo.
    define input parameter piNumeroCOntrat as int64     no-undo.
    define input parameter pcNatureContrat as character no-undo.

    define variable voFournisseurLoyer as class parametrageFournisseurLoyer no-undo.
    define variable voBudgetLocatif    as class parametrageBudgetLocatif    no-undo.
    define variable voReleveGerance    as class parametrageReleveGerance    no-undo.
    define variable vcDepartementTaxeBureau  as character no-undo.
    define variable vcTypeContratPrincipal   as character no-undo.
    define variable viNumeroContratPrincipal as int64     no-undo.
    define variable vcNatureContratPrincipal as character no-undo.
    define variable vcListeTacheMandat       as character no-undo. /* Liste des taches du mandat associées à la compta ADB */
    define variable vcListeTacheBail         as character no-undo. /* Liste des taches du Bail associées à la compta ADB */
    define variable vcListeTachePrebail      as character no-undo. /* Liste des taches du Pré-Bail interdites */
    define variable vcCodeModele             as character no-undo. /* Variable pour gestion fourn. loyer */
    define variable vcCodePays               as character no-undo.

    define buffer vbSys_pg for sys_pg.
    define buffer sys_pg   for sys_pg.
    define buffer ctrat    for ctrat.
    define buffer cttac    for cttac.
    define buffer adres    for adres.
    define buffer ladrs    for ladrs.
    define buffer intnt    for intnt.

    assign
        vcDepartementTaxeBureau  = "75,77,78,91,92,93,94,95"             /* Liste des codes postaux concernés par taxe sur les bureaux */
        vcListeTacheMandat       = "04001,04102,04104,04105,04133,04344" /* Liste des Taches associées à la compta gestion (ADB) */
        vcListeTacheBail         = "04010,04104,04134"                   /* modif SY le 15/10/2013 : ajout 04344 */
        vcListeTachePrebail      = "04104,04134,04111,04153"
        voBudgetLocatif          = new parametrageBudgetLocatif('000')
        voFournisseurLoyer       = new parametrageFournisseurLoyer()
        voReleveGerance          = new parametrageReleveGerance()
        vcCodeModele             = voFournisseurLoyer:getCodeModele()
        vcTypeContratPrincipal   = pcTypeContrat
        viNumeroContratPrincipal = piNumeroCOntrat
    .
    delete object voFournisseurLoyer.
    if pcTypeContrat = {&TYPECONTRAT-bail}
    then assign
        vcTypeContratPrincipal = {&TYPECONTRAT-mandat2Gerance}
        viNumeroContratPrincipal = truncate(piNumeroCOntrat / 100000, 0)  // integer(substring(string(piNumeroCOntrat,"9999999999"), 1, 5)) /* NP 0608/0065 */
    .
    /* Récupération Nature du contrat principal */
    find first ctrat no-lock
        where ctrat.tpcon = vcTypeContratPrincipal
          and ctrat.nocon = viNumeroContratPrincipal no-error.
    if available ctrat then vcNatureContratPrincipal = ctrat.ntcon.
    /* Recherche des Tâches de Type 'Contrat'. */
boucle:
    for each sys_pg no-lock
        where sys_pg.tppar = 'R_CTA'
          and sys_pg.zone1 = pcNatureContrat
        by sys_pg.zone2:
        /* Contrôler le Type de Tâche. */
        find first vbsys_pg no-lock
            where vbsys_pg.tppar = 'O_TAE'
                and vbsys_pg.cdpar = sys_pg.zone2 no-error.
        if not available vbSys_pg then next boucle.

        /* Ne prendre en compte que le Tâches de Type 'C' et les Tâches de Type 'G' et de Type Auto... */
        if entry(1, vbSys_pg.zone9, '@') = 'C'
        or entry(3, vbSys_pg.zone9, '@') begins 'A'
        or entry(1, vbSys_pg.zone9, '@') = 'L' then do:
            /* Taxe sur bureau */
            if pcTypeContrat = {&TYPECONTRAT-mandat2Gerance} and sys_pg.zone2 = {&TYPETACHE-taxeSurBureau}
            then for first intnt no-lock
                where intnt.tpidt = {&TYPEBIEN-immeuble}
                  and intnt.tpcon = pcTypeContrat
                  and intnt.nocon = piNumeroCOntrat
              , first Ladrs no-lock
                where Ladrs.tpidt = intnt.tpidt
                 and Ladrs.noidt = intnt.noidt
                 and ladrs.tpadr = {&TYPEADRESSE-Principale}
              , first adres no-lock
                where adres.noadr = ladrs.noadr:
                vcCodePays = getPaysCabinet().
                if adres.cdpay <> vcCodePays
                or lookup(substring(adres.cdpos, 1, 2, "character"), vcDepartementTaxeBureau) = 0 then next boucle.
            end.
            /* Budget Locatif*/
            if pcTypeContrat = {&TYPECONTRAT-mandat2Gerance} and Sys_pg.Zone2 = {&TYPETACHE-budgetLocatif} then do:
                if not voBudgetLocatif:isBudgetLocatifActif()
                or (pcNatureContrat <> {&NATURECONTRAT-mandatAvecIndivision}
                and pcNatureContrat <> {&NATURECONTRAT-mandatSansIndivision}) then next boucle.
            end.
            /* Filtrer les tache liées à la compta pour les mandats location (03075) et les baux associés, les Pré-baux */
            if pcTypeContrat = {&TYPECONTRAT-mandat2Gerance}
                and (pcNatureContrat = {&NATURECONTRAT-mandatLocation}
                  or pcNatureContrat = {&NATURECONTRAT-mandatLocationIndivision}
                  or pcNatureContrat = {&NATURECONTRAT-mandatLocationDelegue})
                and lookup(sys_pg.zone2, vcListeTacheMandat, ",") > 0
                and integer(vcCodeModele) < 3 then next boucle.

            if pcTypeContrat = {&TYPECONTRAT-bail}
                and (vcNatureContratPrincipal = {&NATURECONTRAT-mandatLocation}
                  or vcNatureContratPrincipal = {&NATURECONTRAT-mandatLocationIndivision}
                  or vcNatureContratPrincipal = {&NATURECONTRAT-mandatLocationDelegue})
                and lookup(sys_pg.zone2, vcListeTacheBail, ",") > 0
                and integer(vcCodeModele) < 3 then next boucle.
            /* Ajout SY le 15/10/2013: Filtrage Taches qui ne concernent pas Manpower */
            if integer(mToken:cRefPrincipale) = 10 //  todo vérifier que c'est la bonne ref! if integer(NoRefUse) = 10 then do:
            then do:
                if pcTypeContrat = {&TYPECONTRAT-mandat2Gerance}
                and (lookup(sys_pg.zone2, vcListeTacheMandat, ",") > 0                 /* pas de compta */
                  or sys_pg.zone2 = {&TYPETACHE-usufruitNuePropriete6} 
                  or sys_pg.zone2 = {&TYPETACHE-mutation}) then next boucle.

                if pcTypeContrat = {&TYPECONTRAT-bail}
                and lookup (sys_pg.zone2, vcListeTacheBail, ",") > 0 then next boucle. /* pas de compta */
            end.

            /* La tache "Bailleur" est réservée aux baux rattachés à un mandat sous-location pour le modele "Lots isoles" (CREDIT LYONNAIS) */
            if sys_pg.zone2 = {&TYPETACHE-bailleur}
            and (integer(vcCodeModele) <> 2
             or (vcNatureContratPrincipal <> {&NATURECONTRAT-mandatSousLocation}
             and vcNatureContratPrincipal <> {&NATURECONTRAT-mandatSousLocationDelegue})
             or pcTypeContrat <> {&TYPECONTRAT-bail}) then next boucle.

            /* Pré-Baux : Filtrer les taches interdites */
            if pcTypeContrat = {&TYPECONTRAT-preBail}
            and lookup(sys_pg.zone2, vcListeTachePrebail, ",") > 0 then next boucle.

            if can-find(first cttac no-lock
                        where cttac.tpcon = pcTypeContrat
                          and cttac.nocon = piNumeroCOntrat
                          and cttac.tptac = sys_pg.zone2) then next boucle.

            /* Appels de fonds relevés ssi param à "OUI" */
            if pcTypeContrat = {&TYPECONTRAT-mandat2Syndic} and Sys_pg.Zone2 = {&TYPETACHE-appelFondConsommation}
            then do:
                if not voReleveGerance:isDbParameter or not voReleveGerance:isReleveEauGeranceCreeParLaCopropriete() then next boucle.

                /* Génération de la Relation Contrat/Tâche. */
                create cttac.
                assign
                    cttac.tpcon = pcTypeContrat
                    cttac.nocon = piNumeroCOntrat
                    cttac.tptac = sys_pg.zone2
                    cttac.dtcsy = today
                    cttac.hecsy = mtime
                    cttac.cdcsy = mToken:cUser
                    cttac.dtmsy = cttac.dtcsy
                    cttac.hemsy = cttac.hecsy
                    cttac.cdmsy = mToken:cUser
                NO-ERROR.
                if error-status:error then do:
                    mError:createError({&error}, error-status:get-message(1)).
                    undo, leave.
                end.
            end.
        end.
    end.
    delete object voBudgetLocatif no-error.
    delete object voReleveGerance no-error.

end procedure.

procedure deleteCttacSurContrat:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant aux parametres de selection 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeContrat   as character no-undo.
    define input parameter piNumeroContrat as int64     no-undo.
    
    define buffer cttac for cttac.

message "deleteCttacSurContrat "  pcTypeContrat "// " piNumeroContrat.

blocTrans:
    do transaction:
        for each cttac exclusive-lock 
           where cttac.tpcon = pcTypeContrat 
             and cttac.nocon = piNumeroContrat:
            delete cttac no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    error-status:error = false no-error.  // reset error-status

end procedure.
