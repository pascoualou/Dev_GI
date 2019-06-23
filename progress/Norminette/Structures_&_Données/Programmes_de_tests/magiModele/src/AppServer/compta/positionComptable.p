/*------------------------------------------------------------------------
File        : positionComptable.p
Purpose     :
Author(s)   : RFA - 2018/03/09
Notes       :
derniere revue: 2018/03/23 - phm
----------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */
{preprocesseur/nature2contrat.i}
{preprocesseur/type2contrat.i}
{preprocesseur/type2role.i}
{compta/include/positionComptable.i}

procedure getPositionComptable:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes: service utilisé par beConsultationCompte.cls
    ------------------------------------------------------------------------------*/
    define input  parameter poCollection as class collection no-undo.
    define output parameter table for ttPositionComptable.

    empty temp-table ttPositionComptable.

    message "decodage de poCollection: "
        poCollection:getInteger  ('iNumeroSociete') ", "
        poCollection:getCharacter('cTypeContrat')   ", "
        poCollection:getInt64    ('iNumeroContrat') ", "
        poCollection:getDate     ('daDatePosition') ", ".

    case poCollection:getCharacter('cTypeContrat'):
        when {&TYPECONTRAT-mandat2Gerance} then run positionMandatGerance(
            poCollection:getInteger('iNumeroSociete'),
            poCollection:getInt64  ('iNumeroContrat'),
            poCollection:getDate   ('daDatePosition')
        ).
        when {&TYPECONTRAT-bail} then run positionBail(
            poCollection:getInteger('iNumeroSociete'),
            poCollection:getInt64  ('iNumeroContrat'),
            poCollection:getDate   ('daDatePosition')
        ).
    end case.

end procedure.

procedure positionMandatGerance private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroSociete as integer no-undo.
    define input parameter piNumeroContrat as int64   no-undo.
    define input parameter pdaDatePosition as date    no-undo.

    define variable vcParamEnt as character no-undo.
    define variable vcParamSor as character no-undo.

    define buffer vbIntnt for intnt.
    define buffer intnt   for intnt.
    define buffer ctrat   for ctrat.

    message "entree de positionMandatGerance"
    piNumeroSociete
    piNumeroContrat
    pdaDatePosition
    .

    // 1 - Mandat
    vcParamEnt = substitute("&1|&2|4110|00000||&3|||", piNumeroSociete, piNumeroContrat, string(pdaDatePosition, "99/99/9999")).
    run compta/souspgm/solcpt.p(vcParamEnt, output vcParamSor).
    create ttPositionComptable.
    assign
      //ttPositionComptable.iNumeroSociete   = piNumeroSociete
      //ttPositionComptable.iNumeroMandat    = piNumeroContrat
      //ttPositionComptable.cCollectif       = "M"
      //ttPositionComptable.cCompte          = "00000"
        ttPositionComptable.cLibellePosition = outilTraduction:getLibelle(104527)
        ttPositionComptable.dSolde           = decimal(entry(1, vcParamSor, "|")) / 100
    .
    for first intnt no-lock
        where intnt.tpcon = {&TYPECONTRAT-mandat2Gerance}
          and intnt.nocon = piNumeroContrat
          and intnt.tpidt = {&TYPEROLE-mandant}
      , first ctrat no-lock
        where ctrat.tpcon = {&TYPECONTRAT-mandat2Gerance}
          and ctrat.nocon = piNumeroContrat:
        // 2 - Propriétaire
        vcParamEnt = substitute("&1|&2|4111|&3||&4|||",
                                piNumeroSociete, piNumeroContrat, string(intnt.noidt, "99999"), string(pdaDatePosition, "99/99/9999")).
        run compta/souspgm/solcpt.p(vcParamEnt, output vcParamSor).
        create ttPositionComptable.
        assign
          //ttPositionComptable.iNumeroSociete   = piNumeroSociete
          //ttPositionComptable.iNumeroMandat    = piNumeroContrat
          //ttPositionComptable.cCollectif       = "P"
          //ttPositionComptable.cCompte          = string(intnt.noidt,"99999")
            ttPositionComptable.cLibellePosition = outilTraduction:getLibelle(104528) + " " + ctrat.lbnom
            ttPositionComptable.dSolde           = decimal(entry(1, vcParamSor, "|")) / 100
        .
       // 3 - Indivisaire (le cas échéant)
       if ctrat.ntcon = {&NATURECONTRAT-mandatAvecIndivision}
       or ctrat.ntcon = {&NATURECONTRAT-mandatLocationIndivision}
       then for each vbIntnt no-lock
          where vbIntnt.tpcon = ctrat.tpcon
            and vbIntnt.nocon = ctrat.nocon
            and vbIntnt.tpidt = "00016"
            and vbIntnt.noidt <> intnt.noidt:
           vcParamEnt = substitute("&1|&2|4111|&3||&4|||",
                                   piNumeroSociete, piNumeroContrat, string(vbIntnt.noidt,"99999"), string(pdaDatePosition, "99/99/9999")).
           run compta/souspgm/solcpt.p(vcParamEnt, output vcParamSor).
           create ttPositionComptable.
           assign
             //ttPositionComptable.iNumeroSociete   = piNumeroSociete
             //ttPositionComptable.iNumeroMandat    = piNumeroContrat
             //ttPositionComptable.cCollectif       = "P"
             //ttPositionComptable.cCompte          = string(bintnt.noidt,"99999")
               ttPositionComptable.cLibellePosition = outilTraduction:getLibelle(104528) + " " + outilFormatage:getNomTiers(vbIntnt.tpidt, vbIntnt.noidt)
               ttPositionComptable.dSolde           = decimal(entry(1, vcParamSor, "|")) / 100
           .
        end.
    end.

