/*-----------------------------------------------------------------------------
File        : extractionAssurance.p
Purpose     : Recherche des donnees de fusion assurance
Author(s)   : RF - 2008/04/18, Kantena - 2018/01/25
Notes       : appelé par extract.p, Suite à refonte extract.p et fiche 0108/0233

01  27/08/2010  NP    0810/0096: Modif ds fctexpor.i
02  24/09/2012  PL    0912/0107: pb valorisation VilleCedexCourtier
03  24/05/2013  PL    0513/0127: bidouille en passant par assigneparametre pour être sur le bon contrat assurance si on vient de la fiche assurance.
04  05/08/2013  NP    0713/0097: add new champs de fusion
05  11/01/2016  PL    0711/0069: Normalisation adresses sur 6 lignes
06  25/01/2016  PL    0711/0069: Normalisation adresses sur 6 lignes
-----------------------------------------------------------------------------*/
{preprocesseur/famille2tiers.i}
{preprocesseur/type2bien.i}
{preprocesseur/type2contrat.i}
{preprocesseur/nature2contrat.i}
{preprocesseur/type2role.i}
{preprocesseur/type2tache.i}
{preprocesseur/fusion/fusionAssurance.i}
{preprocesseur/listeRubQuit2TVA.i}

using bureautique.fusion.classe.fusionAssurance.
using bureautique.fusion.classe.fusionAdresse.
using bureautique.fusion.classe.fusionRole.
using bureautique.fusion.classe.fusionQuittance.
using bureautique.fusion.classe.fusionBanque.

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */
{application/include/glbsepar.i} 
{bureautique/fusion/include/fctexport.i}

procedure extractionAssurance:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes: service utilisé par extraction.p
    ------------------------------------------------------------------------------*/
    define input        parameter piNumeroSyndic    as integer   no-undo.
    define input        parameter piNumeroDocument  as integer   no-undo.
    define input        parameter piNumeroMandat    as integer   no-undo.
    define input        parameter pcListeChamp      as character no-undo.
    define input-output parameter poFusionAssurance as class fusionAssurance no-undo.

    define variable viNumeroContrat as integer   no-undo.
    define variable vcTmp           as character no-undo.
    define variable viCompteur      as integer   no-undo.
    define variable viBoucle        as integer   no-undo.
    define variable vlBloc1         as logical   no-undo.
    define variable voAdresse       as class fusionAdresse no-undo.
    define variable voRole          as class fusionRole    no-undo.

    define buffer ctctt for ctctt.
    define buffer ctrat for ctrat.
    define buffer intnt for intnt.
    define buffer assat for assat.
    define buffer tache for tache.

