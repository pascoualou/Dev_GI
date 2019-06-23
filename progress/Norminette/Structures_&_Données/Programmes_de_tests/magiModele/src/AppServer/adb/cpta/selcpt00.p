/*-----------------------------------------------------------------------------
File        : selcpt00.p
Purpose     : Sélection d'un mandat copro ou gérance
Author(s)   : SY - 04/03/2008     GGA - 2018/10/08
Notes       : reprise de adb/cpta/selcpt00.p

 0001  24/08/2009    SY    retour tests : interdire l'auto-compensation 
 0002  22/09/2009    SY    retour consultants : interdit de compenser   
                           sur un Fournisseur ou en copro (détournement 
                           de fonds !)                                  
-----------------------------------------------------------------------------*/
{preprocesseur/type2contrat.i}
{preprocesseur/comptabilite.i}

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{application/include/glbsepar.i}
{adb/include/selectionCollectif.i &nomtable=ttListeCodeCollectif}
{adb/include/selectionCollectif.i &nomtable=ttListeSousCompteCollectif}

function lectureCtrat return integer (pcTypeContrat as character, piNumeroContrat as int64):
    /*------------------------------------------------------------------------------
    Purpose: 
    Notes  :
    ------------------------------------------------------------------------------*/
    define buffer ctrat for ctrat.
    for first ctrat no-lock
        where ctrat.tpcon = pcTypeContrat
          and ctrat.nocon = piNumeroContrat:
        return (if ctrat.tpcon = {&TYPECONTRAT-mandat2Syndic} then integer(mtoken:cRefCopro) else integer(mtoken:cRefGerance)).
    end.              
    mError:createError({&error}, 1000847, substitute("&2&1&3", separ[1], piNumeroContrat, pcTypeContrat)). //Contrat N° &1 de type &2 non trouvé
    return ?.
    
end function.

