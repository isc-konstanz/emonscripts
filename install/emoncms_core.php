<?php
define('EMONCMS_EXEC', 1);

$root_dir = dirname(dirname(__FILE__));

$options_short = "d:";
$options_short .= "p:";
$options_long  = array(
    "dir:",
    "password:"
);
$options = getopt($options_short, $options_long);

if (isset($options['d'])) {
    $emoncms_dir = $options['d'];
}
else if (isset($options['dir'])) {
    $emoncms_dir = $options['dir'];
}
else {
    $emoncms_dir = "/var/www/emoncms";
}
if(substr_compare($emoncms_dir, '/', strlen($emoncms_dir)-1, 1) !== 0) {
    $emoncms_dir = $emoncms_dir."/";
}
chdir($emoncms_dir);

require_once "core.php";
require_once "process_settings.php";

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
