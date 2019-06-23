/*------------------------------------------------------------------------
File        : comptabilisationReliquat.p
Purpose     : Paramètres pour solder chb en cloture dossier
Author(s)   : gg  -  2017/04/07
Notes       : reprise du pgm adb\src\trav\soldechb.p

01 27/10/2011  DM  1010/0125 Gestion des droits
02 07/02/2016  DM  0217/0002 Limite de plafond grisée
----------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{travaux/include/comptabilisationReliquat.i}

procedure initialisationTrt:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe (dossierTravaux.p)
    ------------------------------------------------------------------------------*/
    define input parameter poCollection as collection no-undo.
    define output parameter table for ttComptabilisationReliquat.

    define variable viNumeroMandat        as int64     no-undo.
    define variable viNumeroDossier       as integer   no-undo.

    define buffer ietab  for ietab.
    define buffer agest  for agest.
    define buffer ijou   for ijou.
    define buffer parenc for parenc.

    assign
        viNumeroMandat    = poCollection:getInteger("iNumeroMandat")
        viNumeroDossier   = poCollection:getInteger("iNumeroDossierTravaux")
    .

message "gga debut initialisationTrt " viNumeroMandat "//" viNumeroDossier.

    empty temp-table ttComptabilisationReliquat.
    create ttComptabilisationReliquat.
    assign
        ttComptabilisationReliquat.CRUD                = "R"
        ttComptabilisationReliquat.iNumDossier         = viNumeroDossier
        ttComptabilisationReliquat.cTypeMouvement      = "OD"                              /** Type de mouvement par défaut **/
        ttComptabilisationReliquat.cCodCollectif01     = "CHB"                             /** Collectifs **/
        ttComptabilisationReliquat.cCodCollectif02     = "C"
        ttComptabilisationReliquat.cTypeOd             = "C"                               /** Par défaut: Bascule vers copropriétaire C **/
        ttComptabilisationReliquat.cLibelle            = substitute('&1 &2', outilTraduction:getLibelle(110129), string(viNumeroDossier,"99")) /** Valeur par défaut du libellé : DIFF DE REGLEMENT DOSSIER N° XX **/
        ttComptabilisationReliquat.lLimitePlafond      = yes
        ttComptabilisationReliquat.lCoproDebUniquement = no
        ttComptabilisationReliquat.daDateComptable     = today                             /** date comptable = date du jour et elle doit être dans le période du gestionnaire du mandat **/
    .
    for first ietab no-lock
        where ietab.soc-cd = integer(mtoken:cRefPrincipale)
          and ietab.etab-cd = viNumeroMandat:
        for first agest no-lock
            where agest.soc-cd = ietab.soc-cd
              and agest.gest-cle = ietab.gest-cle:
            if today < agest.dadeb or today > agest.dafin
            then ttComptabilisationReliquat.daDateComptable = agest.dadeb.
        end.
        ttComptabilisationReliquat.cDevise = caps(ietab.dev-cd).                       /** Devise par défaut **/
        for first ijou no-lock
            where ijou.soc-cd    = ietab.soc-cd
              and ijou.etab-cd   = ietab.etab-cd
              and ijou.natjou-gi = 46
              and ijou.natjou-cd = 4:
            ttComptabilisationReliquat.cJournal = caps(ijou.jou-cd).                    /** Journal par défaut **/
        end.
    end.
    for first parenc no-lock
        where parenc.soc-cd  = integer(mtoken:cRefPrincipale)
          and parenc.etab-cd = viNumeroMandat:
        ttComptabilisationReliquat.dConfirmPlafond = parenc.nso-mttx.
    end.

end procedure.

procedure Validation:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :  service externe (beComptabilisationReliquat.cls)
    ------------------------------------------------------------------------------*/
    define input parameter poCollection as collection no-undo.
    define input-output parameter table for ttComptabilisationReliquat.

    define variable viNumeroMandat as int64     no-undo.
    define variable vcTypeMandat   as character no-undo.

    define buffer ietab  for ietab.
    define buffer agest  for agest.
    define buffer trdos  for trdos.

    assign
        vcTypeMandat   = poCollection:getCharacter("cTypeMandat")
        viNumeroMandat = poCollection:getInteger("iNumeroMandat")
    .

message "gga debut Validation " vcTypeMandat "//" viNumeroMandat "//" mtoken:cRefPrincipale.

    find first ttComptabilisationReliquat
        where ttComptabilisationReliquat.CRUD = "U" no-error.
    if not available ttComptabilisationReliquat
    then do:
        mError:createError({&error}, 4000038).   /* enregistrement traitement comptabilisation reliquat inexistant */
        return.
    end.

    /** La date comptable doit être dans le période du gestionnaire du mandat **/
    for first ietab no-lock
        where ietab.soc-cd = integer(mtoken:cRefPrincipale)
          and ietab.etab-cd = viNumeroMandat
      , first agest no-lock
        where agest.soc-cd = ietab.soc-cd
          and agest.gest-cle = ietab.gest-cle:
        if ttComptabilisationReliquat.daDateComptable < agest.dadeb
        or ttComptabilisationReliquat.daDateComptable > agest.dafin
        then do:
            /* la date comptable doit être comprise dans le mois du responsable comptable (&1) */
            mError:createError({&error}, 4000040, substitute("&1/&2", string(month(agest.dadeb), "99"), string(year(agest.dadeb), "9999"))).
            return.
        end.
    end.

    /** Le Libellé est obligatoire **/
    if ttComptabilisationReliquat.cLibelle = ? or ttComptabilisationReliquat.cLibelle = ""
    then do:
        mError:createError({&error}, 102835).   /* le libellé est obligatoire */
        return.
    end.
    /** Solde vers C ou CHB - dossier **/
    if ttComptabilisationReliquat.cTypeOd = "D"
    then do:
        if ttComptabilisationReliquat.iNumDossier = 0
        then do:
            mError:createError({&error}, 4000037).   /* La saisie d'un numéro de dossier est obligatoire */
            return.
        end.
        /* Dossier existe ? */
        find first trdos no-lock
            where trdos.tpcon = vcTypeMandat
              and trdos.nocon = viNumeroMandat
              and trdos.nodos = ttComptabilisationReliquat.iNumDossier no-error.
        if not available trdos
        then do:
            mError:createError({&error}, 4000035).  /* Le dossier de destination est inexistant */
            return.
        end.
        /* Est-il cloturé ? */
        if trdos.dtree <> ?
        then do:
            mError:createError({&error}, 4000036).  /* Le dossier de destination est clôturé */
            return.
        end.
    end.

end procedure.
