/*------------------------------------------------------------------------
File        : outilsTVA.p
Purpose     :
Author(s)   : kantena - 2017/02/01
Notes       :
----------------------------------------------------------------------*/
{preprocesseur/type2contrat.i}
{preprocesseur/type2tache.i}

using parametre.pclie.parametrageCodeTVA.

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */
{compta/include/tva.i}
{application/include/glbsepar.i}

function getTvaDefaut returns decimal:
    /* -------------------------------------------------------------------------
    Purpose: Recherche du taux de TVA par défaut (client)
    Notes  :
    -------------------------------------------------------------------------- */
    define variable voCodeTVA as class parametrageCodeTVA no-undo.
    define buffer sys_pr for sys_pr.

    voCodeTVA = new parametrageCodeTVA().
    if voCodeTVA:isDbParameter
    then for first sys_pr no-lock
        where sys_pr.tppar = "CDTVA"
          and sys_pr.cdpar = voCodeTVA:getCodeTVA():
        return sys_pr.zone1.
    end.
    return 0.
end function.

function getTauxTva returns decimal (picodeTva as integer):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par commercialisation.p, ordreDeService.p, ...
    ------------------------------------------------------------------------------*/
    define buffer itaxe for itaxe.

    for first itaxe no-lock
        where itaxe.soc-cd  = mToken:iCodeSociete
          and itaxe.taxe-cd = picodeTva:
        return if itaxe.taux <> 0 then itaxe.taux else 1.
    end.
    return getTvaDefaut().
end function.

function calculTVAdepuisHT returns decimal(piCodeTVA as integer, pdMontantHT as decimal):
    /*------------------------------------------------------------------------------
    purpose: retourne le montant de TVA calculé à partir du montant HT
    Notes  : service utilisé par appelDeFond.p, recapDossier.p, ...
    ------------------------------------------------------------------------------*/
    return round((pdMontantHT * getTauxTva(piCodeTVA)) / 100, 2).

end function.

function calculTVAdepuisTTC returns decimal(piCodeTVA as integer, pdMontantTTC as decimal):
    /*------------------------------------------------------------------------------
    purpose: retourne le montant de TVA calculé à partir du montant TTC
    Notes  :
    ------------------------------------------------------------------------------*/
    return pdMontantTTC - round(pdMontantTTC - (pdMontantTTC / (100 + getTauxTva(piCodeTVA)) * 100), 2).

end function.

function calculTTCdepuisHT returns decimal(piCodeTVA as integer, pdeMontantHT as decimal):
    /*------------------------------------------------------------------------------
    purpose: retourne le montant de TTC calculé à partir du montant HT et TVA
    Notes  : service utilisé par immeuble.p, intervention.p, ...
    ------------------------------------------------------------------------------*/
    define buffer itaxe for itaxe.

    return pdeMontantHT + round((pdeMontantHT * getTauxTva(piCodeTVA)) / 100, 2).

end function.

function getTauxTvaBail returns decimal (picompte as integer):
    /*------------------------------------------------------------------------------
    purpose:
    Notes  : service utilisé par extencqt.i
    ------------------------------------------------------------------------------*/
    define variable dTaux as decimal no-undo.
    define buffer tache for tache.
    define buffer itaxe for itaxe.
    define buffer sys_pr for sys_pr.

    find first itaxe no-lock
        where itaxe.soc-cd = mtoken:iCodeSociete
          and itaxe.port-emb = true no-error.
    if not available itaxe
    then find first itaxe no-lock
        where itaxe.soc-cd = mtoken:iCodeSociete
          and itaxe.taxe-cd = 5 no-error.
    if available itaxe then dTaux = itaxe.taux.

    for last tache no-lock
        where tache.tpcon = {&TYPECONTRAT-bail}
          and tache.nocon = piCompte
          and tache.tptac = {&TYPETACHE-TVABail}
      , first sys_pr no-lock
        where sys_pr.tppar = "CDTVA"
          and sys_pr.cdpar = tache.ntges:
        dTaux = sys_pr.zone1.
    end.
    return dTaux.
end function.

