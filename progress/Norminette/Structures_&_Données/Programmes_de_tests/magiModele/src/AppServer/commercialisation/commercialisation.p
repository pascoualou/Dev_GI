/*------------------------------------------------------------------------
File        : commercialisation.p
Purpose     :
Author(s)   : LGI/NPO  -  2016/12/07
Notes       :
derniere revue: 2018/05/18 - phm: KO
        traiter les todo et les message
------------------------------------------------------------------------*/
{preprocesseur/type2contrat.i}
{preprocesseur/nature2contrat.i}
{preprocesseur/type2tache.i}
{preprocesseur/type2bien.i}
{preprocesseur/nature2voie.i}
{preprocesseur/type2adresse.i}
{preprocesseur/type2telephone.i}
{preprocesseur/type2role.i}
{preprocesseur/type2libelle.i}
{preprocesseur/codefinancier2commercialisation.i}
{preprocesseur/codeAttributDivers.i}
{preprocesseur/type2tiers.i}

using OpenEdge.Net.HTTP.RequestBuilder.
using OpenEdge.Net.HTTP.ClientBuilder.
using OpenEdge.Net.HTTP.IhttpRequest.
using OpenEdge.Net.HTTP.IhttpResponse.
using Progress.Json.ObjectModel.JsonObject.

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{commercialisation/include/FicheCommercialisation.i}
{commercialisation/include/codeDivers.i &nomTable=ttAttributsDivers}
{commercialisation/include/codeDivers.i &nomTable=ttSiteWebFiche}
{commercialisation/include/historiqueFiche.i}
{commercialisation/include/histoEncadrementLoyer.i}
{commercialisation/include/siteWeb.i}
{commercialisation/include/libellecommercialisation.i}
{commercialisation/include/sequence.i}
{commercialisation/include/tiersCommercialisation.i}
{commercialisation/include/loyerCommercialisation.i}
{commercialisation/include/depotCommercialisation.i}
{commercialisation/include/honoraireCommercialisation.i}
{commercialisation/include/detailFinance.i}
{commercialisation/include/histoWorkflow.i}
{commercialisation/include/plafonnementEncadrementLoyer.i}
{adresse/include/proximite.i}
{adresse/include/coordonnee.i &nomTable=ttCoordonneeTiers}
{adresse/include/moyenCommunication.i &nomTable=ttMoyenCommunicationTiers}
{adresse/include/adresse.i}
{mandat/include/mandat.i}
{application/include/glbsepar.i}
{application/include/combo.i}
{application/include/error.i}

procedure appelWebService private:
    /*------------------------------------------------------------------------------
    Purpose: appel web service gi extranet
    Notes  : gga todo voir si necessaire de rendre cette procedure generique et ou la positionner
    ------------------------------------------------------------------------------*/
    define input  parameter pcUrl         as character no-undo.
    define input  parameter pcRef         as character no-undo.
    define input  parameter pcApiKey      as character no-undo.
    define input  parameter pcFiltreLib   as character no-undo extent 5.
    define input  parameter pcFiltreVal   as character no-undo extent 5.
    define output parameter plErreurAppel as logical   no-undo initial true.

    define variable vcHttpUrl as character no-undo.
    define variable viI       as integer   no-undo.

    empty temp-table ttCalculEncadrementLoyer.
    vcHttpUrl = substitute('&1?ref=&2&&apiKey=&3', pcUrl, pcRef, pcApiKey).
    if pcFiltreLib[1] > "" then do:
        vcHttpUrl = vcHttpUrl + '&filter=~{'.
        do viI = 1 to extent(pcFiltreLib):
            if trim(pcFiltreLib[viI]) > "" then vcHttpUrl = substitute('&1~"&2~":~"&3~",', vcHttpUrl, pcFiltreLib[viI], pcFiltreVal[viI]).
        end.
        vcHttpUrl = right-trim(vcHttpUrl, ",") + '~}'.
    end.

    /*gga todo a voir aussi pour recuperer construction periode (voir document pdf d analyse) */

message "gga url appel : " vcHttpUrl.

/*gga todo le 2017/06/29
pour l'instant mise en commentaire de cette methode d'appel on rencontre des problemes sur la lecture du json
en retour quand il y a un accent sur l'adresse (allée par exemple)
    /* si erreur sur les 2 instructions suivantes, avec le 'no-error' plus de message d'erreur progress mais on n'arrive pas
    a recuperer les erreurs (error-status:error = no et error-status:num-messages = 0), donc on fait un test valid-object */
    define variable voRequest  as IhttpRequest  no-undo.
    define variable voResponse as IhttpResponse no-undo.

    voRequest = RequestBuilder:get(vcHttpUrl):request no-error.
    if not valid-object(voRequest)
    then do:
        /* problème sur l'appel du web service */
        mError:createError({&error}, 1000294).
        return.
    end.

    voResponse = ClientBuilder:Build():Client:execute(voRequest) no-error.
    if not valid-object(voResponse)
    then do:
        /* problème sur l'appel du web service */
        mError:createError({&error}, 1000294).
        return.
    end.

    if voResponse:StatusCode <> 200
    then do:
        /* code retour appel websevice incorrect : &1 */
        mError:createError({&error}, 1000295, string(voResponse:StatusCode)).
        return.
    end.

    if not type-of(voResponse:Entity, JsonObject)
    then do:
        /* les informations en retour du webservice ne sont pas de type json */
        mError:createError({&error}, 1000292).
        return.
    end.

    if not temp-table ttCalculEncadrementLoyer:handle:read-json('JsonObject ', voResponse:Entity, 'empty')
    then do:
        /* le chargement du json a echoué */
        mError:createError({&error}, 1000293).
        return.
    end.

    plErreurAppel = no.

gga todo le 2017/06/29*/

    /*gga todo le 2017/06/29 debut ancienne methode pour appel du web service */
    define variable voHttpClient       as class System.Net.WebClient no-undo.
    define variable vcWebResponse      as longchar  no-undo.
    define variable vhttFilter         as handle    no-undo.
    define variable vhBuffer           as handle    no-undo.
    define variable vcAncFormatNumeric as character no-undo.
    define variable vcAncFormatDate    as character no-undo.

    {&_proparse_ prolint-nowarn(bufdbproc)}         // TODO revoir cette règle car system.net est considéré comme buffer
    assign
        voHttpClient                   = new System.Net.WebClient()
        voHttpClient:proxy:Credentials = System.Net.CredentialCache:DefaultNetworkCredentials
        vcWebResponse                  = voHttpClient:DownloadString(vcHttpUrl)
    .
    voHttpClient:Dispose().
    delete object voHttpClient.

message string(vcWebResponse).

    if vcWebResponse > "" then do:
        create temp-table vhttFilter.
        vhttFilter:read-json("LONGCHAR", vcWebResponse, "empty") no-error.
        if not error-status:error
        then do:
            vhBuffer = vhttFilter:default-buffer-handle.
            vhBuffer:find-first() no-error.
            if vhBuffer:available then do:
                create ttCalculEncadrementLoyer.
                assign
                    vcAncFormatNumeric     = session:numeric-format
                    vcAncFormatDate        = session:date-format
                    session:numeric-format = "american"
                    session:date-format    = "ymd"
                    ttCalculEncadrementLoyer.lvalid = vhBuffer::valid
                no-error.
                ttCalculEncadrementLoyer.cstatus      = vhBuffer::code_status no-error.
                ttCalculEncadrementLoyer.dthorodatage = vhBuffer::horodatage no-error.
                {&_proparse_ prolint-nowarn(abbrevkwd)}
                ttCalculEncadrementLoyer.dLoyerMinore = vhBuffer::min no-error.
                {&_proparse_ prolint-nowarn(abbrevkwd)}
                ttCalculEncadrementLoyer.dLoyerMajore = vhBuffer::max no-error.
                ttCalculEncadrementLoyer.dLoyerMedian = vhBuffer::ref no-error.
                assign
                    session:numeric-format = vcAncFormatNumeric
                    session:date-format    = vcAncFormatDate
                    plErreurAppel          = no
                .
            end.
        end.
    end.
/*gga todo le 2017/06/29 fin ancienne methode pour appel du web service */

end procedure.

function getLibelleIndice returns character private(piCdIrv as integer):
    /*------------------------------------------------------------------------------
    Purpose: recherche du libellé indice de révision
    Notes  :
    ------------------------------------------------------------------------------*/
    define buffer lsirv for lsirv.

    for first lsirv no-lock
        where lsirv.cdirv = piCdIrv:
        return lsirv.lbcrt.
    end.
    return "".

end function.

function igetNextSequence returns integer (pcNomTable as character, pcChampSequence as character):
    /*------------------------------------------------------------------------------
    Purpose: calcul prochain numero de sequence
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhBuffer   as handle  no-undo.
    define variable viSequence as integer no-undo initial 1.

    create buffer vhBuffer for table pcNomTable.
    vhBuffer:find-last("", no-lock) no-error.
    viSequence = if vhBuffer:available then vhBuffer:buffer-field(pcChampSequence):buffer-value + 1 else 1.
    delete object vhBuffer no-error.
    return viSequence.

end function.

function ficheExiste returns logical private(piNoFiche as integer):
    /*------------------------------------------------------------------------------
    Purpose: controle fiche existe
    Notes  :
    ------------------------------------------------------------------------------*/
    if can-find(first gl_fiche no-lock
                where gl_fiche.nofiche = piNoFiche) then return true.

    /* Fiche location no &1 inexistante */
    mError:createError({&error}, 1000226, string(piNoFiche)).
    return false.
end function.

function champFinanceExiste returns logical private (piValFinance as integer, pdTypeFin as decimal):
    /*------------------------------------------------------------------------------
    Purpose: controle type champ finance existe
    Notes  :
    ------------------------------------------------------------------------------*/
    if can-find(first sys_pr no-lock
                where sys_pr.tppar = "GLCHF"
                  and sys_pr.cdpar = string(piValFinance, '99999')
                  and sys_pr.zone1 = pdTypeFin) then return true.

    /* id champ finance &1 inexistant */
    mError:createError({&error}, 1000282, string(piValFinance)).
    return false.
end function.

function champFinanceDouble returns logical private (piNoFinance as integer, piChpFinance as integer):
    /*------------------------------------------------------------------------------
    Purpose: controle si type champ finance deja existant pour la fiche
    Notes  :
    ------------------------------------------------------------------------------*/
    if not can-find(first gl_detailfinance no-lock
                    where gl_detailfinance.nofinance    = piNoFinance
                      and gl_detailfinance.nochpfinance = piChpFinance) then return false.

    /* id champ finance &1 deja existant sous cette fiche */
    mError:createError({&error}, 1000283, string(piChpFinance)).
    return true.
end function.

function getLibelleGenreFournisseur returns character private(piCodeSociete as integer, piCodeRaisonSociale as integer):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : Retourne le genre du fournisseur
    ------------------------------------------------------------------------------*/
    define buffer ilibrais for ilibrais.

    for first ilibrais no-lock
        where ilibrais.soc-cd     = piCodeSociete
          and ilibrais.librais-cd = piCodeRaisonSociale:
        return ilibrais.lib.
    end.
    return "".
end function.

function getLibellePaysFournisseur returns character private(piCodeSociete as integer, pcCodePays as character):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : Retourne le Code Pays
    ------------------------------------------------------------------------------*/
    define buffer ilibpays for ilibpays.

    for first ilibpays no-lock
        where ilibpays.soc-cd     = piCodeSociete
          and ilibpays.libpays-cd = pcCodePays:
        return ilibpays.lib.
    end.
    return "".
end function.

function getNomTiersCommercialisation returns character private
    (piTpTiers as integer, pcTpRol as character, piNoRol as integer, pcSocCd as character, pcFour as character):
    /*------------------------------------------------------------------------------
    Purpose: récupère le nom d'un tiers RoleGI ou fournisseurGI
    Notes  :
    ------------------------------------------------------------------------------*/
    define buffer tiers   for tiers.
    define buffer vbRoles for roles.
    define buffer ifour   for ifour.

    if piTpTiers = {&TYPETIERS-tiersRoleGI}                 // Tiers issus de la GESTION : Tiers/roles
    then for first vbRoles no-lock
        where vbRoles.tprol = pcTpRol
          and vbRoles.norol = piNoRol
      , first tiers no-lock
        where tiers.notie = vbRoles.notie:
        return tiers.lnom1.
    end.
    if piTpTiers = {&TYPETIERS-fournisseurGI}               // Tiers issus de la COMPTA : IFOUR
    then for first ifour no-lock
        where ifour.soc-cd   = integer(pcSocCd)
          and ifour.four-cle = pcFour:
        return ifour.nom.
    end.
    return "".
end function.

function rechlibelle returns character private(piTpLibelle as integer, piNoLibelle as integer):
    /*------------------------------------------------------------------------------
    Purpose:  Recherche libelle workflow
    Notes:    si libelle libre alors c'est qu'il y a eu modification du libelle alors
              on retourne ce libelle; si non retour du libelle de la table des messages
    ------------------------------------------------------------------------------*/
    define buffer gl_libelle for gl_libelle.

    for first gl_libelle no-lock
        where gl_libelle.noidt = piNoLibelle
          and gl_libelle.tpidt = piTpLibelle:
        if gl_libelle.libellelibre > "" then return gl_libelle.libellelibre.
        return outilTraduction:getLibelle(string(gl_libelle.nomes)).
    end.
    return "".
end function.

procedure readHistoMajWorkflow private:
    /*------------------------------------------------------------------------------
    Purpose: Récupère l'historique maj workflow pour une fiche
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter piNoFiche as integer no-undo.

    define variable viNbrHisto as integer no-undo.
    define buffer gl_histo_workflow for gl_histo_workflow.

    empty temp-table ttHistoWorkflow.
    {&_proparse_ prolint-nowarn(sortaccess)}
    for each gl_histo_workflow no-lock
        where gl_histo_workflow.nofiche = piNoFiche
           by gl_histo_workflow.dtcsy descending
           by gl_histo_workflow.hecsy descending
        viNbrHisto = 1 to 10:                      // maxi 10 lignes
        create ttHistoWorkflow.
        assign
            ttHistoWorkflow.iNumeroFiche        = gl_histo_workflow.nofiche
            ttHistoWorkflow.iNumeroWorkflowPrec = gl_histo_workflow.noworkflow1
            ttHistoWorkflow.iNumeroWorkflowSuiv = gl_histo_workflow.noworkflow2
            ttHistoWorkflow.dtHorodatageMaj     = datetime(gl_histo_workflow.dtcsy, gl_histo_workflow.hecsy)
            ttHistoWorkflow.cSysUser            = gl_histo_workflow.cdcsy
            ttHistoWorkflow.CRUD                = "R"
        .
    end.
end procedure.

procedure readListeFiche private:
    /*------------------------------------------------------------------------------
    Purpose: Récupère les fiches Commercialisation
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter pcWhereClause       as character no-undo.
    define input parameter pcSiteWeb           as character no-undo.
    define input parameter piNumeroImmeuble    as integer   no-undo.
    define input parameter pcServiceGestion    as character no-undo.
    define input parameter pcCodePostal        as character no-undo.
    define input parameter pcVille             as character no-undo.
    define input parameter pcCodeUsage         as character no-undo.
    define input parameter piJourVacantDeb     as integer   no-undo.
    define input parameter piJourVacantFin     as integer   no-undo.
    define input parameter pdLoyerDeb          as decimal   no-undo.
    define input parameter pdLoyerFin          as decimal   no-undo.
    define input parameter pcWorkflow          as character no-undo.

    define variable vcTableName          as character no-undo initial 'gl_fiche'.
    define variable vhBuffer             as handle    no-undo.
    define variable vhquery              as handle    no-undo.
    define variable viI                  as integer   no-undo.
    define variable vlSelSiteWeb         as logical   no-undo.
    define variable viNombreJoursVacance as integer   no-undo.
    define variable vcNomServiceGestion  as character no-undo.
    define variable vcCodePostal         as character no-undo.
    define variable vcVille              as character no-undo.
    define variable vcAdresse            as character no-undo.
    define variable vcLibelleAdresse     as character no-undo.
    define variable viNumeroImmeuble     as integer   no-undo.
    define variable vdMontantLoyer       as decimal   no-undo.
    define variable viNumeroContratMin   as int64     no-undo.
    define variable viNumeroContratMax   as int64     no-undo.

    define buffer tutil          for tutil.
    define buffer gl_sequence    for gl_sequence.
    define buffer ctrat          for ctrat.
    define buffer tache          for tache.
    define buffer intnt          for intnt.
    define buffer gl_loyer       for gl_loyer.
    define buffer gl_finance     for gl_finance.
    define buffer gl_fiche_tiers for gl_fiche_tiers.

    empty temp-table ttFicheCommercialisation.
    create buffer vhbuffer for table vcTableName.
    create query vhquery.
    vhquery:set-buffers(vhbuffer).
    vhquery:query-prepare(substitute('for each &1 no-lock &2', vcTableName, if pcWhereClause = ? then "" else pcWhereClause)).
    vhquery:query-open().

blocRepeat:
    repeat:
        vhquery:get-next().
        if vhquery:query-off-end then leave blocRepeat.

        if pcSiteWeb > "" then do:
            vlSelSiteWeb = no.
blocDo:
            do viI = 1 to num-entries(pcSiteWeb):
                if can-find(first gl_fiche_siteweb no-lock
                            where gl_fiche_siteweb.nofiche = vhbuffer::nofiche
                              and gl_fiche_siteweb.nositeweb = integer(entry(viI, pcSiteWeb)))
                then do:
                    vlSelSiteWeb = yes.
                    leave blocDo.
                end.
            end.
            if vlSelSiteWeb = no then next blocRepeat.
        end.

        viNumeroImmeuble = 0.
        for first ctrat no-lock
            where ctrat.tpcon = vhbuffer::tpcon
              and ctrat.nocon = vhbuffer::nocon
          , first intnt no-lock
            where intnt.tpcon = {&TYPECONTRAT-mandat2Gerance}
              and intnt.nocon = ctrat.nocon
              and intnt.tpidt = {&TYPEBIEN-immeuble}:
            viNumeroImmeuble = intnt.noidt.
        end.
        if piNumeroImmeuble <> ? and (viNumeroImmeuble < piNumeroImmeuble or viNumeroImmeuble > piNumeroImmeuble) 
        then next blocRepeat.

        vdMontantLoyer = 0.
        for first gl_finance no-lock
            where gl_finance.nofiche   = vhbuffer::nofiche
              and gl_finance.nohisto   = 0
              and gl_finance.tpfinance = {&TYPEFINANCE-LOYER}
          , first gl_loyer no-lock
            where gl_loyer.nofinance   = gl_finance.nofinance:
            vdMontantLoyer = gl_loyer.totalttc.
        end.
        if (pdLoyerDeb > 0 and vdMontantLoyer < pdLoyerDeb)
        or (pdLoyerFin > 0 and vdMontantLoyer > pdLoyerFin) then next blocRepeat.

        assign
            viNombreJoursVacance = 0
            viNumeroContratMin   = vhbuffer::nocon * 100000 + vhbuffer::noapp * 100 + 1   //  int64(string(vhbuffer::nocon, "99999") + string(vhbuffer::noapp, "999") + "01")
            viNumeroContratMax   = vhbuffer::nocon * 100000 + vhbuffer::noapp * 100 + 99  //  int64(string(vhbuffer::nocon, "99999") + string(vhbuffer::noapp, "999") + "99")
        .
        for each ctrat no-lock
            where ctrat.tpcon = {&TYPECONTRAT-bail}
              and ctrat.nocon >= viNumeroContratMin
              and ctrat.nocon <= viNumeroContratMax
              and ctrat.ntcon <> {&NATURECONTRAT-specialVacant}     /* sans les baux spécial vacant */
              and ctrat.fgannul = false                             /* sans les baux annulés */
          , last tache no-lock
            where tache.tpcon = ctrat.tpcon
              and tache.nocon = ctrat.nocon
              and tache.tptac = {&TYPETACHE-quittancement}
            by ctrat.nocon:
            viNombreJoursVacance = today - tache.dtfin.
        end.
        if (piJourVacantDeb > 0 and viNombreJoursVacance < piJourVacantDeb)
        or (piJourVacantFin > 0 and viNombreJoursVacance > piJourVacantFin)
        or (pcWorkflow > ""     and lookup(string(vhbuffer::noworkflow), pcWorkflow) = 0)
        or (pcCodeUsage > ""    and lookup(vhbuffer::cdcmp, pcCodeUsage) = 0) then next blocRepeat.

        vcNomServiceGestion = "".
        for first gl_fiche_tiers no-lock
            where gl_fiche_tiers.nofiche     = vhbuffer::nofiche
              and gl_fiche_tiers.nohisto     = 0
              and gl_fiche_tiers.tprolefiche = "00048":
           vcNomServiceGestion = getNomTiersCommercialisation(gl_fiche_tiers.tptiers, gl_fiche_tiers.tprol, gl_fiche_tiers.norol,
                                                                                      gl_fiche_tiers.soccd, gl_fiche_tiers.four-cle).
        end.
        if (pcServiceGestion > "" and not vcNomServiceGestion matches substitute("*&1*", pcServiceGestion)) then next blocRepeat.

        assign
            vcCodePostal     = ""
            vcVille          = ""
            vcAdresse        = ""
            vcLibelleAdresse = ""
        .
        run getAdresseSimplifieUnite (vhbuffer::noapp, vhbuffer::nocon, output vcCodePostal, output vcVille, output vcAdresse, output vcLibelleAdresse).
        if (pcCodePostal > "" and not vcCodePostal begins pcCodePostal)
        or (pcVille > ""      and not vcVille matches substitute("*&1*", pcVille)) then next blocRepeat.

        create ttFicheCommercialisation.
        assign
            ttFicheCommercialisation.CRUD                 = 'R'
            ttFicheCommercialisation.iNumeroFiche         = vhbuffer::nofiche
            ttFicheCommercialisation.iTypeFiche           = vhbuffer::typfiche
            ttFicheCommercialisation.cTypeContrat         = vhbuffer::tpcon
            ttFicheCommercialisation.iNumeroContrat       = vhbuffer::nocon
            ttFicheCommercialisation.iNumeroUL            = vhbuffer::noapp
            ttFicheCommercialisation.cCodeNatureUL        = vhbuffer::cdcmp
            ttFicheCommercialisation.cLibelleNatureUL     = outilTraduction:getLibelleParam("NTAPP", vhbuffer::cdcmp)
            ttFicheCommercialisation.iNumeroWorkflow      = vhbuffer::noworkflow
            ttFicheCommercialisation.cLibelleWorkflow     = rechlibelle({&TYPLIBELLE-workflow}, vhbuffer::noworkflow)
            ttFicheCommercialisation.iNumeroModeCreation  = vhbuffer::nomodecreation
            ttFicheCommercialisation.iNumeroZoneAlur      = vhbuffer::nozonealur
            ttFicheCommercialisation.cTitreCommercial     = vhbuffer::titre_comm
            ttFicheCommercialisation.cAnnonceCommerciale  = vhbuffer::texte_comm
            ttFicheCommercialisation.cDescriptifGestion   = vhbuffer::texte_gestion
            ttFicheCommercialisation.iNombrePieces        = vhbuffer::nbpiece
            ttFicheCommercialisation.dSurfaceHabitable    = vhbuffer::surfhab
            ttFicheCommercialisation.iNombrePhotos        = vhbuffer::nbphoto
            ttFicheCommercialisation.dLoyerPreconise      = vhbuffer::loy_preco
            ttFicheCommercialisation.cTexteLoyerPreconise = vhbuffer::texte_loy_preco
            ttFicheCommercialisation.lGarantieVacanceLoc  = vhbuffer::fgvac_locative
            ttFicheCommercialisation.lGarantieLoyerImpaye = vhbuffer::fgloy_impaye
            ttFicheCommercialisation.cTypeContratLoc      = vhbuffer::tpconloc
            ttFicheCommercialisation.iNumeroContratLoc    = vhbuffer::noconloc
            ttFicheCommercialisation.iNombreJoursVacance  = viNombreJoursVacance
            ttFicheCommercialisation.cNomServiceGestion   = vcNomServiceGestion
            ttFicheCommercialisation.cCodePostal          = vcCodePostal
            ttFicheCommercialisation.cVille               = vcVille
            ttFicheCommercialisation.cAdresse             = vcAdresse
            ttFicheCommercialisation.cLibelleAdresse      = vcLibelleAdresse
            ttFicheCommercialisation.iNumeroImmeuble      = viNumeroImmeuble
            ttFicheCommercialisation.dMontantLoyerCC      = vdMontantLoyer
            ttFicheCommercialisation.dtDateCreation       = datetime(vhbuffer::dtcsy, vhbuffer::hecsy)
            ttFicheCommercialisation.dtTimestamp          = datetime(vhbuffer::dtmsy, vhbuffer::hemsy)
            ttFicheCommercialisation.rRowid               = vhbuffer:rowid
        .
        for first tutil no-lock
            where tutil.ident_u = vhbuffer::CdCsy:
            ttFicheCommercialisation.cSysUser = tutil.nom.
        end.
        for first ctrat no-lock
            where ctrat.tpcon = ttFicheCommercialisation.cTypeContrat
              and ctrat.nocon = ttFicheCommercialisation.iNumeroContrat:
            assign
                ttFicheCommercialisation.cNomMandant        = ctrat.lbnom
                ttFicheCommercialisation.cNomCompletMandant = ctrat.lnom2
            .
        end.
        for first gl_fiche_tiers no-lock
            where gl_fiche_tiers.nofiche     = ttFicheCommercialisation.iNumeroFiche
              and gl_fiche_tiers.nohisto     = 0
              and gl_fiche_tiers.tprolefiche = "00082":
           ttFicheCommercialisation.cNomCommercial = getNomTiersCommercialisation(gl_fiche_tiers.tptiers, gl_fiche_tiers.tprol, gl_fiche_tiers.norol,
                                                                                  gl_fiche_tiers.soccd, gl_fiche_tiers.four-cle).
        end.
        for first gl_sequence no-lock
            where gl_sequence.nofiche = ttFicheCommercialisation.iNumeroFiche
              and gl_sequence.nohisto = 0:
            ttFicheCommercialisation.daDateDispo = gl_sequence.dtdispo.
        end.
    end.
    vhquery:query-close() no-error.
    delete object vhquery no-error.
    delete object vhBuffer no-error.
    error-status:error = false no-error.   // reset error-status:error
    return.                                // reset return-value

