<?php

error_reporting(E_ALL);
ini_set('display_errors', 1);

$db = "projet";
$dbuser = "root"; 
$dbpassword = ""; 
$dbhost = "localhost";

$link = mysqli_connect($dbhost, $dbuser, $dbpassword, $db);

$data = json_decode(file_get_contents("php://input"), true);

if (!$data || !isset($data['id'])) {
    die(json_encode(["success" => false, "message" => "Missing book ID"]));
}

$id = $data['id'];

$query = "DELETE FROM books WHERE id = '$id'";

$result = mysqli_query($link, $query);

if ($result) {
    echo json_encode(["success" => true, "message" => "book deleted successfully"]);
} else {
    echo json_encode(["success" => false, "message" => "Delete failed: " . mysqli_error($link)]);
}
?>
