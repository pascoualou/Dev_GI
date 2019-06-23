/*------------------------------------------------------------------------
File        : gidemat.p
Description :
Author(s)   : LGI/  -  2017/01/17 
Notes       :
derniere revue: 2018/04/12 - phm: KO
                remplacer vcCrit par un object collection.
                procedure gidemat_param private: faire autant de sous-procedure que de WHEN.
                pour un déploiement, supprimer les messages.
                le bloc suivant est défini 3 fois, en faire une fonction.
                    /* Utilisateur paramétré par défaut */
                    find first iparm no-lock
                        where iparm.tppar = "GIDEMAT_ACCES" no-error.
                    if not available iparm
                    or iparm.lib = ?
                    or num-entries(iparm.lib, separ[1]) < 2
                    or entry(1, iparm.lib, separ[1]) + entry(2, iparm.lib, separ[1]) = ""
                    then do:
                        mError:createError({&error}, 1000247). /* L'identifiant et le mot de passe de l'accès Gidemat ne sont pas paramétrés */
                        return.
                    end.
                    vcTmp = trim(f_gidemat_custom(entry(1, iparm.lib, separ[1]), entry(2, iparm.lib, separ[1]))). /* recherche du custom */
                    if vcTmp > "" then assign
                        gcGidematUser     = entry(1, iparm.lib, separ[1])
                        gcGidematPassword = entry(2, iparm.lib, separ[1])
                        gcGidematCustom   = vcTmp
                    .
                    else do:
                        mError:createError({&error}, 1000247, entry(1, iparm.lib, separ[1])). /* Connection à gidemat impossible avec l'utilisateur &1 */
                        return.
                    end.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */
{application/include/error.i}
{application/include/glbsepar.i}
{ged/include/documentGidemat.i}

define variable gcGidematUser     as character no-undo.
define variable gcGidematPassword as character no-undo.
define variable gcGidematCustom   as character no-undo.
define variable gcActiveNode      as character no-undo.
define variable gcTmpLong         as longchar  no-undo.

define temp-table ttmodindex no-undo xml-node-name "object"
     field cKey    as character xml-node-name "column"
     field cValue  as character xml-node-name "value"
     field cType   as character xml-node-name "type"
.
define temp-table ttarrayOfFile no-undo namespace-uri ""  xml-node-name "item"
    field id-fich as int64 serialize-hidden
    field cFile as clob xml-node-type "TEXT"
.
define temp-table ttarrayOfXml no-undo namespace-uri "" xml-node-name "ficxml"
    field id-fich as int64 serialize-hidden
    field cXml as clob xml-node-name "value"
.
define temp-table ttretour no-undo
    field IdGI-resId as character format "x(20)"
    field cResId as character format "x(20)"
    field return-code as character format "x(20)"
    field cERROR as character
.
define dataset TblFile namespace-uri "urn:MySoapServer"  xml-node-name "items" for ttarrayOfFile.
define dataset TblXml namespace-uri "urn:MySoapServer" xml-node-name "ficxmls" for ttarrayOfXml.

function f_ReferenceClientGidemat returns character:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service appelé par versement.p, ...
    ------------------------------------------------------------------------------*/
    define buffer iparm for iparm.

    for first iparm no-lock
        where iparm.tppar = "GED":
        return iparm.zone2.
    end.
    return ?.
end function.

function f_repertoireGed returns character:
    /*------------------------------------------------------------------------------
    Purpose: retourne le chemin du repertoire GED
    Notes  : service appelé par versement.p, ...
             Création du répertoire temporaire de transfert ged --> M:\gi\trans\svg\ged\99999 (ou 99999 = refcli)
    ------------------------------------------------------------------------------*/
    define variable vcRepertoire as character no-undo.

    vcRepertoire = right-trim(replace(mToken:getValeur('REPGI'), "/", outils:separateurRepertoire()), outils:separateurRepertoire()) + substitute("&1trans&1svg&1ged", outils:separateurRepertoire()).
    os-create-dir value(vcRepertoire).
    vcRepertoire = substitute('&1&3&2', vcRepertoire, f_ReferenceClientGidemat(), outils:separateurRepertoire()).
    os-create-dir value(vcRepertoire).
    return vcRepertoire.

end function.

function f_RepertoireFileWatcher returns character:
    /*------------------------------------------------------------------------------
    Purpose: retourne le chemin du repertoire filewatcher
    Notes  : service appelé par versement.p, ...
             Création du répertoire FileWatcher M:\gi\trans\svg\ged\99999\filewatcher (ou 99999 = refcli)
    ------------------------------------------------------------------------------*/
    define variable vcRepertoire as character no-undo. 

    vcRepertoire = f_repertoireGed() + substitute("&1filewatcher", outils:separateurRepertoire()).
    os-create-dir value(vcRepertoire).
    return vcRepertoire.

end function.

function f_TailleMax returns integer ():
    /*------------------------------------------------------------------------------
    Purpose: Taille maxi autorisée d'un fichier (en Mo)
    Notes  : service appelé par versement.p, ...  
    ------------------------------------------------------------------------------*/
    define buffer aparm for aparm.

    for first aparm no-lock 
        where aparm.tppar = "GEDPAR"
          and aparm.cdpar = "SIZF":
        return integer(aparm.zone2).
    end.
    return 0.

end function.

function f_gidemat_custom returns character private (pcUser as character, pcPassword as character):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhServer   as handle    no-undo.
    define variable vhPortType as handle    no-undo.
    define variable vcUrl      as character no-undo.
    define variable vlReturn   as logical   no-undo.
    define variable vcReturn   as character no-undo.

    define buffer iparm for iparm.

    find first iparm no-lock
        where iparm.tppar = "GIDEMAT_WS_GIDEMAT" no-error.
    if not available iparm then return ?.

    vcUrl = entry(1, iparm.lib, separ[1]). /* URL DU WS Gidemat */
    /* Connexion au serveur */
    create server vhServer.
    vlReturn = vhServer:connect(substitute(" -WSDL &1 -sslprotocols TLSv1 -sslciphers AES128-SHA -Service LoginService -Port LoginPort", vcUrl)) no-error.
    if error-status:num-messages > 0
    then do:
        run erreurs_connection.
        return ?.
    end.
    if vlReturn then do:
        run LoginPort set vhPortType on server vhServer.
        run getLogin in vhPortType(pcUser, pcPassword, f_ReferenceClientGidemat(), output vcReturn).
    end.        
    vhServer:disconnect() no-error.
    delete object vhServer no-error.
    return entry(1, vcReturn, "-").

end function.

procedure getDocumentParIdGed:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service appelé par des .p
    ------------------------------------------------------------------------------*/
    define input  parameter piIdentifiantGed as int64 no-undo.
    define output parameter table for ttDocumentGidemat. 

    define variable vcNomDuFichier as character no-undo.
    define buffer igeddoc for igeddoc.

    empty temp-table ttDocumentGidemat.

    find first igeddoc no-lock
        where igeddoc.id-fich = piIdentifiantGed no-error.
    if not available igeddoc
    then do:
        mError:createError({&error}, 1000072, string(piIdentifiantGed)). /* 1000072 'fiche ged &1 inexistante.' */
        return.
    end.

    /* 1 = transféré, 2 non transféré, 3 non copié dans le répertoire avant transfert */
    vcNomDuFichier = string(igeddoc.id-fich)
                  + if r-index(igeddoc.nmfichier, '.') > 0 then substring(igeddoc.nmfichier, r-index(igeddoc.nmfichier, '.')) else ''.
    if igeddoc.statut-cd = "2" /* le fichier est dans le repertoire de transfert */
    then do:
        mError:createError({&error}, 1000073, vcNomDuFichier).          /* Fichier &1.7z non transféré */
        return.
    end.

    if igeddoc.statut-cd = "3"
    then do:
        mError:createError({&error}, 1000074, vcNomDuFichier).           /* "Le fichier &1 n'est pas dans le répertoire de transfert"). */
        return.
    end.
    /* connection gidemat et ouverture du fichier */
    run gidemat_extract_doc(substitute("&1,RESID,&2", if num-entries(igeddoc.cdivers2, separ[1]) >= 4 then entry(4, igeddoc.cdivers2, separ[1]) else "", igeddoc.resid)).

end procedure.

procedure getDocumentParIdGidemat:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service appelé par des .p
    ------------------------------------------------------------------------------*/
    define input  parameter piIdentifiantGidemat as int64 no-undo.
    define output parameter table for ttDocumentGidemat. 

    empty temp-table ttDocumentGidemat.
    /* connexion gidemat et ouverture du fichier */
    run gidemat_extract_doc(substitute("&1,RESID,&2", "O", piIdentifiantGidemat)).

end procedure.


procedure gidemat_auth private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vcTmp as character no-undo.

    define buffer iparm for iparm.
    define buffer tutil for tutil.

    if gcGidematUser > "" and gcGidematPassword > "" and gcGidematCustom > "" then return.

    find first iparm no-lock
        where iparm.tppar = "GIDEMAT_ACCES" no-error.
    find first tutil no-lock
        where tutil.ident_u = mtoken:cUser no-error.
    /* Code utilisateur et mot de passe GIDEMAT paramétré */
    if  available tutil
    and tutil.fg-mdpgidemat
    and available iparm
    and entry(1, iparm.lib, separ[1]) + (if num-entries(iparm.lib, separ[1]) >= 2 then entry(2, iparm.lib, separ[1]) else '') > ""
    then do:
        assign
            vcTmp = ?    // ne pas enlever, si la fonction f_gidemat_custom est en erreur, vcTmp vaut ?
            vcTmp = f_gidemat_custom(entry(1, iparm.lib, separ[1]), if num-entries(iparm.lib, separ[1]) >= 2 then entry(2, iparm.lib, separ[1]) else '')
        no-error.
        if vcTmp = ?
        then do:
            mError:createError({&error}, 1000075). /* Echec de connection à Gidemat */
            assign
                gcGidematUser     = ""
                gcGidematPassword = ""
                gcGidematCustom   = ""
            .
        end.
        else if vcTmp = "" or vcTmp = ? or entry(1, iparm.lib, separ[1]) = ""
        then do:
            mError:createError({&error}, 1000076). /* Identifiant ou mot de passe paramétré incorrect */
            assign
                gcGidematUser     = ""
                gcGidematPassword = ""
                gcGidematCustom   = ""
            .
        end.
        else assign
            gcGidematUser     = entry(1, iparm.lib, separ[1])
            gcGidematPassword = if num-entries(iparm.lib, separ[1]) >= 2 then entry(2, iparm.lib, separ[1]) else ''
            gcGidematCustom   = vcTmp
        .
    end.
    else do:
        mError:createError({&error}, 1000084). /* Utilisateur non authentifié pour accéder à Gidemat */
        assign
            gcGidematUser     = ""
            gcGidematPassword = ""
            gcGidematCustom   = ""
        .
    end.

end procedure.

procedure erreurs_connection private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable viTmp   as integer no-undo.

boucle:
    do viTmp = 1 to error-status:num-messages:
        if  error-status:get-number(viTmp) = 9318              // Secure Socket Layer (SSL) failure. error code <err_number>: <ssl_error_message> (9318)
        and error-status:get-message(viTmp) matches "*certs*"
        and error-status:get-message(viTmp) matches "* -54 *"
        then do:
            /* Erreur &1 Les certificats ne sont pas installés dans le répertoire &2  --> Veuillez contacter la GI. */
            mError:createError({&error}, 1000078, string(error-status:get-number(viTmp)) + separ[1] + os-getenv("DLC")).
            leave boucle.
        end.
        else if (error-status:get-number(viTmp) = 9318 and error-status:get-message(viTmp) matches "* 10060 *")
             or error-status:get-number(viTmp) = 9407
             /* Erreur &1 (10060) Erreur réseau inconnue --> Vérifier la connection internet. */
        then mError:createError({&error}, 1000079, string(error-status:get-number(viTmp))).
        else mError:createError({&error}, substitute("&1 &2", error-status:get-number(viTmp), error-status:get-message(viTmp))).
    end.

end procedure.