end procedure.

procedure rechercheCommercialisation:
    /*------------------------------------------------------------------------------
    Purpose: Récupère les fiches Commercialisation
    Notes  : service utilisé par beCommercialisation.cls.
    ------------------------------------------------------------------------------*/
    define input  parameter poCollection as collection no-undo.
    define output parameter table for ttFicheCommercialisation.

    define variable vcWhereClause       as character no-undo.
    define variable viNumeroFiche       as integer   no-undo.
    define variable viNumeroMandat      as integer   no-undo.
    define variable viNombrePieceDeb    as integer   no-undo.
    define variable viNombrePieceFin    as integer   no-undo.
    define variable viNombrePhotoDeb    as integer   no-undo.
    define variable viNombrePhotoFin    as integer   no-undo.
    define variable viSurfaceDeb        as integer   no-undo.
    define variable viSurfaceFin        as integer   no-undo.
    define variable viNumeroImmeuble    as integer   no-undo.
    define variable vcServiceGestion    as character no-undo.
    define variable vcCodePostal        as character no-undo.
    define variable vcVille             as character no-undo.
    define variable vcCodeUsage         as character no-undo.
    define variable viJourVacantDeb     as integer   no-undo.
    define variable viJourVacantFin     as integer   no-undo.
    define variable vdLoyerDeb          as decimal   no-undo.
    define variable vdLoyerFin          as decimal   no-undo.
    define variable vcSiteWeb           as character no-undo.
    define variable vcWorkflow          as character no-undo.

    assign
        viNumeroFiche       = poCollection:getInteger("iNumeroFiche")
        viNumeroMandat      = poCollection:getInteger("iNumeroMandat")
        viNombrePieceDeb    = poCollection:getInteger("iNombrePieceDeb")
        viNombrePieceFin    = poCollection:getInteger("iNombrePieceFin")
        viNombrePhotoDeb    = poCollection:getInteger("iNombrePhotoDeb")
        viNombrePhotoFin    = poCollection:getInteger("iNombrePhotoFin")
        viSurfaceDeb        = poCollection:getInteger("iSurfaceDeb")
        viSurfaceFin        = poCollection:getInteger("iSurfaceFin")
        viNumeroImmeuble    = poCollection:getInteger("iNumeroImmeuble")
        vcServiceGestion    = poCollection:getCharacter("cServiceGestion")
        vcCodePostal        = poCollection:getCharacter("cCodePostal")
        vcVille             = poCollection:getCharacter("cVille")
        vcCodeUsage         = poCollection:getCharacter("cCodeUsage")
        viJourVacantDeb     = poCollection:getInteger("iJourVacantDeb")
        viJourVacantFin     = poCollection:getInteger("iJourVacantFin")
        vdLoyerDeb          = poCollection:getDecimal("dLoyerDeb")
        vdLoyerFin          = poCollection:getDecimal("dLoyerFin")
        vcSiteWeb           = poCollection:getCharacter("cSiteWeb")
        vcWorkflow          = poCollection:getCharacter("cWorkflow")
    .
    // attention, bien maîtriser l'usage du WHEN. Ici OK, on ne modifie pas les champs utilisés dans when.
    {&_proparse_ prolint-nowarn(when)}
    assign
        viNombrePieceDeb    = 0 when viNombrePieceDeb = ?
        viSurfaceDeb        = 0 when viSurfaceDeb = ?
        viJourVacantDeb     = 0 when viJourVacantDeb = ?
        vdLoyerDeb          = 0 when vdLoyerDeb = ?
        viNombrePieceFin    = viNombrePieceDeb when viNombrePieceFin = ?
        viSurfaceFin        = viSurfaceDeb when viSurfaceFin = ?
        viJourVacantFin     = 0 when viJourVacantFin = ?
        vdLoyerFin          = 0 when vdLoyerFin = ?
        vcCodePostal        = "" when vcCodePostal = ?
        vcVille             = "" when vcVille = ?
        vcServiceGestion    = "" when vcServiceGestion = ?
        vcWhereClause = trim(substitute('&1&2&3&4&5&6&7&8&9',
                                     if viNumeroFiche     <> ? then substitute('gl_fiche.nofiche >= &1 and gl_fiche.nofiche <= &2', trim(string(viNumeroFiche)), trim(string(viNumeroFiche))) else '',
                                     if viNumeroMandat    <> ? then substitute(' and gl_fiche.nocon >= &1 and gl_fiche.nocon <= &2', trim(string(viNumeroMandat)), trim(string(viNumeroMandat))) else '',
                                     if viNombrePieceDeb  > 0 then ' and gl_fiche.nbpiece >= ' + trim(string(viNombrePieceDeb)) else '',
                                     if viNombrePieceFin  > 0 then ' and gl_fiche.nbpiece <= ' + trim(string(viNombrePieceFin)) else '',
                                     if viNombrePhotoDeb  <> ? then ' and gl_fiche.nbphoto >= ' + trim(string(viNombrePhotoDeb)) else '',
                                     if viNombrePhotoFin  <> ? then ' and gl_fiche.nbphoto <= ' + trim(string(viNombrePhotoFin)) else '',
                                     if viSurfaceDeb      > 0 then ' and gl_fiche.surfhab >= ' + trim(string(viSurfaceDeb)) else '')
                                   + if viSurfaceFin      > 0 then ' and gl_fiche.surfhab <= ' + trim(string(viSurfaceFin)) else '',
                            'and ').
    .

message "a100 "  vcWhereClause.   

    if vcWhereClause > '' then vcWhereClause = 'where ' + vcWhereClause.
    run readListeFiche(vcWhereClause, vcSiteWeb, viNumeroImmeuble, vcServiceGestion, vcCodePostal, vcVille,
                       vcCodeUsage, viJourVacantDeb, viJourVacantFin, vdLoyerDeb, vdLoyerFin, vcWorkflow).
    error-status:error = false no-error.   // reset error-status:error
    return.                                // reset return-value
end procedure.

procedure readInfoFiche:
    /*------------------------------------------------------------------------------
    Purpose: Récupère les fiches Commercialisation
    Notes  : service utilisé par beCommercialisation.cls.
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroFiche as integer no-undo.
    define output parameter table for ttFicheCommercialisation.
    define output parameter table for ttHistoWorkflow.

    run readListeFiche('where gl_fiche.nofiche = ' + string(piNumeroFiche), "", ?, "", "", "", "", 0, 0, 0, 0, "").
    run readHistoMajWorkflow(input piNumeroFiche).

end procedure.

procedure readAdresseFiche:
    /*------------------------------------------------------------------------------
    Purpose: Renvoie l'adresse de la fiche de (re)location
    Notes  : service utilisé par beCommercialisation.cls.
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroFiche   as integer no-undo.
    define output parameter table for ttAdresse.

    define buffer gl_fiche for gl_fiche.
    define buffer unite    for unite.
    define buffer local    for local.
    define buffer ladrs    for ladrs.
    define buffer adres    for adres.

    empty temp-table ttAdresse.
    for first gl_fiche no-lock
        where gl_fiche.nofiche = piNumeroFiche
      , first unite no-lock
        where unite.nomdt = gl_fiche.nocon
          and unite.noapp = gl_fiche.noapp
          and unite.noact = 0
      , first local no-lock
        where local.noimm = unite.noimm
          and local.nolot = unite.nolot
      , first ladrs no-lock
        where ladrs.tpidt = {&TYPEBIEN-lot}
          and ladrs.noidt = local.noloc
          and ladrs.tpadr = {&TYPEADRESSE-Principale}
      , first adres no-lock
        where adres.noadr = ladrs.noadr:
        create ttAdresse.
        assign
            ttAdresse.CRUD                    = 'R'
            ttAdresse.iNumeroFiche            = piNumeroFiche
            ttAdresse.iTypeBranche            = 1
            ttAdresse.iNumeroLien             = ladrs.nolie
            ttAdresse.cCodeTypeAdresse        = ladrs.tpadr
            ttAdresse.cLibelleTypeAdresse     = outilTraduction:getLibelleParam("TPADR", ladrs.tpadr)
            ttAdresse.cCodeFormat             = ladrs.tpfrt
            ttAdresse.cLibelleFormat          = outilTraduction:getLibelleParam("FTADR", ladrs.tpfrt)
            ttAdresse.cIdentification         = adres.cpad2
            ttAdresse.cNumeroVoie             = trim(ladrs.novoi)
            ttAdresse.cCodeNumeroBis          = ladrs.cdadr
            ttAdresse.cLibelleNumeroBis       = outilTraduction:getLibelleParam("CDADR", ladrs.cdadr)
            ttAdresse.cLibelleNumeroBisCourt  = outilTraduction:getLibelleParam("CDADR", ladrs.cdadr, 'c')
            ttAdresse.cCodeNatureVoie         = adres.ntvoi
            ttAdresse.cLibelleNatureVoie      = if adres.ntvoi = {&NATUREVOIE--} then "" else outilTraduction:getLibelleParam("NTVOI", adres.ntvoi)
            ttAdresse.cLibelleNatureVoieCourt = if adres.ntvoi = {&NATUREVOIE--} then "" else outilTraduction:getLibelleParam("NTVOI", adres.ntvoi, 'c')
            //ttAdresse.cVoie1              = adres.lbvoi
            //ttAdresse.cVoie2              = ""
            //ttAdresse.cVoie3              = ""
            ttAdresse.cNomVoie                = adres.lbvoi
            ttAdresse.cComplementVoie         = adres.cpvoi
            ttAdresse.cCodePostal             = trim(adres.cdpos)
            ttAdresse.cBureauDistributeur     = adres.lbbur
            ttAdresse.cVille                  = trim(adres.lbvil)
            ttAdresse.cCodeINSEE              = adres.cdins
            ttAdresse.cCodePays               = adres.cdpay
            ttAdresse.cLibellePays            = outilTraduction:getLibelleParam("CDADR", ladrs.cdadr)
            ttAdresse.cLibelle                = outilFormatage:formatageAdresse(ladrs.tpidt, ladrs.noidt, ladrs.tpadr, mToken:iCodeLangueSession, mToken:iCodeLangueReference)
            ttAdresse.dtTimestampAdres        = datetime(adres.dtmsy, adres.hemsy)
            ttAdresse.dtTimestampLadrs        = datetime(ladrs.dtmsy, ladrs.hemsy)
            ttAdresse.rRowid                  = rowid(adres)
        .
    end.

end procedure.

procedure getAttributsDivers:
    /*------------------------------------------------------------------------------
    Purpose: Récupère la liste des attributs divers liés à une fiche de (re)location
    Notes  : service utilisé par beCommercialisation.cls.
             Paramètre des attributs divers : GLATB dans sys_pr
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroFiche as integer no-undo.
    define output parameter table for ttAttributsDivers.

    define buffer gl_fiche_attrcomm for gl_fiche_attrcomm.
    define buffer gl_fiche          for gl_fiche.

    empty temp-table ttAttributsDivers.
    for first gl_fiche no-lock
        where gl_fiche.nofiche = piNumeroFiche
      , each gl_fiche_attrcomm no-lock
        where gl_fiche_attrcomm.nofiche = gl_fiche.nofiche:
        create ttAttributsDivers.
        assign
            ttAttributsDivers.cCode    = string(gl_fiche_attrcomm.noattrcom, "99999")
            ttAttributsDivers.cLibelle = outilTraduction:getLibelleParam("GLATB", string(gl_fiche_attrcomm.noattrcom, "99999"))
        .
    end.

end procedure.

procedure getHistoriqueFiche:
    /*------------------------------------------------------------------------------
    Purpose: Récupère la liste de tous les historiques d'une fiche de (re)location
    Notes  : service utilisé par beCommercialisation.cls.
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroFiche as integer no-undo.
    define output parameter table for ttHistoriqueFiche.
    define output parameter table for ttSequence.
    define output parameter table for ttTiersCommercialisation.
    define output parameter table for ttLoyerCommercialisation.
    define output parameter table for ttDetailFinance.

    define buffer gl_fiche   for gl_fiche.
    define buffer gl_histo   for gl_histo.

    empty temp-table ttHistoriqueFiche.
    empty temp-table ttSequence.
    empty temp-table ttTiersCommercialisation.
    empty temp-table ttLoyerCommercialisation.
    empty temp-table ttDetailFinance.

    for first gl_fiche no-lock
        where gl_fiche.nofiche = piNumeroFiche
      , each gl_histo no-lock
        where gl_histo.nofiche = piNumeroFiche:
        create ttHistoriqueFiche.
        assign
            ttHistoriqueFiche.iNumeroHisto = (if gl_histo.nohisto = 0 then ? else gl_histo.nohisto)
            ttHistoriqueFiche.iNumeroFiche = piNumeroFiche
            ttHistoriqueFiche.CRUD         = 'R'
            ttHistoriqueFiche.dtTimestamp  = datetime(GL_histo.dtmsy, gl_histo.hemsy)
            ttHistoriqueFiche.rRowid       = rowid(GL_histo)
        .
        run getSequencePrivate(piNumeroFiche, gl_histo.nohisto).
        run readLoyerFicheCommercialisationPrivate(piNumeroFiche, gl_histo.nohisto).
    end.

end procedure.

procedure getSequence:
    /*------------------------------------------------------------------------------
    Purpose: Cette procédure est l'interface externe pour getSequencePrivate.
    Notes  : service utilisé par beCommercialisation.cls.
    -------------------------------------------------------------------l-----------*/
    define input  parameter piNumeroFiche as integer no-undo.
    define input  parameter piNumeroHisto as integer no-undo.
    define output parameter table for ttSequence.

    empty temp-table ttSequence.
    empty temp-table ttTiersCommercialisation.
    /* gga on vide la table ttTiersCommercialisation car utilise dans la procedure getSequencePrivate,
       mais pas necessaire de la retourner */
    run getSequencePrivate(piNumeroFiche, piNumeroHisto).
end procedure.

