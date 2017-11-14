// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "phoenix_html";
import "jquery";

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

import commentReport from "./reportGenerator.js";

jQuery(function($) {
    var $bodyEl = $('body'),
        $sidedrawerEl = $('#sidedrawer');

    var reportButton = $("#commentReport");
    var reportData = reportButton.attr("data-comments");
    reportButton.click(commentReport);
    console.log("test");
    console.log(reportButton);
    console.log(reportData);


    // ==========================================================================
    // Toggle Sidedrawer
    // ==========================================================================
    function showSidedrawer() {
        // show overlay
        let options = {
            onclose: function() {
                $sidedrawerEl
                    .removeClass('active')
                    .appendTo(document.body);
            }
        };

        let $overlayEl = $(mui.overlay('on', options));

        // show element
        $sidedrawerEl.appendTo($overlayEl);
        setTimeout(function() {
            $sidedrawerEl.addClass('active');
        }, 20);
    }


    function hideSidedrawer() {
        $bodyEl.toggleClass('hide-sidedrawer');
    }


    $('.js-show-sidedrawer').on('click', showSidedrawer);
    $('.js-hide-sidedrawer').on('click', hideSidedrawer);


    // ==========================================================================
    // Animate menu
    // ==========================================================================
    let $titleEls = $('strong', $sidedrawerEl);

    $titleEls
        .next()
        .hide();

    $titleEls.on('click', function() {
        $(this).next().slideToggle(200);
    });
});

