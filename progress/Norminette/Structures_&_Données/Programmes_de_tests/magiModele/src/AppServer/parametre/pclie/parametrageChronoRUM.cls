/*------------------------------------------------------------------------
File        : parametrageChronoRUM.cls
Description : Gestion du no chrono pour le codage RUM du mandat de prélèvement SEPA (SANUM)
Author(s)   : SPo - 2018/06/18
Notes       : d'après prcmsepa.i / procedure NxtNoChronoSEPA
------------------------------------------------------------------------*/
using oerealm.magiToken.
using outils.outilTraduction.
using outils.outils.

block-level on error undo, throw.

class parametre.pclie.parametrageChronoRUM inherits parametre.pclie.pclie:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    {application/include/error.i}
    {crud/include/pclie.i}

    define public static property mToken as class oerealm.token no-undo get. set.
    define public static property mError as class outils.errorHandler no-undo get. set.

    constructor public parametrageChronoRUM():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        super("SANUM").

    end constructor.

    method public void getNextNoChronoSEPA ( output piNoChronoRUM as integer ):
        /*------------------------------------------------------------------------------
        Purpose: recherche & incrémentation prochain numero chrono de génération AUTO du code RUM
                 de 1 à 9999999
        Notes  : d'après NxtNoChronoSEPA
        ------------------------------------------------------------------------------*/
        define variable viNoChronoSEPA as integer no-undo.
        empty temp-table ttpclie.
        define buffer pclie for pclie.
        find first Pclie no-lock where pclie.tppar = "SANUM" no-error.
        if not available pclie then do:
            create ttpclie.
            assign
            viNoChronoSEPA = 1
            ttpclie.tppar = "SANUM"
            ttpclie.int01 = viNoChronoSEPA
            ttpclie.CRUD = "C"
            .
        end.
        else do:
            /* si chrono max atteint : on repart à 1 */
            viNoChronoSEPA = (if pclie.int01 + 1 > 9999999 then 1 else pclie.int01 + 1).
            create ttpclie.
            outils:copyValidField(buffer pclie:handle, buffer ttpclie:handle).  // copy table physique vers temp-table
            assign
                ttpclie.int01       = viNoChronoSEPA
                ttpclie.CRUD        = "U"
                ttpclie.rRowid      = rowid(pclie)
                ttpclie.dtTimestamp = datetime(pclie.dtmsy, pclie.hemsy)
                .
        end.
        ttpclie.zon04 = string(today) + "@" + STRING(time , "HH:MM:SS").            /* date @ heure derniere utilisation */
        crudChronoSEPA ().
        empty temp-table ttpclie.
        piNoChronoRUM = viNoChronoSEPA.
    end method.

    method private logical crudChronoSEPA ():
        /*--------------------------------------------------------- ---------------------
         Purpose: CRUD du paramètre "SANUM"
         Notes:
        ------------------------------------------------------------------------------*/
        deleteChronoSEPA ().
        updateChronoSEPA ().
        createChronoSEPA ().
    end method.

    method public void setChronoSEPA (input table for ttPclie):
        /*------------------------------------------------------------------------------
         Purpose:
         Notes: Service externe
        ------------------------------------------------------------------------------*/
        crudChronoSEPA().
    end method.

    method private void updateChronoSEPA ():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define buffer Pclie for Pclie.

    bloc:
        do transaction:
            for each ttPclie where ttPclie.CRUD = "U":
                find first Pclie exclusive-lock
                    where rowid(Pclie) = ttPclie.rRowid no-wait no-error.
                if not outils:copyValidField(buffer Pclie:handle, buffer ttPclie:handle, 'U', MagiToken:mToken:cUser)
                then undo bloc, leave bloc.
            end.
        end.
        error-status:error = false no-error.   // reset error-status
        return.                                // reset return-value
    end method.

    method private void createChronoSEPA ():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define buffer Pclie for Pclie.

    bloc:
        do transaction:
            for each ttPclie where ttPclie.CRUD = "C" on error undo, leave:
                create Pclie.
                if not outils:copyValidField(buffer Pclie:handle, buffer ttPclie:handle, 'C', MagiToken:mtoken:cUser)
                then undo bloc, leave bloc.
            end.
        end.
        error-status:error = false no-error.   // reset error-status
        return.                                // reset return-value
    end method.

    method private void deleteChronoSEPA ():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  : service
        ------------------------------------------------------------------------------*/
        define buffer Pclie for Pclie.

    blocTrans:
        do transaction:
            for each ttPclie where ttPclie.CRUD = 'D':
                find first Pclie exclusive-lock
                    where rowid(Pclie) = ttPclie.rRowid no-wait no-error.
                delete Pclie no-error.
                if error-status:error then do:
                    //mError:createError({&error}, error-status:get-message(1)).
                    undo blocTrans, leave blocTrans.
                end.
            end.
        end.
        error-status:error = false no-error.  // reset error-status
    end method.

end class.