procedure getSequencePrivate private:
    /*------------------------------------------------------------------------------
    Purpose: Récupère l'historique et l'Encours de tout ce qui concerne une fiche de (re)location
    Notes  :
    -------------------------------------------------------------------l-----------*/
    define input  parameter piNumeroFiche as integer no-undo.
    define input  parameter piNumeroHisto as integer no-undo.

    define variable viLocataireFicheHisto as integer no-undo.
    define variable vhProcTiers           as handle  no-undo.

    define buffer gl_sequence for gl_sequence.
    define buffer gl_fiche    for gl_fiche.

    for first gl_sequence no-lock
        where gl_sequence.nofiche = piNumeroFiche
          and gl_sequence.nohisto = piNumeroHisto:
        create ttSequence.
        assign
            ttSequence.iNumeroFiche    = gl_sequence.nofiche
            ttSequence.iNumeroSequence = gl_sequence.nosequence
            ttSequence.iNumeroRang     = gl_sequence.norang
            ttSequence.iNumeroHisto    = (if piNumeroHisto = 0 then ? else gl_sequence.nohisto)
            ttSequence.daDateDispo     = gl_sequence.dtdispo
            ttSequence.daDateSortie    = gl_sequence.dtsortie
            ttSequence.daDateEntree    = gl_sequence.dtentree
            ttSequence.daDateConge     = gl_sequence.dtconge
            ttSequence.CRUD            = 'R'
            ttSequence.dtTimestamp     = datetime(gl_sequence.dtmsy, gl_sequence.hemsy)
            ttSequence.rRowid          = rowid(gl_sequence)
        .
        if piNumeroHisto > 0
        then do:
            find first gl_fiche no-lock
                where gl_fiche.nofiche = gl_sequence.nofiche no-error.
            if available gl_fiche
            then viLocataireFicheHisto = gl_fiche.nocon * 100000 + gl_fiche.noapp * 100 + gl_sequence.norang.
            if viLocataireFicheHisto > 0
            then do:
                run tiers/tiers.p persistent set vhProcTiers.
                run getTokenInstance     in vhProcTiers(mToken:JSessionId).
                run getTiersLocatairesUL in vhProcTiers (viLocataireFicheHisto, piNumeroHisto, piNumeroFiche,
                                                         output table ttTiersCommercialisation append).
                run destroy              in vhProcTiers.
            end.
        end.
    end.

end procedure.

procedure getHistoEncadrementLoyer:
    /*------------------------------------------------------------------------------
    Purpose: Récupère la liste des contrôles du Loyer historisés liés à une fiche de (re)location
    Notes  : Service externe
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroFiche as integer no-undo.
    define input  parameter prRowidGlHistoLoyer as rowid no-undo.
    define output parameter table for ttHistoEncadrementLoyer.

    run getHistoEncadrementLoyerPrivate(piNumeroFiche, prRowidGlHistoLoyer).

end procedure.

procedure getHistoEncadrementLoyerPrivate private:
    /*------------------------------------------------------------------------------
    Purpose: Récupère la liste des contrôles du Loyer historisés liés à une fiche de (re)location
    Notes  :
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroFiche       as integer no-undo.
    define input  parameter prRowidGlHistoLoyer as rowid   no-undo.

    define buffer gl_histo_loyer_ctrl for gl_histo_loyer_ctrl.

    empty temp-table ttHistoEncadrementLoyer.
    if piNumeroFiche = ?
    then for first gl_histo_loyer_ctrl no-lock
        where rowid(gl_histo_loyer_ctrl) = prRowidGlHistoLoyer:
        run createHistoEncadrementLoyer(buffer gl_histo_loyer_ctrl).
    end.
    else for each  gl_histo_loyer_ctrl no-lock
        where gl_histo_loyer_ctrl.nofiche = piNumeroFiche:
        run createHistoEncadrementLoyer(buffer gl_histo_loyer_ctrl).
    end.
end procedure.

procedure createHistoEncadrementLoyer private:
    /*------------------------------------------------------------------------------
    Purpose: Création d'un enregistrement ttHistoEncadrementLoyer
    Notes  :
    ------------------------------------------------------------------------------*/
    define parameter buffer gl_histo_loyer_ctrl for gl_histo_loyer_ctrl.

    create ttHistoEncadrementLoyer.
    assign
        ttHistoEncadrementLoyer.iNumeroHistoLoyerCtrl = gl_histo_loyer_ctrl.nohisto_loyer_ctrl
        ttHistoEncadrementLoyer.iNumeroFiche          = gl_histo_loyer_ctrl.nofiche
        ttHistoEncadrementLoyer.cAnneeConstruction    = gl_histo_loyer_ctrl.anneeconstruction
        ttHistoEncadrementLoyer.cAdresseEnvoye        = gl_histo_loyer_ctrl.adresse
        ttHistoEncadrementLoyer.iNombrePieces         = gl_histo_loyer_ctrl.nbpiece
        ttHistoEncadrementLoyer.lLocationMeuble       = gl_histo_loyer_ctrl.fgmeuble
        ttHistoEncadrementLoyer.dSurfaceHabitable     = gl_histo_loyer_ctrl.surface
        ttHistoEncadrementLoyer.dLoyerEnvoye          = gl_histo_loyer_ctrl.loyer
        ttHistoEncadrementLoyer.dLoyerM2Envoye        = gl_histo_loyer_ctrl.loyerfiche_m2
        ttHistoEncadrementLoyer.dLoyerM2Mediant       = gl_histo_loyer_ctrl.loyermediant
        ttHistoEncadrementLoyer.dLoyerM2Minore        = gl_histo_loyer_ctrl.loyerminore
        ttHistoEncadrementLoyer.dLoyerM2Majore        = gl_histo_loyer_ctrl.loyermajore
        ttHistoEncadrementLoyer.cCodeRetour           = gl_histo_loyer_ctrl.coderetour
        ttHistoEncadrementLoyer.cMessageRetour        = gl_histo_loyer_ctrl.messageretour
        ttHistoEncadrementLoyer.cCodeStatutCalcul     = gl_histo_loyer_ctrl.status_calcul
        ttHistoEncadrementLoyer.dtHorodatageCalcul    = gl_histo_loyer_ctrl.horodatage_calcul
        ttHistoEncadrementLoyer.CRUD                  = 'R'
        ttHistoEncadrementLoyer.dtTimestamp           = datetime(gl_histo_loyer_ctrl.dtmsy, gl_histo_loyer_ctrl.hemsy)
        ttHistoEncadrementLoyer.rRowid                = rowid(gl_histo_loyer_ctrl)
    .
end procedure.

procedure getLibelleCommercialisation:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par beCommercialisation.cls.
    ------------------------------------------------------------------------------*/
    define input parameter piTypeLibelle as integer no-undo.
    define output parameter table for ttLibelle.

    define buffer gl_libelle for gl_libelle.

    empty temp-table ttLibelle.
    for each gl_libelle no-lock
        where gl_libelle.tpidt = piTypeLibelle:
        create ttLibelle.
        assign
            ttLibelle.CRUD          = 'R'
            ttLibelle.iNoLibelle    = gl_libelle.nolibelle
            ttLibelle.iTypeLibelle  = gl_libelle.tpidt
            ttLibelle.iNoMes        = gl_libelle.nomes
            ttLibelle.cLibelleLibre = gl_libelle.libellelibre
            ttlibelle.cLibelleStd   = if gl_libelle.nomes <> 0 then outilTraduction:getLibelle(string(gl_libelle.nomes)) else ""
            ttLibelle.iNoOrdre      = gl_libelle.noordre
            ttLibelle.iNoIdt        = gl_libelle.noidt
            ttLibelle.dtTimestamp   = datetime(gl_libelle.dtmsy, gl_libelle.hemsy)
        .
    end.

end procedure.

procedure getProximite:
    /*------------------------------------------------------------------------------
    Purpose: Récupère la liste des proximités liés à une fiche de (re)location
    Notes  : service utilisé par beCommercialisation.cls.
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroFiche as integer no-undo.
    define output parameter table for ttProximite.

    define buffer gl_fiche_proximite for gl_fiche_proximite.
    define buffer gl_proximite       for gl_proximite.
    define buffer gl_libelle         for gl_libelle.
    define buffer gl_fiche           for gl_fiche.

    empty temp-table ttProximite.
    for first gl_fiche no-lock
        where gl_fiche.nofiche = piNumeroFiche
      , each  gl_fiche_proximite no-lock
        where gl_fiche_proximite.nofiche = gl_fiche.nofiche
      , each  gl_proximite no-lock
        where gl_proximite.noproximite = gl_fiche_proximite.noproximite
      , first gl_libelle no-lock
        where gl_libelle.nolibelle = gl_proximite.nomes:
        create ttProximite.
        assign
            ttProximite.CRUD                  = 'R'
            ttProximite.iNumeroProximite      = gl_proximite.noproximite
            ttProximite.iNumeroFiche          = gl_fiche_proximite.nofiche
            ttProximite.iTypeProximite        = gl_proximite.tpproximite
            ttProximite.cCodeTypeProximite    = string(gl_proximite.tpproximite, '99999')
            ttProximite.cLibelleTypeProximite = outilTraduction:getLibelleParam("GLPRO", ttProximite.cCodeTypeProximite)   /* exemple : "Transport (s)"  */
            ttProximite.iNumeroLibelle        = gl_proximite.nomes
            ttProximite.cLibelleProximite     = gl_libelle.libelleLibre
            ttProximite.dtTimestamp           = datetime(gl_fiche_proximite.dtmsy, gl_fiche_proximite.hemsy)
        .
    end.

end procedure.

procedure getsiteweb:
    /*------------------------------------------------------------------------------
    Purpose: Récupère la liste des site web liés à une fiche de (re)location
    Notes  : service utilisé par beCommercialisation.cls.
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroFiche as integer no-undo.
    define output parameter table for ttSiteWebFiche.

    define buffer gl_fiche_siteweb for gl_fiche_siteweb.
    define buffer gl_siteweb       for gl_siteweb.
    define buffer gl_fiche         for gl_fiche.

    empty temp-table ttSiteWebFiche.
    for first gl_fiche no-lock
        where gl_fiche.nofiche = piNumeroFiche
      , each gl_fiche_siteweb no-lock
        where gl_fiche_siteweb.nofiche = gl_fiche.nofiche
      , first gl_siteweb no-lock
        where gl_siteweb.nositeweb = gl_fiche_siteweb.nositeweb:
        create ttSiteWebFiche.
        assign
            ttSiteWebFiche.cCode    = string(gl_siteweb.nositeweb)
            ttSiteWebFiche.cLibelle = gl_siteweb.nom
        .
    end.

end procedure.

procedure getMandatCommercialisation:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par beCommercialisation.cls.
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroFiche   as integer   no-undo.
    define output parameter table for ttMandat.

    define variable vhProcMandat as handle no-undo.
    define buffer gl_fiche for gl_fiche.

    empty temp-table ttMandat.
    /*--> Mandat de commercialisation */
    for first gl_fiche no-lock
        where gl_fiche.nofiche = piNumeroFiche:
        run "mandat/mandat.p" persistent set vhProcMandat.
        run getTokenInstance in vhProcMandat(mToken:JSessionId).
        run getMandat in vhProcMandat (gl_fiche.tpcon, gl_fiche.nocon, output table ttMandat by-reference).
        run destroy in vhProcMandat.
    end.

end procedure.

procedure readDepotFicheCommercialisation:
    /*------------------------------------------------------------------------------
    purpose: procedure basé sur le fait qu'il ne peut y avoir qu'un seul gl_depot
             par fiche (et avec gl_depot sans gl_detailfinance)
    Note   : service utilisé par beCommercialisation.cls.
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroFiche as integer   no-undo.
    define output parameter table for ttDepotCommercialisation.
    define output parameter table for ttDetailFinance.

    define buffer gl_fiche         for gl_fiche.
    define buffer gl_finance       for gl_finance.
    define buffer gl_detailfinance for gl_detailfinance.
    define buffer gl_depot         for gl_depot.

    empty temp-table ttDepotCommercialisation.
    empty temp-table ttDetailFinance.
    for first gl_fiche no-lock
        where gl_fiche.nofiche = piNumeroFiche
      , each gl_finance no-lock
        where gl_finance.nofiche = gl_fiche.nofiche
          and gl_finance.nohisto = 0
          and gl_finance.tpfinance = {&TYPEFINANCE-DEPOT}
      , first gl_depot no-lock
        where gl_depot.nofinance = gl_finance.nofinance:
        create ttDepotCommercialisation.
        assign
            ttDepotCommercialisation.iNumeroDepot          = gl_depot.nodepot
            ttDepotCommercialisation.iNumeroElementFinance = gl_depot.nofinance
            ttDepotCommercialisation.iNumeroFiche          = piNumeroFiche
            ttDepotCommercialisation.iTypeDepot            = gl_depot.tpdepot
            ttDepotCommercialisation.iNombre2Mois          = gl_depot.nbloyer
            ttDepotCommercialisation.dMontantTotalHT       = gl_depot.totalht
            ttDepotCommercialisation.dMontantTotalTTC      = gl_depot.totalttc
            ttDepotCommercialisation.dtTimestamp           = datetime(GL_depot.dtmsy, gl_depot.hemsy)
            ttDepotCommercialisation.CRUD                  = 'R'
            ttDepotCommercialisation.rRowid                = rowid(GL_depot)
        .
        for each gl_detailfinance no-lock
            where gl_detailfinance.nofinance = GL_FINANCE.nofinance:
            create ttDetailFinance.
            assign
                ttDetailFinance.iNumeroFiche          = piNumeroFiche
                ttDetailFinance.iNumeroDetailFinance  = gl_detailfinance.nodetailfinance
                ttDetailFinance.iNumeroElementFinance = gl_detailfinance.nofinance
                ttDetailFinance.iNumeroChampFinance   = gl_detailfinance.nochpfinance
                ttDetailFinance.iCodeTva              = gl_detailfinance.notaxe
                ttDetailFinance.dMontantHT            = gl_detailfinance.montantht
                ttDetailFinance.dMontantTaxe          = gl_detailfinance.montanttaxe
                ttDetailFinance.dMontantTTC           = gl_detailfinance.montantttc
                ttDetailFinance.dMontantHTprorata     = 0    /*gga todo pourquoi 0 au lieu des infos de la table */
                ttDetailFinance.dMontantTaxeprorata   = 0    /*gga todo pourquoi 0 au lieu des infos de la table */
                ttDetailFinance.dMontantTTCProrata    = 0    /*gga todo pourquoi 0 au lieu des infos de la table */
                ttDetailFinance.dtTimestamp           = datetime(gl_detailfinance.dtmsy, gl_detailfinance.hemsy)
                ttDetailFinance.CRUD                  = 'R'
                ttDetailFinance.rRowid                = rowid(gl_detailfinance)
            .
        end.
    end.

end procedure.

procedure readLoyerFicheCommercialisation:
    /*------------------------------------------------------------------------------
    purpose: Cette procédure est l'interface externe pour readLoyerFicheCommercialisationPrivate.
    Note   : service utilisé par beCommercialisation.cls.
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroFiche   as integer   no-undo.
    define input  parameter piNumeroHisto   as integer   no-undo.
    define output parameter table for ttLoyerCommercialisation.
    define output parameter table for ttDetailFinance.

    empty temp-table ttLoyerCommercialisation.
    empty temp-table ttDetailFinance.
    run readLoyerFicheCommercialisationPrivate(piNumeroFiche, piNumeroHisto).

end procedure.

procedure readLoyerFicheCommercialisationPrivate private:
    /*------------------------------------------------------------------------------
    purpose: Bloc 1ère quittance - éléments de loyer
    Note   : procedure basé sur le fait qu'il ne peut y avoir qu'un seul gl_loyer
             par fiche (et avec gl_loyer sans gl_detailfinance)
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroFiche   as integer   no-undo.
    define input  parameter piNumeroHisto   as integer   no-undo.

    define buffer gl_fiche          for gl_fiche.
    define buffer gl_finance        for gl_finance.
    define buffer gl_detailfinance  for gl_detailfinance.
    define buffer gl_Loyer          for gl_Loyer.

    for first gl_fiche no-lock
        where gl_fiche.nofiche = piNumeroFiche
      , each gl_finance no-lock
        where gl_finance.nofiche = gl_fiche.nofiche
          and gl_finance.nohisto = piNumeroHisto
          and gl_finance.tpfinance = {&TYPEFINANCE-LOYER}
      , first gl_loyer no-lock
        where gl_loyer.nofinance = GL_FINANCE.nofinance:
        create ttLoyerCommercialisation.
        assign
            ttLoyerCommercialisation.iNumeroLoyer               = gl_loyer.noLoyer
            ttLoyerCommercialisation.iNumeroElementFinance      = gl_loyer.nofinance
            ttLoyerCommercialisation.iNumeroFiche               = piNumeroFiche
            ttLoyerCommercialisation.iTypeLoyer                 = gl_loyer.tpLoyer
            ttLoyerCommercialisation.iPeriodiciteLoyer          = gl_loyer.noperio
            ttLoyerCommercialisation.iEcheanceLoyer             = gl_loyer.noecheance
            ttLoyerCommercialisation.iIndiceRevision            = gl_loyer.noindice
            // informations indice saisies dans la fiche
            ttLoyerCommercialisation.dValeurIndice              = gl_loyer.indice_rev
            ttLoyerCommercialisation.cLibelleCompletIndice      = gl_loyer.lbindice_rev
            ttLoyerCommercialisation.daDateIndiceRevision       = gl_loyer.dtindice_rev
            ttLoyerCommercialisation.dValeurIndiceConnu         = gl_loyer.indice_connu
            ttLoyerCommercialisation.cLibelleCompletIndiceConnu = gl_loyer.lbindice_connu
            ttLoyerCommercialisation.dMontantHorsChargeHT       = gl_loyer.loyerhc_ht
            ttLoyerCommercialisation.dMontantHorsChargeTTC      = gl_loyer.loyerhc_ttc
            ttLoyerCommercialisation.dMontantChargeHT           = gl_loyer.charge_ht
            ttLoyerCommercialisation.dMontantChargeTTC          = gl_loyer.charge_ttc
            ttLoyerCommercialisation.daDateEntree               = gl_loyer.dtdeb_quit
            ttLoyerCommercialisation.dMontantTotalHT            = gl_loyer.totalht
            ttLoyerCommercialisation.dMontantTotalTTC           = gl_loyer.totalttc
            ttLoyerCommercialisation.dMontantTotalHTProrata     = gl_loyer.totalht_pro
            ttLoyerCommercialisation.dMontantTotalTTCProrata    = gl_loyer.totalttc_pro
            ttLoyerCommercialisation.dMontantTotalAnnuelHT      = gl_loyer.loyercc_annuel
            ttLoyerCommercialisation.dtTimestamp                = datetime(gl_loyer.dtmsy, gl_loyer.hemsy)
            ttLoyerCommercialisation.CRUD                       = 'R'
            ttLoyerCommercialisation.iNumeroHisto               = gl_finance.nohisto
            ttLoyerCommercialisation.cLibelleCourtIndice = getLibelleIndice (ttLoyerCommercialisation.iIndiceRevision)
        .
        for each gl_detailfinance no-lock
            where gl_detailfinance.nofinance = gl_finance.nofinance:
            create ttDetailFinance.
            assign
                ttDetailFinance.iNumeroDetailFinance  = gl_detailfinance.nodetailfinance
                ttDetailFinance.iNumeroFiche          = piNumeroFiche
                ttDetailFinance.iNumeroElementFinance = gl_detailfinance.nofinance
                ttDetailFinance.iNumeroChampFinance   = gl_detailfinance.nochpfinance
                ttDetailFinance.iCodeTva              = gl_detailfinance.notaxe
                ttDetailFinance.dMontantHT            = gl_detailfinance.montantht
                ttDetailFinance.dMontantTaxe          = gl_detailfinance.montanttaxe
                ttDetailFinance.dMontantTTC           = gl_detailfinance.montantttc
                ttDetailFinance.dMontantHTprorata     = gl_detailfinance.montantht_pro
                ttDetailFinance.dMontantTaxeprorata   = gl_detailfinance.montanttaxe_pro
                ttDetailFinance.dMontantTTCProrata    = gl_detailfinance.montantttc_pro
                ttDetailFinance.dtTimestamp           = datetime(gl_detailfinance.dtmsy, gl_detailfinance.hemsy)
                ttDetailFinance.CRUD                  = 'R'
                ttDetailFinance.rRowid                = rowid(gl_detailfinance)
            .
        end.
    end.

end procedure.

procedure readHonoraireFicheCommercialisation:
    /*------------------------------------------------------------------------------
    purpose: procedure basé sur le fait qu'il ne peut y avoir qu'un seul gl_honoraire
             par fiche (et avec gl_honoraire sans gl_detailfinance)
    Note   : service utilisé par beCommercialisation.cls.
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroFiche   as integer   no-undo.
    define output parameter table for ttHonoraireCommercialisation.
    define output parameter table for ttDetailFinance.

    define buffer gl_fiche          for gl_fiche.
    define buffer gl_finance        for gl_finance.
    define buffer gl_detailfinance  for gl_detailfinance.
    define buffer gl_honoraire      for gl_honoraire.

    empty temp-table ttHonoraireCommercialisation.
    empty temp-table ttDetailFinance.
    for first gl_fiche no-lock
        where gl_fiche.nofiche = piNumeroFiche
      , each gl_finance no-lock
        where gl_finance.nofiche   = gl_fiche.nofiche
          and gl_finance.nohisto   = 0
          and gl_finance.tpfinance = {&TYPEFINANCE-HONORAIRE}
      , first gl_honoraire no-lock
        where gl_honoraire.nofinance = gl_finance.nofinance:
        create ttHonoraireCommercialisation.
        assign
            ttHonoraireCommercialisation.iNumeroHonoraire      = gl_honoraire.noHonoraire
            ttHonoraireCommercialisation.iNumeroElementFinance = gl_honoraire.nofinance
            ttHonoraireCommercialisation.iNumeroFiche          = piNumeroFiche
            ttHonoraireCommercialisation.iTypeHonoraire1       = gl_honoraire.tpHonoraire1
            ttHonoraireCommercialisation.iTypeHonoraire2       = gl_honoraire.tpHonoraire2
            ttHonoraireCommercialisation.iNumeroBareme         = gl_honoraire.nobareme
            ttHonoraireCommercialisation.dMontantTotalHT       = gl_honoraire.totalht
            ttHonoraireCommercialisation.dMontantTotalTTC      = gl_honoraire.totalttc
            ttHonoraireCommercialisation.dtTimestamp           = datetime(gl_honoraire.dtmsy, gl_honoraire.hemsy)
            ttHonoraireCommercialisation.CRUD                  = 'R'
        .
        for each gl_detailfinance no-lock
            where gl_detailfinance.nofinance = gl_finance.nofinance:
            create ttDetailFinance.
            assign
                ttDetailFinance.iNumeroDetailFinance   = gl_detailfinance.nodetailfinance
                ttDetailFinance.iNumeroFiche           = piNumeroFiche
                ttDetailFinance.iNumeroElementFinance  = gl_detailfinance.nofinance
                ttDetailFinance.iNumeroChampFinance    = gl_detailfinance.nochpfinance
                ttDetailFinance.iCodeTva               = gl_detailfinance.notaxe
                ttDetailFinance.dMontantHT             = gl_detailfinance.montantht
                ttDetailFinance.dMontantTaxe           = gl_detailfinance.montanttaxe
                ttDetailFinance.dMontantTTC            = gl_detailfinance.montantttc
                ttDetailFinance.dMontantHTprorata      = 0    /*gga todo pourquoi 0 au lieu des infos de la table */
                ttDetailFinance.dMontantTaxeprorata    = 0    /*gga todo pourquoi 0 au lieu des infos de la table */
                ttDetailFinance.dMontantTTCProrata     = 0    /*gga todo pourquoi 0 au lieu des infos de la table */
                ttDetailFinance.dtTimestamp            = datetime(gl_detailfinance.dtmsy, gl_detailfinance.hemsy)
                ttDetailFinance.CRUD                   = 'R'
                ttDetailFinance.rRowid                 = rowid(gl_detailfinance)
            .
        end.
    end.

