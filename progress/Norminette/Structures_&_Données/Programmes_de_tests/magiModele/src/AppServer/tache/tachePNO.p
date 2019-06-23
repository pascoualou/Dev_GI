/*------------------------------------------------------------------------
File        : tachePNO.p
Purpose     :
Author(s)   : DM 2017/11/09
Notes       : à partir de adb/src/tach/prmmtpno.p
       ATTENTION, nature UL et type bareme inversés !!!???
       - UL Commerciale 00002 - Bareme commercial 00001
       - UL Habitation  00001 - Bareme Habitation 00002
------------------------------------------------------------------------*/
{preprocesseur/type2bien.i}
{preprocesseur/type2contrat.i}
{preprocesseur/type2role.i}
{preprocesseur/type2tache.i}
{preprocesseur/type2bareme.i}
{preprocesseur/type2uniteLocation.i}
{preprocesseur/gestionPno.i}
{preprocesseur/codePeriode.i}

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */
{tache/include/tachePNO.i}
{tache/include/tache.i}
{adblib/include/cttac.i}
{adblib/include/aspno.i}
{application/include/error.i}
{application/include/glbsepar.i}

function fIsNull returns logical private (pcString as character):
    /*------------------------------------------------------------------------------
    Purpose: retourne vrai si chaine en entree = "" ou ?
    Notes:
    ------------------------------------------------------------------------------*/
    return pcString = "" or pcString = ?.
end function.

function fProrata1erePrime returns character private (phBareme as handle) :
    /*------------------------------------------------------------------------------
    Purpose: Donne le code periodicite de la 1ere prime
    Notes:
    ------------------------------------------------------------------------------*/
    define buffer garan for garan.
    for first garan no-lock
        where garan.tpctt = phBareme::tpctt
          and garan.noctt = phBareme::noctt
          and garan.tpbar = phBareme::tpbar
          and garan.nobar = 0:
        return garan.cdper.
    end.
    return ?.
end function.

function fLibelleBareme returns character private(piNumeroGarantie as integer, piNoBar as integer, pcTpBar as character):
    /*------------------------------------------------------------------------------
    Purpose: Donne le libellé formaté du bareme
    Notes: issu de la function DonneLibelleBareme
    ------------------------------------------------------------------------------*/
    define buffer garan for garan.
    for first garan no-lock
        where garan.tpctt = {&TYPECONTRAT-proprietaireNonOccupant}
          and garan.noctt = piNumeroGarantie
          and garan.tpbar = pcTpBar
          and garan.nobar = piNoBar:
        return substitute("&1 (&2)", string(garan.nobar, "99"), string(garan.tpbar = {&TYPEBAREME-Commercial}, "Com/Hab")).
    end.
    return "".
end function.

function fInfosGarantie returns character private (piNumeroGarantie as int64, pcDemande as character):
    /*------------------------------------------------------------------------------
    Purpose: Donne les infos de garantie
    Notes: issu de la fonction DonneInfosGarantie
    ------------------------------------------------------------------------------*/
    define buffer garan for garan.
    for first garan   no-lock
        where garan.tpctt = {&TYPECONTRAT-proprietaireNonOccupant}
          and garan.tpbar = ""
          and garan.nobar = 0
          and garan.noctt = piNumeroGarantie:
        case pcDemande:
            when "DTFIN"        then return string(if num-entries(garan.lbdiv3, "@") >= 5 then date(entry(5, garan.lbdiv3, "@")) else ?, "99/99/9999").
            when "DTDEB"        then return string(if num-entries(garan.lbdiv3, "@") >= 4 then date(entry(4, garan.lbdiv3, "@")) else ?, "99/99/9999").
            when "CONTRAT"      then return if num-entries(garan.lbdiv3, "@") >= 3 then entry(3, garan.lbdiv3, "@") else "".
            when "LIB"          then return substitute("&1 - &2", string(garan.noctt, "99"), outilFormatage:getNomFour("F", int64(entry(1, garan.lbdiv, "@")))).
            when "PERIODEPRIME" then return outilTraduction:getLibelleParam("PDPNO", garan.cdper).
        end case.
    end.
    return "".
end function.

function fMontantCotisation returns decimal private (phGarantie as handle, phBareme as handle):
    /*------------------------------------------------------------------------------
    Purpose: Donne le montant de la cotisation
    Notes:
    ------------------------------------------------------------------------------*/
    return if valid-handle(phGarantie) and num-entries(phGarantie::lbdiv3, "@") >= 2 and entry(2, phGarantie::lbdiv3, "@")  = "00001"
           then phBareme::txcot + phBareme::txhon
           else phBareme::txcot * (1 + (phBareme::txhon / 100)).
end function.

