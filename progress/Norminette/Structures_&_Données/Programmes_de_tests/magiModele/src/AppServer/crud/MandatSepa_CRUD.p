/*------------------------------------------------------------------------
File        : mandatSepa_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table MandatSepa
Author(s)   : generation automatique le 01/31/18 - Adaptation SPo 2018/06/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
derniere revue: 2018/08/08 - phm: 
------------------------------------------------------------------------*/
{preprocesseur/type2contrat.i}
{preprocesseur/nature2contrat.i}
{preprocesseur/origineRUM.i}

using parametre.pclie.parametrageChronoRUM.
{oerealm/include/instanciateTokenOnModel.i}            // Doit être positionnée juste après using
define variable ghttMandatSepa as handle no-undo.      // le handle de la temp table à mettre à jour

function getIndexField returns logical private(phBuffer as handle, output phNomprelsepa as handle, output phNomdt as handle, output phtpcon as handle , output phNocon as handle, output phtprol as handle, output phNorol as handle, output phnoord as handle, output phcoderum as handle, output phnomandat as handle, output phcdori as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur noMPrelSEPA,
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'noMPrelSEPA' then phNomprelsepa = phBuffer:buffer-field(vi).
            when 'nomdt'       then phNomdt       = phBuffer:buffer-field(vi).
            when 'tpcon'       then phtpcon       = phBuffer:buffer-field(vi).
            when 'nocon'       then phnocon       = phBuffer:buffer-field(vi).
            when 'tprol'       then phtprol       = phBuffer:buffer-field(vi).
            when 'norol'       then phnorol       = phBuffer:buffer-field(vi).
            when 'noord   '    then phnoord       = phBuffer:buffer-field(vi).
            when 'coderum'     then phcoderum     = phBuffer:buffer-field(vi).
            when 'nomandat'    then phnomandat    = phBuffer:buffer-field(vi).
            when 'cdori'       then phcdori       = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

function getNextMandatsepa returns int64 private():
    /*------------------------------------------------------------------------------
    Purpose: prochain no unique de mandat SEPA
    Notes  :
    ------------------------------------------------------------------------------*/
    define buffer mandatSepa for mandatSepa.
    {&_proparse_ prolint-nowarn(wholeIndex)}
    for last mandatSepa no-lock where mandatSepa.nomprelsepa > 0:
        return mandatSepa.nomprelsepa + 1.
    end.
    return 1.
end function.

function getNextOrdreMandatsepa returns integer private(poCollectionContratRole as class collection):
    /*------------------------------------------------------------------------------
    Purpose: Prochain no d'ordre pour la création d'un mandat SEPA pour un contrat + role
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable viNumMandatMaitre as integer   no-undo.
    define variable vcTypeContrat     as character no-undo.
    define variable viNumContrat      as int64     no-undo.
    define variable vcTypeRole        as character no-undo.
    define variable viNumRole         as int64     no-undo.

    define buffer mandatSepa for mandatSepa.
    assign
        viNumMandatMaitre = poCollectionContratRole:getInteger('iNumMandatMaitre')
        vcTypeContrat     = poCollectionContratRole:getCharacter('cTypeContrat')
        viNumContrat      = poCollectionContratRole:getInt64('iNumContrat')
        vcTypeRole        = poCollectionContratRole:getCharacter('cTypeRole')
        viNumRole         = poCollectionContratRole:getInt64('iNumRole')
    .
    {&_proparse_ prolint-nowarn(wholeIndex)}
    for last mandatSepa  no-lock
        where mandatSEPA.tpmandat = {&TYPECONTRAT-sepa}
          and mandatSEPA.ntcon    = {&NATURECONTRAT-recurrent}
          and mandatSEPA.nomdt    = viNumMandatMaitre
          and mandatSEPA.tpcon    = vcTypeContrat
          and mandatSEPA.nocon    = viNumContrat
          and mandatSEPA.tprol    = vcTypeRole
          and mandatSEPA.norol    = viNumRole
        use-index ix_mandatsepa07:
        return mandatSEPA.noord + 1.
    end.
    return 1.
end function.

procedure crudMandatsepa private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteMandatsepa.
    run updateMandatsepa.
    run createMandatsepa.
end procedure.

procedure setMandatsepa:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttMandatsepa.
    ghttMandatsepa = phttMandatsepa.
    run crudMandatsepa.
    delete object phttMandatsepa.
end procedure.

procedure readMandatsepa:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table MandatSepa Mandats de prélèvement SEPA
    Notes  : Fiche 0511/0023. Service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNomprelsepa as int64      no-undo.
    define input parameter table-handle phttMandatsepa.
    define variable vhttBuffer as handle no-undo.
    define buffer MandatSepa for MandatSepa.

    vhttBuffer = phttMandatsepa:default-buffer-handle.
    for first MandatSepa no-lock
        where MandatSepa.noMPrelSEPA = piNomprelsepa:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer MandatSepa:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttMandatsepa no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getMandatsepa:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table MandatSepa Mandats de prélèvement SEPA
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input  parameter pcTpcon    as character no-undo.
    define input  parameter piNocon    as int64     no-undo.
    define input  parameter pcTpmandat as character no-undo.
    define input  parameter pcNtcon    as character no-undo.
    define input parameter table-handle phttMandatsepa.
    define variable vhttBuffer as handle  no-undo.
    define buffer MandatSepa for MandatSepa.

    vhttBuffer = phttMandatsepa:default-buffer-handle.
    if pcNtcon > ""
    then for each mandatSepa no-lock
        where mandatSepa.tpcon    = pcTpcon
          and mandatSepa.nocon    = piNocon
          and mandatSepa.tpmandat = pcTpmandat
          and mandatSepa.ntcon    = pcNtcon:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer mandatSepa:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each mandatSepa no-lock
        where mandatSepa.tpcon    = pcTpcon
          and mandatSepa.nocon    = piNocon
          and mandatSepa.tpmandat = pcTpmandat:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer MandatSepa:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttMandatsepa no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure getContratDeReference private:
    /*------------------------------------------------------------------------------
    Purpose: recherche du contrat de référence pour le RUM du mandat de prélèvement SEPA
             = contrat bail pour le locataire, futur contrat bail pour le candidat locataire
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeContrat     as character no-undo.
    define input parameter piNoContrat       as int64     no-undo.
    define output parameter pcTypeContratRef as character no-undo.
    define output parameter piNoContratRef   as int64     no-undo.
    define variable vinomandatUL as integer no-undo.
    define variable viNoBailMin  as int64   no-undo.
    define variable viNoBailMax  as int64   no-undo.
    define buffer ctrat for ctrat.

    assign
        pcTypeContratRef = pcTypeContrat
        piNoContratRef   = piNoContrat
    .
    if pcTypeContratRef = {&TYPECONTRAT-preBail} then do:
        assign
            vinomandatUL     = integer(truncate(piNoContrat / 100, 0))
            viNoBailMin      = vinomandatUL * 100 + 01
            viNoBailMax      = vinomandatUL * 100 + 99
            pcTypeContratRef = {&TYPECONTRAT-bail}
            piNoContratRef   = viNoBailMin
        .
        /* dernier locataire */
        for last ctrat no-lock
            where ctrat.tpcon = {&TYPECONTRAT-bail}
              and ctrat.nocon >= viNoBailMin
              and ctrat.nocon <= viNoBailMax:
            if ctrat.nocon + 1 <= viNoBailMax then piNoContratRef = ctrat.nocon + 1.
        end.
    end.
end procedure.

procedure createMandatsepa private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery               as handle    no-undo.
    define variable vhttBuffer              as handle    no-undo.
    define variable vhNoMPrelSEPA           as handle    no-undo.
    define variable vhNomdt                 as handle    no-undo.
    define variable vhtpcon                 as handle    no-undo.
    define variable vhNocon                 as handle    no-undo.
    define variable vhTprol                 as handle    no-undo.
    define variable vhNorol                 as handle    no-undo.
    define variable vhcoderum               as handle    no-undo.
    define variable vhnomandat              as handle    no-undo.
    define variable vhnoord                 as handle    no-undo.
    define variable vhcdori                 as handle    no-undo.
    define variable viNoMPrelSEPA           as int64     no-undo.
    define variable viNoord                 as integer   no-undo.
    define variable vcCdori                 as character no-undo.
    define variable vccoderum               as character no-undo.
    define variable viNoChronoSEPA          as integer   no-undo.
    define variable vcTypeContratRef        as character no-undo.
    define variable viNoContratRef          as int64     no-undo.
    define variable voCollectionRoleContrat as class collection           no-undo.
    define variable voParametrageChronoRUM  as class parametrageChronoRUM no-undo.

    define buffer mandatSepa for mandatSepa.
    define buffer roles      for roles.

    create query vhttquery.
    assign
        voCollectionRoleContrat = new collection()
        voParametrageChronoRUM  = new parametrageChronoRUM()
        vhttBuffer              = ghttMandatsepa:default-buffer-handle
    .
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttMandatsepa:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNomprelsepa, output vhNomdt, output vhtpcon, output vhNocon, output vhTprol, output vhNorol, output vhNoord, output vhcoderum, output vhnomandat, output vhCdori).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            voCollectionRoleContrat:set("iNumMandatMaitre", vhnomdt:buffer-value()).
            voCollectionRoleContrat:set("cTypeContrat", vhtpcon:buffer-value()).
            voCollectionRoleContrat:set("iNumContrat", vhnocon:buffer-value()).
            voCollectionRoleContrat:set("cTypeRole", vhtprol:buffer-value()).
            voCollectionRoleContrat:set("iNumRole", vhnorol:buffer-value()).
            assign
                vcCdori                      = vhCdori:buffer-value()
                vccoderum                    = vhcoderum:buffer-value()
                viNoMPrelSEPA                = getNextMandatsepa()
                vhNoMPrelSEPA:buffer-value() = viNoMPrelSEPA
                vhnomandat:buffer-value()    = viNoMPrelSEPA
                viNoord                      = getNextOrdreMandatsepa(voCollectionRoleContrat)
                vhnoord:buffer-value()       = viNoord
            .
            if vcCdori = {&ORIGINERUM-automatiqueGI} then do:
                 voParametrageChronoRUM:getNextNoChronoSEPA(output viNoChronoSEPA).
                 if viNoChronoSEPA = ? or viNoChronoSEPA = 0 then do:
                    mError:createError({&error}, 1000788).
                    undo blocTrans, leave blocTrans.
                 end.
                 if mError:erreur() then undo blocTrans, leave blocTrans.
                 for first roles no-lock
                     where roles.tprol = vhtprol:buffer-value()
                       and roles.norol = vhnorol:buffer-value():
                     run getContratDeReference (vhtpcon:buffer-value(), vhnocon:buffer-value(), output vcTypeContratRef, output viNoContratRef).
                     assign
                         vccoderum = substitute("&1&2&3&4",
                                         if vcTypeContratRef = {&TYPECONTRAT-titre2copro} then mToken:cRefCopro else mToken:cRefGerance,
                                         string(roles.notie, "9999999999"),
                                         string(viNoContratRef, "9999999999"),
                                         string(viNoChronoSEPA, "9999999"))
                         vhcoderum:buffer-value() = vccoderum
                     .
                 end.
            end.
            if vhcoderum:buffer-value() = ? or vhcoderum:buffer-value() = "" then do:
                mError:createError({&error}, 1000798).
                undo blocTrans, leave blocTrans.
            end.
            create MandatSepa.
            if not outils:copyValidField(buffer MandatSepa:handle, vhttBuffer, "", mtoken:cUser)    // create sans réinitialisation CRUD
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    delete object voCollectionRoleContrat.
    delete object voParametrageChronoRUM.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteMandatsepa private:
    /*------------------------------------------------------------------------------
    Purpose: suppression en fonction du CRUD du dataset 
    Notes  : la suppression des lignes suimandatsepa associées est effectuée via suimandatsepa_CRUD.p
    ------------------------------------------------------------------------------*/
    define variable vhttquery     as handle  no-undo.
    define variable vhttBuffer    as handle  no-undo.
    define variable vhNomprelsepa as handle  no-undo.
    define variable vhNomdt       as handle  no-undo.
    define variable vhtpcon       as handle  no-undo.
    define variable vhNocon       as handle  no-undo.
    define variable vhTprol       as handle  no-undo.
    define variable vhNorol       as handle  no-undo.
    define variable vhcoderum     as handle  no-undo.
    define variable vhnomandat    as handle  no-undo.
    define variable vhnoord       as handle  no-undo.
    define variable vhcdori       as handle  no-undo.
    define buffer MandatSepa for MandatSepa.

    create query vhttquery.
    vhttBuffer = ghttMandatsepa:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttMandatsepa:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNomprelsepa, output vhNomdt, output vhtpcon, output vhNocon, output vhTprol, output vhNorol, output vhNoord, output vhcoderum, output vhnomandat, output vhCdori).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first MandatSepa exclusive-lock
                where rowid(Mandatsepa) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer MandatSepa:handle, 'noMPrelSEPA: ', substitute('&1', vhNomprelsepa:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete MandatSepa no-error.
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

procedure deleteMandatSepaSurContrat:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant à un contrat (suppression de mandat, bail...)
    Notes  : service externe
             pas de fusion avec deleteMandatSepaRoleContrat pour plus de lisibilité
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeMandatSepa as character no-undo.
    define input parameter pcTypeContrat    as character no-undo.
    define input parameter piNumeroContrat  as int64     no-undo.

    define buffer mandatSepa    for mandatSepa.
    define buffer suimandatSepa for suimandatSepa.

//message "deleteMandatSepaSurContrat "  pcTypeMandatSepa "// " pcTypeContrat "// " piNumeroContrat.

blocTrans:
    do transaction:
        for each mandatSepa exclusive-lock
           where mandatSepa.tpmandat = pcTypeMandatSepa
             and mandatSepa.tpcon    = pcTypeContrat
             and mandatSepa.nocon    = piNumeroContrat:
            for each suimandatSepa exclusive-lock
                where suimandatSepa.noMPrelSEPA = mandatSepa.noMPrelSEPA:
                delete suimandatSepa no-error.
                if error-status:error then do:
                    mError:createError({&error}, error-status:get-message(1)).
                    undo blocTrans, leave blocTrans.
                end.
            end.
            delete mandatSepa no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    error-status:error = false no-error.  // reset error-status
    return.
end procedure.

procedure deleteMandatSepaRoleContrat:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant à un role et un contrat (suppression d'un role)
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeMandatSepa as character no-undo.
    define input parameter pcTypeContrat    as character no-undo.
    define input parameter piNumeroContrat  as int64     no-undo.
    define input parameter pcTypeRole       as character no-undo.
    define input parameter piNumeroRole     as int64     no-undo.

    define buffer mandatSepa    for mandatSepa.
    define buffer suimandatSepa for suimandatSepa.

blocTrans:
    do transaction:
        for each mandatsepa exclusive-lock
            where mandatsepa.tpmandat = pcTypeMandatSepa
              and mandatsepa.tpcon    = pcTypeContrat
              and mandatsepa.nocon    = piNumeroContrat
              and mandatsepa.tprol    = pcTypeRole
              and mandatsepa.norol    = piNumeroRole:
            for each suimandatSepa exclusive-lock
                where suimandatSepa.noMPrelSEPA = mandatSepa.noMPrelSEPA:
                delete suimandatSepa no-error.
                if error-status:error then do:
                    mError:createError({&error}, error-status:get-message(1)).
                    undo blocTrans, leave blocTrans.
                end.
            end.
            delete mandatSEPA no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    error-status:error = false no-error.  // reset error-status
    return.
end procedure.

procedure updateMandatsepa private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery     as handle  no-undo.
    define variable vhttBuffer    as handle  no-undo.
    define variable vhNomprelsepa as handle  no-undo.
    define variable vhNomdt       as handle  no-undo.
    define variable vhtpcon       as handle  no-undo.
    define variable vhNocon       as handle  no-undo.
    define variable vhTprol       as handle  no-undo.
    define variable vhNorol       as handle  no-undo.
    define variable vhcoderum     as handle  no-undo.
    define variable vhnomandat    as handle  no-undo.
    define variable vhnoord       as handle  no-undo.
    define variable vhcdori       as handle  no-undo.
    define buffer MandatSepa for MandatSepa.

    create query vhttquery.
    vhttBuffer = ghttMandatsepa:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttMandatsepa:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNomprelsepa, output vhNomdt, output vhtpcon, output vhNocon, output vhTprol, output vhNorol, output vhNoord, output vhcoderum, output vhnomandat, output vhCdori).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first MandatSepa exclusive-lock
                where rowid(MandatSepa) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer MandatSepa:handle, 'noMPrelSEPA: ', substitute('&1', vhNomprelsepa:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer MandatSepa:handle, vhttBuffer, "", mtoken:cUser)    // update sans réinitialisation CRUD
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.
