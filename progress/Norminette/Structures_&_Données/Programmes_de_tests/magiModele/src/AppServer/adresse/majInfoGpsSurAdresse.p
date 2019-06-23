/*------------------------------------------------------------------------
File        : majInfoGpsSurAdresse.p
Purpose     :
Author(s)   : LGI/NPO - 2016/12/16
Notes       :
derniere revue: 2018/05/22 - phm: KO
        traiter les todo et enlever les messages
------------------------------------------------------------------------*/
{preprocesseur/nature2voie.i}
{preprocesseur/type2bien.i}

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{adresse/include/listeMajInfoGpsSurAdresse.i}

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

procedure ListeAdresse:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input  parameter poCollection as collection no-undo.
    define output parameter table for ttListeMajInfoGpsSurAdresse.

    empty temp-table ttListeMajInfoGpsSurAdresse.
    run listeAdresseImmeuble(poCollection).

end procedure.

procedure ListeAdresseImmeuble private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    TODO   : créer un index codePostal sur adres !? whole index!
    ------------------------------------------------------------------------------*/
    define input parameter poCollection as collection no-undo.

    define variable viImm        as integer   no-undo.
    define variable viImmDeb     as integer   no-undo.
    define variable viImmFin     as integer   no-undo.
    define variable vcCodepostal as character no-undo.
    define variable vcCpostDeb   as character no-undo.
    define variable vcCpostFin   as character no-undo.

    define buffer ladrs    for ladrs.
    define buffer adres    for adres.

    assign
        viImm        = poCollection:getInteger("iImm")
        viImmDeb     = poCollection:getInteger("iImmDeb")
        viImmFin     = poCollection:getInteger("iImmFin")
        vcCodepostal = poCollection:getCharacter("cCp")
        vcCpostDeb   = poCollection:getCharacter("cCpDeb")
        vcCpostFin   = poCollection:getCharacter("cCpFin")
    .

message "a0000000 " viImm "//" viImmdeb "//" viImmfin "//" vcCodepostal "//" vcCpostDeb "//" vcCpostfin.

    {&_proparse_ prolint-nowarn(when)}
    assign
        viImm    = 0        when viImm = ?
        viImmDeb = viImm    when viImmDeb = 0 or viImmDeb = ?
        viImmFin = viImmDeb when viImmFin = 0 or viImmFin = ?
        vcCodepostal = ""           when vcCodepostal = ?
        vcCpostDeb   = vcCodepostal when vcCpostDeb = "" or vcCpostDeb = ?
        vcCpostFin   = vcCpostDeb   when vcCpostFin = "" or vcCpostFin = ?
    .
    {&_proparse_ prolint-nowarn(when)}
    // Attention, viImmFin et vcCpFin étant modifié dans le précédent assign, on ne peut pas fusionner les assign.
    assign
        viImmFin   = 99999    when viImmFin   = 0
        vcCpostFin = "99999"  when vcCpostFin = ""
    .

message "a11111111111 " viImm "//" viImmdeb "//" viImmfin "//" vcCodepostal "//" vcCpostDeb "//" vcCpostfin.

    {&_proparse_ prolint-nowarn(wholeindex)}
