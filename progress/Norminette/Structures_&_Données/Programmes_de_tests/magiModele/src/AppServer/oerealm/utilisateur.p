/*------------------------------------------------------------------------
File        : utilisateur.p
Purpose     :
Author(s)   : kantena - 2016/05/09
Notes       : block-level error management!
Tables      : BASE inter : tutil tparam
----------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */
{oerealm/include/utilisateur.i}
define temp-table ttUser no-undo
    field cCode        as character
    field iNumeroTiers as integer
    field cPassword    as character
.

procedure getListeUtilisateur:
    /*------------------------------------------------------------------------------
    Purpose: Extrait la liste de tous les utilisateurs (mot de passe non envoyé)
    Notes  : service utilisé par beUtilisateur.cls
    ------------------------------------------------------------------------------*/
    define output parameter table for ttUtilisateur.

    define variable vhbtutil      as handle    no-undo.
    define variable vhQuery       as handle    no-undo.
    define variable vcQuery       as character no-undo.

    define buffer ttUtilisateur for ttUtilisateur.

    create buffer vhbtutil for table "tutil".
    create query vhQuery.
    vhQuery:set-buffers(vhbtutil).
    vcQuery = "FOR EACH tutil NO-LOCK".
    vhQuery:query-prepare(vcQuery).
    vhQuery:query-open().
boucle:
    repeat:
        vhQuery:get-next().
        if vhQuery:query-off-end then leave boucle.
        run createttUtilisateur(vhbtutil).
    end.
end procedure.

procedure getUtilisateur:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par beUtilisateur.cls
    ------------------------------------------------------------------------------*/
    define input parameter pcCode        as character no-undo.
    define input parameter piNumeroTiers as integer   no-undo.
    define output parameter table for ttUtilisateur.

    define variable vhbtutil      as handle    no-undo.
    define variable vhQuery       as handle    no-undo.
    define variable vcQuery       as character no-undo.

    define buffer ttUtilisateur for ttUtilisateur.
    if (pcCode = '' or pcCode = ?) and (piNumeroTiers = ? or piNumeroTiers = 0) then assign pcCode = mtoken:cUser. // utilisateur connecté

    create buffer vhbtutil for table "tutil".
    create query vhQuery.
    vhQuery:set-buffers(vhbtutil).
    vcQuery = "FOR EACH tutil NO-LOCK WHERE tutil."
           + if pcCode > ''
             then substitute('ident_u = "&1"', pcCode)
             else substitute('notie = &1', string(piNumeroTiers)).
    vhQuery:query-prepare(vcQuery).
    vhQuery:query-open().
boucle:
    repeat:
        vhQuery:get-next().
        if vhQuery:query-off-end then leave boucle.
        run createttUtilisateur(vhbtutil).
    end.
end procedure.

procedure getUserByName:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par HybridRealm.cls
    ------------------------------------------------------------------------------*/
    define input parameter pcCode as character no-undo.
    define output parameter table for ttUser.
    define buffer ttUser for ttUser.

    if pcCode = '' or pcCode = ? then return.

    for each tutil no-lock where tutil.ident_u = pcCode:
        create ttUser.
        assign
            ttUser.cCode        = tutil.ident_u
            ttUser.cPassword    = tutil.mot-passe
            ttUser.iNumeroTiers = tutil.notie
        .
    end.
end procedure.
procedure getUserById:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par HybridRealm.cls
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroTiers as integer no-undo.
    define output parameter table for ttUser.
    define buffer ttUser for ttUser.

    if piNumeroTiers = 0 or piNumeroTiers = ? then return.

    for each tutil no-lock where tutil.notie = piNumeroTiers:
        create ttUser.
        assign
            ttUser.cCode        = tutil.ident_u
            ttUser.cPassword    = tutil.mot-passe
            ttUser.iNumeroTiers = tutil.notie
        .
    end.
end procedure.

procedure createTTutilisateur private:
    /*------------------------------------------------------------------------------
    Purpose: Copie les informations de la table physique vers la temp-table
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter phbuffer   as handle  no-undo.
    define buffer tparam for tparam.

    /* Récupération de l'imprimante et du code langue */
    find first tparam no-lock
        where tparam.ident_u = phbuffer::ident_u no-error.
    create ttUtilisateur.
    assign
        ttUtilisateur.cCode                    = phbuffer::ident_u
        ttUtilisateur.cCodeProfil              = phbuffer::profil_u
        ttUtilisateur.cNom                     = phbuffer::nom
        ttUtilisateur.cEmail                   = phbuffer::email
        ttUtilisateur.cInitiales               = phbuffer::initiales
        ttUtilisateur.cCompte                  = phbuffer::cptutil
        ttUtilisateur.cAccordMessage           = phbuffer::cdaccord
        ttUtilisateur.cCodeUtilSignataire1     = phbuffer::signataire1
        ttUtilisateur.cCodeUtilSignataire2     = phbuffer::signataire2
        ttUtilisateur.cCodeUtilSignataireEvent = phbuffer::code1
        ttUtilisateur.cTypeRechercheTiers      = phbuffer::cTypeRecherche  /* C/T */
        ttUtilisateur.cTypeRechercheEvent      = phbuffer::cIdentEvent     /* R/T/I/C */
        ttUtilisateur.lActif                   = phbuffer::fg-actif
        ttUtilisateur.lIdentGiDemat            = phbuffer::fg-mdpgidemat
        ttUtilisateur.lGiprint                 = phbuffer::fg-giprint
        ttUtilisateur.cInfosGED                = phbuffer::GEd
        ttUtilisateur.iPaletteCouleur          = phbuffer::palette
        ttUtilisateur.iNumeroTiers             = phbuffer::notie
        ttUtilisateur.cTypeRole                = phbuffer::tprol
        ttUtilisateur.iNumeroRole              = phbuffer::norol
        ttUtilisateur.cNomRole                 = phbuffer::lnom1
        ttUtilisateur.cPrenomRole              = phbuffer::lpre1
        ttUtilisateur.cCodeLangue              = string(tparam.cdlng) when available tparam
        ttUtilisateur.cImprimante              = tparam.printer-field when available tparam
    .
end procedure.
