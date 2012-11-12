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

  first_slot = 1;

  slot_number = 1;

  XanderClient.prototype.showVariantBar = function() {
    console.log("Show variant bar");
    $('body').prepend("<div id='__variants' style='padding-left: 10%; width: 80%; background: black; color: white; border-bottom: 5px solid #CCC'>\n</div>");
    $("*[data-variant]").parent().each(function(i, x) {
      var options, variants;
      variants = $(x).find("> [data-variant]");
      options = "";
      variants.each(function(i, y) {
        return options += " <button onclick='xander.showVariant(\"" + ($(x).attr('id')) + "\",\"" + ($(y).attr('data-variant')) + "\"); return false'>" + ($(y).attr('data-variant')) + "</button>";
      });
      return $('#__variants').append("<div><span>" + ($(x).attr('id')) + "</span><span>" + options + "</span></div>");
    });
    return $("*[data-css-variants]").each(function(i, x) {
      var options, variants;
      variants = $(x).attr('data-css-variants').split(' ');
      options = "";
      $(variants).each(function(i, y) {
        return options += " <button onclick='xander.showCssVariant(\"" + ($(x).attr('id')) + "\",\"" + y + "\"); return false'>" + y + "</button>";
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

  XanderClient.prototype.showCssVariant = function(id, klass) {
    var el, variants;
    el = $("#" + id);
    variants = el.attr('data-css-variants').split(' ');
    $(variants).each(function(i, y) {
      return el.removeClass(y);
    });
    return el.addClass(klass);
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
      var option, options;
      options = $(x).attr('data-css-variants').split(' ');
      option = options[parseInt(Math.random() * options.length)];
      $(x).addClass(option);
      $(x).show().attr('data-variant-slot', slot_number);
      $(x).show().attr('data-variant-chosen', option);
      return slot_number += 1;
    });
  };

  XanderClient.prototype.callAnalytics = function() {
    return $("*[data-variant-slot]").each(function(i, x) {
      var chosen, title;
      chosen = $(x).attr('data-variant-chosen');
      slot_number = $(x).attr('data-variant-slot');
      title = $(x).attr('id' || ("slot_" + slot_number));
      return _gaq.push(['_setCustomVar', parseInt(slot_number), title, chosen, 2]);
    });
  };

  XanderClient.prototype.reroll = function($target) {
    var $chosen, chosen, i, variant, variants, _i, _len;
    if ($target) {
      chosen = $target.attr("data-variant-chosen");
      variants = $target.find("> [data-variant]");
      if (variants.length > 1) {
        variants.hide();
        for (i = _i = 0, _len = variants.length; _i < _len; i = ++_i) {
          variant = variants[i];
          if ($(variant).attr('data-variant') === chosen) {
            variants.splice(i, 1);
            break;
          }
        }
        $chosen = $(variants[parseInt(Math.random() * variants.length)]).show();
        return $target.attr('data-variant-chosen', $chosen.attr('data-variant'));
      }
    } else {
      this.chooseVariant();
      return this.chooseCssVariant();
    }
  };

  XanderClient.prototype.variant = function() {
    var results;
    results = {};
    $("*[data-variant-slot]").each(function(i, x) {
      var chosen, title;
      chosen = $(x).attr('data-variant-chosen');
      title = $(x).attr('id' || ("slot_" + slot_number));
      return results[title] = chosen;
    });
    return results;
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
  if (getParameterByName('showVariants') !== 'true') {
    return xander.callAnalytics();
  }
});

window.xander = xander;
