#!/bin/bash

emb_module_id="wds-doc_and_source_for_drivers"
emb_module_desc="wds-doc_and_source_for_drivers"
emb_module_help="/opt/embox/hardwares/wds-doc_and_source_for_drivers"
emb_module_section="bsp"

function sources_wds-doc_and_source_for_drivers() {
    gitPullOrClone "$md_build" https://e.coding.net/weidongshan/linux/doc_and_source_for_drivers.git
}