env:
let
  template =
    {
      lib,
      templates,
      ...
    }:
    {
      pages,
      index,
    }:
    with lib;
    let
      prevItem = if (index > 1) then elemAt pages (index - 2) else null;
      nextItem = if (index < (length pages)) then elemAt pages index else null;
    in
    ''
      <nav aria-label="...">
      <ul class="pager">
      ${optionalString (prevItem != null)
        ''<li class="previous">${
          templates.tag.ilink {
            to = prevItem;
            content = ''<span aria-hidden="true">&larr;</span> ${prevItem.title or "Previous"}'';
          }
        }</li>''
      }
      ${optionalString (nextItem != null)
        ''<li class="next">${
          templates.tag.ilink {
            to = nextItem;
            content = ''${nextItem.title or "Next"} <span aria-hidden="true">&rarr;</span>'';
          }
        }</li>''
      }
      </ul>
      </nav>
    '';
in
template env
