<?php
$root_dir = dirname(dirname(__FILE__));

$options_short = "p::";
$options_long  = array(
    "password::"
);
$options = getopt($options_short, $options_long);

require_once "$root_dir/common/emoncmscore.php";
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
