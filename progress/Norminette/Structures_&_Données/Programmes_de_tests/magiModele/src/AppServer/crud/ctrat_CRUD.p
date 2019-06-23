/*------------------------------------------------------------------------
File        : ctrat_CRUD.p
Purpose     :
Author(s)   : kantena -
Notes       : il reste les méthodes suivante a adapter : Mj2Ctrat, Mj4ctrat, Mj5ctrat, Mj6ctrat
derniere revue: 2018/04/27 - phm: OK
------------------------------------------------------------------------*/
{preprocesseur/type2contrat.i}
{preprocesseur/nature2contrat.i}
{preprocesseur/mode2gestionFournisseurLoyer.i}

using parametre.pclie.parametrageFournisseurLoyer.
using parametre.syspg.syspg.

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */
{mandat/include/listeNumeroContratDispo.i}

define variable ghttctrat         as handle no-undo.      // le handle de la temp table à mettre à jour
define variable goCollectionGesFL as class collection no-undo.

function getIndexField returns logical private(phBuffer as handle, output phTpcon as handle, output phNocon as handle, output phNodoc as handle, output phNtcon as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nodoc,
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tpcon' then phTpcon = phBuffer:buffer-field(vi).
            when 'nocon' then phNocon = phBuffer:buffer-field(vi).
            when 'nodoc' then phNodoc = phBuffer:buffer-field(vi).
            when 'ntcon' then phNtcon = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

function getInfosGESFL returns collection private ():
    /*------------------------------------------------------------------------------
    Purpose: récupère toutes les infos concernant la gestion des mandats FL
    Notes:
    ------------------------------------------------------------------------------*/
    define variable vcCdModele               as character no-undo.
    define variable viSousLocationDeb        as int64     no-undo.
    define variable viSousLocationFin        as int64     no-undo.
    define variable vlFournisseurLoyer       as logical   no-undo.
    define variable viFournisseurLoyerDebut  as integer   no-undo.
    define variable voFournisseurLoyer       as class parametrageFournisseurLoyer no-undo.

    assign
        goCollectionGesFL        = new collection()
        voFournisseurLoyer       = new parametrageFournisseurLoyer("00001") // Dans tous les cas on recherche le paramètre fournisseurs loyer, Valeurs par défaut
        vlFournisseurLoyer       = voFournisseurLoyer:isGesFournisseurLoyer()
        vcCdModele               = voFournisseurLoyer:getCodeModele()
        viSousLocationDeb        = voFournisseurLoyer:getImmeubleDebut()
        viSousLocationFin        = voFournisseurLoyer:getImmeubleFin()
        viFournisseurLoyerDebut  = voFournisseurLoyer:getFournisseurLoyerDebut()
    .
    goCollectionGesFL:set("lFournisseurLoyer",       vlFournisseurLoyer).
    goCollectionGesFL:set("cCdModele",               vcCdModele).
    goCollectionGesFL:set("iSousLocationDeb",        viSousLocationDeb).
    goCollectionGesFL:set("iSousLocationFin",        viSousLocationFin).
    goCollectionGesFL:set("iFournisseurLoyerDebut",  viFournisseurLoyerDebut).

    return goCollectionGesFL.

end function.

procedure crudCtrat private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCtrat.
    run updateCtrat.
    run createCtrat.
end procedure.

procedure setCtrat:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCtrat.
    ghttCtrat = phttCtrat.
    run crudCtrat.
    delete object phttCtrat.
end procedure.

procedure readCtrat:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ctrat
    Notes  : service externe (genoffqt.p, ...)
    ------------------------------------------------------------------------------*/
    define input parameter pcTpcon as character no-undo.
    define input parameter piNocon as int64     no-undo.
    define input parameter table-handle phttCtrat.
    define variable vhttBuffer as handle no-undo.
    define buffer ctrat for ctrat.

    vhttBuffer = phttCtrat:default-buffer-handle.
    for first ctrat no-lock
        where ctrat.tpcon = pcTpcon
          and ctrat.nocon = piNocon:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ctrat:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCtrat no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCtrat:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ctrat
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter pcTpcon as character no-undo.
    define input parameter table-handle phttCtrat.
    define variable vhttBuffer as handle  no-undo.
    define buffer ctrat for ctrat.

    vhttBuffer = phttCtrat:default-buffer-handle.
    for each ctrat no-lock
        where ctrat.tpcon = pcTpcon:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ctrat:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCtrat no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCtrat private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : (mandat.p, immeuble.p, objetAssImm.p, ...)
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhNodoc    as handle  no-undo.
    define variable vhNtcon    as handle  no-undo.
    define buffer ctrat for ctrat.

    create query vhttquery.
    vhttBuffer = ghttCtrat:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCtrat:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon, output vhNodoc, output vhNtcon).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ctrat exclusive-lock
                where rowid(ctrat) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ctrat:handle, 'tpcon/nocon: ', substitute('&1/&2', vhTpcon:buffer-value(), vhNocon:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ctrat:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCtrat private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable viNoDocSui as int64    no-undo.
    define variable viNoConSui as int64    no-undo.
    define variable vhTpcon    as handle   no-undo.
    define variable vhNocon    as handle   no-undo.
    define variable vhNodoc    as handle   no-undo.
    define variable vhNtcon    as handle   no-undo.
    define buffer ctrat for ctrat.

    create query vhttquery.
    vhttBuffer = ghttCtrat:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCtrat:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon, output vhNodoc, output vhNtcon).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            run getNextContrat(vhTpcon:buffer-value(), vhNtcon:buffer-value(), 0, 0, output viNoDocSui, output viNoConSui).
            if mError:erreur() then undo blocTrans, leave blocTrans.
            assign
                vhNocon:buffer-value() = viNoConSui when vhNocon:buffer-value() = ? or vhNocon:buffer-value() = 0
                vhNodoc:buffer-value() = viNoDocSui
            .
            create ctrat.
            if not outils:copyValidField(buffer ctrat:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCtrat private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhNodoc    as handle  no-undo.
    define variable vhNtcon    as handle  no-undo.
    define buffer ctrat for ctrat.
    define buffer notes for notes.

    create query vhttquery.
    vhttBuffer = ghttCtrat:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCtrat:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon, output vhNodoc, output vhNtcon).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ctrat exclusive-lock
                where rowid(Ctrat) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ctrat:handle, 'tpcon/nocon: ', substitute('&1/&2', vhTpcon:buffer-value(), vhNocon:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            //suppression des commentaires
            if ctrat.noblc > 0 then
                for each notes exclusive-lock
                    where notes.noblc = ctrat.noblc:
                    delete notes.
                end.
            delete ctrat no-error.
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

procedure getNextContrat:
    /*------------------------------------------------------------------------------
    Purpose: Procedure qui permet de connaitre le prochain N° de ctrat libre.
    Notes  : service externe (mandat, mutation ....) et interne (createCtrat)
    ------------------------------------------------------------------------------*/
    define input parameter  pcTypeContrat            as character no-undo.
    define input parameter  pcNatureContrat          as character no-undo.
    define input parameter  piNumeroContratPrincipal as int64     no-undo.
    define input parameter  piNumeroAppartement      as integer   no-undo.
    define output parameter piNumeroDocumentSuivant  as integer   no-undo.
    define output parameter piNumeroContratSuivant   as int64     no-undo.

    define variable viNoBorInf         as int64   no-undo.
    define variable viNoBorSup         as int64   no-undo.
    define variable viNoOrdSal         as integer no-undo.
    define variable viNoNxtSal         as integer no-undo.
    define variable viAnnee            as integer no-undo.
    define variable viChrono           as int64   no-undo.
    define variable viReferenceContrat as integer no-undo.

    define buffer ctrat  for ctrat.
    define buffer csscpt for csscpt.

    {&_proparse_ prolint-nowarn(wholeindex)}
    find last ctrat no-lock no-error.
    piNumeroDocumentSuivant = if available ctrat then ctrat.nodoc + 1 else 1.
    case pcTypeContrat:
        when {&TYPECONTRAT-bail} or when {&TYPECONTRAT-preBail} then do:
            assign
                viNoBorInf = piNumeroContratPrincipal * 100000 + piNumeroAppartement * 100       // integer(string(piNumeroContratPrincipal, "99999") + string(piNumeroAppartement, "999") + "00")
                viNoBorSup = piNumeroContratPrincipal * 100000 + piNumeroAppartement * 100 + 99  // integer(string(piNumeroContratPrincipal, "99999") + string(piNumeroAppartement, "999") + "99")
            .
            find last ctrat no-lock
                where ctrat.tpcon =  pcTypeContrat
                  and ctrat.nocon >= viNoBorInf
                  and ctrat.nocon <= viNoBorSup no-error.
            if available ctrat
            then do:
                if ctrat.nocon modulo 100 = 99 then do:    // substring (string(ctrat.nocon, "9999999999"), 9, 2, 'character') = "99"  /* NP 0608/0065 */
                    mError:createError({&error}, 1000987).  //Erreur calcul prochain contrat
                    return.
                end.
                piNumeroContratSuivant = ctrat.nocon + 1.
            end.
            else piNumeroContratSuivant = piNumeroContratPrincipal * 100000 + piNumeroAppartement * 100 + 1.  // integer(string(piNumeroContratPrincipal, "99999") + string(piNumeroAppartement, "999") + "01") . /* NP 0608/0065 */
        end.

        when {&TYPECONTRAT-mutation} or when {&TYPECONTRAT-travaux} or when {&TYPECONTRAT-DossierMutation}
        then do:
            assign
                viNoBorInf = piNumeroContratPrincipal * 100000    // integer(string(piNumeroContratPrincipal, "99999") + "00000")
                viNoBorSup = viNoBorInf + 99999                   // integer(string(piNumeroContratPrincipal, "99999") + "99999")
            .
            find last ctrat no-lock
                where ctrat.tpcon =  pcTypeContrat
                  and ctrat.nocon >= viNoBorInf
                  and ctrat.nocon <= viNoBorSup no-error.
            if available ctrat
            then do:
                if ctrat.nocon modulo 100000 = 99999 then do:         // substring (string (ctrat.nocon, "9999999999"), 6, 5, 'character') = "99999"
                    mError:createError({&error}, 1000987).  //Erreur calcul prochain contrat
                    return.
                end.
                piNumeroContratSuivant = ctrat.nocon + 1.
            end.
            else piNumeroContratSuivant = viNoBorInf + 1.             // integer(string(piNumeroContratPrincipal, "99999") + "00001").
        end.

        when {&TYPECONTRAT-UsufruitNuePropriete} or when {&TYPECONTRAT-CessionUsufruit} or when {&TYPECONTRAT-CessionNuePropriete} or when {&TYPECONTRAT-ExtinctionUsufruit}
        then do:
            assign
                viNoBorInf = piNumeroContratPrincipal * 10000 + 1   // integer (string (piNumeroContratPrincipal, "99999") + "0001")
                viNoBorSup = viNoBorInf + 9998                      // integer (string (piNumeroContratPrincipal, "99999") + "9999")
            .
            find last ctrat no-lock
                where ctrat.tpcon =  pcTypeContrat
                  and ctrat.nocon >= viNoBorInf
                  and ctrat.nocon <= viNoBorSup no-error.
            if available ctrat
            then do:
                if ctrat.nocon modulo 10000 = 9999 then do:   // substring (string (ctrat.nocon, "999999999"), 6) = "9999" then do:
                    mError:createError({&error}, 1000987).  //Erreur calcul prochain contrat
                    return.
                end.
                piNumeroContratSuivant = ctrat.nocon + 1.
            end.
            else piNumeroContratSuivant = piNumeroContratPrincipal * 10000 + 1.         // integer(string(viNoCttPrc, "99999") + "0001").
        end.

        when {&TYPECONTRAT-Salarie}
        then do:
            assign
                viReferenceContrat = integer(mtoken:cRefPrincipale)
                viNoOrdSal         = 00
                viNoBorInf         = piNumeroContratPrincipal * 100     // integer(string(piNumeroContratPrincipal, "99999") + string(viNoOrdSal, "99"))
                viNoBorSup         = piNumeroContratPrincipal + 99      // integer(string(piNumeroContratPrincipal, "99999") + "99")
            .
            find last csscpt no-lock
                where csscpt.soc-cd     = viReferenceContrat
                  and csscpt.etab-cd    = piNumeroContratPrincipal
                  and csscpt.sscoll-cle = "EI"
                  and csscpt.cpt-cd     < "00050" no-error.
            {&_proparse_ prolint-nowarn(use-index)}
            if not available csscpt
            then find last csscpt no-lock
                where csscpt.soc-cd     = viReferenceContrat
                  and csscpt.etab-cd    = piNumeroContratPrincipal
                  and csscpt.sscoll-cle = "EI"
                use-index sscpt-i no-error.  // potentiellement index sscpt-lib, mais ordre alphabétique donne sscpt-i
            if available csscpt
            then assign
                viNoOrdSal = integer(csscpt.cpt-cd)
                viNoBorInf = piNumeroContratPrincipal * 100 + viNoOrdSal        // integer(string (piNumeroContratPrincipal, "99999") + STRING(viNoOrdSal, "99"))
            .
            find last ctrat no-lock
                where ctrat.tpcon =  pcTypeContrat
                  and ctrat.nocon >= viNoBorInf
                  and ctrat.nocon <= viNoBorSup no-error.
            if not available ctrat
            then piNumeroContratSuivant = piNumeroContratPrincipal * 100 + viNoOrdSal + 1.    // integer(string(piNumeroContratPrincipal, "99999") + string(viNoOrdSal + 1, "99")).
            else if ctrat.nocon < viNoBorSup
            then piNumeroContratSuivant = ctrat.nocon + 1.
            else do:
                viNoNxtSal = viNoBorSup.
boucle:
                for each ctrat no-lock
                    where ctrat.tpcon =  pcTypeContrat
                      and ctrat.nocon >= viNoBorInf
                      and ctrat.nocon <= viNoBorSup:
                    if ctrat.nocon > viNoNxtSal then leave boucle.

                    viNoNxtSal = ctrat.nocon + 1.
                end.
                if viNoNxtSal >= viNoBorSup then do:
                    mError:createError({&error}, 1000987).  //Erreur calcul prochain contrat
                    return.
                end.
                piNumeroContratSuivant = viNoNxtSal.
            end.
        end.

        when {&TYPECONTRAT-assuranceGerance} or when {&TYPECONTRAT-assuranceSyndic} then do:
            piNumeroContratSuivant = 1.
            find last ctrat no-lock
                where ctrat.tpcon = pcTypeContrat no-error.
            piNumeroContratSuivant = if available ctrat then ctrat.nocon + 1 else 1.
        end.

        when {&TYPECONTRAT-mutationGerance} then do:
            assign
                viNoBorInf = piNumeroContratPrincipal * 10000        // integer(string(piNumeroContratPrincipal, "99999") + "0000")
                viNoBorSup = viNoBorInf + 9999                       // integer(string(piNumeroContratPrincipal, "99999") + "9999")
            .
            find last ctrat no-lock
                where ctrat.tpcon =  pcTypeContrat
                  and ctrat.nocon >= viNoBorInf
                  and ctrat.nocon <= viNoBorSup no-error.
            if available ctrat
            then do:
                 if ctrat.nocon modulo 10000 = 9999 then do:       // substring(string (ctrat.nocon, "999999999"), 6, 4, 'character') = "9999"
                     mError:createError({&error}, 1000987).  //Erreur calcul prochain contrat
                     return.
                 end.
                 piNumeroContratSuivant = ctrat.nocon + 1.
            end.
            else piNumeroContratSuivant = viNoBorInf + 1.          // integer(string(piNumeroContratPrincipal, "99999") + "0001").
        end.

        when {&TYPECONTRAT-mandat2Gerance} or when {&TYPECONTRAT-mandat2Syndic} then
            run getPremierNumeroMandatDispo(pcTypeContrat, pcNatureContrat, output piNumeroContratSuivant).

        when {&TYPECONTRAT-MandatLocation}
        then do:
            viAnnee = (year(today) modulo 100) * 10000.
            find last ctrat no-lock
                where ctrat.tpcon = pcTypeContrat no-error.
            if available ctrat
            and ctrat.nocon >= viAnnee + 1
            and ctrat.nocon <= viAnnee + 9999
            then assign
                viChrono   = ctrat.nocon modulo 10000               // integer(substring(string(ctrat.nocon , "999999"), 3))
                piNumeroContratSuivant = viAnnee + viChrono + 1     // integer(vcAnnee + string(viChrono + 1, "9999"))
            .
            else piNumeroContratSuivant = viAnnee + 1.
        end.

        otherwise do:
            find last ctrat no-lock
                where ctrat.tpcon = pcTypeContrat no-error.
            piNumeroContratSuivant = if available ctrat then ctrat.nocon + 1 else 1.
        end.
    end case.

end procedure.

procedure getListeNumeroMandatDispo:
    /*------------------------------------------------------------------------------
    Purpose:  creation d'une liste des numeros de mandat disponible
              reprise du pgm adb/objet/frmlct24.p
    Notes  :  service externe
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeContrat   as character no-undo.
    define input  parameter pcNatureContrat as character no-undo.
    define output parameter table for ttListeNumeroContratDispo.

    define variable vcFrmCod                 as character no-undo.
    define variable viNoDerCtt               as integer   no-undo.
    define variable viNoDebCtt               as integer   no-undo.
    define variable viNoFinCtt               as integer   no-undo.
    define variable viNoFinSvg               as integer   no-undo.
    define variable vcCdModele               as character no-undo.
    define variable viSousLocationDeb        as int64     no-undo.
    define variable viSousLocationFin        as int64     no-undo.
    define variable viNoCttEnc               as int64     no-undo.
    define variable viNoCttNxt               as int64     no-undo.
    define variable vcLibPlageNumero         as character no-undo.
    define variable vcNatureLocation         as character no-undo.    // natures de mandat 'location'
    define variable vcNatureLocSsLoc         as character no-undo.    // natures de mandat 'location' et 'sousLocation'
    define variable vcListeModeleFLComptaAdb as character no-undo.
    define variable vlFournisseurLoyer       as logical   no-undo.
    define variable viFournisseurLoyerDebut  as integer   no-undo.
    define variable voSyspg                  as class syspg no-undo.

    define buffer aprof for aprof.
    define buffer ctrat for ctrat.

    empty temp-table ttListeNumeroContratDispo.
    assign
        vcFrmCod                 = if lookup(pcTypeContrat, substitute('&1,&2,&3,&4', {&TYPECONTRAT-bail}, {&TYPECONTRAT-titre2copro}, {&TYPECONTRAT-travaux}, {&TYPECONTRAT-budget})) > 0
                                   then "9999999999"
                                   else ">9999"
        vcNatureLocation         = substitute('&1,&2,&3', {&NATURECONTRAT-mandatLocation}, {&NATURECONTRAT-mandatLocationDelegue}, {&NATURECONTRAT-mandatLocationIndivision})
        vcNatureLocSsLoc         = substitute('&1,&2,&3', vcNatureLocation, {&NATURECONTRAT-mandatSousLocation}, {&NATURECONTRAT-mandatSousLocationDelegue})
        vcListeModeleFLComptaAdb = substitute('&1,&2', {&MODELE-ResidenceLocative-ComptaAdb}, {&MODELE-ResidenceLocativeEtDeleguee-ComptaAdb})
        vcLibPlageNumero         = outilTraduction:getLibelle(100068)
        voSyspg                  = new syspg()
    .
    if not voSyspg:isParamExist("R_CRC", pcTypeContrat, pcNatureContrat)
    then do:
        mError:createError({&error}, 1000611, pcNatureContrat).   //nature de contrat &1 inconnue
        return.
    end.
    delete object voSyspg.

    // Recherche du premier numero libre
    run getPremierNumeroMandatDispo(pcTypeContrat, pcNatureContrat, output viNoDerCtt).

    assign
        vlFournisseurLoyer       = goCollectionGesFL:getLogical("lFournisseurLoyer")
        vcCdModele               = goCollectionGesFL:getCharacter("cCdModele")
        viSousLocationDeb        = goCollectionGesFL:getInteger("iSousLocationDeb")
        viSousLocationFin        = goCollectionGesFL:getInteger("iSousLocationFin")
        viFournisseurLoyerDebut  = goCollectionGesFL:getInteger("iFournisseurLoyerDebut")
    .

    if pcTypeContrat = {&TYPECONTRAT-mandat2Gerance} and vlFournisseurLoyer then do: // Cas des FL (BNP, LCL)
    boucle:
    for each aprof no-lock
       where aprof.profil-cd = 21:

        if lookup(pcNatureContrat, vcNatureLocation) > 0 then do:
           if not aprof.fgfloy then next boucle.
        end.
        else if aprof.fgfloy then next boucle.

        // Maj des bornes : si on doit les modifier pour les FL
        assign
            viNoDebCtt = aprof.mandatdeb
            viNoFinCtt = aprof.mandatfin
            viNoFinSvg = viNoFinCtt
        .
        // Maj de la borne supérieure pour optimisation
        // modif SY le 05/06/2009 : gestion mandat FL ou standard
        if lookup(pcNatureContrat, vcNatureLocation) > 0
        then for last ctrat no-lock
            where ctrat.tpcon = pcTypeContrat
              and ctrat.nocon >= viNoDebCtt
              and ctrat.nocon <= viNoFinCtt
              and lookup(ctrat.ntcon, vcNatureLocation) > 0:
            viNoDerCtt = ctrat.nocon.
        end.
        else if lookup(vcCdModele, vcListeModeleFLComptaAdb) > 0    // LCL, BNP
        then for last ctrat no-lock                 // recherche dernier mandat standard
            where ctrat.tpcon = pcTypeContrat
              and ctrat.nocon >= viNoDebCtt
              and ctrat.nocon <= viNoFinCtt
              and not ctrat.fgfloy
              and lookup(ctrat.ntcon, vcNatureLocSsLoc) = 0:
            assign
                viNoCttNxt = viNoDerCtt + 1
                viNoDerCtt = if viNoCttNxt >= viSousLocationDeb and viNoCttNxt <= viSousLocationFin then viSousLocationFin else ctrat.nocon
            .
        end.
        else for last ctrat no-lock
            where ctrat.tpcon = pcTypeContrat
              and ctrat.nocon >= viNoDebCtt
              and ctrat.nocon <= viNoFinCtt
              and not ctrat.fgfloy
              and lookup(ctrat.ntcon, vcNatureLocation) = 0:
            viNoDerCtt = ctrat.nocon.
        end.

        if viNoFinCtt > viNoDerCtt then viNoFinCtt = viNoDerCtt.

        // Constitution de la liste
        boucle2:
        do viNoCttEnc = viNoDebCtt to viNoFinCtt:
            if can-find(first ctrat no-lock
                        where ctrat.tpcon = pcTypeContrat and ctrat.nocon = viNoCttEnc)     // le mandat est-il présent en gestion
            or can-find(first ietab no-lock
                        where ietab.soc-cd  = integer(mtoken:cRefPrincipale)
                          and ietab.etab-cd = viNoCttEnc)                                   // le mandat est-il présent en compta
            // ajout SY le 04/01/2010: mandat standard: sauter tranche sous-location = no immeuble
            or (lookup(vcCdModele, vcListeModeleFLComptaAdb) > 0
                and lookup(pcNatureContrat, vcNatureLocSsLoc) = 0
                and viNoCttEnc >= viSousLocationDeb and viNoCttEnc <= viSousLocationFin)
            then next boucle2.

            // A ce point le numéro n'est pas utilisé
            create ttListeNumeroContratDispo.
            assign
                ttListeNumeroContratDispo.iNumero      = viNoCttEnc
                ttListeNumeroContratDispo.cPlageNumero = if viNoCttEnc = viNoFinCtt then substitute('&1 &2 &3', string(viNoCttEnc, vcFrmCod), vcLibPlageNumero, string(viNoFinSvg, vcFrmCod))
                                                                                    else string(viNoCttEnc, vcFrmCod)
            .
        end.

        if lookup(vcCdModele, vcListeModeleFLComptaAdb) > 0 and lookup(pcNatureContrat, vcNatureLocSsLoc) = 0
        and viSousLocationDeb >= aprof.mandatdeb and viSousLocationDeb <= aprof.mandatfin
        and viNoCttEnc >= viSousLocationDeb and viNoCttEnc <= viSousLocationFin
        then viNoCttEnc = viSousLocationFin + 1.

        // gestion de la fin de la tranche
        if viNoDebCtt <> viNoFinCtt and viNoFinCtt < viNoFinSvg then do:
            create ttListeNumeroContratDispo.
            assign
                viNoFinCtt                             = viNoCttEnc
                ttListeNumeroContratDispo.iNumero      = viNoCttEnc
                ttListeNumeroContratDispo.cPlageNumero = substitute('&1 &2 &3', string(viNoCttEnc, vcFrmCod), vcLibPlageNumero, string(viNoFinSvg, vcFrmCod))
            .
        end.
    end.
    end.
    else do:    // Pas de FL: cas Mandat de gérance classique / Mandat des syndicats
        boucleProfils:
        for each aprof no-lock
            where aprof.profil-cd = (if pcTypeContrat = {&TYPECONTRAT-mandat2Gerance} then 21 else 91)
              and not aprof.fgfloy:
            assign
                viNoDebCtt = aprof.mandatdeb
                viNoFinCtt = aprof.mandatfin
                viNoFinSvg = viNoFinCtt
                viNoDerCtt = viNoDebCtt
            .
            // Maj de la borne supérieure pour optimisation: gestion mandat standard
            for last ctrat no-lock
                where ctrat.tpcon = pcTypeContrat
                  and ctrat.nocon >= viNoDebCtt
                  and ctrat.nocon <= viNoFinCtt
                  and not ctrat.fgfloy
                  and lookup(ctrat.ntcon, vcNatureLocation) = 0:
                viNoDerCtt = ctrat.nocon.
            end.
            if viNoFinCtt > viNoDerCtt then viNoFinCtt = viNoDerCtt.

            // Constitution de la liste
            boucleListe:
            do viNoCttEnc = viNoDebCtt to viNoFinCtt:
                // le mandat est-il présent en gestion ou en compta
                if can-find(first ctrat no-lock
                            where ctrat.tpcon = pcTypeContrat and ctrat.nocon = viNoCttEnc)     // le mandat est-il présent en gestion
                or can-find(first ietab no-lock
                            where ietab.soc-cd = integer(mtoken:cRefPrincipale)
                              and ietab.etab-cd = viNoCttEnc)                                   // le mandat est-il présent en compta
                then next boucleListe.

                // A ce point le numéro n'est pas utilisé
                create ttListeNumeroContratDispo.
                assign
                    ttListeNumeroContratDispo.iNumero      = viNoCttEnc
                    ttListeNumeroContratDispo.cPlageNumero = if viNoCttEnc = viNoFinCtt then substitute('&1 &2 &3', string(viNoCttEnc, vcFrmCod), vcLibPlageNumero, string(viNoFinSvg, vcFrmCod))
                                                                                        else string(viNoCttEnc, vcFrmCod)
                .
            end.
            // Gestion de la fin de la tranche
            if viNoDebCtt <> viNoFinCtt and viNoFinCtt < viNoFinSvg then do:
                create ttListeNumeroContratDispo.
                assign
                    viNoFinCtt                             = viNoCttEnc
                    ttListeNumeroContratDispo.iNumero      = viNoCttEnc
                    ttListeNumeroContratDispo.cPlageNumero = substitute('&1 &2 &3', string(viNoCttEnc, vcFrmCod), vcLibPlageNumero, string(viNoFinSvg, vcFrmCod))
                .
            end.
        end.
    end.

end procedure.

procedure getPremierNumeroMandatDispo private:
    /*------------------------------------------------------------------------------
    Purpose:  donne le 1er numero de mandat disponible
              reprise du pgm adb/lib/l_ctrat_ext.p (NextCtrat)
    Notes  :
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeContrat          as character no-undo.
    define input  parameter pcNatureContrat        as character no-undo.
    define output parameter piNumeroContratSuivant as int64     no-undo.

    define variable vlFournisseurLoyer       as logical   no-undo.
    define variable vcNatureLocation         as character no-undo.
    define variable vcNatureLocSsLoc         as character no-undo.
    define variable vcCdModele               as character no-undo.
    define variable viSousLocationDeb        as integer   no-undo.
    define variable viSousLocationFin        as integer   no-undo.
    define variable viFournisseurLoyerDebut  as integer   no-undo.
    define variable vcListeModeleFLComptaAdb as character no-undo.
    define variable vlMandatTrouve           as logical   no-undo.
    define variable viBorneMandatDeb         as int64     no-undo.
    define variable viBorneMandatFin         as int64     no-undo.
    define variable viNumeroMandat           as int64     no-undo.

    define buffer ctrat for ctrat.
    define buffer aprof for aprof.

    assign
        goCollectionGesFL        = new collection()
        goCollectionGesFL        = getInfosGESFL()
        vlFournisseurLoyer       = goCollectionGesFL:getLogical("lFournisseurLoyer")
        vcCdModele               = goCollectionGesFL:getCharacter("cCdModele")
        viSousLocationDeb        = goCollectionGesFL:getInteger("iSousLocationDeb")
        viSousLocationFin        = goCollectionGesFL:getInteger("iSousLocationFin")
        viFournisseurLoyerDebut  = goCollectionGesFL:getInteger("iFournisseurLoyerDebut")
        vcNatureLocation         = substitute('&1,&2,&3', {&NATURECONTRAT-mandatLocation}, {&NATURECONTRAT-mandatLocationDelegue}, {&NATURECONTRAT-mandatLocationIndivision})
        vcNatureLocSsLoc         = substitute('&1,&2,&3', vcNatureLocation, {&NATURECONTRAT-mandatSousLocation}, {&NATURECONTRAT-mandatSousLocationDelegue})
        vcListeModeleFLComptaAdb = substitute('&1,&2', {&MODELE-ResidenceLocative-ComptaAdb}, {&MODELE-ResidenceLocativeEtDeleguee-ComptaAdb})
    .
    /*
        Lecture de la table des contrats
        1) Recherche 1er trou dispo dans les tranches successives
        2) Si rien: recherche dernier dans les tranches de mandats
    */
    piNumeroContratSuivant = 0.
    if pcTypeContrat = {&TYPECONTRAT-mandat2Gerance} and vlFournisseurLoyer then do: // Cas des FL
        boucleProfils:
        for each aprof no-lock
            where aprof.profil-cd = 21:

            if lookup(pcNatureContrat, vcNatureLocation) > 0 then do:
               if not aprof.fgfloy then next boucleProfils.
            end.
            else
               if aprof.fgfloy then next boucleProfils.
            assign
                viBorneMandatDeb = aprof.mandatdeb
                viBorneMandatFin = aprof.mandatfin
            .
            if lookup(vcCdModele, vcListeModeleFLComptaAdb) > 0 then viBorneMandatDeb = viSousLocationFin + 1.
            viBorneMandatFin = minimum(aprof.mandatfin, viFournisseurLoyerDebut - 1).
            if viBorneMandatFin < viBorneMandatdeb then next boucleProfils.

            // recherche du premier numero libre
            boucle2:
            do viNumeroMandat = viBorneMandatDeb to viBorneMandatFin:
                if can-find(first ctrat no-lock
                            where ctrat.tpcon = pcTypeContrat
                              and ctrat.nocon = viNumeroMandat)                 // le mandat est-il présent en gestion
                or can-find(first ietab no-lock
                            where ietab.soc-cd = integer(mtoken:cRefPrincipale)
                              and ietab.etab-cd = viNumeroMandat)               // le mandat est-il présent en compta
                // ajout SY le 04/01/2010: mandat standard: sauter tranche sous-location = no immeuble
                or (lookup(vcCdModele, vcListeModeleFLComptaAdb) > 0
                    and lookup(pcNatureContrat, vcNatureLocSsLoc) = 0
                    and viNumeroMandat >= viSousLocationDeb and viNumeroMandat <= viSousLocationFin)
                then next boucle2.
                assign
                    piNumeroContratSuivant = viNumeroMandat
                    vlMandatTrouve         = true
                .
                leave boucleProfils.
            end.
        end.

        if not vlMandatTrouve then do:
            boucleProfils2:
            for each aprof no-lock
                where aprof.profil-cd = 21:

                if lookup(pcNatureContrat, vcNatureLocation) > 0 then do:
                   if not aprof.fgfloy then next boucleProfils2.
                end.
                else
                   if aprof.fgfloy then next boucleProfils2.

                assign
                    viBorneMandatDeb = aprof.mandatdeb
                    viBorneMandatFin = aprof.mandatfin
                .
                viBorneMandatFin = minimum(aprof.mandatfin, viFournisseurLoyerDebut).
                if viBorneMandatFin < viBorneMandatdeb then next boucleProfils2.

                boucleMandat:
                do viNumeroMandat = viBorneMandatDeb to viBorneMandatFin:
                    if can-find (first ctrat no-lock
                                 where ctrat.tpcon = pcTypeContrat
                                   and ctrat.nocon = viNumeroMandat)
                    then next boucleMandat.

                    assign
                        piNumeroContratSuivant = viNumeroMandat
                        vlMandatTrouve = true
                    .
                    leave boucleMandat.
                end.
            end.
        end.
    end.
    else do:    // Pas de FL: cas Mandat de gérance classique / Mandat des syndicats
        boucleProfils:
        for each aprof no-lock
            where aprof.profil-cd = (if pcTypeContrat = {&TYPECONTRAT-mandat2Gerance} then 21 else 91)
              and not aprof.fgfloy:

            assign
                viBorneMandatDeb = aprof.mandatdeb
                viBorneMandatFin = aprof.mandatfin
            .
            // Recherche du premier numero libre
            boucle_NumLibre:
            do viNumeroMandat = viBorneMandatDeb to viBorneMandatFin:
                if can-find(first ctrat no-lock
                            where ctrat.tpcon = pcTypeContrat
                              and ctrat.nocon = viNumeroMandat)     // le mandat est-il présent en gestion
                or can-find(first ietab no-lock
                            where ietab.soc-cd = integer(mtoken:cRefPrincipale)
                              and ietab.etab-cd = viNumeroMandat)   // le mandat est-il présent en compta
                then next boucle_NumLibre.
                assign
                    piNumeroContratSuivant = viNumeroMandat
                    vlMandatTrouve         = true
                .
                leave boucleProfils.
            end.
        end.    // boucleProfils
        if not vlMandatTrouve then do:
            boucleProfilsSuite:
            for each aprof no-lock
                where aprof.profil-cd = (if pcTypeContrat = {&TYPECONTRAT-mandat2Gerance} then 21 else 91)
                  and not aprof.fgfloy:

                assign
                    viBorneMandatDeb = aprof.mandatdeb
                    viBorneMandatFin = aprof.mandatfin
                .
                /* Recherche du contrat */
                find last ctrat no-lock
                    where ctrat.tpcon = pcTypeContrat
                      and (ctrat.nocon >= viBorneMandatDeb and ctrat.nocon <= viBorneMandatFin) no-error.
                if available ctrat then do:
                    /* On a trouvé un contrat, il ne faut pas que ce soit la borne de fin */
                    if ctrat.nocon <> viBorneMandatFin then do:
                        assign
                            piNumeroContratSuivant = ctrat.nocon + 1
                            vlMandatTrouve         = true
                        .
                        leave boucleProfilsSuite.
                    end.
                end.
                else do:
                    // dans ce cas il faut prendre le premier numéro de la tranche
                    assign
                        piNumeroContratSuivant = viBorneMandatDeb
                        vlMandatTrouve         = true
                    .
                    leave boucleProfilsSuite.
                end.
            end.    // boucleProfilsSuite
        end.
    end.
    if not vlMandatTrouve then do:
        mError:createError({&error}, 1000987).  //Erreur calcul prochain contrat
        return.
    end.

end procedure.