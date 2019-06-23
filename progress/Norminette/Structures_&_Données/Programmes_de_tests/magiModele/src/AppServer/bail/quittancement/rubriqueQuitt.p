/*------------------------------------------------------------------------
File        : rubriqueQuitt.p
Purpose     : 
Author(s)   :  kantena  -  2017/11/14 
Notes       :
------------------------------------------------------------------------*/
{preprocesseur/referenceClient.i}
using parametre.pclie.pclie.
using parametre.pclie.parametrageHonoraireLocation.
{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{bail/include/rubriqueQuitt.i &NomTable=ttRubriqueQuitt}
{bail/include/rubriqueQuitt.i &NomTable=ttLibelleQuitt}

procedure getListeRubrique:
    /*------------------------------------------------------------------------------
    Purpose: Donne la liste des rubriques de quittancement
    Notes  : todo  procédure non utilisée ???? --  outilTraduction au lieu de sys_lb ???
    ------------------------------------------------------------------------------*/
    define output parameter table for ttRubriqueQuitt.

    define variable vcLbRubQt  as character no-undo.
    define buffer prrub  for prrub.
    define buffer sys_lb for sys_lb.

    for each prrub no-lock
       where prrub.noLoc = 0
         and prrub.cdLib = 0:
        if prrub.lbRub = ? or prrub.lbRub = "" then do:
            // Pas de libelle client => libelle GI
            find first sys_lb no-lock
                 where sys_lb.nomes = prrub.noMe1 
                   and (sys_lb.cdlng = mtoken:iCodeLangueSession or (mtoken:iCodeLangueSession = 100 and sys_lb.cdlng = 0)) no-error.
            vcLbRubQt = if available sys_lb then sys_lb.lbmes else "".
        end.
        else vcLbRubQt = prrub.LbRub.
        create ttRubriqueQuitt.
        assign
            ttRubriqueQuitt.iCodeRubrique     = prrub.CdRub
            ttRubriqueQuitt.iCodeLibelle      = prrub.CdLib
            ttRubriqueQuitt.cLibelleRubrique  = vcLbRubQt
            ttRubriqueQuitt.iNumeroLibelle    = prrub.Nome1
            ttRubriqueQuitt.iCodeFamille      = prrub.CdFam
            ttRubriqueQuitt.iCodeSousFamille  = prrub.CdSfa
            ttRubriqueQuitt.cCodeGenre        = prrub.CdGen
            ttRubriqueQuitt.cCodeSigne        = prrub.CdSig
            ttRubriqueQuitt.cCodeIRF          = prrub.CdIrf
            ttRubriqueQuitt.iNumeroLocataire  = prrub.NoLoc
            ttRubriqueQuitt.iMoisTraitementGI = prrub.MsQtt
            ttRubriqueQuitt.lAffiche          = (prrub.CdAff = "00000")
            ttRubriqueQuitt.cLibelleCabinet   = vcLbRubQt
            ttRubriqueQuitt.lModifiable       = false
        .
    end.
end procedure.

procedure getListeRubriqueAutorisee :
    /*------------------------------------------------------------------------------
    Purpose: Donne la liste des rubriques de quittancement autorisée, procedure frmlrb06.p
    Notes  : service appelé par paramBudgetLocatif.p
    ------------------------------------------------------------------------------*/
    define input parameter LsGenAut as character no-undo.
    define input parameter LsSigAut as character no-undo.
    define output parameter table for ttRubriqueQuitt.
    
    define variable voParametrageHonoraireLocation as class parametrageHonoraireLocation no-undo.
    define variable voPclie as class pclie no-undo.
        
    define buffer prrub  for prrub.
    define buffer rubqt  for rubqt.
    
    voParametrageHonoraireLocation = new parametrageHonoraireLocation().
    voPclie = new pclie().
    for each  prrub  no-lock
        where prrub.CdLib = 0
        and   prrub.CdAff = "00001" 
        use-index ix_prrub04
       ,first rubqt no-lock
        where rubqt.cdrub = prrub.cdrub
        and   rubqt.cdlib = prrub.cdlib :
            
      if LsGenAut <> "" then
          if lookup( prrub.cdgen ,LsGenAut ,':') = 0 then next.
      if LsSigAut <> "" then
          if lookup( prrub.cdsig ,LsSigAut,':') = 0 then next.
          
        
        if prrub.cdfam = 08 and voParametrageHonoraireLocation:auMoinsUnArticle(prrub.cdrub) = false then next.
        if voParametrageHonoraireLocation:isDbParameter then do:    
            if integer(mtoken:cRefPrincipale) = {&REFCLIENT-GIDEV} or integer(mtoken:cRefPrincipale) = {&REFCLIENT-GICLI} then do:
                if voParametrageHonoraireLocation:ancienneRubriqueInterdite(prrub.cdrub) then next.
            end.
            else do:
                voPclie:reload("RBEXT", string(prrub.cdrub , "999")). // Anciennes rubriques EXTOURNABLES interdites
                if voPclie:isDbParameter then next.  
            end.                                
        end.
        create ttRubriqueQuitt.
        assign
            ttRubriqueQuitt.iCodeRubrique    = prrub.CdRub
            ttRubriqueQuitt.cLibelleRubrique = outilTraduction:getLibelle(prrub.noMe1 )
        .
    end.    
    delete object voParametrageHonoraireLocation.
    delete object voPclie.
end procedure.

procedure getListeLibelleRubrique:
    /*------------------------------------------------------------------------------
    Purpose: Donne la liste des libellés poue le cabinet 
    Notes  : todo  procédure non utilisée ???? --  outilTraduction au lieu de sys_lb ???
    ------------------------------------------------------------------------------*/
    define output parameter table for ttLibelleQuitt.
    define variable vcLbRubQt  as character no-undo.
    define buffer prrub  for prrub.

    for each prrub no-lock
       where prrub.noLoc = 0
         and prrub.cdLib <> 0 
         and prrub.cdLib <> 99:
        create ttLibelleQuitt.
        assign
            vcLbRubQt                        = if prrub.lbRub = ? or prrub.lbRub = ""
                                               then outilTraduction:getLibelle(prrub.noMe1)
                                               else prrub.lbRub
            ttLibelleQuitt.iCodeRubrique     = prrub.CdRub
            ttLibelleQuitt.iCodeLibelle      = prrub.CdLib
            ttLibelleQuitt.cLibelleRubrique  = vcLbRubQt
            ttLibelleQuitt.iNumeroLibelle    = prrub.Nome1
            ttLibelleQuitt.iCodeFamille      = prrub.CdFam
            ttLibelleQuitt.iCodeSousFamille  = prrub.CdSfa
            ttLibelleQuitt.cCodeGenre        = prrub.CdGen
            ttLibelleQuitt.cCodeSigne        = prrub.CdSig
            ttLibelleQuitt.cCodeIRF          = prrub.CdIrf
            ttLibelleQuitt.iNumeroLocataire  = prrub.NoLoc
            ttLibelleQuitt.iMoisTraitementGI = prrub.MsQtt
            ttLibelleQuitt.lAffiche          = (prrub.CdAff = "00000")
            ttLibelleQuitt.cLibelleCabinet   = vcLbRubQt
            ttLibelleQuitt.lModifiable       = false
        .
    end.

end procedure.

function getLibelleRubrique returns character(piNumeroRubrique as integer, piNumeroLibelle as integer, piNumeroLoc as int64,
    piMoisQuittance as integer, pdaDateQuittance as date, piReferenceGerance as integer, piNumeroInterneFac as integer):
    /*------------------------------------------------------------------------------
    Purpose: Fonction qui récupère le libelle d'une rubrique 
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vcLibelleRub      as character no-undo.
    define variable viNumeroQuittance as integer   no-undo.
    define variable viBoucle          as integer   no-undo.
    define variable vcRubriques       as character no-undo.
    define variable vcLibelleStocke   as character no-undo.
    
    define buffer rubqt  for rubqt.
    define buffer iftsai for iftsai.
    define buffer iftln  for iftln.
    define buffer prrub  for prrub.
    define buffer equit  for equit.
    define buffer aquit  for aquit.

    /* On prend en priorité le libellé stocké dans la quittance lors de l'historisation de l'AE */
    for first aquit no-lock
         where aquit.noloc = piNumeroLoc
           and aquit.msqtt = piMoisQuittance:
        /* Balayage des rubriques */
boucle:
        do viBoucle = 1 to 20:
            vcRubriques = aquit.tbrub[viBoucle].
            /* Bonne rubrique/numéro libellé ??? */
            if num-entries(vcRubriques, "|") < 2
            or integer(entry(1, vcRubriques, "|")) <> piNumeroRubrique
            or integer(entry(2, vcRubriques, "|")) <> piNumeroLibelle  then next boucle.

            /* Libellé stocké ??? */
            if num-entries(vcRubriques, "|") >= 14 and entry(14, vcRubriques, "|") > ""
            then do:
                vcLibelleStocke = entry(14, vcRubriques, "|").
                leave boucle.
            end.
        end.
    end.
    if vcLibelleStocke > "" then return vcLibelleStocke. /* On a trouvé le libellé stocké dans la quittance */

    /* Il faut chercher le libellé comme avant le stockage dans la quittance */
    if piNumeroInterneFac <> 0
    then for first iftsai no-lock
        where iftsai.soc-cd    = piReferenceGerance
          and iftsai.etab-cd   = integer(truncate(piNumeroLoc / 100000, 0))
          and iftsai.tprole    = 19
          and iftsai.sscptg-cd = string(piNumeroLoc modulo 100000, "99999")
          and iftsai.num-int   = piNumeroInterneFac
      , first iftln no-lock
        where iftln.soc-cd   = iftsai.soc-cd
          and iftln.etab-cd  = iftsai.etab-cd
          and iftln.tprole   = iftsai.tprole
          and iftln.sscptg-cd= iftsai.sscptg-cd
          and iftln.num-int  = iftsai.num-int
          and iftln.typecr-cd = "1"
          and iftln.brwcoll1  = string(piNumeroRubrique , "999")
          and integer(iftln.brwcoll2) = piNumeroLibelle:
        vcLibelleRub = iftln.lib-ecr[1].
    end.
    else do:
        /* Recuperation du libelle client de la rubrique.
           On cherche s'il existe un parametrage pour le locataire puis pour le cabinet.*/
        if piMoisQuittance = 0 and pdaDateQuittance <> ? 
        then piMoisQuittance = integer(string(year(pdaDateQuittance), "9999") + string(month(pdaDateQuittance), "99")).
        /* recherche viNumeroQuittance avec buffer */
        find last equit no-lock
            where equit.noloc = piNumeroLoc
              and equit.msqtt = piMoisQuittance no-error.
        if not available equit
        then for last aquit no-lock
            where aquit.noloc = piNumeroLoc 
              and aquit.msqtt = piMoisQuittance
              and (aquit.type-fac = "" or aquit.type-fac = "E"):
            viNumeroQuittance = aquit.noqtt.
        end.
        else viNumeroQuittance = equit.noqtt.

        /* Libelle specifique locataire/Mois */
        for first prrub no-lock 
            where prrub.CdRub = piNumeroRubrique
              and prrub.CdLib = piNumeroLibelle
              and prrub.NoLoc = piNumeroLoc
              and prrub.MsQtt = piMoisQuittance
              and prrub.MsQtt <> 0
              and (prrub.noQtt = 0 or prrub.noQtt = viNumeroQuittance):
            vcLibelleRub = prrub.LbRub.
        end.
    end.
    if vcLibelleRub > "" then return vcLibelleRub.
    // Libelle Cabinet 
    for first prrub no-lock 
        where prrub.cdRub = piNumeroRubrique
          and prrub.cdLib = piNumeroLibelle
          and prrub.noLoc = 0
          and prrub.msQtt = 0
          and prrub.lbRub > "":
        return prrub.lbRub.
    end.
    // Recuperation du no du libelle de la rubrique ³
    for first rubqt no-lock
        where rubqt.cdrub = piNumeroRubrique
          and rubqt.cdlib = piNumeroLibelle:
        return outilTraduction:getLibelle(rubqt.nome1).
    end.   
    return "".

end function.