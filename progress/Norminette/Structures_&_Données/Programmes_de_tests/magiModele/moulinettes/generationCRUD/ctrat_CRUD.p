/*------------------------------------------------------------------------
File        : ctrat_CRUD.p
Purpose     :
Author(s)   : kantena -
Notes       : il reste les méthodes suivante a adapter : Mj2Ctrat, Mj4ctrat, Mj5ctrat, Mj6ctrat
------------------------------------------------------------------------*/
{preprocesseur/type2contrat.i}

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */
{mandat/include/mandat.i}
{adblib/include/ctrat.i}
define variable ghttctrat as handle no-undo.      // le handle de la temp table à mettre à jour

function getIndexField returns logical private(phBuffer as handle, output phTpcon as handle, output phNocon as handle, output phNodoc as handle):
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
       end case.
    end.
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
    define buffer ctrat for ctrat.

    create query vhttquery.
    vhttBuffer = ghttCtrat:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCtrat:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon, output vhNodoc).
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
    define variable viRetour   as integer  no-undo.
    define variable viNoDocSui as int64    no-undo.
    define variable viNoConSui as int64    no-undo.
    define variable vhTpcon    as handle   no-undo.
    define variable vhNocon    as handle   no-undo.
    define variable vhNodoc    as handle   no-undo.
    define buffer ctrat for ctrat.

    create query vhttquery.
    vhttBuffer = ghttCtrat:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCtrat:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon, output vhNodoc).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.
            run getNextContrat(vhTpcon:buffer-value(), "0", 0, output viRetour, output viNoDocSui, output viNoConSui).
            if viRetour <> 0
            then do:
                mError:createError({&error}, substitute("Erreur calcul prochain contrat (&1)", viRetour)).      // todo traduction
                undo blocTrans, leave blocTrans.
            end.
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