boucle:
    for each adres no-lock
       where adres.cdpos >= vcCpostDeb
         and adres.cdpos <= vcCpostFin
     , each ladrs no-lock
       where ladrs.noadr = adres.noadr
         and ladrs.noidt >= viImmDeb
         and ladrs.noidt <= viImmFin
         and (ladrs.tpidt >= {&TYPEBIEN-borneinf} and ladrs.tpidt <= {&TYPEBIEN-bornesup}):
        if can-find(first ttListeMajInfoGpsSurAdresse
                    where ttListeMajInfoGpsSurAdresse.cCodeNumeroBis  = ladrs.cdadr
                      and ttListeMajInfoGpsSurAdresse.cIdentification = adres.cpad2
                      and ttListeMajInfoGpsSurAdresse.cNumeroVoie     = trim(ladrs.novoi)
                      and ttListeMajInfoGpsSurAdresse.cCodeNatureVoie = adres.ntvoi
                      and ttListeMajInfoGpsSurAdresse.cNomVoie        = adres.lbvoi
                      and ttListeMajInfoGpsSurAdresse.cComplementVoie = adres.cpvoi
                      and ttListeMajInfoGpsSurAdresse.cCodePostal     = trim(adres.cdpos)
                      and ttListeMajInfoGpsSurAdresse.cVille          = trim(adres.lbvil)
                      and ttListeMajInfoGpsSurAdresse.cCodePays       = adres.cdpay) then next boucle.

        create ttListeMajInfoGpsSurAdresse.
        assign
            ttListeMajInfoGpsSurAdresse.cCodeTypeIdentifiant    = string(ladrs.tpidt)
            ttListeMajInfoGpsSurAdresse.cLibelleTypeIdentifiant = ""
            ttListeMajInfoGpsSurAdresse.CRUD                    = 'R'
            ttListeMajInfoGpsSurAdresse.iNumeroLien             = ladrs.nolie
            ttListeMajInfoGpsSurAdresse.iNumeroIdentifiant      = ladrs.noidt
            ttListeMajInfoGpsSurAdresse.cCodeTypeAdresse        = ladrs.tpadr
            ttListeMajInfoGpsSurAdresse.cLibelleTypeAdresse     = outilTraduction:getLibelleParam("TPADR", ladrs.tpadr)
            ttListeMajInfoGpsSurAdresse.cCodeFormat             = ladrs.tpfrt
            ttListeMajInfoGpsSurAdresse.cLibelleFormat          = outilTraduction:getLibelleParam("FTADR", ladrs.tpfrt)
            ttListeMajInfoGpsSurAdresse.cIdentification         = adres.cpad2
            ttListeMajInfoGpsSurAdresse.cNumeroVoie             = trim(ladrs.novoi)
            ttListeMajInfoGpsSurAdresse.cCodeNumeroBis          = ladrs.cdadr
            ttListeMajInfoGpsSurAdresse.cLibelleNumeroBis       = outilTraduction:getLibelleParam("CDADR", ladrs.cdadr)
            ttListeMajInfoGpsSurAdresse.cLibelleNumeroBisCourt  = outilTraduction:getLibelleParam("CDADR", ladrs.cdadr, 'c')
            ttListeMajInfoGpsSurAdresse.cCodeNatureVoie         = adres.ntvoi
            ttListeMajInfoGpsSurAdresse.cLibelleNatureVoie      = if adres.ntvoi = {&NATUREVOIE--} then "" else outilTraduction:getLibelleParam("NTVOI", adres.ntvoi)
            ttListeMajInfoGpsSurAdresse.cLibelleNatureVoieCourt = if adres.ntvoi = {&NATUREVOIE--} then "" else outilTraduction:getLibelleParam("NTVOI", adres.ntvoi, 'c')
            ttListeMajInfoGpsSurAdresse.cNomVoie                = adres.lbvoi
            ttListeMajInfoGpsSurAdresse.cComplementVoie         = adres.cpvoi
            ttListeMajInfoGpsSurAdresse.cCodePostal             = trim(adres.cdpos)
            ttListeMajInfoGpsSurAdresse.cBureauDistributeur     = adres.lbbur
            ttListeMajInfoGpsSurAdresse.cVille                  = trim(adres.lbvil)
            ttListeMajInfoGpsSurAdresse.cCodePays               = adres.cdpay
            ttListeMajInfoGpsSurAdresse.cLibellePays            = trim(caps(outilTraduction:getLibelleParam("CDPAY", adres.cdpay, mToken:iCodeLangueSession, mToken:iCodeLangueReference)))
            ttListeMajInfoGpsSurAdresse.cLibelle                = outilFormatage:formatageAdresse(ladrs.tpidt, ladrs.noidt, ladrs.nolie, mToken:iCodeLangueSession, mToken:iCodeLangueReference)
            ttListeMajInfoGpsSurAdresse.dtTimestampAdres        = datetime(adres.dtmsy, adres.hemsy)
            ttListeMajInfoGpsSurAdresse.dtTimestampLadrs        = datetime(ladrs.dtmsy, ladrs.hemsy)
            ttListeMajInfoGpsSurAdresse.rRowid                  = rowid(adres)
        .
    end.