procedure gidemat_extract_doc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter pcParametre as character no-undo.

    define variable vhServer         as handle    no-undo.
    define variable vcCrit           as character no-undo.
    define variable vcCrit-sav       as character no-undo.
    define variable vrRowid          as rowid     no-undo.
    define variable vcCoproprietaire as character no-undo.
    define variable vcMandataire     as character no-undo.
    define variable vcIndivisaire    as character no-undo.

    /* authentification */
    run gidemat_auth.
    mError:getErrors(output table ttError).
    if can-find(first tterror)
    or gcGidematCustom = ? or gcGidematCustom = "" then return.

    /* Connexion au WS Maarch */
    run maarch_connect(output vhServer).
    if not valid-handle(vhServer) then return.

    run gidemat_param(pcParametre, output vcCrit).
    if vcCrit = ?
    then mError:createError({&error}, 1000080). /* Type d'accès au document non géré */
    else do:
        /* Extraction des documents vérifiant les critères */
        assign
            vcCrit-sav                 = vcCrit
            entry(1, vcCrit, separ[1]) = "" /* "" = Liste de documents (sans le contenu) */
        .
        empty temp-table ttDocumentGidemat.
        run maarch_query(vhServer, vcCrit).
        find first ttDocumentGidemat no-error.
        if available ttDocumentGidemat
        and entry(1, vcCrit-sav, separ[1]) > ""   /* Ouverture demandée */
        then do:
            /* Recherche du dernier document de la liste  */
            assign
                vcCoproprietaire = outilTraduction:getLibelle(101185)
                vcMandataire     = outilTraduction:getLibelle(101184)
                vcIndivisaire    = outilTraduction:getLibelle(102801)
                vrRowid          = ?
            .
boucle:
            for each ttDocumentGidemat 
                by (if ttDocumentGidemat.cDestinataire = vcCoproprietaire then 1 else 99999)
                by (if ttDocumentGidemat.cDestinataire = vcIndivisaire    then 2 else 99999)
                by (if ttDocumentGidemat.cDestinataire = vcMandataire     then 3 else 99999)
                by ttDocumentGidemat.iIdentifiantGidemat descending:
                vrRowid = rowid(ttDocumentGidemat).
                leave boucle.
            end.
            find first ttDocumentGidemat where rowid(ttDocumentGidemat) = vrRowid no-error.
            if available ttDocumentGidemat
            then do:
                entry(2, vcCrit-sav, separ[1]) = string(ttDocumentGidemat.iIdentifiantGidemat). /* contenu demandé */
                empty temp-table ttDocumentGidemat.
                run maarch_query(vhServer, vcCrit-sav). /* extraction du dernier document avec le contenu */
            end.
            else if entry(2, vcCrit, separ[1]) > ""
                 then mError:createError({&error}, outilTraduction:getLibelle(1000081) + entry(2, vcCrit, separ[1])). /* Aucun document ne correspond au resid Gidemat */
        end.
    end.
    /* Déconnexion */
    vhServer:disconnect() no-error.
    delete object vhServer no-error.

end procedure.

procedure maarch_connect private:
    /*------------------------------------------------------------------------------
    Purpose: Connection au WS Maarch
    Notes  :
    ------------------------------------------------------------------------------*/
    define output parameter phServer as handle no-undo.

    define variable vcUrl    as character no-undo.
    define variable vlReturn as logical   no-undo.
    define buffer iparm for iparm.

    find first iparm no-lock
        where iparm.tppar = "GIDEMAT_WS_MAARCH" no-error.
    if not available iparm then return ?.

    vcUrl = replace(entry(1, iparm.lib, separ[1]), "[custom]", gcGidematCustom). // https://gi-7.la-gi.fr/[custom]/ws_server.php?WSDL
    create server phServer.
    vlReturn = phServer:connect(
        substitute(
            "-WSDL &1 -WSDLUserid &2 -WSDLPassword &3 -SOAPEndpointUserid &4 -SOAPEndpointPassword &5 -sslprotocols TLSv1 -sslciphers AES128-SHA -connectionLifetime 600"
           , vcUrl
           , gcGidematUser
           , gcGidematPassword
           , gcGidematUser
           , gcGidematPassword)) no-error.
    if not vlReturn
    then do:
        if error-status:num-messages > 0 then run erreurs_connection.
        delete object phServer no-error.
    end.

end procedure.