end procedure.

procedure readBareme:
    /*------------------------------------------------------------------------------
    purpose:
    Note   : service utilisé par beCommercialisation.cls.
    ------------------------------------------------------------------------------*/
    define output parameter table for ttBaremeHonoraireComm.
    define output parameter table for ttCalculBareme.

    define variable vhTva as handle no-undo.

    define buffer gl_bareme         for gl_bareme.
    define buffer gl_calcul_bareme  for gl_calcul_bareme.

    empty temp-table ttBaremeHonoraireComm.
    empty temp-table ttCalculBareme.
    run compta/outilsTVA.p persistent set vhTva.
    run getTokenInstance in vhTva(mToken:JSessionId).
    {&_proparse_ prolint-nowarn(wholeindex)}
    for each gl_bareme no-lock:
        create ttBaremeHonoraireComm.
        assign
            ttBaremeHonoraireComm.iNumeroBareme   = gl_bareme.nobareme
            ttBaremeHonoraireComm.iTypeHonoraire2 = gl_bareme.tphonoraire2
            ttBaremeHonoraireComm.cNomBareme      = gl_bareme.nom
            ttBaremeHonoraireComm.dtTimestamp     = datetime(gl_bareme.dtmsy, gl_bareme.hemsy)
            ttBaremeHonoraireComm.CRUD            = "R"
            ttBaremeHonoraireComm.rRowid          = rowid(gl_bareme).
        .
        for each gl_calcul_bareme no-lock
            where gl_calcul_bareme.nobareme = gl_bareme.nobareme:
            create ttCalculBareme.
            assign
                ttCalculBareme.iNumeroCalculBareme     = gl_calcul_bareme.nocalcul_bareme
                ttCalculBareme.iNumeroBareme           = gl_calcul_bareme.nobareme
                ttCalculBareme.iNumeroZoneALUR         = gl_calcul_bareme.NoZoneAlur
                ttCalculBareme.iCodeTVA                = gl_calcul_bareme.notaxe
                ttCalculBareme.dTauxTVA                = dynamic-function("getTauxTva" in vhTva, gl_calcul_bareme.notaxe)
                ttCalculBareme.iNumeroChampFinance     = gl_calcul_bareme.nochpfinance
                ttCalculBareme.lLocationMeuble         = gl_calcul_bareme.fgmeuble
                ttCalculBareme.cCalculBaremeHT         = gl_calcul_bareme.baremeht
                ttCalculBareme.cCalculBaremeTTC        = gl_calcul_bareme.baremettc
                ttCalculBareme.cCalculBaremeMiniHT     = gl_calcul_bareme.baremeht_min
                ttCalculBareme.cCalculBaremeMiniTTC    = gl_calcul_bareme.baremettc_min
                ttCalculBareme.cCalculBaremeMaxiHT     = gl_calcul_bareme.baremeht_max
                ttCalculBareme.cCalculBaremeMaxiTTC    = gl_calcul_bareme.baremettc_max
                ttCalculBareme.cTypeCalcul             = gl_calcul_bareme.typcalcul
                ttCalculBareme.dtTimestamp             = datetime(gl_calcul_bareme.dtmsy, gl_calcul_bareme.hemsy)
                ttCalculBareme.CRUD                    = "R"
            .
        end.
    end.
    run destroy in vhTva.

end procedure.

procedure readSiteWeb:
    /*------------------------------------------------------------------------------
    purpose: extraction infos site web
    Note   : service utilisé par beCommercialisation.cls.
    ------------------------------------------------------------------------------*/
    define output parameter table for ttSiteWeb.

    define buffer gl_siteweb for gl_siteweb.

    empty temp-table ttsiteweb.
    {&_proparse_ prolint-nowarn(wholeindex)}
    for each gl_siteweb no-lock:
        create ttsiteweb.
        assign
            ttsiteweb.iNumerositeweb        = gl_siteweb.nositeweb
            ttsiteweb.lActif                = gl_siteweb.fgpublier
            ttsiteweb.cIdentifiantAgence    = gl_siteweb.identifiant
            ttsiteweb.cCorrespondance       = gl_siteweb.correspondance
            ttsiteweb.cfiltreChamps         = gl_siteweb.filtre_champ
            ttsiteweb.cCsvNom               = gl_siteweb.csvnom
            ttsiteweb.cCsvDelimiter         = gl_siteweb.csvdelimiter
            ttsiteweb.cZipNom               = gl_siteweb.zipnom
            ttsiteweb.cTabComplement        = gl_siteweb.tabcomplement
            ttsiteweb.lEnvoiUniqueFiche     = gl_siteweb.fgsend_unique
            ttsiteweb.cUrlExportUnique      = gl_siteweb.urlscript
            ttsiteweb.iIdMessageUpd         = gl_siteweb.nomes_upd
            ttsiteweb.cParamFTP             = gl_siteweb.tabftp
            ttsiteweb.cIdentifiantFiche     = gl_siteweb.identifiantfiche
            ttsiteweb.cColonnePhoto         = gl_siteweb.colphoto
            ttsiteweb.cRepertoireCourantFTP = gl_siteweb.ftpcurdir
            ttsiteweb.cCheminLogo           = gl_siteweb.cheminlogo
            ttsiteweb.cNomSiteWeb           = gl_siteweb.nom
            ttsiteweb.CRUD                  = 'R'
            ttsiteweb.dtTimestamp           = datetime(gl_siteweb.dtmsy, gl_siteweb.hemsy)
            ttsiteweb.rRowid                = rowid(gl_siteweb)
        .
    end.

end procedure.

procedure MajFichierSiteWeb:
    /*------------------------------------------------------------------------------
    purpose: maj de la liste des photos a ne pas publier par site web
    Note   : service utilisé par beCommercialisation.cls.
    ------------------------------------------------------------------------------*/
    define input-output parameter table for ttFichierSiteWeb.

    define variable viI            as integer   no-undo.
    define variable vcSiteParPhoto as character no-undo.

    define buffer gl_siteweb_tbfic for gl_siteweb_tbfic.

    for each ttFichierSiteWeb:
        vcSiteParPhoto = "".
        do viI = 1 to extent(ttFichierSiteWeb.cNumerositeweb):
            if ttFichierSiteWeb.cNumerositeweb[viI] > ""
            then do:
                vcSiteParPhoto = vcSiteParPhoto + ttFichierSiteWeb.cNumerositeweb[viI] + ",".
                if not can-find (first gl_siteweb_tbfic no-lock
                                 where gl_siteweb_tbfic.noidt = ttFichierSiteWeb.iIdFichier
                                   and gl_siteweb_tbfic.nositeweb = integer(ttFichierSiteWeb.cNumerositeweb[viI]))
                then do:
                    create gl_siteweb_tbfic.
                    assign
                        gl_siteweb_tbfic.noidt     = ttFichierSiteWeb.iIdFichier
                        gl_siteweb_tbfic.nositeweb = integer(ttFichierSiteWeb.cNumerositeweb[viI])
                        gl_siteweb_tbfic.dtcsy     = today
                        gl_siteweb_tbfic.hecsy     = mtime
                        gl_siteweb_tbfic.cdcsy     = mToken:cUser
                        gl_siteweb_tbfic.dtmsy     = gl_siteweb_tbfic.dtcsy
                        gl_siteweb_tbfic.hemsy     = gl_siteweb_tbfic.hecsy
                        gl_siteweb_tbfic.cdmsy     = mToken:cUser
                    .
                end.
            end.
        end.

        /* difficile cote client de gérer la suppression, donc ici ajout d'une boucle pour voir si il existe des enregistrements
        pour la photo dont le siteweb n'est pas dans la zone ttFichierSiteWeb.cNumerositeweb de la table */
        /* attention cela veut dire aussi que si il y a suppression pour une photo de tous les sites web associes il faut recevoir
        un enregistrement pour cette photo avec la zone ttFichierSiteWeb.cNumerositeweb vide */

message "aaaaaaaaaaaaaa " ttFichierSiteWeb.iIdFichier vcSiteParPhoto.

        // TODO : whole index !!!
        for each gl_siteweb_tbfic exclusive-lock
            where gl_siteweb_tbfic.noidt = ttFichierSiteWeb.iIdFichier:
            if lookup(string(gl_siteweb_tbfic.nositeweb), vcSiteParPhoto) = 0
            then delete gl_siteweb_tbfic.
        end.
    end.

end procedure.

procedure readFichierSiteWeb:
    /*------------------------------------------------------------------------------
    purpose: extraction table des fichiers a ne pas publier par site web
    Note   : service utilisé par beCommercialisation.cls.
    ------------------------------------------------------------------------------*/
    define input parameter pcListePhoto as character no-undo.
    define output parameter table for ttFichierSiteWeb.

    define variable viI as integer no-undo.

    define buffer gl_siteweb_tbfic for gl_siteweb_tbfic.

    empty temp-table ttFichierSiteWeb.
    if num-entries(pcListePhoto) > 0
    then do viI = 1 to num-entries(pcListePhoto):
        // TODO : whole index !!!
        for each gl_siteweb_tbfic no-lock
            where gl_siteweb_tbfic.noidt = integer(entry(viI, pcListePhoto)):
            run creationTtFichierSiteWeb (buffer gl_siteweb_tbfic).
        end.
    end.
    else for each gl_siteweb_tbfic no-lock:
        run creationTtFichierSiteWeb (buffer gl_siteweb_tbfic).
    end.

end procedure.

procedure creationTtFichierSiteWeb private:
    /*------------------------------------------------------------------------------
    purpose: creation table ttfchiersiteweb
    Note   :
    ------------------------------------------------------------------------------*/
    define parameter buffer gl_siteweb_tbfic for gl_siteweb_tbfic.

    find first ttFichierSiteWeb
        where ttFichierSiteWeb.iIdFichier = gl_siteweb_tbfic.noidt no-error.
    if not available ttFichierSiteWeb
    then do:
        create ttFichierSiteWeb.
        assign
            ttFichierSiteWeb.iIdFichier = gl_siteweb_tbfic.noidt
            ttFichierSiteWeb.iNbSiteWeb = 0
        .
    end.
    assign
        ttFichierSiteWeb.iNbSiteWeb = ttFichierSiteWeb.iNbSiteWeb + 1
        ttFichierSiteWeb.cNumerositeweb[ttFichierSiteWeb.iNbSiteWeb] = string(gl_siteweb_tbfic.nositeweb)
    .
end procedure.


/*
procedure readFichierSiteWeb:
    /*------------------------------------------------------------------------------
    purpose: extraction table des fichiers a ne pas publier par site web
    Note   : service utilisé par beCommercialisation.cls.
    ------------------------------------------------------------------------------*/
    define input parameter pcListePhoto as character no-undo.
    define output parameter table for ttFichierSiteWeb.

    define variable viI as integer no-undo.

    define buffer gl_siteweb_tbfic for gl_siteweb_tbfic.

    empty temp-table ttFichierSiteWeb.

    if num-entries(pcListePhoto) > 0
    then do viI = 1 to num-entries(pcListePhoto):

        for each gl_siteweb_tbfic no-lock
        where gl_siteweb_tbfic.noidt = integer(entry(viI,pcListePhoto)):

            run creationTtFichierSiteWeb (buffer gl_siteweb_tbfic).

        end.

    end.
    else do:

        for each gl_siteweb_tbfic no-lock:

            run creationTtFichierSiteWeb (buffer gl_siteweb_tbfic).

        end.

    end.

    for each ttFichierSiteWeb:

        ttFichierSiteWeb.cNumerositeweb = '[' + ttFichierSiteWeb.cNumerositeweb + ']'.

    end.

end procedure.

procedure creationTtFichierSiteWeb private:
    /*------------------------------------------------------------------------------
    purpose: creation table ttfchiersiteweb
    Note   :
    ------------------------------------------------------------------------------*/
    define parameter buffer gl_siteweb_tbfic for gl_siteweb_tbfic.

    find first ttFichierSiteWeb
    where ttFichierSiteWeb.iIdFichier = gl_siteweb_tbfic.noidt no-error.
    if not available ttFichierSiteWeb
    then do:

        create ttFichierSiteWeb.
        ttFichierSiteWeb.iIdFichier = gl_siteweb_tbfic.noidt.

    end.

    if ttFichierSiteWeb.cNumerositeweb > ""
    then ttFichierSiteWeb.cNumerositeweb = substitute('&1,&2',ttFichierSiteWeb.cNumerositeweb,string(gl_siteweb_tbfic.nositeweb)).
    else ttFichierSiteWeb.cNumerositeweb = string(gl_siteweb_tbfic.nositeweb).

end procedure.

procedure MajFichierSiteWeb:
    /*------------------------------------------------------------------------------
    purpose: maj de la liste des photos a ne pas publier par site web
    Note   : service utilisé par beCommercialisation.cls.
    ------------------------------------------------------------------------------*/
    define input-output parameter table for ttFichierSiteWeb.

    define variable viI as integer no-undo.

    define buffer gl_siteweb_tbfic for gl_siteweb_tbfic.

    for each ttFichierSiteWeb:

        if ttFichierSiteWeb.cNumerositeweb > ''
        then assign
                 ttFichierSiteWeb.cNumerositeweb = replace(ttFichierSiteWeb.cNumerositeweb, '[', '')
                 ttFichierSiteWeb.cNumerositeweb = replace(ttFichierSiteWeb.cNumerositeweb, ']', '')
             .

        if num-entries(ttFichierSiteWeb.cNumerositeweb) > 0
        then do viI = 1 to num-entries(ttFichierSiteWeb.cNumerositeweb):

            if not can-find (first gl_siteweb_tbfic no-lock
                             where gl_siteweb_tbfic.noidt = ttFichierSiteWeb.iIdFichier
                             and gl_siteweb_tbfic.nositeweb = integer(entry(viI,ttFichierSiteWeb.cNumerositeweb)))
            then do:
                create gl_siteweb_tbfic.
                assign
                    gl_siteweb_tbfic.noidt     = ttFichierSiteWeb.iIdFichier
                    gl_siteweb_tbfic.nositeweb = integer(entry(viI,ttFichierSiteWeb.cNumerositeweb))
                    gl_siteweb_tbfic.dtcsy     = today
                    gl_siteweb_tbfic.hecsy     = mtime
                    gl_siteweb_tbfic.cdcsy     = mToken:cUser
                    gl_siteweb_tbfic.dtmsy     = gl_siteweb_tbfic.dtcsy
                    gl_siteweb_tbfic.hemsy     = gl_siteweb_tbfic.hecsy
                    gl_siteweb_tbfic.cdmsy     = mToken:cUser
                .
            end.

        end.

        /* difficile cote client de gérer la suppression, donc ici ajout d'une boucle pour voir si il existe des enregistrements
        pour la photo dont le siteweb n'est pas dans la zone ttFichierSiteWeb.cNumerositeweb de la table */
        /* attention cela veut dire aussi que si il y a suppression pour une photo de tous les sites web associes il faut recevoir
        un enregistrement pour cette photo avec la zone ttFichierSiteWeb.cNumerositeweb vide */
        for each gl_siteweb_tbfic exclusive-lock
        where gl_siteweb_tbfic.noidt = ttFichierSiteWeb.iIdFichier:
            if lookup(string(gl_siteweb_tbfic.nositeweb),ttFichierSiteWeb.cNumerositeweb) = 0
            then do:
                delete gl_siteweb_tbfic.
            end.

        end.

    end.

end procedure.
*/

