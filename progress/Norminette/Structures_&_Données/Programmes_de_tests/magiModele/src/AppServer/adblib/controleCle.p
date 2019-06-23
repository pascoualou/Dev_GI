/*------------------------------------------------------------------------
File        : controleCle.p 
Purpose     : Module de controle de l'utilisation d'une cl� afin d'autoriser ou non sa suppression  
Author(s)   : DMI 20180214
Notes       : � partir de ctrcle00.p
derniere revue: 2018/03/21 - phm
------------------------------------------------------------------------*/
{preprocesseur/type2tache.i}
{preprocesseur/type2contrat.i}
{preprocesseur/type2role.i}
using outils.outilTraduction.
{oerealm/include/instanciateTokenOnModel.i} /* Doit �tre positionn�e juste apr�s using */

procedure controleCleGerance private:
    /*------------------------------------------------------------------------------
    Purpose: Procedure de controle de l'utilisation de la cl� en G�rance
    Notes  : recherche dans les param�trages prestations
             recherche dans les charges locatives (cl�s de chauffe)
             recherche dans les relev�s d'eau/thermies...
             recherche dans les imputations particuli�res
             recherche dans la Paie concierge            
             recherche dans les �critures comptables     
    ------------------------------------------------------------------------------*/    
    define input parameter piNumeroImmeuble      as integer   no-undo.
    define input parameter pcTypeControle        as character no-undo. 
    define input parameter pcTypeContratControle as character no-undo. // Sera significatif pour le controle des cl�s en copro
    define input parameter pcTypeContrat         as character no-undo.
    define input parameter piNumeroContrat       as integer   no-undo.
    define input parameter pcCodeCle             as character no-undo.
    define output parameter pcErreur             as character no-undo. 

    define variable viBoucle               as integer   no-undo.
    define variable vcMessageMandat        as character no-undo.
    define variable viNumeroDossierMinimum as int64     no-undo.
    define variable viNumeroDossierMaximum as int64     no-undo.       
    define variable vcListeMessage         as character no-undo.
    
    define buffer tache for tache.
    define buffer perio for perio. 
    define buffer erlet for erlet.
    define buffer entip for entip.
    define buffer cecrlnana for cecrlnana.
    define buffer cexmlnana for cexmlnana.

    vcMessageMandat = outilFormatage:fSubstGestion(outilTraduction:getLibelle(104113), string(piNumeroContrat)). 
    for first tache no-lock // recherche dans les param�trages prestations (cl� par d�faut) 
        where tache.tpcon = pcTypeContrat
          and tache.nocon = piNumeroContrat
          and tache.tptac = {&TYPETACHE-chargesLocativesPrestations}
          and tache.notac = 1 
          and tache.dcreg = pcCodeCle:
        // cl� par d�faut des charges locatives
        vcListeMessage = outilTraduction:getLibelle(104114). // Cl� par d�faut des charges locatives
        if pcTypeContratControle <> pcTypeContrat then vcListeMessage = substitute("&1,&2", vcMessageMandat,  vcListeMessage). 
        pcErreur = substitute("&1@&2", pcErreur, vcListeMessage). 
    end.
    for each perio no-lock // recherche dans les charges locatives (cl�s de chauffe) 
        where perio.tpctt = pcTypeContrat
          and perio.nomdt = piNumeroContrat
          and perio.noper = 0:
boucleCle:
        do viBoucle = 1 to num-entries( perio.lbdiv, ","):
            if entry(viBoucle, perio.lbdiv, ",") = pcCodeCle then do:
                vcListeMessage = outilTraduction:getLibelle(104122). // Les cl�s de chauffage de la p�riode n� %1
                if pcTypeContratControle <> pcTypeContrat then vcListeMessage = substitute("&1,&2", vcMessageMandat, vcListeMessage).
                mError:createError({&error}, substitute(vcListeMessage, perio.noexo)).
                pcErreur = substitute("&1@&2", pcErreur, substitute(vcListeMessage, perio.noexo)).
                leave boucleCle.
            end.
        end.
    end.