procedure gidemat_param private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input  parameter pcParametre as character no-undo.
    define output parameter pcResultat  as character no-undo.

    define variable vcTypeConsult     as character no-undo.
    define variable vcResid           as character no-undo.
    define variable vcReferenceClient as character no-undo.
    define variable vcNumeroSociete   as character no-undo.
    define variable vcDocType         as character no-undo.
    define variable vcNumeroMandat    as character no-undo.
    define variable vcNumeroCompte    as character no-undo.
    define variable vcNumtrt          as character no-undo.
    define variable vcChemise         as character no-undo.
    define variable vcNumeroImmeuble  as character no-undo.
    define variable vcNumeroLot       as character no-undo.
    define variable vcLibelleTrt      as character no-undo.
    define variable vcAnneeMois       as character no-undo.
    define variable vcDateDebut       as character no-undo.
    define variable vcDateFin         as character no-undo.
    define variable vcRowid           as character no-undo.
    define variable vcLstParam        as character no-undo.
    define variable vlOK              as logical   no-undo.
    define variable vdaDateCompta     as date      no-undo.
    define variable vlODRTProprio     as logical   no-undo.
    define variable vcExtension       as character no-undo.
    define variable viSepar1          as integer   no-undo.

    define buffer ichrono   for ichrono.
    define buffer ibque     for ibque.
    define buffer ifdsai    for ifdsai.
    define buffer ifdparam  for ifdparam.
    define buffer iftsai    for iftsai.
    define buffer cecrsai   for cecrsai.
    define buffer cecrln    for cecrln.
    define buffer igeddoc   for igeddoc.
    define buffer ijou      for ijou.
    define buffer cecrlnana for cecrlnana.
    define buffer vbCecrln  for cecrln.
    define buffer vbIjou    for ijou.

    assign
        vcExtension       = entry(1, pcParametre)
        vcTypeConsult     = if num-entries(pcParametre, ',') >= 2 then entry(2, pcParametre, ',') else ''
        vcReferenceClient = f_ReferenceClientGidemat()
    .
    case vcTypeConsult:
        when "ecr" or when "ecrlnana" then do:
            vcRowid = if num-entries(pcParametre, ',') >= 3 then entry(3, pcParametre) else ''.
            if vcTypeConsult = "ecrlnana"
            then do:
                {&_proparse_ prolint-nowarn(release)}
                release cecrln.
                find first cecrlnana no-lock
                    where rowid(cecrlnana) = to-rowid(vcRowid) no-error.
                if available cecrlnana
                then find first cecrln no-lock 
                    where cecrln.soc-cd    = cecrlnana.soc-cd
                      and cecrln.etab-cd   = cecrlnana.etab-cd
                      and cecrln.jou-cd    = cecrlnana.jou-cd
                      and cecrln.prd-cd    = cecrlnana.prd-cd
                      and cecrln.prd-num   = cecrlnana.prd-num
                      and cecrln.piece-int = cecrlnana.piece-int
                      and cecrln.lig       = cecrlnana.lig no-error.
            end.
            else find first cecrln no-lock where rowid(cecrln) = to-rowid(vcRowid) no-error.
            if available cecrln then do:
                find first cecrsai no-lock
                    where cecrsai.soc-cd    = cecrln.soc-cd
                      and cecrsai.etab-cd   = cecrln.mandat-cd
                      and cecrsai.jou-cd    = cecrln.jou-cd
                      and cecrsai.prd-cd    = cecrln.mandat-prd-cd
                      and cecrsai.prd-num   = cecrln.mandat-prd-num
                      and cecrsai.piece-int = cecrln.piece-int no-error.
                assign
                    vcReferenceClient = ""
                    vcNumeroSociete   = string(cecrln.soc-cd, "99999")
                .
                if cecrln.id-fich > 0
                then for first igeddoc no-lock     /* extraction par le resid */
                    where igeddoc.id-fich = cecrln.id-fich
                      and igeddoc.statut-cd = "1": /* transfere */
                    assign
                        vlOK              = true
                        vcExtension       = (if num-entries(igeddoc.cdivers2, separ[1]) >= 4 then entry(4, igeddoc.cdivers2, separ[1]) else "")
                        vcReferenceClient = "" /* pas indispensable */
                        vcNumeroSociete   = "" /* pas indispensable */
                        vcResid           = igeddoc.resid
                    .
                end.
                else if available cecrsai and cecrsai.usrid begins "FACTURE|" and cecrln.ref-num > ""
                then for first ifdparam no-lock   /* DM 0414/0167 */
                    where ifdparam.soc-dest = cecrln.soc-cd:
                    if cecrln.jou-cd = "ODV"
                    then find first ifdsai no-lock
                        where ifdsai.soc-cd     = ifdparam.soc-cd
                          and ifdsai.etab-cd    = ifdparam.etab-cd
                          and ifdsai.soc-dest   = ifdparam.soc-dest
                          and ifdsai.etab-dest  = cecrln.etab-cd
                          and ifdsai.facnum-cab = integer(cecrln.ref-num) no-error.
                    else find first ifdsai no-lock
                        where ifdsai.soc-cd     = ifdparam.soc-cd
                          and ifdsai.etab-cd    = ifdparam.etab-cd
                          and ifdsai.soc-dest   = ifdparam.soc-dest
                          and ifdsai.etab-dest  = cecrln.etab-cd
                          and ifdsai.fac-num    = integer(cecrln.ref-num) no-error.
                    if available ifdsai
                    then for each igeddoc no-lock                    //  && pour & dans un substitute
                        where igeddoc.lbrech contains substitute("MDT_&1 && IDENTIFIANT_FACTURED@&2@&3@&4", string(cecrln.etab-cd, "99999"), string(IFdsai.soc-cd), string(IFdsai.etab-cd), string(IFdsai.com-num))
                          and igeddoc.num-soc = cecrln.soc-cd:
                        assign
                            vcResid           = igeddoc.resid
                            vlOK              = true
                            vcExtension       = if num-entries(igeddoc.cdivers2, separ[1]) >= 4 then entry(4, igeddoc.cdivers2, separ[1]) else ''
                            vcReferenceClient = "" /* pas indispensable */
                            vcNumeroSociete   = "" /* pas indispensable */
                        .
                        leave.
                    end.
                end.
                else if available cecrsai and cecrsai.usrid begins "FAC. LOC.|" and cecrln.ref-num begins "FL"
                then do:   /* DM 0414/0166 */
                    find first iftsai no-lock
                        where iftsai.soc-cd    = cecrsai.soc-cd
                          and iftsai.etab-cd   = cecrln.etab-cd
                          and iftsai.tprole    = 19
                          and iftsai.sscptg-cd = cecrln.cpt-cd
                          and iftsai.fac-num   = integer(substring(cecrln.ref-num, 3)) no-error.
                    if available iftsai
                    then for each igeddoc no-lock                    //  && pour & dans un substitute
                        where igeddoc.lbrech contains substitute("MDT_&1 && IDENTIFIANT_FACTURED@&2@&3@19&4&5", string(cecrln.etab-cd, "99999"), string(cecrsai.soc-cd), string(cecrln.etab-cd), cecrln.cpt-cd, string(IFtsai.num-int))
                          and igeddoc.num-soc = cecrln.soc-cd:
                        assign
                            vcResid           = igeddoc.resid
                            vlOK              = true
                            vcExtension       = if num-entries(igeddoc.cdivers2, separ[1]) >= 4 then entry(4, igeddoc.cdivers2, separ[1]) else ''
                            vcReferenceClient = "" /* pas indispensable */
                            vcNumeroSociete   = "" /* pas indispensable */
                        .
                        leave.
                    end.
                end.
                else if cecrln.sscoll-cle = "L" and cecrln.jou-cd = "QUIT" and cecrln.type-cle = "ODQTT" and not cecrln.ref-num begins "FL"
                then assign                                            /*** Quittancement */
                    vlOK             = true
                    vcDocType        = "" /* 1000 */
                    vcNumeroMandat   = string(cecrln.etab-cd, "99999")
                    vcNumeroCompte   = cecrln.cpt-cd
                    vcNumtrt         = "" /*Pas utilisé*/
                    vcChemise        = "QU"
                    vcNumeroImmeuble = ""
                    vcNumeroLot      = ""
                    vcLibelleTrt     = ""
                    vcAnneeMois      = string(year(cecrln.dacompta), "9999") + string(month(cecrln.dacompta), "99")
                    vcDateDebut      = ""
                    vcDateFin        = ""
                .
                else if cecrln.sscoll-cle = "P" and cecrln.jou-cd = "OD" and cecrln.type-cle = "ODRT"
                then assign                  /*** Relevés propriétaires */
                    vlODRTProprio    = can-find(first pclie no-lock where pclie.tppar = "ODTRM" and pclie.zon01 = "00001")
                    vlOK             = true
                    vcDocType        = ""
                    vcNumeroMandat   = ""
                    vcNumeroCompte   = cecrln.cpt-cd
                    vcNumtrt         = "" /*Pas utilisé*/
                    vcChemise        = "RL"
                    vcNumeroImmeuble = ""
                    vcNumeroLot      = ""
                    vcLibelleTrt     = ""
                    vdaDateCompta    = cecrln.dacompta - (if vlODRTProprio then 0 else 1)
                    vcAnneeMois      = string(year(vdaDateCompta), "9999") + string(month(vdaDateCompta), "99")
                    vcDateDebut      = ""
                    vcDateFin        = ""
                .
                else if cecrln.sscoll-cle = "M" and cecrln.jou-cd = "OD" and cecrln.type-cle = "ODRT"
                then for first vbCecrln no-lock
                    where vbCecrln.soc-cd         = cecrln.soc-cd
                      and vbCecrln.mandat-cd      = cecrln.mandat-cd
                      and vbCecrln.jou-cd         = cecrln.jou-cd
                      and vbCecrln.mandat-prd-cd  = cecrln.mandat-prd-cd
                      and vbCecrln.mandat-prd-num = cecrln.mandat-prd-num
                      and vbCecrln.piece-int      = cecrln.piece-int
                      and vbCecrln.sscoll-cle     = "P":
                       /*** Relevés du propriétaires ***/
                       /*** Le premier en passant par le "M 4110" ***/
                    assign
                        vlODRTProprio    = can-find(first pclie no-lock where pclie.tppar = "ODTRM" and pclie.zon01 = "00001")
                        vlOK             = true
                        vcDocType        = ""
                        vcNumeroMandat   = ""
                        vcNumeroCompte   = vbCecrln.cpt-cd
                        vcNumtrt         = "" /*Pas utilisé*/
                        vcChemise        = "RL"
                        vcNumeroImmeuble = ""
                        vcNumeroLot      = ""
                        vcLibelleTrt     = ""
                        vdaDateCompta    = vbCecrln.dacompta - (if vlODRTProprio then 0 else 1)
                        vcAnneeMois      = string(year(vdaDateCompta), "9999") + string(month(vdaDateCompta), "99")
                        vcDateDebut      = ""
                        vcDateFin        = ""
                    .
                end.
                /* JPM 0911/0112 */
                else if (cecrln.sscoll-cle = "C" or cecrln.sscoll-cle = "CHB") and (cecrln.jou-cd begins "AF" or cecrln.jou-cd = "CPHB")
                     and cecrln.appel-rgrp begins "AR"
                then assign      /*** Appels de fonds regroupés */
                    vlOK             = true
                    vcDocType        = ""
                    vcNumeroMandat   = string(cecrln.etab-cd, "99999")
                    vcNumeroCompte   = cecrln.cpt-cd
                    vcNumtrt         = "" /*Pas utilisé*/
                    vcChemise        = "AR"
                    vcNumeroImmeuble = ""
                    vcNumeroLot      = ""
                    vcLibelleTrt     = ""
                    vcAnneeMois      = substring(cecrln.appel-rgrp, 3, 6, 'character')
                    vcDateDebut      = ""
                    vcDateFin        = ""
                .
                else if cecrln.coll-cle = "C" and cecrln.jou-cd = "AFTA" and cecrln.type-cle = "OD" 
                     and cecrln.ref-num begins cecrln.jou-cd
                then assign     /*** Appels de fonds travaux alur */
                    vlOK             = true
                    vcDocType        = ""
                    vcNumeroMandat   = string(cecrln.etab-cd, "99999")
                    vcNumeroCompte   = cecrln.cpt-cd
                    vcNumtrt         = "" /*Pas utilisé*/
                    vcChemise        = "AY"
                    vcNumeroImmeuble = ""
                    vcNumeroLot      = ""
                    vcLibelleTrt     = ""
                    vcAnneeMois      = "99" + substring(cecrln.ref-num, 6, 4, 'character')
                    vcDateDebut      = ""
                    vcDateFin        = ""
                .
                else if cecrln.sscoll-cle = "C" and cecrln.jou-cd = "AFB" and cecrln.type-cle = "ODB" 
                     and cecrln.ref-num begins cecrln.jou-cd
                then assign   /*** Appels de fonds budgets */
                    vlOK             = true
                    vcDocType        = ""
                    vcNumeroMandat   = string(cecrln.etab-cd, "99999")
                    vcNumeroCompte   = cecrln.cpt-cd
                    vcNumtrt         = "" /*Pas utilisé*/
                    vcChemise        = "AB"
                    vcNumeroImmeuble = ""
                    vcNumeroLot      = ""
                    vcLibelleTrt     = ""
                    vcAnneeMois      = "99" + substring(cecrln.ref-num, 6, 4, 'character')
                    vcDateDebut      = ""
                    vcDateFin        = ""
                .
                else if cecrln.sscoll-cle = "C"
                   and ((cecrln.jou-cd = "CP" and cecrln.type-cle = "ODCP2") or (cecrln.jou-cd = "AFBA" and cecrln.type-cle = "ODBA"))
                   and cecrln.ref-num begins cecrln.jou-cd
                then assign      /*** Charges de copropriété */
                    vlOK             = true
                    vcDocType        = ""
                    vcNumeroMandat   = string(cecrln.etab-cd, "99999")
                    vcNumeroCompte   = cecrln.cpt-cd
                    vcNumtrt         = "" /*Pas utilisé*/
                    vcChemise        = "CO"
                    vcNumeroImmeuble = ""
                    vcNumeroLot      = ""
                    vcLibelleTrt     = ""
                    vcAnneeMois      = "99" + substring(cecrln.ref-num, 6, 4, 'character')
                    vcDateDebut      = ""
                    vcDateFin        = ""
                .
                else if cecrln.sscoll-cle = "C" and cecrln.jou-cd = "AFC" and cecrln.type-cle = "ODB"
                     and cecrln.ref-num begins "AFHB"
                then assign      /*** Appels de fonds consommation */
                    vlOK             = true
                    vcDocType        = ""
                    vcNumeroMandat   = string(cecrln.etab-cd, "99999")
                    vcNumeroCompte   = cecrln.cpt-cd
                    vcNumtrt         = "" /*Pas utilisé*/
                    vcChemise        = "AH"
                    vcNumeroImmeuble = ""
                    vcNumeroLot      = ""
                    vcLibelleTrt     = ""
                    vcAnneeMois      = "99" + substring(cecrln.ref-num, 6, 4, 'character')
                    vcDateDebut      = "" 
                    vcDateFin        = "" 
                .
                else if cecrln.sscoll-cle = "C" and cecrln.jou-cd = "AFHB" and cecrln.type-cle = "ODHB" 
                     and cecrln.ref-num begins cecrln.jou-cd
                then assign    /*** Appels de fonds hors budgets */
                    vlOK             = true
                    vcDocType        = ""
                    vcNumeroMandat   = string(cecrln.etab-cd, "99999")
                    vcNumeroCompte   = cecrln.cpt-cd
                    vcNumtrt         = "" /*Pas utilisé*/
                    vcChemise        = "AH"
                    vcNumeroImmeuble = ""
                    vcNumeroLot      = ""
                    vcLibelleTrt     = ""
                    vcAnneeMois      = "99" + substring(cecrln.ref-num, 6, 4, 'character')
                    vcDateDebut      = ""
                    vcDateFin        = ""
                .
                else if cecrln.sscoll-cle = "CHB" and cecrln.jou-cd = "AFTX" and cecrln.type-cle = "ODTX" 
                     and cecrln.ref-num begins cecrln.jou-cd
                then assign     /*** Appels de fonds travaux */
                    vlOK             = true
                    vcDocType        = ""
                    vcNumeroMandat   = string(cecrln.etab-cd, "99999")
                    vcNumeroCompte   = cecrln.cpt-cd
                    vcNumtrt         = "" /*Pas utilisé*/
                    vcChemise        = "AX"
                    vcNumeroImmeuble = ""
                    vcNumeroLot      = ""
                    vcLibelleTrt     = ""
                    vcAnneeMois      = "99" + substring(cecrln.ref-num, 6, 4, 'character')
                    vcDateDebut      = "" 
                    vcDateFin        = "" 
                .
                else if cecrln.sscoll-cle = "C" and cecrln.jou-cd = "AFRL" and cecrln.type-cle = "ODRL" 
                     and cecrln.ref-num begins cecrln.jou-cd
                then assign     /*** Appels de fonds de roulement */
                    vlOK             = true
                    vcDocType        = ""
                    vcNumeroMandat   = string(cecrln.etab-cd, "99999")
                    vcNumeroCompte   = cecrln.cpt-cd
                    vcNumtrt         = "" /*Pas utilisé*/
                    vcChemise        = "AL"
                    vcNumeroImmeuble = ""
                    vcNumeroLot      = ""
                    vcLibelleTrt     = ""
                    vcAnneeMois      = "99" + substring(cecrln.ref-num, 6, 4, 'character')
                    vcDateDebut      = ""
                    vcDateFin        = ""
                .
                else if cecrln.sscoll-cle = "C" and cecrln.jou-cd = "AFRS" and cecrln.type-cle = "ODRS" 
                     and cecrln.ref-num begins cecrln.jou-cd
                then assign   /*** Appels de fonds de réserve */
                    vlOK             = true
                    vcDocType        = ""
                    vcNumeroMandat   = string(cecrln.etab-cd, "99999")
                    vcNumeroCompte   = cecrln.cpt-cd
                    vcNumtrt         = "" /*Pas utilisé*/
                    vcChemise        = "AS"
                    vcNumeroImmeuble = ""
                    vcNumeroLot      = ""
                    vcLibelleTrt     = ""
                    vcAnneeMois      = "99" + substring(cecrln.ref-num, 6, 4, 'character')
                    vcDateDebut      = "" 
                    vcDateFin        = "" 
                .
                else if cecrln.sscoll-cle = "C" and cecrln.jou-cd = "AFTR" and cecrln.type-cle = "ODTR" 
                     and cecrln.ref-num begins cecrln.jou-cd
                then assign    /*** Appels de fonds travaux */
                    vlOK             = true
                    vcDocType        = ""
                    vcNumeroMandat   = string(cecrln.etab-cd,"99999")
                    vcNumeroCompte   = cecrln.cpt-cd
                    vcNumtrt         = "" /*Pas utilisé*/
                    vcChemise        = "AT"
                    vcNumeroImmeuble = ""
                    vcNumeroLot      = ""
                    vcLibelleTrt     = ""
                    vcAnneeMois      = "99" + substring(cecrln.ref-num, 6, 4, 'character')
                    vcDateDebut      = ""
                    vcDateFin        = ""
                .
                else if cecrln.sscoll-cle = "CHB" and cecrln.jou-cd = "CPHB" and cecrln.type-cle = "ODCP2" 
                     and cecrln.ref-num begins cecrln.jou-cd
                then assign   /*** Appels de fonds cloture travaux */
                    vlOK             = true
                    vcDocType        = ""
                    vcNumeroMandat   = string(cecrln.etab-cd, "99999")
                    vcNumeroCompte   = cecrln.cpt-cd
                    vcNumtrt         = "" /*Pas utilisé*/
                    vcChemise        = "AC"
                    vcNumeroImmeuble = ""
                    vcNumeroLot      = ""
                    vcLibelleTrt     = ""
                    vcAnneeMois      = "99" + substring(cecrln.ref-num, 6, 4, 'character')
                    vcDateDebut      = ""
                    vcDateFin        = ""
                .
                else if cecrln.sscoll-cle = "EI" and cecrln.jou-cd = "SAL" and cecrln.ref-num begins cecrln.jou-cd 
                then assign     /*** Bulletin de salaire */
                    vlOK             = true
                    vcDocType        = "4010" /* validation uniquement */
                    vcNumeroMandat   = string(cecrln.etab-cd, "99999")
                    vcNumeroCompte   = string(cecrln.etab-cd, "9999") + substring(cecrln.cpt-cd, 4, 2, 'character')
                    vcNumtrt         = "" /*Pas utilisé*/
                    vcChemise        = "PA"
                    vcNumeroImmeuble = ""
                    vcNumeroLot      = ""
                    vcLibelleTrt     = ""
                    vcAnneeMois      = "20" + substring(cecrln.lib, 12, 2, 'character') + substring(cecrln.lib, 9, 2, 'character')
                    vcDateDebut      = ""
                    vcDateFin        = ""
                .
                else if cecrln.sscoll-cle = "EI" and cecrln.jou-cd = "ODSAL" and cecrln.ref-num begins cecrln.jou-cd 
                then assign    /*** Bulletin de salaire Pegase*/
                    vlOK             = true
                    vcDocType        = "4010" /* validation uniquement */
                    vcNumeroMandat   = string(cecrln.etab-cd, "99999")
                    vcNumeroCompte   = string(cecrln.cpt-cd, "99999")
                    vcNumtrt         = "" /*Pas utilisé*/
                    vcChemise        = "PZ"
                    vcNumeroImmeuble = ""
                    vcNumeroLot      = ""
                    vcLibelleTrt     = ""
                    vcAnneeMois      = "20" + substring(cecrln.lib, 12, 2, 'character') + substring(cecrln.lib, 9, 2, 'character') 
                    vcDateDebut      = ""
                    vcDateFin        = ""
                .
                else if lookup(cecrln.sscoll-cle, "F,FHB,P,PF,C,CHB") > 0 and (cecrln.type-cle = "CHQA" or cecrln.type-cle = "VTA")
                then assign  /*** lettre-cheque + virement, La recherche se fait du mandat de la banque/journal/ Numéro de chq ou vir */
                    vlOK             = true
                    vcDocType        = ""
                    vcNumeroMandat   = string(cecrln.mandat-cd, "99999") 
                    vcNumeroCompte   = ""
                    vcNumtrt         = "" /*Pas utilisé*/
                    vcChemise        = (if cecrln.type-cle = "CHQA" then "CH" else "VT")
                    vcNumeroImmeuble = ""
                    vcNumeroLot      = ""
                    /* Injection SQL pour rajouter le matches sur fin de chaine uniquement, car le webservice fait un matches début/fin de chaine sur title (libtrt) */
                    vcLibelleTrt     = substitute("' AND title ilike '&1 &2 DU %' AND title ilike '", cecrln.jou-cd, if vcChemise = "CH" then "CHEQUE" else "VIREMENT")
                    /* Injection SQL pour rajouter le critère "=", car le webservice fait un matches sur début et fin de chaine sur custom_t16 */                    
                    vcAnneeMois      = substitute("' AND doc_custom_t16 = '&1' AND doc_custom_t16 ilike '", (if num-entries(cecrln.lib-ecr[1], " ") >= 2 then entry(2, cecrln.lib-ecr[1], " ") else " "))  /* Numéro du cheque ou du virement */ 
                    vcDateDebut      = ""
                    vcDateFin        = ""
                .
                else if cecrln.sscoll-cle = "" and cecrln.cpt-cd begins "5" and lookup(cecrln.type-cle, "CP,CH,CE,ESP") > 0 and available ijou
                then do:
                    /*** Bordereau remise ***/
                    if ijou.bqjou-cd > ""
                    then do:
                        find first vbIjou no-lock
                            where vbIjou.soc-cd  = ijou.soc-cd
                              and vbIjou.etab-cd = ijou.etab-cd
                              and vbIjou.jou-cd  = ijou.bqjou-cd no-error.
                        find first ibque no-lock 
                            where ibque.soc-cd  = vbIjou.soc-cd 
                              and ibque.etab-cd = vbIjou.etab-cd
                              and ibque.cpt-cd  = vbIjou.cpt-cd no-error.
                    end.
                    else find first ibque no-lock
                         where ibque.soc-cd  = ijou.soc-cd 
                           and ibque.etab-cd = ijou.etab-cd
                           and ibque.cpt-cd  = ijou.cpt-cd no-error.
                    if available ibque
                    then for first ichrono no-lock
                        where ichrono.soc-cd  = ibque.soc-cd
                          and ichrono.etab-cd = ibque.etab-cd
                          and ichrono.bque    = ibque.bque
                          and ichrono.guichet = ibque.guichet
                          and ichrono.cpt     = ibque.cpt
                          and ichrono.rib     = ibque.rib
                          and ichrono.fg-A4:
                        /* La recherche se fait du mandat de la banque/journal/ Numéro de bordereau */
                        assign
                            vlOK             = true
                            vcDocType        = "7550"
                            vcNumeroMandat   = string(cecrln.mandat-cd, "99999") 
                            vcNumeroCompte   = "" 
                            vcNumtrt         = "" /*Pas utilisé*/
                            vcChemise        = ""
                            vcNumeroImmeuble = ""
                            vcNumeroLot      = ""
                            /* Injection SQL pour rajouter le matches sur fin de chaine uniquement, car le webservice fait un matches début/fin de chaine sur title (libtrt) */
                            vcLibelleTrt     = substitute("' AND title ilike '&1%' AND title ilike '", if trim(ijou.bqjou-cd) > "" then ijou.bqjou-cd else cecrln.jou-cd)
                            vcAnneeMois      = string(integer(replace(cecrln.ref-num, "#", "")), "9999999")
                            vcDateDebut      = ""
                            vcDateFin        = ""
                        no-error.
                    end.
                end.
                else do:
                    /* Cas ou plusieurs documents sur une seule et même écriture (ORONE) */
                    assign
                        vcResid     = ""
                        vcExtension = ""
                    .
                    for each igeddoc no-lock                    // && doublé dans un substitute
                        where igeddoc.lbrech contains substitute("MDT_&1 && IDENTIFIANT_CECRLN@&2@&3@&4@&5@&6@&7"
                                                                , string(cecrln.etab-cd, "99999")
                                                                , string(cecrln.soc-cd)
                                                                , replace(cecrln.jou-cd, " ", separ[1])
                                                                , string(cecrln.prd-cd)
                                                                , string(cecrln.prd-num)
                                                                , string(cecrln.piece-int)
                                                                , string(cecrln.lig))
                          and igeddoc.num-soc = cecrln.soc-cd:
                        assign
                            vcResid     = vcResid + "," + igeddoc.resid
                            vlOK        = true
                            vcExtension = vcExtension + "," + (if num-entries(igeddoc.cdivers2, separ[1]) >= 4 then entry(4, igeddoc.cdivers2, separ[1]) else '')
                        .
                    end.
                    assign
                        vcResid           = trim(vcResid, ',')
                        vcExtension       = trim(vcExtension, ',')
                        vcReferenceClient = "" /* pas indispensable */
                        vcNumeroSociete   = "" /* pas indispensable */
                    .
                end.
            end. /* available cecrln */
        end.
        when "CRIT" then do:
            vcLstParam = entry(3, pcParametre) no-error.
            viSepar1   = num-entries(vcLstParam, "|") no-error.     // Attention, ne pas merger avec l'assign dessous, utilisation de WHEN
            assign
                vlOK             = true
                vcDocType        = entry(1,  vcLstParam, "|") when viSepar1 >= 1
                vcNumeroMandat   = entry(2,  vcLstParam, "|") when viSepar1 >= 2
                vcNumeroCompte   = entry(3,  vcLstParam, "|") when viSepar1 >= 3
                vcNumtrt         = entry(4,  vcLstParam, "|") when viSepar1 >= 4
                vcChemise        = entry(5,  vcLstParam, "|") when viSepar1 >= 5
                vcNumeroImmeuble = entry(6,  vcLstParam, "|") when viSepar1 >= 6
                vcNumeroLot      = entry(7,  vcLstParam, "|") when viSepar1 >= 7
                vcLibelleTrt     = entry(8,  vcLstParam, "|") when viSepar1 >= 8
                vcAnneeMois      = entry(9,  vcLstParam, "|") when viSepar1 >= 9
                vcNumeroSociete  = entry(10, vcLstParam, "|") when viSepar1 >= 10
                vcDateDebut      = entry(11, vcLstParam, "|") when viSepar1 >= 11
                vcDateFin        = entry(12, vcLstParam, "|") when viSepar1 >= 12
            .
        end. /* lst */
        when "resid" then assign
            vcLstParam        = entry(3, pcParametre) when num-entries(pcParametre) >= 3
            vlOK              = true
            vcResid           = entry(1, vcLstParam, "|")
            vcReferenceClient = "" /* pas indispensable */
            vcNumeroSociete   = "" /* pas indispensable */
        .
        when "igeddoc" then if num-entries(pcParametre) >= 3
        then for first igeddoc no-lock
            where igeddoc.id-fich = integer(entry(3, pcParametre)):
            assign
                vlOK              = true
                vcExtension       = if num-entries(igeddoc.cdivers2, separ[1]) >= 4 then entry(4, igeddoc.cdivers2, separ[1]) else ""
                vcResid           = igeddoc.resid
                vcReferenceClient = "" /* pas indispensable */
                vcNumeroSociete   = "" /* pas indispensable */
            .
        end.
    end case.

    if vlOK
    then pcResultat = vcExtension       + separ[1]
                    + vcResid           + separ[1]
                    + vcReferenceClient + separ[1]
                    + vcNumeroSociete   + separ[1]
                    + vcDocType         + separ[1]
                    + vcNumeroMandat    + separ[1]
                    + vcNumeroCompte    + separ[1]
                    + vcNumtrt          + separ[1]
                    + vcChemise         + separ[1]
                    + vcNumeroImmeuble  + separ[1]
                    + vcNumeroLot       + separ[1]
                    + vcLibelleTrt      + separ[1]
                    + vcAnneeMois       + separ[1]
                    + vcDateDebut       + separ[1]
                    + vcDateFin         + separ[1].
    else pcResultat = ?.