end procedure.

procedure ListeAdresseFournisseur private:
    /*------------------------------------------------------------------------------
    Purpose:
    TODO   : integer(mToken:cRefPrincipale) - peut-être pas le bon soc-cd!!!!!
    Notes  : service
    1° On a pas le droit de ne pas utiliser 'soc-cd', tous les index (en dehors de four-adr) ont soc-cd en premier champ.
    2° Il faut pouvoir utiliser le bon index, pour cela mettre une heuristique entre four-cle et cp!
        index candidats: four-cle-type (soc-cd, type-four, four-cle), four-cp-type (soc-cd, type-four, cp, nom),
    heuristique:
        si vcFourCleDeb = vcFourCleFin, ifour.four-cle = vcFourCleDeb
        si vcFourCleDeb = "" ET vcFourCleFin = "99999", pas de critère ifour.four-cle
        si vcFourCleFin = "99999", pas de 'and ifour.four-cle <= vcFourCleFin'
        si vcCpDeb = vcCpFin, ifour.cp = vcCpDeb
        si vcCpDeb = "" ET vcCpFin = "99999", pas de critère ifour.cp
        si vcCpFin = "99999", pas de 'and ifour.cp <= vcCpFin'
        Si aucun critère four-cle et cp, on remet four-cle pour utilisation du bon index.
    ------------------------------------------------------------------------------*/
    define input parameter poCollection as collection no-undo.

    define variable viSociete    as integer   no-undo.
    define variable vcFourCle    as character no-undo.
    define variable vcFourCleDeb as character no-undo.
    define variable vcFourCleFin as character no-undo.
    define variable vcCp         as character no-undo.
    define variable vcCpDeb      as character no-undo.
    define variable vcCpFin      as character no-undo.
    define variable vcWhereCle   as character no-undo.
    define variable vcWhereCp    as character no-undo.
    define variable vhQuery      as handle    no-undo.

    define buffer ifour    for ifour.
    define buffer isoc     for isoc.

    assign
        viSociete    = poCollection:getInteger("iSociete")
        vcFourCle    = poCollection:getCharacter("cFourCle")
        vcFourCleDeb = poCollection:getCharacter("cFourCleDeb")
        vcFourCleFin = poCollection:getCharacter("cFourCleFin")
        vcCp         = poCollection:getCharacter("cCp")
        vcCpDeb      = poCollection:getCharacter("cCpDeb")
        vcCpFin      = poCollection:getCharacter("cCpFin")
    .
    {&_proparse_ prolint-nowarn(when)}
    assign
        vcFourCle    = ""           when vcFourCle = ?
        vcFourCleDeb = vcFourCle    when vcFourCleDeb = "" or vcFourCleDeb = ?
        vcFourCleFin = vcFourCleDeb when vcFourCleFin = "" or vcFourCleFin = ?
        vcCp         = ""           when vcCp = ?
        vcCpDeb      = vcCp         when vcCpDeb = "" or vcCpDeb = ?
        vcCpFin      = vcCpDeb      when vcCpFin = "" or vcCpFin = ?
    .
    {&_proparse_ prolint-nowarn(when)}
    assign
        vcFourCleFin = "99999" when vcFourCleFin = ""
        vcCpFin      = "99999" when vcCpFin = ""
    .