function fDonneProrata returns decimal private (pdMontantPrime as decimal, pdaPrime as date, pcPeriodicite as character, pcProrata1erePrime as character):
    /*------------------------------------------------------------------------------
    Purpose: Calcul du prorata
    Notes: issu de DonneProrata
    ------------------------------------------------------------------------------*/
    define variable viMois                    as integer   no-undo.
    define variable vcTbNumerateurSemestriel  as character no-undo.
    define variable vcTbNumerateurTrimestriel as character no-undo.
    define variable vcTbNumerateurMensuel     as character no-undo.
    define variable vcTbNumerateurCalcul      as character no-undo.
    define variable viNumerateur              as integer   no-undo.
    define variable viDenominateur            as integer   no-undo.
    define variable viMoisDebutPeriode        as integer   no-undo.
    define variable vdaDebut                  as date      no-undo.
    define variable vdaFin                    as date      no-undo.
    define variable viAnnee                   as integer   no-undo.
    define variable vcTbMoisDebutAnnuel       as character no-undo.
    define variable vcTbMoisDebutSemestriel   as character no-undo.
    define variable vcTbMoisDebutTrimestriel  as character no-undo.

    viMois = month(pdaPrime).
    if pcProrata1erePrime <> "99999" then do: // Autre que prorate jour
        viDenominateur = integer(pcPeriodicite) / integer(pcProrata1erePrime). // Détermination du dénominateur = nombre total de périodes = base
        // Détermination du numérateur = nombre périodes concernées en fonction de la date de 1ere cotisation
        if pcProrata1erePrime = pcPeriodicite 
        then viNumerateur = 1.
        else do:
            if pcPeriodicite = {&PERIODICITEPNO-annuel} then assign
                vcTbNumerateurSemestriel  = "02,02,02,02,02,02,01,01,01,01,01,01"
                vcTbNumerateurTrimestriel = "04,04,04,03,03,03,02,02,02,01,01,01"
                vcTbNumerateurMensuel     = "12,11,10,09,08,07,06,05,04,03,02,01"
            .
            if pcPeriodicite = {&PERIODICITEPNO-semestriel} then assign
                vcTbNumerateurTrimestriel = "02,02,02,01,01,01,02,02,02,01,01,01"
                vcTbNumerateurMensuel     = "06,05,04,03,02,01,06,05,04,03,02,01"
            .
            if pcPeriodicite = {&PERIODICITEPNO-trimestriel} then assign
                vcTbNumerateurMensuel     = "03,02,01,03,02,01,03,02,01,03,02,01"
            .
            /*
            Je ne traite pas le cas pcPeriodicite = "00001", car dans ce cas je ne peux avoir que
            pcProrata1erePrime = "00001" et je passe dans le cas pcProrata1erePrime = pcPeriodicite
            */
            // Quel tableau utiliser
            if pcProrata1erePrime = {&PERIODICITEPNO-semestriel} then vcTbNumerateurCalcul = vcTbNumerateurSemestriel.
            if pcProrata1erePrime = {&PERIODICITEPNO-trimestriel} then vcTbNumerateurCalcul = vcTbNumerateurTrimestriel.
            if pcProrata1erePrime = {&PERIODICITEPNO-mensuel} then vcTbNumerateurCalcul = vcTbNumerateurMensuel.
            /*
            Je ne traite pas le cas pcProrata1erePrime = "00012", car dans ce cas je ne peux avoir que
            pcPeriodicite = "00012" et je passe dans le cas pcProrata1erePrime = pcPeriodicite
            */
            // Numerateur en fonction du mois de la 1ere échéance
            viNumerateur = integer(entry(viMois, vcTbNumerateurCalcul)).
        end.
    end.
    else do:
        // Le dénominateur doit représenter le nombre de jours de la période de la périodicité de la prime
        // Le numérateur doit représenter le nombre de jours présents de la période de la périodicité de la prime
        assign
            vcTbMoisDebutAnnuel      = "01,01,01,01,01,01,01,01,01,01,01,01"
            vcTbMoisDebutSemestriel  = "01,01,01,01,01,01,07,07,07,07,07,07"
            vcTbMoisDebutTrimestriel = "01,01,01,04,04,04,07,07,07,10,10,10"
            viMois                   = month(pdaPrime)        // Mois de début/fin de la période
        .
        if pcPeriodicite = {&PERIODICITEPNO-annuel} then assign // Annuel 
            viMoisDebutPeriode = integer(entry(viMois, vcTbMoisDebutAnnuel))
        .
        if pcPeriodicite = {&PERIODICITEPNO-semestriel} then assign // semestriel
            viMoisDebutPeriode = integer(entry(viMois, vcTbMoisDebutSemestriel))
        .
        if pcPeriodicite = {&PERIODICITEPNO-trimestriel} then assign // Trimestriel
            viMoisDebutPeriode = integer(entry(viMois, vcTbMoisDebutTrimestriel))
        .
        if pcPeriodicite = {&PERIODICITEPNO-mensuel} then assign // Mensuel
            viMoisDebutPeriode = viMois
        .
        // Nombre de jours de la période
        assign
            viAnnee        = year(pdaPrime)
            vdaDebut       = date(viMoisDebutPeriode, 01, viAnnee)
            vdaFin         = add-interval(vdaDebut, integer(pcPeriodicite), "months") - 1
            viDenominateur = vdaFin - vdaDebut + 1
            viNumerateur   = vdaFin - pdaPrime + 1
        .
    end.
    return pdMontantPrime * (viNumerateur / viDenominateur). // Montant proraté

end function.


function fDonneMontantBareme returns decimal private (piNumeroGarantie as integer, piNumeroBareme as integer, pcNatureUL as character, pdaCotisation as date, plCotisationTraitee as logical):
    /*------------------------------------------------------------------------------
    Purpose: Calcul du montant du barème
    Notes: issu de DonneMontantBareme
    ------------------------------------------------------------------------------*/
    define variable vdRetour     as decimal   no-undo.
    define variable vcTypeBareme as character no-undo.
    define variable vdMtTot      as decimal   no-undo.

    define buffer garan    for garan.
    define buffer vbGaran  for garan.
    define buffer vb2Garan for garan.

    vcTypeBareme = if pcNatureUL = {&NATUREUL-commerce} then {&TYPEBAREME-Commercial} else {&TYPEBAREME-Habitation}.
    for first garan no-lock                                       // Garantie
        where garan.tpctt = {&TYPECONTRAT-proprietaireNonOccupant}
          and garan.tpbar = ""
          and garan.nobar = 0
          and garan.noctt = piNumeroGarantie
      , first vbGaran no-lock
        where vbGaran.tpctt = {&TYPECONTRAT-proprietaireNonOccupant}
          and vbGaran.noctt = garan.noctt
          and vbGaran.tpbar = vcTypeBareme
          and vbGaran.nobar = piNumeroBareme
          and (vbGaran.txcot <> 0 or vbGaran.txhon <> 0) : // Ne pas prendre les barêmes non saisis
        if num-entries(garan.lbdiv3, "@") >= 2 and entry(2, garan.lbdiv3, "@") =  "00001"
        then vdMtTot = vbGaran.txcot + vbGaran.txhon.
        else vdMtTot = vbGaran.txcot * (1 + (vbGaran.txhon / 100)).
        vdRetour = vdMtTot.
        /* ne prorater la prime que si c'est la première */
        if plCotisationTraitee = false then do:
            find first vb2garan no-lock
                where vb2garan.tpctt = vbGaran.tpctt
                  and vb2garan.noctt = vbGaran.noctt
                  and vb2garan.tpbar = vbGaran.tpbar
                  and vb2garan.nobar = 0 no-error.
            vdRetour = fDonneProrata(vdRetour, pdaCotisation, garan.cdper, if available vb2garan then vb2garan.cdper else "").
        end.
    end.
    vdRetour = truncate(vdRetour, 2).
    return vdRetour.
end function.