procedure createFamilleDepotFicheCommercialisation:
    /*------------------------------------------------------------------------------
    purpose: création d'une famille "dépot de garantie" de la gestion financière
    Note   : service utilisé par beCommercialisation.cls.
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroFiche as integer no-undo.
    define output parameter table for ttDepotCommercialisation.
    define output parameter table for ttDetailFinance.

    define buffer gl_depot   for gl_depot.
    define buffer gl_finance for gl_finance.

    empty temp-table ttDepotCommercialisation.
    empty temp-table ttDetailFinance.
    if piNumeroFiche = 0
    or not can-find(first gl_fiche no-lock where gl_fiche.nofiche = piNumeroFiche)
    then do:
        mError:createError({&error}, 1000226, string(piNumeroFiche)).   // Fiche location no &1 inexistante
        return.
    end.

    /* gga todo a confirmer, 1 seul enregistrement depot par fiche */
    /* cas ou gl_finance type depot existe sans gl_depot en principe impossible */
    for first gl_finance no-lock
        where gl_finance.nofiche   = piNumeroFiche
          and gl_finance.nohisto   = 0
          and gl_finance.tpfinance = {&TYPEFINANCE-DEPOT}
      , first gl_depot no-lock
        where gl_depot.nofinance = gl_finance.nofinance:
        /* creation interdite, depot &1 deja existant cette fiche */
        mError:createError({&error}, 1000286, string(gl_depot.nodepot)).
        return.
    end.
    create gl_finance.
    assign
        gl_finance.nofinance = igetNextSequence('gl_finance', 'nofinance')
        gl_finance.tpfinance = {&TYPEFINANCE-DEPOT}
        gl_finance.nofiche   = piNumeroFiche
        gl_finance.nohisto   = 0
        gl_finance.dtcsy     = today
        gl_finance.hecsy     = mtime
        gl_finance.cdcsy     = mToken:cUser
        gl_finance.dtmsy     = today
        gl_finance.hemsy     = mtime
        gl_finance.cdmsy     = mToken:cUser
    .
    create gl_depot.
    assign
        gl_depot.nodepot   = igetNextSequence('gl_depot', 'nodepot')
        gl_depot.nofinance = gl_finance.nofinance
        gl_depot.tpdepot   = 0
        gl_depot.dtcsy     = today
        gl_depot.hecsy     = mtime
        gl_depot.cdcsy     = mToken:cUser
        gl_depot.dtmsy     = today
        gl_depot.hemsy     = mtime
        gl_depot.cdmsy     = mToken:cUser
    .
    /* création enregistrement vide avec seulement les no identifiants */
    create ttDepotCommercialisation.
    assign
        ttDepotCommercialisation.iNumeroDepot          = gl_depot.nodepot
        ttDepotCommercialisation.iNumeroElementFinance = gl_depot.nofinance
        ttDepotCommercialisation.iNumeroFiche          = piNumeroFiche
        ttDepotCommercialisation.dtTimestamp           = datetime(gl_depot.dtmsy, gl_depot.hemsy)
        ttDepotCommercialisation.CRUD                  = 'R'
        ttDepotCommercialisation.rRowid                = rowid(GL_depot)
    .
end procedure.

procedure createFamilleLoyerFicheCommercialisation:
    /*------------------------------------------------------------------------------
    purpose: création d'une famille "loyer" de la gestion financière
    Note   : service utilisé par beCommercialisation.cls.
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroFiche as integer no-undo.
    define output parameter table for ttLoyerCommercialisation.
    define output parameter table for ttDetailFinance.

    define buffer gl_loyer   for gl_loyer.
    define buffer gl_finance for gl_finance.

    empty temp-table ttLoyerCommercialisation.
    empty temp-table ttDetailFinance.
    if piNumeroFiche = 0
    or not can-find(first gl_fiche no-lock where gl_fiche.nofiche = piNumeroFiche)
    then do:
        mError:createError({&error}, 1000226, string(piNumeroFiche)).   // Fiche location no &1 inexistante
        return.
    end.

    /* gga todo a confirmer, 1 seul enregistrement loyer par fiche */
    /* cas ou gl_finance type loyer existe sans gl_loyer en principe impossible */
    for first gl_finance no-lock
        where gl_finance.nofiche   = piNumeroFiche
          and gl_finance.nohisto   = 0
          and gl_finance.tpfinance = {&TYPEFINANCE-LOYER}
      , first gl_loyer no-lock
        where gl_loyer.nofinance = gl_finance.nofinance:
        /* creation interdite, loyer &1 deja existant cette fiche */
        mError:createError({&error}, 1000281, string(gl_loyer.noloyer)).
        return.
    end.

    create gl_finance.
    assign
        gl_finance.nofinance = igetNextSequence('gl_finance', 'nofinance')
        gl_finance.tpfinance = {&TYPEFINANCE-LOYER}
        gl_finance.nofiche   = piNumeroFiche
        gl_finance.nohisto   = 0
        gl_finance.dtcsy     = today
        gl_finance.hecsy     = mtime
        gl_finance.cdcsy     = mToken:cUser
        gl_finance.dtmsy     = today
        gl_finance.hemsy     = mtime
        gl_finance.cdmsy     = mToken:cUser
    .
    create gl_loyer.
    assign
        gl_loyer.noloyer   = igetNextSequence('gl_loyer', 'noloyer')
        gl_loyer.nofinance = gl_finance.nofinance
        gl_loyer.tployer   = 0
        gl_loyer.dtcsy     = today
        gl_loyer.hecsy     = mtime
        gl_loyer.cdcsy     = mToken:cUser
        gl_loyer.dtmsy     = today
        gl_loyer.hemsy     = mtime
        gl_loyer.cdmsy     = mToken:cUser
    .
    /* création enregistrement vide avec seulement les no identifiants */
    create ttLoyerCommercialisation.
    assign
        ttLoyerCommercialisation.iNumeroLoyer          = gl_loyer.noloyer
        ttLoyerCommercialisation.iNumeroElementFinance = gl_loyer.nofinance
        ttLoyerCommercialisation.iNumeroFiche          = piNumeroFiche
        ttLoyerCommercialisation.iNumeroHisto          = 0
        ttLoyerCommercialisation.dtTimestamp           = datetime(gl_loyer.dtmsy, gl_loyer.hemsy)
        ttLoyerCommercialisation.CRUD                  = 'R'
    .
end procedure.

procedure createFamilleHonoraireFicheCommercialisation:
    /*------------------------------------------------------------------------------
    purpose: création d'une ligne détail pour la famille "honoraire" de la gestion financière
    Note   : service utilisé par beCommercialisation.cls.
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroFiche    as integer no-undo.
    define input  parameter piTypeHonoraire1 as integer no-undo.
    define input  parameter piTypeHonoraire2 as integer no-undo.
    define output parameter table for ttHonoraireCommercialisation.
    define output parameter table for ttDetailFinance.

    define variable vhProc  as handle    no-undo.

    define buffer gl_fiche     for gl_fiche.
    define buffer gl_finance   for gl_finance.
    define buffer gl_honoraire for gl_honoraire.

    empty temp-table ttHonoraireCommercialisation.
    empty temp-table ttDetailFinance.
    if piNumeroFiche = 0
    or not can-find(first gl_fiche no-lock where gl_fiche.nofiche = piNumeroFiche)
    then do:
        mError:createError({&error}, 1000226, string(piNumeroFiche)).   // Fiche location no &1 inexistante
        return.
    end.

    /* chargement combo type honoraire pour controle de ces types (la creation de ces parametres est en dur
    donc pour eviter de faire des test sur des zones en dur, chargement de la combo */
    run application/libelle/labelLadb.p persistent set vhProc.
    run getTokenInstance in vhProc (mToken:JSessionId).
    run getCombolabel in vhProc ("CMBTYPEHONORAIRE1,CMBTYPEHONORAIRE2", output table ttcombo by-reference).
    run destroy in vhProc.

    if not can-find (first ttcombo
                     where ttcombo.cNomCombo = "CMBTYPEHONORAIRE1"
                     and ttcombo.cCode = string(piTypeHonoraire1, "99999"))
    then do:
        /* type honoraire &1 n'est pas un honoraire de type 1 */
        mError:createError({&error}, 1000306, string(piTypeHonoraire1, "99999")).
        return.
    end.
    if not can-find (first ttcombo
                     where ttcombo.cNomCombo = "CMBTYPEHONORAIRE2"
                     and ttcombo.cCode = string(piTypeHonoraire2, "99999"))
    then do:
        /* type honoraire &1 n'est pas un honoraire de type 2 */
        mError:createError({&error}, 1000307, string(piTypeHonoraire2, "99999")).
        return.
    end.

    /* on peut avoir plusieurs honoraires par fiche, mais pour 1 seul type d'honoraire 1 */
    /* cas ou gl_finance type honoraire existe sans gl_honoraire en principe impossible */
    for each gl_finance no-lock
        where gl_finance.nofiche   = piNumeroFiche
          and gl_finance.nohisto   = 0
          and gl_finance.tpfinance = {&TYPEFINANCE-HONORAIRE}
      , first gl_honoraire no-lock
        where gl_honoraire.nofinance = gl_finance.nofinance:
        if gl_honoraire.tpHonoraire1 <> piTypeHonoraire1
        then do:
            /* creation interdite, honoraire type &1 deja existant cette fiche */
            mError:createError({&error}, 1000305, string(gl_honoraire.nohonoraire)).
            return.
        end.
        if gl_honoraire.tpHonoraire1 = piTypeHonoraire1
        and gl_honoraire.tpHonoraire2 = piTypeHonoraire2
        then do:
            /* creation interdite, honoraire &1 deja existant cette fiche */
            mError:createError({&error}, 1000291, string(gl_honoraire.nohonoraire)).
            return.
        end.
    end.

    create gl_finance.
    assign
        gl_finance.nofinance = igetNextSequence('gl_finance', 'nofinance')
        gl_finance.tpfinance = {&TYPEFINANCE-HONORAIRE}
        gl_finance.nofiche   = piNumeroFiche
        gl_finance.nohisto   = 0
        gl_finance.dtcsy     = today
        gl_finance.hecsy     = mtime
        gl_finance.cdcsy     = mToken:cUser
        gl_finance.dtmsy     = today
        gl_finance.hemsy     = mtime
        gl_finance.cdmsy     = mToken:cUser
    .
    create gl_honoraire.
    assign
        gl_honoraire.nohonoraire  = igetNextSequence('gl_honoraire', 'nohonoraire')
        gl_honoraire.nofinance    = gl_finance.nofinance
        gl_honoraire.tpHonoraire1 = piTypeHonoraire1
        gl_honoraire.tpHonoraire2 = piTypeHonoraire2
        gl_honoraire.dtcsy        = today
        gl_honoraire.hecsy        = mtime
        gl_honoraire.cdcsy        = mToken:cUser
        gl_honoraire.dtmsy        = today
        gl_honoraire.hemsy        = mtime
        gl_honoraire.cdmsy        = mToken:cUser
    .
    /* création enregistrement vide avec seulement les no identifiants */
    create ttHonoraireCommercialisation.
    assign
        ttHonoraireCommercialisation.iNumeroHonoraire      = gl_honoraire.nohonoraire
        ttHonoraireCommercialisation.iNumeroElementFinance = gl_honoraire.nofinance
        ttHonoraireCommercialisation.iTypeHonoraire1       = gl_honoraire.tpHonoraire1
        ttHonoraireCommercialisation.iTypeHonoraire2       = gl_honoraire.tpHonoraire2
        ttHonoraireCommercialisation.iNumeroFiche          = piNumeroFiche
        ttHonoraireCommercialisation.dtTimestamp           = datetime(gl_honoraire.dtmsy, gl_honoraire.hemsy)
        ttHonoraireCommercialisation.CRUD                  = 'R'
    .
end procedure.

procedure createDetailFinancierFicheCommercialisation private:
    /*------------------------------------------------------------------------------
    purpose: création d'une ligne détail pour la famille "dépot de garantie" de la gestion financière
    Note   :
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroElementFinance as integer no-undo.
    define output parameter piNumeroDetailFinance  as integer no-undo.

    define buffer gl_detailfinance for gl_detailfinance.

    if piNumeroElementFinance = 0
    or not can-find (first gl_finance no-lock
                     where gl_finance.nofinance = piNumeroElementFinance) then return.

    /* création enregistrement vide avec seulement les no identifiants */
    create gl_detailfinance.
    assign
        gl_detailfinance.nodetailfinance = igetNextSequence('gl_detailfinance', 'nodetailfinance')
        gl_detailfinance.nofinance       = piNumeroElementFinance
        gl_detailfinance.nochpfinance    = 0
        gl_detailfinance.dtcsy           = today
        gl_detailfinance.hecsy           = mtime
        gl_detailfinance.cdcsy           = mToken:cUser
        gl_detailfinance.dtmsy           = today
        gl_detailfinance.hemsy           = mtime
        gl_detailfinance.cdmsy           = mToken:cUser
        piNumeroDetailFinance            = gl_detailfinance.nodetailfinance
    .
end procedure.

procedure setDepotFicheCommercialisation:
    /*------------------------------------------------------------------------------
    purpose: mise à jour de l'ensemble des éléments financiers pour la famille dépot de garantie
    Note   : service utilisé par beCommercialisation.cls.
    ------------------------------------------------------------------------------*/
    define input parameter table for ttDepotCommercialisation.
    define input parameter table for ttDetailFinance.

    define variable vdMontantHTTotal  as decimal no-undo.
    define variable vdMontantTTCTotal as decimal no-undo.

    define buffer gl_depot         for gl_depot.
    define buffer gl_finance       for gl_finance.
    define buffer gl_detailfinance for gl_detailfinance.

    find first ttDepotCommercialisation
        where lookup(ttDepotCommercialisation.CRUD, "U,D") > 0 no-error.
    if not available ttDepotCommercialisation then return.

    if not can-find(first gl_depot no-lock
                    where gl_depot.nodepot   = ttDepotCommercialisation.iNumerodepot
                      and gl_depot.nofinance = ttDepotCommercialisation.iNumeroElementFinance)
    then do:
        /* numero de dépot inexistant */
        mError:createError({&error}, 1000288).
        return.
    end.

    for each ttDetailFinance
        where ttDetailFinance.iNumeroElementFinance = ttDepotCommercialisation.iNumeroElementFinance
          and ttDetailFinance.crud = 'D':
        find first gl_detailfinance exclusive-lock
            where gl_detailfinance.nodetailfinance = ttDetailFinance.iNumeroDetailFinance no-wait no-error.
        if outils:isUpdated(buffer gl_detailfinance:handle, 'gl_detailfinance avec nodetailfinance', string(ttDetailFinance.iNumeroDetailFinance), ttDetailFinance.dtTimestamp)
        then return.

        delete gl_detailfinance.
    end.

    for each ttDetailFinance
        where ttDetailFinance.iNumeroElementFinance = ttDepotCommercialisation.iNumeroElementFinance
          and ttDetailFinance.crud = 'U':
        if not champFinanceExiste(ttDetailFinance.iNumeroChampFinance, {&TYPEFINANCE-DEPOT}) then return.

        find first gl_detailfinance exclusive-lock
            where gl_detailfinance.nodetailfinance = ttDetailFinance.iNumeroDetailFinance no-wait no-error.
        if outils:isUpdated(buffer gl_detailfinance:handle, 'gl_detailfinance avec nodetailfinance', string(ttDetailFinance.iNumeroDetailFinance), ttDetailFinance.dtTimestamp)
        or not outils:copyValidField(buffer gl_detailfinance:handle, buffer ttDetailFinance:handle, 'U', mtoken:cUser)
        then return.
    end.

    for first ttDetailFinance
        where ttDetailFinance.iNumeroElementFinance = ttDepotCommercialisation.iNumeroElementFinance
          and ttDetailFinance.crud                  = 'C'
          and ttDetailFinance.iNumeroDetailFinance <> 0:
        mError:createError({&error}, 1000287).
    end.
    for each ttDetailFinance
        where ttDetailFinance.iNumeroElementFinance = ttDepotCommercialisation.iNumeroElementFinance
          and ttDetailFinance.crud                  = 'C'
          and ttDetailFinance.iNumeroDetailFinance  = 0:  /*gga ajout de ce test, si non comme c'est un index de la temp table boucle car valeur change en creation */

        if not champFinanceExiste(ttDetailFinance.iNumeroChampFinance, {&TYPEFINANCE-DEPOT})
        or champFinanceDouble(ttDetailFinance.iNumeroElementFinance, ttDetailFinance.iNumeroChampFinance) then return.

        run createDetailFinancierFicheCommercialisation (ttDetailFinance.iNumeroElementFinance, output ttDetailFinance.iNumeroDetailFinance).
        if ttDetailFinance.iNumeroDetailFinance = 0 then return.

        for first gl_detailfinance exclusive-lock
            where gl_detailfinance.nodetailfinance = ttDetailFinance.iNumeroDetailFinance:
            if not outils:copyValidField(buffer gl_detailfinance:handle, buffer ttDetailFinance:handle, 'U', mtoken:cUser)
            then return.
        end.
    end.

    for each gl_detailfinance no-lock
        where gl_detailfinance.nofinance = ttDepotCommercialisation.iNumeroElementFinance:
        assign
            vdMontantHTTotal  = vdMontantHTTotal  + gl_detailfinance.montantht
            vdMontantTTCTotal = vdMontantTTCTotal + gl_detailfinance.montantttc
        .
    end.

if vdMontantHTTotal <> ttDepotCommercialisation.dMontantTotalHT
then message "cumul HT des détails dépot (" vdMontantHTTotal ") différent du cumul écran (" ttDepotCommercialisation.dMontantTotalHT ") pour la fiche no " ttDepotCommercialisation.iNumeroFiche.
if vdMontantTTCTotal <> ttDepotCommercialisation.dMontantTotalTTC
then message "cumul TTC des détails dépot (" vdMontantTTCTotal ") différent du cumul écran (" ttDepotCommercialisation.dMontantTotalTTC ") pour la fiche no " ttDepotCommercialisation.iNumeroFiche.

    find first gl_depot exclusive-lock
        where gl_depot.nodepot = ttDepotCommercialisation.iNumerodepot no-wait no-error.
    if outils:isUpdated(buffer gl_depot:handle, 'gl_depot avec nodepot ', string(ttDepotCommercialisation.iNumerodepot), ttDepotCommercialisation.dtTimestamp)
    then return.

    if ttDepotCommercialisation.CRUD = "U"
    then do:
        if not outils:copyValidField(buffer gl_depot:handle, buffer ttDepotCommercialisation:handle, 'U', mtoken:cUser)
        then return.

        assign
            gl_depot.totalht  = vdMontantHTTotal
            gl_depot.totalttc = vdMontantTTCTotal
        .
    end.
    else do:
        /* avant de supprimer gl_depot, suppression des gl_detail_finance associés */
        for each gl_detailfinance exclusive-lock
            where gl_detailfinance.nofinance = ttDepotCommercialisation.iNumeroElementFinance:
            delete gl_detailfinance.
        end.
        /* avant de supprimer gl_depot, suppression du gl_finance associé */
        for first gl_finance exclusive-lock
        where gl_finance.nofinance = ttDepotCommercialisation.iNumeroElementFinance:
            delete gl_finance.
        end.
        delete gl_depot.
    end.

end procedure.

procedure setLoyerFicheCommercialisation:
    /*------------------------------------------------------------------------------
    purpose: mise à jour de l'ensemble des éléments financiers pour la famille loyer
    Note   : service utilisé par beCommercialisation.cls.
    ------------------------------------------------------------------------------*/
    define input parameter table for ttLoyerCommercialisation.
    define input parameter table for ttDetailFinance.

    define variable vdMontantHTTotal  as decimal no-undo.
    define variable vdMontantTTCTotal as decimal no-undo.

    define buffer gl_detailfinance for gl_detailfinance.
    define buffer gl_loyer         for gl_loyer.
    define buffer gl_finance       for gl_finance.

    find first ttLoyerCommercialisation
        where lookup(ttLoyerCommercialisation.CRUD, "U,D") > 0 no-error.
    if not available ttLoyerCommercialisation then return.

    find first gl_loyer no-lock
        where gl_loyer.noloyer = ttLoyerCommercialisation.iNumeroloyer
          and gl_loyer.nofinance = ttLoyerCommercialisation.iNumeroElementFinance no-error.
    if not available gl_loyer
    then do:
        /* numero de loyer inexistant */
        mError:createError({&error}, 1000289).
        return.
    end.

    for each ttDetailFinance
        where ttDetailFinance.iNumeroElementFinance = ttLoyerCommercialisation.iNumeroElementFinance
          and ttDetailFinance.crud                  = 'D':
        find first gl_detailfinance exclusive-lock
            where gl_detailfinance.nodetailfinance = ttDetailFinance.iNumeroDetailFinance no-wait no-error.
        if outils:isUpdated(buffer gl_detailfinance:handle, 'gl_detailfinance avec nodetailfinance', string(ttDetailFinance.iNumeroDetailFinance), ttDetailFinance.dtTimestamp)
        then return.

        delete gl_detailfinance.
    end.

    for each ttDetailFinance
        where ttDetailFinance.iNumeroElementFinance = ttLoyerCommercialisation.iNumeroElementFinance
          and ttDetailFinance.crud = 'U':
        if not champFinanceExiste(ttDetailFinance.iNumeroChampFinance, {&TYPEFINANCE-LOYER}) then return.

        find first gl_detailfinance exclusive-lock
            where gl_detailfinance.nodetailfinance = ttDetailFinance.iNumeroDetailFinance no-wait no-error.
        if outils:isUpdated(buffer gl_detailfinance:handle, 'gl_detailfinance avec nodetailfinance', string(ttDetailFinance.iNumeroDetailFinance), ttDetailFinance.dtTimestamp)
        or not outils:copyValidField(buffer gl_detailfinance:handle, buffer ttDetailFinance:handle, 'U', mtoken:cUser)
        then return.
    end.

    for first ttDetailFinance
        where ttDetailFinance.iNumeroElementFinance = ttLoyerCommercialisation.iNumeroElementFinance
          and ttDetailFinance.crud                  = 'C'
          and ttDetailFinance.iNumeroDetailFinance <> 0:
        mError:createError({&error}, 1000287).
        return.
    end.
    for each ttDetailFinance
        where ttDetailFinance.iNumeroElementFinance = ttLoyerCommercialisation.iNumeroElementFinance
          and ttDetailFinance.crud                  = 'C'
          and ttDetailFinance.iNumeroDetailFinance  = 0:
        if not champFinanceExiste(ttDetailFinance.iNumeroChampFinance, {&TYPEFINANCE-LOYER})
        or champFinanceDouble (ttDetailFinance.iNumeroElementFinance, ttDetailFinance.iNumeroChampFinance) then return.

        run createDetailFinancierFicheCommercialisation (ttDetailFinance.iNumeroElementFinance, output ttDetailFinance.iNumeroDetailFinance).
        if ttDetailFinance.iNumeroDetailFinance = 0 then return.

        for first gl_detailfinance exclusive-lock
            where gl_detailfinance.nodetailfinance = ttDetailFinance.iNumeroDetailFinance:
            if not outils:copyValidField(buffer gl_detailfinance:handle, buffer ttDetailFinance:handle, 'U', mtoken:cUser)
            then return.
        end.
    end.

