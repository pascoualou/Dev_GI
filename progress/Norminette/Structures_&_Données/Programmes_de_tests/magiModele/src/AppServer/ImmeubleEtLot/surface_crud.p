/*------------------------------------------------------------------------
File        : surface_crud.p
Purpose     :
Author(s)   : kantena - 2016/12/20
Notes       :
              13/10/2017  npo  #2241 add new surface commerciale utile 
------------------------------------------------------------------------*/
{preprocesseur/unite2surface.i}
{preprocesseur/type2bien.i}

using parametre.syspr.parametrageUniteSurface.
{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{immeubleEtLot/include/lot.i}
{immeubleEtLot/include/surface.i}

function lCreateSurface returns logical private(
    phttBuffer as handle, phBuffer as handle, pcTypeBien as character, piNumeroBien as integer, pcTypeSurface as character, pcCode as character):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vdSurface1 as decimal no-undo.  /* Surface habitable Km2 ou Ha */
    define variable vdSurface2 as decimal no-undo.  /* Surface habitable M2  ou A  */
    define variable vdSurface3 as decimal no-undo.

    phttBuffer:buffer-create().
    assign
        phttBuffer::CRUD                = 'R'
        phttBuffer::cTypeBien           = pcTypeBien
        phttBuffer::iNumeroBien         = piNumeroBien
        phttBuffer::cCodeTypeSurface    = pcTypeSurface
        phttBuffer::cLibelleTypeSurface = outilTraduction:getLibelle(pcTypeSurface)
        phttBuffer::cCodeUnite          = phBuffer:buffer-field('us' + pcCode):buffer-value
        phttBuffer::dtTimestamp         = datetime(phBuffer::dtmsy, phBuffer::hemsy)
        phttBuffer::rRowid              = phBuffer:rowid
    .
    if pcTypeBien <> {&TYPEBIEN-lot}
    then do:
        run decoupeSurface(
            phBuffer:buffer-field('sf' + pcCode):buffer-value(),
            phBuffer:buffer-field('af' + pcCode):buffer-value(),
            phttBuffer::cCodeUnite,
            output vdSurface1, output vdSurface2, output vdSurface3).
        assign
            phttBuffer::dSurface1 = vdSurface1
            phttBuffer::dSurface2 = vdSurface2
            phttBuffer::dValeur   = vdSurface3
        .
    end.
    else phttBuffer::dValeur = phBuffer:buffer-field('sf' + pcCode):buffer-value.

end function.

procedure readSurfaceSelectionLot:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par beImmeuble.cls
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeSurface as character no-undo.
    define input  parameter table for ttListeLot.
    define output parameter table for ttSurface.

    for each ttListeLot:
        run readSurface({&TYPEBIEN-lot}, ttListeLot.iNumeroBien, pcTypeSurface, output table ttSurface).
    end.
end procedure.

procedure readSurface:
    /*------------------------------------------------------------------------------
    Purpose: attention, pour batiment, le piNumeroBien est l'immeuble !!!
    Notes  : service utilisé par beImmeuble.cls
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeBien    as character no-undo.
    define input parameter piNumeroBien  as integer   no-undo.
    define input parameter pcTypeSurface as character no-undo.
    define output parameter table-handle phtt.

    define variable vhBuffer as handle no-undo.
    define buffer local for local.
    define buffer batim for batim.
    define buffer imble for imble.

    assign 
        phtt     = temp-table ttSurface:handle
        vhBuffer = phtt:default-buffer-handle
    .
    case pcTypeBien:
        when {&TYPEBIEN-immeuble} then for first imble no-lock
            where imble.noimm = piNumeroBien:
            lCreateSurface(vhBuffer, buffer imble:handle, pcTypeBien, imble.noimm, {&TYPESURFACE-habitable},  'hab').
            lCreateSurface(vhBuffer, buffer imble:handle, pcTypeBien, imble.noimm, {&TYPESURFACE-developpee}, 'dev').
            lCreateSurface(vhBuffer, buffer imble:handle, pcTypeBien, imble.noimm, {&TYPESURFACE-terrain},    'ter').
            lCreateSurface(vhBuffer, buffer imble:handle, pcTypeBien, imble.noimm, {&TYPESURFACE-espaceVert}, 'vet').
        end.

        when {&TYPEBIEN-batiment} then for each batim no-lock
            where batim.noimm = piNumeroBien:
            lCreateSurface(vhBuffer, buffer batim:handle, pcTypeBien, batim.NoBat, {&TYPESURFACE-habitable},  'hab').
            lCreateSurface(vhBuffer, buffer batim:handle, pcTypeBien, batim.NoBat, {&TYPESURFACE-developpee}, 'dev').
            lCreateSurface(vhBuffer, buffer batim:handle, pcTypeBien, batim.NoBat, {&TYPESURFACE-terrain},    'ter').
            lCreateSurface(vhBuffer, buffer batim:handle, pcTypeBien, batim.NoBat, {&TYPESURFACE-espaceVert}, 'vet').
        end.

        when {&TYPEBIEN-lot}
        then if pcTypeSurface = "PRINCIPALE"
        then for first local no-lock
            where local.noloc = piNumeroBien:
            lCreateSurface(vhBuffer, buffer local:handle, pcTypeBien, local.noloc, {&TYPESURFACE-habitable},  'ree').
        end.
        else for first local no-lock
            where local.noloc = piNumeroBien:
            lCreateSurface(vhBuffer, buffer local:handle, pcTypeBien, local.noloc, {&TYPESURFACE-habitable},  'ree').
            lCreateSurface(vhBuffer, buffer local:handle, pcTypeBien, local.noloc, {&TYPESURFACE-carrez},     'non').
            lCreateSurface(vhBuffer, buffer local:handle, pcTypeBien, local.noloc, {&TYPESURFACE-ponderee},   'pde').
            lCreateSurface(vhBuffer, buffer local:handle, pcTypeBien, local.noloc, {&TYPESURFACE-expertisee}, 'exp').
            lCreateSurface(vhBuffer, buffer local:handle, pcTypeBien, local.noloc, {&TYPESURFACE-corrigee},   'cor').
            lCreateSurface(vhBuffer, buffer local:handle, pcTypeBien, local.noloc, {&TYPESURFACE-estimee},    'arc').
            lCreateSurface(vhBuffer, buffer local:handle, pcTypeBien, local.noloc, {&TYPESURFACE-bureau},     'bur').
            lCreateSurface(vhBuffer, buffer local:handle, pcTypeBien, local.noloc, {&TYPESURFACE-commerciale},'com').
            lCreateSurface(vhBuffer, buffer local:handle, pcTypeBien, local.noloc, {&TYPESURFACE-stockage},   'stk').
            lCreateSurface(vhBuffer, buffer local:handle, pcTypeBien, local.noloc, {&TYPESURFACE-parking},    'pkg').
            lCreateSurface(vhBuffer, buffer local:handle, pcTypeBien, local.noloc, {&TYPESURFACE-annexe},     'axe').
            lCreateSurface(vhBuffer, buffer local:handle, pcTypeBien, local.noloc, {&TYPESURFACE-terrasse},   'ter').
            lCreateSurface(vhBuffer, buffer local:handle, pcTypeBien, local.noloc, {&TYPESURFACE-plancher},   'plancher').
            lCreateSurface(vhBuffer, buffer local:handle, pcTypeBien, local.noloc, {&TYPESURFACE-emprisesol}, 'emprisesol').
            lCreateSurface(vhBuffer, buffer local:handle, pcTypeBien, local.noloc, {&TYPESURFACE-commUtile},  'scu').   /* npo #2241 */
        end.
    end case.

end procedure.

procedure setSurface:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par beImmeuble.cls et beLot.cls
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeBien as character no-undo.
    define input  parameter table-handle phttSurfaceBien.
    define input-output parameter table-handle phttBien.

    define variable vhttSurface    as handle  no-undo.
    define variable vhQuerySurface as handle  no-undo.
    define variable vhBuffer       as handle  no-undo.
    define variable vhQueryBien    as handle  no-undo.
    define variable vdSurface      as decimal no-undo.
    define variable viAffichage    as integer no-undo.
    define variable viNumeroBien   as integer no-undo.

    assign
        vhttSurface = phttSurfaceBien:default-buffer-handle
        vhBuffer    = phttBien:default-buffer-handle
    .
    create query vhQueryBien.
    vhQueryBien:set-buffers(vhBuffer).
    vhQueryBien:query-prepare(substitute("FOR EACH &1", vhBuffer:name)).
    vhQueryBien:query-open().
    create query vhQuerySurface.
    vhQuerySurface:set-buffers(vhttSurface).
boucle1:
    repeat:
        vhQueryBien:get-next().
        if vhQueryBien:query-off-end then leave boucle1.

        viNumeroBien = if pcTypeBien = {&TYPEBIEN-immeuble} then vhBuffer::iNumeroImmeuble else if pcTypeBien = {&TYPEBIEN-batiment} then vhBuffer::iNumeroBatiment else vhBuffer::iNumeroBien.
        vhQuerySurface:query-prepare(substitute('FOR EACH &1 where &1.iNumeroBien=&2', vhttSurface:name, viNumeroBien)).
        vhQuerySurface:query-open().
boucle2:
        repeat:
            vhQuerySurface:get-next().
            if vhQuerySurface:query-off-end then leave boucle2.

            run regroupeSurface(vhttSurface::dSurface1, vhttSurface::dSurface2, vhttSurface::dValeur, vhttSurface::cCodeUnite, output vdSurface, output viAffichage).
            case string(vhttSurface::cCodeTypeSurface):
                when {&TYPESURFACE-habitable} then assign
                    vhBuffer::sfhab = vdSurface
                    vhBuffer::ushab = vhttSurface::cCodeUnite
                    vhBuffer::afhab = viAffichage
                .
                when {&TYPESURFACE-developpee} then assign
                    vhBuffer::sfDev = vdSurface
                    vhBuffer::usDev = vhttSurface::cCodeUnite
                    vhBuffer::afDev = viAffichage
                .
                when {&TYPESURFACE-terrain} then assign
                    vhBuffer::sfTer = vdSurface
                    vhBuffer::usTer = vhttSurface::cCodeUnite
                    vhBuffer::afTer = viAffichage
                .
                when {&TYPESURFACE-espaceVert} then assign
                    vhBuffer::sfVet = vdSurface
                    vhBuffer::usVet = vhttSurface::cCodeUnite
                    vhBuffer::afVet = viAffichage
                .
            end case.
        end.
        vhQuerySurface:query-close().
    end.
    vhQueryBien:query-close().
    delete object vhQueryBien no-error.
    delete object vhQuerySurface no-error.

end procedure.

procedure setSurfaceLot:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par beImmeuble.cls et beLot.cls
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeBien as character no-undo.
    define input  parameter table-handle phttSurfaceBien.
    define input-output parameter table-handle phttBien.

    define variable vhttSurface    as handle  no-undo.
    define variable vhQuerySurface as handle  no-undo.
    define variable vhBuffer       as handle  no-undo.
    define variable vhQueryBien    as handle  no-undo.
    define variable vdSurface      as decimal no-undo.
    define variable viAffichage    as integer no-undo.
    define variable viNumeroBien   as integer no-undo.

    assign
        vhttSurface   = phttSurfaceBien:default-buffer-handle
        vhBuffer      = phttBien:default-buffer-handle
    .
    create query vhQueryBien.
    vhQueryBien:set-buffers(vhBuffer).
    vhQueryBien:query-prepare(substitute("FOR EACH &1", vhBuffer:name)).
    vhQueryBien:query-open().

    create query vhQuerySurface.
    vhQuerySurface:set-buffers(vhttSurface).
boucle1:
    repeat:
        vhQueryBien:get-next().
        if vhQueryBien:query-off-end then leave boucle1.

        viNumeroBien = vhBuffer::iNumeroBien.
        vhQuerySurface:query-prepare(substitute('FOR EACH &1 where &1.iNumeroBien=&2', vhttSurface:name, viNumeroBien)).
        vhQuerySurface:query-open().
boucle2:
        repeat:
            vhQuerySurface:get-next().
            if vhQuerySurface:query-off-end then leave boucle2.

            run regroupeSurface(vhttSurface::dSurface1, vhttSurface::dSurface2, vhttSurface::dValeur, vhttSurface::cCodeUnite, output vdSurface, output viAffichage).
            case string(vhttSurface::cCodeTypeSurface):
                when {&TYPESURFACE-habitable} then assign
                    vhBuffer::sfree = vhttSurface::dValeur
                    vhBuffer::usree = vhttSurface::cCodeUnite
                .
                when {&TYPESURFACE-carrez} then assign
                    vhBuffer::sfnon = vhttSurface::dValeur
                    vhBuffer::usnon = vhttSurface::cCodeUnite
                .
                when {&TYPESURFACE-annexe} then assign
                    vhBuffer::sfaxe = vhttSurface::dValeur
                    vhBuffer::usaxe = vhttSurface::cCodeUnite
                .
                when {&TYPESURFACE-ponderee} then assign
                    vhBuffer::sfpde = vhttSurface::dValeur
                    vhBuffer::uspde = vhttSurface::cCodeUnite
                .
                when {&TYPESURFACE-corrigee} then assign
                    vhBuffer::sfcor = vhttSurface::dValeur
                    vhBuffer::uscor = vhttSurface::cCodeUnite
                .
                when {&TYPESURFACE-estimee} then assign
                    vhBuffer::sfarc = vhttSurface::dValeur
                    vhBuffer::usarc = vhttSurface::cCodeUnite
                .
                when {&TYPESURFACE-expertisee} then assign
                    vhBuffer::sfexp = vhttSurface::dValeur
                    vhBuffer::usexp = vhttSurface::cCodeUnite
                .
                when {&TYPESURFACE-bureau} then assign
                    vhBuffer::sfbur = vhttSurface::dValeur
                    vhBuffer::usbur = vhttSurface::cCodeUnite
                .
                when {&TYPESURFACE-commerciale} then assign
                    vhBuffer::sfcom = vhttSurface::dValeur
                    vhBuffer::uscom = vhttSurface::cCodeUnite
                .
                when {&TYPESURFACE-parking} then assign
                    vhBuffer::sfPkg = vhttSurface::dValeur
                    vhBuffer::usPkg = vhttSurface::cCodeUnite
                .
                when {&TYPESURFACE-stockage} then assign
                    vhBuffer::sfstk = vhttSurface::dValeur
                    vhBuffer::usstk = vhttSurface::cCodeUnite
                .
                when {&TYPESURFACE-terrasse} then assign
                    vhBuffer::sfter = vhttSurface::dValeur
                    vhBuffer::uster = vhttSurface::cCodeUnite
                .
                when {&TYPESURFACE-plancher} then assign
                    vhBuffer::sfPlancher = vhttSurface::dValeur
                    vhBuffer::usPlancher = vhttSurface::cCodeUnite
                .
                when {&TYPESURFACE-empriseSol} then assign
                    vhBuffer::sfEmpriseSol = vhttSurface::dValeur
                    vhBuffer::usEmpriseSol = vhttSurface::cCodeUnite
                .
                when {&TYPESURFACE-commUtile} then assign
                    vhBuffer::sfscu = vhttSurface::dValeur
                    vhBuffer::usscu = vhttSurface::cCodeUnite
                . /* npo #2241 */
            end case.
        end.
        vhQuerySurface:query-close().
    end.
    vhQueryBien:query-close().
    delete object vhQueryBien no-error.
    delete object vhQuerySurface no-error.

end procedure.

procedure decoupeSurface:
    /*-------------------------------------------------------------------------
    Purpose : Découpage de la surface totale en 1, 2 ou 3 zones
    Notes   :
    -------------------------------------------------------------------------*/
    define input  parameter pdSurfaceIn    as decimal   no-undo.
    define input  parameter piTypeSurface  as integer   no-undo.
    define input  parameter pcUniteSurface as character no-undo.
    define output parameter pdSurface01    as decimal   no-undo.  /* Surface habitable Km2 ou Ha */
    define output parameter pdSurface02    as decimal   no-undo.  /* Surface habitable M2  ou A   */
    define output parameter pdSurface03    as decimal   no-undo.

    pdSurface03 = pdSurfaceIn.
    if piTypeSurface = 2
    then case pcUniteSurface:
        when {&UNITESURFACE-m2} then assign
            pdSurface01 = 0
            pdSurface02 = truncate(pdSurfaceIn / {&Million}, 0)         /* Surface Km2  */
            pdSurface03 = pdSurface03 - pdSurface02 * {&Million}
        .
        when {&UNITESURFACE-cm2} then assign
            pdSurface01 = truncate(pdSurfaceIn / {&dixMilliard}, 0)     /* Surface Km2  */
            pdSurface03 = pdSurfaceIn - pdSurface01 * {&dixMilliard}
            pdSurface02 = truncate(pdSurface03 / {&dixMille}, 0)        /* Surface m2   */
            pdSurface03 = pdSurface03 - pdSurface02 * {&dixMille}
        .
        when {&UNITESURFACE-are} then assign
            pdSurface01 = 0
            pdSurface02 = truncate(pdSurfaceIn / {&cent}, 0)            /* Surface Ha   */
            pdSurface03 = pdSurface03 - pdSurface02 * {&cent}
        .
        when {&UNITESURFACE-hectare} then assign
            pdSurface01 = truncate(pdSurfaceIn / {&dixMille}, 0)        /* Surface Ha   */
            pdSurface03 = pdSurfaceIn - pdSurface01 * {&dixMille}
            pdSurface02 = truncate( pdSurface03 / {&cent}, 0)           /* Surface Ares */
            pdSurface03 = pdSurface03 - pdSurface02 * {&cent}
        .
    end case.

end procedure.

procedure regroupeSurface private:
    /*-------------------------------------------------------------------------
    Purpose : recalcul de la surface totale à partir de 1 à 3 zones
    Notes   :
    -------------------------------------------------------------------------*/
    define input  parameter pdSurface01    as decimal   no-undo.
    define input  parameter pdSurface02    as decimal   no-undo.
    define input  parameter pdSurface03    as decimal   no-undo.
    define input  parameter pcUniteSurface as character no-undo.
    define output parameter pdSurface      as decimal   no-undo.
    define output parameter piTypeSurface  as integer   no-undo.

    assign
        pdSurface     = pdSurface03
        piTypeSurface = (if pdSurface01 = 0 and pdSurface02 = 0 then 1 else 2)
    .
    case pcUniteSurface:
        when {&UNITESURFACE-m2}      then pdSurface = pdSurface02 * {&Million} + pdSurface03.
        when {&UNITESURFACE-cm2}     then pdSurface = pdSurface01 * {&dixMilliard} + pdSurface02 * {&dixMille} + pdSurface03.
        when {&UNITESURFACE-are}     then pdSurface = pdSurface02 * {&cent} + pdSurface03.
        when {&UNITESURFACE-hectare} then pdSurface = pdSurface01 * {&dixMille} + pdSurface02 * {&cent} + pdSurface03.
    end case.

end procedure.

procedure controleSurface:
    /*-------------------------------------------------------------------------
    Purpose : controle des zones de surface
    Notes   : service?
    todo    : pas utilisé pour le moment. A supprimer !?
    -------------------------------------------------------------------------*/
    define input  parameter pdSurface01    as decimal   no-undo.
    define input  parameter pdSurface02    as decimal   no-undo.
    define input  parameter pdSurface03    as decimal   no-undo.
    define input  parameter pcUniteSurface as character no-undo.
    define output parameter plSurfaceOK    as logical   no-undo.
    define output parameter piErreur       as integer   no-undo.
    define output parameter pcTranche      as character no-undo.
    define output parameter pcUnite        as character no-undo.

    case pcUniteSurface:
        when {&UNITESURFACE-m2} then if (pdSurface01 > 0 or pdSurface02 > 0) and pdSurface03 >= {&Million} then assign
            piErreur = 3
            pcTranche = "doit être < 1 000 000"  // todo traduction?
            pcUnite = "M2"
        .
        when {&UNITESURFACE-cm2} then if (pdSurface01 > 0 or pdSurface02 > 0) and pdSurface03 >= {&DixMille} then assign
            piErreur = 3
            pcTranche = "doit être < 10 000"     // todo traduction?
            pcUnite = "CM2"
        .
        when {&UNITESURFACE-are} then if pdSurface02 > 0 and pdSurface03 >= {&Cent} then assign
            piErreur = 3
            pcTranche = "doit être < 100"        // todo traduction?
            pcUnite = "A"
        .
        when {&UNITESURFACE-hectare} then if pdSurface02 >= 100 then assign
            piErreur = 2
            pcTranche = "doit être < 100"        // todo traduction?
            pcUnite = "A"
        .
        else if (pdSurface01 > 0 or pdSurface02 > 0) and pdSurface03 >= {&cent} then assign
            piErreur = 3
            pcTranche = "doit être < 100"        // todo traduction?
            pcUnite = "Ca"
        .
    end case.
    plSurfaceOK = (piErreur > 0).

end procedure.

procedure formateSurface:
    /*-------------------------------------------------------------------------
    Purpose : formate une surface
    Notes   : utilisee par bureautique/fusion/immeuble.p 
    -------------------------------------------------------------------------*/
    define input         parameter pdSurface       as decimal   no-undo.
    define input         parameter piAfSurface     as integer   no-undo.
    define input         parameter pcUniteSurface  as character no-undo.
    define output        parameter pcLibelleFormat as character no-undo.

    define variable viNumeroSurface1 as integer      no-undo.
    define variable viNumeroSurface2 as integer      no-undo.
    define variable viNumeroSurface3 as decimal      no-undo.
    define variable voParametreUniteSurface as class parametrageUniteSurface no-undo.
    
    run DecoupSurf ( pdSurface
                    , input piAfSurface 
                    , input pcUniteSurface 
                    , output viNumeroSurface1
                    , output viNumeroSurface2
                    , output viNumeroSurface3).
    voParametreUniteSurface = new parametrageUniteSurface(pcUniteSurface).

    pcLibelleFormat  = string(viNumeroSurface3) + " " + voParametreUniteSurface:getLibelleUnite3().
    if piAfSurface = 2 then do:
        if viNumeroSurface1 <> 0 
        then pcLibelleFormat = string(viNumeroSurface1)
                             + " "
                             + voParametreUniteSurface:getLibelleUnite1()
                             + "  "
                             + string(viNumeroSurface2)
                             + " " 
                             + voParametreUniteSurface:getLibelleUnite2()
                             + "  "
                             +  string(viNumeroSurface3)
                             + " "
                             + voParametreUniteSurface:getLibelleUnite3().
        else pcLibelleFormat = string(viNumeroSurface2) 
                             + " "
                             + voParametreUniteSurface:getLibelleUnite2() 
                             + "  "
                             + string(viNumeroSurface3)
                             + " "
                             + voParametreUniteSurface:getLibelleUnite3().
    end.

    if session:numeric-format = "AMERICAN" 
    then assign
        pcLibelleFormat = replace(pcLibelleFormat, ",", " ")
        pcLibelleFormat = replace(pcLibelleFormat, ".", ",")
    .
    if valid-object(voParametreUniteSurface) then delete object voParametreUniteSurface. 
end procedure.