end procedure.

procedure maarch_query private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:  
    ------------------------------------------------------------------------------*/
    define input parameter phServer    as handle    no-undo.
    define input parameter pcParametre as character no-undo.
  
    define variable vhAddrPortType     as handle    no-undo.
    define variable vcResid            as character no-undo.
    define variable vcReferenceClient  as character no-undo.
    define variable vcNumeroSociete    as character no-undo.
    define variable vcDocType          as character no-undo.
    define variable vcNumeroMandat     as character no-undo.
    define variable vcNumeroCompte     as character no-undo.
    define variable vcNumtrt           as character no-undo.
    define variable vcChemise          as character no-undo.
    define variable vcNumeroImmeuble   as character no-undo.
    define variable vcNumeroLot        as character no-undo.
    define variable vcLibelleTrt       as character no-undo.
    define variable vcAnneeMois        as character no-undo.
    define variable vcDateDebut        as character no-undo.
    define variable vcDateFin          as character no-undo.
    define variable vcExtension        as character no-undo.
    define variable vcExtensionEnCours as character no-undo.
    define variable vcParamWS          as character no-undo.
    define variable vcXMLWS-Maarch     as longchar  no-undo.
    define variable vlErreur           as logical   no-undo.
    define variable viBoucle           as integer   no-undo.

    /* Critères de sélection */
    assign
        vcExtension       = entry(1, pcParametre, separ[1])
        vcResid           = entry(2, pcParametre, separ[1])
        vcReferenceClient = entry(3, pcParametre, separ[1])
        vcNumeroSociete   = entry(4, pcParametre, separ[1])
        vcDocType         = replace(entry(5, pcParametre, separ[1]), ":", ",")             /* Possibilité liste de type doc */
        vcNumeroMandat    = entry(6, pcParametre, separ[1])
        vcNumeroCompte    = entry(7, pcParametre, separ[1])
        vcNumtrt          = entry(8, pcParametre, separ[1])
        vcChemise         = entry(9, pcParametre, separ[1])
        vcNumeroImmeuble  = entry(10, pcParametre, separ[1])
        vcNumeroLot       = entry(11, pcParametre, separ[1])
        vcLibelleTrt      = entry(12, pcParametre, separ[1])
        vcAnneeMois       = entry(13, pcParametre, separ[1])
        vcDateDebut       = entry(14, pcParametre, separ[1])
        vcDateFin         = entry(15, pcParametre, separ[1])
    no-error.

    if trim(vcResid) > ""
    then do viBoucle = 1 to num-entries(vcResid):
        {&_proparse_ prolint-nowarn(substitute)}
        vcParamWS = '<magi:searchParams xmlns:magi="https://tempuri.org/">'
                  + substitute('<&1>&2</&1>', 'magi:resid',     trim(entry(viBoucle, vcResid)))
                  + substitute('<&1>&2</&1>', 'magi:refcli',    if vcReferenceClient > "" then "R" + trim(vcReferenceClient) else "")
                  + substitute('<&1>&2</&1>', 'magi:numsoc',    trim(vcNumeroSociete))
                  + substitute('<&1>&2</&1>', 'magi:doctype',   trim(vcDocType))
                  + substitute('<&1>&2</&1>', 'magi:nummdt',    trim(vcNumeroMandat))
                  + substitute('<&1>&2</&1>', 'magi:numcpt',    trim(vcNumeroCompte))
                  + substitute('<&1>&2</&1>', 'magi:numtrt',    trim(vcNumtrt))
                  + substitute('<&1>&2</&1>', 'magi:chemise',   trim(vcChemise))
                  + substitute('<&1>&2</&1>', 'magi:numimm',    trim(vcNumeroImmeuble))
                  + substitute('<&1>&2</&1>', 'magi:numlot',    trim(vcNumeroLot))
                  + substitute('<&1>&2</&1>', 'magi:libtrt',    trim(vcLibelleTrt))
                  + substitute('<&1>&2</&1>', 'magi:anneemois', trim(vcAnneeMois))
                  + substitute('<&1>&2</&1>', 'magi:dadeb',     trim(vcDateDebut))
                  + substitute('<&1>&2</&1>', 'magi:dafin',     trim(vcDateFin))
                  + '</magi:searchParams>'.
        run MySoapServerPort set vhAddrPortType on server phServer. /* récupère le handle du port MySoapServerPort */
        vcExtensionEnCours = (if num-entries(vcExtension) >= viBoucle then entry(viBoucle, vcExtension) else ""). /* Execution du WS */
        run custom_searchResources in vhAddrPortType (vcExtensionEnCours <> "" , vcParamWS, output vcXMLWS-Maarch) no-error. /* Lancement de l'operation (ws) */
        run ErrorInfo (mToken:cUser, output vlErreur).

        if not vlErreur
        then run maarch_result(vcExtensionEnCours, vcXMLWS-Maarch).   /* extraction des données du xml de retour (vcXMLWS-Maarch) */
    end.
    else do:
        {&_proparse_ prolint-nowarn(substitute)}
        vcParamWS = '<magi:searchParams xmlns:magi="https://tempuri.org/">'
                  + substitute('<&1>&2</&1>', 'magi:resid',     trim(vcResid))
                  + substitute('<&1>&2</&1>', 'magi:refcli',    if vcReferenceClient > "" then "R" + trim(vcReferenceClient) else "")
                  + substitute('<&1>&2</&1>', 'magi:numsoc',    trim(vcNumeroSociete))
                  + substitute('<&1>&2</&1>', 'magi:doctype',   trim(vcDocType))
                  + substitute('<&1>&2</&1>', 'magi:nummdt',    trim(vcNumeroMandat))
                  + substitute('<&1>&2</&1>', 'magi:numcpt',    trim(vcNumeroCompte))
                  + substitute('<&1>&2</&1>', 'magi:numtrt',    trim(vcNumtrt))
                  + substitute('<&1>&2</&1>', 'magi:chemise',   trim(vcChemise))
                  + substitute('<&1>&2</&1>', 'magi:numimm',    trim(vcNumeroImmeuble))
                  + substitute('<&1>&2</&1>', 'magi:numlot',    trim(vcNumeroLot))
                  + substitute('<&1>&2</&1>', 'magi:libtrt',    trim(vcLibelleTrt))
                  + substitute('<&1>&2</&1>', 'magi:anneeMois', trim(vcAnneeMois))
                  + substitute('<&1>&2</&1>', 'magi:dadeb',     trim(vcDateDebut))
                  + substitute('<&1>&2</&1>', 'magi:daFin',     trim(vcDateFin))
                  + '</magi:searchParams>'.
        /* récupère le handle du port MySoapServerPort */
        run MySoapServerPort set vhAddrPortType on server phServer.
        /* Execution du WS */
        run custom_searchResources in vhAddrPortType (vcExtension <> "", vcParamWS, output vcXMLWS-Maarch) no-error. /* Lancement de l'operation (ws) */
        run errorInfo (mToken:cUser, output vlErreur).
        if not vlErreur then run maarch_result(vcExtension, vcXMLWS-Maarch). /* extraction des données du xml de retour (vcXMLWS-Maarch) */
    end.
    return.