boucleTache:
    for each tache no-lock                  // recherche dans le param�trage des relev�s d'eau/thermies...
        where tache.TpCon = pcTypeContrat
          and tache.nocon = piNumeroContrat
          and tache.tptac >= {&TYPETACHE-eauFroideGerance} // Eau Froide
          and tache.tptac <= {&TYPETACHE-thermieGerance}   // Thermies
          and tache.notac = 1:
        if tache.utreg = pcCodeCle
        or (tache.dcreg = pcCodeCle and pcTypeControle <> "RAZNBTOT") then do:
            case tache.tptac:
                when {&TYPETACHE-eauFroideGerance} then vcListeMessage = outilTraduction:getLibelle(104117). // Le param�trage eau froide
                when {&TYPETACHE-eauChaudeGerance} then vcListeMessage = outilTraduction:getLibelle(104116). // Le param�trage eau chaude
                when {&TYPETACHE-thermieGerance}   then vcListeMessage = outilTraduction:getLibelle(104120). // Le param�trage thermies
            end case.
            if pcTypeContratControle <> pcTypeContrat then vcListeMessage = substitute("&1,&2", vcMessageMandat, vcListeMessage).
            pcErreur = substitute("&1@&2", pcErreur, vcListeMessage).
        end.
    end.
boucleErlet:
    for each erlet no-lock                  // recherche dans les relev�s d'eau/thermies...
        where erlet.tpcon = pcTypeContrat
          and erlet.nocon = piNumeroContrat:
        if erlet.clrec = pcCodeCle
        or (erlet.clrep = pcCodeCle and pcTypeControle <> "RAZNBTOT") then do:
            case erlet.tpcpt:
                when "00001" then vcListeMessage = outilTraduction:getLibelle(104101). /* Le relev� d'eau froide n� %1 */
                when "00002" then vcListeMessage = outilTraduction:getLibelle(104102). /* Le relev� d'eau chaude n� %1 */
                when "00003" then vcListeMessage = outilTraduction:getLibelle(104103). /* Le relev� de thermies n� %1 */
            end case.
            if pcTypeContratControle <> pcTypeContrat then vcListeMessage = substitute("&1,&2", vcMessageMandat, vcListeMessage).
            assign
                vcListeMessage = substitute(vcListeMessage,erlet.norlv) 
                pcErreur       = substitute("&1@&2", pcErreur, vcListeMessage)
            .
            leave boucleErlet.
        end.
    end.
boucleEntip:
    for each entip no-lock                  // recherche dans les imputations particuli�res MANDAT
        where entip.nocon = piNumeroContrat
          and entip.noimm = piNumeroImmeuble:
        if entip.nocre = pcCodeCle
        or (entip.nocle = pcCodeCle and pcTypeControle <> "RAZNBTOT") then do:
            vcListeMessage = outilTraduction:getLibelle(104107). // L'imputation particuli�re du %1
            if pcTypeContratControle <> pcTypeContrat then vcListeMessage = substitute("&1,&2", vcMessageMandat, vcListeMessage).
            assign
                vcListeMessage = substitute(vcListeMessage, string(entip.dtimp, "99/99/9999"))
                pcErreur       = substitute("&1@&2", pcErreur, vcListeMessage)
            .
            leave boucleEntip.
        end.
    end.
    // recherche dans les imputations particuli�res Dossier travaux 
    assign
        viNumeroDossierMinimum = piNumeroContrat * 100000 + 1
        viNumeroDossierMaximum = piNumeroContrat * 100000 + 99999
    .