procedure chargeBareme private:
    /*------------------------------------------------------------------------------
    Purpose: Donne la liste des baremes
    Notes:
    ------------------------------------------------------------------------------*/
    define buffer garan    for garan.
    define buffer vbgaran  for garan.
    define buffer vb2garan for garan.

    empty temp-table ttBareme.

    for each garan no-lock                                   // Baremes
        where garan.tpctt = {&TYPECONTRAT-proprietaireNonOccupant}
          and garan.nobar <> 0
          and (garan.txcot <> 0 or garan.txhon <> 0):        // Ne pas prendre les barêmes non saisis
        find first vbGaran no-lock // Garantie
            where vbGaran.tpctt = garan.tpctt
              and vbGaran.noctt = garan.noctt
              and vbGaran.tpbar = ""
              and vbGaran.nobar = 0 no-error.
        find first vb2garan no-lock
            where vb2garan.tpctt = garan.tpctt
              and vb2garan.noctt = garan.noctt
              and vb2garan.tpbar = garan.tpbar
              and vb2garan.nobar = 0 no-error.
        create ttBareme.
        assign
            ttBareme.iNumeroGarantie    = garan.noctt
            ttBareme.iNumeroBareme      = garan.nobar
            ttBareme.cTypebareme        = garan.tpbar
            ttBareme.cNatureUL          = if garan.tpbar = {&TYPEBAREME-Habitation} then {&NATUREUL-habitation} else {&NATUREUL-commerce}
            ttBareme.cLibelleTypeBareme = if garan.tpbar = {&TYPEBAREME-Commercial} then "Commercial" else "Habitation"    // todo  traduction
            ttBareme.cLibelleBareme     = substitute("&1 (&2)", string(garan.nobar, "99"), string(garan.tpbar = {&TYPEBAREME-Commercial}, "Com/Hab"))
            ttBareme.dCotisation        = garan.txcot
            ttbareme.dHonoraires        = garan.txhon
            ttbareme.cTypeSaisie        = entry(2, vbGaran.lbdiv3, "@") when available vbGaran and num-entries(vbGaran.lbdiv3, "@") >= 2
            ttbareme.cProrata1erePrime  = vb2garan.cdper when available vb2garan
            ttbareme.dResultant         = fMontantCotisation(if available vbgaran then buffer vbgaran:handle else ?, buffer garan:handle)
        .
    end.
end procedure.

procedure majInfosGarantie private:
    /*------------------------------------------------------------------------------
    Purpose: Récupération des infos relatives au bail
    Notes:
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat   as int64     no-undo.
    define input parameter piGarantieDefaut as integer   no-undo.

    define buffer aspno for aspno.
    define buffer garan for garan.

    find first aspno no-lock
        where aspno.tpcon = {&TYPECONTRAT-mandat2Gerance}
          and aspno.nocon = piNumeroMandat
          and aspno.noord = 1
          and aspno.nolot = ttLotPNO.iNumeroLot no-error.
    if available aspno
    then assign
        ttLotPNO.dtTimestamp = datetime(aspno.dtmsy, aspno.hemsy)
        ttLotPNO.rRowid      = rowid(aspno)
    .
    if piGarantieDefaut = 0 then do:
        if available aspno then do:
            outils:copyValidlabeledField(buffer aspno:handle, buffer ttLotPNO:handle).
            assign
                ttLotPNO.daVente              = date(entry(1, aspno.lbdiv, "@")) when num-entries(aspno.lbdiv, "@") >= 1
                ttLotPNO.daPremiereCotisation = date(entry(2, aspno.lbdiv, "@")) when num-entries(aspno.lbdiv, "@") >= 2
                ttLotPNO.dMontantCotisation   = fDonneMontantBareme(ttLotPNO.iNumeroGarantie, ttLotPNO.iNumeroBareme, ttLotPNO.cNatureUL, ttLotPNO.daCotisation, ttLotPNO.lCotisationTraitee)
                ttLotPNO.cLibelleGarantie     = fInfosGarantie(ttLotPNO.iNumeroGarantie, "LIB")
                ttLotPNO.cLibelleBareme       = fLibelleBareme(ttLotPNO.iNumeroGarantie, ttLotPNO.iNumeroBareme, if ttLotPNO.cNatureUL = {&NATUREUL-commerce} then {&TYPEBAREME-Commercial} else {&TYPEBAREME-Habitation})
            .
        end.
    end.
    else do:
        find first garan no-lock
            where garan.tpctt = {&TYPECONTRAT-proprietaireNonOccupant}
              and garan.noctt = piGarantieDefaut
              and garan.tpbar = (if ttLotPNO.cNatureUL = {&NATUREUL-commerce} then {&TYPEBAREME-Commercial} else {&TYPEBAREME-Habitation})
              and garan.nobar <> 0
              and (garan.txcot <> 0 or garan.txhon <> 0) no-error.
        if not available garan
        then assign
            ttLotPNO.iNumeroGarantie  = 0
            ttLotPNO.cNumeroAssurance = ""
            ttLotPNO.iNumeroBareme    = 0
            ttLotPNO.daDebutAssurance = ?
            ttLotPNO.cLibelleGarantie = ""
            ttLotPNO.cLibelleBareme   = ""
        .
        else assign
            ttLotPNO.iNumeroGarantie  = piGarantieDefaut
            ttLotPNO.cNumeroAssurance = fInfosGarantie(ttLotPNO.iNumeroGarantie, "CONTRAT")
            ttLotPNO.iNumeroBareme    = garan.nobar /*1*/
            ttLotPNO.daDebutAssurance = date(fInfosGarantie(ttLotPNO.iNumeroGarantie, "DTDEB"))
            ttLotPNO.cLibelleGarantie = fInfosGarantie(ttLotPNO.iNumeroGarantie, "LIB")
            ttLotPNO.cLibelleBareme   = fLibelleBareme(ttLotPNO.iNumeroGarantie, ttLotPNO.iNumeroBareme, if ttLotPNO.cNatureUL = {&NATUREUL-commerce} then {&TYPEBAREME-Commercial} else {&TYPEBAREME-Habitation})
        .
        assign
            ttLotPNO.daFinAssurance       = ?
            ttLotPNO.daCotisation         = ?
            ttLotPNO.dMontantCotisation   = 0
            ttLotPNO.lCotisationTraitee   = false
            ttLotPNO.daVente              = ?
            ttLotPNO.daPremiereCotisation = ?
        .
    end.
end procedure.

