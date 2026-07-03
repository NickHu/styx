env:
let
  template = { lib, ... }: with lib; content: ''<span class="badge">${toString content}</span>'';
in
template env
