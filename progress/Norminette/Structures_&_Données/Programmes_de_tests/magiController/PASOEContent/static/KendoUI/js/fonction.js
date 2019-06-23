var pathURLArray = window.location.pathname.split('/'), urlAjax = '', tabInHash = Array('ong'), regHash = new RegExp("[0-9_-]+", "g"), regInt = new RegExp("[^0-9]+", "g");
for (var iUrl = 1; iUrl < (pathURLArray.length)-1; iUrl++)
    urlAjax += '/' + pathURLArray[iUrl]
$.fn.clearForm = function () {
    return this.each(function () {
        var type = this.type, tag = this.tagName.toLowerCase();
        if (tag == 'form')
            return $(':input', this).clearForm();
        if (type == 'text' || type == 'password' || tag == 'textarea') {
            if ($(this).data("kendoDropDownList"))
                $(this).data("kendoDropDownList").value('');
            else
                this.value = '';
        }
        else if (type == 'checkbox' || type == 'radio')
            this.checked = false;
        else if (tag == 'select')
            this.selectedIndex = -1;
    });
};
function animate_menu() {
    $('#div_menu').hover(function () {
        $('#div_menu nav').stop(true).slideDown();
    }, function () {
        $('#div_menu nav').stop(true).slideUp();
    });
    var selectedNode = $('#menu').find('.k-menu-on');
    selectedNode.parents('ul.ul_menu').addClass('k-ul-on');

    $("#menu").kendoMenu({
        direction: 'right',
        orientation: 'vertical'
    });
}
function setAnimationAjax(state) {
    if (state == 1) {
        $('#divLoaderGlobal').stop(true).animate({ top: "0" }, 200, function () {
            $(this).find('.img_loading').show();
        });
    } else if(state == 2) {
        $('#divLoaderGlobal .img_loading').delay(250).fadeOut(200, function () {
            $('#divLoaderGlobal .img_loaded').fadeIn(200, function () {
                window.setTimeout(function () {
                    $('#divLoaderGlobal').animate({ top: "-65px" }, 200, function () {
                        $(this).find('img').hide();
                    });
                }, 700);
            });
        });
    } else {
        window.setTimeout(function () {
            $('#divLoaderGlobal').animate({ top: "-65px" }, 200, function () {
                $(this).find('img').hide();
            });
        }, 400);
    }
}
function isEmail(str) {
    var regemail = /^[a-zA-Z0-9._-]+@([a-zA-Z-]{1,}[.]){1,}[a-zA-Z]{2,3}$/, trigger = false;
    if (str != '') {
        if (str.match(regemail))
            trigger = true;
    }
    return trigger;
}
function getUrlVars(url) {
    var hash;
    var myJson = {};
    var hashes = url.slice(url.indexOf('?') + 1).split('&');
    for (var i = 0; i < hashes.length; i++) {
        hash = hashes[i].split('=');
        myJson[hash[0]] = hash[1];
    }
    return myJson;
}
function loadUrlHash() {
    $("body").hide();
    var tabHash = ((location.hash).replace('#', '')).split('_'), tabUrl = Array(), tabNewHash = Array(), eltHash = '', urlHref = '';
    for (iHash = 0; iHash < tabHash.length; iHash++) {
        eltHash = (tabHash[iHash]).replace(regHash, '');
        if ($.inArray(eltHash, tabInHash) > -1)
            tabNewHash.push(tabHash[iHash]);
        else
            tabUrl.push(tabHash[iHash]);      
    }
    urlHref = urlAjax;   
    if (tabUrl.length > 0)
        urlHref += '/' + tabUrl.join('/');
    if (tabNewHash.length > 0)
        urlHref += '#' + tabNewHash.join('_');
    window.location.href = urlHref;    
}
function loadButtonFiche() {
    $(".k-button-fiche, .btn_retour, #div_ariane a").each(function () {
        var href = '';
        if ($(this).hasClass('btn_retour')) {
            href = $('#hid_urlAction' + $(this).attr('id').replace('btn_','')).val();
        }
        else {
            href = $(this).attr('href');
        }
        var classOut = 'zoom-out-sm', classIn = 'zoom-in-sm', classInRemove = 'zoom-in-sm fade-in-left-sm fade-in-right-sm';
        /*if ($(this).parent().hasClass('fleche_gauche')) {
            classOut = 'fade-out-left';
            classIn = 'fade-in-right-sm';
        } else if ($(this).parent().hasClass('fleche_droite')) {
            classOut = 'fade-out-right';
            classIn = 'fade-in-left-sm';
        }*/
        $(this).unbind('click.load_fiche').bind('click.load_fiche', function (e) {
            e.preventDefault();
            if ($(this).hasClass('k-button-fiche')) {
                var dataAjax = $('.param').serialize();
                $.ajax({
                    url: href,
                    dataType: "html",
                    type: "POST",
                    data: dataAjax,
                    beforeSend: function () {
                        setAnimationAjax(1);
                    },
                    complete: function () {
                        setAnimationAjax(0);
                    },
                    success: function (data) {
                        var pathHref = href.split('/');
                        var hashLocation = href.replace(urlAjax, '');
                        if (hashLocation.charAt(0) == '/')
                            hashLocation = hashLocation.substring(1);
                        var tabHash = ((location.hash).replace('#', '')).split('_'), tabNewHash = Array(), eltHash = '';
                        for (iHash = 0; iHash < tabHash.length; iHash++) {
                            eltHash = (tabHash[iHash]).replace(regHash, '');
                            if ($.inArray(eltHash, tabInHash) > -1)
                                tabNewHash.push(tabHash[iHash]);
                        }
                        if (tabNewHash.length > 0)
                            hashLocation += '_' + tabNewHash.join('_');
                        location.hash = hashLocation.replace(new RegExp("/", 'g'), '_');
                        $('body main.animsition').removeClass(classInRemove).addClass(classOut).fadeTo("slow", 0.3, function () {
                            $('.k-popup, .k-window').remove();
                            $(this).html(data).removeClass(classOut).addClass(classIn);
                        }).fadeTo("slow", 1, function () {
                        });
                    }, error: function (xhr, status, error) {
                        loadDialogMessage(null, 'Erreur', false);
                    }
                });
            } else {
                $('body main.animsition').removeClass(classInRemove).addClass(classOut);
                window.location.href = href;
            }
        });
    });
}
function loadToTop() {
    $('.toTop').each(function () {
        var $toAnim = $('body,html'), $scroll = $(window), $toTop = $(this);
        if ($toTop.closest('.k-window-content').length > 0) {
            $parentDiv = $toTop.closest('.k-window-content');
            $toAnim = $parentDiv;
            $scroll = $parentDiv;
            $toTop.css('margin-top', -($parentDiv[0].scrollHeight) + $parentDiv.height() - (150 + $(window).scrollTop()));
            $toTop.css('margin-left', ($parentDiv.innerWidth()) - 70);
        }
        $scroll.scroll(function () {
            var distanceY = $(this).scrollTop();
            if (distanceY > 50)
                $toTop.fadeIn();
            else
                $toTop.fadeOut();
        });
        $toTop.unbind('click').bind('click', function () {
            $toAnim.animate({ scrollTop: 0 }, 500);
        });
    });
}

