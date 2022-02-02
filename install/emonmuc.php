<?php
define('EMONCMS_EXEC', 1);

$options_short = "d::";
$options_short .= "p::";
$options_short .= "a::";
$options_long  = array(
    "dir:",
    "port::",
    "apikey::"
);
$options = getopt($options_short, $options_long);

if (isset($options['d'])) {
    $dir = $options['d'];
}
else if (isset($options['dir'])) {
    $dir = $options['dir'];
}
else {
    $dir = "/var/www/emoncms";
}
if(substr_compare($dir, '/', strlen($dir)-1, 1) !== 0) {
    $dir = $dir."/";
}
chdir($dir);
require "process_settings.php";
require "core.php";

require_once "Lib/EmonLogger.php";

# Check MySQL PHP modules are loaded
if (!extension_loaded('mysql') && !extension_loaded('mysqli')){
    echo "Your PHP installation appears to be missing the MySQL extension(s) which are required by Emoncms."; die;
}

# Check Gettext PHP  module is loaded
if (!extension_loaded('gettext')){
    echo "Your PHP installation appears to be missing the gettext extension which is required by Emoncms."; die;
}
$mysqli = @new mysqli(
    $settings['sql']['server'],
    $settings['sql']['username'],
    $settings['sql']['password'],
    $settings['sql']['database'],
    $settings['sql']['port']
    );
if ($mysqli->connect_error) {
    echo "Can't connect to database, please verify credentials/configuration in settings.php"; die;
}
// Set charset to utf8
$mysqli->set_charset("utf8");

if ($settings['redis']['enabled']) {
    $redis = new Redis();
    $connected = $redis->connect($settings['redis']['host'], $settings['redis']['port']);
    if (!$connected) { echo "Can't connect to redis at ".$settings['redis']['host'].":".$settings['redis']['port']." , it may be that redis-server is not installed or started see readme for redis installation"; die; }
    if (!empty($settings['redis']['prefix'])) $redis->setOption(Redis::OPT_PREFIX, $settings['redis']['prefix']);
    if (!empty($settings['redis']['auth'])) {
        if (!$redis->auth($settings['redis']['auth'])) {
            echo "Can't connect to redis at ".$settings['redis']['host'].", autentication failed"; die;
        }
    }
    if (!empty($settings['redis']['dbnum'])) {
        $redis->select($settings['redis']['dbnum']);
    }
}
else {
    $redis = false;
}

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
    
    // Only register controller, if none exists jet
    if (count($ctrl->get_list($userid)) < 1) {
        if (isset($options['p']) || isset($options['port'])) {
            $port = isset($options['p']) ? $options['p'] : $options['port'];;
        }
        else {
            $port = 8080;
        }
        $ctrl->create($userid, 'http', 'Local', '', '{"address":"localhost","port":'.$port.'}');
    }
    $config = '/opt/openmuc/conf/emoncms.conf';

    if (!is_writable('/opt/openmuc/conf') || (is_file($config) && !is_writable($config))) {
        echo "Unable to edit emoncms configution file in /opt/openmuc/conf\n";
        die;
    }

    $contents = file_get_contents($config);
    $contents = str_replace(';authorization', 'authorization', $contents);
    $contents = str_replace(';authentication', 'authentication', $contents);
    $contents = str_replace('authentication = API_KEY', 'authentication = '.$apikey, $contents);
    file_put_contents($config, $contents);
}
catch(Exception $e) {
    echo "Unable to register controller for user $userid: ".$e->getMessage()."\n";
}
