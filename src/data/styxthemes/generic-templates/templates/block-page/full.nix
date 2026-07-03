{
  lib,
  templates,
  ...
}:
lib.normalTemplate (page: lib.processBlocks page.blocks)