message "a11111111111 " vcFourCle "//" vcFourCledeb "//" vcFourclefin "//" vcCp "//" vcCpdeb "//" vcCpfin.

    if vcFourCleDeb = vcFourCleFin then vcWhereCle = substitute('ifour.four-cle = "&1"', vcFourCleDeb).
    if vcFourCleFin = "99999"
    then vcWhereCle = substitute('ifour.four-cle >= "&1"', vcFourCleDeb).
    else vcWhereCle = substitute('ifour.four-cle >= "&1" and ifour.four-cle <= "&2"', vcFourCleDeb, vcFourCleFin).

    if vcCpDeb = vcCpFin then vcWhereCp = substitute('ifour.cp = "&1"', vcCpDeb).
    if vcCpFin = "99999"
    then vcWhereCp = substitute('ifour.cp >= "&1"', vcCpDeb).
    else vcWhereCp = substitute('ifour.cp >= "&1" and ifour.cp <= "&2"', vcCpDeb, vcCpFin).

    {&_proparse_ prolint-nowarn(weakchar)}
    if vcWhereCle = '' and vcWhereCp = ''
    then vcWhereCle = 'ifour.four-cle >= ""'.
    else if vcWhereCle = ''
        then vcWhereCle = vcWhereCp.
        else if vcWhereCp > '' then vcWhereCle = vcWhereCle + ' and ' + vcWhereCp.    // else vcWhereCle = vcWhereCle.

    if viSociete > 0
    then do:
        create query vhQuery.
        vhQuery:set-buffers(buffer ifour:handle).
        vhQuery:query-prepare(substitute(
            'for each ifour no-lock where ifour.soc-cd = &1 and ifour.fg-actif and ifour.type-four = "f" and &2', viSociete, vcWhereCle)).
        vhQuery:query-open().
boucle:
        repeat:
            vhQuery:get-next().
            if vhQuery:query-off-end then leave boucle.
            run createInfoGps(buffer ifour).
        end.
        vhQuery:query-close().
        delete object vhQuery.
    end.
    else for each isoc no-lock:
        create query vhQuery.
        vhQuery:set-buffers(buffer ifour:handle).
        vhQuery:query-prepare(substitute(
            'for each ifour no-lock where ifour.soc-cd = &1 and ifour.fg-actif and ifour.type-four = "f" and &2', isoc.soc-cd, vcWhereCle)).
        vhQuery:query-open().
boucle:
        repeat:
            vhQuery:get-next().
            if vhQuery:query-off-end then leave boucle.
            run createInfoGps(buffer ifour).
        end.
        vhQuery:query-close().
        delete object vhQuery.
    end.

end procedure.