end procedure.

procedure ErrorInfo private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter pcUserId as character no-undo.
    define output parameter plError  as logical   no-undo.

    define variable viI               as integer   no-undo.
    define variable vhSOAPFault       as handle    no-undo.
    define variable vhSOAPFaultDetail as handle    no-undo.
    define variable vcHeaderXML       as character no-undo.
    define variable vcErreur          as character no-undo.
    
    if error-status:num-messages = 0 then return.

    plError = true.
    do viI = 1 to error-status:num-messages:
        vcErreur = error-status:get-message(viI).
        if vcErreur matches "* 413 *"
        then vcErreur = outilTraduction:getLibelle(1000082). /* Traitement abandonné dû à une requête trop importante (413) */
        mError:createErrorComplement({&error}, vcErreur, pcUserId).
    end.
    if valid-handle(error-status:error-object-detail)
    then do:
        assign
            vhSOAPFault = error-status:error-object-detail
            vcErreur    = substitute("Fault Code: &2&1Fault String: &3&1Fault Actor: &4&1Error Type: &5"
                                   , chr(13), vhSOAPFault:soap-fault-code, vhSOAPFault:soap-fault-string, vhSOAPFault:soap-fault-actor, vhSOAPFault:type)
        .
        if valid-handle(vhSOAPFault:soap-fault-detail)
        then assign
            vhSOAPFaultDetail = vhSOAPFault:soap-fault-detail
            vcErreur          = "Error Type: " + vhSOAPFaultDetail:type
            vcHeaderXML       = vhSOAPFaultDetail:get-serialized()
            vcErreur          = "Serialized SOAP fault detail:" + vcHeaderXML
        .
        mError:createErrorComplement({&error}, vcErreur, pcUserId).
    end.
end procedure.

procedure maarch_result private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter pcFileContent as character no-undo.
    define input parameter pcXML         as longchar  no-undo.
  
    define variable viI         as integer  no-undo.
    define variable viJ         as integer  no-undo.
    define variable viK         as integer  no-undo.
    define variable vcChamps    as longchar no-undo.
    define variable vcSortie    as longchar no-undo.
    define variable vcLongValue as longchar no-undo.
    define variable vcEnreg     as longchar no-undo.
    define variable vhNoderef   as handle   no-undo.
    define variable vhiTem      as handle   no-undo.
    define variable vhDoc       as handle   no-undo.
    define variable vhRoot      as handle   no-undo.

    /*Chargement du XML de retour vcXMLWS-Maarch*/
    create x-document vhDoc.
    create x-noderef vhRoot.
    vhDoc:load("LONGCHAR", pcXML, false).
    vhDoc:get-document-element(vhRoot).

    /* test du status */
    vcSortie = ?.
    run value-champs(vhRoot, 1, "return", "status", output vcSortie).
    if vcSortie <> "ok"
    then do:
        vcSortie = ?.
        run value-champs(vhRoot, 1, "return", "error", output vcSortie).
        mError:createError({&error}, string(vcSortie)).
        delete object vhDoc.
        delete object vhRoot.
        return.
    end.

    /* Liste de documents */
    create x-noderef vhNoderef.
    create x-noderef vhiTem.
    if valid-handle(vhRoot)
    then repeat viI = 1 to vhRoot:num-children:
        if vhRoot:get-child(vhNoderef, viI) and vhNoderef:name = "value" and vhNoderef:type = "x-noderef"
        then repeat viJ = 1 to vhNoderef:num-children:
            if vhNoderef:get-child(vhiTem, viJ) and vhiTem:name = "item" and vhiTem:type = "x-noderef" and vhiTem:subtype = "element"
            then do:
                vcEnreg = "".
                run liste-enreg(vhiTem, input-output vcEnreg).
                if vcEnreg = "" then next.

                create ttDocumentGidemat.
boucleChamp:
                repeat viK = 1 to num-entries(vcEnreg, chr(9)):          /* pour chaque champs */
                    vcChamps = entry(viK, vcEnreg, chr(9)).
                    if num-entries(vcChamps, separ[1]) < 2 then next boucleChamp.

                    vcLongValue = entry(2, vcChamps, separ[1]).
                    case string(entry(1, vcChamps, separ[1])):
                        when "resid"        then ttDocumentGidemat.iIdentifiantGidemat = int64(vcLongValue).
                        when "libcpt"       then ttDocumentGidemat.cLibellecompte    = vcLongValue.
                        when "docdate"      then ttDocumentGidemat.cDateDocument     = vcLongValue.
                        when "nummdt"       then ttDocumentGidemat.cNumeroMandat     = vcLongValue.
                        when "numcpt"       then ttDocumentGidemat.cNumeroCompte     = vcLongValue.
                        when "destinataire" then ttDocumentGidemat.cDestinataire     = vcLongValue.
                        when "numimm"       then ttDocumentGidemat.cNumeroImmeuble   = vcLongValue.
                        when "doctype"      then ttDocumentGidemat.cTypeDocument     = vcLongValue.
                        when "numtrt"       then ttDocumentGidemat.cNumeroTraitement = vcLongValue.
                        when "file_content" then if pcFileContent > ""                             /* contenu du fichier demandé */ 
                                            then copy-lob from vcLongValue to object ttDocumentGidemat.cContenuFichier no-error.
                                            else ttDocumentGidemat.cContenuFichier = "".
                        when "mime_type"    then ttDocumentGidemat.cTypeMime          = vcLongValue.
                        when "ext"          then ttDocumentGidemat.cExtension         = vcLongValue.
                        when "libtrt"       then ttDocumentGidemat.cLibelleTraitement = vcLongValue.
                    end case.
                end. /* repeat */
            end.
        end.
    end.
    delete object vhDoc     no-error.
    delete object vhRoot    no-error.
    delete object vhNoderef no-error.
    delete object vhiTem    no-error.
    return.
end procedure.

procedure liste-enreg private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input        parameter phParent as handle   no-undo.
    define input-output parameter pcEnreg  as longchar no-undo.

    define variable vhNoderef as handle   no-undo.
    define variable viCpt     as integer  no-undo.
    define variable vcValeur  as longchar no-undo.
 
    create x-noderef vhNoderef.
boucle:
    repeat viCpt = 1 to phParent:num-children:
        if not phParent:get-child(vhNoderef, viCpt) then next boucle.

        if vhNoderef:subtype = "ELEMENT"
        then do:
            run value-champs(vhNoderef, 1, vhNoderef:name, "#text", output vcValeur).
            if vcValeur <> ?
            then pcEnreg = pcEnreg + vhNoderef:name + separ[1] + vcValeur + chr(9). /* Champs + valeur */
        end.
        run liste-enreg(vhNoderef, input-output pcEnreg).
    end.
    if valid-handle(vhNoderef) then delete object vhNoderef no-error.
 
end procedure.

procedure value-champs private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input  parameter phParent as handle    no-undo.
    define input  parameter piLevel  as integer   no-undo.
    define input  parameter pcNoeud  as character no-undo.
    define input  parameter pcChamp  as character no-undo.
    define output parameter pcSortie as longchar  no-undo initial ?.

    define variable vhNoderef as handle  no-undo.
    define variable viCpt     as integer no-undo.
 
    create x-noderef vhNoderef.
boucle:
    repeat viCpt = 1 to phParent:num-children:
        if not phParent:get-child(vhNoderef, viCpt) then leave boucle.
        if vhNoderef:name = pcChamp and phParent:name = pcNoeud and vhNoderef:subtype = "ELEMENT"
        then do:     /* recherche de la valeur dans le sous-noeud #text */
            run value-champs(vhNoderef, piLevel + 1, vhNoderef:name, "#text", output pcSortie).
            leave boucle.
        end.
        else if vhNoderef:name = pcChamp and phParent:name = pcNoeud and vhNoderef:subtype = "TEXT"
        then do:     /* extraction de la valeur du noeud */
            vhNoderef:node-value-to-longchar(pcSortie).
            leave boucle.
        end.
        else run value-champs(vhNoderef, piLevel + 1, pcNoeud, pcChamp, output pcSortie).

        if pcSortie <> ? then leave boucle.
    end.
    if valid-handle(vhNoderef) then delete object vhNoderef no-error.
    return.

end procedure.

procedure gidemat_extract_liste:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service appelé par des .p
    ------------------------------------------------------------------------------*/
    define input  parameter pcParam-In as character no-undo.
    define output parameter table for ttDocumentGidemat.
    run gidemat_extract_doc(pcParam-In).
end procedure.