/***** ui *****/
function loadTitle() {
    $('a[title]:not(#div_menu a), img[title], input[title], div.title[title], .k-ellipsis[title]').removeData('qtip');
	$('.qtip').each(function(){
		$(this).remove();
	});
	$('a[title]:not(#div_menu a), img[title], input[title], div.title[title], .k-ellipsis[title]').each(function () {
		var qtip_my = 'bottom center';
		var qtip_at = 'top center';
		if ($(this).hasClass('qtip-position')) {
		    var all_class = $(this).attr('class');
		    if (all_class.indexOf(' ') != -1) {
		        var tab_all_class = all_class.split(' ');
		        if (tab_all_class.length > 0) {
		            for (i = 0; i < tab_all_class.length; i++) {
		                if (tab_all_class[i].substr(0, 8) == 'qtip-my-')
		                    qtip_my = tab_all_class[i].replace('qtip-my-', '').replace('_', ' ');
                        if (tab_all_class[i].substr(0, 8) == 'qtip-at-')
                            qtip_at = tab_all_class[i].replace('qtip-at-', '').replace('_', ' ');
		            }
		        }
		    }
		} else if ($(this).offset().top <= 60) {
		    qtip_my = 'top right';
		    qtip_at = 'bottom left';
		    if ($(this).offset().left <= 100) {
		        qtip_my = 'top left';
		        qtip_at = 'bottom right';
		    }
		} else if ($(this).offset().left <= 100) {
		    qtip_my = 'top left';
		    qtip_at = 'bottom right';
		}
		$('body').data('qtip_my', qtip_my);
		$('body').data('qtip_at', qtip_at);
		$(this).qtip({
			position: { my: $('body').data('qtip_my'), at: $('body').data('qtip_at')},
			hide: { fixed: true },
			style: {
			    classes: 'ui-tooltip-shadow ui-tooltip-magi'
			}
		});
	});
}
function toggleImageHover() {
    $('.k-button-hover:not(.k-img_on) img, input[type=image].k-button-hover').each(function () {
        $(this).hover(function () {
            $(this).attr('src', $(this).attr('src').replace('/off/', '/on/'));
        }, function () {
            $(this).attr('src', $(this).attr('src').replace('/on/', '/off/'));
        });
    });
    $('.k-button-hover.k-img_on img').each(function () {
        $(this).hover(function () {
            $(this).attr('src', $(this).attr('src').replace('/off/', '/on/'));
        }, function () {
            $(this).attr('src', $(this).attr('src').replace('/off/', '/on/'));
        });
    });
}
function loadHtmlFunction() {
    toggleImageHover();
    loadTitle();
    loadWindowStandard();
}
/***** fin ui *****/
/***** form ******/
function checkAll() {    
    var class_id = '', tab_all_class = Array(), all_class = '';
    $('.check_all').each(function () {       
        all_class = $(this).attr('class');
        if (all_class.indexOf(' ') != -1) {
             tab_all_class = all_class.split(' ');
            if (tab_all_class.length > 0) {
                for (i = 0; i < tab_all_class.length; i++) {
                    if (tab_all_class[i].substr(0, 6) == 'check_' && tab_all_class[i] != 'check_all') {                        
                        class_id = '.' + tab_all_class[i];
                        $(this).unbind('click.CheckAll').bind('click.CheckAll', function () {
                            if ($(this).is(':checked')) {                               
                                $(class_id).prop('checked', true);
                            }
                            else {
                                $(class_id).prop('checked', false);
                            }

                        });
                    }
                }
            }
        }
    });
    var nb_checkbox = 0, nb_checked = 0;
    $('.check_one').each(function () {
        all_class = $(this).attr('class');
        if (all_class.indexOf(' ') != -1) {
            tab_all_class = all_class.split(' ');
            if (tab_all_class.length > 0) {
                for (i = 0; i < tab_all_class.length; i++) {
                    if (tab_all_class[i].substr(0, 6) == 'check_' && tab_all_class[i] != 'check_one') {
                        class_id = '.' + tab_all_class[i];
                        $(this).unbind('click.CheckOne').bind('click.CheckOne', function () {
                            if ($(this).is(':checked')) {
                                nb_checkbox = $('.check_one' + class_id).length;
                                nb_checked = $('.check_one' + class_id + ':checked').length;                              
                                if (nb_checkbox == nb_checked) {
                                    $(class_id + '.check_all').prop('checked', true);
                                }
                              
                            }
                            else {
                                $(class_id + '.check_all').prop('checked', false);
                            }

                        });
                    }
                }
            }
        }
    });
}
function setEditMode(e) {
    $('#hid_editMode').val('1');
    $.ajax({
        url: $('#hid_urlActionEditMode').val() + '&state=1',
        dataType: "html",
        type: "POST",
        async:false,
        success: function (data) {
            $('#ToolbarActionGlobal .k-edit-mode').removeClass('k-img_on').addClass('k-img_on');
            loadHtmlFunction();
            $('#ToolbarActionGlobal .k-edit-mode img').attr('src', $('#ToolbarActionGlobal .k-edit-mode img').attr('src').replace('/off/', '/on/'));
            $('#div_nav_fleche').hide();
            $('.view_mode').fadeOut(function () {
                $('.edit_mode').fadeIn(function () {
                    if ($('.edit_mode .templateDetailBottom').length > 0) {
                        $('.edit_mode .templateDetailBottom').show();
                    }
                    if ($(this).find(".k-grid-autobind").length > 0) {
                        $(this).find(".k-grid-autobind").each(function () {
                            $(this).data("kendoGrid").dataSource.read();
                            $(this).removeClass('k-grid-autobind');
                        });
                    }
                    if ($(this).find('.k-grid-databound').length > 0) {
                        $(this).find('.k-grid-databound').each(function () {
                            onDataBoundGridStandard($(this).data("kendoGrid"));
                        });
                    }
                    $(window).trigger('resize');
                });
            });
        }, error: function (xhr, status, error) {
            loadDialogMessage(null, 'Erreur', false);
        }
    });
}
function setViewMode() {
    $('#hid_editMode').val('0');
    $.ajax({
        url: $('#hid_urlActionEditMode').val() + '&state=0',
        dataType: "html",
        type: "POST",
        async: false,
        success: function (data) {
            $('#ToolbarActionGlobal .k-edit-mode').removeClass('k-img_on');
            loadHtmlFunction();
            $('#ToolbarActionGlobal .k-edit-mode img').attr('src', $('#ToolbarActionGlobal .k-edit-mode img').attr('src').replace('/on/', '/off/'));
            $('#div_nav_fleche').show();
            $('.edit_mode').fadeOut(function () {
                $('.view_mode').fadeIn(function () {
                    if ($('.view_mode .templateDetailBottom').length > 0) {
                        $('.view_mode .templateDetailBottom').show();
                    }
                    if ($(this).find(".k-grid-autobind").length > 0) {
                        $(this).find(".k-grid-autobind").each(function () {
                            $(this).data("kendoGrid").dataSource.read()
                            $(this).removeClass('k-grid-autobind');
                        });
                    }
                    $(window).trigger('resize');
                });
            });
            $(window).trigger('resize');
        }, error: function (xhr, status, error) {
            loadDialogMessage(null, 'Erreur', false);
        }
    });
}
/***** fin form *****/
/***** telerik *****/
/*** grid ***/
function onDataBoundGridDetailBottom(grid) {
    var tr1 = grid.tbody.find("tr.k-master-row").first();
    if (tr1.length > 0) {
        grid.expandRow(grid.tbody.find("tr.k-master-row"));
        tr1.addClass('k-state-selected');
        var dataHtml = tr1.next().find('.div_detail').html().replace(/&amp;#/g, '&#');
        var idDetail = tr1.next().find('.div_detail').attr('id').replace('div_detail', '');
        tr1.next().find('.div_detail').empty();
        tr1.closest('.mode').find('.templateDetailBottom').html(dataHtml).attr('id', 'templateDetailBottom' + idDetail).show();
        if ($('#templateDetailBottom' + idDetail).find('.k-grid-autobind-detail').length > 0) {
            $('#templateDetailBottom' + idDetail).find('.k-grid-autobind-detail').each(function () {
                var $grid2 = $(this);
                window.setTimeout(function () {
                    $grid2.data("kendoGrid").dataSource.read()
                    $grid2.removeClass('k-grid-autobind-detail').addClass('k-grid-databound');
                }, 100);
            });
        }
        else if ($('#templateDetailBottom' + idDetail).find('.k-grid-databound').length > 0) {
            $('#templateDetailBottom' + idDetail).find('.k-grid-databound').each(function () {
                var $grid2 = $(this);
                window.setTimeout(function () {
                    onDataBoundGridStandard($grid2.data("kendoGrid"));
                }, 100);
            });
        }
        $('#templateDetailBottom' + idDetail + ' .datepicker').each(function () {
            $(this).removeClass('k-textbox').kendoDatePicker({
                format: "dd/MM/yyyy"
            });
        });
    }
    onDataBoundGridStandard(grid);
}
function onDataBoundGridStandard(arg) {	
    var grid = this;
    if (typeof arg.sender === typeof undefined && typeof arg == 'object')
        grid = arg;
    grid.element.removeClass('k-grid_trigger');
    if (grid.element.find('.k_table_scroll').length == 0)
        $(grid.table).wrap('<div class="k_table_scroll"></div>');
    grid.element.find(".td_action").each(function () {
        if ($(this).find('.k-toolbar-line').hasClass('k-toolbar')) {
            $(this).find('.k-toolbar').data("kendoToolBar").destroy();
            $(this).find('.k-toolbar').empty();
        }
        eval($(this).children("script").last().html());
        $(this).find('.k-toolbar-line:visible').each(function () {
            $(this).data("kendoToolBar").resize();
            $(this).find('.k-button-icon').each(function () {
                $(this).unbind('click.img_action').bind('click.img_action', function () {
                    grid.element.addClass('k-grid_img_action');
                });
            });
        });
    });
    grid.element.find(".k-ellipsis").each(function () {
        var $elips = $(this).get(0);
        if ($elips.scrollWidth <= $(this).width())
            $(this).removeClass('k-ellipsis').removeAttr('title');
    });
    if (grid.element.hasClass('k-grid_window')) {
        var kwindow = grid.element.closest('.k-window-content').data("kendoWindow");
        if(kwindow.element.find('.main_window').length>0){
            kwindow.element.find('.main_window').show();
        }
        kwindow.center();
    }
    grid.element.removeClass('k-grid_loaded');
    if(grid.dataSource.total() > 0)
        grid.element.addClass('k-grid_loaded');
   /* loadButtonFiche();*/
   /* loadHtmlFunction();*/
}
function saveOptionGrid(arg) {
    var $a_img = arg.target;
    $a_img.unbind('click').bind('click', function (e) {
        e.preventDefault();
        var grid = $a_img.closest('.k-grid').data().kendoGrid;
        var dataSource = grid.dataSource;
        var state = {
            columns: grid.columns,
            page: dataSource.page(),
            pageSize: dataSource.pageSize(),
            sort: dataSource.sort(),
            filter: dataSource.filter(),
            group: dataSource.group()
        };
        var idgrid = $a_img.closest('.k-grid').attr('id');
        $.ajax({
            url: "/Application/Kendo/SaveGridOption",
            type: "POST",
            dataType: 'json',
            beforeSend: function () {
                setAnimationAjax(1);
            },
            complete: function () {
                setAnimationAjax(2);
            },
            data: {
                url: window.location.pathname,
                grid: idgrid,
                dataGrid: JSON.stringify(state)
            }
        });
    });
}
function loadPreferenceUser($grid) {
    var grid = $grid.data("kendoGrid");
    if (grid) {
        var dataSource = grid.dataSource, $divAction = grid.element.find('#ActionGlobale');
        var idgrid = $grid.attr('id'), flag_autobind = false;
        if ($grid.hasClass('k-grid-autobind'))
            flag_autobind = true;
        if ($divAction.find('.k-preference-dataGrid').length > 0) {
            var dataGrid = $divAction.find('.k-preference-dataGrid').val();
            if (dataGrid != "") {
                dataGrid = JSON.parse(dataGrid);
                var options = grid.getOptions();
                options.columns = dataGrid.columns;
                options.dataSource.page = dataGrid.page;
                options.dataSource.pageSize = dataGrid.pageSize;
                options.dataSource.sort = dataGrid.sort;
                options.dataSource.filter = dataGrid.filter;
                options.dataSource.group = dataGrid.group;
                options.dataSource.total = 1;
                var toolbarHtml = $("#toolbarTemplate_" + idgrid).html() + '<script>jQuery(function(){ loadTitle();toggleImageHover(); });';
                options.toolbar = [
                    { template: toolbarHtml }
                ];
                grid.destroy();
                var grid = $grid.empty().kendoGrid(options).data("kendoGrid");
                $divAction = grid.element.find('#ActionGlobale'), $grid = grid.element;
                if (flag_autobind)
                    $grid.addClass('k-grid-autobind');
                $grid.find('.k-grid-toolbar').each(function(){
                    if ($(this).find('.k-toolbar-global').length > 0)
                        $(this).removeClass('k-grid-top').addClass('k-grid-top');
                });
                if ($grid.find('.k-grid-header tr').length > 0) {
                    var $tr_col = $grid.find('.k-grid-header tr').eq(0);
                    if ($grid.find('.k-grid-header tr').length > 1) {
                        var $tr_col = $grid.find('.k-grid-header tr').eq(1);
                        $grid.find('.k-grid-header tr').eq(0).find('.k-header[role=columnheader]').removeClass('k-header-group').addClass('k-header-group');
                    }
                    var nb_col = $tr_col.find('th.k-header[role=columnheader]').length;
                    if ($grid.find('tbody[role=rowgroup]').is(':empty'))
                        $grid.find('tbody[role=rowgroup]').html('<tr class="k-no-data"><td colspan="' + nb_col  + '" style="display: none;"></td></tr>');
                } 
                if ($grid.find('.k-grid-pager ul.k-pager-numbers').length > 0) {
                    if ($grid.find('.k-grid-pager ul.k-pager-numbers').is(':empty'))
                        $grid.find('.k-grid-pager ul.k-pager-numbers').html('<li><span class="k-state-selected" data-page="1">1</span></li>');
                }
                if ($grid.find('.k-grid-pager .k-pager-input input.k-textbox').length > 0) {
                    if ($grid.find('.k-grid-pager .k-pager-input input.k-textbox').val() == '')
                        $grid.find('.k-grid-pager .k-pager-input input.k-textbox').attr('type', 'text').attr('value', 1);
                }
                if ($grid.find('.k-grid-pager .k-pager-info').length > 0) {
                    if ($grid.find('.k-grid-pager .k-pager-info').is(':empty'))
                        $grid.find('.k-grid-pager .k-pager-info').text(options.pageable.messages.empty);
                }
                if ($('#scriptLoadGrid_' + idgrid).length > 0)
                    eval($('#scriptLoadGrid_' + idgrid).html());
                $divAction.find('.k-preference-dataGrid').remove();
            }
        }
        if ($divAction.find('.k-preference-dataForm').length > 0 || $divAction.find('.k-preference_global-dataForm').length > 0) {
            if ($divAction.find('.k-preference-dataForm').length > 0 && $divAction.find('.k-preference-dataForm').val() != '')
                var dataForm = $divAction.find('.k-preference-dataForm').val();
            else
                var dataForm = $divAction.find('.k-preference_global-dataForm').val();
            if (dataForm != "") {
                dataForm = JSON.parse(dataForm);
                var $form = $('.k-window_' + idgrid + ' form');
                if ($form.length > 0) {
                    $form.loadJSON(getUrlVars($.param(dataForm)));
                    if ($divAction.find('.k-preference-dataForm').length > 0 && $divAction.find('.k-preference-dataForm').val() != '' && !flag_autobind && !$grid.hasClass('k-grid_noload'))
                    {
                        grid.element.addClass('k-grid_trigger');
                        $form.trigger('submit');
                    }
                }
            }
            if ($divAction.find('.k-preference-dataForm').length > 0)
                $divAction.find('.k-preference-dataForm').remove();
        }
        if (flag_autobind) {
            grid.dataSource.read();
        }
    }
}
function getFormDataForGrid(arg) {   
    var $form = $('#RechercheAvancee form, .param_global_form, .div_param_global_form :input');
    if (!$.isPlainObject(arg) && arg != null)
        $form = $('.param_global_form, ' + arg);
    var unindexed_array = $form.serializeArray();   
    var indexed_array = {};
    $.map(unindexed_array, function (n, i) {
        var val = n['value'];
        if ($('#' + n['name']).length > 0) {
            if ($('#' + n['name']).is('input') || $('#' + n['name']).is('textarea')) {
                if ($('#' + n['name']).is('input')) {
                    if ($('#' + n['name']).attr('type') == 'checkbox') {
                        if ($('#' + n['name']).is(':checked') == true)
                            val = true;
                        else
                            val = false;
                    }
                }
                indexed_array[n['name']] = val;
            } else if ($('#' + n['name']).is('select')) {
                if (n['name'] in indexed_array)
                    indexed_array[n['name']] += ',' + n['value'];
                else
                    indexed_array[n['name']] = n['value'];
            }
        } else {
            if ($('input[type=radio][name=' + n['name'] + ']').length > 0) {
                if ($('input[type=radio][name=' + n['name'] + ']:checked').length > 0)
                    val = $('input[type=radio][name=' + n['name'] + ']:checked').val();
                else
                    val = '';
            }
            indexed_array[n['name']] = val;
        }
    });
    return indexed_array;
}
var idtr_selected_detail_row = '';
function loadClickDetail(grid) {
    window.setTimeout(function () {
        grid.select().each(function () {
            var $tr_select = $(this);
            var flagOk = true;
            if (grid.element.hasClass('k-grid_no_close_detail')) {
                if (idtr_selected_detail_row == $tr_select.attr('data-uid')) {
                    flagOk = false;
                }
            }
            if (flagOk) {
                if (grid.tbody.find('.div_detail:visible').length > 0) {
                    grid.tbody.find('.div_detail:visible').slideUp(400, 'swing', function () {
                        $(this).hide();
                        grid.collapseRow($(this).closest(".k-detail-row").prev());
                        slideDetailGrid(grid, $tr_select);
                    });
                } else {
                    slideDetailGrid(grid, $tr_select);
                }
            }
        });
    }, 100);
}
function slideDetailGrid(grid, $elm) {
    var isAction = false;
    if (!$elm.hasClass('k-tr-open')) {
        if (typeof event !== typeof undefined) {
            var eventTarget = (event.target) ? $(event.target) : $(event.srcElement);
            if (eventTarget.hasClass('td_action') || eventTarget.closest('td').hasClass('td_action'))
                isAction = true;
        }
        if (grid.element.hasClass('k-grid_img_action'))
            isAction = true;
        if (isAction) {
            return;
        }
    }
    if (idtr_selected_detail_row != $elm.attr('data-uid') || (!$elm.hasClass('k-tr-open') && $elm.next().is('tr.k-detail-row'))) {
        grid.expandRow(grid.tbody.find("tr.k-state-selected"));
        $elm.next("tr.k-detail-row").find(".div_detail").slideDown();
        idtr_selected_detail_row = $elm.attr('data-uid');
        $elm.removeClass('k-state-selected').addClass('k-state-selected').removeClass('k-tr-open').addClass('k-tr-open');
    } else {
        $elm.removeClass('k-state-selected').removeClass('k-tr-open');
    }
}
function loadDetailGridBottom($grid, callback) {
    $grid.each(function () {
        var grid = $(this).data("kendoGrid");
        grid.select().each(function () {
            $(this).closest('.mode').find('.templateDetailBottom').hide();
            if ($(this).closest('.mode').find('.templateDetailBottom .k_table_scroll').length > 0) {
                $(this).closest('.mode').find('.templateDetailBottom .k_table_scroll>table').each(function () {
                    $(this).unwrap();
                });
            }
            $(this).closest('.mode').find('.templateDetailBottom .datepicker').each(function () {
                if($(this).parent().is( "span" )){
                    $(this).unwrap().unwrap();
                    $(this).closest('td').find('span').remove();
                }
                var datepicker = $(this).data("kendoDatePicker");
                if (datepicker) {
                    datepicker.destroy();
                }
            });
            var currentDataHtml = $(this).closest('.mode').find('.templateDetailBottom').html();
            var currentIdDetail = $(this).closest('.mode').find('.templateDetailBottom').attr('id').replace('templateDetailBottom', '');
            var $tr_select = $(this);
            $tr_select.closest('.mode').find('.templateDetailBottom').empty();
            $('#div_detail' + currentIdDetail).html(currentDataHtml);
            if ($tr_select.next().is('tr.k-detail-row')) {
                var dataHtml = $tr_select.next().find('.div_detail').html().replace(/&amp;#/g, '&#');
                var idDetail = $tr_select.next().find('.div_detail').attr('id').replace('div_detail', '');
                $tr_select.next().find('.div_detail').empty();
                $tr_select.closest('.mode').find('.templateDetailBottom').html(dataHtml).attr('id', 'templateDetailBottom' + idDetail).show();
                if ($('.mode:visible #templateDetailBottom' + idDetail).find('.k-grid-autobind-detail').length > 0) {
                    $('.mode:visible #templateDetailBottom' + idDetail).find('.k-grid-autobind-detail').each(function () {
                        var $grid2 = $(this);
                        window.setTimeout(function () {
                            $grid2.data("kendoGrid").dataSource.read();
                            $grid2.removeClass('k-grid-autobind-detail').addClass('k-grid-databound');
                        }, 100);
                    });
                }
                if ($('.mode:visible #templateDetailBottom' + idDetail).find('.k-grid-databound').length > 0) {
                    $('.mode:visible #templateDetailBottom' + idDetail).find('.k-grid-databound').each(function () {
                        var $grid2 = $(this);
                        onDataBoundGridStandard($grid2.data("kendoGrid"));
                    });
                }
                $('.mode:visible #templateDetailBottom' + idDetail + ' .datepicker').each(function () {
                    $(this).removeClass('k-textbox').removeClass('k-input').kendoDatePicker({
                        format: "dd/MM/yyyy"
                    });
                });
            }
        });
    });
    if (callback != null) {
        eval(callback);
    }
}
function onChangeRowGridAngular(grid, div_parent) {
    onDataBoundGridStandard(grid);
    var other_mode = 'edit_mode', grid_mode1 = 'View', grid_mode2 = 'Edit';
    if (grid.element.closest('.mode').hasClass('edit_mode')) {
        other_mode = 'view_mode';
        grid_mode1 = 'Edit';
        grid_mode2 = 'View';
    }
    
    var id_other_grid = grid.element.attr('id').replace(grid_mode1, grid_mode2);   
    var $tr_other_mode = $('#' + div_parent + ' .' + other_mode + ' #' + id_other_grid + ' .k_table_scroll>table tr[id=' + (grid.select().attr('id')).replace(grid_mode1, grid_mode2) + ']');
    if ($tr_other_mode.length > 0) {
        $('#' + div_parent + ' .' + other_mode + ' #' + id_other_grid + ' tr').removeClass('k-state-selected');
        $tr_other_mode.addClass('k-state-selected');
        if ($('#' + div_parent + ' .' + other_mode + ' #div_detail_' + id_other_grid).length > 0) {
            $('#' + div_parent + ' .' + other_mode + ' #div_detail_' + id_other_grid).show();
        }
    }
}
function onExcelClickGridStandard(e) {
    setAnimationAjax(1);
}
function onExcelDoneGridStandard(e) {
    setAnimationAjax(2);
    var sheet = e.workbook.sheets[0];
    if (sheet.rows[0].type == 'header' && sheet.rows[1].type == 'header') {
        sheet.rows.shift();
        sheet.freezePane.rowSplit = 1;
    }
    for (var rowIndex = 1; rowIndex < sheet.rows.length; rowIndex++) {
        if (rowIndex % 2 == 0) {
            var row = sheet.rows[rowIndex];
            for (var cellIndex = 0; cellIndex < row.cells.length; cellIndex++) {
                row.cells[cellIndex].background = "#ebebeb";
            }
        }
    }
}
function onSubmitRechercherGrid($grid) {
    var grid = $grid.data("kendoGrid");
    var filter = new Array(), $x = $('.form_filter_grid:visible .filterGrid').val();
    if ($x) {
        $.each(grid.columns, function (key, column) {
            if (typeof column.field !== typeof undefined) {
                var typeColumn = "string";
                if (typeof column.type !== typeof undefined) {
                    typeColumn = column.type;
                }
                switch (typeColumn) {
                    case 'number':
                        if (!isNaN(parseInt($x))) {
                            filter.push({ field: column.field, operator: "eq", value: parseInt($x) });
                        }
                        break;
                    default:
                        filter.push({ field: column.field, operator: "contains", value: $x });
                        break;
                }
            }
        });
    }
    grid.dataSource.filter({ logic: "or", filters: filter });
}
function afficheKgridFirstEnum(tab, col) {
    return tab[0][col];
}
function afficheKgridDonneeAnnuaire(jsonobj, identifiant, code) {
    var libelle = '-';
    $.each(jsonobj, function (index, tab) {
        if (tab.Identifiant == identifiant) {
            $.each(tab.Liste, function (i, liste) {
                if (liste.Code == code) {
                    libelle = liste.Libelle;
                }
            });
        }
    });
    return libelle;
}
/*** fin grid ***/
/*** window ***/
function openWindowUI($elm) {
    $elm.data("kendoWindow").open();
}
function onActivateWindowStandard($grid) {
    loadPanelBarRecherche();
    $('#RechercheAvancee form').unbind('submit').bind('submit', function (e) {
        e.preventDefault();
        var paramForm = getFormDataForGrid();
        var idgrid = $grid.attr('id');
        var dataForm = paramForm;
        var idform = $('.k-window_' + idgrid + ' form').attr('id');
        paramForm.url = window.location.pathname;
        paramForm.form = idform;
        paramForm.dataForm = JSON.stringify(dataForm);

        if ($grid.find('.k-grid-pager .k-pager-input input').length > 0) {
            $grid.find('.k-grid-pager .k-pager-input input').val(1);
        }
        var grid = $grid.data("kendoGrid");
        if ($grid.hasClass('k-grid_signalr')) {
            if (!$grid.hasClass('k-grid_trigger')) {
                grid.dataSource.transport.hub.connection.stop();
            }
            grid.dataSource.transport.hub.connection.start().done(function () {
                grid.element.removeClass('k-grid_trigger');
                grid.dataSource.transport.parameterMap = function () {
                    return paramForm;
                };
                grid.dataSource.page(1);
                grid.dataSource.bind();
                if ($grid.hasClass('k-grid_loaded')) {
                    grid.dataSource.read();
                }
            });
        } else {
            grid.dataSource.transport.options.read.url = $('#RechercheAvancee form').attr('action');
            grid.dataSource.transport.options.read.data = paramForm;
            grid.dataSource.page(1);
        }
    });
}
var buttonConfirm = '<div class="div_confirm_window"><button class="b-confirm k-button k-primary">Oui</button><button class="b-cancel k-button">Non</button></div>';
var buttonOk = '<div class="div_confirm_window"><button class="b-cancel k-button k-primary">OK</button></div>';
function loadDialogMessage(texte, titre, isConfirm, callbackConfirm, callbackCancel) {
    $('#div_dialog_alert').empty();
    if (texte == null)
        texte = '<p>Une erreur est survenue.</p>';
    if (isConfirm == true)
        texte += buttonConfirm;
    else
        texte += buttonOk;
    var kendoWindow = $("#div_dialog_alert").data("kendoWindow");
    if (!kendoWindow) {
        kendoWindow = $("#div_dialog_alert").kendoWindow({
            title: titre,
            resizable: false,
            modal: true
        }).data("kendoWindow");
        kendoWindow.content(texte)
    } else {
        kendoWindow.title(titre);
        kendoWindow.content(texte);
        kendoWindow.refresh();
    }
    kendoWindow.center().open();    
    $("#div_dialog_alert").find(".b-confirm,.b-cancel").one('click', function () {       
        if ($(this).hasClass("b-confirm")) {
            callbackConfirm();
        }
        if ($(this).hasClass("b-cancel")) {
            if (typeof callbackCancel !== typeof undefined) {
                callbackCancel();
            }            
        }
        kendoWindow.close();
    }).end()
}
function loadWindowStandard(){
    $('.k-button-window').each(function () {
        var href = $(this).attr('href'), titre = $(this).attr('data-window-title');
        var awidth = ((typeof $(this).attr('data-window-width') !== typeof undefined && $(this).attr('data-window-width') !== false) ? $(this).attr('data-window-width') : '');
        var aheight = ((typeof $(this).attr('data-window-height') !== typeof undefined && $(this).attr('data-window-height') !== false) ? $(this).attr('data-window-height') : '');
        var amaxheight = ((typeof $(this).attr('data-window-maxheight') !== typeof undefined && $(this).attr('data-window-maxheight') !== false) ? $(this).attr('data-window-maxheight') : '');
        var aminheight = ((typeof $(this).attr('data-window-minheight') !== typeof undefined && $(this).attr('data-window-minheight') !== false) ? $(this).attr('data-window-minheight') : '');
        $(this).unbind('click').bind('click', function (e) {
            e.preventDefault();
            var kwindow = $("#div_window_standard"), kwidth = 'auto', kheight = 'auto', kmaxheight = 'auto', kminheight = 'auto';
            if (awidth != '') kwidth = awidth;
            if (aheight != '') kheight = aheight;
            if (amaxheight != '') kmaxheight = amaxheight;
            if (aminheight != '') kminheight = aminheight;
            var kendoWindow = $("#div_window_standard").kendoWindow({
                title: titre,
                resizable: false,
                modal: true,
                content: href,
                width: kwidth,
                height: kheight,
                maxHeight: kmaxheight,
                minHeight: kminheight,
                activate: function () {
                },
                refresh: function () {
                    this.center();
                    this.element.find('.topTop').remove();
                    $('<div/>').addClass('toTop').appendTo(this.element);
                    loadToTop();
                },
                deactivate: function () {
                    this.destroy();
                    $('<div/>').attr('id', 'div_window_standard').appendTo($('#corps'));
                }
            }).data("kendoWindow");
            kendoWindow.center().open();
        });
    });
}
/*** fin window ***/
/*** button ***/
function onClickResetFormulaire() {
    var flag_grid_preference_global = false;
    var $window = this.element.closest('.k-window');
    if ($window) {
        var all_class = $window.attr('class');
        if (all_class.indexOf(' ') != -1) {
            var tab_all_class = all_class.split(' ');
            if (tab_all_class.length) {
                for (i = 0; i < tab_all_class.length; i++) {
                    if (tab_all_class[i].substr(0, 13) == 'k-window_grid') {
                        var class_grid = tab_all_class[i].replace('k-window_', '');
                        var $grid = $('#' + class_grid);
                        if ($grid.find('.k-preference_global-dataForm').length > 0) {
                            if ($grid.find('.k-preference_global-dataForm').val() != '') {
                                loadPreferenceUser($grid);
                                flag_grid_preference_global = true;
                            }
                        }
                    }
                }
            }
        }
    }
    if (flag_grid_preference_global == false)
        this.element.closest('form').clearForm();
}
/*** fin button ***/
/*** sortable ***/
function onStartSortableTabStrip(e) {
    var tabstrip = e.item.closest('.k-tabstrip').data("kendoTabStrip");
    tabstrip.activateTab(e.item);
}

function onChangeSortableTabStrip(e) {
    var tabstrip = e.item.closest('.k-tabstrip').data("kendoTabStrip"),
        reference = tabstrip.tabGroup.children().eq(e.newIndex);

    if (e.oldIndex < e.newIndex) {
        tabstrip.insertAfter(e.item, reference);
    } else {
        tabstrip.insertBefore(e.item, reference);
    }
}
/*** fin sortable ***/
/*** tabstrip ***/
function activateTabStripMenu() {
    var hashUrl = location.hash, hashOnglet = '';
    if (hashUrl.indexOf('_') > -1) {
        var tabHash = Array();
        tabHash = hashUrl.split('_');
        for (iHash = 0; iHash < tabHash.length; iHash++) {
            if (tabHash[iHash].indexOf('ong') > -1) {
                hashOnglet = tabHash[iHash];
            }
        }
    } else
        hashOnglet = hashUrl;
    var tabOnglet = (hashOnglet.replace('ong', '').replace('#', '')).split('-');
    if ($(".nav_onglet").length > 0) {
        var isLoadTS1 = false;
        if (location.hash != '' && location.hash != '#') {
            var hashUrl = location.hash, nbId = 1;
            if ((hashUrl.match(/ong[0-9]-[0-9]/g) || []).length > 0) {
                nbId = parseInt(tabOnglet[0]) + 1;
                $(".nav_onglet").data("kendoTabStrip").activateTab($('#li-onglet-' + nbId));
                isLoadTS1 = true;
            } else if ((hashUrl.match(/ong[0-9]/g) || []).length > 0) {
                nbId = parseInt(hashUrl.replace('ong', '').replace('#', '')) + 1;
                $(".nav_onglet").data("kendoTabStrip").activateTab($('#li-onglet-' + nbId));
                isLoadTS1 = true;
            }
        }
        if (isLoadTS1 == false)
            $(".nav_onglet").data("kendoTabStrip").activateTab($('#li-onglet-1'));
    }
}
function onSelectTabStripMenu(e) {
    var itemSel = e.item, listOnglet = $(itemSel.closest('.k-tabstrip-items')).find('li');
    var hashUrl = '#', $parent = $(itemSel.closest('.k-tabstrip-items')).parent(), isLeft = false;
    if ($parent.hasClass('k-tabstrip-left'))
        isLeft = true;
    if (location.hash != '' && location.hash != '#') {
        hashUrl = location.hash;
        if (isLeft == false) {
            if ((hashUrl.match(/ong[0-9]-[0-9]/g) || []).length > 0) {
                hashUrl = hashUrl.replace(/ong[0-9]-[0-9]/g, '');
            }
            else {
                hashUrl = hashUrl.replace(/ong[0-9]/g, '');
            }
            if (hashUrl != '#' && hashUrl.slice(-1) != '_')
                hashUrl += '_';
            hashUrl += 'ong';
        }
        else {
            if ((hashUrl.match(/ong[0-9]-[0-9]/g) || []).length > 0) {
                var ong_niv1 = hashUrl.match(/ong[0-9]/g);
                hashUrl = hashUrl.replace(/ong(\d+)-(\d+)/g, 'ong' + ong_niv1[0].replace('ong', '') + '-');
            }
            else
                hashUrl = hashUrl + '-';
        }
    } else
        hashUrl += 'ong';
    location.hash = hashUrl + $(listOnglet).index($(itemSel));
}
function onSelectTabStripMenuOnglet(e) {
    var oldItem = $(e.item).parent().find('li.k-item.k-state-active');
    var oldNbId = oldItem.attr('id').replace(regInt, '');
    var oldContentElement = $('#onglet-' + oldNbId);
    if (oldContentElement.length > 0) {
        kendo.destroy(oldContentElement);
        oldContentElement.empty();
        if ($('.k-widget_onglet-' + oldNbId).length > 0) {
            $('.k-widget_onglet-' + oldNbId).each(function () {
                kendo.destroy($(this));
            });
            $('.k-widget_onglet-' + oldNbId).remove();
        }
    }
}
function setClassWindowOnglet(tabElt) {
    var kTabStrip = $('#onglet').data("kendoTabStrip");
    if(typeof kTabStrip !== typeof undefined){
        var currentItem = kTabStrip.select();
        var nbId = currentItem.attr('id').replace(regInt, '');
        for (var i = 0; i < tabElt.length; i++) {
            if (typeof tabElt[i] !== typeof undefined) {
                var $kWindow = tabElt[i].closest('.k-window');
                if ($kWindow.length > 0) {
                    $kWindow.removeClass('k-widget_onglet-' + nbId).addClass('k-widget_onglet-' + nbId);
                }
            }
        }
    }
}
function onContentLoadTabStripMenu(e) {
    var hashUrl = location.hash, tabOnglet = (hashUrl.replace('ong', '').replace('#', '')).split('-');
    if ($('#' + $(e.item).attr('aria-controls') + ' .k-tabstrip').length > 0) {
        var menuActive = 0;
        if (!isNaN(parseInt(tabOnglet[1])))
            menuActive = parseInt(tabOnglet[1]);
        $('#' + $(e.item).attr('aria-controls') + ' .k-tabstrip').data("kendoTabStrip").select(menuActive);
    }
    loadHtmlFunction();
}
function onContentLoadTabStripStandard(e) {
    var editMode = parseInt($('#hid_editMode').val()), classDisplay = 'view_mode';
    if (editMode == 1)
        classDisplay = 'edit_mode';
    $('.' + classDisplay).fadeIn(function () {
        loadHtmlFunction();
        if ($(this).find(".k-grid-autobind").length > 0)
        {
            $(this).find(".k-grid-autobind").each(function() {
                $(this).data("kendoGrid").dataSource.read()
                $(this).removeClass('k-grid-autobind');
            });
        }
    });
}
function onActivateTabStripMenuOnglet(e) {
    if ($(e.contentElement).find('.k-chart').length > 0) {
        window.setTimeout(function () {
            $(e.contentElement).find('.k-chart').each(function () {
                var chart = $(this).data("kendoChart")
                chart.refresh();
            });
        }, 200);
        $(window).resize(function () {
            $('.k-chart').each(function () {
                var chartRz = $(this).data("kendoChart")
                chartRz.refresh();
            });
        });
    }
    if ($(e.contentElement).find('.gridster').length > 0) {
        loadGridster();
    }
}
/*** fin tabstrip ***/
/***** fin telerik *****/
/***** synthese *****/
var widthContainerWidget = 0, $gridster;
function loadGridster() {
    var nbItemLine = 1, objRow = new Object();
    $('.gridster').css('visibility', 'hidden');
    $(".gridster li").each(function () {
        if (typeof objRow[parseInt($(this).attr('data-row'))] === typeof undefined) {
            objRow[parseInt($(this).attr('data-row'))] = 0;
        }
        objRow[parseInt($(this).attr('data-row'))] += parseInt($(this).attr('data-sizex'));
    });
    for (keyRow in objRow) {
        nbItemLine = (objRow[keyRow] > nbItemLine) ? objRow[keyRow] : nbItemLine;
    }
    if (widthContainerWidget == 0) {
        widthContainerWidget = $('#corps main').width() + 10;
    }
    $(".gridster").width(widthContainerWidget);
    var gridsterWidth = (widthContainerWidget - (20 * nbItemLine)) / nbItemLine, gridsterHeight = 125, gridsterMaxHeight = 150;
    $('.gridster li.encart').each(function () {
        $(this).css({
            visibility: 'hidden'
        });
        var heightEnc = parseFloat($(this).prop('scrollHeight'));
        if (heightEnc > gridsterHeight && heightEnc <= gridsterMaxHeight)
            gridsterHeight = heightEnc + 5;
        $(this).css({
            visibility: 'visible',
        });
    });
    $gridster = $(".gridster > ul").gridster({
        widget_margins: [10, 10],
        widget_base_dimensions: [gridsterWidth, gridsterHeight],
        min_cols: 1,
        draggable: {
            handle: 'h2.titre_encart .handle_widget',
            stop: function (event, ui) {
                saveWidgetGrid();
            }
        },
        resize: {
            enabled: true,
            stop: function (event, ui) {
                loadScrollWidget();
                $(window).trigger('resize');
                saveWidgetGrid();
            }
        },
        serialize_params: function ($w, wgd) {
            return {
                id: $($w).attr('id').replace('encart', ''),
                col: wgd.col,
                row: wgd.row,
                size_x: wgd.size_x,
                size_y: wgd.size_y
            };
        }
    }).data('gridster');
    loadWidget();
    $('.gridster').css('visibility', 'visible');
}
function loadWidget() {
    loadCloseWidget();
    loadWidgetPlus();
    loadScrollWidget();
}
function loadScrollWidget() {
    $('.gridster li.encart').each(function () {
        var heightLi = $(this).outerHeight();
        if (parseInt($(this).attr('data-sizey')) < 4) {
            $(this).find('.relative').height(heightLi * 0.86);  // => padding top et bottom
        } else {
            $(this).find('.relative').height(heightLi * 0.96);  // => padding top et bottom
        }
        $(this).find('.tojq_scrollbar').scrollbar({
            ignoreMobile: true
        });
    });
}
function loadCloseWidget() {
    $('body').on('mouseenter', '.encart h2.titre_encart', function (e) {
        $(this).stop(true).find('.close').fadeIn(200);
    }).on('mouseleave', '.encart h2.titre_encart', function () {
        $(this).stop(true).find('.close').fadeOut(200);
    });
    $('body').on('click', '.encart h2.titre_encart .close', function (e) {
        var txtTitle = $(this).parent().text(), idEncart = $(this).closest('.encart').attr('id'), classEncart = $(this).closest('.encart').attr('class');
        $gridster.remove_widget($(this).closest('li'), function () {
            $('#btn_widget_plus').fadeIn();
            $('#widget_plus .div_marge').append('<div class="encart widget" title="Ajouter" id="widget_' + idEncart + '"><input type="hidden" name="class_' + idEncart + '" id="class_' + idEncart + '" value="' + classEncart + '" /><h4>' + txtTitle + '</h4></div>');
            //resize_contenu();
            loadTitle();
            saveWidgetGrid();
        });
    });
}
function loadWidgetPlus() {
    if ($('#widget_plus .div_marge .encart').length > 0)
        $('#btn_widget_plus').fadeIn();
    $('body').off('click', '#widget_plus .close').off('click', '#btn_widget_plus .backbutton').off('click', '#widget_plus .div_marge .bgencart');
    $('body').on('click', '#widget_plus .close', function (e) {
        $('#widget_plus').animate({
            bottom: "-260px"
        }, 500, function () {
            if ($('#widget_plus .div_marge .encart').length > 0)
                $('#btn_widget_plus').fadeIn();
        });
    });
    $('body').off('click', '#btn_widget_plus .k-button').on('click', '#btn_widget_plus .k-button', function (e) {
        $('#widget_plus').show();
        $('#widget_plus').animate({
            bottom: "0px"
        }, 500, function () {
            $('#btn_widget_plus').hide();
        });
    });
    $('body').off('click', '#widget_plus .div_marge .encart').on('click', '#widget_plus .div_marge .encart', function (e) {
        var idWidget = $(this).attr('id').replace('widget_', ''), $widget = $(this);
        $.ajax({
            url: $('#hid_urlSyntheseWidget').val(),
            dataType: "json",
            type: "POST",
            data: ({ widgetId: idWidget }),
            beforeSend: function () {
                setAnimationAjax(1);
            },
            complete: function () {
                setAnimationAjax(0);
            },
            success: function (data) {
                var htmlResult = data.html, widgetResult = $.parseJSON(data.widget);
                var pos = $gridster.next_position(widgetResult.dataSizeX, widgetResult.dataSizeY);
                var classWidget = $widget.find('#class_' + idWidget).val();
                $gridster.add_widget('<li class="' + classWidget + '" id="' + idWidget + '">' + htmlResult + '</li>', pos.size_x, pos.size_y, pos.col, pos.row);
                $widget.remove();
                saveWidgetGrid();
                loadScrollWidget();
            }, error: function (xhr, status, error) {
                loadDialogMessage(null, 'Erreur', false);
            }
        });
    });
}
function saveWidgetGrid() {
    var tabData = JSON.stringify($gridster.serialize());
    $.post($('#hid_urlSyntheseWidgetSave').val(), { name: $('#hid_nameSyntheseWidget').val(), widget: tabData });
}
/***** fin synthese *****/