procedure majInfosBail private:
    /*------------------------------------------------------------------------------
    Purpose: Récupération des infos relatives au bail
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat as int64   no-undo.
    define input parameter piNumeroLot    as integer no-undo.

    define variable viLocataireSvg as integer   no-undo.
    define variable vcNatureULSvg  as character no-undo initial ?.  // ? pour ne pas réinitialiser une valeur 
    define variable viULSvg        as integer   no-undo initial ?.
    define variable viCompoSvg     as integer   no-undo initial ?.
    define variable viOrdreSvg     as integer   no-undo initial ?.
    define variable vlLotPrincipal as logical   no-undo.

    define buffer unite   for unite.
    define buffer ctrat   for ctrat.
    define buffer cpuni   for cpuni.
    define buffer vbCpuni for cpuni.

    // Recherche du bail
    for each unite no-lock
        where unite.nomdt = piNumeroMandat
          and unite.noact = 0
          and unite.noapp <> 998         // PL : 23/12/2015
      , each cpuni no-lock
        where cpuni.nomdt = unite.nomdt
          and cpuni.noapp = unite.noapp
          and cpuni.nocmp = unite.nocmp
          and cpuni.nolot = piNumeroLot
        by unite.dtdeb:                // Pour avoir la dernière compo avec ce lot
        assign                         // Sauvegarde des infos de l'UL
            viLocataireSvg = unite.norol
            vcNatureULSvg  = unite.cdcmp
            viULSvg        = unite.noapp
            viCompoSvg     = unite.nocmp
            viOrdreSvg     = cpuni.noord
        .
        // Vérification du lot principal car le premier n'a pas forcément le numéro d'ordre 1 ...des fois c'est 500 ????
        find first vbCpuni no-lock
            where vbCpuni.nomdt = unite.nomdt
              and vbCpuni.noapp = unite.noapp
              and vbCpuni.nocmp = unite.nocmp no-error.
        vlLotPrincipal = (vbCpuni.nolot = piNumeroLot).
    end.
    // Maj des infos du bail 
    if viLocataireSvg <> 0 then do:
        // Positionnement sur le bail 
        find first ctrat  no-lock
            where ctrat.tpcon = {&TYPECONTRAT-bail}
              and ctrat.nocon = viLocataireSvg no-error.
        if not available ctrat then return.

        assign
            ttLotPNO.iNumeroBail        = ctrat.nocon
            ttLotPNO.cLibelleNatureBail = outilTraduction:getLibelleProg("O_COT", ctrat.ntcon)
            ttLotPNO.cNomLocataire      = outilFormatage:getNomTiers2({&TYPEROLE-locataire}, ctrat.nocon, false)
        .
    end.
    assign                   // Maj des infos de l'UL
        ttLotPNO.iNumeroUL    = viULSvg
        ttLotPNO.iNumeroCompo = viCompoSvg
        ttLotPNO.cNatureUL    = vcNatureULSvg
        ttLotPNO.cLibelleUL   = substitute("&1 (&2)",
                                    string(ttLotPNO.iNumeroUL, "999"),
                                    substring(outilTraduction:getLibelleParam("NTAPP", ttLotPNO.cNatureUL), 1, 3, "character"))
        ttLotPNO.lPrincipal   = (viOrdreSvg = 1 or vlLotPrincipal)
    .
end procedure.

procedure getTachePNO:
    /*------------------------------------------------------------------------------
    Purpose: charge la liste des lots et contrat pno
    Notes  : service utilisé par beMandatGerance.cls
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroContrat        as int64     no-undo.
    define input parameter pcGereParCabinetMandat as character no-undo.
    define output parameter table for ttTachePNO.
    define output parameter table for ttLotPNO.

//gga todo verifier si pcGereParCabinetMandat = 00001 ou 00002  

    define buffer tache for tache.

    create ttTachePNO.
    find first tache no-lock
        where tache.tpcon = {&TYPECONTRAT-mandat2Gerance}
          and tache.nocon = piNumeroContrat
          and tache.tptac = {&TYPETACHE-proprietaireNonOccupant} no-error.
    if available tache
        then outils:copyValidlabeledField(buffer tache:handle, buffer ttTachePNO:handle).
        else assign
            ttTachePNO.iNumeroMandat = piNumeroContrat
            ttTachePNO.CRUD          = "R"
         .
    if pcGereParCabinetMandat = {&GESTIONPNO-cabinet}
    or (fIsNull(pcGereParCabinetMandat) and ttTachePNO.cGereParCabinetMandant = {&GESTIONPNO-cabinet}) // si cabinet alors Charger les infos
    then run chargeLotPNO(piNumeroContrat). // Chargement de la table des lots
end procedure.

procedure chargeLotPNO private:
    /*------------------------------------------------------------------------------
    Purpose: Procedure de Chargement de la table ttLotPNO
    Notes  : (procedure ChgTbTmp)
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroContrat as int64     no-undo.

    define variable viGarantieDefaut as integer no-undo.
    define buffer local for local.
    define buffer intnt for intnt.
    define buffer garan for garan.

    empty temp-table ttLotPNO.
    /* Chargement de base par défaut */
    if not can-find(first tache no-lock
                where tache.tpcon = {&TYPECONTRAT-mandat2Gerance}
                  and tache.nocon = piNumeroContrat
                  and tache.tptac = {&TYPETACHE-proprietaireNonOccupant}
                  and tache.tpges = {&GESTIONPNO-cabinet})
    then do:               // Garantie par défaut
        find garan no-lock // Pas de find first - todo  pourquoi permettre le ambiguous sur ces critères ????
            where garan.tpctt = {&TYPECONTRAT-proprietaireNonOccupant}
              and garan.tpbar = ""
              and garan.nobar = 0 no-error.
        if available garan then viGarantieDefaut = garan.noctt.
    end.