boucleChamp:
    do viCompteur = 1 to num-entries(pcListeChamp):
        case entry(viCompteur, pcListeChamp):
            when {&FUSION-TitreCompagnie}                  or when {&FUSION-NomCompagnie}           or when {&FUSION-adresseCompagnie}
         or when {&FUSION-SuiteadresseCompagnie}           or when {&FUSION-VilleCompagnie}         or when {&FUSION-CodePostalCompagnie}
         or when {&FUSION-NumPoliceassurance}              or when {&FUSION-DateDbtassurance}       or when {&FUSION-DateFinassurance}
         or when {&FUSION-TitreCourtier}                   or when {&FUSION-NomCourtier}            or when {&FUSION-adresseCourtier}
         or when {&FUSION-SuiteadresseCourtier}            or when {&FUSION-VilleCourtier}          or when {&FUSION-CodePostalCourtier}
         or when {&FUSION-DatelDbtassurance}               or when {&FUSION-DateDbtassuranceLettre} or when {&FUSION-DatelFinassurance}
         or when {&FUSION-DateFinassuranceLettre}          or when {&FUSION-DateSigassurance}       or when {&FUSION-DateLSigassurance}
         or when {&FUSION-DateSigassuranceenLettre}        or when {&FUSION-DateIniassurance}       or when {&FUSION-DateLIniassurance} 
         or when {&FUSION-DateIniassuranceenLettre}        or when {&FUSION-VilleCedexCompagnie}    or when {&FUSION-VilleCedexCourtier}
         or when {&FUSION-EmailCompagnie}                  or when {&FUSION-TelephoneCompagnie}     or when {&FUSION-FaxCompagnie}
         or when {&FUSION-emailCourtier}                   or when {&FUSION-TelephoneCourtier}      or when {&FUSION-FaxCourtier}
         or when {&FUSION-ComplementAdresseIdentCompagnie} or when {&FUSION-ComplementAdresseIdentCourtier} then do:
                if vlBloc1 then next boucleChamp.

                vlBloc1 = true.
                /* Si numero de contrat assurance particulier */
                // vcTmp = DonneEtSupprimeParametre("EXTRACT-ASSURANCE-CONTRAT"). // todo THK comment gérer ces éléments ?
                if vcTmp > "" then viNumeroContrat = integer(entry(2, vcTmp, "|")).
                find last ctctt no-lock 
                    where ctctt.tpct1 = {&TYPECONTRAT-mandat2Gerance}
                      and ctctt.noct1 = piNumeroMandat
                      and ctctt.tpct2 = {&TYPECONTRAT-assuranceGerance} 
                      and (viNumeroContrat = 0 or ctctt.noct2 = viNumeroContrat) no-error.
                if not available ctctt
                then find last ctctt no-lock 
                    where ctctt.tpct1 = {&TYPECONTRAT-mandat2Syndic}
                      and ctctt.noct1 = piNumeroSyndic
                      and ctctt.tpct2 = {&TYPECONTRAT-assuranceSyndic} 
                      and (viNumeroContrat = 0 or ctctt.noct2 = viNumeroContrat) no-error.
                if available ctctt
                then for first ctrat no-lock
                    where ctrat.tpcon = ctctt.tpct2
                      and ctrat.nocon = ctctt.noct2:
                    /* Numero de police */
                    assign
                        poFusionAssurance:NumPoliceAssurance = ctrat.noree
                        voRole                               = chargeRole(ctrat.tprol, ctrat.norol, piNumeroDocument)
                        poFusionAssurance:TitreCompagnie     = voRole:titre
                        poFusionAssurance:NomCompagnie       = voRole:nom
                    .
                    assign
                        voAdresse = chargeAdresse(ctrat.tprol, ctrat.norol, piNumeroDocument)
                        poFusionAssurance:AdresseCompagnie                = voAdresse:Adresse
                        poFusionAssurance:SuiteAdresseCompagnie           = voAdresse:complementVoie
                        poFusionAssurance:CodePostalCompagnie             = voAdresse:codePostal
                        poFusionAssurance:VilleCompagnie                  = voAdresse:villeSansCedex()
                        poFusionAssurance:VilleCedexCompagnie             = voAdresse:ville
                        poFusionAssurance:EmailCompagnie                  = voAdresse:Mail 
                        poFusionAssurance:TelephoneCompagnie              = voAdresse:Telephone
                        poFusionAssurance:FaxCompagnie                    = voAdresse:Fax
                        poFusionAssurance:ComplementAdresseIdentCompagnie = voAdresse:IdentAdresse
                    .
                    /* Information sur le courtier */
                    for first intnt no-lock
                        where intnt.tpcon = ctrat.tpcon
                          and intnt.nocon = ctrat.nocon
                          and intnt.tpidt = {&TYPEROLE-courtier}:
                        assign
                            voRole                          = chargeRole(intnt.tpidt, intnt.noidt, piNumeroDocument)
                            poFusionAssurance:TitreCourtier = voRole:Titre
                            poFusionAssurance:NomCourtier   = voRole:Nom
                        .
                        assign
                            voAdresse = chargeAdresse(intnt.tpidt, intnt.noidt, piNumeroDocument)
                            poFusionAssurance:AdresseCourtier                = voAdresse:Adresse
                            poFusionAssurance:SuiteAdresseCourtier           = voAdresse:complementVoie
                            poFusionAssurance:CodePostalCourtier             = voAdresse:codePostal
                            poFusionAssurance:VilleCourtier                  = voAdresse:VilleSansCedex()
                            poFusionAssurance:VilleCedexCourtier             = voAdresse:Ville
                            poFusionAssurance:EmailCourtier                  = voAdresse:Mail 
                            poFusionAssurance:TelephoneCourtier              = voAdresse:Telephone
                            poFusionAssurance:FaxCourtier                    = voAdresse:Fax
                            poFusionAssurance:ComplementAdresseIdentCourtier = voAdresse:IdentAdresse
                        .
                    end.
                    /* Detail sur la tache attestation */
                    for first assat no-lock
                         where assat.tpcon = ctrat.tpcon
                           and assat.nocon = ctrat.nocon
                           and assat.tptac = {&TYPETACHE-AttestationAssurance}
                           and assat.noatt = 1:
                        assign
                            poFusionAssurance:DateDbtAssurance         = dateToCharacter(assat.dtdeb)
                            poFusionAssurance:DateLDbtAssurance        = outilFormatage:getDateFormat(assat.dtdeb, "L")
                            poFusionAssurance:DateDbtAssuranceLettre   = outilFormatage:getDateFormat(assat.dtdeb, "LL")
                            poFusionAssurance:DateFinAssurance         = dateToCharacter(assat.dtfin)
                            poFusionAssurance:DateLFinAssurance        = outilFormatage:getDateFormat(assat.dtfin, "L")
                            poFusionAssurance:DateFinAssuranceLettre   = outilFormatage:getDateFormat(assat.dtfin, "LL")
                            poFusionAssurance:DateSigAssurance         = dateToCharacter(ctrat.dtsig)
                            poFusionAssurance:DateLSigAssurance        = outilFormatage:getDateFormat(ctrat.dtsig, "L")
                            poFusionAssurance:DateSigAssuranceenLettre = outilFormatage:getDateFormat(ctrat.dtsig, "LL")
                            poFusionAssurance:DateSigAssurance         = dateToCharacter(ctrat.dtini)
                            poFusionAssurance:DateLSigAssurance        = outilFormatage:getDateFormat(ctrat.dtini, "L")
                            poFusionAssurance:DateSigAssuranceenLettre = outilFormatage:getDateFormat(ctrat.dtini, "LL")
                        .
                    end.
                    /* RF - 18/04/08 - 0108/0233 */
                end.
            end.
            when {&FUSION-LstGarassurance} then do:
                find last ctctt no-lock 
                    where ctctt.tpct1 = {&TYPECONTRAT-mandat2Gerance}
                      and ctctt.noct1 = piNumeroMandat
                      and ctctt.tpct2 = {&TYPECONTRAT-assuranceGerance} no-error.
                if not available ctctt 
                then find last ctctt no-lock
                    where ctctt.tpct1 = {&TYPECONTRAT-mandat2Syndic}
                      and ctctt.noct1 = piNumeroSyndic
                      and ctctt.tpct2 = {&TYPECONTRAT-assuranceSyndic} no-error.
                if available ctctt 
                then do:
                    find first tache no-lock
                         where tache.tpcon = ctctt.tpct2
                           and tache.nocon = ctctt.noct2
                           and tache.tptac = {&TYPETACHE-GarantieAssurance}
                           and tache.notac = 1 no-error.
                    if available tache 
                    then do viBoucle = 1 to num-entries(tache.lbdiv, "@"):
                        poFusionAssurance:LstGarAssurance = if poFusionAssurance:LstGarAssurance > ""
                                                            then poFusionAssurance:LstGarAssurance + chr(10) + outilTraduction:getLibelleProg("O_GTI", entry(viBoucle, tache.lbdiv, "@"))
                                                            else outilTraduction:getLibelleProg("O_GTI", entry(viBoucle, tache.lbdiv, "@")).
                    end.
                end.
            end.
        end case.
        if poFusionAssurance:LstGarAssurance = "" then poFusionAssurance:LstGarAssurance = outilTraduction:getLibelle(104783).
    end.
    delete object voAdresse no-error.
    delete object voRole    no-error.

end procedure.
