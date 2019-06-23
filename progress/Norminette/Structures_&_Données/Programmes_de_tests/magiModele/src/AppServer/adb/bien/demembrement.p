/*-----------------------------------------------------------------------------
File        : demembrement.p
Purpose     : reconstitution rattachement lots selon demembrements roles usufruitier/co-usufruitier/nuprop/co-nuprop
Author(s)   : DMI 20181023
Notes       : à partir de adb/src/bien/ratlot00.p
------------------------------------------------------------------------------*/
{preprocesseur/type2contrat.i}
{preprocesseur/type2bien.i}
{preprocesseur/type2role.i}

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{adb/include/demembrement.i &nomtable=ttUsufruitier &serialName=ttUsufruitier}
{adb/include/demembrement.i &nomtable=ttNuProprietaire &serialName=ttNuProprietaire}

procedure getRattachementLot:
    /*------------------------------------------------------------------------------
    Purpose: reconstitution rattachement lots selon demembrements
    Notes  : à partir de chgtabtmp de ratlo00.p - service appelé par convocAG.p
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroImmeuble as integer no-undo.
    define input parameter plSansDateFin    as logical no-undo.
    define output parameter table for ttUsufruitier.
    define output parameter table for ttNuProprietaire.

    define variable vdaFinUsufruit       as date    no-undo.
    define variable vdaDebutContrat      as date    no-undo.
    define variable viNumeroDemembrement as integer no-undo.

    define buffer intnt    for intnt.
    define buffer ctrat    for ctrat.
    define buffer local    for local.
    define buffer ctctt    for ctctt.
    define buffer vbintnt  for intnt.
    define buffer vb2intnt for intnt.
    define buffer vbctrat  for ctrat.

    define buffer vbttNuProprietaire for ttNuProprietaire.
    define buffer vbttUsufruitier    for ttUsufruitier.

    empty temp-table ttUsufruitier.
    empty temp-table ttNuProprietaire.

    for each intnt no-lock // Lots démembres de l'immeuble
        where intnt.tpcon =  {&TYPECONTRAT-UsufruitNuePropriete}
          and intnt.nocon >= ((piNumeroImmeuble * 10000) + 1)
          and intnt.nocon <= ((piNumeroImmeuble * 10000) + 9999)
          and intnt.TpIdt =  {&TYPEBIEN-lot}
       , first ctrat no-lock
         where ctrat.tpcon = intnt.tpcon
           and ctrat.Nocon = intnt.nocon
       , first local no-lock
         where local.noloc = intnt.noidt :
        assign
            viNumeroDemembrement = intnt.Nocon modulo 1000
            vdaDebutContrat      = ctrat.dtdeb
            vdaFinUsufruit       = ctrat.dtFin
        .
        for each vbintnt no-lock // Recherche usufruitier(s) d'origine
            where vbintnt.tpcon  = {&TYPECONTRAT-UsufruitNuePropriete}
              and vbintnt.Nocon  = intnt.Nocon
              and (vbintnt.TpIdt = {&TYPEROLE-usufruitier} or vbintnt.tpidt = {&TYPEROLE-coUsufruitier}):
            find ttUsufruitier
                where ttUsufruitier.iNumeroImmeuble = local.noimm
                  and ttUsufruitier.iNumeroLot      = local.nolot
                  and ttUsufruitier.daDebut         = ctrat.dtdeb
                  and ttUsufruitier.iNumeroRole     = vbintnt.noidt
                  no-error.
            if not available ttUsufruitier then do:
                create ttUsufruitier.
                assign
                    ttUsufruitier.iNumeroImmeuble     = local.noimm
                    ttUsufruitier.iNumeroLot          = local.nolot
                    ttUsufruitier.iNumeroDemembrement = viNumeroDemembrement
                    ttUsufruitier.cCodeTypeRole       = vbintnt.tpidt
                    ttUsufruitier.iNumeroRole         = vbintnt.noidt
                    ttUsufruitier.iNumerateur         = (if vbintnt.nbden = 0 then 100 else vbintnt.nbnum)
                    ttUsufruitier.iDenominateur       = (if vbintnt.nbden = 0 then 100 else vbintnt.nbden)
                    ttUsufruitier.daDebut             = ctrat.dtdeb
                    ttUsufruitier.daFin               = ctrat.dtfin
                    ttUsufruitier.cCodeTypeContrat    = ctrat.tpcon
                    ttUsufruitier.iNumeroContrat      = ctrat.nocon
                .
            end.
        end.
        for each vbintnt no-lock // Recherche nu-proprietaire(s) d'origine
            where vbintnt.tpcon = {&TYPECONTRAT-UsufruitNuePropriete}
              and vbintnt.Nocon = intnt.Nocon
              and (vbintnt.TpIdt = {&TYPEROLE-nuProprietaire} or vbintnt.tpidt = {&TYPEROLE-coNuProprietaire}) :
            find ttNuProprietaire
                where ttNuProprietaire.iNumeroImmeuble = local.noimm
                  and ttNuProprietaire.iNumeroLot      = local.nolot
                  and ttNuProprietaire.daDebut         = ctrat.dtdeb
                  and ttNuProprietaire.iNumeroRole     = vbintnt.noidt
                  no-error.
            if not available ttNuProprietaire then do:
                create ttNuProprietaire.
                assign
                    ttNuProprietaire.iNumeroImmeuble     = local.noimm
                    ttNuProprietaire.iNumeroLot          = local.nolot
                    ttNuProprietaire.iNumeroDemembrement = viNumeroDemembrement
                    ttNuProprietaire.cCodeTypeRole       = vbintnt.tpidt
                    ttNuProprietaire.iNumeroRole         = vbintnt.noidt
                    ttNuProprietaire.iNumerateur         = (if vbintnt.nbden = 0 then 100 else vbintnt.nbnum)
                    ttNuProprietaire.iDenominateur       = (if vbintnt.nbden = 0 then 100 else vbintnt.nbden)
                    ttNuProprietaire.daDebut             = ctrat.dtdeb
                    ttNuProprietaire.daFin               = ctrat.dtfin
                    ttNuProprietaire.cCodeTypeContrat    = ctrat.tpcon
                    ttNuProprietaire.iNumeroContrat      = ctrat.nocon
                .
            end.
        end.
        for each ctctt no-lock // Recherche si cession Usufruit ( 01076 )
            where ctctt.tpct1 = {&TYPECONTRAT-UsufruitNuePropriete}
              and ctctt.noct1 = intnt.Nocon
              and ctctt.tpct2 = {&TYPECONTRAT-CessionUsufruit}
          , first vb2intnt no-lock
            where vb2intnt.tpcon = ctctt.tpct2
              and vb2intnt.Nocon = ctctt.noct2
              and vb2intnt.TpIdt = {&TYPEBIEN-lot}
              and vb2intnt.noidt = local.noloc
          , first vbctrat no-lock
            where vbctrat.tpcon = vb2intnt.tpcon
              and vbctrat.Nocon = vb2intnt.nocon
              by vbctrat.dtdeb :
            for each vbttUsufruitier // maj date fin usufruitiers précédents
                where vbttUsufruitier.iNumeroImmeuble     = local.noimm
                  and vbttUsufruitier.iNumeroLot          = local.nolot
                  and vbttUsufruitier.iNumeroDemembrement = viNumeroDemembrement
                  and vbttUsufruitier.daDebut             = vdaDebutContrat:
                vbttUsufruitier.daFin = vbctrat.dtdeb - 1.
            end.
            vdaDebutContrat = vbctrat.dtdeb.
            for each vbintnt no-lock // recherche des nouveaux usufruitier(s)
                where vbintnt.tpcon = vbctrat.tpcon
                  and vbintnt.Nocon = vbctrat.nocon
                  and (vbintnt.TpIdt = {&TYPEROLE-usufruitier} or vbintnt.tpidt = {&TYPEROLE-coUsufruitier}):
                find ttUsufruitier
                    where ttUsufruitier.iNumeroImmeuble = local.noimm
                    and ttUsufruitier.iNumeroLot        = local.nolot
                    and ttUsufruitier.daDebut           = vbctrat.dtdeb
                    and ttUsufruitier.iNumeroRole       = vbintnt.noidt
                    no-lock no-error.
                if not available ttUsufruitier then do:
                    create ttUsufruitier.
                    assign
                        ttUsufruitier.iNumeroImmeuble     = local.noimm
                        ttUsufruitier.iNumeroLot          = local.nolot
                        ttUsufruitier.iNumeroDemembrement = viNumeroDemembrement
                        ttUsufruitier.cCodeTypeRole       = vbintnt.tpidt
                        ttUsufruitier.iNumeroRole         = vbintnt.noidt
                        ttUsufruitier.iNumerateur         = (if vbintnt.nbden = 0 then 100 else vbintnt.nbnum)
                        ttUsufruitier.iDenominateur       = (if vbintnt.nbden = 0 then 100 else vbintnt.nbden)
                        ttUsufruitier.daDebut             = vbctrat.dtdeb
                        ttUsufruitier.daFin               = vdaFinUsufruit
                        ttUsufruitier.cCodeTypeContrat    = vbctrat.tpcon
                        ttUsufruitier.iNumeroContrat      = vbctrat.nocon
                        .
                end.
            end.
        end.
        vdaDebutContrat = ctrat.dtdeb.
        for each ctctt no-lock // Recherche si cession Nu-propriete ( 01077 )
            where ctctt.tpct1 = {&TYPECONTRAT-UsufruitNuePropriete}
              and ctctt.noct1 = intnt.Nocon
              and ctctt.tpct2 = {&TYPECONTRAT-CessionNuePropriete}
          , first vb2intnt no-lock
            where vb2intnt.tpcon = ctctt.tpct2
              and vb2intnt.Nocon = ctctt.noct2
              and vb2intnt.TpIdt = {&TYPEBIEN-lot}
              and vb2intnt.noidt = local.noloc
          , first vbctrat no-lock
            where vbctrat.tpcon = vb2intnt.tpcon
              and vbctrat.Nocon = vb2intnt.nocon
               by vbctrat.dtdeb :
            for each vbttNuProprietaire // maj date fin Nu proprietaire précédents
                where vbttNuProprietaire.iNumeroImmeuble     = local.noimm
                  and vbttNuProprietaire.iNumeroLot          = local.nolot
                  and vbttNuProprietaire.iNumeroDemembrement = viNumeroDemembrement
                  and vbttNuProprietaire.daDebut             = vdaDebutContrat :
                vbttNuProprietaire.daFin = vbctrat.dtdeb - 1.
            end.
            vdaDebutContrat = vbctrat.dtdeb.
            for each vbintnt no-lock // recherche des nouveaux Nu proprietaire(s)
                where vbintnt.tpcon = vbctrat.tpcon
                  and vbintnt.Nocon = vbctrat.nocon
                  and (vbintnt.TpIdt = {&TYPEROLE-nuProprietaire} or vbintnt.tpidt = {&TYPEROLE-coNuProprietaire}) :
                find ttNuProprietaire
                  where ttNuProprietaire.iNumeroImmeuble = local.noimm
                    and ttNuProprietaire.iNumeroLot = local.nolot
                    and ttNuProprietaire.daDebut = vbctrat.dtdeb
                    and ttNuProprietaire.iNumeroRole = vbintnt.noidt
                    no-lock no-error.
                if not available ttNuProprietaire then do:
                    create ttNuProprietaire.
                    assign
                        ttNuProprietaire.iNumeroImmeuble     = local.noimm
                        ttNuProprietaire.iNumeroLot          = local.nolot
                        ttNuProprietaire.iNumeroDemembrement = viNumeroDemembrement
                        ttNuProprietaire.cCodeTypeRole       = vbintnt.tpidt
                        ttNuProprietaire.iNumeroRole         = vbintnt.noidt
                        ttNuProprietaire.iNumerateur         = (if vbintnt.nbden = 0 then 100 else vbintnt.nbnum)
                        ttNuProprietaire.iDenominateur       = (if vbintnt.nbden = 0 then 100 else vbintnt.nbden)
                        ttNuProprietaire.daDebut             = vbctrat.dtdeb
                        ttNuProprietaire.daFin               = vdaFinUsufruit
                        ttNuProprietaire.cCodeTypeContrat    = vbctrat.tpcon
                        ttNuProprietaire.iNumeroContrat      = vbctrat.nocon
                    .
                end.
            end.
        end.
        vdaDebutContrat = ctrat.dtdeb. // Recherche si Extinction d'usufruit ( 01079 )
        for each ctctt no-lock
            where ctctt.tpct1 = {&TYPECONTRAT-UsufruitNuePropriete}
              and ctctt.noct1 = intnt.Nocon
              and ctctt.tpct2 = {&TYPECONTRAT-ExtinctionUsufruit}
          , first vb2intnt no-lock
             where vb2intnt.tpcon = ctctt.tpct2
              and vb2intnt.Nocon = ctctt.noct2
              and vb2intnt.TpIdt = {&TYPEBIEN-lot}
              and vb2intnt.noidt = local.noloc
          , first vbctrat no-lock
            where vbctrat.tpcon = vb2intnt.tpcon
              and vbctrat.Nocon = vb2intnt.nocon
               by vbctrat.dtdeb:
            for each vbttUsufruitier  // Maj date de fin des derniers intervenants
                where vbttUsufruitier.iNumeroImmeuble     = local.noimm
                  and vbttUsufruitier.iNumeroLot          = local.nolot
                  and vbttUsufruitier.iNumeroDemembrement = viNumeroDemembrement
                  and (vbttUsufruitier.daFin = ? or vbttUsufruitier.daFin = vdaFinUsufruit):
                vbttUsufruitier.daFin = vbctrat.dtdeb.
            end.
            for each vbttNuProprietaire
                where vbttNuProprietaire.iNumeroImmeuble     = local.noimm
                  and vbttNuProprietaire.iNumeroLot          = local.nolot
                  and vbttNuProprietaire.iNumeroDemembrement = viNumeroDemembrement
                  and (vbttNuProprietaire.daFin = ? or vbttNuProprietaire.daFin = vdaFinUsufruit):
                vbttNuProprietaire.daFin = vbctrat.dtdeb.
            end.
        end.
    end.
    if plSansDateFin then do :
        for each ttNuProprietaire where ttNuProprietaire.daFin <>  ? :
            delete ttNuProprietaire.
        end.
        for each ttUsufruitier where ttUsufruitier.daFin <>  ? :
            delete ttUsufruitier.
        end.
    end.
end procedure.