end procedure.

procedure positionBail private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroSociete as integer no-undo.
    define input parameter piNumeroContrat as int64   no-undo.
    define input parameter pdaDatePosition as date    no-undo.

    define variable vcParamEnt        as character no-undo.
    define variable vcParamSor        as character no-undo.
    define variable vcListeCodeColl   as character no-undo initial "L,LC,LF,LGLI,LA,LDG,LDGR,LCAU,LDGRC,LBIP,LDGRB".
    define variable vcListeCompteColl as character no-undo initial "4112,4161,4118,4119,4116,2751,2752,2755,2758,2754,2756".
    define variable vcListeLibColl    as character no-undo.
    define variable viIndice          as integer   no-undo.

    vcListeLibColl = substitute("&1,&2,Fact. honoraires locataire,Locataire Gtie Loyers Impayé,Locataire Avance,&3,&4,&5,&6,&7,&8",
                                outilTraduction:getLibelle(104530),
                                outilTraduction:getLibelle(104531),
                                outilTraduction:getLibelle(104532),
                                outilTraduction:getLibelle(104533),
                                outilTraduction:getLibelle(105140),
                                outilTraduction:getLibelle(105141),
                                outilTraduction:getLibelle(105142),
                                outilTraduction:getLibelle(105143)).
boucleCollectif:
    do viIndice = 1 to num-entries(vcListeCodeColl):
        if entry(viIndice, vcListeCompteColl) = "4119"
        and not can-find(first aparm no-lock
                         where aparm.tppar = "PRMGLI"
                           and aparm.cdpar = "00"
                           and aparm.zone2 = "OUI") then next boucleCollectif.

        vcParamEnt = substitute("&1|&2|&3|&4||&5|||"
                              , piNumeroSociete
                              , truncate(piNumeroContrat / 100000,0)
                              , entry(viIndice,vcListeCompteColl)
                              , string(piNumeroContrat modulo 100000,"99999")
                              , string(pdaDatePosition, "99/99/9999")).
        run compta/souspgm/solcpt.p (vcParamEnt, output vcParamSor).
        create ttPositionComptable.
        assign
          //ttPositionComptable.iNumeroSociete   = piNumeroSociete
          //ttPositionComptable.iNumeroMandat    = truncate(piNumeroContrat / 100000,0)
          //ttPositionComptable.cCollectif       = entry(viIndice,vcListeCodeColl)
          //ttPositionComptable.cCompte          = string(piNumeroContrat mod 100000,"99999")
            ttPositionComptable.cLibellePosition = entry(viIndice,vcListeLibColl)
            ttPositionComptable.dSolde           = decimal(entry(1, vcParamSor, "|")) / 100
            .
    end.

end procedure.
