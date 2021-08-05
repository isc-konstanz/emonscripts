<?php

// Update Emoncms database

$root_dir = dirname(dirname(__FILE__));

$applychanges = true;

require_once "$root_dir/common/emoncmscore.php";
require_once "Lib/dbschemasetup.php";
print json_encode(db_schema_setup($mysqli, load_db_schema(), $applychanges))."\n";