procedure createInfoGps private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define parameter buffer ifour for ifour.

    define buffer iadrfour for iadrfour.

    create ttListeMajInfoGpsSurAdresse.
    assign
        ttListeMajInfoGpsSurAdresse.cCodeTypeIdentifiant    = "four"
        ttListeMajInfoGpsSurAdresse.cLibelleTypeIdentifiant = "fournisseur"
        ttListeMajInfoGpsSurAdresse.CRUD                    = 'R'
        ttListeMajInfoGpsSurAdresse.iFourSociete            = ifour.soc-cd
        ttListeMajInfoGpsSurAdresse.cFourCle                = ifour.four-cle
        ttListeMajInfoGpsSurAdresse.cCodeTypeAdresse        = ""
        ttListeMajInfoGpsSurAdresse.cLibelleTypeAdresse     = ""
        ttListeMajInfoGpsSurAdresse.cCodeFormat             = ""
        ttListeMajInfoGpsSurAdresse.cLibelleFormat          = ""
        ttListeMajInfoGpsSurAdresse.cIdentification         = ""
        ttListeMajInfoGpsSurAdresse.cNumeroVoie             = ""
        ttListeMajInfoGpsSurAdresse.cCodeNumeroBis          = ""
        ttListeMajInfoGpsSurAdresse.cLibelleNumeroBis       = ""
        ttListeMajInfoGpsSurAdresse.cLibelleNumeroBisCourt  = ""
        ttListeMajInfoGpsSurAdresse.cCodeNatureVoie         = ""
        ttListeMajInfoGpsSurAdresse.cLibelleNatureVoie      = ""
        ttListeMajInfoGpsSurAdresse.cLibelleNatureVoieCourt = ""
        ttListeMajInfoGpsSurAdresse.cNomVoie                = ifour.adr[1]
        ttListeMajInfoGpsSurAdresse.cComplementVoie         = ifour.adr[2]
        ttListeMajInfoGpsSurAdresse.cCodePostal             = trim(ifour.cp)
        ttListeMajInfoGpsSurAdresse.cBureauDistributeur     = ""
        ttListeMajInfoGpsSurAdresse.cVille                  = trim(ifour.ville)
        ttListeMajInfoGpsSurAdresse.cCodePays               = ifour.libpays-cd
        ttListeMajInfoGpsSurAdresse.cLibellePays            = getLibellePaysFournisseur(ifour.soc-cd, ifour.libpays-cd)
        ttListeMajInfoGpsSurAdresse.cLibelle                = (if ifour.adr[1] > "" then trim(ifour.adr[1]) + " " else "")
                                                            + (if ifour.adr[2] > "" then trim(ifour.adr[2]) + " " else "")
                                                            + (if ifour.adr[3] > "" then trim(ifour.adr[3]) + " " else "")
                                                            + caps(trim(ifour.cp) + " " + trim(ifour.ville))
        ttListeMajInfoGpsSurAdresse.rRowid                  = rowid(ifour)
    .
    for each iadrfour no-lock
        where iadrfour.soc-cd   = ifour.soc-cd
          and iadrfour.four-cle = ifour.four-cle:
        create ttListeMajInfoGpsSurAdresse.
        assign
            ttListeMajInfoGpsSurAdresse.cCodeTypeIdentifiant    = "fourcomp"
            ttListeMajInfoGpsSurAdresse.cLibelleTypeIdentifiant = "fournisseur complement"
            ttListeMajInfoGpsSurAdresse.CRUD                    = 'R'
            ttListeMajInfoGpsSurAdresse.iFourSociete            = ifour.soc-cd
            ttListeMajInfoGpsSurAdresse.cFourCle                = ifour.four-cle
            ttListeMajInfoGpsSurAdresse.iFourTypeAdr            = iadrfour.libadr-cd
            ttListeMajInfoGpsSurAdresse.iFourNumAdr             = iadrfour.adr-cd
            ttListeMajInfoGpsSurAdresse.cCodeTypeAdresse        = ""
            ttListeMajInfoGpsSurAdresse.cLibelleTypeAdresse     = ""
            ttListeMajInfoGpsSurAdresse.cCodeFormat             = ""
            ttListeMajInfoGpsSurAdresse.cLibelleFormat          = ""
            ttListeMajInfoGpsSurAdresse.cIdentification         = ""
            ttListeMajInfoGpsSurAdresse.cNumeroVoie             = ""
            ttListeMajInfoGpsSurAdresse.cCodeNumeroBis          = ""
            ttListeMajInfoGpsSurAdresse.cLibelleNumeroBis       = ""
            ttListeMajInfoGpsSurAdresse.cLibelleNumeroBisCourt  = ""
            ttListeMajInfoGpsSurAdresse.cCodeNatureVoie         = ""
            ttListeMajInfoGpsSurAdresse.cLibelleNatureVoie      = ""
            ttListeMajInfoGpsSurAdresse.cLibelleNatureVoieCourt = ""
            ttListeMajInfoGpsSurAdresse.cNomVoie                = iadrfour.adr[1]
            ttListeMajInfoGpsSurAdresse.cComplementVoie         = iadrfour.adr[2]
            ttListeMajInfoGpsSurAdresse.cCodePostal             = trim(iadrfour.cp)
            ttListeMajInfoGpsSurAdresse.cBureauDistributeur     = ""
            ttListeMajInfoGpsSurAdresse.cVille                  = trim(iadrfour.ville)
            ttListeMajInfoGpsSurAdresse.cCodePays               = iadrfour.libpays-cd
            ttListeMajInfoGpsSurAdresse.cLibellePays            = getLibellePaysFournisseur(ifour.soc-cd, iadrfour.libpays-cd)
            ttListeMajInfoGpsSurAdresse.cLibelle                = (if iadrfour.adr[1] > "" then trim(iadrfour.adr[1]) + " " else "")
                                                                + (if iadrfour.adr[2] > "" then trim(iadrfour.adr[2]) + " " else "")
                                                                + (if iadrfour.adr[3] > "" then trim(iadrfour.adr[3]) + " " else "")
                                                                + caps(trim(iadrfour.cp) + " " + trim(iadrfour.ville))
            ttListeMajInfoGpsSurAdresse.rRowid                  = rowid(iadrfour)
        .
    end.
end procedure.