/*gga todo pour ce test (et idem pour honoraire et depot) a voir si boucle sur la table ou la temp table si tout est retourne. dans les
2 cas le resultat devrait etre le meme */
    for each gl_detailfinance no-lock
        where gl_detailfinance.nofinance = ttLoyerCommercialisation.iNumeroElementFinance:
        assign
            vdMontantHTTotal  = vdMontantHTTotal  + gl_detailfinance.montantht
            vdMontantTTCTotal = vdMontantTTCTotal + gl_detailfinance.montantttc
        .
    end.

if vdMontantHTTotal <> ttloyerCommercialisation.dMontantTotalHT
then message "cumul HT des détails loyer (" vdMontantHTTotal ") différent du cumul écran (" ttLoyerCommercialisation.dMontantTotalHT ") pour la fiche no " ttLoyerCommercialisation.iNumeroFiche.
if vdMontantTTCTotal <> ttloyerCommercialisation.dMontantTotalTTC
then message "cumul TTC des détails loyer (" vdMontantTTCTotal ") différent du cumul écran (" ttLoyerCommercialisation.dMontantTotalTTC ") pour la fiche no " ttLoyerCommercialisation.iNumeroFiche.

    find first gl_loyer exclusive-lock
        where gl_loyer.noloyer = ttLoyerCommercialisation.iNumeroloyer no-wait no-error.
    if outils:isUpdated(buffer gl_loyer:handle, 'gl_loyer avec noloyer ', string(ttLoyerCommercialisation.iNumeroloyer), ttLoyerCommercialisation.dtTimestamp)
    then return.

    if ttLoyerCommercialisation.CRUD = "U"
    then do:
        if outils:copyValidField(buffer gl_loyer:handle, buffer ttLoyerCommercialisation:handle, 'U', mtoken:cUser)
        then assign
            gl_loyer.totalht  = vdMontantHTTotal
            gl_loyer.totalttc = vdMontantTTCTotal
        .
    end.
    else do:
        /* avant de supprimer gl_loyer, suppression des gl_detail_finance associés */
        for each gl_detailfinance exclusive-lock
            where gl_detailfinance.nofinance = ttLoyerCommercialisation.iNumeroElementFinance:
            delete gl_detailfinance.
        end.
        /* avant de supprimer gl_loyer, suppression du gl_finance associé */
        for first gl_finance exclusive-lock
        where gl_finance.nofinance = ttLoyerCommercialisation.iNumeroElementFinance:
            delete gl_finance.
        end.
        delete gl_loyer.
    end.

end procedure.

procedure setHonoraireFicheCommercialisation:
    /*------------------------------------------------------------------------------
    purpose: mise à jour de l'ensemble des éléments financiers pour la famille honoraires
    Note   : service utilisé par beCommercialisation.cls.
    ------------------------------------------------------------------------------*/
    define input parameter table for ttHonoraireCommercialisation.
    define input parameter table for ttDetailFinance.

    define variable vdMontantHTTotal  as decimal no-undo.
    define variable vdMontantTTCTotal as decimal no-undo.

    define buffer gl_detailfinance for gl_detailfinance.
    define buffer gl_Honoraire     for gl_Honoraire.
    define buffer gl_finance       for gl_finance.

    for each ttHonoraireCommercialisation
        where lookup(ttHonoraireCommercialisation.CRUD, "U,D") > 0:

        find first gl_honoraire no-lock
            where gl_honoraire.noHonoraire = ttHonoraireCommercialisation.iNumeroHonoraire
              and gl_honoraire.nofinance   = ttHonoraireCommercialisation.iNumeroElementFinance no-error.
        if not available gl_honoraire
        then do:
            mError:createError({&error}, 1000290).    /* numero d'honoraire inexistant */
            return.
        end.

        for each ttDetailFinance
            where ttDetailFinance.iNumeroElementFinance = ttHonoraireCommercialisation.iNumeroElementFinance
              and ttDetailFinance.crud                  = 'D':
            find first gl_detailfinance exclusive-lock
                where gl_detailfinance.nodetailfinance = ttDetailFinance.iNumeroDetailFinance no-wait no-error.
            if outils:isUpdated(buffer gl_detailfinance:handle, 'gl_detailfinance avec nodetailhonoraire', string(ttDetailFinance.iNumeroDetailFinance), ttDetailFinance.dtTimestamp)
            then return.

            delete gl_detailfinance.
        end.

        for each ttDetailFinance
            where ttDetailFinance.iNumeroElementFinance = ttHonoraireCommercialisation.iNumeroElementFinance
              and ttDetailFinance.crud = 'U':
            if not champFinanceExiste(ttDetailFinance.iNumeroChampFinance, {&TYPEFINANCE-HONORAIRE}) then return.

            find first gl_detailfinance exclusive-lock
                where gl_detailfinance.nodetailfinance = ttDetailFinance.iNumeroDetailFinance no-wait no-error.
            if outils:isUpdated(buffer gl_detailfinance:handle, 'gl_detailfinance avec nodetailhonoraire', string(ttDetailFinance.iNumeroDetailFinance), ttDetailFinance.dtTimestamp)
            or not outils:copyValidField(buffer gl_detailfinance:handle, buffer ttDetailFinance:handle, 'U', mtoken:cUser)
            then return.
        end.

        for first ttDetailFinance
            where ttDetailFinance.iNumeroElementFinance = ttHonoraireCommercialisation.iNumeroElementFinance
              and ttDetailFinance.crud                  = 'C'
              and ttDetailFinance.iNumeroDetailFinance <> 0:
            mError:createError({&error}, 1000287).
            return.
        end.
        for each ttDetailFinance
            where ttDetailFinance.iNumeroElementFinance = ttHonoraireCommercialisation.iNumeroElementFinance
              and ttDetailFinance.crud                  = 'C'
              and ttDetailFinance.iNumeroDetailFinance  = 0:
            if not champFinanceExiste(ttDetailFinance.iNumeroChampFinance, {&TYPEFINANCE-HONORAIRE})
            or champFinanceDouble (ttDetailFinance.iNumeroElementFinance, ttDetailFinance.iNumeroChampFinance) then return.

            run createDetailFinancierFicheCommercialisation (ttDetailFinance.iNumeroElementFinance, output ttDetailFinance.iNumeroDetailFinance).
            if ttDetailFinance.iNumeroDetailFinance = 0 then return.

            for first gl_detailfinance exclusive-lock
                where gl_detailfinance.nodetailfinance = ttDetailFinance.iNumeroDetailFinance:
                if not outils:copyValidField(buffer gl_detailfinance:handle, buffer ttDetailFinance:handle, 'U', mtoken:cUser)
                then return.
            end.
        end.

        for each gl_detailfinance no-lock
            where gl_detailfinance.nofinance = ttHonoraireCommercialisation.iNumeroElementFinance:
            assign
                vdMontantHTTotal  = vdMontantHTTotal  + gl_detailfinance.montantht
                vdMontantTTCTotal = vdMontantTTCTotal + gl_detailfinance.montantttc
            .
        end.

        /* todo : supprimer les messages !!! */
        if vdMontantHTTotal <> ttHonoraireCommercialisation.dMontantTotalHT
        then message "cumul HT des détails Honoraire (" vdMontantHTTotal ") différent du cumul écran (" ttHonoraireCommercialisation.dMontantTotalHT ") pour la fiche no " ttHonoraireCommercialisation.iNumeroFiche.
        if vdMontantTTCTotal <> ttHonoraireCommercialisation.dMontantTotalTTC
        then message "cumul TTC des détails Honoraire (" vdMontantTTCTotal ") différent du cumul écran (" ttHonoraireCommercialisation.dMontantTotalTTC ") pour la fiche no " ttHonoraireCommercialisation.iNumeroFiche.

        find first gl_honoraire exclusive-lock
            where gl_honoraire.nohonoraire = tthonoraireCommercialisation.iNumerohonoraire no-wait no-error.
        if outils:isUpdated(buffer gl_honoraire:handle, 'gl_honoraire avec nohonoraire ', string(tthonoraireCommercialisation.iNumerohonoraire), tthonoraireCommercialisation.dtTimestamp)
        then return.

        if tthonoraireCommercialisation.CRUD = "U"
        then do:
            if outils:copyValidField(buffer gl_honoraire:handle, buffer tthonoraireCommercialisation:handle, 'U', mtoken:cUser)
            then assign
                gl_honoraire.totalht  = vdMontantHTTotal
                gl_honoraire.totalttc = vdMontantTTCTotal
            .
        end.
        else do:
            /* avant de supprimer gl_honoraire, suppression des gl_detail_finance associés */
            for each gl_detailfinance exclusive-lock
                where gl_detailfinance.nofinance = tthonoraireCommercialisation.iNumeroElementFinance:
                delete gl_detailfinance.
            end.
            /* avant de supprimer gl_honoraire, suppression du gl_finance associé */
            for first gl_finance exclusive-lock
            where gl_finance.nofinance = tthonoraireCommercialisation.iNumeroElementFinance:
                delete gl_finance.
            end.
            delete gl_honoraire.
        end.
    end.

end procedure.

procedure setcaracteristiqueproximite:
    /*------------------------------------------------------------------------------
    purpose: mise à jour infos proximite
    Note   : service utilisé par beCommercialisation.cls.
    ------------------------------------------------------------------------------*/
    define input parameter table for ttProximite.

    define variable viNoFiche as integer no-undo.

    define buffer gl_libelle         for gl_libelle.
    define buffer gl_proximite       for gl_proximite.
    define buffer gl_fiche_proximite for gl_fiche_proximite.

    find first ttProximite where ttProximite.CRUD <> "R" no-error.
    if not available ttProximite or not ficheExiste(ttProximite.iNumeroFiche) then return.

    viNoFiche = ttProximite.iNumeroFiche.
    for each ttProximite
        where lookup(ttProximite.CRUD, "C,D") > 0:
        if ttProximite.CRUD = "C"
        then do:
            if ttProximite.iNumeroProximite <> 0
            then do:
                find first gl_proximite no-lock
                    where gl_proximite.noproximite = ttProximite.iNumeroProximite no-error.
                if not available gl_proximite
                then do:
                    /* numéro de proximité &1 inexistant */
                    mError:createError({&error}, 1000268, string(ttProximite.iNumeroProximite)).
                    return.
                end.
                if ttProximite.iNumeroLibelle <> 0
                and gl_proximite.nomes <> ttProximite.iNumeroLibelle
                then do:
                    /* proximité &1 déjà existante avec numéro de libellé &2 différent */
                    mError:createError({&error}, 1000269, substitute('&2&1&3&1&4', separ[1],
                                                                                   string(ttProximite.iNumeroProximite),
                                                                                   string(gl_proximite.nomes),
                                                                                   "",
                                                                                   "")).
                    return.
                end.
                /* proximité &1 déjà existante avec type de proximité &2 différent */
                if gl_proximite.tpproximite <> ttProximite.iTypeProximite
                then mError:createError({&error}, 1000270, substitute('&2&1&3&1&4', separ[1], ttProximite.iNumeroProximite, gl_proximite.tpproximite, "", "")).
            end.
            else if ttProximite.iNumeroProximite = 0
            then do:
                /* libellé obligatoire pour création proximité */
                if ttProximite.cLibelleProximite = "" or ttProximite.cLibelleProximite = ?
                then do:
                    mError:createError({&error}, 1000271).
                    return.
                end.
                for first gl_libelle no-lock
                    where gl_libelle.tpidt        = {&TYPLIBELLE-proximite}
                      and gl_libelle.libelleLibre = ttProximite.cLibelleProximite:
                    mError:createError({&error}, 999999).   /* gga todo a voir si dans ce cas on recherche la proximite a partir du libelle ou si retour errreur libelle deja existant */
                    return.
                end.
                /* numero de libelle non renseigne et pas trouve de libelle alors creation de ce libelle */
                create gl_libelle.
                assign
                    gl_libelle.nolibelle    = igetNextSequence ("gl_libelle", "nolibelle")
                    gl_libelle.dtcsy        = today
                    gl_libelle.hecsy        = mtime
                    gl_libelle.cdcsy        = mToken:cUser
                    gl_libelle.dtmsy        = today
                    gl_libelle.hemsy        = mtime
                    gl_libelle.cdmsy        = mToken:cUser
                    gl_libelle.tpidt        = {&TYPLIBELLE-proximite}
                    gl_libelle.nomes        = 0
                    gl_libelle.noordre      = 0
                    gl_libelle.noidt        = 0
                    gl_libelle.libelleLibre = ttProximite.cLibelleProximite
                    ttProximite.iNumeroLibelle = gl_libelle.nolibelle
                .
            end.
            else do:
                /* proximité obligatoire en cas d'utilisation de libellé existant */
                mError:createError({&error}, 1000272).
                return.
            end.

            if ttProximite.iNumeroProximite = 0
            then do:
                create gl_proximite.
                assign
                    gl_proximite.noproximite     = igetNextSequence ("gl_proximite", "noproximite")
                    gl_proximite.dtcsy           = today
                    gl_proximite.hecsy           = mtime
                    gl_proximite.cdcsy           = mToken:cUser
                    gl_proximite.dtmsy           = today
                    gl_proximite.hemsy           = mtime
                    gl_proximite.cdmsy           = mToken:cUser
                    gl_proximite.nomes           = ttProximite.iNumeroLibelle
                    gl_proximite.tpproximite     = ttProximite.iTypeProximite
                    ttProximite.iNumeroProximite = gl_proximite.noproximite
                .
            end.
            if not can-find(first gl_fiche_proximite no-lock
                            where gl_fiche_proximite.nofiche     = ttProximite.iNumeroFiche
                              and gl_fiche_proximite.noproximite = ttProximite.iNumeroProximite)
            then do:
                create gl_fiche_proximite.
                assign
                    gl_fiche_proximite.nofiche     = ttProximite.iNumeroFiche
                    gl_fiche_proximite.noproximite = ttProximite.iNumeroProximite
                    gl_fiche_proximite.dtcsy       = today
                    gl_fiche_proximite.hecsy       = mtime
                    gl_fiche_proximite.cdcsy       = mToken:cUser
                    gl_fiche_proximite.dtmsy       = today
                    gl_fiche_proximite.hemsy       = mtime
                    gl_fiche_proximite.cdmsy       = mToken:cUser
                .
            end.
            ttProximite.CRUD = "R".
        end. /* if ttProximite.CRUD = "C" */
        else do:
            /* suppression lien fiche - proximite */
            find first gl_fiche_proximite exclusive-lock
                where gl_fiche_proximite.nofiche = ttProximite.iNumeroFiche
                  and gl_fiche_proximite.noproximite = ttProximite.iNumeroProximite no-wait no-error.
            if outils:isUpdated(buffer gl_fiche_proximite:handle,
                                'fiche-proximite ',
                                substitute('Fiche: &1 - Proximite: &2', ttProximite.iNumeroFiche, ttProximite.iNumeroProximite),
                                ttProximite.dtTimestamp)
            then return.

            delete gl_fiche_proximite.
            delete ttProximite.
        end. /* else do: */
    end.

    /* difficile cote client de gérer le remplacement (il etait prevu dans ce cas de recevoir 2 enregistrements
    dans la table, un en suppression et l'autre en creation). La on ne va recevoir qu'un enregistrement
    en creation donc ici ajout d'une boucle pour voir si il existe des enregistrements dans la table pas
    dans le dataset (dans le dataset on trouve tout y compris les non modifiés en mode R) */
    for each gl_fiche_proximite exclusive-lock
        where gl_fiche_proximite.nofiche = viNoFiche
          and not can-find(first ttProximite
                     where ttProximite.iNumeroFiche     = gl_fiche_proximite.nofiche
                       and ttProximite.iNumeroProximite = gl_fiche_proximite.noproximite):
        delete gl_fiche_proximite.
    end.

end procedure.

procedure setcaracteristiquesiteweb:
    /*------------------------------------------------------------------------------
    purpose: mise à jour infos site web
    Note   : service utilisé par beCommercialisation.cls.
    ------------------------------------------------------------------------------*/
    define input parameter piNoFiche as integer no-undo.
    define input parameter table for ttSiteWebFiche.

    define buffer gl_fiche_siteweb for gl_fiche_siteweb.

    if not ficheExiste(piNoFiche) then return.

    for each gl_fiche_siteweb exclusive-lock
        where gl_fiche_siteweb.nofiche = piNoFiche
          and not can-find(first ttSiteWebFiche
                           where integer(ttSiteWebFiche.cCode) = gl_fiche_siteweb.nositeweb):
        delete gl_fiche_siteweb.
    end.

    for each ttSiteWebFiche
        where not can-find (first gl_fiche_siteweb no-lock
                        where gl_fiche_siteweb.nofiche = piNoFiche
                        and gl_fiche_siteweb.nositeweb = integer(ttSiteWebFiche.cCode)):
        if not can-find(first gl_siteweb no-lock
                        where gl_siteweb.nositeweb = integer(ttSiteWebFiche.cCode))
        then do:
            /* site web &1 inexistant */
            mError:createError({&error}, 1000273, ttSiteWebFiche.cCode).
            return.
        end.
        create gl_fiche_siteweb.
        assign
            gl_fiche_siteweb.nofiche   = piNoFiche
            gl_fiche_siteweb.nositeweb = integer(ttSiteWebFiche.cCode)
            gl_fiche_siteweb.dtcsy     = today
            gl_fiche_siteweb.hecsy     = mtime
            gl_fiche_siteweb.cdcsy     = mToken:cUser
            gl_fiche_siteweb.dtmsy     = today
            gl_fiche_siteweb.hemsy     = mtime
            gl_fiche_siteweb.cdmsy     = mToken:cUser
        .
    end.

end procedure.

procedure setcaracteristiqueAttributsDivers:
    /*------------------------------------------------------------------------------
    purpose: mise à jour infos proximite
    Note   : service utilisé par beCommercialisation.cls.
    ------------------------------------------------------------------------------*/
    define input parameter piNoFiche as integer no-undo.
    define input parameter table for ttAttributsDivers.

    define buffer gl_fiche_attrcomm for gl_fiche_attrcomm.

    if not ficheExiste(piNoFiche) then return.

    for each gl_fiche_attrcomm exclusive-lock
        where gl_fiche_attrcomm.nofiche = piNoFiche
          and not can-find(first ttAttributsDivers
                           where integer(ttAttributsDivers.cCode) = gl_fiche_attrcomm.noattrcom):
        delete gl_fiche_attrcomm.
    end.

    for each ttAttributsDivers
        where not can-find (first gl_fiche_attrcomm no-lock
                        where gl_fiche_attrcomm.nofiche   = piNoFiche
                          and gl_fiche_attrcomm.noattrcom = integer(ttAttributsDivers.cCode)):
        if not can-find(first sys_pr no-lock
                        where sys_pr.tppar = "GLATB"
                          and sys_pr.cdpar = ttAttributsDivers.cCode)
        then do:
            /* attribut divers &1 inexistant */
            mError:createError({&error}, 1000274, ttAttributsDivers.cCode).
            return.
        end.
        create gl_fiche_attrcomm.
        assign
            gl_fiche_attrcomm.nofiche   = piNoFiche
            gl_fiche_attrcomm.noattrcom = integer(ttAttributsDivers.cCode)
            gl_fiche_attrcomm.dtcsy     = today
            gl_fiche_attrcomm.hecsy     = mtime
            gl_fiche_attrcomm.cdcsy     = mToken:cUser
            gl_fiche_attrcomm.dtmsy     = today
            gl_fiche_attrcomm.hemsy     = mtime
            gl_fiche_attrcomm.cdmsy     = mToken:cUser
        .
    end.