procedure gidemat_mod_idx:
    /*------------------------------------------------------------------------------
    Purpose: todo: passer une collection plutôt qu'une chaine separ[1], separ[2]
    Notes  : service appelé par versement.p
    ------------------------------------------------------------------------------*/
    define input  parameter piReference   as integer   no-undo.
    define input  parameter pcResid       as character no-undo.
    define input  parameter pcListeChamps as character no-undo.

    define variable vcLongChar     as longchar  no-undo.
    define variable viTmp          as integer   no-undo.
    define variable vcTmp          as character no-undo.
    define variable vhServer       as handle    no-undo.
    define variable vhAddrPortType as handle    no-undo.
    define variable vcXMLWS-Out    as longchar  no-undo.
    define variable vlErreur       as logical   no-undo.
    define variable vhSaxReader    as handle    no-undo.

    define buffer iparm for iparm.

    empty temp-table ttmodindex.
    do viTmp = 1 to num-entries(pcListeChamps,separ[1]):
        vcTmp = entry(viTmp,pcListeChamps,separ[1]).
        create ttmodindex.
        assign
            ttmodindex.cKey   = entry(1, vcTmp, separ[2])
            ttmodindex.cValue = entry(2, vcTmp, separ[2])
            ttmodindex.ctype  = "string"
        .
        case ttmodindex.cKey:
            when "dadoc" then assign
                ttmodindex.cKey  = "doc_date"
                ttmodindex.ctype = "date"
            .
            when "nbpag" then assign
                ttmodindex.cKey  = "page_count"
                ttmodindex.ctype = "date"
            .
            when "cdoctype" then assign
                ttmodindex.cKey  = "type_id"
                ttmodindex.ctype = "int"
            .
            when "ctypdos" then ttmodindex.cKey  = "custom_t10".
            when "nomdt"   then assign
                ttmodindex.cKey  = "custom_t13"
                ttmodindex.cVALUE = string(integer(ttmodindex.cVALUE), "99999")
            .
            when "cnumcpt"    then ttmodindex.cKey  = "custom_t1".
            when "ctypetrait" then ttmodindex.cKey  = "custom_t3".
            when "canneemois" then ttmodindex.cKey  = "custom_t16".
            when "clibtrt"    then ttmodindex.cKey  = "title".
            when "clibcpt"    then ttmodindex.cKey  = "subject".
            when "cdestinat"  then ttmodindex.cKey  = "custom_t7".
            when "id-fich"    then assign
                ttmodindex.cKey   = "identifier"
                ttmodindex.cvalue = ttmodindex.cvalue + "/" + string(piReference, "99999")
            .
            otherwise do:
                delete ttmodindex.
                mError:createError({&error}, substitute(outilTraduction:getLibelle(1000220), pcResid, ttmodindex.cKey)). /* Resid &1 Champs &2 non modifiable dans gidemat */
                return.
            end.
        end case.
    end. /* viTmp */
    
    /** Détermination du custom        **/
    /* Utilisateur paramétré par défaut */
    find first iparm no-lock
        where iparm.tppar = "GIDEMAT_ACCES" no-error.
    if not available iparm
    or iparm.lib = ?
    or num-entries(iparm.lib, separ[1]) < 2
    or entry(1, iparm.lib, separ[1]) + entry(2, iparm.lib, separ[1]) = ""
    then do:
        mError:createError({&error}, 1000217). /* L'identifiant-mot de passe de Gidemat n'est pas paramétré */
        return.
    end.

    vcTmp = trim(f_gidemat_custom(entry(1, iparm.lib, separ[1]), entry(2, iparm.lib, separ[1]))). /* recherche du custom */
    if vcTmp > "" then assign
        gcGidematUser     = entry(1, iparm.lib, separ[1])
        gcGidematPassword = entry(2, iparm.lib, separ[1])
        gcGidematCustom   = vcTmp
    .
    else do:
        mError:createError({&error}, 1000218, entry(1,iparm.lib,separ[1])). /* "Connection à gidemat impossible avec l'utilisateur &1 */
        return.
    end.

    /* Connection au WS Maarch */
    run maarch_connect(output vhServer).
    if valid-handle(vhServer) then do:
        run mySoapServerPort set vhAddrPortType on server vhServer.                             /* récupère le handle du port MySoapServerPort */
        temp-table ttmodindex:write-xml("longchar", vcLongChar, true).
        copy-lob from vcLongChar to file session:temp-directory + "/updateressource_in.xml".   /* debug : sauvegarde du xml en entree (derniere sauvegarde uniquement) */
        run updateResource in vhAddrPortType(pcResid , vcLongChar, "res_x", output vcXMLWS-Out) no-error.
        copy-lob from vcXMLWS-Out to file session:temp-directory + "/updateressource_out.xml". /* debug sauvegarde du xml en retour (derniere sauvegarde uniquement) */
        run ErrorInfo (mToken:cUser, output vlErreur).                                                       /* Existence d'anomalies ? */
        if not vlErreur
        then do:
            create sax-reader vhSaxReader.
            vhSaxReader:handler = this-procedure.
            vhSaxReader:set-input-source("longchar", vcXMLWS-Out).
            vhSaxReader:sax-parse(). /* maj de gcTmpLong */
            delete object vhSaxReader.
            if gcTmpLong > "" 
            then do viTmp = 1 to num-entries(gcTmpLong, separ[1]):
                mError:createError({&error}, 1000219, string(entry(viTmp, gcTmpLong, separ[1]))). /* Erreur WS updateResource : &1 */
            end.
        end.
        vhServer:disconnect() no-error.
        delete object vhServer no-error.
    end.

end procedure.

procedure characters:
    /*------------------------------------------------------------------------------
    Purpose: callback XML
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter pcData as longchar no-undo.
    define input parameter piData as integer  no-undo.

    if trim(pcData) = "" then return. /* discard whitespace used to format the XML */

    /* assign to the correct field, depending on node identifier - identifiers are created in StartElement callback */
    case gcActiveNode:
        /* Assign values from other nodes to the correct fields. 
        Note that currency field is populated in StartElement callback as it needs to be pulled from an attribute */
        when "error" then gcTmpLong = gcTmpLong + separ[1] + pcData.
    end case.
    gcTmpLong = trim(gcTmpLong, separ[1]).

end procedure.

procedure StartElement:
    /*------------------------------------------------------------------------------
    Purpose: callback XML
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter pcNamespaceURI as character no-undo.
    define input parameter pcLocalName    as character no-undo.
    define input parameter pcQName        as character no-undo.
    define input parameter phAttributes   as handle    no-undo.

    gcActiveNode = pcQName.

end procedure.

procedure gidemat_del_docs:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service appelé par des .p
    ------------------------------------------------------------------------------*/
    define input parameter pcLstId-In    as character  no-undo.

    define variable vhDocumentRetour        as handle    no-undo.
    define variable vhRootRetour            as handle    no-undo.
    define variable vcFichier               as character no-undo.
    define variable viTmp                   as integer   no-undo.
    define variable vcTmp                   as character no-undo.
    define variable vhServer                as handle    no-undo.
    define variable vhAddrPortType          as handle    no-undo.
    define variable vlErreur                as logical   no-undo.
    define variable vcXMLWS-Out             as longchar  no-undo.
    define variable vlSuppressionPossible   as logical   no-undo.
    define variable viResid                 as int64     no-undo extent 1 . // Array nécessaire pour ws gidemat
    define variable vcRepertoireGed         as character no-undo.
    define variable vcRepertoireFileWatcher as character no-undo.

    define buffer iparm   for iparm.
    define buffer igeddoc for igeddoc.

    /** Détermination du custom **/
    /*****************************/
    assign
        vcRepertoireGed         = f_repertoireGed() 
        vcRepertoireFileWatcher = f_RepertoireFileWatcher()
    .
    /* Utilisateur paramétré par défaut */
    find first iparm no-lock
        where iparm.tppar = "GIDEMAT_ACCES" no-error.
    if not available iparm
    or iparm.lib = ?
    or num-entries(iparm.lib, separ[1]) < 2
    or entry(1, iparm.lib, separ[1]) + entry(2, iparm.lib, separ[1]) = ""
    then do:
        mError:createError({&error}, 1000217). /* L'identifiant-mot de passe de Gidemat n'est pas paramétré */
        return.
    end.

    vcTmp = trim(f_gidemat_custom(entry(1, iparm.lib, separ[1]), entry(2, iparm.lib, separ[1]))). /* recherche du custom */
    if vcTmp > "" then assign
        gcGidematUser     = entry(1, iparm.lib, separ[1])
        gcGidematPassword = entry(2, iparm.lib, separ[1])
        gcGidematCustom   = vcTmp
    .
    else do:
        mError:createError({&error}, 1000218). /* L'identifiant-mot de passe de Gidemat n'est pas paramétré */
        return.
    end.
    
    /* Connection au WS Maarch */
    run maarch_connect(output vhServer).
    if valid-handle(vhServer) then do:
        run mySoapServerPort set vhAddrPortType on server vhServer. /* récupère le handle du port MySoapServerPort */ 
        do viTmp = 1 to num-entries(pcLstId-In, separ[1]):
            for first igeddoc exclusive-lock
                where igeddoc.id-fich = int64(entry(viTmp, pcLstId-In, separ[1])):
                if trim(igeddoc.resid) > "" then do:
                    viResid[1] = int64(igeddoc.resid).
                    run deleteDocs in vhAddrPortType(viResid, output vcXMLWS-Out) no-error.
                    run ErrorInfo (mToken:cUser, output vlErreur). /* Existence d'anomalies ? */
                    if not vlErreur then do:
                        /*Chargement du XML de retour vcXMLWS-Out*/
                        create x-document vhDocumentRetour.
                        create x-noderef  vhRootRetour.
                        vhDocumentRetour:load("LONGCHAR",vcXMLWS-Out,false).
                        vhDocumentRetour:get-document-element(vhRootRetour).
                        run maarch_retour_delete(buffer igeddoc, vhRootRetour, output vlSuppressionPossible). /* Extraction de la liste des erreurs en retour du ws */
                        delete object vhDocumentRetour no-error.
                        delete object vhRootRetour no-error.
                        if vlSuppressionPossible then run delete_igeddoc(buffer igeddoc).
                    end.
                end.
                else do:
                    /* Suppression du fichier en attente de transfert */
                    vcFichier = substitute('&1&4&2&3.7z'
                                         , vcRepertoireGed
                                         , string(igeddoc.id-fich)
                                         , if r-index(igeddoc.nmfichier,".") > 0 then substring(igeddoc.nmfichier, r-index(igeddoc.nmfichier, ".")) else ""
                                         , outils:separateurRepertoire()).
                    if search(vcFichier) <> ? 
                    then os-delete value(vcFichier) no-error.
                    else do:
                        vcFichier = substitute('&1&4&2&3.7z'
                                             , vcRepertoireFileWatcher
                                             , string(igeddoc.id-fich)
                                             , if r-index(igeddoc.nmfichier, ".") > 0 then substring(igeddoc.nmfichier, r-index(igeddoc.nmfichier, ".")) else ""
                                             , outils:separateurRepertoire()).
                        if search(vcFichier) <> ? then os-delete value(vcFichier) no-error.
                    end.
                    run delete_igeddoc(buffer igeddoc).
                end.
            end.
        end.
        vhServer:disconnect() no-error.
        delete object vhServer no-error.
    end.

end procedure.

procedure maarch_retour_delete private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define parameter buffer igeddoc for igeddoc.
    define input  parameter phParent              as handle  no-undo.
    define output parameter plSuppressionPossible as logical no-undo.

    define variable viI             as integer   no-undo.
    define variable viJ             as integer   no-undo.
    define variable vcChamps        as character no-undo.
    define variable vcValue         as character no-undo.
    define variable vcEnreg         as longchar  no-undo.
    define variable vhNoderef       as handle    no-undo.
    define variable viCodeErreur    as integer   no-undo.
    define variable vcLibelleErreur as character no-undo.

    if not valid-handle(phParent) then return.

    create x-noderef vhNoderef.
    repeat viI = 1 to phParent:num-children:
        if phParent:get-child(vhNoderef, viI)
        and vhNoderef:name = "item" and vhNoderef:type = "x-noderef" and vhNoderef:subtype = "element"
        then do:
            vcEnreg = "".
            run liste-enreg(vhNoderef, input-output vcEnreg).
            if vcEnreg = ? or vcEnreg = "" then next.

            assign
                viCodeErreur    = 0
                vcLibelleErreur = ""
            .
boucleChamp:
            repeat viJ = 1 to num-entries(vcEnreg, chr(9)) : /* pour chaque champs */
                vcChamps = entry(viJ, vcEnreg, chr(9)).
                if num-entries(vcChamps, separ[1]) < 2 then next boucleChamp.
                vcValue = string(entry(2, vcChamps, separ[1])).
                case string(entry(1, vcChamps, separ[1])):
                    when "returnCode" then do: 
                        viCodeErreur  = integer(vcValue). 
                        if viCodeErreur = 0 or viCodeErreur = -4 or viCodeErreur = -3 then plSuppressionPossible = true. /* 0  Pas d'erreur,  -4 Déjà supprimé sur gidemat, -3 Inexistant sur gidemat */
                    end.
                    when "error"      then vcLibelleErreur = vcValue.
                end case.
            end.
            if viCodeErreur <> 0
            then mError:createError(if plSuppressionPossible then {&info} else {&error}, 1000230, substitute("&1&4&2&4(&3)", string(igeddoc.id-fich), vcLibelleErreur, string(viCodeErreur), separ[1])). /* 1000230 Erreur identifiant ged &1 &2 &3 */
        end.
    end.
    delete object vhNoderef no-error.
