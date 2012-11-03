// Generated by CoffeeScript 1.3.3
var XanderClient, getParameterByName, xander;

getParameterByName = function(name) {
  var regex, regexS, results;
  name = name.replace(/[\[]/, "\\\[").replace(/[\]]/, "\\\]");
  regexS = "[\\?&]" + name + "=([^&#]*)";
  regex = new RegExp(regexS);
  results = regex.exec(window.location.search);
  if (results === null) {
    return "";
  }
  return decodeURIComponent(results[1].replace(/\+/g, " "));
};

XanderClient = (function() {
  var first_slot, slot_number;

  function XanderClient() {}

  first_slot = 0;

  slot_number = 0;

  XanderClient.prototype.showVariantBar = function() {
    console.log("Show variant bar");
    $('body').prepend("<div id='__variants' style='width: 100%; background: black; color: white; border-bottom: 5px solid #CCC'>\n</div>");
    return $("*[data-variant]").parent().each(function(i, x) {
      var options, variants;
      variants = $(x).find("> [data-variant]");
      options = "";
      variants.each(function(i, y) {
        return options += " <a onclick='xander.showVariant(\"" + ($(x).attr('id')) + "\",\"" + ($(y).attr('data-variant')) + "\")'>" + ($(y).attr('data-variant')) + "</a>";
      });
      return $('#__variants').append("<div><span>" + ($(x).attr('id')) + "</span><span>" + options + "</span></div>");
    });
  };

  XanderClient.prototype.showVariant = function(name, subname) {
    var variant, variants;
    variants = $("#" + name);
    $(variants).find("> [data-variant]").hide();
    return variant = $(variants).find("> [data-variant='" + subname + "']").show();
  };

  XanderClient.prototype.chooseVariant = function() {
    var all_choices;
    all_choices = $("*[data-variant]").parent();
    all_choices.each(function(i, x) {
      var chosen, variants;
      variants = $(x).find("> [data-variant]");
      variants.hide();
      $(x).attr('data-variant-slot', slot_number);
      chosen = $(variants[parseInt(Math.random() * variants.length)]).show();
      $(x).attr('data-variant-chosen', chosen.attr('data-variant'));
      return slot_number += 1;
    });
    if (all_choices.length > 5) {
      return typeof console !== "undefined" && console !== null ? console.log("You have too many variants to track!  Google Analytics limits the number of custom variable slots to 5.") : void 0;
    }
  };

  XanderClient.prototype.chooseCssVariant = function() {
    var all_choices;
    all_choices = $("*[data-css-variants]");
    return all_choices.each(function(i, x) {
      var options;
      options = $(x).attr('data-css-variants').split(' ');
      $(x).addClass(options[parseInt(Math.random() * options.length)]);
      $(x).show().attr('data-variant-slot', slot_number);
      return slot_number += 1;
    });
  };

  XanderClient.prototype.callAnalytics = function() {
    return $("*[data-variant-slot]").each(function(i, x) {
      var chosen, title;
      chosen = $(x).attr('data-variant-chosen');
      slot_number = $(x).attr('data-variant-slot');
      title = $(x).attr('id' || ("slot_" + slot_number));
      return _gaq.push(['_setCustomVar', slot_number, title, chosen, 2]);
    });
  };

  return XanderClient;

})();

xander = new XanderClient();

$(function() {
  if (getParameterByName('showVariants') === 'true') {
    xander.showVariantBar();
  }
  xander.slot_number = xander.first_slot;
  xander.chooseVariant();
  xander.chooseCssVariant();
  return xander.callAnalytics();
});

window.xander = xander;