end procedure.

procedure setinfofiche:
    /*------------------------------------------------------------------------------
    purpose: mise à jour infos fiche
    Note   : service utilisé par beCommercialisation.cls.
    ------------------------------------------------------------------------------*/
    define input parameter table for ttFicheCommercialisation.

    define buffer gl_fiche          for gl_fiche.
    define buffer gl_histo_workflow for gl_histo_workflow.

    find first ttFicheCommercialisation where ttFicheCommercialisation.CRUD <> "R" no-error.
    if not available ttFicheCommercialisation then return.

    find first gl_fiche no-lock
        where gl_fiche.nofiche = ttFicheCommercialisation.iNumeroFiche no-error.
    if not available gl_fiche
    then do:
        mError:createError({&error}, 1000226, string(ttFicheCommercialisation.iNumeroFiche)).   /* Fiche location no &1 inexistante */
        return.
    end.

    /* controle workflow */
    if ttFicheCommercialisation.iNumeroWorkflow <> gl_fiche.noworkflow
    then do:
        if not can-find(first gl_libelle no-lock
                        where gl_libelle.noidt = ttFicheCommercialisation.iNumeroWorkflow
                          and gl_libelle.tpidt = {&TYPLIBELLE-workflow})
        then do:
            mError:createError({&error}, 'code workflow inexistant' + string(ttFicheCommercialisation.iNumeroWorkflow)).
            return.
        end.
        if not can-find(first gl_workflow no-lock
                        where gl_workflow.noworkflow1 = gl_fiche.noworkflow
                          and gl_workflow.noworkflow2 = ttFicheCommercialisation.iNumeroWorkflow)
        then do:
            mError:createError({&error}, 'Sequence workflow non respecte').
            return.
        end.
    end.

    if ttFicheCommercialisation.CRUD = "U" then do:
        find first gl_fiche exclusive-lock
            where gl_fiche.nofiche = ttFicheCommercialisation.iNumeroFiche no-wait no-error.
        if outils:isUpdated(buffer gl_fiche:handle,
                            'fiche ',
                            'Fiche: ' + string(ttFicheCommercialisation.iNumeroFiche),
                            ttFicheCommercialisation.dtTimestamp)
        then return.

        if gl_fiche.noworkflow <> ttFicheCommercialisation.iNumeroWorkflow then do:
            create gl_histo_workflow.
            assign
                gl_histo_workflow.nohisto_workflow = igetNextSequence ("gl_histo_workflow", "nohisto_workflow")
                gl_histo_workflow.dtcsy            = today
                gl_histo_workflow.hecsy            = mtime
                gl_histo_workflow.cdcsy            = mToken:cUser
                gl_histo_workflow.dtmsy            = today
                gl_histo_workflow.hemsy            = mtime
                gl_histo_workflow.cdmsy            = mToken:cUser
                gl_histo_workflow.nofiche          = ttFicheCommercialisation.iNumeroFiche
                gl_histo_workflow.noworkflow1      = gl_fiche.noworkflow
                gl_histo_workflow.noworkflow2      = ttFicheCommercialisation.iNumeroWorkflow
            .
        end.
        assign
            gl_fiche.dtmsy           = today
            gl_fiche.hemsy           = mtime
            gl_fiche.cdmsy           = mToken:cUser
            gl_fiche.nbpiece         = ttFicheCommercialisation.iNombrePieces
            gl_fiche.surfhab         = ttFicheCommercialisation.dSurfaceHabitable
            gl_fiche.texte_gestion   = ttFicheCommercialisation.cDescriptifGestion
            gl_fiche.titre_comm      = ttFicheCommercialisation.cTitreCommercial
            gl_fiche.texte_comm      = ttFicheCommercialisation.cAnnonceCommerciale
            gl_fiche.noworkflow      = ttFicheCommercialisation.iNumeroWorkflow
            gl_fiche.fgvac_locative  = ttFicheCommercialisation.lGarantieVacanceLoc
            gl_fiche.fgloy_impaye    = ttFicheCommercialisation.lGarantieLoyerImpaye
            gl_fiche.nomodecreation  = ttFicheCommercialisation.iNumeroModeCreation
            gl_fiche.nozonealur      = ttFicheCommercialisation.iNumeroZoneAlur
            gl_fiche.titre_comm      = ttFicheCommercialisation.cTitreCommercial
            gl_fiche.texte_comm      = ttFicheCommercialisation.cAnnonceCommerciale
            gl_fiche.nbphoto         = ttFicheCommercialisation.iNombrePhotos
            gl_fiche.loy_preco       = ttFicheCommercialisation.dLoyerPreconise
            gl_fiche.texte_loy_preco = ttFicheCommercialisation.cTexteLoyerPreconise
        .
    end.
    ttFicheCommercialisation.CRUD = "R".

end procedure.

procedure setcaracteristiquesequence:
    /*------------------------------------------------------------------------------
    purpose: mise à jour infos sequence
    Note   : service utilisé par beCommercialisation.cls.
    ------------------------------------------------------------------------------*/
    define input parameter table for ttSequence.

    define buffer gl_sequence for gl_sequence.

    find first ttSequence where ttSequence.CRUD <> "R" no-error.
    if not available ttSequence or not ficheExiste(ttSequence.iNumeroFiche) then return.

    if ttSequence.CRUD = "U"
    then do:
        find first gl_sequence exclusive-lock
            where gl_sequence.nosequence = ttSequence.iNumeroSequence no-wait no-error.
        if outils:isUpdated(buffer gl_sequence:handle,
                            'fiche-sequence ',
                            substitute('Fiche: &1 - Sequence: &2', ttSequence.iNumeroFiche, ttSequence.iNumeroSequence),
                            ttSequence.dtTimestamp)
        then return.

        assign
            gl_sequence.dtmsy   = today
            gl_sequence.hemsy   = mtime
            gl_sequence.cdmsy   = mToken:cUser
            gl_sequence.dtdispo = ttSequence.daDateDispo
        .
    end.
    ttSequence.CRUD = "R".        // todo   pourquoi remettre à "R" sans remettre aussi le timestamp.
                                  // todo   de plus, dans le modele transactionnel, attention
end procedure.

procedure setTiersContratCommercialisation:
    /*------------------------------------------------------------------------------
    purpose: mise à jour infos tiers apporteur
    Note   : service utilisé par beCommercialisation.cls.
    ------------------------------------------------------------------------------*/
    define input parameter table for ttTiersCommercialisation.

    define buffer gl_fiche_tiers for gl_fiche_tiers.
    define buffer vbRoles          for roles.

    find first ttTiersCommercialisation
        where ttTiersCommercialisation.CRUD <> "R"
          and lookup(ttTiersCommercialisation.cCodeTypeRoleFiche, {&TYPEROLE-mandant}) = 0 no-error.
    if not available ttTiersCommercialisation or not ficheExiste(ttTiersCommercialisation.iNumeroFiche) then return.

    for each ttTiersCommercialisation
        where lookup(ttTiersCommercialisation.CRUD, "C,D") > 0
          and lookup(ttTiersCommercialisation.cCodeTypeRoleFiche, {&TYPEROLE-mandant}) = 0:    /* 'U' normalement pas possible */

        if ttTiersCommercialisation.CRUD = "C"
        then do:
            /*--> Contrôles **/
            if ttTiersCommercialisation.iTypeTiers = {&TYPETIERS-tiersRoleGI}
            then do:
                /* tiers doit exister */
                find first vbRoles no-lock
                    where vbRoles.tprol = ttTiersCommercialisation.cCodeTypeRole
                      and vbRoles.norol = ttTiersCommercialisation.iNumeroRole no-error.
                if not available vbRoles
                then do:
                    /* combinaison type rôle, numéro rôle inexistante */
                    mError:createError({&error}, 1000297, string(ttTiersCommercialisation.cCodeTypeRole) + string(ttTiersCommercialisation.iNumeroRole)).
                    return.
                end.
                if not can-find(first tiers no-lock where tiers.notie = vbRoles.notie)
                then do:
                    /* tiers &1 inexistant */
                    mError:createError({&error}, 1000298, string(vbRoles.notie)).
                    return.
                end.
                {&_proparse_ prolint-nowarn(weakchar)}
                if can-find (first gl_fiche_tiers no-lock
                             where gl_fiche_tiers.nofiche     = ttTiersCommercialisation.iNumeroFiche
                               and gl_fiche_tiers.nohisto     = 0
                               and gl_fiche_tiers.tprolefiche = ttTiersCommercialisation.cCodeTypeRoleFiche
                               and gl_fiche_tiers.norol       = ttTiersCommercialisation.iNumeroRole
                               and gl_fiche_tiers.tprol       = ttTiersCommercialisation.cCodeTypeRole
                               and gl_fiche_tiers.soccd       = ''
                               and gl_fiche_tiers.four-cle    = '')
                then do:
                    /* type de tiers deja existant pour cette fiche */
                    mError:createError({&error}, 1000296, ttTiersCommercialisation.cCodeTypeRoleFiche).
                    return.
                end.
            end.
            if ttTiersCommercialisation.iTypeTiers = {&TYPETIERS-fournisseurGI}
            then do:
                /* fournisseur doit exister */
                if not can-find (first ifour no-lock
                                 where ifour.soc-cd   = ttTiersCommercialisation.iCodeSociete
                                   and ifour.four-cle = ttTiersCommercialisation.cCodeFournisseur)
                then do:
                    /* fournisseur &1 inexistant */
                    mError:createError({&error}, 1000299, ttTiersCommercialisation.cCodeFournisseur).
                    return.
                end.
                {&_proparse_ prolint-nowarn(weakchar)}
                if can-find (first gl_fiche_tiers no-lock
                             where gl_fiche_tiers.nofiche     = ttTiersCommercialisation.iNumeroFiche
                               and gl_fiche_tiers.nohisto     = 0
                               and gl_fiche_tiers.tprolefiche = ttTiersCommercialisation.cCodeTypeRoleFiche
                               and gl_fiche_tiers.soccd       = string(ttTiersCommercialisation.iCodeSociete)
                               and gl_fiche_tiers.four-cle    = ttTiersCommercialisation.cCodeFournisseur
                               and gl_fiche_tiers.norol       = 0
                               and gl_fiche_tiers.tprol       = '')
                then do:
                    /* type de tiers deja existant pour cette fiche */
                    mError:createError({&error}, 1000296, ttTiersCommercialisation.cCodeTypeRoleFiche).
                    return.
                end.
            end.

            create gl_fiche_tiers.
            assign
                gl_fiche_tiers.nofiche     = ttTiersCommercialisation.iNumeroFiche
                gl_fiche_tiers.tprolefiche = ttTiersCommercialisation.cCodeTypeRoleFiche
                gl_fiche_tiers.tptiers     = ttTiersCommercialisation.iTypeTiers
                gl_fiche_tiers.dtcsy       = today
                gl_fiche_tiers.hecsy       = mtime
                gl_fiche_tiers.cdcsy       = mToken:cUser
                gl_fiche_tiers.dtmsy       = today
                gl_fiche_tiers.hemsy       = mtime
                gl_fiche_tiers.cdmsy       = mToken:cUser
            .
            if ttTiersCommercialisation.iTypeTiers = {&TYPETIERS-tiersRoleGI}
            then assign
                gl_fiche_tiers.norol    = ttTiersCommercialisation.iNumeroRole
                gl_fiche_tiers.tprol    = ttTiersCommercialisation.cCodeTypeRole
                gl_fiche_tiers.soccd    = ''
                gl_fiche_tiers.four-cle = ''
            .
            else assign
                gl_fiche_tiers.soccd    = string(ttTiersCommercialisation.iCodeSociete)
                gl_fiche_tiers.four-cle = ttTiersCommercialisation.cCodeFournisseur
                gl_fiche_tiers.norol    = 0
                gl_fiche_tiers.tprol    = ''
            .
            ttTiersCommercialisation.CRUD = "R".
        end. /* if ttTiersCommercialisation.CRUD = "C"    */

/*gga pas de modif tiers, suppression et creation
            else do: /* ttTiersCommercialisation.CRUD = "U" */
                find first gl_fiche_tiers exclusive-lock
                    where gl_fiche_tiers.nofiche     = ttTiersCommercialisation.iNumeroFiche
                      and gl_fiche_tiers.nohisto     = 0
                      and gl_fiche_tiers.tprolefiche = ttTiersCommercialisation.cCodeTypeRoleFiche no-wait no-error.
                if outils:isUpdated(buffer gl_fiche_tiers:handle,
                                    'fiche-tiers ',
                                    substitute('Fiche: &1 - Tiers &2', ttTiersCommercialisation.iNumeroFiche, ttTiersCommercialisation.cCodeTypeRoleFiche),
                                    ttTiersCommercialisation.dtTimestamp)
                then return.
                if ttTiersCommercialisation.iTypeTiers = {&TYPETIERS-tiersRoleGI}
                then assign
                    gl_fiche_tiers.norol   = ttTiersCommercialisation.iNumeroRole
                    gl_fiche_tiers.tprol   = ttTiersCommercialisation.cCodeTypeRole
                    gl_fiche_tiers.soccd    = ''
                    gl_fiche_tiers.four-cle = ''
                .
                else assign
                    gl_fiche_tiers.soccd    = string(ttTiersCommercialisation.iCodeSociete)
                    gl_fiche_tiers.four-cle = ttTiersCommercialisation.cCodeFournisseur
                    gl_fiche_tiers.norol    = ttTiersCommercialisation.iNumeroRole
                    gl_fiche_tiers.tprol    = ttTiersCommercialisation.cCodeTypeRole
                .
                assign
                    gl_fiche_tiers.dtmsy = today
                    gl_fiche_tiers.hemsy = mtime
                    gl_fiche_tiers.cdmsy = mToken:cUser
                .
            end. /* else do */

            ttTiersCommercialisation.CRUD = "R".
        end. /* if lookup(ttTiersCommercialisation.CRUD,"C,U") > 0 */
gga*/

        else do:
            /* suppression lien fiche - tiers */
            find first gl_fiche_tiers exclusive-lock
                where gl_fiche_tiers.nofiche     = ttTiersCommercialisation.iNumeroFiche
                  and gl_fiche_tiers.nohisto     = 0
                  and gl_fiche_tiers.tprolefiche = ttTiersCommercialisation.cCodeTypeRoleFiche no-wait no-error.
            if outils:isUpdated(buffer gl_fiche_tiers:handle,
                                'fiche-tiers ',
                                substitute('Fiche: &1 - Type Role Fiche: &2', string(ttTiersCommercialisation.iNumeroFiche), ttTiersCommercialisation.cCodeTypeRoleFiche),
                                ttTiersCommercialisation.dtTimestamp)
            then return.

            delete gl_fiche_tiers.
            delete ttTiersCommercialisation.
        end.
    end.

end procedure.

procedure AppelServiceEncadrementLoyer:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par beCommercialisation.cls.
    ------------------------------------------------------------------------------*/
    define input  parameter table for ttDemandeEncadrementLoyer.
    define output parameter table for ttHistoEncadrementLoyer.

    define variable viNbrAppel    as integer   no-undo.
    define variable vcFiltreLib   as character no-undo extent 5 initial ['adresse', 'piece', 'annee', 'loyerm2', ''].
    define variable vcFiltreVal   as character no-undo extent 5.
    define variable vlErreurAppel as logical   no-undo.

    define buffer gl_histo_loyer_ctrl for gl_histo_loyer_ctrl.

    find first ttDemandeEncadrementLoyer no-error.
    if not available ttDemandeEncadrementLoyer
    then do:
        /* pas de demande de traitement */
        mError:createError({&error}, 9999999).
        return.
    end.
    if not ficheExiste(ttDemandeEncadrementLoyer.iNumeroFiche) then return.

    /* nombre appel limite a 5 par jour (par fiche) */
    for each gl_histo_loyer_ctrl no-lock
        where gl_histo_loyer_ctrl.nofiche = ttDemandeEncadrementLoyer.iNumeroFiche
          and date(gl_histo_loyer_ctrl.horodatage_calcul) = today:
        viNbrAppel = viNbrAppel + 1.
    end.
    if viNbrAppel >= 5 /*gga todo pour dev et test on enleve ce controle */ and 1 = 2
    then do:
        /* la limite du nombre d'appel pour une fiche par jour est atteinte */
        mError:createError({&error}, 1000275).
        return.
    end.

    /* zone obligatoire pour appel */
    if ttDemandeEncadrementLoyer.cAdresseEnvoye = ""
    or ttDemandeEncadrementLoyer.cAdresseEnvoye = ?
    then do:
        /* adresse obligatoire pour appel service encadrement loyer */
        mError:createError({&error}, 1000276).
        return.
    end.
    if ttDemandeEncadrementLoyer.iNombrePieces = 0
    then do:
        /* nombre de piece obligatoire pour appel service encadrement loyer */
        mError:createError({&error}, 1000277).
        return.
    end.
    if ttDemandeEncadrementLoyer.cAnneeConstruction = ""
    or ttDemandeEncadrementLoyer.cAnneeConstruction = ?
    then do:
        /* annee de construction obligatoire pour appel service encadrement loyer */
        mError:createError({&error}, 1000278).
        return.
    end.
    if ttDemandeEncadrementLoyer.dLoyerM2Envoye = 0
    then do:
        /* loyer au metre carre obligatoire pour appel service encadrement loyer */
        mError:createError({&error}, 1000279).
        return.
    end.

    /* si tous les controles sont ok, appel du web service */
    assign
        vcFiltreVal[1] = ttDemandeEncadrementLoyer.cAdresseEnvoye
        vcFiltreVal[2] = string(ttDemandeEncadrementLoyer.iNombrePieces)
        vcFiltreVal[3] = ttDemandeEncadrementLoyer.cAnneeConstruction
        vcFiltreVal[4] = string(ttDemandeEncadrementLoyer.dLoyerM2Envoye)
        vcFiltreVal[5] = string(ttDemandeEncadrementLoyer.iLocMeuble)
    .
    run appelWebService(                      // todo  paramétrer l'uri
        'https://gi-6.la-gi.fr/ws/rest/checkLoyerMediant'
      , '03080'
      , 'b0fb933b11b0703c58d948a060376fc2'
      , vcFiltreLib
      , vcFiltreVal
      , output vlErreurAppel
    ).
    /* si il y a eu une erreur au moment de l'appel pas de creation de gl_histo_loyer_ctrl.status_calcul
    car pas a prendre en compte sur le test du nombre d'appel limite a 5 */

    if vlErreurAppel
    then do:
        mError:createError({&error}, 1000304, "erreur appel web sevice").   /* erreur calcul encadrement loyer : &1 */
        return.
    end.

    create gl_histo_loyer_ctrl.
    assign
        gl_histo_loyer_ctrl.nohisto_loyer_ctrl = igetNextSequence ("gl_histo_loyer_ctrl", "nohisto_loyer_ctrl")
        gl_histo_loyer_ctrl.dtcsy              = today
        gl_histo_loyer_ctrl.hecsy              = mtime
        gl_histo_loyer_ctrl.cdcsy              = mToken:cUser
        gl_histo_loyer_ctrl.dtmsy              = today
        gl_histo_loyer_ctrl.hemsy              = mtime
        gl_histo_loyer_ctrl.cdmsy              = mToken:cUser
        gl_histo_loyer_ctrl.nofiche            = ttDemandeEncadrementLoyer.iNumeroFiche
        gl_histo_loyer_ctrl.adresse            = ttDemandeEncadrementLoyer.cAdresseEnvoye
        gl_histo_loyer_ctrl.nbpiece            = ttDemandeEncadrementLoyer.iNombrePieces
        gl_histo_loyer_ctrl.anneeconstruction  = ttDemandeEncadrementLoyer.cAnneeConstruction
        gl_histo_loyer_ctrl.loyerfiche_m2      = ttDemandeEncadrementLoyer.dLoyerM2Envoye
        gl_histo_loyer_ctrl.fgmeuble           = (ttDemandeEncadrementLoyer.iLocMeuble = 1)
    .

    find first ttCalculEncadrementLoyer no-error.
    if available ttCalculEncadrementLoyer
    then assign
        gl_histo_loyer_ctrl.status_calcul     = trim(string(ttCalculEncadrementLoyer.lvalid, "OK/KO"))
        gl_histo_loyer_ctrl.messageretour     = ttCalculEncadrementLoyer.cstatus
        gl_histo_loyer_ctrl.coderetour        = ttCalculEncadrementLoyer.cstatus
        gl_histo_loyer_ctrl.loyermediant      = ttCalculEncadrementLoyer.dLoyerMedian
        gl_histo_loyer_ctrl.loyerminore       = ttCalculEncadrementLoyer.dLoyerMinore
        gl_histo_loyer_ctrl.loyermajore       = ttCalculEncadrementLoyer.dLoyerMajore
        gl_histo_loyer_ctrl.horodatage_calcul = ttCalculEncadrementLoyer.dthorodatage
    .
    else do:
        assign
            gl_histo_loyer_ctrl.status_calcul = "KO"
            gl_histo_loyer_ctrl.messageretour = "erreur"
            gl_histo_loyer_ctrl.coderetour    = "erreur"
        .
        mError:createError({&error}, 1000304, gl_histo_loyer_ctrl.messageretour).   /* erreur calcul encadrement loyer : &1 */
    end.
    run getHistoEncadrementLoyerPrivate (?, rowid(gl_histo_loyer_ctrl)).