end procedure.

procedure delete_igeddoc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define parameter buffer igeddoc for igeddoc.
    
    define variable vcIdentifiant as character no-undo.
    define variable vcParam       as character no-undo.
    define variable vcType        as character no-undo.

    define buffer tbFic    for tbFic.
    define buffer vbImage  for image.
    define buffer pregln   for pregln.
    define buffer vbPregln for pregln.
    define buffer cecrln   for cecrln.
    define buffer vbCecrln for cecrln.
    define buffer cecrsai  for cecrsai.

    if index(igeddoc.lbrech, "IDENTIFIANT_") > 0
    then do:
        vcIdentifiant = substring(igeddoc.lbrech, index(igeddoc.lbrech, "IDENTIFIANT_")).
        if index(vcIdentifiant, " ") - 1 >= 1
        then vcIdentifiant = substring(vcIdentifiant, 1, index(vcIdentifiant, " ") - 1, 'character').
        if trim(vcIdentifiant) > ""
        then do:
            assign
                vcParam = substring(vcIdentifiant, 13)
                vcType  = entry(1, vcParam, "@")
            .
            case vcType:
                when "tbfic" then if num-entries(vcParam, "@") >= 4
                then for first tbfic exclusive-lock
                    where tbfic.tpidt = entry(2, vcParam, "@")
                      and tbfic.noidt = integer(entry(3, vcParam, "@"))
                      and tbfic.lbfic = replace(entry(4, vcParam, "@"), separ[1], " "):
                    tbfic.id-fich = 0.
                end. /* tbfic */

                when "image" then if num-entries(vcParam, "@") >= 5
                then for first vbImage exclusive-lock 
                    where vbImage.tpidt = entry(2, vcParam, "@")
                      and vbImage.noidt = integer(entry(3,vcParam, "@"))
                      and vbImage.nmrep = entry(4, vcParam, "@")
                      and vbImage.noord = integer(entry(5, vcParam, "@")):
                    vbImage.lbdiv3 = "".
                end. /* image */

                when "pregln" then if num-entries(vcParam, "@") >= 5
                then for first pregln exclusive-lock
                    where pregln.soc-cd    = integer(entry(2, vcParam, "@"))
                      and pregln.mandat-cd = integer(entry(3, vcParam, "@"))
                      and pregln.num-int   = integer(entry(4, vcParam, "@"))
                      and pregln.lig-reg   = integer(entry(5, vcParam, "@")):
                    for each vbPregln exclusive-lock
                        where vbPregln.soc-cd    = pregln.soc-cd
                          and vbPregln.mandat-cd = pregln.mandat-cd
                          and vbPregln.num-int   = pregln.num-int
                          and vbPregln.lig-tot   = pregln.lig-tot
                      , first cecrln exclusive-lock
                        where cecrln.soc-cd    = vbPregln.soc-cd
                          and cecrln.etab-cd   = vbPregln.etab-cd
                          and cecrln.jou-cd    = vbPregln.jou-cd
                          and cecrln.prd-cd    = vbPregln.prd-cd
                          and cecrln.prd-num   = vbPregln.prd-num
                          and cecrln.piece-int = vbPregln.piece-int
                          and cecrln.lig       = vbPregln.lig:
                        cecrln.id-fich = 0.
                    end.
                end. /* pregln */

                when "cecrln" then if num-entries(vcParam, "@") >= 8 
                then for first cecrln exclusive-lock
                    where cecrln.soc-cd    = integer(entry(2, vcParam, "@"))
                      and cecrln.etab-cd   = integer(entry(3, vcParam, "@"))
                      and cecrln.jou-cd    = replace(entry(4, vcParam, "@"), separ[1], " ")
                      and cecrln.prd-cd    = integer(entry(5, vcParam, "@"))
                      and cecrln.prd-num   = integer(entry(6, vcParam, "@"))
                      and cecrln.piece-int = integer(entry(7, vcParam, "@"))
                      and cecrln.lig       = integer(entry(8, vcParam, "@")):
                    cecrln.Id-fich = 0.
                    for first cecrsai exclusive-lock
                        where cecrsai.soc-cd    = cecrln.soc-cd
                          and cecrsai.etab-cd   = cecrln.mandat-cd
                          and cecrsai.jou-cd    = cecrln.jou-cd
                          and cecrsai.prd-cd    = cecrln.mandat-prd-cd
                          and cecrsai.prd-num   = cecrln.mandat-prd-num
                          and cecrsai.piece-int = cecrln.piece-int:
                        if cecrsai.id-fich = igeddoc.id-fich then cecrsai.id-fich = 0.
                        for each vbCecrln exclusive-lock   
                            where vbCecrln.soc-cd         = cecrsai.soc-cd
                              and vbCecrln.mandat-cd      = cecrsai.etab-cd
                              and vbCecrln.jou-cd         = cecrsai.jou-cd
                              and vbCecrln.mandat-prd-cd  = cecrsai.prd-cd
                              and vbCecrln.mandat-prd-num = cecrsai.prd-num
                              and vbCecrln.piece-int      = cecrsai.piece-int
                              and vbCecrln.id-fich        = igeddoc.id-fich:
                            vbCecrln.id-fich = 0.
                        end. /* cecrln */
                    end. /* cecrsai */
                end.

                when "cecrsai" then if num-entries(vcParam, "@") >= 7
                then for first cecrsai exclusive-lock
                    where cecrsai.soc-cd    = integer(entry(2, vcParam, "@"))
                      and cecrsai.etab-cd   = integer(entry(3, vcParam, "@"))
                      and cecrsai.jou-cd    = replace(entry(4, vcParam, "@"), separ[1], " ")
                      and cecrsai.prd-cd    = integer(entry(5, vcParam, "@"))
                      and cecrsai.prd-num   = integer(entry(6, vcParam, "@"))
                      and cecrsai.piece-int = integer(entry(7, vcParam, "@")):
                    cecrsai.Id-fich = 0.
                    for each cecrln  exclusive-lock   
                        where cecrln.soc-cd         = cecrsai.soc-cd
                          and cecrln.mandat-cd      = cecrsai.etab-cd
                          and cecrln.jou-cd         = cecrsai.jou-cd
                          and cecrln.mandat-prd-cd  = cecrsai.prd-cd
                          and cecrln.mandat-prd-num = cecrsai.prd-num
                          and cecrln.piece-int      = cecrsai.piece-int
                          and cecrln.id-fich        = igeddoc.id-fich:
                        cecrln.id-fich = 0.
                    end.
                end.
            end case.
        end. /* trim */
    end. /* index */
    mError:createError({&info}, 1000252, string(igeddoc.id-fich)). /* Fichier GED &1 supprimé*/
    delete igeddoc.

end procedure. /* delete_igeddoc */

procedure gidemat_trsf_docs:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service appelé par des .p
    ------------------------------------------------------------------------------*/
    define input parameter pcLstId-In as longchar no-undo.

    define variable viId              as int64     no-undo.
    define variable viTmp             as integer   no-undo.
    define variable vcFichier         as character no-undo.
    define variable vcExtension       as character no-undo.
    define variable vcResultXml       as longchar  no-undo.
    define variable vhxDoc            as handle    no-undo.
    define variable vhxRoot           as handle    no-undo.
    define variable vhxNoeud          as handle    no-undo.
    define variable vhxText           as handle    no-undo.
    define variable vcReferenceClient as character no-undo.
    define variable vmEncdmptr        as memptr    no-undo.
    define variable vcTmp             as character no-undo.
    define variable vhServer          as handle    no-undo.
    define variable vhAddrPortType    as handle    no-undo.
    define variable vcXMLWS-Out       as longchar  no-undo.
    define variable vhDocumentRetour  as handle    no-undo.
    define variable vhRootRetour      as handle    no-undo.
    define variable vlErreur          as logical   no-undo.
    define variable viId-Fich         as int64     no-undo.
    define variable viNumeroSociete   as integer   no-undo.
    define variable vcIdGi            as character no-undo.
    define variable vcRepertoireGed   as character no-undo.
    define variable viI1              as integer   no-undo.
    define buffer iparm           for iparm.
    define buffer igeddoc         for igeddoc.
    define buffer vbigeddoc       for igeddoc.
    define buffer vbttArrayOfFile for ttArrayOfFile.

    empty temp-table ttarrayOfXml.
    empty temp-table ttarrayOfFile.
    empty temp-table ttretour.

    vcRepertoireGed = f_repertoireGed().
    for first iparm no-lock
        where iparm.tppar = "GED":
        vcReferenceClient = iparm.zone2.
    end.

    /* Création des xml */
boucleXML:
    do viTmp = 1 to num-entries(pcLstId-In, separ[1]):
        viId = int64(entry(viTmp, pcLstId-In, separ[1])).
        find first igeddoc no-lock
            where igeddoc.id-fich = viId no-error.
        if not available igeddoc then do:
            mError:createError({&error}, 1000245, string(viId)). /* 1000245,0,ID GED &1 inexistant */
            next boucleXML.
        end.
        else if igeddoc.statut-cd = "1" then do :
