/*------------------------------------------------------------------------
File        : prclogia.i
Purpose     : Procédures pour créer/supprimer les traces de modif dans la base et autres Log ou suivi (table iAction) 
              reprise de cette procedure avec creation table p^lus simple que d'utiliser table ttIaction avec pgm iaction_CRUD.p
Author(s)   : PL/SY 07/06/2013   -  GGA  2018/05/25
Notes       : a partir de comm.prclogia.i 
------------------------------------------------------------------------*/

procedure CreLog-iAction private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : ATTENTION, par rapport a l'appli le parametre en entree cDivZone-IN (le dernier) n'est pas repris (pas utilise) 
    ------------------------------------------------------------------------------*/
    define input parameter pcNmUsrUse-IN       as character no-undo.
    define input parameter pcCodeAction-IN     as character no-undo.
    define input parameter pcNomPrg-IN         as character no-undo.
    define input parameter pcTypeIdent-IN      as character no-undo.
    define input parameter piNumeroIdent-IN    as int64     no-undo.
    define input parameter pcAncienneValeur-IN as character no-undo.
    define input parameter pcNouvelleValeur-IN as character no-undo.
    define input parameter pcTypeCtt-IN        as character no-undo.
    define input parameter piNumeroCtt-IN      as int64     no-undo.
    define input parameter pcTypeTache-IN      as character no-undo.
    define input parameter piNumeroTache-IN    as int64     no-undo.
    define input parameter pczone3-IN          as character no-undo.
    define input parameter pczone4-IN          as character no-undo.
    
    define buffer iaction for iaction.

    create iaction.
    assign
        iaction.usrid    = pcNmUsrUse-IN
        iaction.dacrea   = today
        iaction.ihcrea   = mtime
        iaction.action   = pcCodeAction-IN
        iaction.nomprg   = pcNomPrg-IN
        iaction.tpidt    = pcTypeIdent-IN
        iaction.noidt    = piNumeroIdent-IN
        iaction.zone1    = pcAncienneValeur-IN
        iaction.zone2    = pcNouvelleValeur-IN
        iaction.tpcon    = pcTypeCtt-IN
        iaction.nocon    = piNumeroCtt-IN
        iaction.tptac    = pcTypeTache-IN
        iaction.notac    = piNumeroTache-IN
        iaction.zone3    = pczone3-IN
        iaction.zone4    = pczone4-IN
        iaction.computer = os-getenv("COMPUTERNAME")   //gga todo 
        iaction.username = os-getenv("USERNAME")       //gga todo
    .
    
end procedure.  

procedure SupLog-iAction-ident private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : 
    ------------------------------------------------------------------------------*/    
    define input parameter pcCodeAction-IN  as character no-undo.
    define input parameter pcTypeIdent-IN   as character no-undo.
    define input parameter piNumeroIdent-IN as int64     no-undo.

    define buffer iaction for iaction.   

    if pcCodeAction-IN = "" 
    then for each iaction exclusive-lock /* Suppression de toute trace d'action pour cet identifiant */
            where iaction.tpidt = pcTypeIdent-IN
              and iaction.noidt = piNumeroIdent-IN:
        delete iaction.
    end.
    else for each iaction exclusive-lock /* Suppression des traces d'action d'un code action donné pour cet identifiant */
            where iaction.nomprg = pcCodeAction-IN
              and iaction.tpidt  = pcTypeIdent-IN
              and iaction.noidt  = piNumeroIdent-IN:
        delete iaction.
    end.

end procedure.              
        


