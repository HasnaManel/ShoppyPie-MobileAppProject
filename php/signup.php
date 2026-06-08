<?php
$conn = new mysqli("localhost", "root", "", "projet");

$email = $_POST['email'];
$password = $_POST['password'];
$type = $_POST['type'];
$store = $_POST['store'];

$sql = "INSERT INTO users (email, password, type, store) VALUES ('$email', '$password', '$type', '$store')";
$conn->query($sql);

echo json_encode(["error" => false, "message" => "User registered"]);
?>