message substitute("fichier &1 statut &2", igeddoc.id-fich, igeddoc.statut-cd).
                mError:createErrorComplement({&error}
                                 , 1000257 // 1000257 "Identifiant GED &1"
                                 , substitute("&1 &2 &3 &4"
                                            , igeddoc.id-fich
                                            , outilTraduction:getLibelle(103265) // 103265 Statut
                                            , "="
                                            , igeddoc.statut-cd)
                                 , igeddoc.ident_u).  
            next boucleXML.
        end.
        assign
            vcExtension = if r-index(igeddoc.nmfichier, ".") > 0
                          then substring(igeddoc.nmfichier, r-index(igeddoc.nmfichier, ".") + 1) /* Ajout de l'extension du fichier d'origine */
                          else ""                
            vcFichier = substitute('&1&4&2&3.7z', vcRepertoireGed, string(igeddoc.id-fich)
                           , if r-index(igeddoc.nmfichier, ".") > 0
                             then substring(igeddoc.nmfichier, r-index(igeddoc.nmfichier, ".")) /* Ajout de l'extension du fichier d'origine */
                             else ""
                           , outils:separateurRepertoire())
        .
        if search(vcFichier) = ? then do:
            mError:createErrorComplement({&error}
                                       , 1000230     // Erreur identifiant ged &1 &2 &3
                                       , substitute("&1&2&3", viId, separ[1], substitute(outilTraduction:getLibelle(1000243), vcFichier)) // 1000243 "Le fichier &1 est inexistant"
                                       , igeddoc.ident_u).
            next boucleXML.
        end.

        file-info:file-name = vcFichier.
        if f_TailleMax() < round(file-info:file-size / (1024 * 1024), 2) /* octet -> mega octet */ then do:
            mError:createErrorComplement({&error}
                                       , 1000230     // Erreur identifiant ged &1 &2 &3
                                       , substitute("&1&2&3"
                                                  , viId
                                                  , separ[1]
                                                  , substitute(outilTraduction:getLibelle(1000244)
                                                             , vcFichier
                                                             , string(round(file-info:file-size / (1024 * 1024),2))
                                                             , f_TailleMax()))
                                       , igeddoc.ident_u).            
            next boucleXML.
        end.

        create x-document vhxDoc.
        create x-noderef  vhxNoeud.
        create x-noderef  vhxText.
        create x-noderef  vhxRoot.

        vhxDoc:create-node(vhxRoot, "ROOT", "ELEMENT").
        vhxDoc:append-child(vhxRoot).
        viNumeroSociete = igeddoc.num-soc.
        if mToken:getValeur('REPGI') matches "*GIDEV*" or mToken:getValeur('REPGI') = ? then viNumeroSociete = 6500. /* custom de test */

        run p_addbalise(vhxRoot, "REFCLI",      "R" + trim(vcReferenceClient),      vhxDoc, vhxNoeud, vhxText).
        run p_addbalise(vhxRoot, "NUMSOC",      string(viNumeroSociete,"99999"),    vhxDoc, vhxNoeud, vhxText).
        run p_addbalise(vhxRoot, "DATE_IDX",    string(igeddoc.dadoc,"99/99/9999"), vhxDoc, vhxNoeud, vhxText).
        run p_addbalise(vhxRoot, "PAGECOUNT",   string(igeddoc.nbpag),         vhxDoc, vhxNoeud, vhxText).
        run p_addbalise(vhxRoot, "DOCTYPE",     igeddoc.cdoctype,              vhxDoc, vhxNoeud, vhxText).
        run p_addbalise(vhxRoot, "TYPDOS",      igeddoc.ctypdos,               vhxDoc, vhxNoeud, vhxText).
        run p_addbalise(vhxRoot, "NUMMDT",      string(igeddoc.nomdt,"99999"), vhxDoc, vhxNoeud, vhxText).
        run p_addbalise(vhxRoot, "NUMCPT",      igeddoc.cnumcpt,               vhxDoc, vhxNoeud, vhxText).
        run p_addbalise(vhxRoot, "TYPETRAIT",   igeddoc.ctypetrait,            vhxDoc, vhxNoeud, vhxText). /* GED */
        run p_addbalise(vhxRoot, "ANNEEMOIS",   igeddoc.canneemois,            vhxDoc, vhxNoeud, vhxText).
        run p_addbalise(vhxRoot, "LIBTRT",      igeddoc.clibtrt,               vhxDoc, vhxNoeud, vhxText).
        run p_addbalise(vhxRoot, "LIBCPT",      igeddoc.clibcpt,               vhxDoc, vhxNoeud, vhxText).
        run p_addbalise(vhxRoot, "MODEREGLT",   "",                            vhxDoc, vhxNoeud, vhxText).
        run p_addbalise(vhxRoot, "DESTINATAIRE",igeddoc.cdestinat,             vhxDoc, vhxNoeud, vhxText).
        run p_addbalise(vhxRoot, "IDENTIFIER",  string(igeddoc.id-fich) + "/" + string(viNumeroSociete, "99999"), vhxDoc, vhxNoeud, vhxText).
        run p_addbalise(vhxRoot, "FORMAT",      vcExtension,                   vhxDoc, vhxNoeud, vhxText).

        vhxDoc:encoding = "utf-8".
        vhxDoc:save("longchar", vcResultXml).
        /** Stockage du xml **/
        create ttarrayOfXml.
        assign 
            ttarrayOfXml.cXml     = vcResultXml
            ttarrayOfXml.id-fich  = igeddoc.id-fich
        .                        
        delete object vhxRoot.
        delete object vhxDoc.
        delete object vhxNoeud.
        delete object vhxText.
        /* Stockage du fichier */
        copy-lob from file vcFichier to vmEncdmptr.
        /***/
        create ttarrayOfFile.
        assign
            ttarrayOfFile.cFile   = base64-encode(vmEncdmptr)
            ttarrayOfFile.id-fich = igeddoc.id-fich
            set-size(vmEncdmptr)  = 0
        .

        /* Contrôle taille du fichier encodé en base 64 */
        if f_TailleMax() < round(length(ttarrayOfFile.cFile, "character") / (1024 * 1024), 2) /* octet -> mega octet */ then do:
            mError:createErrorComplement(
                {&error},
                1000230, /* Erreur identifiant ged &1 &2 &3 */
                substitute("&1&2&3",
                           viId,
                           separ[1],
                           substitute(outilTraduction:getLibelle(1000719), // Taille du fichier à transférer &1 (&2 Mo après conversion base64) supérieure au maximum autorisé (&3 Mo)
                                      "",
                                      round(length(ttarrayOfFile.cFile, "character") / (1024 * 1024), 2), f_TailleMax())),
                                      igeddoc.ident_u).  
            return.
        end.
    end. /* viTmp */

    for first ttarrayOfFile, 
        first vbigeddoc where vbigeddoc.id-fich = ttarrayOfFile.id-fich no-lock : 
        /*****************************/
        /** Détermination du custom **/
        /*****************************/
        /* Utilisateur paramétré par défaut */
        find first iparm no-lock
            where iparm.tppar = "GIDEMAT_ACCES" no-error.
        if not available iparm
        or iparm.lib = ?
        or num-entries(iparm.lib, separ[1]) < 2
        or entry(1, iparm.lib, separ[1]) + entry(2, iparm.lib, separ[1]) = ""
        then do:
            mError:createErrorComplement({&error}, 1000247, "", vbigeddoc.ident_u). /* L'identifiant et le mot de passe de l'accès Gidemat ne sont pas paramétrés */
            return.
        end.
        vcTmp = trim(f_gidemat_custom(entry(1, iparm.lib, separ[1]), entry(2, iparm.lib, separ[1]))). /* recherche du custom */
        if vcTmp > "" then assign
            gcGidematUser     = entry(1, iparm.lib, separ[1])
            gcGidematPassword = entry(2, iparm.lib, separ[1])
            gcGidematCustom   = vcTmp
        .
        else do:
            mError:createErrorComplement({&error}, 1000247, entry(1, iparm.lib, separ[1]), vbigeddoc.ident_u). /* Connection à gidemat impossible avec l'utilisateur &1 */
            return.
        end.

        run maarch_connect(output vhServer). /* Connection au WS Maarch */
        run mySoapServerPort set vhAddrPortType on server vhServer. /* récupère le handle du port MySoapServerPort */
        
boucleTransfert :
        repeat viI1 = 1 to 10 : // Jusque 10 tentatives de transfert
message substitute("StoreDocs transfert Id &1 (passe &2)", pcLstId-In, viI1).
            run storeDocs in vhAddrPortType(dataset TblFile, dataset TblXml, output vcXMLWS-Out) no-error. /* Execution de la procedure storedocs dans le ws */
            run ErrorInfo (vbigeddoc.ident_u, output vlErreur). /* Existence d'anomalie ? */
            if vlErreur then do:
                mError:createErrorComplement({&error}, 1000249, substitute("&1&3&2", vcFichier, igeddoc.id-fich, separ[1]), vbigeddoc.ident_u). /* Erreur fichier &1 Identifiant &2 */
message "Anomalie de transfert" string(pcLstId-In).
                vhServer:disconnect() no-error.
                delete object vhServer no-error.
                return.
            end.            
            /*Chargement du XML de retour vcXMLWS-Out*/
            create x-document vhDocumentRetour.
            create x-noderef  vhRootRetour.
            vhDocumentRetour:load("LONGCHAR",vcXMLWS-Out,false).
            vhDocumentRetour:get-document-element(vhRootRetour).
            run maarch_retour_vers(vhRootRetour). /* A partir du xml de retour : Extraction de la liste des id versés dans gidemat (ttRetour) */
            delete object vhDocumentRetour no-error.
            delete object vhRootRetour no-error.
            // Suppression des fichiers transférés
            for each ttarrayOfXml :
                if can-find(first ttRetour where ttRetour.IdGI-resId begins string(ttarrayOfXml.id-fich) + "/") // Fichier transféré ou anomalie retournée
                then do :
                    find first vbttArrayOfFile where vbttArrayOfFile.id-fich = ttarrayOfXml.id-fich no-error.
                    if available vbttArrayOfFile then delete vbttArrayOfFile no-error.
                    delete ttarrayOfXml no-error.
                end.                    
            end.
            if not can-find(first ttarrayOfXml) then leave boucleTransfert. // Maarch a renvoyé une réponse pour tous les fichiers
            for each ttretour where ttRetour.IdGI-resId = "" or ttRetour.IdGI-resId = ? :
                message "Id Ged : " string(pcLstId-In) " -> Retour Gidemat = vide".                 
                delete ttretour.
            end.                            
            pause 1.   //  Présence de fichiers sans retour associé = pas de réponse de maarch, on retransfert
        end.
        vhServer:disconnect() no-error.
        delete object vhServer no-error.
message "Retour gidemat transfert " string(pcLstId-In).
        for each ttretour:
            message "Id Ged : " string(pcLstId-In) " -> Retour Gidemat = " ttretour.IdGI-resId.
        end.
        if not can-find(first ttRetour where ttretour.IdGI-resId > "") then do :
            mError:createErrorComplement({&error}, 1000249, substitute("&1&3&2&4", vcFichier, igeddoc.id-fich, separ[1],"(2)"), vbigeddoc.ident_u). /* Erreur fichier &1 Identifiant &2 */
            return.    
        end.    
        /* Mise à jour des resid */
        for each ttretour where integer(ttretour.return-Code) = 0 and ttretour.IdGI-resId > "" :
            /* Format identifiant GI/societe-resid maarch */
            assign
                vcIdGi    = entry(1, ttretour.IdGI-resId, "-")
                viId-Fich = int64(entry(1, vcIdGi, "/"))
            .
            for first igeddoc exclusive-lock
                where igeddoc.id-fich = viId-Fich:
                assign
                    igeddoc.resid  = entry(2, ttretour.IdGI-resId, "-") /* resid maarch */
                    igeddoc.statut = "1"                                /* Transféré */
                    /* Suppression de l'archive du repertoire de sauvegarde temporaire, Ajout de l'extension du fichier d'origine */
                    vcFichier      = substitute('&1&4&2&3.7z'
                               , vcRepertoireGed
                               , string(igeddoc.id-fich)
                               , if r-index(igeddoc.nmfichier,".") > 0 then substring(igeddoc.nmfichier, r-index(igeddoc.nmfichier, ".")) else ""
                               , outils:separateurRepertoire())
                .
message "Fichier a supprimer " vcFichier "id" viId-Fich.
                os-delete value(vcFichier) no-error.
                if search(vcFichier) > "" then do :
                    mError:createErrorComplement({&info}, 1000237, substitute("&1 : &2", igeddoc.id-fich, vcFichier), igeddoc.ident_u).  // INFO 1000237 Erreur en suppression du fichier &1" !
message "Erreur en suppression du fichier " igeddoc.id-fich vcFichier.
                end.
                mError:createErrorComplement({&info}, 1000251, substitute("&1&3&2", igeddoc.id-fich, igeddoc.nmfichier, separ[1]), igeddoc.ident_u).  /* Identifiant GED &1 fichier &2 transféré */
            end.
        end.  
        /* Anomalies retournées */
        for each ttretour where integer(ttretour.return-Code) <> 0:
            mError:createErrorComplement({&error}, 1000250, substitute("&1&4&2&4&3", ttretour.return-Code, ttretour.cerror, "", separ[1]), vbigeddoc.ident_u).  /* Erreur &1 &2 &3 */
        end.
    end.

end procedure.

procedure p_addbalise private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
     define input parameter phNode-In      as handle    no-undo.
     define input parameter pcNomBalise-In as character no-undo.
     define input parameter pcValue-In     as character no-undo.
     define input parameter phxDoc-In      as handle    no-undo.
     define input parameter phxNoeud-In    as handle    no-undo.
     define input parameter phxText-In     as handle    no-undo.

     phxDoc-In:create-node(phxNoeud-In, pcNomBalise-In, "ELEMENT").
     phNode-In:append-child(phxNoeud-In).
     phxDoc-In:create-node(phxText-In, "", "TEXT").
     phxNoeud-IN:append-child(phxText-In).
     phxText-In:node-value = pcValue-In.

 end procedure.

 procedure maarch_retour_vers private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter phParent as handle no-undo.

    define variable viI       as integer   no-undo.
    define variable viK       as integer   no-undo.
    define variable viJ       as integer   no-undo.
    define variable vcLigne   as character no-undo.
    define variable vcChamps  as character no-undo.
    define variable vcValue   as character no-undo.
    define variable vcEnreg   as longchar  no-undo.
    define variable vhNoderef as handle    no-undo.

    /* Liste de documents */
    create x-noderef vhNoderef.
    if valid-handle(phParent)
    then repeat viI = 1 to phParent:num-children:
        if phParent:get-child(vhNoderef, viI)
        and vhNoderef:name = "item" and vhNoderef:type = "x-noderef" and vhNoderef:subtype = "element"
        then do:
            vcEnreg = "".
            run liste-enreg(vhNoderef, input-output vcEnreg).
boucleEnregistrement:
            repeat viJ = 1 to num-entries(vcEnreg, chr(13)):
                vcLigne = entry(viJ, vcEnreg, chr(13)).
                if vcLigne = ? or vcLigne = "" then next boucleEnregistrement.

                create ttretour.
boucleChamp:
                repeat viK = 1 to num-entries(vcLigne, chr(9)):
                    vcChamps = entry(viK, vcLigne, chr(9)).
                    if num-entries(vcChamps, separ[1]) < 2 then next boucleChamp.

                    vcValue = string(entry(2, vcChamps, separ[1])).
                    case string(entry(1, vcChamps, separ[1])):
                        when "returnCode" then ttretour.return-Code = vcValue.
                        when "IdGI-resId" then ttretour.IdGI-resId = vcValue.
                        when "error"      then ttretour.cerror = vcValue.
                    end case.
                end.
            end.
        end.
    end.
    delete object vhNoderef no-error.

end procedure.
 