boucleLotMandat:
    for each intnt   no-lock
        where intnt.tpidt = {&TYPEBIEN-lot}
          and intnt.tpcon = {&TYPECONTRAT-mandat2Gerance}
          and intnt.nocon = piNumeroContrat :
        // Création de l'enregistrement
        create ttLotPNO.
        assign
            ttLotPNO.iNumeroLocal  = intnt.noidt
            ttLotPNO.iNumeroMandat = piNumeroContrat
            ttLotPNO.CRUD          = "R"
        .
        // Récupération des infos du lot
        find first local  no-lock
            where local.noloc = ttLotPNO.iNumeroLocal no-error.
        //si local inexistant, affichage d'un message d'erreur, mais on veut quand meme continuer l'extraction pour les autres informations et les autres lots
        //todo a preciser dans la doc que cet extraction peut envoyer un message d'erreur     
        if not available local 
        then mError:createError({&error}, 1000379, substitute("&1&2&3", piNumeroContrat, separ[1], ttLotPNO.iNumeroLocal)). // 1000379 "Mandat N° &1 : Lot introuvable avec le N° de local &2"
        else assign
            ttLotPNO.cSurfaceLot       = substitute("&1 &2", local.sfree, outilTraduction:getLibelleParam("UTSUR", local.usree, "c"))
            ttLotPNO.iNumeroLot        = local.nolot
            ttLotPNO.cLibelleNatureLot = outilTraduction:getLibelleParam("NTLOT", local.ntlot)
        .
        run majInfosBail(piNumeroContrat, ttLotPNO.iNumeroLot).                                      // Récupération des infos du bail
        run majInfosGarantie(piNumeroContrat, viGarantieDefaut). // Récupération des infos de la garantie
    end.
    for each ttLotPNO where ttLotPNO.lPrincipal = false              : delete ttLotPNO. end. // Retrait des lots non principaux
    for each ttLotPNO where ttLotPNO.iNumeroUL  = 997                : delete ttLotPNO. end. // Retrait de l'ul 997
    for each ttLotPNO where ttLotPNO.iNumeroUL  = 998                : delete ttLotPNO. end. // Retrait de l'ul 998
    for each ttLotPNO where ttLotPNO.cNatureUL  = {&NATUREUL-parking}: delete ttLotPNO. end. // Retrait des ULs de type parking
end procedure.

procedure initComboTachePNO:
    /*------------------------------------------------------------------------------
    Purpose: Lance la procédure de chargement de la combo des garanties PNO
    Notes  : Service externe appelé par beMandatGerance.cls
    ------------------------------------------------------------------------------*/
    define output parameter table for ttGarantie.
    define output parameter table for ttBareme.
    run chargeComboGarantie.
    run chargeBareme.
end procedure.

procedure chargeComboGarantie private:
    /*------------------------------------------------------------------------------
    Purpose: Chargement de liste des garanties PNO
    Notes  :
    ------------------------------------------------------------------------------*/
    define buffer garan for garan.

    empty temp-table ttGarantie.
    for each garan no-lock
        where garan.tpctt = {&TYPECONTRAT-proprietaireNonOccupant}
          and garan.tpbar = ""
          and garan.nobar = 0:
        create ttGarantie.
        assign
            ttGarantie.iNumeroGarantie          = garan.noctt
            ttGarantie.cLibelleGarantie         = fInfosGarantie(garan.noctt, "LIB")
            ttgarantie.cCodePeriodicitePrime    = garan.cdper
            ttgarantie.cLibellePeriodicitePrime = fInfosGarantie(garan.noctt, "PERIODEPRIME")
            ttgarantie.cContrat         = if num-entries(garan.lbdiv3, "@") >= 3 then entry(3, garan.lbdiv3, "@") else ""
            ttgarantie.daDebut          = if num-entries(garan.lbdiv3, "@") >= 4 then date(entry(4, garan.lbdiv3, "@")) else ?
            ttgarantie.daFin            = if num-entries(garan.lbdiv3, "@") >= 5 then date(entry(5, garan.lbdiv3, "@")) else ?
            ttgarantie.cNumeroAssurance = fInfosGarantie(garan.noctt,"CONTRAT")
        .
    end.
end procedure.

procedure getCalculCotisation:
    /*------------------------------------------------------------------------------
    Purpose: Calcul des infos de cotisation
    Notes  : Service appelé par beMandatGerance.cls
    ------------------------------------------------------------------------------*/
    define input parameter table for ttTachePNO.
    define input parameter table for ttError.
    define input-output parameter table for ttLotPNO.

    for first ttTachePNO,
        first ttLotPNO
            where ttLotPno.iNumeroMandat = ttTachePNO.iNumeroMandat
              and ttLotPNO.CRUD = "U"
              and ttLotPNO.lControle:
        run calculDatePremiereCotisation.
        if merror:erreur() then return.
        run calculEtDupliqueCotisation.
    end.
end procedure.

procedure calculProchaineCotisation private:
    /*------------------------------------------------------------------------------
    Purpose: Calcul la date de prochaine cotisation
    Notes  : code issu de la procédure ProchaineCotisation
    ------------------------------------------------------------------------------*/
    define variable vdaCotisation    as date   no-undo.
    define variable vdaQuittancement as date   no-undo.
    define variable vhProc           as handle no-undo.

    define variable viNumeroErreur as integer no-undo.
    define variable viGlMoiQtt     as integer no-undo.
    define variable viGlMoiMdf     as integer no-undo.
    define variable viGlMoiMEc     as integer no-undo.

    define buffer garan for garan.
    define buffer vbgaran for garan.

    /* Si les infos nécessaires ne sont pas renseignées, on ne fait rien */
    if ttLotPNO.iNumeroGarantie = 0
    or ttLotPNO.iNumeroBareme = 0
    or ttLotPNO.daPremiereCotisation = ?
    or ttLotPNO.lCotisationTraitee // Date de la cotisation si pas déjà traitée
    then return.

    for first vbgaran   no-lock // garantie
        where vbGaran.tpctt = {&TYPECONTRAT-proprietaireNonOccupant}
          and vbGaran.tpbar = ""
          and vbGaran.nobar = 0
          and vbGaran.noctt = ttLotPNO.iNumeroGarantie
      , first garan no-lock // Baremes
        where garan.tpctt = {&TYPECONTRAT-proprietaireNonOccupant}
          and garan.nobar = ttLotPNO.iNumeroBareme
          and garan.noctt = ttLotPNO.iNumeroGarantie
          and garan.tpbar = (if ttLotPNO.cNatureUL = {&NATUREUL-commerce} then {&TYPEBAREME-Commercial} else {&TYPEBAREME-Habitation})
          and (garan.txcot <> 0 or garan.txhon <> 0):
        // Date de prochaine cotisation - Ajout d'un mois jusqu'à la date du prochain quit
        run bail/bail.p persistent set vhProc.
        run getTokenInstance in vhProc(mToken:JSessionId).
        run getMoisQuittancement in vhProc (output viNumeroErreur, output viGlMoiQtt, output viGlMoiMdf, output viGlMoiMec).
        run destroy   in vhProc.
        assign
            vdaCotisation    = ttLotPNO.daDebutAssurance
            vdaQuittancement = date(viGlMoiMdf modulo 100, 01, integer(truncate(viGlMoiMdf / 100,0)))
        .
