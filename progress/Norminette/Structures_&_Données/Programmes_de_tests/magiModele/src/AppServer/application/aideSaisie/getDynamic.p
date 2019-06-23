/*------------------------------------------------------------------------
File        : getDynamic.p
Purpose     : 
Description : 
Author(s)   : 
Created     : Fri Nov 10 14:42:24 CET 2017
Notes       :
------------------------------------------------------------------------*/
{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

procedure getDynamic:
    /*------------------------------------------------------------------------------
    Purpose: requête dynamique utilisé par différents services
    Notes  : service
    ------------------------------------------------------------------------------*/
    define input  parameter pcTableName as character no-undo.
    define input  parameter pcFieldList as character no-undo.
    define input  parameter pcWhere     as character no-undo.
    define output parameter table-handle phttTable.

    define variable vhQuery     as handle  no-undo.
    define variable vhbufferIn  as handle  no-undo.
    define variable vhbufferOut as handle  no-undo.
    define variable viCpt       as integer no-undo.

    // Création table, buffer et query 
    create temp-table phttTable.    
    create buffer vhbufferIn for table pcTableName.
    create query vhQuery.

    // Ajout champ booléen de sélection
    phttTable:add-new-field("lSelect", "logical", 0, "", true).

    // Ajout des champs depuis la table physique
    do viCpt = 1 to num-entries(pcFieldList, ","):
        phttTable:add-like-field(entry(viCpt, pcFieldList, ","), substitute('&1.&2', pcTableName, entry(viCpt, pcFieldList, ","))).
    end.

    // Initialisation de la table temporaire cible
    phttTable:temp-table-prepare("tt" + pcTableName).
    vhBufferOut = phttTable:default-buffer-handle.

    // Exécution de la requête
    vhQuery:set-buffers(vhbufferIn).
    vhQuery:query-prepare(substitute("FOR EACH &1 no-lock &2", pcTableName, if pcWhere > "" then 'where ' + pcWhere else "")).
    vhQuery:query-open().

boucle1:
    repeat:
        vhQuery:get-next().
        if vhQuery:query-off-end then leave boucle1.
        vhBufferOut:buffer-create().
        vhBufferOut:buffer-copy(vhBufferIn).
    end.
    vhQuery:query-close().
    delete object vhQuery.

end procedure.
