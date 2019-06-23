/*------------------------------------------------------------------------
File        : ctrlUtilisateur.p
Purpose     : Controle du code utilisateur et mot de passe MaGI
Description : Le controle de l'utilisateur ne se fait que si le code utilisateur est différent de "INS"
              Si l'utilisateur est "INS" le mot de passe est un mot de passe calculé et saisi automatiquement
Author(s)   : kantena - 2016/02/25
Notes       : le mot de passe est CASE-SENSITIVE (pas le code utilisateur)
derniere revue: 2018/05/23 - phm: OK
----------------------------------------------------------------------*/
{preprocesseur/type2role.i}
{preprocesseur/type2contrat.i}
{preprocesseur/profilGestionnaire.i}

using parametre.pclie.parametrageReferenceGeranceCopro.
{oerealm/include/utilisateur.i}

function VerificationMotDePasse returns logical(pcUser as character, pcPassword as character):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define buffer tutil for tutil.

    for first tutil no-lock
        where tutil.ident_u = pcUser:
        if encode(pcPassword) = tutil.Mot-passe then return true.
    end.
    return false.

end function.

function verificationUtilisateur returns character(pcUser as character):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vcRetour   as character no-undo.
    define variable vcExePasse as character no-undo.

    /* Le chemin est en dur. C'est volontaire pour ne pas trouver cet executable chez les clients */
    /* TODO A revoir la localisation du fichier */
    if pcUser = "INS" then do:
        vcExePasse = search("c:/magi/gestion_utilisateurs/passe.exe").
        if vcExePasse <> ? then do:
            os-command silent value(vcExePasse + " INVISIBLE").
            assign
                vcRetour = clipboard:value
                clipboard:value = ""
            .
        end.
    end.
    return vcRetour.

end function.

function calculPasseIns return character():
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vcRetour as character no-undo.
    define variable vitempo  as integer   no-undo.
    define variable viBoucle as integer   no-undo.

    assign
        vcRetour = iso-date(now)
        vcRetour = substitute('&1&2&3&4',
                            substring(vcRetour, 6, 2, 'character'),  /* mois  */
                            substring(vcRetour, 9, 2, 'character'),  /* jour  */
                            substring(vcRetour, 3, 2, 'character'),  /* an    */
                            substring(vcRetour, 12, 2, 'character')) /* heure */
        vcRetour = string(99999999 - integer(vcRetour), "99999999")
    .
    do viBoucle = 1 to 8:
        viTempo = viTempo + integer(substring(vcRetour, viBoucle, 1, 'character')).
    end.
    vcRetour = vcRetour + string(viTempo, "99").
    return vcRetour.

end function.

function getGestionnaire returns logical (pcUser as character, output piGest as integer, output piColl as integer):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par magiToken.cls
    ------------------------------------------------------------------------------*/
    define buffer tutil   for tutil.
    define buffer tiers   for tiers.
    define buffer intnt   for intnt.
    define buffer ctrat   for ctrat.
    define buffer vbRoles for roles.

    /*--> Recherche du numéro de collaborateur associé au user */
    find first tutil no-lock where tutil.ident_u = pcUser no-error.
    if available tutil then do:
        find first vbRoles no-lock
            where vbRoles.tprol = {&TYPEROLE-gestionnaire} no-error.
        if available vbRoles
        then find first tiers no-lock
            where tiers.notie = vbRoles.notie
              and tiers.lnom1 = tutil.nom no-error.
        do while available vbRoles and not available tiers:
            find next vbRoles no-lock
                where vbRoles.tprol = {&TYPEROLE-gestionnaire} no-error.
            if available vbRoles
            then find first tiers no-lock
                where tiers.notie = vbRoles.notie
                  and tiers.lnom1 = tutil.nom no-error.
        end.

        if not available vbRoles     /*--> Recherche du collaborateur */
        then find first vbRoles no-lock
            where vbRoles.tprol = {&TYPEROLE-gestionnaire} no-error.
        if available vbRoles then piColl = vbRoles.NoRol.
    end.

    /*--> Recherche du profil du collaborateur */
    find first intnt no-lock
         where intnt.tpidt = {&TYPEROLE-gestionnaire}
           and intnt.tpcon = {&TYPECONTRAT-serviceGestion}
           and intnt.noidt = piColl no-error.
    if available intnt then piGest = intnt.nbnum.

    if piGest = {&PROFILGESTIONNAIRE-administrateur}
    then do:
        /*--> Pas de gestion par gestionnaire */
        find first ctrat no-lock
             where ctrat.tpcon = {&TYPECONTRAT-serviceGestion} no-error.
        if not available ctrat then piGest = {&PROFILGESTIONNAIRE-pas2agence}.
    end.
    return true.

end function.

function getReferences returns logical (output pcNoRefUse as character, output pcNoRefCop as character, output pcNoRefGer as character):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par magiToken.cls
    ------------------------------------------------------------------------------*/
    define variable voReferenceGeranceCopro as class parametrageReferenceGeranceCopro no-undo.
    define buffer isoc for isoc.

    /* Récupération de la référence principale */
    {&_proparse_ prolint-nowarn(wholeIndex)}
    for first isoc no-lock
        where isoc.specif-cle <> 0:
        pcNoRefUse = string(isoc.soc-cd, "99999").
    end.
    /*--> Mettre a jour les references gerance et copro si plusieurs références */
    voReferenceGeranceCopro = new parametrageReferenceGeranceCopro().
    if voReferenceGeranceCopro:isDbParameter
    then assign
        pcNoRefGer = voReferenceGeranceCopro:getReferenceGerance()
        pcNoRefCop = voReferenceGeranceCopro:getReferenceCopro()
    .
    else assign
        pcNoRefGer = pcNoRefUse
        pcNoRefCop = pcNoRefUse
    .
    delete object voReferenceGeranceCopro.
    return true.

