/*------------------------------------------------------------------------
File        : facture.p
Purpose     :
Author(s)   : kantena - 2017/05/02
Notes       : le plus grans entier 32 bits est exp(2, 31) - 1 = 2147483647
----------------------------------------------------------------------*/

&SCOPED-DEFINE MAXRETURNEDROWS 500

&SCOPED-DEFINE MAXINTEGER32    2147483647

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{compta/include/facture.i}

procedure getFactureByRowid:
    /*------------------------------------------------------------------------------
    Purpose: Récupération d'une facture par son rowid
    Notes  : service utilisé par beFacture.cls
    ------------------------------------------------------------------------------*/
    define input  parameter prRowId as rowid no-undo.
    define output parameter table for ttFacture.

    define buffer factu for factu.

    for first factu no-lock
        where rowid(factu) = prRowId:
        run createTTFacture(input buffer factu:handle).
    end.
end procedure.

procedure getFacture:
    /*------------------------------------------------------------------------------
    Purpose: Récupération d'une facture par son numéro de facture
    Notes  : service utilisé par beFacture.cls
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroFacture as integer no-undo.
    define output parameter table for ttFacture.

    define buffer factu for factu.

    for first factu no-lock
        where factu.nofac = piNumeroFacture:
        run createTTFacture(input buffer factu:handle).
    end.

end procedure.

procedure rechercheFacture:
    /*------------------------------------------------------------------------------
    Purpose: Recherche avancée des factures
    Notes  : service utilisé par beFacture.cls
        Il faut pouvoir utiliser le bon index, pour cela mettre une heuristique entre nofact, nocon et dtfac!
        index candidats: ix_factu01(nofac - PrimaireUnique), ix_factu07(dtfac,nofou,fgfac), ix_factu11(nocon,nopie,...)
    heuristique:
        compléter les début/fin par les valeurs mini/maxi et choisir le bon index.
        Attention, une date dans une requête doit garder le format 'mdy' !!!!!
    ------------------------------------------------------------------------------*/
    define input parameter poCollection as class collection no-undo.
    define output parameter table for ttFacture.

    define variable vcDateFormat    as character no-undo.
    define variable viNombreLigne   as integer   no-undo.
    define variable viFacture       as integer   no-undo.
    define variable viFactureDebut  as integer   no-undo.
    define variable viFactureFin    as integer   no-undo.
    define variable viMandat        as integer   no-undo.
    define variable viMandatDebut   as integer   no-undo.
    define variable viMandatFin     as integer   no-undo.
    define variable vdaFactureDebut as date      no-undo.
    define variable vdaFactureFin   as date      no-undo.
    define variable vcWhere         as character no-undo.
    define variable vcIndex         as character no-undo.
    define variable vcQuery         as character no-undo.
    define variable vhQuery         as handle    no-undo.

    empty temp-table ttFacture.
    create query vhQuery.
    vhQuery:set-buffers(buffer factu:handle).
    assign
        vcDateFormat    = session:date-format
        session:date-format = 'mdy'
        vdaFactureDebut = poCollection:getDate('daDateFactureDebut')
        vdaFactureFin   = poCollection:getDate('daDateFactureFin')
        viFacture       = poCollection:getInteger('iNumeroFacture')
        viFactureDebut  = poCollection:getInteger('iNumeroFactureDebut')
        viFactureFin    = poCollection:getInteger('iNumeroFactureFin')
        viMandat        = poCollection:getInteger('iNumeroMandat')
        viMandatDebut   = poCollection:getInteger('iNumeroMandatDebut')
        viMandatFin     = poCollection:getInteger('iNumeroMandatFin')
    .
    if vdaFactureDebut = ? then vdaFactureDebut = 01/01/1901.
    if vdaFactureFin   = ? then vdaFactureFin   = 12/31/9999.
    {&_proparse_ prolint-nowarn(when)}
    if viFacture > 0
    then assign
        viFactureDebut = viFacture
        viFactureFin   = viFacture
    .
    else assign
        viFactureDebut = 1               when viFactureDebut = ? or viFactureDebut = 0
        viFactureFin   = {&MAXINTEGER32} when viFactureFin   = ? or viFactureFin   = 0
    .
    {&_proparse_ prolint-nowarn(when)}
    if viMandat > 0
    then assign
        viMandatDebut = viMandat
        viMandatFin   = viMandat
    .
    else assign
        viMandatDebut = 1               when viMandatDebut  = ? or viMandatDebut  = 0
        viMandatFin   = {&MAXINTEGER32} when viMandatFin    = ? or viMandatFin    = 0
    .
    assign
        session:date-format = 'mdy'
        vcWhere = substitute('&1 and &2 and &3',
                      if viFactureDebut = viFactureFin
                      then substitute('factu.nofac = &1', viFactureDebut)
                      else substitute('factu.nofac >= &1 and factu.nofac <= &2', viFactureDebut, viFactureFin),
                      if viMandatDebut = viMandatFin
                      then substitute('factu.nocon = &1', viMandatDebut)
                      else substitute('factu.nocon >= &1 and factu.nocon <= &2', viMandatDebut, viMandatFin),
                      // Attention, une date dans un query doit rester en format mdy !!!!!
                      if vdaFactureDebut = vdaFactureFin
                      then substitute('factu.dtfac = &1', vdaFactureDebut)
                      else substitute('factu.dtfac >= &1 and factu.dtfac <= &2', vdaFactureDebut, vdaFactureFin))
        session:date-format = vcDateFormat
        vcIndex = if viFactureDebut = viFactureFin
                  then 'ix_factu01'
                  else if viMandatDebut = viMandatFin
                       then 'ix_factu11'
                       else if vdaFactureDebut = vdaFactureFin
                            then 'ix_factu07'
                            else if viFactureDebut > 1 or viFactureFin < {&MAXINTEGER32}
                                 then 'ix_factu01'
                                 else if viMandatDebut > 1 or viMandatFin < {&MAXINTEGER32}
                                      then 'ix_factu11'
                                      else if vdaFactureDebut > 01/01/1901 or vdaFactureFin < 12/31/9999
                                           then 'ix_factu07'
                                           else 'ix_factu01'
        vcQuery = substitute('for each factu no-lock where &1 use-index &2', vcWhere, vcIndex)
    .
    vhQuery:query-prepare(vcQuery).

