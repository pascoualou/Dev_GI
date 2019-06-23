/*------------------------------------------------------------------------
File        : libelleRubQuitt.i
Purpose     : Récupération du libellé d'une rubrique de quittancement
Author(s)   : SPo - 2018/01/30 
Notes       : à partir de comm/LibRubQt.i procédure RecLibRub & comm/LibRubQ2.i fonction LibRubQt
------------------------------------------------------------------------*/
{preprocesseur/type2role.i}

function f_librubqt returns character
    (piRubrique as integer, piLibelle as integer, piRole as int64, piMois as integer, piNoQtt as integer, piNumIntFac as integer, pinoreference as integer):
    /*---------------------------------------------------------------------------
    Purpose : Récupération du libellé d'une rubrique de quittancement en tenant compte
              du libellé spécial locataire/mois (prrub)
              ou du libellé Cabinet (prrub)
              ou du libellé stocké dans l'historique de quittancement (aquit / noqtt)
              ou du libellés saisis dans une facture locataire en compta (iftsai)
              sinon libellé GI (rubqt)
    Notes   : repris de adb/comm/rclibrub.i  procédure RecLibRub
              utilisé dans prrubcal.i
    ---------------------------------------------------------------------------*/
    define variable vcListeRubHisto  as character no-undo.
    define variable viBoucle         as integer   no-undo.
    define variable vcLibelleStocke  as character no-undo.
    
    define buffer prrub for prrub.
    define buffer rubqt for rubqt.
    define buffer aquit for aquit.
    define buffer iftsai for iftsai.
    define buffer iftln for iftln.

    /* On prend en priorité le libellé stocké dans la quittance lors de l'historisation de l'AE */
    if piRole > 0 and piNoQtt > 0
    then for first aquit no-lock
        where aquit.noloc = piRole
          and aquit.noqtt = piNoQtt:
balayageRubriques:
        do viBoucle = 1 to 20:
            vcListeRubHisto = aquit.tbrub[viBoucle].
            if num-entries(vcListeRubHisto, "|") < 14
            or integer(entry(1, vcListeRubHisto, "|")) <> piRubrique
            or integer(entry(2, vcListeRubHisto, "|")) <> piLibelle then next balayageRubriques.

            vcLibelleStocke = trim(entry(14, vcListeRubHisto, "|")).
            if vcLibelleStocke > "" then return vcLibelleStocke.  
        end.
    end.
    if piRole > 0 and piNumIntFac > 0 and pinoreference > 0
    then for first iftsai no-lock
        where iftsai.soc-cd    = pinoreference
          and iftsai.etab-cd   = integer(truncate(piRole / 100000, 0))
          and iftsai.tprole    = integer({&TYPEROLE-locataire})
          and iftsai.sscptg-cd = string(piRole modulo 100000, "99999")
          and iftsai.num-int   = piNumIntFac
      , first iftln no-lock
        where iftln.soc-cd    = iftsai.soc-cd
          and iftln.etab-cd   = iftsai.etab-cd
          and iftln.tprole    = iftsai.tprole
          and iftln.sscptg-cd = iftsai.sscptg-cd
          and iftln.num-int   = iftsai.num-int
          and iftln.typecr-cd = "1"
          and iftln.brwcoll1  = string(piRubrique, "999")
          and integer(iftln.brwcoll2) = piLibelle:
        return iftln.lib-ecr[1].
    end.

    // Récuperation du libelle client de la rubrique.
    // On cherche s'il existe un parametrage pour le locataire puis pour le cabinet. 
    // Libellé specifique locataire/Mois 
    find first prrub no-lock
        where prrub.CdRub = piRubrique
          and prrub.CdLib = piLibelle
          and prrub.NoLoc = piRole
          and prrub.MsQtt = piMois
          and prrub.MsQtt <> 0 no-error.
    if not available prrub
    then find first prrub no-lock        /* Libellé Cabinet */
        where prrub.CdRub = piRubrique
          and prrub.CdLib = piLibelle
          and prrub.NoLoc = 0
          and prrub.MsQtt = 0
          and prrub.LbRub <> "" no-error.
    if available prrub then return prrub.LbRub.
    /* Récupération du no du libellé GI de la rubrique */
    for first rubqt no-lock
        where rubqt.cdrub = piRubrique
          and rubqt.cdlib = piLibelle:
        return outilTraduction:getLibelle(rubqt.nome1).
    end.
    return "".
end function.

procedure recupLibelleDefautRubrique private:
    /*------------------------------------------------------------------------
    Purpose : fonction de récupération du libellé par défaut d'une rubrique
    Notes   :
    ------------------------------------------------------------------------*/
    define input parameter  piNumeroRubrique  as integer   no-undo.
    define input parameter  pcNatureContrat   as character no-undo.
    define output parameter piNumeroLibelle   as integer   no-undo.
    define output parameter pcLibelleRubrique as character no-undo.

    define buffer bxrbp for bxrbp.
    define buffer rubqt for rubqt.

    for first bxrbp no-lock
        where bxrbp.norub = piNumeroRubrique
          and bxrbp.noord = -1
          and bxrbp.ntbai = pcNatureContrat:
        piNumeroLibelle = bxrbp.nolib.
        if piNumeroLibelle = 0 then piNumeroLibelle = 1.

        // Recuperation du no du libelle de la rubrique
        for first rubqt no-lock
            where rubqt.cdrub = piNumeroRubrique
              and rubqt.cdlib = piNumeroLibelle:
            pcLibelleRubrique = outilTraduction:getLibelle(rubqt.nome1).
        end.  
    end.

end procedure.
