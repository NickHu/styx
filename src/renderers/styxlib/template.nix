# Template functions
lib: styxlib: with lib; rec {
  processBlocks = blocks: {
    content = mapTemplate (b: b.content) blocks;
    extraJS = flatten (catAttrs "extraJS" blocks);
    extraCSS = flatten (catAttrs "extraCSS" blocks);
  };

  htmlAttr =
    attrName: value:
    let
      value' = if isList value then concatStringsSep " " value else value;
    in
    ''${attrName}="${value'}"'';

  htmlAttrs = s: concatStringsSep " " (mapAttrsToList htmlAttr s);

  escapeHTML = replaceStrings [ "<" ">" "\"" "&" ] [ "&lt;" "&gt;" "&quot;" "&amp;" ];

  normalTemplate =
    f: p:
    let
      content = if isFunction f then f p else f;
      contentSet = if isAttrs content then content else { inherit content; };
    in
    p // contentSet;

  mapTemplate = concatMapStringsSep "\n";

  mapTemplateWithIndex = concatImapStringsSep "\n";

  mod = a: b: a - (b * (a / b));

  isOdd = a: (mod a 2) == 1;

  isEven = a: (mod a 2) == 0;

  parseDate =
    date:
    let
      year = default (substring 0 4 date) "1970";
      month = default (substring 5 2 date) "01";
      day = default (substring 8 2 date) "01";
      hour = default (substring 11 2 date) "00";
      minut = default (substring 14 2 date) "00";
      second = default (substring 17 2 date) "00";
      default = x: default: if (x == "") then default else x;
      monthConv = {
        "01" = {
          b = "Jan";
          B = "January";
        };
        "02" = {
          b = "Feb";
          B = "February";
        };
        "03" = {
          b = "Mar";
          B = "March";
        };
        "04" = {
          b = "Apr";
          B = "April";
        };
        "05" = {
          b = "May";
          B = "May";
        };
        "06" = {
          b = "Jun";
          B = "June";
        };
        "07" = {
          b = "Jul";
          B = "July";
        };
        "08" = {
          b = "Aug";
          B = "August";
        };
        "09" = {
          b = "Sep";
          B = "September";
        };
        "10" = {
          b = "Oct";
          B = "October";
        };
        "11" = {
          b = "Nov";
          B = "November";
        };
        "12" = {
          b = "Dec";
          B = "December";
        };
      };
      doNotPad =
        x:
        let
          m = builtins.match "^0+([0-9]+)$" x;
        in
        if m != null then elemAt m 0 else x;
    in
    rec {
      # shortcuts
      date = {
        num = "${YYYY}-${MM}-${DD}";
        lit = "${D} ${B} ${YYYY}";
      };
      time = "${hh}:${mm}:${ss}";
      T = "${date.num}T${time}Z";
      # year
      YYYY = year;
      YY = substring 2 4 year;
      Y = YYYY;
      y = YY;
      # month
      MM = month;
      M = doNotPad MM;
      m = MM;
      m- = M;
      inherit (monthConv."${MM}") b;
      inherit (monthConv."${MM}") B;
      # day
      DD = day;
      D = doNotPad DD;
      d- = D;
      # hour
      hh = hour;
      h = doNotPad hh;
      # minut
      mm = minut;
      # second
      ss = second;
    };
}