boucle:
        repeat:
            /* Date du jour atteinte ou dépassée */
            if vdaCotisation >= vdaQuittancement then leave boucle.
            /* Ajout de la périodicité de la garantie */
            vdaCotisation = add-interval(vdaCotisation, integer(vbGaran.cdper), "months").
        end.
        assign
            ttLotPNO.daCotisation       = vdaCotisation
            ttLotPNO.dMontantCotisation = fMontantCotisation(buffer vbGaran:handle, buffer garan:handle) // Montant de la cotisation si pas déjà renseigné
        .
        if ttLotPNO.daDebutAssurance >= vdaQuittancement and not ttLotPNO.lCotisationTraitee // Prorata de la cotisation */
        then ttLotPNO.dMontantCotisation = fDonneProrata(fMontantCotisation(buffer vbGaran:handle, buffer garan:handle),
                                                         ttLotPNO.daCotisation,
                                                         vbGaran.cdPer,
                                                         fProrata1erePrime(buffer garan:handle)).
        ttLotPNO.dMontantCotisation = truncate(ttLotPNO.dMontantCotisation, 2).

        /* Avertissement si cotisation en décembre et mois de quit janvier */
        if viGlMoiMdf modulo 100 = 1 and month(ttLotPNO.daDebutAssurance) = 12
        then mError:createError({&info}, 1000380, string(year(ttLotPNO.daDebutAssurance))). // 1000380 "La cotisation de l'année &1 ne peut être facturée automatiquement car le quittancement est déjà effectué. Vous devez la comptabiliser manuellement"
    end.
end procedure.

procedure calculDatePremiereCotisation private:
    /*------------------------------------------------------------------------------
    Purpose: Calcul la date de 1ere cotisation
    Notes  : code issu de la procédure PremiereCotisation
    ------------------------------------------------------------------------------*/
    define variable vdaCotisation    as date    no-undo.
    define variable vdaMoisQuittance as date    no-undo.
    define variable viNumeroErreur   as integer no-undo.
    define variable viGlMoiQtt       as integer no-undo.
    define variable viGlMoiMdf       as integer no-undo.
    define variable viGlMoiMEc       as integer no-undo.
    define variable vhProc           as handle  no-undo.

    define buffer garan   for garan.
    define buffer vbgaran for garan.

    // Si les infos nécessaires ne sont pas renseignées, on ne fait rien
    if ttLotPNO.iNumeroGarantie = 0
     or ttLotPNO.iNumeroBareme = 0
     or ttLotPNO.daDebutAssurance = ?
     or ttLotPNO.daPremiereCotisation <> ? // Ne rien faire si date déjà renseignée
     or ttLotPNO.lCotisationTraitee        // Date de la cotisation si pas déjà traitée
     then return.

    for first vbGaran no-lock // garantie
        where vbGaran.tpctt = {&TYPECONTRAT-proprietaireNonOccupant}
          and vbGaran.tpbar = ""
          and vbGaran.nobar = 0
          and vbGaran.noctt = ttLotPNO.iNumeroGarantie
      , first garan no-lock // Baremes
        where garan.tpctt = {&TYPECONTRAT-proprietaireNonOccupant}
          and garan.nobar = ttLotPNO.iNumeroBareme
          and garan.noctt = ttLotPNO.iNumeroGarantie
          and garan.tpbar = (if ttLotPNO.cNatureUL = {&NATUREUL-commerce} then {&TYPEBAREME-Commercial} else {&TYPEBAREME-Habitation})
          and (garan.txcot <> 0 or garan.txhon <> 0):
        // Date de premiere cotisation. Ajout d'un mois jusqu'à la date du prochain quit
        run bail/bail.p persistent set vhProc.
        run getTokenInstance in vhProc(mToken:JSessionId).
        run getMoisQuittancement in vhProc(output viNumeroErreur, output viGlMoiQtt, output viGlMoiMdf, output viGlMoiMec).
        run destroy   in vhProc.
        assign
            vdaMoisQuittance = date(viGlMoiMdf modulo 100, 01, integer(truncate(viGlMoiMdf / 100,0)))
            vdaCotisation    = ttLotPNO.daDebutAssurance
        .
boucle:
        repeat:
            if vdaCotisation >= vdaMoisQuittance then leave boucle. // Date du jour atteinte ou dépassée
            vdaCotisation = add-interval(vdaCotisation, 1, "months"). // Ajout de la périodicité
        end.
        ttLotPNO.daPremiereCotisation = vdaCotisation.
    end.
end procedure.

procedure calculEtDupliqueCotisation private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : code issu de la procédure Trig_LEAVE-COLONNE
    ------------------------------------------------------------------------------*/
    define variable viCompteurLots as integer no-undo.
    define buffer vbttLotPNO for ttLotPNO.

    for each vbttLotPNO
        where vbttLotPNO.iNumeroMandat = ttTachePno.iNumeroMandat and vbttLotPNO.iNumeroBareme > 0:
        viCompteurLots = viCompteurLots + 1.
    end.
    run calculProchaineCotisation.
    if ttTachePNO.lReport and viCompteurLots > 1 then do:
        if outils:questionnaire(1000378, table ttError by-reference) <= 2  then return.  // 1000381 "Voulez-vous reporter la saisie sur les autres lots ?" then do :
        // Report des infos
        for each vbttLotPNO
            where vbttLotPNO.iNumeroMandat = ttTachePno.iNumeroMandat
              and vbttLotPNO.iNumeroLot    <> ttLotPNO.iNumeroLot
              and vbttLotPNO.iNumeroBareme <> 0:  // PL : 18/12/2015 - (Fiche : 1215/0158)
            assign
                vbttLotPNO.cNumeroAssurance     = ttLotPNO.cNumeroAssurance
                vbttLotPNO.daDebutAssurance     = ttLotPNO.daDebutAssurance
                vbttLotPNO.daFinAssurance       = ttLotPNO.daFinAssurance
                vbttLotPNO.daCotisation         = ttLotPNO.daCotisation
                vbttLotPNO.daPremiereCotisation = ttLotPNO.daPremiereCotisation
            .
            if vbttLotPNO.CRUD = "R" then vbttLotPNO.CRUD = "U".
        end.
        // Calcul de la cotisation pour chaque ligne
        for each ttLotPNO where ttLotPNO.iNumeroMandat = ttTachePno.iNumeroMandat:
            run calculProchaineCotisation.
            if ttLotPNO.CRUD = "R" then ttLotPNO.CRUD = "U".
        end.
    end.