end function.

function getCodeSociete returns integer ():
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par magiToken.cls
    ------------------------------------------------------------------------------*/
    define buffer isoc for isoc.

    {&_proparse_ prolint-nowarn(wholeIndex)}
    find first isoc no-lock
        where isoc.specif-cle = 1000 no-error.
    return if available isoc then isoc.soc-cd else ?.

end function.

function getCodeUser returns character(piUserID as integer):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par magiToken.cls
    ------------------------------------------------------------------------------*/
    define buffer tutil for tutil.

    {&_proparse_ prolint-nowarn(wholeIndex)}
    for first tutil no-lock
        where tutil.notie = piUserID:
        return tutil.ident_u.
    end.
    return "".

end function.

function getDateCptaEnCours returns date(pcTypeMandat as character):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par magiToken.cls
    ------------------------------------------------------------------------------*/
    define buffer isoc  for isoc.
    define buffer agest for agest.

    {&_proparse_ prolint-nowarn(wholeIndex)}
    for each isoc no-lock
        where isoc.specif-cle = 1000
      , each agest no-lock 
        where agest.soc-cd = isoc.soc-cd:
        if pcTypeMandat = "GERANCE" 
        and can-find(first ietab no-lock
                     where ietab.soc-cd = agest.soc-cd
                       and ietab.profil-cd = 21) then return agest.dafin. 
        else if pcTypeMandat = "COPRO" 
             and can-find(first ietab no-lock
                          where ietab.soc-cd = agest.soc-cd
                            and ietab.profil-cd = 91) then return agest.dafin. 
    end.
    return ?.
end function.

function getLangueReference returns integer (pcUser as character):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par magiToken.cls
    ------------------------------------------------------------------------------*/
    define buffer tparam for tparam.

    /* récupération du code langue utilisateur */
    for first tparam no-lock
        where tparam.ident_u = pcUser:
        return tparam.cdlng.
    end.
    return 0.

end function.

function getDeviseReference returns character():
    /*------------------------------------------------------------------------------
    Purpose: retourne la devise de la référence
    Notes  : service
    ------------------------------------------------------------------------------*/
    define variable viSociete as integer no-undo.
    define buffer ietab for ietab.

    viSociete = getCodeSociete().
    for first ietab no-lock
        where ietab.soc-cd = viSociete:
        return ietab.dev-cd.
    end.
    return "EUR".
end function.

procedure InfosUtilisateur:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service ?
    TODO   : a supprimer ?!
    ------------------------------------------------------------------------------*/
    define input parameter pcUser as character no-undo.

    define buffer tparam for tparam.
    define buffer tutil  for tutil.
    define buffer ttUtilisateur for ttUtilisateur.

    /* Positionnement sur l'utilisateur */
    for first tutil no-lock
        where tutil.ident_u = pcUser:
        create ttUtilisateur.
        assign
            ttUtilisateur.cCode                    = tutil.ident_u
            ttUtilisateur.cCodeProfil              = tutil.profil_u
            ttUtilisateur.cNom                     = tutil.nom
            ttUtilisateur.cEmail                   = tutil.email
            ttUtilisateur.cInitiales               = tutil.initiales
            ttUtilisateur.cCompte                  = tutil.cptutil
            ttUtilisateur.cAccordMessage           = tutil.cdaccord
            ttUtilisateur.cCodeUtilSignataire1     = tutil.signataire1
            ttUtilisateur.cCodeUtilSignataire2     = tutil.signataire2
            ttUtilisateur.cCodeUtilSignataireEvent = tutil.code1
            ttUtilisateur.cTypeRechercheTiers      = tutil.cTypeRecherche  /* C/T */
            ttUtilisateur.cTypeRechercheEvent      = tutil.cIdentEvent  /* R/T/I/C */
            ttUtilisateur.lActif                   = tutil.fg-actif
            ttUtilisateur.lIdentGiDemat            = tutil.fg-mdpgidemat
            ttUtilisateur.lGiprint                 = tutil.fg-giprint
            ttUtilisateur.cInfosGED                = tutil.GEd
            ttUtilisateur.iPaletteCouleur          = tutil.palette
            ttUtilisateur.iNumeroTiers             = tutil.notie
            ttUtilisateur.cTypeRole                = tutil.tprol
            ttUtilisateur.iNumeroRole              = tutil.norol
            ttUtilisateur.cNomRole                 = tutil.lnom1
            ttUtilisateur.cPrenomRole              = tutil.lpre1
        .
        /* Récupération de l'imprimante et du code langue */
        for first tparam no-lock
            where tparam.ident_u = pcUser:
            assign
                ttUtilisateur.cCodeLangue = string(tparam.cdlng)
                ttUtilisateur.cImprimante = tparam.printer-field
            .
        end.
    end.
end procedure.
