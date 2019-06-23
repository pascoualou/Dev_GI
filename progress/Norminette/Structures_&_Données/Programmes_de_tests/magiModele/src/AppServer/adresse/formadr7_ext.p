/*------------------------------------------------------------------------
File        : formAdr7_ext.p
Purpose     : Lien ADB => Compta : retourne adresse immeuble
Author(s)   : LGI/RT 1997/04/01 - kantena 2016/11/30
Notes       :
------------------------------------------------------------------------*/

using outils.outilTraduction.
{preprocesseur/type2bien.i}

procedure getAdresseFormat7:
    /*------------------------------------------------------------------------------
    purpose: Récupération des infos adresse d'un immeuble
    Note   : service utilisé dans pontImmeubleCompta.p
    TODO   : Mettre la proc dans pont.. et supprimer ce prog!?
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroImmeuble as integer   no-undo.
    define output parameter pcNomImmeuble    as character no-undo format "X(32)" initial '?.?.?'.
    define output parameter pcZoneAdr1       as character no-undo format "X(32)" initial '?.?.?'.
    define output parameter pcZoneAdr2       as character no-undo format "X(32)" initial '?.?.?'.
    define output parameter pcCodePostal     as character no-undo format "X(32)" initial '?.?.?'.
    define output parameter pcNomVille       as character no-undo format "X(32)" initial '?.?.?'.
    define output parameter pcCodePays       as character no-undo format "X(32)" initial '?.?.?'.

    define variable vcCodeVoie   as character no-undo.
    define variable vcNatureVoie as character no-undo.
    define variable vcLibelleTmp as character no-undo.
    define buffer imble for imble.
    define buffer ladrs for ladrs.
    define buffer adres for adres.

    for first imble no-lock
        where imble.noimm = piNumeroImmeuble
      , first ladrs no-lock          /* Recherche du lien adresse princ. de l'Immeuble */
        where ladrs.tpidt = {&TYPEBIEN-immeuble}
          and ladrs.noidt = piNumeroImmeuble
          and ladrs.tpadr = "00001"
      , first adres no-lock          /* Recherche de l'adresse                         */
        where adres.noadr = ladrs.noadr:
        assign
            vcCodeVoie   = outilTraduction:getLibelleParam("CDADR", ladrs.cdadr, "c")
            vcNatureVoie = outilTraduction:getLibelleParam("NTVOI", adres.ntvoi, "c")
            pcNomImmeuble= imble.lbnom
            pcZoneAdr1   = if ladrs.novoi <> "0" then ladrs.novoi else ""
            pcZoneAdr1   = if vcCodeVoie > "" then substitute('&1 &2', trim(pcZoneAdr1), vcCodeVoie) else trim(pcZoneAdr1)
            pcZoneAdr1   = substitute('&1 &2', trim(pcZoneAdr1), vcNatureVoie)
            vcLibelleTmp = trim(pcZoneAdr1)
            pcZoneAdr1   = substitute('&1 &2', trim(pcZoneAdr1), adres.lbvoi)
            pcZoneAdr2   = adres.cpvoi
            pcCodePostal = adres.cdpos
            pcNomVille   = trim(adres.lbvil)
            pcCodePays   = substring(adres.cdpay, 3, 3, 'character')
        no-error.

        /* Si nom immeuble = "" => <nom_voie> (no rue, <ville>)  */
        if pcNomImmeuble = "" or pcNomImmeuble = ?
        then assign
            vcLibelleTmp  = (if vcLibelleTmp > "" then vcLibelleTmp + ", " else "")
            pcNomImmeuble = substitute('&1 (&2&3)', trim(adres.lbvoi), vcLibelleTmp, trim(adres.lbvil))
        no-error.
    end.
    assign error-status:error = false no-error. /* reset error-status */
    return.                                     /* reset return-value */

end procedure.
