<?php
define('EMONCMS_EXEC', 1);

$options_short = "d::";
$options_short .= "p::";
$options_long  = array(
    "dir:",
    "password::"
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

if (isset($options['p']) || isset($options['password'])) {
    $password = isset($options['p']) ? $options['p'] : $options['password'];
}
else {
    $password = 'admin';
}

if ($user->get_number_of_users() == 0) {
    $email = 'admin@'.gethostname().'.local';
    $result = $user->register('admin', $password, $email, date_default_timezone_get());

    if (isset($result['success']) && $result['success'] == false) {
        echo "Unable to register default user \"admin\": ".$result['message']."\n"; die;
    }
}