boucleEntip2:
    for each entip no-lock
        where entip.nocon >= viNumeroDossierMinimum
          and entip.nocon <= viNumeroDossierMaximum
          and entip.noimm = piNumeroImmeuble:
        if entip.nocre = pcCodeCle
        or (entip.nocle = pcCodeCle and pcTypeControle <> "RAZNBTOT") then do:
            assign 
                vcListeMessage = substitute(outilTraduction:getLibelle(1000578), string(entip.dtimp, "99/99/9999"), string(entip.nocon modulo 100000, "99999"))  // 1000578 "L'imputation particuli�re du &1 du dossier travaux no &2"
                pcErreur       = substitute("&1@&2", pcErreur, vcListeMessage)
            .
            leave boucleEntip2.
        end.
    end.    
    if pcTypeControle <> "RAZNBTOT" then do:
        for first cecrlnana no-lock // recherche dans les �critures comptables
            where cecrlnana.soc-cd  = integer(mtoken:cRefGerance)
              and cecrlnana.etab-cd = piNumeroContrat
              and cecrlnana.ana4-cd = pcCodeCle:
            vcListeMessage = outilTraduction:getLibelle(104111). // Les �critures comptables (journal %1 du %2)
            if pcTypeContratControle <> pcTypeContrat then vcListeMessage = substitute("&1,&2", vcMessageMandat, vcListeMessage).
            assign
                vcListeMessage = substitute(vcListeMessage, cecrlnana.jou-cd, string(cecrlnana.dacompta, "99/99/9999"))
                pcErreur       = substitute("&1@&2", pcErreur, vcListeMessage)
            .
        end.
        for first cexmlnana no-lock // recherche dans les �critures extra-comptables
            where cexmlnana.soc-cd  = integer(mtoken:cRefGerance)
              and cexmlnana.etab-cd = piNumeroContrat
              and cexmlnana.ana4-cd = pcCodeCle:
            vcListeMessage = outilTraduction:getLibelle(104112). //  Les �critures extra-comptables (journal %1 du %2) */
            if pcTypeContratControle <> pcTypeContrat then vcListeMessage = substitute("&1,&2", vcMessageMandat, vcListeMessage).
            assign
                vcListeMessage = substitute(vcListeMessage, cexmlnana.jou-cd, string(cexmlnana.dacompta, "99/99/9999"))
                pcErreur       = substitute("&1@&2", pcErreur, vcListeMessage)
            .
        end.
    end.
end procedure.

procedure controle:
    /*------------------------------------------------------------------------------
    Purpose: Procedure de controle de l'utilisation de la cl�
    Notes  : service utilis� par tacheCleRepartition.p
    ------------------------------------------------------------------------------*/    
    define input parameter pcTypeContrat    as character no-undo.
    define input parameter piNumeroContrat  as int64     no-undo.
    define input parameter piNumeroImmeuble as integer   no-undo.
    define input parameter pcCodeCle        as character no-undo.
    define input parameter pcTypeControle   as character no-undo.

    define variable vcErreur         as character no-undo. 
    define variable vcListeMessage   as character no-undo.
    define variable vcTableauMessage as character no-undo extent 10.
    define variable viBoucle         as integer   no-undo.

    if pcTypeContrat = {&TYPECONTRAT-mandat2Gerance} 
    then run controleCleGerance (piNumeroImmeuble, pcTypeControle, pcTypeContrat, pcTypeContrat, piNumeroContrat, pcCodeCle, output vcErreur). // pcTypeContrat ->  
    if vcErreur > "" then do:
        assign 
            vcListeMessage      = outilTraduction:getLibelle(104096)      // Cette cl� est utilis�e dans
            vcErreur            = substring(vcErreur, 2)
            vcTableauMessage[1] = vcListeMessage + " :" 
        .
        do viBoucle = 1 to 9:
            vcTableauMessage[viBoucle + 1] = if num-entries(vcErreur, "@") >= viBoucle then entry(viBoucle, vcErreur, "@") else "".
        end.
        if pcTypeControle = "RAZNBTOT" 
        then vcListeMessage = substitute(outilTraduction:getLibelle(1000542), pcCodeCle). // 1000542 0 "Suppression des milli�mes de la cl� &1 interdite"
        else vcListeMessage = substitute(outilTraduction:getLibelle(1000543), pcCodeCle). // 1000543 0 "Suppression de la cl� &1 interdite"
        mError:createError({&error}, vcListeMessage). // Titre de la liste d'erreurs
        do viBoucle = 1 to 10 :
            if vcTableauMessage[viBoucle] > "" then mError:createError({&error}, vcTableauMessage[viBoucle]). // Liste d'erreurs
        end.
    end.
end procedure.