procedure getTVACompta:
    /* -------------------------------------------------------------------------
    Purpose: Chargement des taux de tva
    Notes  : service utilisé par beTVA.cls
    -------------------------------------------------------------------------- */
    define input parameter piCodeTVA as integer no-undo.
    define output parameter table for ttTva.

    /* TODO : créer un paramétrage client listant les codes tva à taux réduits */
    define variable vcListeCodeReduit as character no-undo initial "1,7,10".
    define variable vdTauxDefaut      as decimal   no-undo.

    define buffer itaxe for itaxe.
    define buffer iparm for iparm.

    empty temp-table ttTVA.
    if valid-object(mtoken)
    then do:
        vdTauxDefaut = getTvaDefaut().
        find first iparm no-lock
            where iparm.tppar   = "TVA"
              and iparm.soc-cd  = mToken:iCodeSociete
              and iparm.etab-cd = 0
              and iparm.cdpar   = "ACTIF" no-error.
        for each itaxe no-lock
            where itaxe.soc-cd = mToken:iCodeSociete
              and itaxe.type   = true
              and (itaxe.libass-cd = 1 or itaxe.libass-cd = 7)
              and (if piCodeTVA <> ? and piCodeTVA <> 0 then itaxe.taxe-cd = piCodeTVA else true):
            if not available iparm or lookup(string(itaxe.taxe-cd, "99"), iparm.zone2) > 0
            then do:
                create ttTVA.
                assign
                    ttTVA.iCodeTVA    = itaxe.taxe-cd
                    ttTVA.dTauxTVA    = itaxe.taux
                    ttTVA.cLibelleTVA = itaxe.lib
                    ttTVA.lDefaut     = (itaxe.taux = vdTauxDefaut)
                    ttTva.lReduit     = (lookup(string(itaxe.taxe-cd), vcListeCodeReduit) > 0)
                .
            end.
        end.
    end.
    else mError:createError({&error}, 'getTVA: No valid mtoken.').

end procedure.

procedure getCodeTVA:
    /* -------------------------------------------------------------------------
    Purpose: Chargement des codes de tva (selon sys_pr)
    Notes  : service utilisé par tache/baremeHonoraire.p 
             et service externe (beTVA.cls)
    -------------------------------------------------------------------------- */
    define output parameter table for ttTva.
    
    define variable vlOk            as logical   no-undo.
    define variable vcCodeTVADefaut as character no-undo.
    define variable voCodeTVA       as class     parametrageCodeTVA no-undo.
    define buffer iparm  for iparm.
    define buffer itaxe  for itaxe.
    define buffer sys_pr for sys_pr.
    assign
        voCodeTVA       = new parametrageCodeTVA()
        vcCodeTVADefaut = voCodeTVA:getCodeTVA()   // code TVA par défaut
        .
    delete object voCodeTVA.
    empty temp-table ttTVA.
    if valid-object(mtoken)
    then do:
        find first iparm no-lock
          where iparm.tppar   = "TVA"
            and iparm.soc-cd  = mToken:iCodeSociete
            and iparm.etab-cd = 0
            and iparm.cdpar   = "ACTIF" no-error.
boucle:
        for each sys_pr no-lock
            where sys_pr.tppar = "CDTVA"
            by sys_pr.zone1:
            vlok = false.
            if available iparm then for each itaxe no-lock
                where itaxe.soc-cd = mToken:iCodeSociete
                  and itaxe.taux   = sys_pr.zone1:
                if lookup(string(itaxe.taxe-cd, "99"), iparm.zone2) > 0
                then vlok = true.  
            end.  
            else vlok = true.
            if not vlOk then next boucle.

            create ttTVA.
            assign
                ttTVA.cCodeTVA    = sys_pr.cdpar
                ttTVA.cLibelleTVA = outilTraduction:getLibelle(sys_pr.nome1)
                ttTVA.dTauxTVA    = sys_pr.zone1
                ttTVA.lDefaut     = (sys_pr.cdpar = vcCodeTVADefaut)
            .
        end.
    end.
    else mError:createError({&error}, 'getTVA: No valid mtoken.').
end procedure.

procedure getRatioCleRepartion:
    /* -------------------------------------------------------------------------
    Purpose: Interface de renvoie du ratio d'une cle
             a partir de adb/cpta/chgclera.p
gga todo peut etre plus logique si procedure dans tache tva ???? voir sylvie             
    Notes  : service externe
    -------------------------------------------------------------------------- */
    define input  parameter piNumeroMandat as integer no-undo.
    define input  parameter piAnnee        as integer no-undo.
    define output parameter piNumerateur   as integer no-undo.
    define output parameter piDenominateur as integer no-undo.

    define variable viI as integer no-undo.

    define buffer tache for tache.
    
    find first tache no-lock
         where tache.tpcon = {&TYPECONTRAT-mandat2Gerance}
           and tache.nocon = piNumeroMandat
           and tache.tptac = {&TYPETACHE-TVA} no-error.
    if available tache 
    then do:
        /*Nouveau stockage du prorata*/
        if piAnnee <> ? and num-entries(tache.lbdiv2, separ[1]) > 2 
        then do:
            do viI = 1 to num-entries(tache.lbdiv2, separ[2]):
                if piAnnee >= integer(entry(1, entry(viI, tache.lbdiv2, separ[2]), separ[1])) 
                then piNumerateur = integer(entry(2, entry(viI, tache.lbdiv2, separ[2]), separ[1])).
            end.
            piDenominateur = 100.
        end.
        /*Ancien stockage du prorata*/
        else assign
                 piNumerateur   = integer(entry(1, tache.lbdiv, "#"))
                 piDenominateur = integer(entry(2, tache.lbdiv, "#"))
        .
    end.
    else assign
             piNumerateur   = 100
             piDenominateur = 100
    .

end procedure.