message 'RECHERCHE AVANCEE '  vcQuery.

    vhQuery:query-open().
boucle:
    repeat:
        vhQuery:get-next().
        if vhQuery:query-off-end then leave boucle.
        viNombreLigne = viNombreLigne + 1.
        run createTTFacture(input buffer factu:handle).
        if viNombreLigne >= {&MAXRETURNEDROWS}
        then do:
            mError:createError({&warning}, 211668, "{&MAXRETURNEDROWS}").  // nombre maxi d'enregistrement atteint
            leave boucle.
        end.
    end.
    vhQuery:query-close() no-error.
    delete object vhQuery no-error.

end procedure.

procedure createTTFacture private:
    /*------------------------------------------------------------------------------
    Purpose: Copie les informations de la table physique vers la temp-table
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter phBuffer as handle no-undo.
    define variable vhFournisseur   as handle  no-undo. // handle de procédure

    run tiers/fournisseur.p persistent set vhFournisseur.
    run getTokenInstance in vhFournisseur(mToken:JSessionId).

    create ttFacture.
    assign
        ttFacture.daDateFacture                = phBuffer::DtFac
        ttFacture.dNumeroIdentifiantFacture    = phBuffer::noidt-fac
        ttFacture.iNumeroFacture               = phBuffer::NoFac
        ttFacture.cTypeIdentifiantFacture      = phBuffer::tpidt-fac
        ttFacture.daDateComptable              = phBuffer::DtCpt
        ttFacture.daDateEcheance               = phBuffer::DtEch
        ttFacture.cReferenceFacture            = phBuffer::ref-fac
        ttFacture.iReferenceClient             = phBuffer::NoRef
        ttFacture.cReferenceFournisseur        = phBuffer::NoReg
        ttFacture.iNumeroAdresseFacturation    = phBuffer::AdFac
        ttFacture.iNumeroTerritorialite        = phBuffer::NoTer
        ttFacture.dMontantTva                  = phBuffer::MtTva
        ttFacture.dMontantTtc                  = phBuffer::MtTtc
        ttFacture.lFactureAvoir                = phBuffer::FgFac
        ttFacture.lFacturePayee                = phBuffer::FgPaye
        ttFacture.iNumeroPieceComptable        = phBuffer::NoPie
        ttFacture.cCodeJournal                 = phBuffer::CdJou
        ttFacture.cCommentaire                 = phBuffer::LbCom
        ttFacture.iNumeroMandat                = phBuffer::nocon
        ttFacture.cTypeMandat                  = phBuffer::tpcon
        ttFacture.cLibelleEcriture             = phBuffer::LbEcr
        ttFacture.iNumeroExercice              = phBuffer::NoExe
        ttFacture.iNumeroPeriode               = phBuffer::NoPer
        ttFacture.lMoisCloture                 = phBuffer::FgMoisClot
        ttFacture.iModeReglement               = phBuffer::MdReg
        ttFacture.dMontantPort                 = phBuffer::MtPor
        ttFacture.iCodeTvaPort                 = phBuffer::CdTvP
        ttFacture.dMontantTvaPort              = phBuffer::TvPor
        ttFacture.dMontantEscomptePort         = phBuffer::EsPor
        ttFacture.dMontantTvaEscomptePort      = phBuffer::TvEsP
        ttFacture.dMontantEmballage            = phBuffer::MtEmb
        ttFacture.iCodeTvaEmballage            = phBuffer::CdTvE
        ttFacture.dMontantTvaEmballage         = phBuffer::TvEmb
        ttFacture.dMontantEscompteEmballage    = phBuffer::EsEmb
        ttFacture.dMontantTvaEscompteEmballage = phBuffer::TvEsE
        ttFacture.dTauxRemise                  = phBuffer::TxRem
        ttFacture.dMontantRemise               = phBuffer::MtRem
        ttFacture.dMontantTvaRemise            = phBuffer::TvRem
        ttFacture.dTauxEscompte                = phBuffer::TxEsc
        ttFacture.dMontantEscompte             = phBuffer::MtEsc
        ttFacture.dMontantTvaEscompte          = phBuffer::TvEsc
        ttFacture.lEscompteReglement           = phBuffer::FgEsc
        ttFacture.lBonAPayer                   = phBuffer::FgBap
        ttFacture.iNumeroFournisseur           = phBuffer::NoFou
        ttFacture.iNumeroContratFournisseur    = phBuffer::NoCttF
        ttFacture.cTypeContratFournisseur      = phBuffer::tpcttF
        ttFacture.cCollectifFournisseur        = phBuffer::sscoll-cle
        ttFacture.lComptabilisation            = phBuffer::FgCpt
        ttFacture.cDivers1                     = phBuffer::LbDiv1
        ttFacture.cDivers2                     = phBuffer::LbDiv2
        ttFacture.cDivers3                     = phBuffer::LbDiv3
        ttFacture.cTypeRoleSignalant           = phBuffer::TpPar
        ttFacture.iNumeroRoleSignalant         = phBuffer::NoPar
        ttFacture.cCodeModeSignalement         = phBuffer::MdSig
        ttFacture.cEcheancier                  = phBuffer::Echeancier
        ttFacture.cUserModification            = phBuffer::CdMsy
        ttFacture.CRUD                         = "R"
        ttFacture.dtTimeStamp                  = datetime(phBuffer::DtMsy, phBuffer::HeMsy)
        ttFacture.rRowid                       = phBuffer:rowid
        ttFacture.cLibelleFournisseur          = dynamic-function('getLibelleFour' in vhFournisseur, phBuffer::tpcon, phBuffer::NoFou)
    .
    run destroy in vhFournisseur.
end procedure.