end procedure.

procedure controle private:
    /*------------------------------------------------------------------------------
    Purpose: Controle avant validation
    Notes  :
    ------------------------------------------------------------------------------*/
    for first ttTachePNO where ttTachePNO.CRUD = "U":
        if lookup(ttTachePNO.cGereParCabinetMandant, substitute("&1,&2", {&GESTIONPNO-cabinet}, {&GESTIONPNO-mandant})) = 0
        then do :
            mError:createError({&info}, 1000382). // 1000382 "Vous devez choisir un mode de gestion de la PNO (Cabinet ou Mandant)"
            return.
        end.
boucleLotpno:
        for each ttLotPNO where ttLotPNO.iNumeroMandat = ttTachePNO.iNumeroMandat:
            // Si la ligne est vide, on ne fait rien
            if  fIsNull(fInfosGarantie(ttLotPNO.iNumeroGarantie,"LIB"))
            and fIsNull(fLibelleBareme(ttLotPNO.iNumeroGarantie, ttLotPNO.iNumeroBareme, if ttLotPNO.cNatureUL = {&NATUREUL-commerce} then {&TYPEBAREME-Commercial} else {&TYPEBAREME-Habitation}))
            and fIsNull(ttLotPNO.cNumeroAssurance)
            and ttLotPNO.daDebutAssurance = ?
            and ttLotPNO.daFinAssurance = ?
            and ttLotPNO.daCotisation = ?
            and ttLotPNO.dMontantCotisation = ?
            and ttLotPNO.daVente = ?
            then next boucleLotpno.

            /* Si une ligne a été modifié et qu'il n'y a pas de garantie: PB */
            if (ttLotPNO.iNumeroGarantie = 0 or ttLotPNO.iNumeroBareme = 0) then do:
                mError:createError({&error}, 1000383). // 1000383 "Un ou plusieurs lots n'ont pas de garantie ou de barême associé"
                leave boucleLotpno.
            end.
            /* Si une garantie sans barême ou inverse: PB */
            if (ttLotPNO.iNumeroGarantie <> 0 and ttLotPNO.iNumeroBareme = 0)
            or (ttLotPNO.iNumeroGarantie = 0  and ttLotPNO.iNumeroBareme <> 0)
            then do:
                mError:createError({&error}, 1000384).  // 1000384 "Un ou plusieurs lots ont une garantie associée mais pas de barême ou inversement"
                leave boucleLotpno.
            end.
            /* Si une ligne a une garantie ou un bareme */
            if ttLotPNO.iNumeroGarantie <> 0
            then do:
                /* Si pas de numero de contrat: PB */
                if fIsNull(ttLotPNO.cNumeroAssurance) then do:
                    mError:createError({&error}, 1000385).  // 1000385 "Un ou plusieurs lots ont une garantie associée mais pas de barême ou inversement"
                    leave boucleLotpno.
                end.
                /* Si pas de date de debut ou de fin de contrat: PB */
                if ttLotPNO.daDebutAssurance = ? then do:
                    mError:createError({&error}, 1000386).  // 1000386 "Un ou plusieurs lots n'ont pas de date de début ou de fin de contrat"
                    leave boucleLotpno.
                end.
                /* Si pas de date de cotisation: PB */
                if ttLotPNO.daCotisation = ? then do:
                    mError:createError({&error}, 1000387).  // 1000387 "Un ou plusieurs lots n'ont pas de date de prochaine cotisation"
                    leave boucleLotpno.
                end.
                /* Si pas de montant de cotisation: PB */
                if ttLotPNO.dMontantCotisation = 0 then do:
                    mError:createError({&error}, 1000388). // 1000388 "Un ou plusieurs lots n'ont pas de montant de prochaine cotisation"
                    leave boucleLotpno.
                end.
            end.
            /* controle cohérence des dates */
            if ttLotPNO.daDebutAssurance <> ? and ttLotPNO.daFinAssurance <> ?
            then do:
                if ttLotPNO.daDebutAssurance > ttLotPNO.daFinAssurance
                then do:
                    mError:createError({&error}, 1000389). // 1000389 "Un ou plusieurs lots ont une incohérence entre la date de début et de fin de contrat assurance"
                    leave boucleLotpno.
                end.
                if ttLotPNO.daCotisation < ttLotPNO.daDebutAssurance
                then do:
                    mError:createError({&error}, 1000390). // 1000390 "Un ou plusieurs lots ont une date de prochaine cotisation antérieure à la date de début du contrat assurance"
                    leave boucleLotpno.
                end.
            end.
        end.
    end.
end procedure.

procedure updateTachePNO :
    /*------------------------------------------------------------------------------
    Purpose: Controle et validation tache PNO
    Notes  : Service appelé par beMandatGerance.cls
    ------------------------------------------------------------------------------*/
    define input parameter table for ttTachePNO.
    define input parameter table for ttLotPNO.

blocTrans:
    do transaction:
        run controle.
        if merror:erreur() then undo blocTrans, return.
        run validation.
        if merror:erreur() then undo blocTrans, return.
    end.
end procedure.

