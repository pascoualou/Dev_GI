/*------------------------------------------------------------------------
    File        : indrv_CRUD.p
    Purpose     : Librairie contenant les procédures liées à la mise à jour de la table indrv
    Author(s)   : génération automatique le 04/27/18 + DM - 2017/10/10 + npo - 2018/06/20
    Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
                  que les champs de l'index unique soient tous présents.
                  reprise de adb/src/lib/l_indrv_ext.p
derniere revue: 2018/08/08 - phm: KO
        TODO  N'a rien à voir avec un _CRUD !?
              en plus, si on regarde le code indiceRevision.p, un find lsirv est fait avec ensuite un appel à getLibelleIndice!
              cf indiceRevision.p, Je ne comprend rien!!!!!
  ----------------------------------------------------------------------*/
{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
define variable ghttindrv as handle no-undo.     // le handle de la temp table à mettre à jour

function getIndexField returns logical private(phBuffer as handle, output phCdirv as handle, output phAnper as handle, output phNoper as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur cdirv/anper/noper, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'cdirv' then phCdirv = phBuffer:buffer-field(vi).
            when 'anper' then phAnper = phBuffer:buffer-field(vi).
            when 'noper' then phNoper = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIndrv private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIndrv.
    run updateIndrv.
    run createIndrv.
end procedure.

procedure setIndrv:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIndrv.
    ghttIndrv = phttIndrv.
    run crudIndrv.
    delete object phttIndrv.
end procedure.

procedure readIndrv:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table indrv 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piCdirv as integer    no-undo.
    define input parameter piAnper as integer    no-undo.
    define input parameter piNoper as integer    no-undo.
    define input parameter table-handle phttIndrv.
    define variable vhttBuffer as handle no-undo.
    define buffer indrv for indrv.

    vhttBuffer = phttIndrv:default-buffer-handle.
    for first indrv no-lock
        where indrv.cdirv = piCdirv
          and indrv.anper = piAnper
          and indrv.noper = piNoper:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer indrv:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIndrv no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIndrv:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table indrv 
    Notes  : service externe. Critère piAnper = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piCdirv as integer    no-undo.
    define input parameter piAnper as integer    no-undo.
    define input parameter table-handle phttIndrv.
    define variable vhttBuffer as handle  no-undo.
    define buffer indrv for indrv.

    vhttBuffer = phttIndrv:default-buffer-handle.
    if piAnper = ?
    then for each indrv no-lock
        where indrv.cdirv = piCdirv:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer indrv:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each indrv no-lock
        where indrv.cdirv = piCdirv
          and indrv.anper = piAnper:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer indrv:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIndrv no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIndrv private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhCdirv    as handle  no-undo.
    define variable vhAnper    as handle  no-undo.
    define variable vhNoper    as handle  no-undo.
    define buffer indrv for indrv.

    create query vhttquery.
    vhttBuffer = ghttIndrv:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIndrv:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdirv, output vhAnper, output vhNoper).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first indrv exclusive-lock
                where rowid(indrv) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer indrv:handle, 'cdirv/anper/noper: ', substitute('&1/&2/&3', vhCdirv:buffer-value(), vhAnper:buffer-value(), vhNoper:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer indrv:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIndrv private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define buffer indrv for indrv.

    create query vhttquery.
    vhttBuffer = ghttIndrv:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIndrv:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create indrv.
            if not outils:copyValidField(buffer indrv:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIndrv private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhCdirv    as handle  no-undo.
    define variable vhAnper    as handle  no-undo.
    define variable vhNoper    as handle  no-undo.
    define buffer indrv for indrv.

    create query vhttquery.
    vhttBuffer = ghttIndrv:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIndrv:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdirv, output vhAnper, output vhNoper).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first indrv exclusive-lock
                where rowid(Indrv) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer indrv:handle, 'cdirv/anper/noper: ', substitute('&1/&2/&3', vhCdirv:buffer-value(), vhAnper:buffer-value(), vhNoper:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete indrv no-error.
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

procedure getLibelleIndiceCommun private:
    /*------------------------------------------------------------------------------
    Purpose: Libellé indice de révision
    Notes  :
    ------------------------------------------------------------------------------*/
    define input  parameter piCdPer   as integer   no-undo.
    define input  parameter piAnPer   as integer   no-undo.
    define input  parameter piNoPer   as integer   no-undo.
    define input parameter  pcTypeLib as character no-undo.    // npo pour gérer libellé court et explicite
    define output parameter pcLibelle as character no-undo.

    define variable vcLibelleMes as character no-undo.

    case piCdPer:
        when 1 then  // Indice mensuel
            pcLibelle = substitute("&1 &2", outilTraduction:getLibelleParam("CDMOI", string(piNoPer,"99999"), "c"), string(piAnPer)). // Recherche du libelle du mois

        when 3 then do: // Indice trimestriel
              if mToken:iCodeLangueReference = 0     // Gestion du 1er et des nièmes (pour la France)
              then vcLibelleMes = outilTraduction:getLibelle(if piNoPer = 1 then 44 else 24).
              pcLibelle = substitute("&1&2 &3 &4",
                                piNoPer, vcLibelleMes, outilTraduction:getLibelle(if pcTypeLib = "c" then 102088 else 100997), piAnPer).
        end.

        when 6 then do: // Indice semestriel
            if mToken:iCodeLangueReference = 0     // Gestion du 1er et des nièmes (pour la France)
            then vcLibelleMes = outilTraduction:getLibelle(if piNoPer = 1 then 44 else 24).
            pcLibelle = if pcTypeLib = "c"
                        then substitute("&1&2 &3 &4", piNoPer, vcLibelleMes, string(outilTraduction:getLibelle(107514), "X(3)"), piAnPer)
                        else substitute("&1&2 &3 &4", piNoPer, vcLibelleMes, outilTraduction:getLibelle(107514), piAnPer).
        end.
        when 12 then pcLibelle = string(piAnPer).
    end case.

end procedure.

procedure getLibelleIndice:
    /*------------------------------------------------------------------------------
    Purpose: Libellé indice de révision   
    Notes  : service appelé par baremeHonoraire.p  .... reprise de adb/src/lib/l_indrv_ext.p
    ------------------------------------------------------------------------------*/
    define input parameter  piCdIrv   as integer   no-undo.
    define input parameter  piAnPer   as integer   no-undo.
    define input parameter  piNoPer   as integer   no-undo.
    define input parameter  pcTypeLib as character no-undo.    // npo pour gérer libellé court et explicite
    define output parameter pcLibelle as character no-undo.

    define buffer lsirv for lsirv.

    for first lsirv no-lock where lsirv.cdirv = piCdIrv:
        run getLibelleIndiceCommun(lsirv.cdper, piAnPer, piNoPer, pcTypeLib, output pcLibelle).
    end.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure getLibelleIndiceSurPeriodicite:
    /*------------------------------------------------------------------------------
    Purpose: Libellé indice de révision reprise de adb/src/lib/l_indrv_ext.p (procedure RecLibInd et RecLibInc)
    Notes  : service externe 
    ------------------------------------------------------------------------------*/
    define input parameter  piCdPer   as integer   no-undo.
    define input parameter  piAnPer   as integer   no-undo.
    define input parameter  piNoPer   as integer   no-undo.
    define input parameter  pcTypeLib as character no-undo.    // npo pour gérer libellé court et explicite
    define output parameter pcLibelle as character no-undo.

    run getLibelleIndiceCommun(piCdPer, piAnPer, piNoPer, pcTypeLib, output pcLibelle).
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure readIndiceRevision2:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service reprise de LecIndR2
    ------------------------------------------------------------------------------*/
    define input  parameter piTypeIndiceCou         as integer no-undo.
    define input  parameter piAnneeCou              as integer no-undo.
    define input  parameter piNumeroPeriodeCou      as integer no-undo.
    define input  parameter piNombrePeriodeRevision as integer no-undo.
    define output parameter poCollection            as class collection no-undo.

    define variable viIndice as integer no-undo.

    define buffer indrv for indrv.
    define buffer lsirv for lsirv.

    poCollection = new collection().
    find first indrv no-lock
         where indrv.cdirv = piTypeIndiceCou
           and indrv.anper = piAnneeCou + piNombrePeriodeRevision
           and indrv.noper = piNumeroPeriodeCou no-error.
    if not available indrv then do:
        poCollection:set("lTrouve", false).
        return.
    end.
    
    /* Recuperation des infos */
    poCollection:set("lTrouve",         true).
    poCollection:set("iTypeIndice",     indrv.cdirv).
    poCollection:set("iAnneeCou",       indrv.anper).
    poCollection:set("iNumerPeriode",   indrv.noper).
    poCollection:set("dValeurRevision", indrv.vlirv).
    poCollection:set("dParutionJO",     indrv.dtpjo).
    poCollection:set("daMAJ",           indrv.dtmsy).
    poCollection:set("dTauxRevision",   0.0).                         //init par defaut    
    
    /* Recherche du type d'indice */
    find first lsirv no-lock
         where lsirv.cdirv = piTypeIndiceCou no-error.
    if available lsirv and LsIrv.FgVal = 1
    then poCollection:set("dTauxRevision", indrv.txirv). /* Indice avec taux uniquement */
    else do:
        /* Modif Sy le 14/03/2005 : calcul du taux sur sur la période écoulée (1 ans, 3ans ...) */
        viIndice = indrv.vlirv.
        find first indrv no-lock
             where indrv.cdirv = piTypeIndiceCou
               and indrv.anper = piAnneeCou 
               and indrv.noper = piNumeroPeriodeCou no-error.
        if available indrv
        then poCollection:set("dTauxRevision", ((viIndice * 100) / indrv.vlirv) - 100).
    end.

end procedure.

procedure readIndiceRevision3:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service reprise de LecIndR3
    ------------------------------------------------------------------------------*/
    define input  parameter piTypeIndiceCou         as integer no-undo.
    define input  parameter piAnneeCou              as integer no-undo.
    define input  parameter piNumeroPeriodeCou      as integer no-undo.
    define input  parameter piNombrePeriodeRevision as integer no-undo.
    define output parameter poCollection            as class collection no-undo.

    define variable viIndice as integer no-undo.

    define buffer indrv for indrv.
    define buffer lsirv for lsirv.

    poCollection = new collection().
    find first indrv no-lock
        where indrv.cdIrv = piTypeIndiceCou
          and indrv.anPer = piAnneeCou
          and indrv.noPer = piNumeroPeriodeCou no-error.
    if not available indrv then do:
        poCollection:set("lTrouve", false).
        return.
    end.
    /* Recuperation des infos */
    poCollection:set("lTrouve",         true).
    poCollection:set("iTypeIndice",     indrv.cdirv).
    poCollection:set("iAnneeCou",       indrv.anper).
    poCollection:set("iNumerPeriode",   indrv.noper).
    poCollection:set("dValeurRevision", indrv.vlirv).
    poCollection:set("dParutionJO",     indrv.dtpjo).
    poCollection:set("daMAJ",           indrv.dtmsy).
    poCollection:set("dTauxRevision",   0.0).                         //init par defaut
    /* Recherche du type d'indice */
    find first lsirv no-lock
         where lsirv.cdirv = piTypeIndiceCou no-error.
    if available lsirv and lsirv.fgVal = 1 
    then poCollection:set("dTauxRevision", indrv.txirv). /* Indice avec taux uniquement  */
    else do:
        /** Modif Sy le 14/03/2005 : calcul du taux sur la période écoulée ( 1 ans , 3ans ...) **/
        viIndice = indrv.vlirv.
        find first indrv no-lock
             where indrv.cdIrv = piTypeIndiceCou
               and indrv.anPer = piAnneeCou - piNombrePeriodeRevision
               and indrv.noPer = piNumeroPeriodeCou no-error.
        if available indrv 
        then poCollection:set("dTauxRevision", ((viIndice * 100) / indrv.vlirv) - 100).
    end.

end procedure.