procedure deleteContrat:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhNodoc    as handle  no-undo.
    define buffer ctrat for ctrat.

    create query vhttquery.
    vhttBuffer = ghttCtrat:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCtrat:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon, output vhNodoc).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ctrat exclusive-lock
                where rowid(Ctrat) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ctrat:handle, 'tpcon/nocon: ', substitute('&1/&2', vhTpcon:buffer-value(), vhNocon:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

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

/*gga todo a revoir au retour de Thierry si procedure déjà testé (utilisé depuis appel de createcontrat dans immeuble.p)
utilisation impossible car les champs phttBuffer::cTypeContrat phttBuffer::iNumeroAppartement et phttBuffer::lNoLock n'existent pas
dans table ttMandat (ou je n'arrive pas a l'utiliser)
pour l'instant mise en commentaire pour duplication avec appel different)
procedure getNextContrat private:
    /*------------------------------------------------------------------------------
    Purpose: Procedure qui permet de connaitre le prochain N° de ctrat libre.
    Notes  :
    TODO compléter avec les création des messages d'erreur : run GestMess (000001,"",100386,"","","ERROR",output FgExeMth).
    ------------------------------------------------------------------------------*/
    define input parameter  phttBuffer   as handle no-undo.
    define output parameter piCodeRetour as integer no-undo.
/*
    define output parameter piNumeroDocumentSuivant as integer no-undo.
    define output parameter piNumeroContratSuivant  as integer no-undo.
*/
    define variable viNoDocSui         as integer   no-undo.
    define variable viNoConSui         as integer   no-undo.
    define variable viNoCttPrc         as integer   no-undo.
    define variable viNoBorInf         as integer   no-undo.
    define variable viNoBorSup         as integer   no-undo.
    define variable viNoOrdSal         as integer   no-undo.
    define variable viNodebCtt         as integer   no-undo initial 1.
    define variable viNoNxtSal         as integer   no-undo.
    define variable vlGesFlo           as logical   no-undo.
    define variable vcCdModele         as character no-undo.
    define variable vlMandatTrouve     as logical   no-undo.
    define variable viBorneMandatDeb   as integer   no-undo.
    define variable viBorneMandatFin   as integer   no-undo.
    define variable viNumeroMandat     as integer   no-undo.
    define variable vcAnnee            as character no-undo.
    define variable viChrono           as integer   no-undo.
    define variable viReferenceContrat as integer   no-undo.
    define variable viNoSloDeb         as integer   no-undo.
    define variable viNoSloFin         as integer   no-undo.
    define variable viNoFloDeb         as integer   no-undo.
    define variable viNoSlDDeb         as integer   no-undo.
    define variable viNoSlDFin         as integer   no-undo.

    define variable vcTypeContrat            as character no-undo.
    define variable vcNumeroContratPrincipal as character no-undo.
    define variable viNumeroAppartement      as integer   no-undo.
    define variable vlnolock                 as logical   no-undo.
    define buffer ctrat  for ctrat.
    define buffer csscpt for csscpt.
//    define buffer trdos  for trdos.
    define buffer pclie  for pclie.
    define buffer aprof  for aprof.

    assign
        vcTypeContrat            = phttBuffer::cTypeContrat
        vcNumeroContratPrincipal = phttBuffer::cNumeroContrat
        viNumeroAppartement      = phttBuffer::iNumeroAppartement
        vlnolock                 = phttBuffer::lNoLock
    .
    if vlnolock
    then find last ctrat no-lock no-error.
    else find last ctrat exclusive-lock no-wait no-error.
    if locked ctrat then do:
        // 0000: provisoire
        mError:createError({&error}, 0000).
        return.
    end.
    assign
        viNoDocSui = if available ctrat then ctrat.nodoc + 1 else 1
        vlGesFlo   = false
        viNoSloDeb = 1
        viNoSloFin = 200
        viNoFloDeb = 8001
        viNoSlDDeb = 0
        viNoSlDFin = 0
    .
    find first pclie no-lock where pclie.tppar = "GESFL" no-error.
    if available pclie and pclie.zon01 = "00001" and pclie.zon03 > ""
    then do:
        assign
            vlGesFlo   = true
            vcCdModele = if pclie.zon03 > "" then pclie.zon03 else vcCdModele
            viNoSloDeb = if pclie.zon04 > "" then integer(pclie.zon04) else viNoSloDeb  /* mandats sous-location réservés */
            viNoSloFin = if pclie.zon04 > "" then integer(pclie.zon05) else viNoSloFin
            viNoFloDeb = integer(pclie.zon06)        /* debute des fournisseurs loyer */
        .
        if vcCdModele = "00004"
        then assign
            viNoSlDDeb = (if pclie.int03 > 0 then pclie.int03 else viNoSlDDeb)
            viNoSlDFin = (if pclie.int03 > 0 then pclie.int04 else viNoSlDFin)
        .
        else assign
            viNoSlDDeb = viNoSloDeb
            viNoSlDFin = viNoSloFin
        .
    end.
    case vcTypeContrat:
        when {&TYPECONTRAT-bail} or when {&TYPECONTRAT-preBail} then do:
            assign
                viNoBorInf = integer(vcNumeroContratPrincipal) * 100000 + viNumeroAppartement * 100
                viNoBorSup = integer(vcNumeroContratPrincipal) * 100000 + viNumeroAppartement * 100 + 99
            .
            if vlnolock
            then find last ctrat no-lock
                where ctrat.tpcon =  vcTypeContrat
                  and ctrat.nocon >= viNoBorInf
                  and ctrat.nocon <= viNoBorSup no-error.
            else find last ctrat exclusive-lock
                where ctrat.tpcon =  vcTypeContrat
                  and ctrat.nocon >= viNoBorInf
                  and ctrat.nocon <= viNoBorSup no-wait no-error.
            if locked ctrat then do:
                piCodeRetour = 1.
                return.
            end.
            if available ctrat
            then do:
                if ctrat.nocon modulo 100 = 99 then do:  /* NP 0608/0065 */
                    piCodeRetour = 2.
                    return.
                end.
                viNoConSui = ctrat.nocon + 1.
            end.
            else viNoConSui = integer(vcNumeroContratPrincipal) * 100000 + viNumeroAppartement * 100 + 01. /* NP 0608/0065 */
        end.

        when {&TYPECONTRAT-mutation} or when {&TYPECONTRAT-travaux} or when {&TYPECONTRAT-DossierMutation}
        then do:
            assign
                viNoCttPrc = integer(vcNumeroContratPrincipal)
                viNoBorInf = viNoCttPrc * 100000
                viNoBorSup = viNoCttPrc * 100000 + 99999
            .
            if vlnolock
            then find last ctrat no-lock
                    where ctrat.tpcon =  vcTypeContrat
                      and ctrat.nocon >= viNoBorInf
                      and ctrat.nocon <= viNoBorSup no-error.
            else find last ctrat exclusive-lock
                    where ctrat.tpcon =  vcTypeContrat
                      and ctrat.nocon >= viNoBorInf
                      and ctrat.nocon <= viNoBorSup no-wait no-error.
            if locked ctrat then do:
                piCodeRetour = 1.
                return.
            end.
            if available ctrat
            then do:
                if ctrat.nocon modulo 100000 = 99999 then do:
                    piCodeRetour = 2.
                    return.
                end.
                viNoConSui = ctrat.nocon + 1.
            end.
            else viNoConSui = viNoCttPrc * 100000 + 1.
        end.

        when {&TYPECONTRAT-UsufruitNuePropriete} or when {&TYPECONTRAT-CessionUsufruit} or when {&TYPECONTRAT-CessionNuePropriete} or when {&TYPECONTRAT-ExtinctionUsufruit}
        then do:
            assign
                viNoCttPrc = integer(vcNumeroContratPrincipal)
                viNoBorInf = viNoCttPrc * 10000 + 1    // integer(string(viNoCttPrc, "99999") + "0001")
                viNoBorSup = viNoCttPrc * 10000 + 9999 // integer(string(viNoCttPrc, "99999") + "9999")
            .
            if vlnolock
            then find last ctrat no-lock
                where ctrat.tpcon =  vcTypeContrat
                  and ctrat.nocon >= viNoBorInf
                  and ctrat.nocon <= viNoBorSup no-error.
            else find last ctrat exclusive-lock
                where ctrat.tpcon =  vcTypeContrat
                  and ctrat.nocon >= viNoBorInf
                  and ctrat.nocon <= viNoBorSup no-wait no-error.
            if locked ctrat then do:
                piCodeRetour = 1.
                return.
            end.
            if available ctrat
            then do:
                if ctrat.nocon modulo 10000 = 9999 then do:  // substring (string (ctrat.nocon, "999999999"), 6) = "9999" then do:    // todo  ???? nombre 99999 d'habitude, pas 9999  ?????
                    piCodeRetour = 2.
                    return.
                end.
                viNoConSui = ctrat.nocon + 1.
            end.
            else viNoConSui = viNoCttPrc * 10000 + 1.   // integer(string(viNoCttPrc, "99999") + "0001").
        end.

        when {&TYPECONTRAT-Salarie} then do:     //gga todo attention dans le pgm initial c 'est code 010485 pas 01096
            assign                               // todo  ATTENTION, D'ou vient trdos ?????
                viReferenceContrat = mtoken:getSociete(trdos.tpcon)
                viNoCttPrc = integer(vcNumeroContratPrincipal)
                viNoOrdSal = 00
                viNoBorInf = viNoCttPrc * 100 + viNoOrdSal // integer(string(viNoCttPrc, "99999") + string(viNoOrdSal, "99"))
                viNoBorSup = viNoCttPrc * 100 + 99         // integer(string(viNoCttPrc, "99999") + "99")
            .
            find last csscpt no-lock
                where csscpt.soc-cd     = viReferenceContrat
                  and csscpt.etab-cd    = viNoCttPrc
                  and csscpt.sscoll-cle = "EI"
                  and csscpt.cpt-cd     < "00050" no-error.
            if not available csscpt then do:
                {&_proparse_ prolint-nowarn(use-index)}
                find last csscpt no-lock
                    where csscpt.soc-cd     = viReferenceContrat
                      and csscpt.etab-cd    = viNoCttPrc
                      and csscpt.sscoll-cle = "EI"
                  use-index sscpt-i no-error.  // potentiellement index sscpt-lib, mais ordre alphabétique donne sscpt-i
            end.
            if available csscpt
            then assign
                viNoOrdSal = integer(csscpt.cpt-cd)
                viNoBorInf = viNoCttPrc * 100 + viNoOrdSal // integer(string (viNoCttPrc, "99999") + string(viNoOrdSal, "99"))
            .
            if vlnolock
            then find last ctrat no-lock
                    where ctrat.tpcon =  vcTypeContrat
                      and ctrat.nocon >= viNoBorInf
                      and ctrat.nocon <= viNoBorSup no-error.
            else find last ctrat exclusive-lock
                    where ctrat.tpcon =  vcTypeContrat
                      and ctrat.nocon >= viNoBorInf
                      and ctrat.nocon <= viNoBorSup no-wait no-error.
            if locked ctrat then do:
                piCodeRetour = 1.
                return.
            end.
            if not available ctrat
            then viNoConSui = viNoCttPrc * 100 + viNoOrdSal + 1.   // integer(string(viNoCttPrc, "99999") + string(viNoOrdSal + 1, "99")).
            else if ctrat.nocon < viNoBorSup
            then viNoConSui = ctrat.nocon + 1.
            else do:
                viNoNxtSal = viNoBorSup.
boucle:
                for each ctrat no-lock
                   where ctrat.tpcon =  vcTypeContrat
                     and ctrat.nocon >= viNoBorInf
                     and ctrat.nocon <= viNoBorSup:
                    if ctrat.nocon > viNoNxtSal then leave boucle.

                    viNoNxtSal = ctrat.nocon + 1.
                end.
                if viNoNxtSal >= viNoBorSup then do:
                    piCodeRetour = 2.
                    return.
                end.
                viNoConSui = viNoNxtSal.
            end.
        end.

        when {&TYPECONTRAT-assuranceGerance} or when {&TYPECONTRAT-assuranceSyndic} then do:
            viNoConSui = 1.
            if vlnolock
            then find last ctrat no-lock
                    where ctrat.tpcon = vcTypeContrat no-error.
            else find last ctrat exclusive-lock
                    where ctrat.tpcon = vcTypeContrat no-wait no-error.
            if locked ctrat then do:
                //run AffIntIdt (1, GlAdbLib).
                piCodeRetour = 1.
                return.
            end.
            viNoConSui = if available ctrat then ctrat.NoCon + 1 else 1.
        end.

        when {&TYPECONTRAT-mutationGerance} then do:
            assign
                viNoCttPrc = integer(vcNumeroContratPrincipal)
                viNoBorInf = viNoCttPrc * 10000   // integer(string(viNoCttPrc, "99999") + "0000")
                viNoBorSup = viNoBorInf + 9999    // integer(string(viNoCttPrc, "99999") + "9999")
            .
            if vlnolock
            then find last ctrat no-lock
                   where ctrat.tpcon =  vcTypeContrat
                     and ctrat.nocon >= viNoBorInf
                     and ctrat.nocon <= viNoBorSup no-error.
            else find last ctrat exclusive-lock
                   where ctrat.tpcon =  vcTypeContrat
                     and ctrat.nocon >= viNoBorInf
                     and ctrat.nocon <= viNoBorSup no-wait no-error.
            if locked ctrat then do:
                piCodeRetour = 1.
                return.
            end.
            if available ctrat
            then do:
                 if ctrat.nocon modulo 10000 = 9999 then do:   // substring(string (ctrat.nocon, "999999999"), 6, 4, 'character') = "9999"
                     piCodeRetour = 2.
                     return.
                 end.
                 viNoConSui = ctrat.nocon + 1.
            end.
            else viNoConSui = viNoCttPrc * 10000 + 1.          // integer(string(viNoCttPrc, "99999") + "0001").
        end.

        when {&TYPECONTRAT-mandat2Gerance} or when {&TYPECONTRAT-mandat2Syndic}
        then do:
            assign
                vlMandatTrouve = false
                viNoConSui = 0
            .
boucleProfils:
            for each aprof no-lock
                where aprof.profil-cd = (if vcTypeContrat = {&TYPECONTRAT-mandat2Gerance} then 21 else 91):
                assign
                    viBorneMandatDeb = aprof.mandatdeb
                    viBorneMandatFin = aprof.mandatfin
                .
                if vcTypeContrat = {&TYPECONTRAT-mandat2Gerance} and vlGesFlo
                then do:
                    if (vcCdModele = "00003") then viBorneMandatDeb = viNoSloFin + 1.
                    if (vcCdModele = "00004") then viBorneMandatDeb = viNoSlDFin + 1.
                    viBorneMandatFin = minimum(aprof.mandatfin, viNoFloDeb - 1).
                    if viBorneMandatFin < viBorneMandatdeb then next boucleProfils.
                end.
                find last ctrat no-lock
                    where ctrat.tpcon  =  vcTypeContrat
                      and (ctrat.nocon >= viBorneMandatDeb
                      and ctrat.nocon  <= viBorneMandatFin) no-error.
                if available ctrat then do:
                    if ctrat.nocon <> viBorneMandatFin then do:
                        assign
                            viNoConSui     = ctrat.nocon + 1
                            vlMandatTrouve = true
                        .
                        leave boucleProfils.
                    end.
                end.
                else do:
                    assign
                        viNoConSui     = viBorneMandatDeb
                        vlMandatTrouve = true
                    .
                    leave boucleProfils.
                end.
            end.
            {&_proparse_ prolint-nowarn(do1)}
            if vlMandatTrouve = false then do:
boucleProfils2:
                for each aprof no-lock
                    where aprof.profil-cd = (if vcTypeContrat = {&TYPECONTRAT-mandat2Gerance} then 21 else 91):
                    assign
                        viBorneMandatDeb = aprof.mandatdeb
                        viBorneMandatFin = aprof.mandatfin
                    .
                    if vlGesFlo then do:
                        viBorneMandatFin = minimum(aprof.mandatfin, viNoFloDeb).
                        if viBorneMandatFin < viBorneMandatdeb then next boucleProfils2.
                    end.
boucleMandat:
                    do viNumeroMandat = viBorneMandatDeb to viBorneMandatFin:
                        find first ctrat no-lock
                            where ctrat.tpcon = vcTypeContrat
                              and ctrat.nocon = viNumeroMandat no-error.
                        if available ctrat then next boucleMandat.

                        assign
                            viNoConSui = viNumeroMandat
                            vlMandatTrouve = true
                        .
                        leave boucleMandat.
                    end.
                end.
            end.
            if vlMandatTrouve = false then do:
                piCodeRetour = 3.
                return.
            end.
        end.

        when {&TYPECONTRAT-MandatLocation}
        then do:
            vcAnnee = string(year(today) modulo 100, "99").
            if vlnolock
            then find last ctrat no-lock
                where ctrat.tpcon = vcTypeContrat no-error.
            else find last ctrat exclusive-lock
                where ctrat.tpcon = vcTypeContrat no-wait no-error.
            if locked ctrat then do:
                piCodeRetour = 1.
                return.
            end.
            if available ctrat
            and ctrat.nocon >= integer(vcAnnee + "0001")
            and ctrat.nocon <= integer(vcAnnee + "9999")
            then assign
                viChrono   = ctrat.nocon modulo 10000                // integer(substring(string(ctrat.nocon , "999999"), 3))
                viNoConSui = integer(vcAnnee) * 10000 + viChrono + 1 // integer(vcAnnee + string(viChrono + 1, "9999"))
            .
            else viNoConSui = integer(vcAnnee + "0001").
        end.

        otherwise do:
            if vlnolock
            then find last ctrat no-lock
                where ctrat.tpcon = vcTypeContrat no-error.
            else find last ctrat exclusive-lock
                where ctrat.tpcon = vcTypeContrat no-wait no-error.
            if locked ctrat then do:
                piCodeRetour = 1.
                return.
            end.
            viNoConSui = if available ctrat then ctrat.nocon + 1 else viNoDebCtt.
        end.
    end case.
    assign
        piCodeRetour = 0
        phttBuffer::iNumeroDocument = viNoDocSui
        phttBuffer::iNumeroContrat  = viNoConSui
    .
end procedure.
gg*/

procedure getNextContrat:
    /*------------------------------------------------------------------------------
    Purpose: Procedure qui permet de connaitre le prochain N° de ctrat libre.
    Notes  : procédure interne et service appelé par mandat.p
    TODO compléter avec les création des messages d'erreur : run GestMess (000001,"",100386,"","","ERROR",output FgExeMth).
//gga todo seulement test pour appel depuis mandat.p (contrat de gerance 01030)
    ------------------------------------------------------------------------------*/
    define input parameter  pcTypeContrat            as character no-undo.
    define input parameter  pcNumeroContratPrincipal as character no-undo.
    define input parameter  piNumeroAppartement      as integer   no-undo.
    define output parameter piCodeRetour             as integer   no-undo.
    define output parameter piNumeroDocumentSuivant  as integer   no-undo.
    define output parameter piNumeroContratSuivant   as int64     no-undo.

    define variable viContratPrincipal      as integer   no-undo.
    define variable viNoBorInf              as integer   no-undo.
    define variable viNoBorSup              as integer   no-undo.
    define variable viNoOrdSal              as integer   no-undo.
    define variable viNoNxtSal              as integer   no-undo.
    define variable vlFournisseurLoyer      as logical   no-undo.
    define variable vcCdModele              as character no-undo.
    define variable vlMandatTrouve          as logical   no-undo.
    define variable viBorneMandatDeb        as integer   no-undo.
    define variable viBorneMandatFin        as integer   no-undo.
    define variable viNumeroMandat          as integer   no-undo.
    define variable viAnnee                 as int64     no-undo.
    define variable viChrono                as integer   no-undo.
    define variable viReferenceContrat      as integer   no-undo.
    define variable viSousLocationFin       as integer   no-undo initial 200.
    define variable viFournisseurLoyerDebut as integer   no-undo initial 8001.
    define variable viNoSlDFin              as integer   no-undo.

    define buffer ctrat  for ctrat.
    define buffer csscpt for csscpt.
//  define buffer trdos  for trdos.
    define buffer pclie  for pclie.
    define buffer aprof  for aprof.

    {&_proparse_ prolint-nowarn(wholeindex)}
    find last ctrat no-lock no-error.
    piNumeroDocumentSuivant = if available ctrat then ctrat.nodoc + 1 else 1.
    find first pclie no-lock where pclie.tppar = "GESFL" no-error.
    if available pclie and pclie.zon01 = "00001" and pclie.zon03 > ""
    then assign
        vlFournisseurLoyer      = true
        vcCdModele              = if pclie.zon03 > "" then pclie.zon03 else vcCdModele
        viSousLocationFin       = if pclie.zon05 > "" then integer(pclie.zon05) else viSousLocationFin   /* mandats sous-location réservés */
        viFournisseurLoyerDebut = integer(pclie.zon06)                                                   /* debut des fournisseurs loyer */
        viNoSlDFin              = if vcCdModele = "00004"
                                  then (if pclie.int03 > 0 then pclie.int04 else viNoSlDFin)
                                  else viSousLocationFin
    .

    case pcTypeContrat:
        when {&TYPECONTRAT-bail} or when {&TYPECONTRAT-preBail} then do:
            assign
                viNoBorInf = integer(pcNumeroContratPrincipal) * 100000 + piNumeroAppartement * 100       // integer(string(pcNumeroContratPrincipal, "99999") + string(piNumeroAppartement, "999") + "00")
                viNoBorSup = integer(pcNumeroContratPrincipal) * 100000 + piNumeroAppartement * 100 + 99  // integer(string(pcNumeroContratPrincipal, "99999") + string(piNumeroAppartement, "999") + "99")
            .
            find last ctrat no-lock
                where ctrat.tpcon =  pcTypeContrat
                  and ctrat.nocon >= viNoBorInf
                  and ctrat.nocon <= viNoBorSup no-error.
            if available ctrat
            then do:
                if ctrat.nocon modulo 100 = 99 then do:    // substring (string(ctrat.nocon, "9999999999"), 9, 2, 'character') = "99"  /* NP 0608/0065 */
                    piCodeRetour = 2.
                    return.
                end.
                piNumeroContratSuivant = ctrat.nocon + 1.
            end.
            else piNumeroContratSuivant = integer(pcNumeroContratPrincipal) * 100000 + piNumeroAppartement * 100 + 1.  // integer(string(pcNumeroContratPrincipal, "99999") + string(piNumeroAppartement, "999") + "01") . /* NP 0608/0065 */
        end.

        when {&TYPECONTRAT-mutation} or when {&TYPECONTRAT-travaux} or when {&TYPECONTRAT-DossierMutation}
        then do:
            assign
                viContratPrincipal = integer(pcNumeroContratPrincipal)
                viNoBorInf         = viContratPrincipal * 100000    // integer(string(viContratPrincipal, "99999") + "00000")
                viNoBorSup         = viNoBorInf + 99999             // integer(string(viContratPrincipal, "99999") + "99999")
            .
            find last ctrat no-lock
                where ctrat.tpcon =  pcTypeContrat
                  and ctrat.nocon >= viNoBorInf
                  and ctrat.nocon <= viNoBorSup no-error.
            if available ctrat
            then do:
                if ctrat.nocon modulo 100000 = 99999 then do:         // substring (string (ctrat.nocon, "9999999999"), 6, 5, 'character') = "99999"
                    piCodeRetour = 2.
                    return.
                end.
                piNumeroContratSuivant = ctrat.nocon + 1.
            end.
            else piNumeroContratSuivant = viNoBorInf + 1.             // integer(string(viContratPrincipal, "99999") + "00001").
        end.

        when {&TYPECONTRAT-UsufruitNuePropriete} or when {&TYPECONTRAT-CessionUsufruit} or when {&TYPECONTRAT-CessionNuePropriete} or when {&TYPECONTRAT-ExtinctionUsufruit}
        then do:
            assign
                viContratPrincipal = integer(pcNumeroContratPrincipal)
                viNoBorInf         = viContratPrincipal * 10000 + 1   // integer (string (viContratPrincipal, "99999") + "0001")
                viNoBorSup         = viNoBorInf + 9998                // integer (string (viContratPrincipal, "99999") + "9999")
            .
            find last ctrat no-lock
                where ctrat.tpcon =  pcTypeContrat
                  and ctrat.nocon >= viNoBorInf
                  and ctrat.nocon <= viNoBorSup no-error.
            if available ctrat
            then do:
                if ctrat.nocon modulo 10000 = 9999 then do:   // substring (string (ctrat.nocon, "999999999"), 6) = "9999" then do:
                    piCodeRetour = 2.
                    return.
                end.
                piNumeroContratSuivant = ctrat.nocon + 1.
            end.
            else piNumeroContratSuivant = viContratPrincipal * 10000 + 1.         // integer(string(viNoCttPrc, "99999") + "0001").
        end.

        when {&TYPECONTRAT-Salarie} then do:     // gga todo attention dans le pgm initial c 'est code 01045 pas 01096
            assign                               // TODO  ATTENTION, D'ou vient trdos ?????
                viReferenceContrat = mtoken:getSociete(trdos.tpcon)
                viContratPrincipal = integer(pcNumeroContratPrincipal)
                viNoOrdSal         = 00
                viNoBorInf         = viContratPrincipal * 100     // integer(string(viContratPrincipal, "99999") + string(viNoOrdSal, "99"))
                viNoBorSup         = viContratPrincipal + 99      // integer(string(viContratPrincipal, "99999") + "99")
            .
            find last csscpt no-lock
                where csscpt.soc-cd     = viReferenceContrat
                  and csscpt.etab-cd    = viContratPrincipal
                  and csscpt.sscoll-cle = "EI"
                  and csscpt.cpt-cd     < "00050" no-error.
            {&_proparse_ prolint-nowarn(use-index)}
            if not available csscpt
            then find last csscpt no-lock
                where csscpt.soc-cd     = viReferenceContrat
                  and csscpt.etab-cd    = viContratPrincipal
                  and csscpt.sscoll-cle = "EI"
                use-index sscpt-i no-error.  // potentiellement index sscpt-lib, mais ordre alphabétique donne sscpt-i
            if available csscpt
            then assign
                viNoOrdSal = integer(csscpt.cpt-cd)
                viNoBorInf = viContratPrincipal * 100 + viNoOrdSal        // integer(string (viContratPrincipal, "99999") + STRING(viNoOrdSal, "99"))
            .
            find last ctrat no-lock
                where ctrat.tpcon =  pcTypeContrat
                  and ctrat.nocon >= viNoBorInf
                  and ctrat.nocon <= viNoBorSup no-error.
            if not available ctrat
            then piNumeroContratSuivant = viContratPrincipal * 100 + viNoOrdSal + 1.    // integer(string(viContratPrincipal, "99999") + string(viNoOrdSal + 1, "99")).
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
                    piCodeRetour = 2.
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
                viContratPrincipal = integer(pcNumeroContratPrincipal)
                viNoBorInf         = viContratPrincipal * 10000        // integer(string(viContratPrincipal, "99999") + "0000")
                viNoBorSup         = viNoBorInf + 9999                 // integer(string(viContratPrincipal, "99999") + "9999")
            .
            find last ctrat no-lock
                where ctrat.tpcon =  pcTypeContrat
                  and ctrat.nocon >= viNoBorInf
                  and ctrat.nocon <= viNoBorSup no-error.
            if available ctrat
            then do:
                 if ctrat.nocon modulo 10000 = 9999 then do:    // substring(string (ctrat.nocon, "999999999"), 6, 4, 'character') = "9999"
                     piCodeRetour = 2.
                     return.
                 end.
                 piNumeroContratSuivant = ctrat.nocon + 1.
            end.
            else piNumeroContratSuivant = viNoBorInf + 1.                   // integer(string(viContratPrincipal, "99999") + "0001").
        end.

        when {&TYPECONTRAT-mandat2Gerance} or when {&TYPECONTRAT-mandat2Syndic}
        then do:
            assign
                vlMandatTrouve = false
                piNumeroContratSuivant = 0
            .
boucleProfils:
            for each aprof no-lock
                where aprof.profil-cd = (if pcTypeContrat = {&TYPECONTRAT-mandat2Gerance} then 21 else 91):
                assign
                    viBorneMandatDeb = aprof.mandatdeb
                    viBorneMandatFin = aprof.mandatfin
                .
                if pcTypeContrat = {&TYPECONTRAT-mandat2Gerance} and vlFournisseurLoyer
                then do:
                    if (vcCdModele = "00003") then viBorneMandatDeb = viSousLocationFin + 1.
                    if (vcCdModele = "00004") then viBorneMandatDeb = viNoSlDFin + 1.
                    viBorneMandatFin = minimum(aprof.mandatfin, viFournisseurLoyerDebut - 1).
                    if viBorneMandatFin < viBorneMandatdeb then next boucleProfils.
                end.
                find last ctrat no-lock
                    where ctrat.tpcon  =  pcTypeContrat
                      and (ctrat.nocon >= viBorneMandatDeb
                      and ctrat.nocon  <= viBorneMandatFin) no-error.
                if available ctrat then do:
                    if ctrat.nocon <> viBorneMandatFin then do:
                        assign
                            piNumeroContratSuivant     = ctrat.nocon + 1
                            vlMandatTrouve = true
                        .
                        leave boucleProfils.
                    end.
                end.
                else do:
                    assign
                        piNumeroContratSuivant = viBorneMandatDeb
                        vlMandatTrouve         = true
                    .
                    leave boucleProfils.
                end.
            end.
            {&_proparse_ prolint-nowarn(do1)}
            if vlMandatTrouve = false then do:
boucleProfils2:
                for each aprof no-lock
                    where aprof.profil-cd = (if pcTypeContrat = {&TYPECONTRAT-mandat2Gerance} then 21 else 91):
                    assign
                        viBorneMandatDeb = aprof.mandatdeb
                        viBorneMandatFin = aprof.mandatfin
                    .
                    if vlFournisseurLoyer then do:
                        viBorneMandatFin = minimum(aprof.mandatfin, viFournisseurLoyerDebut).
                        if viBorneMandatFin < viBorneMandatdeb then next boucleProfils2.
                    end.
boucleMandat:
                    do viNumeroMandat = viBorneMandatDeb to viBorneMandatFin:
                        find first ctrat no-lock
                            where ctrat.tpcon = pcTypeContrat
                              and ctrat.nocon = viNumeroMandat no-error.
                        if available ctrat then next boucleMandat.

                        assign
                            piNumeroContratSuivant = viNumeroMandat
                            vlMandatTrouve = true
                        .
                        leave boucleMandat.
                    end.
                end.
            end.
            if vlMandatTrouve = false then do:
                piCodeRetour = 3.
                return.
            end.
        end.

        when {&TYPECONTRAT-MandatLocation}
        then do:
            viAnnee = (year(today) modulo 100) * 10000.
            find last ctrat no-lock
                where ctrat.tpcon = pcTypeContrat no-error.
            if available ctrat
            and ctrat.nocon >= viAnnee + 1
            and ctrat.nocon <= viAnnee + 9999
            then assign
                viChrono   = ctrat.nocon modulo 10000   // integer(substring(string(ctrat.nocon , "999999"), 3))
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
