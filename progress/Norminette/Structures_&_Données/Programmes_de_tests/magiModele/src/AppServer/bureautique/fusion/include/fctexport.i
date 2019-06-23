/*------------------------------------------------------------------------
File        : fctexport.i
Description : Décodage organisme sociaux pour lecture orsoc OU ifour
Author(s)   :  , kantena - 2018/01/15
Notes       : appelé par extractionImmeuble.p, ...
----------------------------------------------------------------------*/
{preprocesseur/type2telephone.i}

function setInfoAdresse returns logical(input-output poRole as class bureautique.fusion.classe.fusionRole,
piSociete as integer, piCodeTitre as integer, pcFormulePolitesse as character, pcNom as character):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define buffer ilibrais for ilibrais.

    find first ilibrais no-lock
        where ilibrais.soc-cd     = piSociete
          and ilibrais.librais-cd = piCodeTitre no-error.
    if available ilibrais then do:
        case ilibrais.librais-cd:
            /* Société - Société par actions simplifiée */
            when 1 or when 7 then assign
                poRole:titre               = outilTraduction:getLibelle(701047)
                poRole:titreLettre         = outilTraduction:getLibelle(104203)
                /* ajout SY le 13/05/2009 - forme juridique */
                poRole:formeJuridiqueLong  = ilibrais.lib
                poRole:formeJuridiqueCourt = ilibrais.lib
            .
            /* S.A - S.A.R.L. - S.C.I. - S.N.C - SCP - ETS */
            when 2 or when 3 or when 5 or when 6 or when 8 or when 51 then assign
                poRole:titre       = ilibrais.lib
                poRole:titreLettre = outilTraduction:getLibelle(104203)
                /* ajout SY le 13/05/2009 - forme juridique */
                poRole:formeJuridiqueLong  = ilibrais.lib
                poRole:formeJuridiqueCourt = ilibrais.lib
            .
            /* Maitre */
            when 14 then assign
                poRole:titre       = outilTraduction:getLibelle(101903) 
                poRole:titreLettre = outilTraduction:getLibelle(106201) + " " + poRole:titre
            .
            /* Monsieur - Madame */
            when 10 or when 11 then assign
                poRole:titre       = ilibrais.lib
                poRole:titre       = trim(substring(poRole:titre, 1, 1, "character") + lc(substring(poRole:titre, 2, length(poRole:titre, "character"), "character")))
                poRole:titreLettre = poRole:titre
            .
            /* Succursale - Agence - Association - Assurances - Cabinet - Compagnie - Entreprise - Etude
               Imprimerie - Librairie - Papeterie - Transports - Magasin - Maison */
            when 04 or when 20 or when 21 or when 22 or when 30 or when 31 or when 50 or when 52 or when 60
         or when 61 or when 62 or when 70 or when 80 or when 81 then assign
                poRole:titre       = ilibrais.lib
                poRole:titre       = trim(substring(poRole:titre, 1, 1, "character") + lc(substring(poRole:titreLettre, 2, length(poRole:titre, "character"), "character")))
                poRole:titreLettre = outilTraduction:getLibelle(104203)
            .
            /* Mr & Mme */
            when 12 then assign
                poRole:titre       = substitute('&1 &2 &3', outilTraduction:getLibelle(701645), outilTraduction:getLibelle(102161), outilTraduction:getLibelle(701650))
                poRole:titreLettre = substitute('&1, &2',   outilTraduction:getLibelle(701645), outilTraduction:getLibelle(701650))
            .
            /* Mlle */
            when 13 then assign
                poRole:titre       = outilTraduction:getLibelle(701649)
                poRole:titreLettre = poRole:titre
            .
            /* Le reste */
            otherwise assign
                poRole:titre       = if ilibrais.lib = "-" then "" else ilibrais.lib
                poRole:titreLettre = if poRole:titre > "" then poRole:titre else outilTraduction:getLibelle(104203)
            .
        end case.
        poRole:civilite = poRole:titre.
        /* Surcharge de titreLettre avec nouvelle gestion civilité et politesse */
        if entry(1, pcFormulePolitesse, "|") = "S"
        then poRole:titreLettre = ilibrais.PolitesseStandard.
        else if entry(1, pcFormulePolitesse, "|") = "SC"
             then poRole:titreLettre = ilibrais.PolitesseCher.
             else if entry(1, pcFormulePolitesse, "|") = "L"
                  then poRole:titreLettre = (if num-entries(pcFormulePolitesse, "|") >= 2 then entry(2, pcFormulePolitesse, "|") else "").
        poRole:formulePolitesse = (if num-entries(pcFormulePolitesse, "|") >= 3 then entry(3, pcFormulePolitesse, "|") else "").
    end.
    assign
        poRole:nom        = trim(pcNom)
        poRole:nomUsuel   = poRole:nom
        poRole:nomComplet = (if poRole:titre > "" then poRole:titre + " " else "") + poRole:nom
    .
end function.

