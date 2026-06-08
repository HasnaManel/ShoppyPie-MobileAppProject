<?php

error_reporting(E_ALL);
ini_set('display_errors', 1);

$db = "projet";
$dbuser = "root"; 
$dbpassword = ""; 
$dbhost = "localhost";

$link = mysqli_connect($dbhost, $dbuser, $dbpassword, $db);

// Get raw POST data
$data = json_decode(file_get_contents("php://input"), true);

// Basic validation
if (!$data || !isset($data['id'])) {
    die(json_encode(["success" => false, "message" => "Missing album ID"]));
}

$id = $data['id'];

// Delete query
$query = "DELETE FROM albums WHERE id = '$id'";

$result = mysqli_query($link, $query);

if ($result) {
    echo json_encode(["success" => true, "message" => "Album deleted successfully"]);
} else {
    echo json_encode(["success" => false, "message" => "Delete failed: " . mysqli_error($link)]);
}
?>