end procedure.

procedure getTiersFicheCommercialisation:
    /*------------------------------------------------------------------------------
    Purpose: Permet de récupérer les tiers liés à une fiche de (re)Location
    Notes  : service utilisé par beCommercialisation.cls.
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroFiche   as integer no-undo.
    define input  parameter piNumeroHisto   as integer no-undo.
    define output parameter table for ttTiersCommercialisation.
    define output parameter table for ttCoordonneeTiers.
    define output parameter table for ttMoyenCommunicationTiers.
    define output parameter table for ttAdresse.

    define variable vhProcAdresse as handle no-undo.
    define variable vhProcMoyen   as handle no-undo.

    define buffer gl_fiche_tiers for gl_fiche_tiers.
    define buffer tiers          for tiers.
    define buffer vbRoles        for roles.
    define buffer ifour          for ifour.

    empty temp-table ttTiersCommercialisation.
    empty temp-table ttCoordonneeTiers.
    empty temp-table ttMoyenCommunicationTiers.
    empty temp-table ttAdresse.

    run adresse/moyenCommunication.p persistent set vhProcMoyen.
    run getTokenInstance in vhProcMoyen(mToken:JSessionId).
    run adresse/adresse.p persistent set vhProcAdresse.
    run getTokenInstance in vhProcAdresse(mToken:JSessionId).

    for each gl_fiche_tiers no-lock
        where gl_fiche_tiers.nofiche = piNumeroFiche
          and gl_fiche_tiers.nohisto = piNumeroHisto:

        /* Tiers issus de la GESTION : Tiers/roles */
        if gl_fiche_tiers.tptiers =  {&TYPETIERS-tiersRoleGI}
        then for first vbRoles no-lock
            where vbRoles.tprol = gl_fiche_tiers.tprol
              and vbRoles.norol = gl_fiche_tiers.norol
          , first tiers no-lock
            where tiers.notie = vbRoles.notie:
            create ttTiersCommercialisation.
            assign
                ttTiersCommercialisation.CRUD                  = 'R'
                ttTiersCommercialisation.cJointure             = substitute('&1-&2&3&4', gl_fiche_tiers.tprolefiche, gl_fiche_tiers.tprol, gl_fiche_tiers.norol, tiers.notie)
                ttTiersCommercialisation.iNumeroFiche          = gl_fiche_tiers.nofiche
                ttTiersCommercialisation.iNumeroHistorique     = gl_fiche_tiers.nohisto
                ttTiersCommercialisation.iTypeTiers            = gl_fiche_tiers.tptiers
                ttTiersCommercialisation.cCodeTypeRoleFiche    = gl_fiche_tiers.tprolefiche
                ttTiersCommercialisation.cLibelleTypeRoleFiche = outilTraduction:getLibelleProg("O_ROL", gl_fiche_tiers.tprolefiche)
                //ttTiersCommercialisation.iNumeroRoleFiche      = gl_fiche_tiers.norolefiche
                ttTiersCommercialisation.cCodeTypeRole         = gl_fiche_tiers.tprol
                ttTiersCommercialisation.iNumeroRole           = gl_fiche_tiers.norol
                ttTiersCommercialisation.cNom1                 = tiers.lnom1
                ttTiersCommercialisation.cPrenom1              = tiers.lpre1
                ttTiersCommercialisation.cCodeCivilite1        = tiers.cdcv1
                ttTiersCommercialisation.cLibelleCivilite1     = outilTraduction:getLibelleProg("O_CVT", tiers.cdcv1)
                ttTiersCommercialisation.cNom2                 = tiers.lnom2
                ttTiersCommercialisation.cPrenom2              = tiers.lpre2
                ttTiersCommercialisation.cCodeCivilite2        = tiers.cdcv2
                ttTiersCommercialisation.cLibelleCivilite2     = outilTraduction:getLibelleProg("O_CVT", tiers.cdcv2)
                ttTiersCommercialisation.cCheminPhoto          = ''    // NPO  TODO
                ttTiersCommercialisation.dtTimestamp           = datetime(gl_fiche_tiers.dtmsy, gl_fiche_tiers.hemsy)
                ttTiersCommercialisation.rRowid                = rowid(gl_fiche_tiers)
            .
            run getAdresse in vhProcAdresse(gl_fiche_tiers.tprol, gl_fiche_tiers.norol, "", ttTiersCommercialisation.cJointure
                                          , output table ttAdresse by-reference
                                          , output table ttCoordonneeTiers by-reference
                                          , output table ttMoyenCommunicationTiers by-reference).
        end.
        /* Tiers issus de la COMPTA : IFOUR */
        if gl_fiche_tiers.tptiers =  {&TYPETIERS-fournisseurGI}
        then for first ifour no-lock
            where ifour.soc-cd   = integer(gl_fiche_tiers.soccd)
              and ifour.four-cle = gl_fiche_tiers.four-cle:
            create ttTiersCommercialisation.
            assign
                ttTiersCommercialisation.CRUD                  = 'R'
                ttTiersCommercialisation.cJointure             = substitute('&1-FOU&2&3', gl_fiche_tiers.tprolefiche, gl_fiche_tiers.soccd, gl_fiche_tiers.four-cle)
                ttTiersCommercialisation.iNumeroFiche          = gl_fiche_tiers.nofiche
                ttTiersCommercialisation.iNumeroHistorique     = gl_fiche_tiers.nohisto
                ttTiersCommercialisation.iTypeTiers            = gl_fiche_tiers.tptiers
                ttTiersCommercialisation.cCodeTypeRoleFiche    = gl_fiche_tiers.tprolefiche
                ttTiersCommercialisation.cLibelleTypeRoleFiche = outilTraduction:getLibelleProg("O_ROL", gl_fiche_tiers.tprolefiche)
                //ttTiersCommercialisation.iNumeroRoleFiche      = gl_fiche_tiers.norolefiche
                ttTiersCommercialisation.iCodeSociete          = integer(gl_fiche_tiers.soccd)
                ttTiersCommercialisation.cCodeFournisseur      = gl_fiche_tiers.four-cle
                ttTiersCommercialisation.cCodeTypeRole         = gl_fiche_tiers.tprol
                ttTiersCommercialisation.iNumeroRole           = gl_fiche_tiers.norol
                ttTiersCommercialisation.cNom1                 = ifour.nom
                ttTiersCommercialisation.cCodeCivilite1        = string(ifour.librais-cd)
                ttTiersCommercialisation.cSiret                = ifour.siret
                ttTiersCommercialisation.cCheminPhoto          = ''    // NPO  TODO
                ttTiersCommercialisation.dtTimestamp           = datetime(gl_fiche_tiers.dtmsy, gl_fiche_tiers.hemsy)
                ttTiersCommercialisation.rRowid                = rowid(gl_fiche_tiers)
                ttTiersCommercialisation.cLibelleCivilite1     = getLibelleGenreFournisseur(ifour.soc-cd, ifour.librais-cd)
            .
            create ttAdresse.
            assign
                ttAdresse.CRUD               = 'R'
                ttAdresse.cJointure          = substitute('&1-FOU&2&3', gl_fiche_tiers.tprolefiche, gl_fiche_tiers.soccd, gl_fiche_tiers.four-cle)
                ttAdresse.cTypeIdentifiant   = 'FOU'
                ttAdresse.iNumeroIdentifiant = integer(ifour.four-cle)
                ttAdresse.iNumeroFiche       = gl_fiche_tiers.nofiche
                ttAdresse.cNomVoie           = (if trim(ifour.adr[1]) > "" then trim(ifour.adr[1]) + " " else "")
                                           /*+ (if trim(ifour.adr[2]) > "" then trim(ifour.adr[2]) + " " else "")
                                             + (if trim(ifour.adr[3]) > "" then trim(ifour.adr[3]) + " " else "")*/
                ttAdresse.cComplementVoie    = (if trim(ifour.adr[2]) > "" then trim(ifour.adr[2]) + " " else "")
                                             + (if trim(ifour.adr[3]) > "" then trim(ifour.adr[3]) + " " else "")
                ttAdresse.cCodePostal        = ifour.cp
                ttAdresse.cVille             = ifour.ville
                ttAdresse.cCodePays          = ifour.libpays-cd
                ttAdresse.cLibelle           = (if trim(ifour.adr[1]) > "" then trim(ifour.adr[1]) + " " else "")
                                             + (if trim(ifour.adr[2]) > "" then trim(ifour.adr[2]) + " " else "")
                                             + (if trim(ifour.adr[3]) > "" then trim(ifour.adr[3]) + " " else "")
                                             + caps(trim(ifour.cp) + " " + trim(ifour.ville))
                ttAdresse.dtTimestampadres   = datetime(ifour.damod, ifour.ihmod)
                ttAdresse.dtTimestampladrs   = datetime(ifour.damod, ifour.ihmod)
                ttAdresse.rRowid             = rowid(ifour)
                ttAdresse.cLibellePays       = getLibellePaysFournisseur(ifour.soc-cd, ifour.libpays-cd)
            .
            run getMoyenCommunication in vhProcMoyen ('FOU', integer(gl_fiche_tiers.four-cle), ttTiersCommercialisation.cJointure, output table ttMoyenCommunicationTiers by-reference).
        end.

/*gga
        if can-find(first ttMoyenCommunicationTiers)
        then do:
            create ttCoordonneeTiers.
            assign
                ttCoordonneeTiers.iNumeroIdentifiant = if gl_fiche_tiers.tptiers =  {&TYPETIERS-fournisseurGI}
                                                       then integer(ttTiersCommercialisation.cCodeFournisseur)
                                                       else ttTiersCommercialisation.iNumeroRole
                ttCoordonneeTiers.cJointure          = ttTiersCommercialisation.cJointure
            .
        end.
gga*/

    end.
    run destroy in vhProcMoyen.
    run destroy in vhProcAdresse.

end procedure.

procedure SaisiePlafonnementEncadrementLoyer:

    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par beCommercialisation.cls.
    ------------------------------------------------------------------------------*/
    define input-output parameter table for ttPlafonnementEncadrementLoyer.
    define input parameter table for ttError.

    define buffer gl_fiche for gl_fiche.
    define buffer gl_histo_loyer89 for gl_histo_loyer89.

    define variable vdPourCalculLoyerActualise as decimal no-undo.

    find first ttPlafonnementEncadrementLoyer no-error.
    if not available ttPlafonnementEncadrementLoyer
    then do:
        /* pas d'enregistrement plafonnement loyer a traiter */
        mError:createError({&error}, 1000315).
        return.
    end.

    find first gl_fiche no-lock
        where gl_fiche.nofiche = ttPlafonnementEncadrementLoyer.iNumeroFiche no-error.
    if not available gl_fiche
    then do:
        /* Fiche location no &1 inexistante */
        mError:createError({&error}, 1000226, string(ttPlafonnementEncadrementLoyer.iNumeroFiche)).
        return.
    end.

    if outils:questionnaire(1000309, table ttError by-reference) <= 2  /* question sur premier bail de ce bien en loi 89 (reponse oui/non) */
    or ttPlafonnementEncadrementLoyer.lPremBailLoi89                   /* si premier bail en loi 89 arret questionnaire */
    or outils:questionnaire(1000310, table ttError by-reference) <= 2  /* question sur date de résiliation du bail précédent (reponse date) */
    or ttPlafonnementEncadrementLoyer.daResilBailPrec = ?              /* si logement innocupe depuis plus de 18 mois arret questionnaire */
    or ttPlafonnementEncadrementLoyer.daResilBailPrec < add-interval(today, -18, "month")
    or outils:questionnaire(1000311, table ttError by-reference) <= 2  /* question dernier travaux d'amélioration ou de mise en conformite < 6 mois */
    then return.

    if ttPlafonnementEncadrementLoyer.lDernTravInf6Mois = yes
    then do:
        /* montant TTC des travaux */
        if outils:questionnaire(1000312, table ttError by-reference) <= 2 then return.

        /* montant travaux >= ancien loyer annuel arret du questionnaire */
        if ttPlafonnementEncadrementLoyer.dMontantTravauxInf6MoisTTC >= ttPlafonnementEncadrementLoyer.dAncienLoyer
        then return.
    end.

message "a001 " ttPlafonnementEncadrementLoyer.dAncienLoyer ttPlafonnementEncadrementLoyer.dDernIndiceConnu ttPlafonnementEncadrementLoyer.dDernIndiceUtilise.

    /* date denier indexation - date nouveau bail > 12 mois */
    if interval(ttPlafonnementEncadrementLoyer.daNouvBail, ttPlafonnementEncadrementLoyer.daDernIndex, "month") > 12
    then assign
        ttPlafonnementEncadrementLoyer.dLoyerRevise = (ttPlafonnementEncadrementLoyer.dAncienLoyer * ttPlafonnementEncadrementLoyer.dDernIndiceConnu)
                                                    / ttPlafonnementEncadrementLoyer.dDernIndiceUtilise
        vdPourCalculLoyerActualise = ttPlafonnementEncadrementLoyer.dLoyerRevise
    .
    else assign
        ttPlafonnementEncadrementLoyer.dLoyerRevise = 0
        vdPourCalculLoyerActualise                  = ttPlafonnementEncadrementLoyer.dAncienLoyer
    .

message "a002 " ttPlafonnementEncadrementLoyer.dAncienLoyer ttPlafonnementEncadrementLoyer.dLoyerRevise vdPourCalculLoyerActualise.

    /* question ancien loyer est il sous-evalue */
    if outils:questionnaire(1000313, table ttError by-reference) <= 2 then return.

    if ttPlafonnementEncadrementLoyer.lAncLoyerSousEval = yes
    then do:
        /* question sur loyer constaté dans le quartier */
        if outils:questionnaire(1000314, table ttError by-reference) <= 2 then return.

        /* calcul loyer actualise car sous evalue */
        ttPlafonnementEncadrementLoyer.dLoyerActualise = vdPourCalculLoyerActualise
                                                       + (ttPlafonnementEncadrementLoyer.dLoyerPourQuartier - vdPourCalculLoyerActualise) / 2.
    end.

    /* question dernier travaux d'amélioration ou de mise en conformite > 6 mois */
    if outils:questionnaire(1000316, table ttError by-reference) <= 2 then return.

    if ttPlafonnementEncadrementLoyer.lDernTravSup6Mois then do:
        /* montant TTC des travaux */
        if outils:questionnaire(1000317, table ttError by-reference) <= 2 then return.

message "a003 " ttPlafonnementEncadrementLoyer.dMontantTravauxSup6MoisTTC "//" ttPlafonnementEncadrementLoyer.dAncienLoyer
        vdPourCalculLoyerActualise.

        /* montant travaux >= ancien loyer annuel arret du questionnaire */
        if ttPlafonnementEncadrementLoyer.dMontantTravauxSup6MoisTTC >= ttPlafonnementEncadrementLoyer.dAncienLoyer / 2
        then ttPlafonnementEncadrementLoyer.dLoyerSelonTravaux = vdPourCalculLoyerActualise
             /* calcul loyer selon travaux */                  + ttPlafonnementEncadrementLoyer.dMontantTravauxSup6MoisTTC * 15 / 100.
    end.

    create gl_histo_loyer89.
    assign gl_histo_loyer89.nohisto_loyer89    = igetNextSequence('gl_histo_loyer89', 'nohisto_loyer89')
           gl_histo_loyer89.nodetailfinance    = 0                                         //??????????????????
           gl_histo_loyer89.nofiche            = ttPlafonnementEncadrementLoyer.iNumeroFiche
           gl_histo_loyer89.dtcsy              = today
           gl_histo_loyer89.hecsy              = mtime
           gl_histo_loyer89.cdcsy              = mToken:cUser
           gl_histo_loyer89.dtmsy              = gl_histo_loyer89.dtcsy
           gl_histo_loyer89.hemsy              = gl_histo_loyer89.hecsy
           gl_histo_loyer89.cdmsy              = mToken:cUser
           gl_histo_loyer89.ancienloyer        = ttPlafonnementEncadrementLoyer.dAncienLoyer
           gl_histo_loyer89.loyerrevise        = ttPlafonnementEncadrementLoyer.dLoyerRevise
           gl_histo_loyer89.loyeractualise     = ttPlafonnementEncadrementLoyer.dLoyerActualise
           gl_histo_loyer89.loyertravaux       = ttPlafonnementEncadrementLoyer.dLoyerSelonTravaux
           gl_histo_loyer89.loyerquartier      = ttPlafonnementEncadrementLoyer.dLoyerPourQuartier
           gl_histo_loyer89.montanttravaux_ttc = ttPlafonnementEncadrementLoyer.dMontantTravauxSup6MoisTTC
           gl_histo_loyer89.noperio            = 0
    .
    for each ttError
        where ttError.iType = {&NIVEAU-questionRepondue}
           or ttError.iType = {&NIVEAU-questionYesNo}:
        gl_histo_loyer89.cheminement = substitute("&1&2-&3#",
                                                  gl_histo_loyer89.cheminement,
                                                  string(ttError.iErrorId),
                                                  string(ttError.lYesNo)).
    end.

end procedure.

procedure getAdresseSimplifieUnite private:
    /*------------------------------------------------------------------------------
    Purpose: Renvoie l'adresse d'une unité de location sur 3 zone adresse code postal ville
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter  piNumeroUL       as integer no-undo.
    define input parameter  piNumeroContrat  as integer no-undo.
    define output parameter pcCodePostal     as character no-undo.
    define output parameter pcVille          as character no-undo.
    define output parameter pcAdresse        as character no-undo.
    define output parameter pcLibelleAdresse as character no-undo.

    define buffer unite for unite.
    define buffer intnt for intnt.
    define buffer ladrs for ladrs.
    define buffer adres for adres.

    for first unite no-lock
        where unite.noapp = piNumeroUL
          and unite.nomdt = piNumeroContrat
      , first intnt no-lock
        where intnt.tpidt = {&TYPEBIEN-immeuble}
          and intnt.tpcon = {&TYPECONTRAT-mandat2Gerance}
          and intnt.nocon = unite.nomdt
      , first ladrs no-lock
        where ladrs.tpidt = {&TYPEBIEN-immeuble}
          and ladrs.noidt = intnt.noidt
          and ladrs.tpadr = {&TYPEADRESSE-Principale}
      , first adres no-lock
        where adres.noadr = ladrs.noadr:
        assign
            pcCodePostal     = trim(adres.cdpos)
            pcVille          = trim(adres.lbvil)
            pcAdresse        = outilFormatage:formatageAdresse(buffer ladrs, buffer adres, 0 /* ni ville, ni pays */) 
            pcLibelleAdresse = outilFormatage:formatageAdresse(buffer ladrs, buffer adres, 3 /* ville et pays */)
        .
    end.

end procedure.
