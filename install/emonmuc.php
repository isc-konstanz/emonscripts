<?php
$root_dir = dirname(dirname(__FILE__));

$options_short = "a::";
$options_short .= "p::";
$options_long  = array(
    "apikey::",
    "port::"
);
$options = getopt($options_short, $options_long);

require_once "$root_dir/common/emoncmscore.php";
require_once "Modules/user/user_model.php";
$user = new User($mysqli, $redis);

if (isset($options['a']) || isset($options['apikey'])) {
    $apikey = isset($options['a']) ? $options['a'] : $options['apikey'];
    if (strlen($apikey) != 32) {
        echo "Invalid apikey: $apikey\n"; die;
    }
    $session = $user->apikey_session($apikey);
    $userid = $session['userid'];
}
else {
    $result = $mysqli->query("SELECT id FROM users ORDER BY id ASC LIMIT 1");
    $userid = $result->fetch_object()->id;
    $apikey = $user->get_apikey_write($userid);
}

if (!is_dir('/opt/openmuc')) {
    // OpenMUC not installed
    return;
}
try {
    require_once "Modules/muc/muc_model.php";
    $ctrl = new Controller($mysqli, $redis);

    if (count($ctrl->get_list($userid)) < 1) {
        // Only register controller, if none exists jet
        if (isset($options['p']) || isset($options['port'])) {
            $port = isset($options['p']) ? $options['p'] : $options['port'];;
        }
        else {
            $port = 8080;
        }
        $ctrl->create($userid, 'http', 'Local', '', '{"address":"localhost","port":'.$port.'}');
    }

    if (!is_writable('/opt/openmuc/conf') || (is_file('/opt/openmuc/conf/emoncms.conf') && !is_writable('/opt/openmuc/conf/emoncms.conf'))) {
        echo "Unable to edit emoncms configution file in /opt/openmuc/conf\n";
        die;
    }
    $config = '/opt/openmuc/conf/emoncms.conf';

    if (!is_file($config)) {
        $config = $root_dir.'/conf/emoncms.default.conf';
    }
    if (!is_file($config)) {
        echo "Unable to find default emoncms configuration $config\n";
        die;
    }

    $contents = file_get_contents($config);
    $contents = str_replace(';authorization', 'authorization', $contents);
    $contents = str_replace(';authentication', 'authentication', $contents);
    $contents = str_replace('authentication = API_KEY', 'authentication = '.$apikey, $contents);
    file_put_contents('/opt/openmuc/conf/emoncms.conf', $contents);
}
catch(Exception $e) {
    echo "Unable to register controller for user $userid: ".$e->getMessage()."\n";
}