procedure suppressionAspno private:
    /*------------------------------------------------------------------------------
    Purpose: Procedure de suppression des aspno (gestion par le mandant)
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhProcAspno as handle    no-undo.

    run adblib/aspno_CRUD.p persistent set vhProcAspno.
    run getTokenInstance in vhProcAspno(mToken:JSessionId).
    empty temp-table ttAspno.
    run getAspno in vhProcAspno({&TYPECONTRAT-mandat2Gerance}, ttTachePNO.iNumeroMandat, ?, table ttAspno by-reference).
    for each ttAspno:
        ttAspno.CRUD  = "D".
    end.
    run setAspno in vhProcAspno(table ttAspno by-reference).
    run destroy in vhProcAspno.
end procedure.

procedure validation private:
    /*------------------------------------------------------------------------------
    Purpose: Validation tache PNO
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhProcTache as handle no-undo.
    define variable vhProcCttac as handle no-undo.
    define variable vhProcAspno as handle no-undo.
    define buffer cttac for cttac.
    define buffer tache for tache.

    run adblib/aspno_CRUD.p persistent set vhProcAspno.
    run getTokenInstance in vhProcAspno(mToken:JSessionId).
    run tache/tache.p       persistent set vhProcTache.
    run getTokenInstance in vhProcTache(mToken:JSessionId).
    run adblib/cttac_CRUD.p persistent set vhProcCttac.
    run getTokenInstance in vhProcCttac(mToken:JSessionId).

blocTrans:
    do transaction:
        for first ttTachePNO where ttTachePNO.CRUD = "U":
            find last tache no-lock
                where tache.tpcon = {&TYPECONTRAT-mandat2Gerance}
                  and tache.nocon = ttTachePNO.iNumeroMandat
                  and tache.tptac = {&TYPETACHE-proprietaireNonOccupant} no-error.
            empty temp-table ttTache.
            create ttTache.
            assign
                ttTache.tpTac = {&TYPETACHE-proprietaireNonOccupant}
                ttTache.tpcon = {&TYPECONTRAT-mandat2Gerance}
                ttTache.nocon = ttTachePNO.iNumeroMandat
                ttTache.noita = tache.noita when available tache
                ttTache.tpges = ttTachePNO.cGereParCabinetMandant
                ttTache.CRUD        = string(available tache, "U/C")
                ttTache.dtTimestamp = ttTachePNO.dtTimeStamp
                ttTache.rRowid      = rowid(tache) when available tache
            .
            run setTache in vhProcTache(table ttTache by-reference).
            if mError:erreur() then undo blocTrans, leave blocTrans.

            if not can-find(first cttac
                where cttac.tpcon = {&TYPECONTRAT-mandat2Gerance}
                  and cttac.nocon = ttTachePNO.iNumeroMandat
                  and cttac.tptac = {&TYPETACHE-proprietaireNonOccupant})
            then do: // lien contrat/tache
                empty temp-table ttCttac.
                create ttCttac.
                assign
                    ttCttac.tpcon = {&TYPECONTRAT-mandat2Gerance}
                    ttCttac.nocon = ttTachePNO.iNumeroMandat
                    ttCttac.tptac = {&TYPETACHE-refacturationDepMandat1}
                    ttCttac.CRUD  = "C"
                .
                run setCttac in vhProcCttac(table ttCttac by-reference).
                if mError:erreur() then undo blocTrans, leave blocTrans.
            end.

            empty temp-table ttAspno.
            if ttTachePNO.cGereParCabinetMandant = {&GESTIONPNO-mandant}  // Mandant
            then run SuppressionAspno.
            else do:
                for each ttLotPNO where ttLotPNO.CRUD = "U" : // Mise à jour des lots
                    run readAspno in vhProcAspno(
                        {&TYPECONTRAT-mandat2Gerance},
                        ttTachePNO.iNumeroMandat,
                        1,
                        ttLotPNO.iNumeroLot,
                        table ttAspno by-reference
                    ).
                    find first ttAspno
                        where ttAspno.tpcon = {&TYPECONTRAT-mandat2Gerance}
                          and ttAspno.nocon = ttTachePNO.iNumeroMandat
                          and ttAspno.noord = 1
                          and ttAspno.nolot = ttLotPNO.iNumeroLot no-error.
                    if available ttAspno
                    then ttAspno.CRUD = "U".
                    else do:
                        create ttAspno.
                        assign
                            ttAspno.tpcon = {&TYPECONTRAT-mandat2Gerance}
                            ttAspno.nocon = ttTachePNO.iNumeroMandat
                            ttAspno.noord = 1
                            ttAspno.nolot = ttLotPNO.iNumeroLot
                            ttAspno.CRUD  = "C"
                        .
                    end.
                    assign
                        ttAspno.noapp      = ttLotPNO.iNumeroUL
                        ttAspno.cdcmp      = string(ttLotPNO.iNumeroCompo)
                        ttAspno.numcontrat = ttLotPNO.cNumeroAssurance
                        ttAspno.tpgar      = {&TYPECONTRAT-proprietaireNonOccupant}
                        ttAspno.nogar      = ttLotPNO.iNumeroGarantie
                        ttAspno.nobar      = ttLotPNO.iNumeroBareme
                        ttAspno.dtdebass   = ttLotPNO.daDebutAssurance
                        ttAspno.dtfinass   = ttLotPNO.daFinAssurance
                        ttAspno.dtcotis1   = ttLotPNO.daCotisation
                        ttAspno.mtcotis1   = ttLotPNO.dMontantCotisation
                        ttAspno.lbdiv      = substitute("&1@&2@",
                                                 if ttLotPNO.daVente <> ? then string(ttLotPNO.daVente) else "",
                                                 if ttLotPNO.daPremiereCotisation <> ? then string(ttLotPNO.daPremiereCotisation) else "")
                    .
                end.
                run setAspno in vhProcAspno(table ttAspno by-reference).
            end.
            if mError:erreur() then undo blocTrans, leave blocTrans.
        end.
        for first ttTachePNO where ttTachePNO.CRUD = "D":
            for each cttac no-lock
                where cttac.tpcon = {&TYPECONTRAT-mandat2Gerance}
                  and cttac.nocon = ttTachePNO.iNumeroMandat
                  and cttac.tptac = {&TYPETACHE-proprietaireNonOccupant}:
                empty temp-table ttcttac.
                create ttCttac.
                if outils:copyValidField(buffer cttac:handle, buffer ttCttac:handle) then ttCttac.CRUD  = "D".
            end.
            run setCttac in vhProcCttac(table ttCttac by-reference).
            if mError:erreur() then undo blocTrans, leave blocTrans.

            for each tache no-lock
                where tache.tpcon = {&TYPECONTRAT-mandat2Gerance}
                  and tache.nocon = ttTachePNO.iNumeroMandat
                  and tache.tptac = {&TYPETACHE-proprietaireNonOccupant} :
                empty temp-table ttTache.
                create ttTache.
                if outils:copyValidField(buffer tache:handle, buffer ttTache:handle) then do:
                    assign
                        ttTache.CRUD        = "D"
                        ttTache.dtTimeStamp = ttTachePNO.dtTimeStamp
                        ttTache.rRowid      = ttTachePNO.rRowid
                    .
                    run setTache in vhProcTache(table ttTache by-reference).
                    if mError:erreur() then undo blocTrans, leave blocTrans.
                end.
            end.
            run SuppressionAspno.
            if mError:erreur() then undo blocTrans, leave blocTrans.
        end.
    end. // trans
    run destroy in vhProcTache.
    run destroy in vhProcCttac.
    run destroy in vhProcAspno.
    error-status:error = false no-error.  // reset error-status

end procedure.