procedure controleCollectif:
    /*------------------------------------------------------------------------------
    Purpose: 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter poCollection as class collection no-undo.
        
    define variable vcTypeContrat          as character no-undo.
    define variable viNumeroContrat        as int64     no-undo.
    define variable vcListeCompteCollectif as character no-undo.    
    define variable vcCodeCollectif        as character no-undo.
    define variable vcNumeroSousCompte     as character no-undo.
    define variable viCodeSociete          as integer   no-undo.

    define buffer csscptcol for csscptcol.

    assign
        vcTypeContrat          = poCollection:getCharacter("cTypeContrat")
        viNumeroContrat        = poCollection:getInt64("iNumeroContrat")
        vcListeCompteCollectif = poCollection:getCharacter("cCompteCollectifCompensation") 
        vcCodeCollectif        = poCollection:getCharacter("cCodeCollectif")
        vcNumeroSousCompte     = poCollection:getCharacter("cNumeroSousCompte")
        viCodeSociete          = lectureCtrat (vcTypeContrat, viNumeroContrat).
    .
    if mError:erreur() then return.
        
    find first csscptcol no-lock
         where csscptcol.soc-cd     = viCodeSociete
           and csscptcol.etab-cd    = viNumeroContrat
           and csscptcol.sscoll-cle = vcCodeCollectif no-error.
    if not available csscptcol
    then do:
        mError:createError({&error}, 1000889).              //Le collectif n'existe pas pour ce mandat
        return.
    end.
    if not can-do(vcListeCompteCollectif, csscptcol.sscoll-cpt)
    then do:
        mError:createError({&error}, 1000892, csscptcol.sscoll-cpt). //le compte collectif &1 n'est pas un compte autorisé pour la compensation 
        return.        
    end.    
    if not can-find(first csscpt no-lock 
                     where csscpt.soc-cd     = viCodeSociete
                       and csscpt.sscoll-cle = vcCodeCollectif
                       and csscpt.cpt-cd     = vcNumeroSousCompte)
    then do:
        mError:createError({&error}, 1000891).           //Ce sous-compte n'existe pas
        return.
    end.

end procedure.

procedure listeCollectif:
    /*------------------------------------------------------------------------------
    Purpose: liste code collectif
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter poCollection as class collection no-undo.
    define output parameter table for ttListeCodeCollectif.
            
    define variable vcTypeContrat          as character no-undo.
    define variable viNumeroContrat        as int64     no-undo.
    define variable vcListeCompteCollectif as character no-undo.
    define variable viCodeSociete          as integer   no-undo.

    define buffer csscptcol for csscptcol.

    empty temp-table ttListeCodeCollectif.
    assign
        vcTypeContrat          = poCollection:getCharacter("cTypeContrat")
        viNumeroContrat        = poCollection:getInt64("iNumeroContrat")
        vcListeCompteCollectif = poCollection:getCharacter("cCompteCollectifCompensation") 
        viCodeSociete          = lectureCtrat (vcTypeContrat, viNumeroContrat).
    .
    if mError:erreur() then return.

    for each csscptcol no-lock
       where csscptcol.soc-cd      = viCodeSociete
         and csscptcol.etab-cd     = viNumeroContrat
         and can-do(vcListeCompteCollectif, csscptcol.sscoll-cpt):
        create ttListeCodeCollectif.
        assign 
            ttListeCodeCollectif.cTypeContrat      = vcTypeContrat
            ttListeCodeCollectif.iNumeroContrat    = viNumeroContrat
            ttListeCodeCollectif.cCompteCollectif  = csscptcol.sscoll-cpt
            ttListeCodeCollectif.cCodeCollectif    = csscptcol.sscoll-cle 
            ttListeCodeCollectif.cLibelleCollectif = csscptcol.lib
        .    
    end.
    
end procedure.

procedure listeSousCompte:
    /*------------------------------------------------------------------------------
    Purpose: liste sous-compte
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter poCollection as class collection no-undo.    
    define output parameter table for ttListeSousCompteCollectif.

    define variable vcTypeContrat          as character no-undo.
    define variable viNumeroContrat        as int64     no-undo.
    define variable vcListeCompteCollectif as character no-undo.    
    define variable vcCodeCollectif        as character no-undo.    
    define variable viCodeSociete          as integer   no-undo.

    define buffer csscptcol for csscptcol.
    define buffer csscpt    for csscpt. 
    define buffer ctrat     for ctrat. 

    empty temp-table ttListeSousCompteCollectif.
    assign
        vcTypeContrat          = poCollection:getCharacter("cTypeContrat")
        viNumeroContrat        = poCollection:getInt64("iNumeroContrat")
        vcListeCompteCollectif = poCollection:getCharacter("cCompteCollectifCompensation") 
        vcCodeCollectif        = poCollection:getCharacter("cCodeCollectif")
        viCodeSociete          = lectureCtrat(vcTypeContrat, viNumeroContrat).
    .
    if mError:erreur() then return.

    find first csscptcol no-lock
         where csscptcol.soc-cd     = viCodeSociete
           and csscptcol.etab-cd    = viNumeroContrat
           and csscptcol.sscoll-cle = vcCodeCollectif no-error.
    if not available csscptcol
    then do:
        mError:createError({&error}, 1000889).            //Le collectif n'existe pas pour ce mandat
        return.
    end.
    if not can-do(vcListeCompteCollectif, csscptcol.sscoll-cpt)
    then do:
        mError:createError({&error}, 1000892, csscptcol.sscoll-cpt). //le compte collectif &1 n'est pas un compte autorisé pour la compensation 
        return.        
    end.    
    if csscptcol.sscoll-cpt = {&compteCollectif-Locataire}
    then for each csscpt no-lock
            where csscpt.soc-cd     = viCodeSociete
              and csscpt.etab-cd    = viNumeroContrat
              and csscpt.sscoll-cle = vcCodeCollectif
         , first ctrat no-lock
           where ctrat.tpcon = {&TYPECONTRAT-bail}
             and ctrat.nocon = integer(string(viNumeroContrat, "99999") + csscpt.cpt-cd) 
             and ctrat.dtree = ?:
        create ttListeSousCompteCollectif.
        assign 
            ttListeSousCompteCollectif.cTypeContrat       = vcTypeContrat
            ttListeSousCompteCollectif.iNumeroContrat     = viNumeroContrat
            ttListeSousCompteCollectif.cCompteCollectif   = csscptcol.sscoll-cpt
            ttListeSousCompteCollectif.cCodeCollectif     = csscptcol.sscoll-cle 
            ttListeSousCompteCollectif.cLibelleCollectif  = csscptcol.lib                
            ttListeSousCompteCollectif.cSousCompte        = csscpt.cpt-cd  
            ttListeSousCompteCollectif.cLibelleSousCompte = csscpt.lib               
        .    
    end.    
    else for each csscpt no-lock 
            where csscpt.soc-cd     = viCodeSociete
              and csscpt.etab-cd    = viNumeroContrat
              and csscpt.sscoll-cle = vcCodeCollectif:
        create ttListeSousCompteCollectif.
        assign 
            ttListeSousCompteCollectif.cTypeContrat       = vcTypeContrat
            ttListeSousCompteCollectif.iNumeroContrat     = viNumeroContrat
            ttListeSousCompteCollectif.cCompteCollectif   = csscptcol.sscoll-cpt
            ttListeSousCompteCollectif.cCodeCollectif     = csscptcol.sscoll-cle 
            ttListeSousCompteCollectif.cLibelleCollectif  = csscptcol.lib            
            ttListeSousCompteCollectif.cSousCompte        = csscpt.cpt-cd  
            ttListeSousCompteCollectif.cLibelleSousCompte = csscpt.lib                               
        .    
    end.                      
    
end procedure.


