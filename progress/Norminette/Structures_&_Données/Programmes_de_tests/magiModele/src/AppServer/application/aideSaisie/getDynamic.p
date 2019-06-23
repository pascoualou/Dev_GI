/*------------------------------------------------------------------------
File        : getDynamic.p
Purpose     : 
Description : 
Author(s)   : 
Created     : Fri Nov 10 14:42:24 CET 2017
Notes       :
------------------------------------------------------------------------*/
{oerealm/include/instanciateTokenOnModel.i} /* Doit �tre positionn�e juste apr�s using */

procedure getDynamic:
    /*------------------------------------------------------------------------------
    Purpose: requ�te dynamique utilis� par diff�rents services
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

    // Cr�ation table, buffer et query 
    create temp-table phttTable.    
    create buffer vhbufferIn for table pcTableName.
    create query vhQuery.

    // Ajout champ bool�en de s�lection
    phttTable:add-new-field("lSelect", "logical", 0, "", true).

    // Ajout des champs depuis la table physique
    do viCpt = 1 to num-entries(pcFieldList, ","):
        phttTable:add-like-field(entry(viCpt, pcFieldList, ","), substitute('&1.&2', pcTableName, entry(viCpt, pcFieldList, ","))).
    end.

    // Initialisation de la table temporaire cible
    phttTable:temp-table-prepare("tt" + pcTableName).
    vhBufferOut = phttTable:default-buffer-handle.

    // Ex�cution de la requ�te
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