function CreNomDoc return character(piNumeroDocument as integer):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    todo : valoriser RpWrdEve
    ------------------------------------------------------------------------------*/
    define variable vcNomFichierDocument   as character no-undo.
    define variable vcNomFIchierTemp       as character no-undo.
    define variable vcNomDocumentTemp      as character no-undo.
    define variable vcaamm                 as character no-undo.
    define variable vcaammjj               as character no-undo.
    define variable vcReferenceChrono      as character no-undo.
    define variable vcReferenceUtilisateur as character no-undo.
    define variable vcReferenceContrat     as character no-undo.
    define variable vcRepertoire           as character no-undo.
    define variable viBoucle               as integer   no-undo.
    define variable RpWrdEve      as character no-undo.
    define variable GlColUse      as integer   no-undo.

    define buffer lidoc   for lidoc.
    define buffer tutil   for tutil.
    define buffer pclie   for pclie.
    define buffer vbDocum for docum.

    /* Creation du repertoire mensuel */
    assign
        vcaamm                 = string((year(today) modulo 100) * 100 + month(today), "9999")
        vcRepertoire            = RpWrdEve + "docum~\" + vcaamm
        vcReferenceUtilisateur = substring(mtoken:cUser, 1, 3, "character")
    .
    if search(vcRepertoire + "~\lisezmoi.txt") = ? then do:
        os-command silent value("mkdir " + vcRepertoire).
        os-command silent value(substitute("echo &1>&2~\lisezmoi.txt", today, vcRepertoire)).
    end.
    /* Référence contrat */
    find first lidoc no-lock
         where (lidoc.tpidt = {&TYPECONTRAT-bail} or lidoc.tpidt = {&TYPECONTRAT-titre2copro})
           and  lidoc.nodoc = piNumeroDocument no-error.
    if available lidoc 
    then vcReferenceContrat = string(lidoc.noidt, "9999999999").   /* modif SY le 15/09/2008 */
    else do:
        find first lidoc no-lock
             where (lidoc.tpidt = {&TYPECONTRAT-mandat2Gerance} or lidoc.tpidt = {&TYPECONTRAT-mandat2Syndic})
               and  lidoc.nodoc = piNumeroDocument no-error.
        if available lidoc 
        then vcReferenceContrat = string(lidoc.noidt, "99999").
        else do:
            find first lidoc no-lock
                 where lidoc.tpidt = {&TYPEBIEN-Immeuble}
                   and lidoc.nodoc = piNumeroDocument no-error.
            vcReferenceContrat = if available lidoc then string(lidoc.noidt, "99999") + "I" else "Cab".
        end.
    end.
    assign
        vcaammjj          = vcaamm + string(day(today), "99")    /* Référence date */
        vcReferenceChrono = "00001"                              /* Référence chrono */
    .
    do while search(substitute("&1/&2-&3-&4-&5.doc", vcRepertoire, vcReferenceContrat, vcReferenceUtilisateur, vcaammjj, vcReferenceChrono)) > "":
        vcReferenceChrono = string(integer(vcReferenceChrono) + 1, "99999").
    end.
    /* Ancien mode ou nouveau mode de référencement dossier */
    find first pclie no-lock
        where pclie.tppar = "RFDOS"
          and pclie.int01 = 1              /* Champ selectionné */
          and pclie.int03 = 0  no-error.   /* Champ non obligatoire */
    if not available pclie /* Ancien référencement */ 
    then vcNomFichierDocument = substitute("&1-&2-&3-&4.doc", vcReferenceContrat, vcReferenceUtilisateur, vcaammjj, vcReferenceChrono). /*--> Nom du document */
    else do:               /* Nouvelle méthode */
        for each pclie no-lock
            where pclie.tppar = "RFDOS"
              and pclie.int01 = 1 /* Champ selectionné */
            by pclie.int02:
            case pclie.zon01:
                when "REFERENCE" then vcNomFIchierTemp = string(mtoken:cRefprincipale, "99999").
                when "REDACTEUR" then for first tutil no-lock
                    where tutil.ident_u = mtoken:cUser:
                    vcNomFIchierTemp = tutil.initiales.
                end.
                when "GESTIONNAIRE" then do:
                    find first vbDocum no-lock
                        where vbDocum.nodoc = piNumeroDocument no-error.
                    if available vbDocum
                    then find first tutil no-lock
                        where tutil.tprol = {&TYPEROLE-gestionnaire}
                          and tutil.norol = vbDocum.noges no-error.
                    else find first tutil no-lock
                        where tutil.tprol = {&TYPEROLE-gestionnaire}
                          and tutil.norol = GlColUse no-error.
                    if available tutil then vcNomFIchierTemp = tutil.initiales.
                end.
                when "CONTRAT"   then vcNomFIchierTemp = vcReferenceContrat.
                when "DATE"      then vcNomFIchierTemp = string(year(today), "9999") + string(month(today), "99") + string(day(today), "99").
                when "ANNEEMOIS" then vcNomFIchierTemp = string(year(today), "9999") + string(month(today), "99").
                when "CHRONO"    then vcNomFIchierTemp = "[CHRONO2]".
            end case.
            /* Ajout du champ */
            if vcNomFIchierTemp > "" then vcNomFichierDocument = vcNomFichierDocument + "-" + vcNomFIchierTemp.
        end.
        assign
            /* Ajout de l'extension */
            vcNomFichierDocument = trim(vcNomFichierDocument, "-") + ".doc"
            vcNomFIchierTemp = vcNomFichierDocument
        .
        /* Gestion des chronos car je ne peux pas trouver le chrono avant de savoir comment est constitué le nom du fichier au final */
        if vcNomFichierDocument matches "*[CHRONO1]*"
        then do viBoucle = 1 to 9999:
            vcNomFIchierTemp = replace(vcNomFichierDocument, "[CHRONO1]", string(viBoucle, "9999")).
            if search(vcRepertoire + "/" + vcNomFIchierTemp) = ? then leave.
        end.
        if vcNomFichierDocument matches "*[CHRONO2]*"
        then do viBoucle = 1 to 99999:
            assign
                vcNomFIchierTemp = replace(vcNomFichierDocument, "[CHRONO2]", string(viBoucle, "99999"))
                vcNomDocumentTemp = vcNomFIchierTemp
            .
            if search(vcRepertoire + "/" + vcNomDocumentTemp) = ? then do:
                vcNomDocumentTemp = replace(vcNomFIchierTemp, ".doc", "") + "-00001.doc".        /* SY 0515/0153 à cause du no ordre ajouté dans edition.p ("-" + STRING(iNbOrdre-IO,"99999")) */
                if search(vcRepertoire + "/" + vcNomDocumentTemp) = ? then leave.
            end.
        end.
        vcNomFichierDocument = vcNomFIchierTemp.
    end. /* nouvelle méthode */
    return (vcaamm + "~\" + vcNomFichierDocument).

end function.

function iMoisToCharacter returns character(piNoMoiUse as integer):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define variable vcAnnee as character no-undo.
    define variable vcMois  as character no-undo.

    if piNoMoiUse > 0 then do:
        assign
            vcAnnee = substring(string(piNoMoiUse), 1, 4, "CHARACTER")
            vcMois  = substring(string(piNoMoiUse), 5, 2, "CHARACTER")
        .
        return outilTraduction:getLibelleParam("CDMOI", vcMois) + " " + vcAnnee.
    end.
    return "".
end function.

function dateToCharacter returns character(pdaDate as date):
    /*------------------------------------------------------------------------------
    Purpose: retourne une date formattee en chaine de caractères
    Notes:
    ------------------------------------------------------------------------------*/
    return if pdaDate = ? then "" else string(pdaDate, "99/99/9999").
end function.

function organisme returns character(pcTypeOrganisme as character, pcIdentifiant as character):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define buffer orsoc for orsoc.
    for first orsoc no-lock
        where orsoc.tporg = pcTypeOrganisme
          and orsoc.ident = pcIdentifiant:
        return orsoc.lbnom.
    end.
    return "".
end function.

function usage returns character(pcNatureContrat as character):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    case pcNatureContrat:
        when {&NATURECONTRAT-usageCommercial1953}       or when {&NATURECONTRAT-usageCommercial-2ans}
     or when {&NATURECONTRAT-usageCommercialAccessoire} or when {&NATURECONTRAT-usageEmplacementPublicitaire}
        then return outilTraduction:getLibelle(104779).                 /* Usage Commerciale */
        when {&NATURECONTRAT-usageMixte1989Art17a}      or when {&NATURECONTRAT-usageMixte1989Art17b}
     or when {&NATURECONTRAT-usageMixte1989Art11}       or when {&NATURECONTRAT-usageMixte1948}
     or when {&NATURECONTRAT-usageMixte1982}            or when {&NATURECONTRAT-usageMixteMehaignerie}
     or when {&NATURECONTRAT-usageMixteDroitCommun}
        then return outilTraduction:getLibelle(104780).                 /* Usage Mixte */
        when {&NATURECONTRAT-usageProfessionnel1948}    or when {&NATURECONTRAT-usageProfessionnel1986}
     or when {&NATURECONTRAT-usageProfessionnel1989}
        then return outilTraduction:getLibelle(104781).                 /* Usage Professionnel */
        otherwise return outilTraduction:getLibelle(104778).            /* Usage d'habitation */
    end case.
end function.

function soldeCpt returns decimal(pcTypeContrat as character, piNumeroContrat as integer, piNumeroRole as integer, pcCompte as character, paDateSolde as date):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define variable vcTmp       as character no-undo.
    define variable vcReference as character no-undo.

/* TODO  compta/souspgm/solcpt.p a revoir. Donner des parametres plutot qu'une chaine. */

    vcReference = if (pcTypeContrat = {&TYPECONTRAT-bail} or pcTypeContrat = {&TYPECONTRAT-mandat2Gerance})
                  then mtoken:cRefGerance else mtoken:cRefCopro.
    if pcTypeContrat = {&TYPECONTRAT-bail} or pcTypeContrat = {&TYPECONTRAT-titre2copro}
    then run compta/souspgm/solcpt.p(
        substitute("&1|&2|&3|&4|&5|&6||",
                   vcReference,
                   substring(string(piNumeroContrat, "9999999999"), 1, 5, "character"),
                   pcCompte,
                   substring(string(piNumeroContrat, "9999999999"), 6, 5, "character"),
                   "S",
                   string(paDateSolde, "99/99/9999")),
        output vcTmp
    ).
    else run compta/souspgm/solcpt.p(
        substitute("&1|&2|&3|&4|&5|&6||",
                   vcReference, 
                   string(piNumeroContrat, "99999"),
                   pcCompte,
                   string(piNumeroRole, "99999"),
                   "S",
                   string(paDateSolde, "99/99/9999")),
        output vcTmp
    ).
    return if vcTmp > "" then decimal(entry(1, vcTmp, "|")) / 100 else 0.
end function.

function getLibelleRubqt returns character(piCodeRubrique as integer, piCodeLibelle as integer):
    /*------------------------------------------------------------------------------
     Purpose: 
     Notes:
    ------------------------------------------------------------------------------*/
    define buffer rubqt for rubqt.

    for first rubqt no-lock
        where rubqt.cdrub = piCodeRubrique
          and rubqt.cdlib = piCodeLibelle:
        return trim(outilTraduction:getLibelle(rubqt.nome1)).
    end.
    return "".
end function.

function suppCedex returns character(pcVille as character):
    /*------------------------------------------------------------------------------
     Purpose: supprime le code cedex du champ ville
     Notes:
    ------------------------------------------------------------------------------*/
    return trim(entry(1, pcVille, "cedex")).
end function.

function donneInfosContact returns class bureautique.fusion.classe.fusionRole(
    piSociete as integer, pcCleFournisseur as character, pcTypeAdresse as character):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define variable voRole as class bureautique.fusion.classe.fusionRole no-undo.
    define buffer icontacf for icontacf.

    voRole = new bureautique.fusion.classe.fusionRole().
    find first icontacf no-lock
        where icontacf.soc-cd   = piSociete
          and icontacf.four-cle = pcCleFournisseur
          and icontacf.numero   = integer(pcTypeAdresse) no-error.
    if not available icontacf then return voRole.

    setInfoAdresse(input-output voRole, piSociete, icontacf.librais-cd, icontacf.fopol, icontacf.nom).
    return voRole.
end function.

function montantToCharacter returns character(pdeMontant as decimal, plDevise as logical):
    /*------------------------------------------------------------------------------
    Purpose: retourne une valeur decimal en caractères selon le format
    Notes:
    ------------------------------------------------------------------------------*/
    define variable vcLibelle as character no-undo.

    if pdeMontant = ? then pdeMontant = 0.
    if session:numeric-format = "AMERICAN" 
    then assign
        session:numeric-format = "EUROPEAN"
        vcLibelle = trim(string(pdeMontant, "->>>,>>>,>>9.99"))
        session:numeric-format = "AMERICAN"
    .
    else vcLibelle = trim(string(pdeMontant, "->>>,>>>,>>9.99")).
    /* Ajouter la devise */
    if plDevise then vcLibelle = vcLibelle + " EURO" + (if absolute(pdeMontant) <= 1 then "" else "S").
    return vcLibelle.
end function.

function convChiffre returns character(pdeNombre as decimal):
    /*------------------------------------------------------------------------------
    Purpose: Conversion de chiffre en lettres AVEC DEVISE EUROS
    Notes:
    ------------------------------------------------------------------------------*/
    return outilFormatage:convchiffre(pdeNombre, "EUROS").
end function.
function ConvChifLet returns character(pdeNombre as decimal):
    /*------------------------------------------------------------------------------
    Purpose: Conversion de chiffre en lettres SANS CODE DEVISE
    Notes:
    ------------------------------------------------------------------------------*/
    return outilFormatage:convchiffre(pdeNombre, ?).
end function.
function decMontant returns decimal(pcMontant as character):
    /*------------------------------------------------------------------------------
    Purpose: Retourne un montant formatté en décimal
    Notes:
    ------------------------------------------------------------------------------*/
    define variable vdeMontant as decimal no-undo.

    pcMontant = replace(replace(pcMontant, "EUROS", ""), "EURO", "").
    if session:numeric-format = "AMERICAN"
    then assign
        session:numeric-format = "EUROPEAN"
        vdeMontant             = decimal(pcMontant)
        session:numeric-format = "AMERICAN"
    .
    else vdeMontant = decimal(pcMontant).
    return vdeMontant.
end function.

function bureauDistrib returns character(pcTypeIdentifiant as character, piNumeroIdentifiant as int64, piNumeroDocument as int64):
    /*------------------------------------------------------------------------------
    Purpose: recupere le bureau distributeur
    Notes:
    ------------------------------------------------------------------------------*/
    define variable vcTypeDestinataire as character no-undo initial "00001".
    define variable vcTypeAdresse      as character no-undo initial "00001".
    define variable vcBureauDistri     as character no-undo.
    define variable vcIdentifiant      as character no-undo.
    define variable vcNomTable         as character no-undo.
    define variable vcCodeRegroupement as character no-undo.
    define variable vcLibelleOrganisme as character no-undo.
    define buffer desti    for desti.
    define buffer ladrs    for ladrs.
    define buffer adres    for adres.
    define buffer orsoc    for orsoc.
    define buffer ifour    for ifour.
    define buffer iadrfour for iadrfour.
    /*--> Recherche du parametrage destinataire */
    for first desti no-lock
        where desti.nodoc = piNumeroDocument
          and desti.tprol = pcTypeIdentifiant
          and desti.norol = piNumeroIdentifiant:
        assign
            vcTypeDestinataire = desti.tpdes
            vcTypeAdresse      = desti.tpAdr
        .
    end.
    /* Valorisation de l'adresse */
    find first ladrs no-lock 
        where ladrs.TpIdt = pcTypeIdentifiant
          and ladrs.NoIdt = piNumeroIdentifiant
          and ladrs.tpadr = vcTypeAdresse no-error.
    if available ladrs 
    then for first adres no-lock
        where adres.noadr = ladrs.noadr:
        vcBureauDistri = trim(adres.lbbur).
    end.
    else do:
        run decodOrg(pcTypeIdentifiant, piNumeroIdentifiant, output vcIdentifiant, output vcNomTable, output vcCodeRegroupement, output vcLibelleOrganisme).
        if vcNomTable = "orsoc"
        then for first orsoc no-lock    /* Tiers Orsoc */
            where orsoc.tporg = pcTypeIdentifiant
              and orsoc.ident = vcIdentifiant:
            vcBureauDistri = trim(orsoc.lbvil).
        end.
        else for first ifour no-lock
            where ifour.soc-cd          = mtoken:iCodeSociete
              and ifour.coll-cle        = vcCodeRegroupement
              and integer(ifour.cpt-cd) = piNumeroIdentifiant:
            if vcTypeDestinataire = "00001" 
            then vcBureauDistri = trim(ifour.ville).
            else for first iadrfour no-lock
                where iadrfour.soc-cd    = ifour.soc-cd
                  and iadrfour.etab-cd   = ifour.etab-cd
                  and iadrfour.four-cle  = ifour.four-cle
                  and iadrfour.libadr-cd = integer(vcTypeDestinataire) - 1
                  and iadrfour.adr-cd    = integer(vcTypeAdresse):
                vcBureauDistri = trim(iadrfour.ville).
            end.
        end.
    end.
    return vcBureauDistri.
end function.

function libpaysfour returns character(piReference as integer, pcCode as character):
    /*------------------------------------------------------------------------------
     Purpose: retourne le libellé d'un pays
     Notes:
     todo : utiliser CDPAY avec string(integer(pcCode), "99999") !!!
    ------------------------------------------------------------------------------*/
    define buffer ilibpays for ilibpays.

    if pcCode <> "001" 
    then for first ilibpays no-lock
        where ilibpays.soc-cd     = piReference
          and ilibpays.libpays-cd = pcCode:
        return ilibpays.lib.
    end.
    return "".
end function.

function frmDateIndice returns character(piCodePeriodeIndice as integer, piAnneePeriode as integer, piNumeroPeriode as integer):
    /*------------------------------------------------------------------------------
    Purpose: retourne un indice formatté
    Notes:
    ------------------------------------------------------------------------------*/
    case piCodePeriodeIndice:
        /* Indice mensuel */
        when 1 then return outilTraduction:getLibelleParam("CDMOI", string(piNumeroPeriode,"99999")) + " " + string(piAnneePeriode).
        /* Indice trimestriel */
        when 3 then return substitute("&1&2 &3 &4",
                               piNumeroPeriode, 
                               if piNumeroPeriode = 1 then outilTraduction:getLibelle(44) else outilTraduction:getLibelle(24), 
                               outilTraduction:getLibelle(100997), 
                               piAnneePeriode).
        /* Indice semestriel */
        when 6 then return substitute("&1&2 &3 &4",
                               piNumeroPeriode,
                               if piNumeroPeriode = 1 then outilTraduction:getLibelle(44) else outilTraduction:getLibelle(24),
                               outilTraduction:getLibelle(107514),
                               piAnneePeriode).
        when 12 then return string(piAnneePeriode).
    end case.
end function.

function chargeAdresseOrganismeSocial returns class bureautique.fusion.classe.fusionAdresse(
    pcTypeIdentifiant as character, pcCodeIdentifiant as character, piTelephone as integer, pcSaisieLibre as character):
    /*------------------------------------------------------------------------------
    Purpose: charge les infos adresse à partir de orsoc
    Notes:
    ------------------------------------------------------------------------------*/
    define variable voAdresse as class bureautique.fusion.classe.fusionAdresse no-undo.
    define buffer orsoc for orsoc.

    voAdresse = new bureautique.fusion.classe.fusionAdresse().
    for first orsoc no-lock 
        where orsoc.tporg = pcTypeIdentifiant
          and orsoc.ident = pcCodeIdentifiant:
        assign
            voAdresse:adresse        = trim(orsoc.adres)
            voAdresse:complementVoie = trim(orsoc.cpadr)
            voAdresse:codePostal     = trim(orsoc.cdpos)
            voAdresse:ville          = suppCedex(trim(orsoc.lbvil))
            voAdresse:cedex          = trim(orsoc.lbvil)
            voAdresse:identAdresse   = trim(orsoc.lbdiv) /* PL : 25/01/2016 - (Fiche : 0711/0069) */
        .
        case piTelephone:
            when 1 then voAdresse:telephone = orsoc.notel.
            when 2 then voAdresse:telephone = orsoc.nofax.
            when 3 then voAdresse:telephone = pcSaisieLibre.
        end case.
        voAdresse:fax = orsoc.nofax.
    end.
    return voAdresse.
end function.

function chargeAdresseFournisseur returns class bureautique.fusion.classe.fusionAdresse(
    pcTypeIdentifiant as character, piNumeroIdentifiant as int64, pcCodeColl-cle as character,
    pcTypeDestinataire as character, pcTypeAdresse as character, piTelephone as integer, pcSaisieLibre as character):
    /*------------------------------------------------------------------------------
     Purpose: charge les infos adresse à partir d'ifour ou iadrfour
     Notes:
    ------------------------------------------------------------------------------*/
    define variable voAdresse as class bureautique.fusion.classe.fusionAdresse no-undo.
    define buffer ifour      for ifour.
    define buffer iContacf   for iContacf.
    define buffer iAdrFour   for iAdrFour.
    define buffer telephones for telephones.

    voAdresse = new bureautique.fusion.classe.fusionAdresse().
    find first ifour no-lock
        where ifour.soc-cd          = mtoken:iCodeSociete
          and ifour.coll-cle        = pcCodeColl-cle
       // TODO  Pas terrible pour l'index. peut-on ifour.cpt-cd = string(piNumeroIdentifiant, "99999") ??????
       //       quelques exceptions (dues à des erreurs  ?) dans la base.
          and int64(ifour.cpt-cd) = piNumeroIdentifiant no-error.
    if not available ifour then return voAdresse.

    if pcTypeDestinataire = {&TYPETIERS-principal}
    then do:
        assign
            voAdresse:adresse        = trim(ifour.adr[1])
            voAdresse:complementVoie = substitute("&1 &2", trim(ifour.adr[2]), trim(ifour.adr[3]))
            voAdresse:codePostal     = trim(ifour.cp)
            voAdresse:ville          = trim(ifour.ville)
            voAdresse:cedex          = voAdresse:ville
            voAdresse:libellePays    = libpaysfour(ifour.soc-cd, ifour.libpays-cd)
            voAdresse:identAdresse   = ""
        .
        /* PL: 15/06/2010 Nouvelle gestion telephones fournisseurs */
        if piTelephone <> 99 then do: /* 99 = saisie libre */
           // TODO  Pas terrible pour l'index. tpidt + noidt (dans ma base, jusqu'à 11 500 enregistrements pour un couple !!!!!).
           //      décomposé en 2 find !!!!!!!!!!!! Pas terrible pour autant.
           // des index actuels sont inutiles 
            find first telephones no-lock
                where telephones.tpidt    = pcTypeIdentifiant
                  and telephones.noidt    = piNumeroIdentifiant
                  and telephones.soc-cd   = ifour.soc-cd            /* SY 30/10/2015 V12.3 */
                  and telephones.four-cle = ifour.four-cle          /* SY 30/10/2015 */
                  and telephones.nopos    = piTelephone no-error.
            if not available telephones
            then find first telephones no-lock
                where telephones.tpidt    = pcTypeIdentifiant
                  and telephones.noidt    = piNumeroIdentifiant
                  and telephones.soc-cd   = 0                /* SY 30/10/2015 V12.3 */
                  and telephones.four-cle = ifour.four-cle   /* SY 30/10/2015 */
                  and telephones.nopos    = piTelephone no-error.
            voAdresse:telephone = if available telephones then telephones.notel else "".
        end.
        else voAdresse:telephone = pcSaisieLibre.
        assign
            voAdresse:fax  = ifour.fax    /* par defaut = 1er numéro de type fax */
            voAdresse:mail = ifour.email
        .
    end.
    else if pcTypeDestinataire = {&TYPETIERS-secondaire}
    then for first icontacf no-lock
        where icontacf.soc-cd   = ifour.soc-cd
          and icontacf.four-cle = ifour.four-cle
          and icontacf.numero   = integer(pcTypeAdresse):
         assign
             voAdresse:adresse       = trim(icontacf.adr[1])
             voAdresse:complementVoie= trim(icontacf.adr[2]) + " " + TRIM(icontacf.adr[3])
             voAdresse:codePostal    = trim(icontacf.cp)
             voAdresse:ville         = trim(icontacf.ville)
             voAdresse:cedex         = voAdresse:ville
             voAdresse:libellePays   = libpaysfour(icontacf.soc-cd, icontacf.libpays-cd)
             voAdresse:identAdresse  = ""
         .
         /* PL : 15/06/2010 Nouvelle gestion telephones fournisseurs */
         if piTelephone <> 99                   /* 99 = saisie libre */
         then for first telephones no-lock
             where telephones.four-cle  = ifour.four-cle                                      /* SY 30/10/2015 */
               and telephones.libadr-cd = 0
               and telephones.adr-cd    = 0
               and telephones.numero    = integer(pcTypeAdresse)
               and telephones.nopos     = piTelephone
               and telephones.tpidt     = pcTypeIdentifiant
               and telephones.noidt     = piNumeroIdentifiant
               and telephones.soc-cd    = (if telephones.soc-cd > 0 then ifour.soc-cd else 0):  /* SY 30/10/2015 V12.3 */
             voAdresse:telephone = telephones.notel.
        end.
        else voAdresse:telephone = pcSaisieLibre.
        assign
            voAdresse:fax  = icontacf.fax     /* par defaut = 1er numéro de type fax */
            voAdresse:mail = icontacf.email
        .
    end.
    else for first iadrfour no-lock 
        where iadrfour.soc-cd    = ifour.soc-cd
          and iadrfour.four-cle  = ifour.four-cle
          and iadrfour.libadr-cd = integer(pcTypeDestinataire) - 2
          and iadrfour.adr-cd    = integer(pcTypeAdresse):
        assign
            voAdresse:adresse        = trim(iadrfour.adr[1])
            voAdresse:complementVoie = substitute("&1 &2", trim(iadrfour.adr[2]), trim(iadrfour.adr[3]))
            voAdresse:codePostal     = trim(iadrfour.cp)
            voAdresse:ville          = trim(iadrfour.ville)
            voAdresse:cedex          = voAdresse:ville
            voAdresse:libellePays    = libpaysfour(iadrfour.soc-cd, iadrfour.libpays-cd)
            voAdresse:identAdresse   = ""
        .
        /* PL : 15/06/2010 Nouvelle gestion telephones fournisseurs */
        if piTelephone <> 99                   /* 99 = saisie libre */
        then for first telephones no-lock
            where telephones.four-cle  = ifour.four-cle                                    /* SY 30/10/2015       */
              and telephones.libadr-cd = integer(pcTypeDestinataire) - 2
              and telephones.adr-cd    = integer(pcTypeAdresse)
              and telephones.tpidt     = pcTypeIdentifiant
              and telephones.noidt     = piNumeroIdentifiant
              and telephones.soc-cd    = (if telephones.soc-cd > 0 then ifour.soc-cd else 0) /* SY 30/10/2015 V12.3 */
              and telephones.nopos     = piTelephone:
            voAdresse:telephone = telephones.notel.
        end.
        else voAdresse:telephone = pcSaisieLibre.
        assign
            voAdresse:fax  = iadrfour.fax     /* par defaut = 1er numéro de type fax */
            voAdresse:mail = iadrfour.email
        .
    end.
    return voAdresse.
end function.

function chargeQuittance returns class bureautique.fusion.classe.fusionQuittance(piNumeroBail as int64):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define variable voQuittance              as class bureautique.fusion.classe.fusionQuittance no-undo.
    define variable vcDateSortie             as character no-undo.
    define variable vcDateBail               as character no-undo.
    define variable vdeMontantCharges        as decimal   no-undo.
    define variable vdeMontantChargesBail    as decimal   no-undo.
    define variable vdeMontantLoyer          as decimal   no-undo.
    define variable vdeMontantLoyerBail      as decimal   no-undo.
    define variable vdeMontantDroit          as decimal   no-undo.
    define variable vdeMontantDroitBail      as decimal   no-undo.
    define variable vdeMontantHonoraire      as decimal   no-undo.
    define variable vdeMontantHonoraireBail  as decimal   no-undo.
    define variable vdeMontantTVA            as decimal   no-undo.
    define variable vdeMontantTVABail        as decimal   no-undo.
    define variable vdeMontantAdd            as decimal   no-undo.
    define variable vdeMontantAddBail        as decimal   no-undo.
    define variable vdeMontantFrais          as decimal   no-undo.
    define variable vdeMontantFraisBail      as decimal   no-undo.
    define variable vdeMontantEtat           as decimal   no-undo.
    define variable vdeMontantEtatBail       as decimal   no-undo.
    define variable vdeMontantDossier        as decimal   no-undo.
    define variable vdeMontantDossierBail    as decimal   no-undo.
    define variable vdeMontantDepot          as decimal   no-undo.
    define variable vdeMontantDepotBail      as decimal   no-undo.
    define variable vdeMontantChargeFixe     as decimal   no-undo.
    define variable vcLoyer                  as character no-undo.
    define variable vcLoyerBail              as character no-undo.
    define variable vcRubriquesLoyer         as character no-undo.
    define variable vdeLoyerAnnuel           as decimal   no-undo.    /* NP 0707/1046 */
    define variable vdeLoyerAnnuelBail       as decimal   no-undo.    /* NP 0707/1046 */
    define variable vdeChargesAnnuelles      as decimal   no-undo.    /* NP #5501 */
    define variable vdeChargesAnnuellesBail  as decimal   no-undo.    /* NP #5501 */
    define variable viRubrique               as integer   no-undo.
    define variable vdeMontantChargeFixeBail as decimal   no-undo.
    define buffer rubqt for rubqt.
    define buffer aquit for aquit.
    define buffer equit for equit.

    /* Initialisation de la liste des rubriques de loyer */
    vcRubriquesLoyer = "101|104|115|102|110|111|112|140|145|150|152".
    /*--> ENCOURS = 1ere quittance equit */
    find first equit no-lock
        where equit.noloc = piNumeroBail no-error.
    {&_proparse_ prolint-nowarn(use-index)}
    if available equit and equit.mtqtt <> 0 
    then do:
        vcDateSortie = dateToCharacter(equit.dtsor).
        do viRubrique = 1 to equit.nbrub:
            if equit.tbfam[viRubrique] = 02 then assign
                vdeMontantCharges    = vdeMontantCharges    + equit.tbtot[viRubrique]
                vdeMontantChargeFixe = vdeMontantChargeFixe + if equit.tbgen[viRubrique] = "00001" then equit.tbtot[viRubrique] else 0
            .
            if equit.tbfam[viRubrique] = 01 and lookup(string(equit.tbrub[viRubrique]), vcRubriquesLoyer, "|") <> 0 
            then assign
                vdeMontantLoyer = vdeMontantLoyer + equit.tbtot[viRubrique]
                vcLoyer         = substitute("&1&2 : &3&4", vcLoyer, getLibelleRubqt(equit.tbrub[viRubrique], equit.tblib[viRubrique]), montantToCharacter(equit.tbtot[viRubrique], true), chr(10))
            .
            case equit.tbrub[viRubrique]: 
                when 771                         then vdeMontantAdd       = vdeMontantAdd       + equit.tbtot[viRubrique].
                when 750 or when 760 or when 770 then vdeMontantDroit     = vdeMontantDroit     + equit.tbtot[viRubrique].
                when 640 or when 650             then vdeMontantHonoraire = vdeMontantHonoraire + equit.tbtot[viRubrique].
                when 600                         then vdeMontantFrais     = vdeMontantFrais     + equit.tbtot[viRubrique].
                when 626                         then vdeMontantEtat      = vdeMontantEtat      + equit.tbtot[viRubrique].
                when 623                         then vdeMontantDossier   = vdeMontantDossier   + equit.tbtot[viRubrique].
                when 580                         then vdeMontantDepot     = vdeMontantDepot     + equit.tbtot[viRubrique].
            end case.
            if lookup(string(equit.tbrub[viRubrique]), {&ListeRubqtTVA-Calcul})      > 0
            or lookup(string(equit.tbrub[viRubrique]), {&ListeRubqtTVA-variable})    > 0
            or lookup(string(equit.tbrub[viRubrique]), {&ListeRubqtTVA-RappelAvoir}) > 0
            then vdeMontantTVA = vdeMontantTVA + equit.tbtot[viRubrique].
        end.
        assign
            vdeLoyerAnnuel      = vdeMontantLoyer * (12 / integer(substring(equit.pdqtt, 1, 3, "character")))
            vdeChargesAnnuelles = (vdeMontantLoyer + vdeMontantCharges) * (12 / integer(substring(equit.pdqtt, 1, 3, "character")))    /* NP #5501 */
        .
    end.
    else for last aquit no-lock        /* "ENCOURS" = dernière quittance historisée HORS facture locataire */
        where aquit.noloc = piNumeroBail
          and aquit.fgfac = false      /* modif SY le 19/03/2009 */
        use-index ix_aquit03:
        vcDateSortie = dateToCharacter(aquit.dtsor).
        do viRubrique = 1 to aquit.nbrub:
            if integer(entry(12, aquit.tbrub[viRubrique], '|')) = 02 
            then do:
                vdeMontantCharges = vdeMontantCharges + decimal(entry(5, aquit.tbrub[viRubrique], '|')).
                for first rubqt no-lock
                    where rubqt.cdrub = integer(entry(1, aquit.tbrub[viRubrique], "|"))
                      and rubqt.cdlib = integer(entry(2, aquit.tbrub[viRubrique], "|"))
                      and rubqt.cdgen = "00001":
                    vdeMontantChargeFixe = vdeMontantChargeFixe + decimal(entry(5, aquit.tbrub[viRubrique], '|')).
                end.
            end.
            if integer(entry(12, aquit.tbrub[viRubrique], '|')) = 01
            and lookup(entry(1, aquit.tbrub[viRubrique], '|'), vcRubriquesLoyer, "|") <> 0 
            then assign
                vdeMontantLoyer = vdeMontantLoyer + decimal(entry(5, aquit.tbrub[viRubrique], '|')) 
                vcLoyer         = substitute("&1&2 : &3&4", vcLoyer,
                                      getLibelleRubqt(integer(entry(1, aquit.tbrub[viRubrique], '|')), integer(entry(2, aquit.tbrub[viRubrique], '|'))),
                                      montantToCharacter(decimal(entry(5, aquit.tbrub[viRubrique], '|')), true), chr(10))
            .
            case integer(entry(1, aquit.tbrub[viRubrique], '|')):
                when 771                         then vdeMontantAdd       = vdeMontantAdd       + decimal(entry(5, aquit.tbrub[viRubrique], '|')).
                when 750 or when 760 or when 770 then vdeMontantDroit     = vdeMontantDroit     + decimal(entry(5, aquit.tbrub[viRubrique], '|')).
                when 640 or when 650             then vdeMontantHonoraire = vdeMontantHonoraire + decimal(entry(5, aquit.tbrub[viRubrique], '|')).
                when 774 or when 775 or when 776 or
                when 778 or when 753 or when 754 or
                when 755 or when 756 or when 758 then vdeMontantTVA       = vdeMontantTVA     + decimal(entry(5, aquit.tbrub[viRubrique], '|')).
                when 600                         then vdeMontantFrais     = vdeMontantFrais   + decimal(entry(5, aquit.tbrub[viRubrique], '|')).
                when 626                         then vdeMontantEtat      = vdeMontantEtat    + decimal(entry(5, aquit.tbrub[viRubrique], '|')).
                when 623                         then vdeMontantDossier   = vdeMontantDossier + decimal(entry(5, aquit.tbrub[viRubrique], '|')).
                when 580                         then vdeMontantDepot     = vdeMontantDepot   + decimal(entry(5, aquit.tbrub[viRubrique], '|')).
            end case.
        end.
        assign
            vdeLoyerAnnuel      = vdeMontantLoyer * (12 / integer(substring(aquit.pdqtt, 1, 3, "character")))
            vdeChargesAnnuelles = (vdeMontantLoyer + vdeMontantCharges) * (12 / integer(substring(aquit.pdqtt, 1, 3, "character")))    /* NP #5501 */
        .
    end.
    /* BAIL = 1er aquit non FL (démarrage du bail) */
    {&_proparse_ prolint-nowarn(use-index)}
    find first aquit no-lock
        where aquit.noloc = piNumeroBail
          and aquit.fgfac = false
        use-index ix_aquit03 no-error.
    if available aquit then do:
        vcDateBail = dateToCharacter(aquit.dtsor).
        do viRubrique = 1 to aquit.nbrub:
            if integer(entry(12, aquit.tbrub[viRubrique], '|')) = 02 
            then do:
                vdeMontantChargesBail = vdeMontantChargesBail + decimal(entry(5, aquit.tbrub[viRubrique],'|')).
                for first rubqt no-lock
                    where rubqt.cdrub = integer(entry(1, aquit.tbrub[viRubrique], "|"))
                      and rubqt.cdlib = integer(entry(2, aquit.tbrub[viRubrique], "|"))
                      and rubqt.cdgen = "00001": 
                    vdeMontantChargeFixeBail = vdeMontantChargeFixeBail + decimal(entry(5, aquit.tbrub[viRubrique], '|')).
                end.
            end.
            if integer(entry(12, aquit.tbrub[viRubrique], '|')) = 01 
            and lookup(entry(1, aquit.tbrub[viRubrique], '|'), vcRubriquesLoyer,"|") <> 0 
            then assign
                vdeMontantLoyerBail = vdeMontantLoyerBail + decimal(entry(5, aquit.tbrub[viRubrique], '|')) 
                vcLoyerBail         = substitute("&1&2 : &3&4", vcLoyerBail,
                                          getLibelleRubqt(integer(entry(1, aquit.tbrub[viRubrique], '|')), integer(entry(2, aquit.tbrub[viRubrique], '|'))), 
                                          montantToCharacter(decimal(entry(5, aquit.tbrub[viRubrique],'|')), true), chr(10))
            .
            case integer(entry(1,aquit.tbrub[viRubrique],'|')):
                when 771                         then vdeMontantAddBail       = vdeMontantAddBail       + decimal(entry(5, aquit.tbrub[viRubrique], '|')).
                when 750 or when 760 or when 770 then vdeMontantDroitBail     = vdeMontantDroitBail     + decimal(entry(5, aquit.tbrub[viRubrique], '|')).
                when 640 or when 650             then vdeMontantHonoraireBail = vdeMontantHonoraireBail + decimal(entry(5, aquit.tbrub[viRubrique], '|')).
                /*WHEN 774 OR WHEN 775 OR WHEN 776 OR
                WHEN 778 OR WHEN 753 OR WHEN 754 OR
                WHEN 755 OR WHEN 756 OR WHEN 758 THEN vdeMontantTVABail       = vdeMontantTVABail + decimal(ENTRY(5,aquit.tbrub[viRubrique],'|')).*/  /* SY 1013/0167 */
                when 600                         then vdeMontantFraisBail     = vdeMontantFraisBail   + decimal(entry(5, aquit.tbrub[viRubrique], '|')).
                when 626                         then vdeMontantEtatBail      = vdeMontantEtatBail    + decimal(entry(5, aquit.tbrub[viRubrique], '|')).
                when 623                         then vdeMontantDossierBail   = vdeMontantDossierBail + decimal(entry(5, aquit.tbrub[viRubrique], '|')).
                when 580                         then vdeMontantDepotBail     = vdeMontantDepotBail   + decimal(entry(5, aquit.tbrub[viRubrique], '|')).
            end case.
            /* SY 1013/0167 */
            if lookup(string(integer(entry(1, aquit.tbrub[viRubrique], '|'))), {&ListeRubqtTVA-Calcul})      > 0
            or lookup(string(integer(entry(1, aquit.tbrub[viRubrique], '|'))), {&ListeRubqtTVA-Variable})    > 0
            or lookup(string(integer(entry(1, aquit.tbrub[viRubrique], '|'))), {&ListeRubqtTVA-RappelAvoir}) > 0
            then vdeMontantTVABail = vdeMontantTVABail + decimal(entry(5, aquit.tbrub[viRubrique], '|')).
        end.
        assign
            vdeLoyerAnnuelBail      = vdeMontantLoyerBail * (12 / integer(substring(aquit.pdqtt, 1, 3, "character")))
            vdeChargesAnnuellesBail = (vdeMontantLoyerBail + vdeMontantChargesBail) * (12 / integer(substring(aquit.pdqtt, 1, 3, "character")))    /* NP #5501 */
        .
    end.
    else assign    /* Si pas de aquit : bail = encours */
        vcDateBail                = vcDateSortie
        vdeMontantChargesBail     = vdeMontantCharges
        vdeMontantChargeFixeBail  = vdeMontantChargeFixe
        vdeMontantLoyerBail       = vdeMontantLoyer
        vdeMontantAddBail         = vdeMontantAdd
        vdeMontantDroitBail       = vdeMontantDroit
        vdeMontantHonoraireBail   = vdeMontantHonoraire
        vdeMontantTVABail         = vdeMontantTVA
        vdeMontantFraisBail       = vdeMontantFrais
        vdeMontantEtatBail        = vdeMontantEtat
        vdeMontantDossierBail     = vdeMontantDossier
        vdeMontantDepotBail       = vdeMontantDepot
        vcLoyerBail               = vcLoyer
        vdeLoyerAnnuelBail        = vdeLoyerAnnuel
        vdeChargesAnnuellesBail   = vdeChargesAnnuelles /* NP #5501 */
    .
    assign
        voQuittance                          = new bureautique.fusion.classe.fusionQuittance()
        voQuittance:LbDatUse                 = vcDateSortie
        voQuittance:LbDatBai                 = vcDateBail
        voQuittance:montantcharge            = vdeMontantCharges
        voQuittance:montantchargeFixe        = vdeMontantChargeFixeBail
        voQuittance:montantloyer             = vdeMontantLoyer
        voQuittance:montantloyerBail         = vdeMontantLoyerBail
        voQuittance:montantDroit             = vdeMontantDroit
        voQuittance:montantDroitBail         = vdeMontantDroitBail
        voQuittance:montantLoyerAnnuel       = vdeLoyerAnnuel
        voQuittance:montantLoyerAnnuelBail   = vdeLoyerAnnuelBail
        voQuittance:montantHonoraire         = vdeMontantHonoraire
        voQuittance:montantHonoraireBail     = vdeMontantHonoraireBail
        voQuittance:montantChargeFixe        = vdeMontantChargeFixe
        voQuittance:montantTVA               = vdeMontantTVA
        voQuittance:montantTVABail           = vdeMontantTVABail
        voQuittance:montantFrais             = vdeMontantFrais
        voQuittance:montantFraisBail         = vdeMontantFraisBail
        voQuittance:montantEtat              = vdeMontantEtat
        voQuittance:montantEtatBail          = vdeMontantEtatBail
        voQuittance:montantDossier           = vdeMontantDossier
        voQuittance:montantDossierBail       = vdeMontantDossierBail
        voQuittance:montantDepotGarantie     = vdeMontantDepot
        voQuittance:montantDepotGarantieBail = vdeMontantDepotBail
        voQuittance:descriptifLoyer          = vcLoyer
        voQuittance:descriptifLoyerBail      = vcLoyerBail 
        voQuittance:montantChargesAnnuel     = vdeMontantAdd
        voQuittance:montantChargesAnnuelBail = vdeMontantAddBail
        voQuittance:montantTotalQuittance    = vdeMontantLoyer + vdeMontantCharges + vdeMontantDroit
        voQuittance:montantLoyerChargesAnnuelBail = vdeChargesAnnuellesBail
    .
    return voQuittance.
end function.

function chargeAdresseLadrs returns class bureautique.fusion.classe.fusionAdresse(piNumeroLien as int64):
    /*------------------------------------------------------------------------------
    Purpose: charge les infos adresse à partir de ladrs
    Notes:
    ------------------------------------------------------------------------------*/
    define variable voAdresse    as class bureautique.fusion.classe.fusionAdresse no-undo.
    define variable vhProcTel    as handle    no-undo.
    define variable vcNatureVoie as character no-undo.
    define variable vcCodeVoie   as character no-undo.
    define buffer adres for adres.
    define buffer ladrs for ladrs.

    voAdresse = new bureautique.fusion.classe.fusionAdresse().
    run adresse/fcttelep.p persistent set vhProcTel.
    run getTokenInstance in vhProcTel(mToken:JSessionId).
    for first ladrs no-lock
        where ladrs.nolie = piNumeroLien:
        assign                  /* Valorisation de l'adresse */
            vcCodeVoie          = outilTraduction:getLibelleParam("CDADR", ladrs.cdadr)
            vcCodeVoie          = if vcCodeVoie = "-" then "" else vcCodeVoie + " "
            voAdresse:codeVoie  = vcCodeVoie 
            voAdresse:telephone = entry(3, dynamic-function("donnePremTpTel" in vhProcTel, ladrs.tpidt, ladrs.noidt, {&TYPETELEPHONE-telephone}), separ[1]) // premier telephone
            voAdresse:fax       = entry(3, dynamic-function("donnePremTpTel" in vhProcTel, ladrs.tpidt, ladrs.noidt, {&TYPETELEPHONE-fax}), separ[1]) // premier fax
            voAdresse:mail      = entry(3, dynamic-function("donnePremTpTel" in vhProcTel, ladrs.tpidt, ladrs.noidt, {&TYPETELEPHONE-mail }), separ[1]) // premier mail
            voAdresse:portable  = entry(3, dynamic-function("donnePremTpTel" in vhProcTel, ladrs.tpidt, ladrs.noidt, {&CODETELEPHONE-mobile}), separ[1]) // premier portable
        .
        for first adres no-lock
            where adres.noadr = ladrs.noadr:
            assign
                vcNatureVoie            = outilTraduction:getLibelleParam("NTVOI", adres.ntvoi)
                voAdresse:natureVoie    = if vcNatureVoie = "-" then "" else vcNatureVoie
                voAdresse:numeroVoie    = trim(ladrs.novoi)
                voAdresse:complementVoie= trim(Adres.cpvoi)
                voAdresse:codePostal    = trim(adres.cdpos)
                voAdresse:cedex         = trim(adres.lbvil)
                voAdresse:ville         = suppCedex(trim(adres.lbvil))
                voAdresse:libellePays   = if adres.cdpay = "00001" then "" else outilTraduction:getLibelleParam("CDPAY", adres.cdpay)
                voAdresse:identAdresse  = adres.cpad2
                voAdresse:codePays      = string(integer(adres.cdpay), "999")
            .
        end.
    end.
    run destroy in vhProcTel.
    return voAdresse.
end function.

function chargeAdresse returns class bureautique.fusion.classe.fusionAdresse(
    pcTypeIdentifiant as character, piNumeroIdentifiant as int64, piNumeroDocument as int64):
    /*------------------------------------------------------------------------------
    Purpose: charge les infos adresse
    Notes:
    ------------------------------------------------------------------------------*/
    define variable voAdresse          as class bureautique.fusion.classe.fusionAdresse no-undo.
    define variable vcTypeDestinataire as character no-undo initial "00001".
    define variable vcTypeAdresse      as character no-undo initial "00001".
    define variable vcCodeIdentifiant  as character no-undo.
    define variable viTelephone        as integer   no-undo initial 1.
    define variable vcNomTable         as character no-undo.
    define variable vcCodecoll-cle     as character no-undo.
    define variable vcSaisieLibre      as character no-undo.
    define variable vcLibelleTitreOrg  as character no-undo.
    define buffer desti for desti.
    define buffer ladrs for ladrs.

    /*--> Recherche du parametrage destinataire */
    find first desti no-lock
        where desti.nodoc = piNumeroDocument
          and desti.tprol = pcTypeIdentifiant
          and desti.norol = piNumeroIdentifiant no-error.
    if available desti 
    then assign
        vcTypeDestinataire = desti.tpdes
        vcTypeAdresse      = desti.TpAdr
        viTelephone        = integer(desti.TpTel)
        vcSaisieLibre      = desti.lbdiv
    .
    /* Valorisation de l'adresse */
    find first ladrs no-lock
        where ladrs.TpIdt = pcTypeIdentifiant
          and ladrs.NoIdt = piNumeroIdentifiant
          and ladrs.tpadr = vcTypeAdresse no-error.
    if available ladrs
    then voAdresse = chargeAdresseLadrs(ladrs.nolie).
    else do:
        run decodOrg(pcTypeIdentifiant,
                     piNumeroIdentifiant,
                     output vcCodeIdentifiant,
                     output vcNomTable,
                     output vcCodecoll-cle,
                     output vcLibelleTitreOrg).
        voAdresse = if vcNomTable = "orsoc" 
                    then chargeAdresseOrganismeSocial(pcTypeIdentifiant, vcCodeIdentifiant, viTelephone, vcSaisieLibre)
                    else chargeAdresseFournisseur(pcTypeIdentifiant, piNumeroIdentifiant, vcCodecoll-cle, vcTypeDestinataire, vcTypeAdresse, vitelephone, vcSaisieLibre).
    end.
    return voAdresse.
end function.

function donneInfosAdresse returns class bureautique.fusion.classe.fusionRole(
    piSociete as integer, pcCleFournisseur as character, pcTypeDestinataire as character, pcTypeAdresse as character):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define variable voRole as class bureautique.fusion.classe.fusionRole no-undo.
    define buffer iadrfour for iadrfour.

    voRole = new bureautique.fusion.classe.fusionRole().
    find first iadrfour no-lock
        where iadrfour.soc-cd    = piSociete
          and iadrfour.four-cle  = pcCleFournisseur
          and iadrfour.libadr-cd = integer(pcTypeDestinataire) - 2
          and iadrfour.adr-cd    = integer(pcTypeAdresse) no-error.
    if not available iadrfour then return voRole.

    setInfoAdresse(input-output voRole, piSociete, iadrfour.librais-cd, iadrfour.fopol, iadrfour.nom).
    return voRole.
end function.

function chargeInfoTiers returns class bureautique.fusion.classe.fusionRole(piNumeroTiers as int64, pcTypeDestinataire as character):
    /*------------------------------------------------------------------------------
    Purpose: charge les info rôle à partir d'un tiers
    Notes:
    ------------------------------------------------------------------------------*/
    define variable voRole             as class bureautique.fusion.classe.fusionRole        no-undo.
    define variable voFormulePolitesse as class parametre.pclie.parametrageFormulePolitesse no-undo.
    define variable voTiers            as class tiers.classe.tiersMultiple                  no-undo.

    assign
        /* Modif SY le 10/09/2010 - toujours pb TpdesUse - fiche 0910/0051 - pour OTS si Tpdesuse = 00002 => Nom Vide */
        pcTypeDestinataire         = if pcTypeDestinataire = {&TYPETIERS-principal} then {&TYPETIERS-secondaire} else pcTypeDestinataire
        voTiers                    = new tiers.classe.tiersMultiple(piNumeroTiers)
        voRole                     = new bureautique.fusion.classe.fusionRole()
        /* Valorisation du tiers principal */
        voRole:Civilite            = voTiers:tiersPrincipal:getLibelleCivilite()
        voRole:Particule           = voTiers:tiersPrincipal:getLibelleParticule()
        voRole:Titre               = voTiers:tiersPrincipal:getTitre()
        voRole:NomUsuel            = voTiers:tiersPrincipal:getNomUsuel()
        voRole:Prenom              = voTiers:tiersPrincipal:getPrenom()
        voRole:Nom                 = voTiers:tiersPrincipal:getNom()
        voRole:Autre               = voTiers:tiersPrincipal:getAutre()
        voRole:DateNaissance       = voTiers:tiersPrincipal:getDateNaissanceFormatee()
        voRole:LieuNaissance       = voTiers:tiersPrincipal:getLieuNaissance()
        voRole:Departement         = voTiers:tiersPrincipal:getCodeDepartement()
        voRole:Profession          = voTiers:tiersPrincipal:getProfession()
        voRole:Nationalite         = voTiers:tiersPrincipal:getNationalite()
        voRole:FormeJuridiqueLong  = voTiers:tiersPrincipal:getFormeJuridiqueLong()
        voRole:FormeJuridiqueCourt = voTiers:tiersPrincipal:getFormeJuridiqueCourt()
        voRole:FormulePolitesse    = voTiers:tiersPrincipal:getFormulePolitesse()
        voRole:typeTiers           = voTiers:tiersPrincipal:getLibelleTypeTiers()
        voRole:NomComplet          = voTiers:tiersPrincipal:getNomComplet()
        voRole:TitreLettre         = voTiers:tiersPrincipal:getTitreLettre()
    .
    /* Valorisation du tiers secondaire */
    case pcTypeDestinataire:
        when {&TYPETIERS-secondaire} then if voTiers:tiersSecondaire:nom > "" 
        then assign
            voRole:civiliteBis      = voTiers:tiersSecondaire:getLibelleCivilite()
            voRole:particuleBis     = voTiers:tiersSecondaire:getLibelleParticule()
            voRole:titreBis         = voTiers:tiersSecondaire:getTitre()
            voRole:nomUsuelBis      = voTiers:tiersSecondaire:getNomUsuel()
            voRole:prenomBis        = voTiers:tiersSecondaire:getPrenom()
            voRole:nomBis           = voTiers:tiersSecondaire:getNom()
            voRole:autreBis         = voTiers:tiersSecondaire:getAutre()
            voRole:dateNaissance    = voTiers:tiersSecondaire:getDateNaissanceFormatee()
            voRole:lieuNaissanceBis = voTiers:tiersSecondaire:getLieuNaissance()
            voRole:departementBis   = voTiers:tiersSecondaire:getCodeDepartement()
            voRole:professionBis    = voTiers:tiersSecondaire:getProfession()
            voRole:nationaliteBis   = voTiers:tiersSecondaire:getNationalite()
        .
        when {&TYPETIERS-careOf} then if voTiers:tiersPrincipal:lCareOf
        then assign
            voRole:civiliteBis   = voTiers:tiersCareOf:getLibelleCivilite()
            voRole:particuleBis  = voTiers:tiersCareOf:getLibelleParticule()
            voRole:titreBis      = voTiers:tiersCareOf:getTitre()
            voRole:nomUsuelBis   = voTiers:tiersCareOf:getNomUsuel()
            voRole:prenomBis     = voTiers:tiersCareOf:getPrenom()
            voRole:nombis        = voTiers:tiersCareOf:getNom()
            voRole:autreBis      = voTiers:tiersCareOf:getAutre()
            voRole:professionBis = voTiers:tiersCareOf:getProfession()
        .
        when {&TYPETIERS-contact} then if voTiers:tiersPrincipal:lContact
        then assign
            voRole:civiliteBis   = voTiers:tiersContact:getLibelleCivilite()
            voRole:particuleBis  = voTiers:tiersContact:getLibelleParticule()
            voRole:titreBis      = voTiers:tiersContact:getTitre()
            voRole:nomUsuelBis   = voTiers:tiersContact:getNomUsuel()
            voRole:prenomBis     = voTiers:tiersContact:getPrenom()
            voRole:nomBis        = voTiers:tiersContact:getNom()
            voRole:autreBis      = voTiers:tiersContact:getAutre()
            voRole:professionBis = voTiers:tiersContact:getProfession()
        .
    end case.

    /* Dans le cas d'une societe la profession du tiers principale est celui du representant */
    if voTiers:tiersPrincipal:codeFamille = {&FAMILLETIERS-personneMorale}
    or voTiers:tiersPrincipal:codeFamille = {&FAMILLETIERS-personneCivile}
    then voRole:profession = voRole:professionBis.

    /* Formatage du nom complet */
    case voTiers:tiersPrincipal:codeFamille:
        when {&FAMILLETIERS-personneIndividu} or when {&FAMILLETIERS-personneMorale} or when {&FAMILLETIERS-personneCivile}
        then assign
            voRole:nomComplet  = trim(substitute('&1 &2', voRole:titre, voRole:nom))
            voRole:titreLettre = voTiers:tiersPrincipal:getTitreLettre()
        .
        when {&FAMILLETIERS-personneCouple} then do:
            voRole:titreLettre = voTiers:tiersPrincipal:getTitreLettre().
            case voTiers:tiersPrincipal:codeSousFamille:
               when {&SOUSFAMILLETIERS-epoux} then voRole:nomComplet = outilTraduction:getLibelle(701761) + " " + voRole:nom. /* Epoux */
               otherwise voRole:nomComplet = substitute("&1 &2 et &3 &4", voRole:civilite, voRole:nom, voRole:civiliteBis, voRole:nomBis). /* Concubins & F-F & H-F & H-H */
            end case.
        end.
    end case.
    /* Valorisation du C/O */
    if voTiers:TiersPrincipal:lCareOf then assign
        voRole:particuleC-O  = voTiers:tiersCareOf:getLibelleParticule()
        voRole:titreC-O      = voTiers:tiersCareOf:getTitre()
        voRole:nomC-O        = voTiers:tiersCareOf:getNom()
        voRole:nomCompletC-O = voTiers:tiersCareOf:getNomComplet()
    .
    if voTiers:tiersPrincipal:codeFamille = {&FAMILLETIERS-personneMorale} 
    then do:
        if voTiers:tiersSecondaire:nom > "" 
        then assign
            voRole:nomCompletRep  = (if voRole:titreBis > "" then voRole:titreBis + " " else "") + voRole:nomBis.
            voRole:nationaliteRep = voTiers:tiersSecondaire:getNationalite()
        . 
        if voTiers:TiersPrincipal:lContact 
        then do:
            assign
                voRole:nomCompletContact = voTiers:tiersContact:getNomComplet()
                /* Recherche TitreL à partir de la civilité dans FOPOL */
                voFormulePolitesse       = new parametre.pclie.parametrageFormulePolitesse(voTiers:tiersPrincipal:codeSousFamille, voTiers:tiersPrincipal:codeCivilite)
            .
            if voFormulePolitesse:isDbParameter  // IsOuvert() ne fonctionne pas sur ce paramètre
            then voRole:titreLettreContact = voFormulePolitesse:getFormule1().
        end.
    end. 
    
    /* TODO : revoir gesind002 pour exporter une table plutôt que d'exporter dans un fichier
    define buffer ctrat for ctrat.
    /* Recherche qualité destinataire si indivisaire */
    if pcTypeRole = "00016" or pcTypeRole = "00022" or pcTypeRole = "00018" or pcTypeRole = "00029" 
    then do:
        /* Uniquement si le mandat est avec indivision */
        find first ctrat no-lock
             where ctrat.tpcon = "01030"
               and ctrat.nocon = NoMdtUse no-error.
        if available ctrat and (ctrat.ntcon = "03030" or ctrat.ntcon = "03093") 
        then do:
            LbQuaInd = "Indivisaire".
            /* Chargement de la table des indivisions depuis le fichier généré
            par gesind02.p car champ de fusion utilisable que dans cet écran */
            if search(cFichierIndivisaires) <> ? then do:
                input STREAM sIndiv FROM VALUE(cFichierIndivisaires).
                repeat:
                    create TbTmpInd.
                    import stream sIndiv TbTmpInd.
                end.
                input STREAM sIndiv CLOSE.
                find first TbTmpInd where TbTmpInd.iNumeroIndivisaire = piNumeroROle no-error.
                if available(TbTmpInd) 
                then do:
                    if TbTmpInd.cTypeU-NP = ""   then LbQuaInd = "Propriétaire".
                    if TbTmpInd.cTypeU-NP = "NP" then LbQuaInd = "Nu propriétaire".
                    if TbTmpInd.cTypeU-NP = "U"  then LbQuaInd = "Usufruitier".
                end.
            end.
        end.
    end.
    */
    if valid-object(voTiers)            then delete object voTiers.
    if valid-object(voFormulePolitesse) then delete object voFormulePolitesse.
    return voRole.
end function.

function chargeInfoOrganismeSocial returns class bureautique.fusion.classe.fusionRole(
    pcTypeIdentifiant as character, pcCodeIdentifiant as character):
    /*------------------------------------------------------------------------------
    Purpose: charge les info rôle à partir d'un organisme social
    Notes:
    ------------------------------------------------------------------------------*/
    define variable voRole as class bureautique.fusion.classe.fusionRole no-undo.
    define buffer orsoc for orsoc.

    voRole = new bureautique.fusion.classe.fusionRole().
    /* Tiers orsoc */
    for first orsoc no-lock
        where orsoc.tporg = pcTypeIdentifiant
          and orsoc.ident = pcCodeIdentifiant:
        assign
            voRole:nom         = trim(orsoc.lbnom)
            voRole:titreLettre = outilTraduction:getLibelle(104203)
            voRole:nomComplet  = voRole:nom
        .
    end.
    return voRole.
end function.

function donneInfosFournisseur returns class bureautique.fusion.classe.fusionRole(
    piSociete as integer, pcNom as character, piCodeTitre as integer, pcFormulePolitesse as character):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define variable voRole as class bureautique.fusion.classe.fusionRole no-undo.

    voRole = new bureautique.fusion.classe.fusionRole().
    setInfoAdresse(input-output voRole, piSociete, piCodeTitre, pcFormulePolitesse, pcNom).
    return voRole.
end function.

function chargeInfoFournisseur returns class bureautique.fusion.classe.fusionRole(
    pcTypeDestinataire as character, piNumeroIdentifiant as integer, pcTypeAdresse as character, pcCodeColl-cle as character):
    /*------------------------------------------------------------------------------
    Purpose: charge les info rôle à partir de fournisseur
    Notes:
    ------------------------------------------------------------------------------*/
    define variable voRole as class bureautique.fusion.classe.fusionRole no-undo.
    define variable vcTemp as character no-undo.
    define buffer ilibrais for ilibrais.
    define buffer icontacf for icontacf.
    define buffer icatfour for icatfour.
    define buffer ifour    for ifour.

    find first ifour no-lock
        where ifour.soc-cd          = mtoken:iCodeSociete
          and ifour.coll-cle        = pcCodeColl-cle
          and integer(ifour.cpt-cd) = piNumeroIdentifiant no-error.
    if available ifour then do:
        if pcTypeDestinataire = {&TYPETIERS-principal}
        then do:
            voRole = donneInfosFournisseur(ifour.soc-cd, ifour.nom, ifour.librais-cd, ifour.fopol).
            find first icatfour no-lock
                where icatfour.soc-cd   = ifour.soc-cd
                  and icatfour.etab-cd  = ifour.etab-cd
                  and icatfour.categ-cd = ifour.categ-cd no-error.
            voRole:profession = if available icatfour then icatfour.lib else "".
        end.
        else voRole = if pcTypeDestinataire = {&TYPETIERS-secondaire}
                      then donneInfosContact(ifour.soc-cd, ifour.four-cle, pcTypeAdresse)
                      else donneInfosAdresse(ifour.soc-cd, ifour.four-cle, pcTypeDestinataire, pcTypeAdresse).
        /* Contact  0108/0352 - RF - 18/04/08 */
        for first icontacf no-lock
            where icontacf.soc-cd   = ifour.soc-cd
              and icontacf.four-cle = ifour.four-cle:
            find first ilibrais no-lock
                where ilibrais.soc-cd     = icontacf.soc-cd
                  and ilibrais.librais-cd = icontacf.librais-cd no-error.
            assign
                voRole:titreBis          = if available ilibrais then ilibrais.lib else "" /* RF 0108/0352 */
                voRole:nomBis            = icontacf.nom
                vcTemp                   = if available ilibrais then ilibrais.lib else ""
                voRole:nomCompletContact = (if vcTemp > "" then vcTemp + " " else "") + icontacf.nom
            .
//          run FrmTitLettreFou in HwLibEve(icontacf.soc-cd, icontacf.four-cle , icontacf.numero , output LbTitLetContact, output LbTitContact , output LbFopolContact).    /* SY 0913/0061 */                  
        end.
        voRole:SIRET = decimal(ifour.siret) no-error.
        if not error-status:error 
        then assign
            voRole:SIREN = substring(string(decimal(ifour.siret), "99999999999999" ), 1,  9, "character")
            voRole:NIC   = substring(string(decimal(ifour.siret), "99999999999999" ), 10, 5, "character")
        .
        voRole:NAF = ifour.ape.
    end.
    else voRole = new bureautique.fusion.classe.fusionRole().
    return voRole.
end function.

function chargeRole returns class bureautique.fusion.classe.fusionRole(
    pcTypeRole as character, piNumeroRole as int64, piNumeroDocument as int64):
    /*------------------------------------------------------------------------------
    Purpose: charge les info rôle
    Notes:
    ------------------------------------------------------------------------------*/
    define variable voRole             as class bureautique.fusion.classe.fusionRole no-undo.
    define variable vcNomTable         as character no-undo.
    define variable vcTypeDestinataire as character no-undo initial "00001".
    define variable vcTypeAdresse      as character no-undo initial "00001".
    define variable vcCodeIdentifiant  as character no-undo.
    define variable vcCodeColl-cle     as character no-undo.
    define variable vcTitreOrganisme   as character no-undo.
    define buffer tutil   for tutil.
    define buffer desti   for desti.
    define buffer vbRoles for roles.

    /* Recherche du parametrage destinataire */
    find first desti no-lock
         where desti.nodoc = piNumeroDocument
           and desti.tprol = pcTypeRole
           and desti.norol = piNumeroRole no-error.
    if available desti 
    then assign
        vcTypeDestinataire = desti.tpdes
        vcTypeAdresse      = desti.TpAdr
    .
    /* Recherche du roles */
    find first vbRoles no-lock 
        where vbRoles.tprol = pcTypeRole
          and vbRoles.norol = piNumeroRole no-error.
    if available vbRoles 
    then voRole = chargeInfoTiers(vbRoles.notie, vcTypeDestinataire).
    else do:
        run decodOrg(pcTypeRole, piNumeroRole, output vcCodeIdentifiant, output vcNomTable, output vcCodeColl-cle, output vcTitreOrganisme).
        if vcNomTable = "orsoc"
        then voRole = chargeInfoOrganismeSocial(pcTypeRole, vcCodeIdentifiant).
        else voRole = chargeInfoFournisseur    (vcTypeDestinataire, piNumeroRole, vcTypeAdresse, vcCodeColl-cle).
    end.
    {&_proparse_ prolint-nowarn(wholeIndex)}
    find first tutil no-lock
        where tutil.tprol = pcTypeRole
          and tutil.norol = piNumeroRole no-error.
    if available tutil then voRole:Initiales = tutil.initiales.
    voRole:formulePolitesse = substitute("Veuillez agréer, %1, l’expression de nos sentiments distingués.", voRole:titreLettre).
    return voRole.
end function.

function chargeBanque returns class bureautique.fusion.classe.fusionBanque(pcTypeRole as character, piNumeroRole as integer):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define variable voBanque as class bureautique.fusion.classe.fusionBanque no-undo.
    define buffer vbRoles for roles.
    define buffer rlctt   for rlctt.
    define buffer ctanx   for ctanx.

    voBanque = new fusionBanque().
    for first vbRoles  no-lock
        where vbRoles.tprol = pcTypeRole
          and vbRoles.norol = piNumeroRole:
        find first rlctt no-lock
             where rlctt.tpidt = vbRoles.tprol
               and rlctt.noidt = vbRoles.norol
               and rlctt.tpct2 = {&TYPECONTRAT-prive} no-error.
        if available rlctt
        then find first ctanx no-lock 
            where ctanx.tpcon = rlctt.tpct2
              and ctanx.nocon = rlctt.noct2 no-error.
        else find first ctanx no-lock
            where ctanx.tprol = "99999"
              and ctanx.norol = vbRoles.notie
              and ctanx.tpact = "DEFAU"
              and ctanx.tpcon = {&TYPECONTRAT-prive} no-error.
        if available ctanx then assign
            voBanque:Banque-Domiciliation = ctanx.lbdom
            voBanque:Banque-Titulaire     = ctanx.lbtit
            voBanque:Banque-IBAN          = ctanx.iban
            voBanque:Banque-BIC           = ctanx.bicod
        .
    end.
    return voBanque.
end function.

function description returns character(pcTypeRole as character, piNumeroIdentifiant as int64, pcDescription as character, piNumeroDocument as int64):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define variable vcDescription           as character no-undo.
    define variable vcTitre            as character no-undo.
    define variable vcNom              as character no-undo.
    define variable vcDateNaissance    as character no-undo.
    define variable vcLieuNaissance    as character no-undo.
    define variable vcProfession       as character no-undo.
    define variable vcTitreBis         as character no-undo.
    define variable vcNomBis           as character no-undo.
    define variable vcDateNaissanceBis as character no-undo.
    define variable vcLieuNaissanceBis as character no-undo.
    define variable vcProfessionBis    as character no-undo.
    define variable vcLibelleAdresse   as character no-undo.
    define variable vcSuiteAdresse     as character no-undo.
    define variable vcCodePostal       as character no-undo.
    define variable vcVille            as character no-undo.
    define variable voRole             as class bureautique.fusion.classe.fusionRole    no-undo.
    define variable voAdresse          as class bureautique.fusion.classe.fusionAdresse no-undo.

    assign 
        voRole             = chargeRole(pcTypeRole, piNumeroIdentifiant, piNumeroDocument)
        vcTitre            = voRole:titre 
        vcNom              = voRole:nom 
        vcDateNaissance    = voRole:dateNaissance
        vcLieuNaissance    = voRole:lieuNaissance
        vcProfession       = voRole:profession
        vcTitreBis         = voRole:titreBis
        vcNomBis           = voRole:NomBis
        vcDateNaissanceBis = voRole:nationaliteBis
        vcLieuNaissanceBis = voRole:lieuNaissanceBis
        vcProfessionBis    = voRole:professionBis
    .
    assign
        voAdresse        = chargeAdresse(pcTypeRole, piNumeroIdentifiant, piNumeroDocument)
        vcLibelleAdresse = voAdresse:adresse
        vcSuiteAdresse   = voAdresse:complementVoie
        vcCodePostal     = voAdresse:codePostal
        vcVille          = voAdresse:ville
    .
    /* Tiers principal */
    if vcDateNaissance > "" 
    then vcDateNaissance = ", né(e) le " + vcDateNaissance + (if vcLieuNaissance > "" then ", à " + vcLieuNaissance else "").

    if vcProfession > ""
    then vcProfession = substitute(", &1 &2", outilTraduction:getLibelle(103159), vcProfession).
    else vcProfession = ", " + outilTraduction:getLibelle(103160).

    vcDescription = trim(vcTitre + " " + vcNom + vcDateNaissance + vcProfession).
    /* tiers secondaire */
    if vcNomBis > "" 
    then do:
        if vcDateNaissanceBis > "" and vcLieuNaissanceBis > "" 
        then vcDateNaissanceBis = ", né(e) le " + vcDateNaissanceBis + (if vcLieuNaissanceBis > "" then ", à " + vcLieuNaissanceBis else "").

        if vcProfessionBis > "" 
        then vcProfessionBis = substitute(", &1 &2", outilTraduction:getLibelle(103159), vcProfessionBis).
        else vcProfessionBis = ", " + outilTraduction:getLibelle(103160).

        if vcTitreBis > "" then vcTitreBis = vcTitreBis + " ".
        if vcDescription > "" then vcDescription = vcDescription + " et, ".
        vcDescription = vcDescription + vcTitreBis + vcNomBis + vcDateNaissanceBis + vcProfessionBis.
    end.
    if vcLibelleAdresse > "" 
    then vcDescription = substitute("&1, &2 &3 &4 &5 &6", vcDescription, outilTraduction:getLibelle(103161), vcLibelleAdresse, vcSuiteAdresse, vcCodePostal, vcVille).
    if pcDescription > "" 
    then pcDescription = pcDescription + chr(10) + "et, " + vcDescription. 
    else pcDescription = vcDescription.

    if valid-object(voRole)    then delete object voRole.
    if valid-object(voAdresse) then delete object voAdresse.
    return pcDescription.

end function.

function descriptnat returns character(pcTypeRole as character, NoIdtUse as int64, pcDescription as character, piNumeroDocument as int64):
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    define variable vcDescription    as character    no-undo.
    define variable vcTitre          as character    no-undo.
    define variable vcNomUsuel       as character    no-undo.
    define variable vcPrenom         as character    no-undo.
    define variable vcAutre          as character    no-undo.
    define variable vcNaissance      as character    no-undo.
    define variable vcLieu           as character    no-undo.
    define variable vcNationalite    as character    no-undo.
    define variable vcDepartement    as character    no-undo. /*- Dépt de Naissance   -*/ /* RF 10/12/08 */
    define variable vcTitreBis       as character    no-undo.
    define variable vcNomUsuelBis    as character    no-undo.
    define variable vcPrenomBis      as character    no-undo.
    define variable vcAutreBis       as character    no-undo.
    define variable vcNaissanceBis   as character    no-undo.
    define variable vcLieuBis        as character    no-undo.
    define variable vcNationaliteBis as character    no-undo.
    define variable vcDepartementBis as character    no-undo. /*- Dépt de Naissance   -*/ /* RF 10/12/08 */ 
    define variable vcAdresse        as character    no-undo.
    define variable vcSuiteAdresse   as character    no-undo.
    define variable vcCodePostal     as character    no-undo.
    define variable vcVille          as character    no-undo.
    define variable voAdresse        as class fusionAdresse no-undo.
    define variable voRole           as class fusionRole    no-undo.

    define buffer vbRoles for roles.
    define buffer tiers   for tiers.
 
    assign 
        voRole           = chargeRole(pcTypeRole, NoIdtUse, piNumeroDocument)
        vcTitre          = voRole:Titre
        vcNomUsuel       = voRole:NomUsuel
        vcPrenom         = voRole:Prenom
        vcAutre          = voRole:Autre
        vcNaissance      = outilFormatage:getDateFormat(date(voRole:DateNaissance), "L")
        vcLieu           = voRole:LieuNaissance
        vcNationalite    = voRole:Nationalite
        vcDepartement    = voRole:Departement
        vcTitreBis       = voRole:TitreBis
        vcNomUsuelBis    = voRole:NomUsuelBis
        vcPrenomBis      = voRole:PrenomBis
        vcAutreBis       = voRole:AutreBis
        vcNaissanceBis   = outilFormatage:getDateFormat(date(voRole:DateNaissanceBis), "L")
        vcLieuBis        = voRole:LieuNaissanceBis
        vcNationaliteBis = voRole:NationaliteBis
        vcDepartementBis = voRole:departementBis
    .
    assign
        voAdresse      = chargeAdresse(pcTypeRole, NoIdtUse, piNumeroDocument)
        vcAdresse      = voAdresse:adresse
        vcSuiteAdresse = voAdresse:complementVoie
        vcCodePostal   = voAdresse:codePostal
        vcVille        = voAdresse:ville
    .
    find first vbRoles no-lock
        where vbRoles.tprol = pcTypeRole
          and vbRoles.norol = noidtuse no-error.
    if available vbRoles
    then find first Tiers no-lock
        where tiers.notie = vbRoles.notie no-error.

    /* Tiers principal */
    if vcNaissance > "" 
    then vcNaissance = substitute(", né(e) le &1&2&3",
                                 vcNaissance,
                                 if vcLieu > "" then ", à " + vcLieu else "",
                                 if vcDepartement > "" then substitute(" (&1)", vcDepartement) else "").
    if vcNationalite > "" 
    then vcNationalite = ", de nationalité " + vcNationalite.
    if vcPrenom > "" then vcPrenom = vcPrenom + " ".
    if vcAutre  > "" then vcAutre  = vcAutre  + " ".
    vcDescription = trim(vcTitre + " " + vcPrenom + vcAutre + vcNomUsuel + vcNaissance + vcNationalite).
    /* tiers secondaire */
    if vcNomUsuel > "" then do:
        if vcNaissance > "" and vcLieuBis > "" 
        then vcNaissance = ", né(e) le "
                         + vcNaissance 
                         + (if vcLieuBis > "" then ", à " + vcLieuBis else "")
                         + (if vcDepartementBis > "" then substitute(" (&1)", vcDepartementBis) else "").

        if vcNationaliteBis > "" 
        then vcNationaliteBis = ", de nationalité " + vcNationaliteBis.

        if vcDescription > "" 
        then vcDescription = vcDescription
                           + (if available tiers and tiers.cdfat = {&FAMILLETIERS-personneMorale} then ", représenté par " else ", et ").
        if vcPrenomBis > "" then vcPrenomBis = vcPrenomBis + " ".
        if vcAutreBis  > "" then vcAutreBis  = vcAutreBis + " ".
        if vcTitreBis  > "" then vcTitreBis = vcTitreBis + " ".
        vcDescription = vcDescription + vcTitreBis + vcPrenomBis + vcAutreBis + vcNomUsuelBis + vcNaissanceBis + vcNationaliteBis.
    end.
    if vcAdresse > "" 
    then vcDescription = substitute("&1, &2 &3 &4 &5 &6",
                                    vcDescription, outilTraduction:getLibelle(103161), vcAdresse, vcSuiteAdresse, vcCodePostal, vcVille).
    if pcDescription > "" 
    then pcDescription = pcDescription + chr(10) + ", et " + vcDescription.
    else pcDescription = vcDescription.
    return pcDescription.

end function.

procedure FrmDigicode:
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    define input        parameter pcTypeDigicode   as character no-undo.
    define input        parameter piNumeroImmeuble as integer   no-undo.
    define input        parameter pcBatiment       as character no-undo.
    define input        parameter pcEntree         as character no-undo.
    define input        parameter pcEscalier       as character no-undo.
    define input-output parameter pcDigicodeDestinataire as character no-undo.
    define input-output parameter pcCourteDigicodeDestin as character no-undo.

    define variable vcListeDigicode as character no-undo.
    define buffer tache for tache.
    define buffer intnt for intnt.

    find first intnt no-lock
         where intnt.tpcon = {&TYPECONTRAT-construction}
           and intnt.tpidt = {&TYPEBIEN-immeuble}
           and intnt.noidt = piNumeroImmeuble no-error.
    if not available intnt then return.

    /* Recherche du Digicode immeuble */
    if pcTypeDigicode = {&TYPEBIEN-immeuble}
    then for each tache no-lock
        where tache.tpcon = intnt.tpcon
          and tache.nocon = intnt.nocon
          and tache.tptac = {&TYPETACHE-digicode}
          and tache.tpfin = ""            /*- Batiment    -*/
          and tache.cdhon = ""            /*- Entree      -*/
          and tache.tphon = "":           /*- Escalier    -*/
        run frmDigicodeTache(buffer tache, input-output vcListeDigicode, input-output pcDigicodeDestinataire, input-output pcCourteDigicodeDestin).
    end.
    /* Recherche du Digicode lot */
    else do:
        find last tache no-lock         /* Recherche par Batiment - Entree - Escalier */
            where tache.tpcon = intnt.tpcon
              and tache.nocon = intnt.nocon
              and tache.tptac = {&TYPETACHE-digicode}
              and tache.tpfin = pcBatiment
              and tache.cdhon = pcEntree
              and tache.tphon = pcEscalier no-error.
        if not available tache
        then find last tache no-lock    /* Recherche par Batient - Entree */
            where tache.tpcon = intnt.tpcon
              and tache.nocon = intnt.nocon
              and tache.tptac = {&TYPETACHE-digicode}
              and tache.tpfin = pcBatiment
              and tache.cdhon = pcEntree
              and tache.tphon = "" no-error.
        if not available tache
        then find last tache no-lock    /* Recherche par Batiment - Escalier */
            where tache.tpcon = intnt.tpcon
              and tache.nocon = intnt.nocon
              and tache.tptac = {&TYPETACHE-digicode}
              and tache.tpfin = pcBatiment
              and tache.cdhon = ""
              and tache.tphon = pcEscalier no-error.
        if not available tache
        then find last tache no-lock    /* Recherche par Entree - Escalier */
            where tache.tpcon = intnt.tpcon
              and tache.nocon = intnt.nocon
              and tache.tptac = {&TYPETACHE-digicode}
              and tache.tpfin = ""
              and tache.cdhon = pcEntree
              and tache.tphon = pcEscalier no-error.
        if not available tache
        then find last tache no-lock    /* Recherche par Batiment */
            where tache.tpcon = intnt.tpcon
              and tache.nocon = intnt.nocon
              and tache.tptac = {&TYPETACHE-digicode}
              and tache.tpfin = pcBatiment
              and tache.cdhon = ""
              and tache.tphon = "" no-error.
        if not available tache
        then find last tache no-lock    /* Recherche par Entree */
            where tache.tpcon = intnt.tpcon
              and tache.nocon = intnt.nocon
              and tache.tptac = {&TYPETACHE-digicode}
              and tache.tpfin = ""           /*- Batiment    -*/
              and tache.cdhon = pcEntree     /*- Entree      -*/
              and tache.tphon = "" no-error. /*- Escalier    -*/
        if not available tache
        then find last tache no-lock    /* Recherche par Escalier */
            where tache.tpcon = intnt.tpcon
              and tache.nocon = intnt.nocon
              and tache.tptac = {&TYPETACHE-digicode}
              and tache.tpfin = ""
              and tache.cdhon = ""
              and tache.tphon = pcEscalier no-error.
        if not available tache
        then find last tache no-lock
            where tache.tpcon = intnt.tpcon
              and tache.nocon = intnt.nocon
              and tache.tptac = {&TYPETACHE-digicode}
              and tache.tpfin = ""
              and tache.cdhon = ""
              and tache.tphon = "" no-error.
        run frmDigicodeTache(buffer tache, input-output vcListeDigicode, input-output pcDigicodeDestinataire, input-output pcCourteDigicodeDestin).
    end.

end procedure.

procedure frmDigicodeTache private:
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    define parameter buffer tache for tache.
    define input-output parameter pcListeDigicode        as character no-undo.
    define input-output parameter pcDigicodeDestinataire as character no-undo.
    define input-output parameter pcCourteDigicodeDestin as character no-undo.

    define variable vcDigicode as character no-undo.

    if available tache and lookup(string(tache.noita), pcListeDigicode) = 0 then do:
        assign
            pcListeDigicode        = substitute("&1,&2", pcListeDigicode, tache.noita)
            vcDigicode             = substitute("&1&2&3&4&5&6&7",
                                         if substring(tache.pdges, 1, 1, "character") = "0" then "-" else "L",
                                         if substring(tache.pdges, 2, 1, "character") = "0" then "-" else "M",
                                         if substring(tache.pdges, 3, 1, "character") = "0" then "-" else "M",
                                         if substring(tache.pdges, 4, 1, "character") = "0" then "-" else "J",
                                         if substring(tache.pdges, 5, 1, "character") = "0" then "-" else "V",
                                         if substring(tache.pdges, 6, 1, "character") = "0" then "-" else "S",
                                         if substring(tache.pdges, 7, 1, "character") = "0" then "-" else "D")
            pcDigicodeDestinataire = substitute("&2&1&3&1&4&1&5&1&6&1&7&1&8&1&9", chr(9), pcDigicodeDestinataire,
                                         trim(tache.lbdiv),                    /*- Libelle     -*/
                                         trim(tache.tpfin),                    /*- Bat         -*/
                                         trim(tache.cdhon),                    /*- Entrée      -*/
                                         trim(tache.tphon),                    /*- Escalier    -*/
                                         trim(tache.tpges),                    /*- Nouveau     -*/
                                         dateToCharacter(tache.dtdeb),         /*- Date Dbt    -*/
                                         vcDigicode)                           /*- En Fonction -*/
                                   +  substitute("&1:&2&3&4:&5&6", 
                                          substring(trim(tache.cdreg), 1, 2, "character"), substring(trim(tache.cdreg), 3, 2, "character"), chr(9),   /*- Heure Dbt   -*/
                                          substring(trim(tache.ntreg), 1, 2, "character"), substring(trim(tache.ntreg), 3, 2, "character"), chr(10))  /*- Heure Fin   -*/
            /* RF 1008/0146 - 1108/0395 */
            pcCourteDigicodeDestin = substitute("&2&1&3&1&4&1&5&1&6&1&7&1&8&9", chr(9), pcCourteDigicodeDestin,
                                        trim(tache.lbdiv),              /*- Libelle     -*/
                                        trim(tache.tpfin),              /*- Bat         -*/
                                        trim(tache.cdhon),              /*- Entrée      -*/
                                        trim(tache.tphon),              /*- Escalier    -*/
                                        trim(tache.tpges),              /*- Nouveau     -*/
                                        dateToCharacter(tache.dtdeb), chr(10)) /*- Date Dbt    -*/
        .
        if tache.pdreg > "" then assign
            pcDigicodeDestinataire = substitute("&2&1&3&1&4&1&5&1&6&1&7&1&8&1&9", chr(9), pcDigicodeDestinataire,
                                         trim(tache.lbdiv2),                   /*- Libelle     -*/
                                         trim(tache.tpfin),                    /*- Bat         -*/
                                         trim(tache.cdhon),                    /*- Entrée      -*/
                                         trim(tache.tphon),                    /*- Escalier    -*/
                                         trim(tache.pdreg),                    /*- Nouveau     -*/
                                         dateToCharacter(tache.dtreg),         /*- Date Dbt    -*/
                                         vcDigicode)                           /*- En Fonction -*/
                                   +  substitute("&1:&2&3&4:&5&6", 
                                          substring(trim(tache.cdreg), 1, 2, "character"), substring(trim(tache.cdreg), 3, 2, "character"), chr(9),   /*- Heure Dbt   -*/
                                          substring(trim(tache.ntreg), 1, 2, "character"), substring(trim(tache.ntreg), 3, 2, "character"), chr(10))  /*- Heure Fin   -*/
            /* RF 1008/0146 - 1108/0395 */
            pcCourteDigicodeDestin = substitute("&2&1&3&1&4&1&5&1&6&1&7&1&8&9", chr(9), pcCourteDigicodeDestin,
                                        trim(tache.lbdiv2),             /*- Libelle     -*/
                                        trim(tache.tpfin),              /*- Bat         -*/
                                        trim(tache.cdhon),              /*- Entrée      -*/
                                        trim(tache.tphon),              /*- Escalier    -*/
                                        trim(tache.pdreg),              /*- Nouveau     -*/
                                        dateToCharacter(tache.dtreg), chr(10)) /*- Date Dbt    -*/
        .
    end.
    pcListeDigicode = trim(pcListeDigicode, ",").
end procedure.

procedure last_Versement_Locat:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes: issu de libEvPrc.p
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroLoc     as integer no-undo.
    define output parameter pdaDernierLoyer as date    no-undo.

    define variable vcJournalOD      as character no-undo.
    define variable vcJournalAN      as character no-undo.
    define variable vcListeMouvement as character no-undo.
    define variable viEtabGlob       as integer   no-undo initial 8000.
    define variable viEtabComm       as integer   no-undo initial 8500.

    define buffer vbCecrln   for cecrln. /* NP 0415/0251 */
    define buffer ilibnatjou for ilibnatjou.
    define buffer ietab      for ietab.
    define buffer cecrln     for cecrln.
    define buffer ijou       for ijou.
    define buffer itypemvt   for itypemvt.

    find first ietab no-lock
        where ietab.soc-cd  = integer(mtoken:cRefGerance)
          and ietab.etab-cd = integer(substring(string(piNumeroLoc, "9999999999"), 1, 5, "character")) no-error.
    if not available ietab then return.

    /**  RECHERCHE DES JOURNAUX OD  **/ /** ON NE PRENDS PAS LE JOURNAL ODT **/ 
    find first ilibnatjou no-lock
        where ilibnatjou.soc-cd = ietab.soc-cd
          and ilibnatjou.od no-error.
    if not available ilibnatjou then return.

    {&_proparse_ prolint-nowarn(use-index)}
    for each ijou no-lock
        where ijou.soc-cd    = ietab.soc-cd
          and ijou.etab-cd   = ietab.etab-cd
          and ijou.natjou-cd = ilibnatjou.natjou-cd 
          and ijou.natjou-gi <> 46 /* EXCLUSION ODT */
        use-index jou-i:
        vcJournalOD = vcJournalOD + "," + ijou.jou-cd.
    end.
    {&_proparse_ prolint-nowarn(use-index)}
    for each ijou no-lock
        where ijou.soc-cd    = ietab.soc-cd
          and ijou.etab-cd   = viEtabGlob
          and ijou.natjou-cd = ilibnatjou.natjou-cd 
          and ijou.natjou-gi <> 46 /* EXCLUSION ODT */
        use-index jou-i:
        vcJournalOD = vcJournalOD + "," + ijou.jou-cd.
    end.
    {&_proparse_ prolint-nowarn(use-index)}
    for each ijou no-lock
        where ijou.soc-cd    = ietab.soc-cd
          and ijou.etab-cd   = viEtabComm
          and ijou.natjou-cd = ilibnatjou.natjou-cd
          and ijou.natjou-gi <> 46 /* EXCLUSION ODT */
        use-index jou-i:
        vcJournalOD = vcJournalOD + "," + ijou.jou-cd.
    end.
    /* RECHERCHE DES JOURNAUX AN */
    find first ilibnatjou no-lock
        where ilibnatjou.soc-cd = ietab.soc-cd
          and ilibnatjou.anouveau no-error.
    if not available ilibnatjou then return.

    {&_proparse_ prolint-nowarn(use-index)}
    for each ijou no-lock
       where ijou.soc-cd    = ietab.soc-cd
         and ijou.etab-cd   = ietab.etab-cd
         and ijou.natjou-cd = ilibnatjou.natjou-cd
        use-index jou-i:
        vcJournalAN = vcJournalAN + "," + ijou.jou-cd.
    end.
    {&_proparse_ prolint-nowarn(use-index)}
    for each ijou no-lock
        where ijou.soc-cd    = ietab.soc-cd
          and ijou.etab-cd   = viEtabGlob
          and ijou.natjou-cd = ilibnatjou.natjou-cd 
        use-index jou-i:
        vcJournalAN = vcJournalAN + "," + ijou.jou-cd.
    end.
    {&_proparse_ prolint-nowarn(use-index)}
    for each ijou no-lock
       where ijou.soc-cd    = ietab.soc-cd
         and ijou.etab-cd   = viEtabComm
         and ijou.natjou-cd = ilibnatjou.natjou-cd 
        use-index jou-i:
        vcJournalAN = vcJournalAN + "," + ijou.jou-cd.
    end.
    for each itypemvt no-lock
       where itypemvt.soc-cd     = ietab.soc-cd
         and itypemvt.etab-cd    = ietab.etab-cd
         and itypemvt.natjou-cd  = 9
         and (itypemvt.typenat-cd = 50 or itypemvt.typenat-cd = 51 or itypemvt.type-cle = "ODT"):
          vcListeMouvement = vcListeMouvement + "," + itypemvt.type-cle.
    end.
    assign
        vcJournalOD      = trim(vcJournalOD, ",")
        vcJournalAN      = trim(vcJournalAN, ",")
        vcListeMouvement = trim(vcListeMouvement, ",")
    .
    {&_proparse_ prolint-nowarn(sortaccess)}
boucleCecrln:
    for each cecrln no-lock 
        where cecrln.soc-cd  = ietab.soc-cd
          and cecrln.etab-cd = ietab.etab-cd
          and cecrln.cpt-cd  = substring(string(piNumeroLoc, "9999999999"), 6, 5, "character")
          and cecrln.sscoll-cle = "L"
          and not cecrln.sens
        by cecrln.dacompta descending:

        find first ijou 
            where ijou.soc-cd  = cecrln.soc-cd
              and ijou.etab-cd = cecrln.mandat-cd
              and ijou.jou-cd  = cecrln.jou-cd no-lock no-error.
        if available ijou
        then find first itypemvt no-lock
            where itypemvt.soc-cd    = cecrln.soc-cd
              and itypemvt.etab-cd   = cecrln.mandat-cd
              and itypemvt.natjou-cd = ijou.natjou-cd
              and itypemvt.type-cle  = cecrln.type-cle no-error.
        if not available ijou
        or (not can-find(first ilibnatjou no-lock
                         where ilibnatjou.soc-cd    = ijou.soc-cd
                           and ilibnatjou.natjou-cd = ijou.natjou-cd
                           and ilibnatjou.treso = true)
        and ijou.natjou-gi <> 46 
        and not(cecrln.type-cle = "ODT" and ijou.natjou-cd = 9)
        and not(available itypemvt and (itypemvt.typenat-cd = 50 or itypemvt.typenat-cd = 51) and ijou.natjou-cd = 9)) /* AN de tréso */
        then next boucleCecrln. /* ce n'est pas un règlement */

        /* Test existance des quittances lettrées avec ce règlement */
        if can-find(first vbCecrln no-lock
                    where vbCecrln.soc-cd     = cecrln.soc-cd
                      and vbCecrln.etab-cd    = cecrln.etab-cd  
                      and vbCecrln.sscoll-cle = cecrln.sscoll-cle
                      and vbCecrln.cpt-cd     = cecrln.cpt-cd
                      and vbCecrln.lettre     = cecrln.lettre 
                      and (vbCecrln.jou-cd    = "QUIT"
                       or lookup(vbCecrln.jou-cd, vcJournalOD) > 0 
                       or (lookup(vbCecrln.jou-cd, vcJournalAN) > 0 and lookup(vbCecrln.type-cle, vcListeMouvement) = 0)) /* Pas les AN de tréso */ 
                  )
        then do:
            pdaDernierLoyer = cecrln.dacompta.
            leave boucleCecrln.
        end.
    end.

end procedure.
