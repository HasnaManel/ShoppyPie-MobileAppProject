<?php
// Enable error reporting for debugging
error_reporting(E_ALL);
ini_set('display_errors', 1);

$db = "projet";
$dbuser = "root";
$dbpassword = "";
$dbhost = "localhost";
$link = mysqli_connect($dbhost, $dbuser, $dbpassword, $db);

if (isset($_POST['email']) && isset($_POST['password'])) {
    $email = $_POST['email'];
    $password = $_POST['password'];

    $query = "SELECT id, type, store FROM users WHERE email='$email' AND password='$password'";
    $result = mysqli_query($link, $query);

    if(mysqli_num_rows($result) > 0) {
        $row = mysqli_fetch_assoc($result);
        $response = [
            'error' => false,
            'id' => $row['id'],
            'type' => $row['type'],
            'store' => $row['store']
        ];
        
    } else {
        $response = [
            'error' => true,
            'message' => "Invalid email or password"
        ];
    }
} else {
    $response = [
        'error' => true,
        'message' => "Email and password are required"
    ];
}

echo json_encode($response);
?>
